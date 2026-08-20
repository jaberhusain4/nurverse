import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class QuranTranslationEdition {
  final String id;
  final String title;
  final String author;
  final int? quranComId;
  final bool localMuhiuddin;

  const QuranTranslationEdition({
    required this.id,
    required this.title,
    required this.author,
    this.quranComId,
    this.localMuhiuddin = false,
  });
}

class QuranTranslationService {
  QuranTranslationService._();
  static final QuranTranslationService instance = QuranTranslationService._();

  static const editions = <QuranTranslationEdition>[
    QuranTranslationEdition(
      id: 'muhiuddin-khan',
      title: 'মুহিউদ্দীন খান',
      author: 'প্রচলিত বাংলা অনুবাদ',
      quranComId: null,
      localMuhiuddin: true,
    ),
    QuranTranslationEdition(
      id: 'taisirul-quran',
      title: 'তাইসীরুল কুরআন',
      author: 'তাওহীদ পাবলিকেশন',
      quranComId: 161,
    ),
    QuranTranslationEdition(
      id: 'sheikh-mujibur-rahman',
      title: 'শাইখ মুজিবুর রহমান',
      author: 'দারুসসালাম পাবলিকেশন',
      quranComId: 163,
    ),
    QuranTranslationEdition(
      id: 'rawai-al-bayan',
      title: 'রাওয়াইউল বায়ান',
      author: 'বয়ান ফাউন্ডেশন',
      quranComId: 162,
    ),
  ];

  Future<Directory> _cacheDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/nurverse_translations');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _cacheFile(String editionId, int surahNumber) async {
    final dir = await _cacheDirectory();
    return File('${dir.path}/${editionId}_$surahNumber.json');
  }

  Future<Map<int, String>> getSurahTranslation({
    required QuranTranslationEdition edition,
    required int surahNumber,
    Map<int, String>? localMuhiuddin,
  }) async {
    if (edition.localMuhiuddin) {
      return Map<int, String>.from(localMuhiuddin ?? const <int, String>{});
    }

    final cache = await _cacheFile(edition.id, surahNumber);
    try {
      if (await cache.exists()) {
        final decoded = jsonDecode(await cache.readAsString());
        final cached = _parse(decoded);
        if (cached.isNotEmpty) return cached;
      }
    } catch (_) {
      // Re-download a bad/missing cache.
    }

    final translationId = edition.quranComId;
    if (translationId == null) return const <int, String>{};

    final uri = Uri.https(
      'api.quran.com',
      '/api/v4/quran/translations/$translationId',
      {
        'fields': 'verse_number,chapter_id,verse_key',
        'chapter_number': '$surahNumber',
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('অনুবাদ ডাউনলোড ব্যর্থ হয়েছে (${response.statusCode})');
    }

    await cache.writeAsString(response.body);
    return _parse(jsonDecode(response.body));
  }

  Map<int, String> _parse(dynamic decoded) {
    final result = <int, String>{};
    final translations = decoded is Map ? decoded['translations'] : null;
    if (translations is! List) return result;

    for (final item in translations) {
      if (item is! Map) continue;
      final verseNumber = int.tryParse(item['verse_number']?.toString() ?? '');
      final text = item['text']?.toString();
      if (verseNumber == null || text == null || text.trim().isEmpty) continue;
      result[verseNumber] = _stripHtml(text).trim();
    }
    return result;
  }

  String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }
}
