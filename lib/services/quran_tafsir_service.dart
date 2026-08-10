import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class QuranTafsirEdition {
  final String slug;
  final String title;

  const QuranTafsirEdition({
    required this.slug,
    required this.title,
  });
}

class QuranTafsirService {
  QuranTafsirService._();
  static final QuranTafsirService instance = QuranTafsirService._();

  static const String _baseUrl =
      'https://cdn.jsdelivr.net/gh/spa5k/tafsir_api@main/tafsir/editions';

  static const List<QuranTafsirEdition> editions = [
    QuranTafsirEdition(
      slug: 'bengali-mokhtasar',
      title: 'বাংলা সংক্ষিপ্ত তাফসির (মুখতাসার)',
    ),
    QuranTafsirEdition(
      slug: 'bn-tafsir-abu-bakr-zakaria',
      title: 'তাফসির আবু বকর যাকারিয়া',
    ),
    QuranTafsirEdition(
      slug: 'bn-tafseer-ibn-e-kaseer',
      title: 'তাফসির ইবনে কাসীর',
    ),
    QuranTafsirEdition(
      slug: 'bn-tafsir-ahsanul-bayaan',
      title: 'তাফসির আহসানুল বায়ান',
    ),
  ];

  Future<Directory> _cacheDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/nurverse_tafsir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _cacheFile(String slug, int surahNumber) async {
    final dir = await _cacheDirectory();
    final safeSlug = slug.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return File('${dir.path}/${safeSlug}_$surahNumber.json');
  }

  Future<Map<int, String>> getSurahTafsir({
    required String slug,
    required int surahNumber,
  }) async {
    final cache = await _cacheFile(slug, surahNumber);

    try {
      if (await cache.exists()) {
        final text = await cache.readAsString();
        final parsed = _parse(text);
        if (parsed.isNotEmpty) return parsed;
      }
    } catch (_) {
      // A stale/corrupt cache should never block the online request.
    }

    final uri = Uri.parse('$_baseUrl/$slug/$surahNumber.json');
    final response = await http.get(uri).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('তাফসির ডাউনলোড ব্যর্থ হয়েছে (${response.statusCode})');
    }

    await cache.writeAsString(response.body);
    return _parse(response.body);
  }

  Map<int, String> _parse(String body) {
    final decoded = jsonDecode(body);
    final result = <int, String>{};

    void readItem(dynamic item) {
      if (item is! Map) return;

      final rawAyah = item['ayah'] ??
          item['ayah_number'] ??
          item['verse'] ??
          item['verse_number'] ??
          item['number'];
      final rawText = item['text'] ??
          item['tafsir'] ??
          item['translation'] ??
          item['content'];

      final ayah = int.tryParse(rawAyah?.toString() ?? '');
      if (ayah == null || rawText == null) return;

      final cleaned = _stripHtml(rawText.toString()).trim();
      if (cleaned.isNotEmpty) {
        result[ayah] = cleaned;
      }
    }

    if (decoded is List) {
      for (final item in decoded) {
        readItem(item);
      }
    } else if (decoded is Map) {
      final ayahs = decoded['ayahs'] ??
          decoded['verses'] ??
          decoded['tafsirs'] ??
          decoded['data'];

      if (ayahs is List) {
        for (final item in ayahs) {
          readItem(item);
        }
      } else if (ayahs is Map) {
        for (final entry in ayahs.entries) {
          final key = int.tryParse(entry.key.toString());
          final value = entry.value;
          if (key == null) continue;
          if (value is Map) {
            final text = value['text'] ?? value['tafsir'] ?? value['content'];
            if (text != null) {
              final cleaned = _stripHtml(text.toString()).trim();
              if (cleaned.isNotEmpty) result[key] = cleaned;
            }
          } else if (value != null) {
            final cleaned = _stripHtml(value.toString()).trim();
            if (cleaned.isNotEmpty) result[key] = cleaned;
          }
        }
      } else {
        // Some static datasets use an object keyed directly by ayah number.
        for (final entry in decoded.entries) {
          final key = int.tryParse(entry.key.toString());
          if (key == null) continue;
          final value = entry.value;
          if (value is Map) {
            final text = value['text'] ?? value['tafsir'] ?? value['content'];
            if (text != null) {
              final cleaned = _stripHtml(text.toString()).trim();
              if (cleaned.isNotEmpty) result[key] = cleaned;
            }
          }
        }
      }
    }

    return result;
  }

  String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }
}
