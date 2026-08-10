import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

/// A physical PDF page is what pdfx uses (1..610).
/// A printed Hafezi page is the number printed inside the PDF (2..611).
/// Users of NurVerse should NOT use the printed number for navigation.
/// They navigate by Para + page-within-Para.
class HafeziPageLocation {
  final int pdfPage;
  final int printedPage;
  final int juzNumber;
  final int pageInJuz;
  final int juzPageCount;

  const HafeziPageLocation({
    required this.pdfPage,
    required this.printedPage,
    required this.juzNumber,
    required this.pageInJuz,
    required this.juzPageCount,
  });

  // Compatibility aliases for screen code.
  int get juz => juzNumber;
  int get page => pageInJuz;
  int get pageNumber => pageInJuz;
  int get globalPage => printedPage;
  int get pdfPageNumber => pdfPage;
  int get printedPageNumber => printedPage;
  int get hafeziPage => pageInJuz;
  int get totalPages => juzPageCount;
}

class HafeziJuzInfo {
  final int juz;
  final String name;
  final String arabicName;
  final int startPdfPage;
  final int endPdfPage;
  final int pageCount;

  const HafeziJuzInfo({
    required this.juz,
    required this.name,
    required this.arabicName,
    required this.startPdfPage,
    required this.endPdfPage,
    required this.pageCount,
  });

  int get startPage => startPdfPage;
  int get endPage => endPdfPage;
}

class HafeziSurahInfo {
  final int number;
  final String arabicName;
  final String englishName;
  final int verses;
  final String revelationType;
  final int startPdfPage;

  const HafeziSurahInfo({
    required this.number,
    required this.arabicName,
    required this.englishName,
    required this.verses,
    required this.revelationType,
    required this.startPdfPage,
  });

  // Compatibility with the older implementation.
  int get startPage => startPdfPage;
}

class HafeziQuranService {
  HafeziQuranService._();
  static final HafeziQuranService instance = HafeziQuranService._();

  static const String pdfAsset = 'assets/quran/nurverse_hafezi_quran.pdf';
  static const String quranDataAsset = 'assets/quran/quran_ar.json';

  /// The NurVerse Hafezi asset contains only the Quran pages: 610 physical pages.
  /// The source PDF has extra cover/front-matter and end pages; the app asset is trimmed
  /// to the Quran itself so pdfx page 1 corresponds to printed Hafezi page 2.
  /// Its printed Hafezi numbers run from 2 through 611.
  static const int fallbackPdfPageCount = 610;
  static const int printedFirstPage = 2;
  static const int printedLastPage = 611;

  static const String _lastPdfPageKey = 'hafezi_last_pdf_page_v2';
  static const String _bookmarkKey = 'hafezi_bookmarks_pdf_v2';

  bool _initialized = false;
  int _pdfPageCount = fallbackPdfPageCount;
  List<HafeziJuzInfo> _juzList = const [];
  List<HafeziSurahInfo> _surahs = const [];

  static const List<String> _juzNames = [
    'Alif Laam Meem',
    'Sayaqool',
    'Tilkal Rusul',
    'Lan Tana Loo',
    'Wal Mohsanat',
    'La Yuhibbullah',
    'Wa Iza Samiu',
    'Wa Lau Annana',
    'Qalal Malao',
    "Wa A'lamu",
    'Yatazeroon',
    'Wa Mamin Daabbah',
    'Wa Ma Ubrioo',
    'Rubama',
    'Subhanallazi',
    'Qal Alam',
    'Iqtaraba',
    'Qadd Aflaha',
    'Wa Qalallazina',
    'Aman Khalaq',
    'Utlu Ma Oohi',
    'Wa Manyaqnut',
    'Wa Mali',
    'Faman Azlam',
    'Elahe Yuruddo',
    'Haa Meem',
    'Qala Fama Khatbukum',
    'Qadd Sami Allah',
    'Tabarakallazi',
    'Amma Yatasaaloon',
  ];

  static const List<String> _juzArabicNames = [
    'آلم',
    'سَيَقُولُ',
    'تِلْكَ الرُّسُلُ',
    'لَنْ تَنَالُوا',
    'وَالْمُحْصَنَاتُ',
    'لَا يُحِبُّ اللَّهُ',
    'وَإِذَا سَمِعُوا',
    'وَلَوْ أَنَّنَا',
    'قَالَ الْمَلَأُ',
    'وَاعْلَمُوا',
    'يَعْتَذِرُونَ',
    'وَمَا مِنْ دَابَّةٍ',
    'وَمَا أُبَرِّئُ',
    'رُبَمَا',
    'سُبْحَانَ الَّذِي',
    'قَالَ أَلَمْ',
    'اقْتَرَبَ',
    'قَدْ أَفْلَحَ',
    'وَقَالَ الَّذِينَ',
    'أَمَّنْ خَلَقَ',
    'اتْلُ مَا أُوحِيَ',
    'وَمَنْ يَقْنُتْ',
    'وَمَا لِيَ',
    'فَمَنْ أَظْلَمُ',
    'إِلَيْهِ يُرَدُّ',
    'حم',
    'قَالَ فَمَا خَطْبُكُمْ',
    'قَدْ سَمِعَ اللَّهُ',
    'تَبَارَكَ الَّذِي',
    'عَمَّ يَتَسَاءَلُونَ',
  ];

  /// Physical PDF start page for each Para.
  /// Verified against the supplied 15-line PDF:
  /// Para 1 = PDF page 1 (printed 2)
  /// Para 2 = PDF page 22 (printed 23)
  /// ...
  /// Para 28 = PDF page 542 (printed 543)
  /// Para 29 = PDF page 562 (printed 563)
  /// Para 30 = PDF page 586 (Hafezi/printed page 587)
  static const List<int> _juzStartPdfPages = [
    1,
    22,
    42,
    62,
    82,
    102,
    122,
    142,
    162,
    182,
    202,
    222,
    242,
    262,
    282,
    302,
    322,
    342,
    362,
    382,
    402,
    422,
    442,
    462,
    482,
    502,
    522,
    542,
    562,
    586,
  ];

  static List<HafeziJuzInfo> getJuzList() {
    final result = <HafeziJuzInfo>[];
    for (var i = 0; i < 30; i++) {
      final start = _juzStartPdfPages[i];
      final end = i == 29 ? fallbackPdfPageCount : _juzStartPdfPages[i + 1] - 1;
      result.add(
        HafeziJuzInfo(
          juz: i + 1,
          name: _juzNames[i],
          arabicName: _juzArabicNames[i],
          startPdfPage: start,
          endPdfPage: end,
          pageCount: end - start + 1,
        ),
      );
    }
    return List.unmodifiable(result);
  }

  bool get isInitialized => _initialized;
  int get pageCount => _pdfPageCount;
  int get pdfPageCount => _pdfPageCount;
  List<HafeziJuzInfo> get juzs => _juzList;
  List<HafeziJuzInfo> get juzList => _juzList;
  List<HafeziSurahInfo> get surahs => _surahs;

  Future<void> init() async {
    if (_initialized) return;

    _juzList = getJuzList();
    await _loadSurahMetadata();
    _initialized = true;
  }

  void setActualPageCount(int count) {
    if (count > 0) _pdfPageCount = count;
  }

  // Compatibility alias.
  void setPageCount(int count) => setActualPageCount(count);

  int normalizePdfPage(int page) {
    if (page < 1) return 1;
    if (page > _pdfPageCount) return _pdfPageCount;
    return page;
  }

  int normalizePage(int page) => normalizePdfPage(page);

  int printedPageForPdfPage(int pdfPage) => normalizePdfPage(pdfPage) + 1;

  int pdfPageForPrintedPage(int printedPage) =>
      normalizePdfPage(printedPage - printedFirstPage + 1);

  HafeziJuzInfo getJuz(int juzNumber) {
    if (_juzList.isEmpty) _juzList = getJuzList();
    final safe = juzNumber.clamp(1, 30).toInt();
    return _juzList[safe - 1];
  }

  int pageForJuz(int juzNumber) => getJuz(juzNumber).startPdfPage;

  int pdfPageForJuzPage(int juzNumber, int pageInJuz) {
    final juz = getJuz(juzNumber);
    final safePage = pageInJuz.clamp(1, juz.pageCount).toInt();
    return juz.startPdfPage + safePage - 1;
  }

  HafeziPageLocation locationForPdfPage(int pdfPage) {
    final safePdfPage = normalizePdfPage(pdfPage);
    HafeziJuzInfo? found;

    for (final juz in _juzList.isEmpty ? getJuzList() : _juzList) {
      if (safePdfPage >= juz.startPdfPage && safePdfPage <= juz.endPdfPage) {
        found = juz;
        break;
      }
    }

    found ??= getJuz(30);

    return HafeziPageLocation(
      pdfPage: safePdfPage,
      printedPage: printedPageForPdfPage(safePdfPage),
      juzNumber: found.juz,
      pageInJuz: safePdfPage - found.startPdfPage + 1,
      juzPageCount: found.pageCount,
    );
  }

  Future<int> getLastReadPdfPage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_lastPdfPageKey) ?? 1;
    return normalizePdfPage(saved);
  }

  Future<void> saveLastReadPdfPage(int pdfPage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPdfPageKey, normalizePdfPage(pdfPage));
  }

  // Compatibility aliases used by older Hafezi screens.
  Future<int> getLastReadPage() => getLastReadPdfPage();
  Future<void> saveLastReadPage(int page) => saveLastReadPdfPage(page);

  Future<Set<int>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_bookmarkKey) ?? const <String>[])
        .map(int.tryParse)
        .whereType<int>()
        .map(normalizePdfPage)
        .toSet();
  }

  Future<bool> isBookmarked(int pdfPage) async {
    final bookmarks = await getBookmarks();
    return bookmarks.contains(normalizePdfPage(pdfPage));
  }

  Future<void> toggleBookmark(int pdfPage) async {
    final safePage = normalizePdfPage(pdfPage);
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();

    if (bookmarks.contains(safePage)) {
      bookmarks.remove(safePage);
    } else {
      bookmarks.add(safePage);
    }

    final sorted = bookmarks.toList()..sort();
    await prefs.setStringList(
      _bookmarkKey,
      sorted.map((e) => e.toString()).toList(),
    );
  }

  Future<void> clearBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bookmarkKey);
  }

  HafeziSurahInfo? getSurah(int surahNumber) {
    for (final surah in _surahs) {
      if (surah.number == surahNumber) return surah;
    }
    return null;
  }

  int pageForSurah(int surahNumber) => getSurah(surahNumber)?.startPdfPage ?? 1;

  Future<void> _loadSurahMetadata() async {
    try {
      final raw = await rootBundle.loadString(quranDataAsset);
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        _surahs = const [];
        return;
      }

      // These are the page positions in the supplied 15-line layout.
      // They are PDF physical page numbers, not the printed numbers.
      // Page map for the supplied 15-line Hafezi layout.
      // The reference index uses its own page numbering where Al-Fatiha is
      // page 1 and Al-Baqarah starts at page 3. In the NurVerse PDF asset,
      // Al-Fatiha is physical PDF page 1 and Al-Baqarah starts at physical
      // PDF page 2, so from Surah 2 onward we subtract one.
      //
      // This is intentionally a fixed map for this exact Hafezi layout;
      // quran_ar.json does not contain page positions for this scanned PDF.
      const referencePages = <int>[
        1,
        3,
        51,
        78,
        107,
        129,
        152,
        178,
        188,
        209,
        222,
        236,
        250,
        256,
        262,
        268,
        283,
        294,
        306,
        313,
        323,
        332,
        343,
        351,
        360,
        367,
        377,
        386,
        397,
        405,
        412,
        416,
        419,
        429,
        435,
        441,
        446,
        453,
        459,
        468,
        478,
        484,
        490,
        496,
        499,
        503,
        507,
        512,
        516,
        519,
        521,
        524,
        527,
        529,
        532,
        535,
        538,
        543,
        546,
        550,
        552,
        554,
        555,
        557,
        559,
        561,
        563,
        565,
        568,
        570,
        572,
        574,
        577,
        579,
        581,
        583,
        585,
        587,
        588,
        590,
        591,
        592,
        593,
        595,
        596,
        597,
        598,
        599,
        600,
        601,
        602,
        603,
        603,
        603,
        604,
        605,
        605,
        606,
        606,
        607,
        607,
        607,
        608,
        608,
        608,
        609,
        609,
        609,
        610,
        610,
        610,
        610,
        611,
        611,
      ];

      final fallback = <int, int>{
        for (var i = 0; i < referencePages.length; i++)
          i + 1: i == 0 ? 1 : referencePages[i] - 1,
      };

      final result = <HafeziSurahInfo>[];
      for (final item in decoded) {
        if (item is! Map) continue;

        int readInt(dynamic value) => int.tryParse('$value') ?? 0;
        String readString(dynamic value) => value?.toString() ?? '';

        final number = readInt(item['id']);
        if (number < 1 || number > 114) continue;

        result.add(
          HafeziSurahInfo(
            number: number,
            arabicName: readString(item['name']),
            englishName: readString(item['transliteration']),
            verses: readInt(item['total_verses']),
            revelationType: readString(item['type']),
            startPdfPage: fallback[number] ?? 1,
          ),
        );
      }
      _surahs = List.unmodifiable(result);
    } catch (_) {
      _surahs = const [];
    }
  }
}
