import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../data/juz_boundaries.dart';
import '../models/quran_surah.dart';

/// Loads the full Quran (Arabic text is bundled inside the app so it is
/// available fully offline from first install) and the Bangla translation
/// (downloaded once from a public CDN and cached to disk, so it works
/// offline for every session after the first successful download).
class QuranDataService extends ChangeNotifier {
  QuranDataService._();
  static final QuranDataService instance = QuranDataService._();

  static const String _banglaUrl =
      'https://cdn.jsdelivr.net/npm/quran-json@3.1.2/dist/quran_bn.json';

  List<dynamic> _arabicRaw = [];
  Map<int, dynamic> _banglaRaw = {}; // surah number -> parsed json entry

  bool _loadingCore = false;
  bool get coreLoaded => _arabicRaw.isNotEmpty;

  bool get translationAvailable => _banglaRaw.isNotEmpty;
  bool _downloading = false;
  bool get downloading => _downloading;
  String? downloadError;

  Future<void> init() async {
    if (coreLoaded || _loadingCore) return;
    _loadingCore = true;
    final raw = await rootBundle.loadString('assets/quran/quran_ar.json');
    _arabicRaw = jsonDecode(raw) as List<dynamic>;
    _loadingCore = false;
    await _tryLoadCachedTranslation();
    notifyListeners();
  }

  Future<File> _translationCacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/quran_bn_cache.json');
  }

  Future<void> _tryLoadCachedTranslation() async {
    try {
      final file = await _translationCacheFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        _parseBangla(content);
      }
    } catch (_) {
      // No cache yet -- that's fine, downloadTranslation() will fetch it.
    }
  }

  void _parseBangla(String content) {
    final list = jsonDecode(content) as List<dynamic>;
    _banglaRaw = {for (final s in list) (s['id'] as int): s};
  }

  /// Downloads the Bangla translation (a few MB) once and caches it to
  /// disk. After this succeeds, the translation is available fully
  /// offline forever -- call again any time to re-sync.
  Future<bool> downloadTranslation() async {
    if (_downloading) return false;
    _downloading = true;
    downloadError = null;
    notifyListeners();
    try {
      final response = await http
          .get(Uri.parse(_banglaUrl))
          .timeout(const Duration(seconds: 60));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final file = await _translationCacheFile();
      await file.writeAsString(response.body);
      _parseBangla(response.body);
      _downloading = false;
      notifyListeners();
      return true;
    } catch (e) {
      downloadError = e.toString();
      _downloading = false;
      notifyListeners();
      return false;
    }
  }

  /// Lightweight list for the surah picker (no verses loaded yet).
  List<QuranSurah> get surahList {
    return _arabicRaw.map((s) {
      final id = s['id'] as int;
      final bn = _banglaRaw[id];
      return QuranSurah(
        number: id,
        arabicName: s['name'] as String,
        transliteration: s['transliteration'] as String,
        type: s['type'] as String,
        totalVerses: s['total_verses'] as int,
        banglaName: bn != null ? bn['translation'] as String? : null,
        verses: const [],
      );
    }).toList();
  }

  /// Full surah with every verse (Arabic always present, Bangla present
  /// only if the translation has been downloaded).
  QuranSurah getSurah(int number) {
    final s = _arabicRaw.firstWhere((e) => e['id'] == number);
    final bn = _banglaRaw[number];
    final bnVerses = bn != null ? (bn['verses'] as List<dynamic>) : null;

    final verses = <QuranVerse>[];
    final arVerses = s['verses'] as List<dynamic>;
    for (var i = 0; i < arVerses.length; i++) {
      final v = arVerses[i];
      String? bnText;
      if (bnVerses != null && i < bnVerses.length) {
        bnText = bnVerses[i]['translation'] as String?;
      }
      verses.add(QuranVerse(
        number: v['id'] as int,
        arabic: v['text'] as String,
        bangla: bnText,
      ));
    }

    return QuranSurah(
      number: number,
      arabicName: s['name'] as String,
      transliteration: s['transliteration'] as String,
      type: s['type'] as String,
      totalVerses: s['total_verses'] as int,
      banglaName: bn != null ? bn['translation'] as String? : null,
      verses: verses,
    );
  }

  /// Verses that belong to [juzNumber] (1-30), grouped by surah, in order.
  /// Each entry is (surahNumber, surahTransliteration, verse).
  List<(int, String, QuranVerse)> getJuzVerses(int juzNumber) {
    final start = kJuzBoundaries.firstWhere((j) => j.juz == juzNumber);
    final nextIndex = kJuzBoundaries.indexOf(start) + 1;
    final end = nextIndex < kJuzBoundaries.length
        ? kJuzBoundaries[nextIndex]
        : null; // juz 30 ends at the end of the Quran

    final result = <(int, String, QuranVerse)>[];

    for (final s in _arabicRaw) {
      final surahNum = s['id'] as int;
      if (surahNum < start.surah) continue;
      if (end != null && surahNum > end.surah) break;

      final full = getSurah(surahNum);
      for (final v in full.verses) {
        if (surahNum == start.surah && v.number < start.ayah) continue;
        if (end != null && surahNum == end.surah && v.number >= end.ayah) {
          break;
        }
        result.add((surahNum, full.transliteration, v));
      }
    }
    return result;
  }
}
