// lib/services/hadith_service.dart

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

// ============================================================================
// MODELS
// ============================================================================

class HadithBook {
  final String key;
  final String nameBn;
  final String nameEn;

  const HadithBook({
    required this.key,
    required this.nameBn,
    required this.nameEn,
  });
}

class HadithChapter {
  final int id;
  final int bookNumber;
  final String nameAr;
  final String nameBn;
  final String nameEn;

  const HadithChapter({
    required this.id,
    required this.bookNumber,
    required this.nameAr,
    required this.nameBn,
    required this.nameEn,
  });
}

class HadithItem {
  final String hadithNo;
  final String arabic;
  final String bangla;
  final String english;
  final String narrator;
  final String reference;
  final String grade;

  const HadithItem({
    required this.hadithNo,
    required this.arabic,
    required this.bangla,
    required this.english,
    required this.narrator,
    required this.reference,
    required this.grade,
  });
}

// ============================================================================
// HADITH BOOKS
// ============================================================================

const List<HadithBook> kHadithBooks = [
  HadithBook(key: 'bukhari', nameBn: 'সহিহ বুখারি', nameEn: 'Sahih al-Bukhari'),
  HadithBook(key: 'muslim', nameBn: 'সহিহ মুসলিম', nameEn: 'Sahih Muslim'),
  HadithBook(
    key: 'abudawud',
    nameBn: 'সুনান আবু দাউদ',
    nameEn: 'Sunan Abi Dawud',
  ),
  HadithBook(
    key: 'tirmidhi',
    nameBn: 'জামে আত-তিরমিজি',
    nameEn: 'Jami` at-Tirmidhi',
  ),
  HadithBook(
    key: 'nasai',
    nameBn: 'সুনান আন-নাসাঈ',
    nameEn: 'Sunan an-Nasa\'i',
  ),
  HadithBook(
    key: 'ibnmajah',
    nameBn: 'সুনান ইবন মাজাহ',
    nameEn: 'Sunan Ibn Majah',
  ),
  HadithBook(key: 'malik', nameBn: 'মুয়াত্তা মালিক', nameEn: 'Muwatta Malik'),
];

// ============================================================================
// SERVICE
// ============================================================================

class HadithService {
  HadithService._();

  static final HadithService instance = HadithService._();

  // --------------------------------------------------------------------------
  // CACHE
  // --------------------------------------------------------------------------

  final Map<String, _LoadedEdition> _editionCache = {};

  final Map<String, List<HadithChapter>> _chapterCache = {};

  final Map<String, List<HadithItem>> _hadithCache = {};

  // --------------------------------------------------------------------------
  // PUBLIC API
  // --------------------------------------------------------------------------

  Future<HadithItem> getTodayHadith() async {
    final books = kHadithBooks;

    if (books.isEmpty) {
      throw StateError('No hadith books configured.');
    }

    final now = DateTime.now();

    final seed = now.year * 10000 + now.month * 100 + now.day;

    for (var offset = 0; offset < books.length; offset++) {
      final book = books[(seed + offset) % books.length];

      try {
        final chapters = await getChapters(book.key, languageCode: 'bn');

        if (chapters.isEmpty) {
          continue;
        }

        final chapter = chapters[(seed + offset) % chapters.length];

        final hadiths = await getHadiths(
          book.key,
          chapter.id,
          bookNumber: chapter.bookNumber,
          languageCode: 'bn',
        );

        if (hadiths.isEmpty) {
          continue;
        }

        return hadiths[(seed + offset) % hadiths.length];
      } catch (_) {
        // Try the next available collection if this one cannot be loaded.
      }
    }

    throw StateError('No hadith content is available from the bundled assets.');
  }

  Future<List<HadithChapter>> getChapters(
    String bookKey, {
    String languageCode = 'bn',
  }) async {
    final cacheKey = '$bookKey:$languageCode';

    final cached = _chapterCache[cacheKey];

    if (cached != null) {
      return cached;
    }

    final arabic = await _loadEdition(bookKey, 'ara');

    final requestedLanguage = _normalizeLanguage(languageCode);

    final translated =
        requestedLanguage == 'ar'
            ? arabic
            : await _loadEdition(bookKey, _assetLanguageCode(requestedLanguage));

    final chapters = _extractChapters(
      arabic: arabic,
      translated: translated,
      languageCode: requestedLanguage,
    );

    _chapterCache[cacheKey] = chapters;

    return chapters;
  }

  Future<List<HadithItem>> getHadiths(
    String bookKey,
    int chapterId, {
    int? bookNumber,
    String languageCode = 'bn',
  }) async {
    final language = _normalizeLanguage(languageCode);

    final cacheKey = '$bookKey:$chapterId:${bookNumber ?? 0}:$language';

    final cached = _hadithCache[cacheKey];

    if (cached != null) {
      return cached;
    }

    final arabic = await _loadEdition(bookKey, 'ara');

    final bangla = await _loadEdition(bookKey, _assetLanguageCode('bn'));

    final english = await _loadEdition(bookKey, _assetLanguageCode('en'));

    final hadiths = _extractHadiths(
      arabic: arabic,
      bangla: bangla,
      english: english,
      chapterId: chapterId,
      bookNumber: bookNumber,
      languageCode: language,
    );

    _hadithCache[cacheKey] = hadiths;

    return hadiths;
  }

  // --------------------------------------------------------------------------
  // LOAD EDITION
  // --------------------------------------------------------------------------

  Future<_LoadedEdition> _loadEdition(String bookKey, String language) async {
    final cacheKey = '$language-$bookKey';

    final cached = _editionCache[cacheKey];

    if (cached != null) {
      return cached;
    }

    final path = 'assets/hadith/$language-$bookKey.json';

    try {
      final raw = await rootBundle.loadString(path);

      final decoded = jsonDecode(raw);

      final edition = _extractEdition(decoded);

      _editionCache[cacheKey] = edition;

      return edition;
    } catch (e) {
      throw StateError('Unable to load hadith asset: $path\n$e');
    }
  }

  // --------------------------------------------------------------------------
  // CHAPTER EXTRACTION
  // --------------------------------------------------------------------------

  List<HadithChapter> _extractChapters({
    required _LoadedEdition arabic,
    required _LoadedEdition translated,
    required String languageCode,
  }) {
    final chapterMap = <int, _ChapterBuilder>{};

    void process(_LoadedEdition edition, String language) {
      for (final entry in edition.sectionNames.entries) {
        final builder = chapterMap.putIfAbsent(
          entry.key,
          () => _ChapterBuilder(id: entry.key, bookNumber: 0),
        );

        final name = entry.value.trim();
        if (name.isEmpty) {
          continue;
        }

        if (language == 'ar') {
          builder.nameAr = name;
        } else if (language == 'bn') {
          builder.nameBn = name;
        } else if (language == 'en') {
          builder.nameEn = name;
        }
      }

      for (final item in edition.records) {
        final chapter = _chapterFromItem(item);

        if (chapter == null) {
          continue;
        }

        final builder = chapterMap.putIfAbsent(
          chapter.id,
          () => _ChapterBuilder(id: chapter.id, bookNumber: chapter.bookNumber),
        );

        if (language == 'ar') {
          builder.nameAr = chapter.name;
        } else if (language == 'bn') {
          builder.nameBn = chapter.name;
        } else if (language == 'en') {
          builder.nameEn = chapter.name;
        }
      }
    }

    process(arabic, 'ar');

    if (languageCode == 'bn') {
      process(translated, 'bn');
    } else if (languageCode == 'en') {
      process(translated, 'en');
    }

    final result =
        chapterMap.values
            .map(
              (chapter) => HadithChapter(
                id: chapter.id,
                bookNumber: chapter.bookNumber,
                nameAr: chapter.nameAr,
                nameBn: chapter.nameBn,
                nameEn: chapter.nameEn,
              ),
            )
            .toList();

    result.sort((a, b) {
      if (a.bookNumber != b.bookNumber) {
        return a.bookNumber.compareTo(b.bookNumber);
      }

      return a.id.compareTo(b.id);
    });

    return result;
  }

  // --------------------------------------------------------------------------
  // HADITH EXTRACTION
  // --------------------------------------------------------------------------

  List<HadithItem> _extractHadiths({
    required _LoadedEdition arabic,
    required _LoadedEdition bangla,
    required _LoadedEdition english,
    required int chapterId,
    required int? bookNumber,
    required String languageCode,
  }) {
    final arabicMap = _indexHadiths(arabic, chapterId, bookNumber);

    final banglaMap = _indexHadiths(bangla, chapterId, bookNumber);

    final englishMap = _indexHadiths(english, chapterId, bookNumber);

    final allKeys = <String>{
      ...arabicMap.keys,
      ...banglaMap.keys,
      ...englishMap.keys,
    };

    final sortedKeys = allKeys.toList()..sort(_compareHadithKeys);

    final result = <HadithItem>[];

    for (final key in sortedKeys) {
      final ar = arabicMap[key];
      final bn = banglaMap[key];
      final en = englishMap[key];

      final hadithNo = _firstNonEmpty([
        _value(ar, 'hadithnumber'),
        _value(ar, 'hadithNo'),
        _value(ar, 'number'),
        _value(bn, 'hadithnumber'),
        _value(bn, 'hadithNo'),
        _value(en, 'hadithnumber'),
        _value(en, 'hadithNo'),
        key,
      ]);

      final arabicText = _extractText(ar);

      final banglaText = _extractText(bn);

      final englishText = _extractText(en);

      final narrator = _firstNonEmpty([
        _value(bn, 'narrator'),
        _value(en, 'narrator'),
        _value(ar, 'narrator'),
        _value(bn, 'narratorName'),
        _value(en, 'narratorName'),
      ]);

      final reference = _firstNonEmpty([
        _value(bn, 'reference'),
        _value(en, 'reference'),
        _value(ar, 'reference'),
        _value(bn, 'book'),
        _value(en, 'book'),
      ]);

      final grade = _firstNonEmpty([
        _value(bn, 'grade'),
        _value(en, 'grade'),
        _value(ar, 'grade'),
      ]);

      final item = HadithItem(
        hadithNo: hadithNo,
        arabic: arabicText,
        bangla: banglaText,
        english: englishText,
        narrator: narrator,
        reference: reference,
        grade: grade,
      );

      if (_hasUsefulText(item)) {
        result.add(item);
      }
    }

    return result;
  }

  // --------------------------------------------------------------------------
  // INDEX
  // --------------------------------------------------------------------------

  Map<String, Map<String, dynamic>> _indexHadiths(
    _LoadedEdition edition,
    int chapterId,
    int? bookNumber,
  ) {
    final result = <String, Map<String, dynamic>>{};
    final range = edition.sectionRanges[chapterId];

    for (final item in edition.records) {
      final chapter = _chapterFromItem(item);
      final numberText = _firstNonEmpty([
        _value(item, 'hadithnumber'),
        _value(item, 'hadithNo'),
        _value(item, 'number'),
        _value(item, 'id'),
      ]);

      if (numberText.isEmpty) {
        continue;
      }

      final number = int.tryParse(numberText);
      final matchesChapter =
          chapter != null
              ? chapter.id == chapterId
              : range != null && number != null
                  ? number >= range.firstHadith && number <= range.lastHadith
                  : false;

      if (!matchesChapter) {
        continue;
      }

      if (bookNumber != null &&
          chapter != null &&
          chapter.bookNumber != 0 &&
          chapter.bookNumber != bookNumber) {
        continue;
      }

      final key = '${chapter?.bookNumber ?? 0}:$numberText';

      result[key] = item;
    }

    return result;
  }

  // --------------------------------------------------------------------------
  // CHAPTER PARSING
  // --------------------------------------------------------------------------

  _ParsedChapter? _chapterFromItem(Map<String, dynamic> item) {
    final chapterId = _intValue(
      item['chapterId'] ??
          item['chapter_id'] ??
          item['chapter'] ??
          item['bookId'] ??
          item['book_id'],
    );

    final bookNumber = _intValue(
      item['bookNumber'] ?? item['book_number'] ?? item['book'],
    );

    final chapterName = _firstNonEmpty([
      item['chapterName']?.toString(),
      item['chapter_name']?.toString(),
      item['chapterTitle']?.toString(),
      item['chapter_title']?.toString(),
      item['section']?.toString(),
    ]);

    if (chapterId == null || chapterName.isEmpty) {
      return null;
    }

    return _ParsedChapter(
      id: chapterId,
      bookNumber: bookNumber ?? 0,
      name: chapterName,
    );
  }

  // --------------------------------------------------------------------------
  // GENERIC JSON HELPERS
  // --------------------------------------------------------------------------

  _LoadedEdition _extractEdition(dynamic decoded) {
    final records = _extractDataList(decoded);

    final sectionNames = <int, String>{};
    final sectionRanges = <int, _SectionRange>{};

    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      final metadata = map['metadata'];

      if (metadata is Map) {
        final sections = metadata['sections'];
        if (sections is Map) {
          for (final entry in sections.entries) {
            final index = _intValue(entry.key);
            final name = entry.value?.toString() ?? '';
            if (index != null && name.trim().isNotEmpty) {
              sectionNames[index] = name.trim();
            }
          }
        }

        final sectionDetails = metadata['section_details'];
        if (sectionDetails is Map) {
          for (final entry in sectionDetails.entries) {
            final index = _intValue(entry.key);
            final details = entry.value;
            if (index == null || details is! Map) {
              continue;
            }

            final first = _intValue(details['hadithnumber_first']);
            final last = _intValue(details['hadithnumber_last']);
            if (first != null && last != null) {
              sectionRanges[index] = _SectionRange(firstHadith: first, lastHadith: last);
            }
          }
        }
      }
    }

    return _LoadedEdition(
      records: records,
      sectionNames: sectionNames,
      sectionRanges: sectionRanges,
    );
  }

  List<Map<String, dynamic>> _extractDataList(dynamic decoded) {
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);

      final candidates = [
        map['hadiths'],
        map['data'],
        map['items'],
        map['results'],
        map['chapters'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }

      // Some datasets store the actual records under nested maps. Search recursively for the first meaningful list.
      final nested = _findFirstList(map);

      if (nested != null) {
        return nested
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return const [];
  }

  List<dynamic>? _findFirstList(Map<String, dynamic> map) {
    for (final value in map.values) {
      if (value is List && value.isNotEmpty) {
        return value;
      }

      if (value is Map) {
        final nested = _findFirstList(Map<String, dynamic>.from(value));
        if (nested != null) {
          return nested;
        }
      }
    }

    return null;
  }

  String _extractText(Map<String, dynamic>? item) {
    if (item == null) {
      return '';
    }

    return _firstNonEmpty([
      item['text']?.toString(),
      item['hadith']?.toString(),
      item['hadithText']?.toString(),
      item['hadith_text']?.toString(),
      item['content']?.toString(),
      item['body']?.toString(),
      item['translation']?.toString(),
    ]);
  }

  String _value(Map<String, dynamic>? item, String key) {
    if (item == null) {
      return '';
    }

    return item[key]?.toString().trim() ?? '';
  }

  String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final normalized = value?.trim() ?? '';

      if (normalized.isNotEmpty && normalized != 'null') {
        return normalized;
      }
    }

    return '';
  }

  int? _intValue(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim());
    }

    return null;
  }

  bool _hasUsefulText(HadithItem item) {
    return item.arabic.isNotEmpty || item.bangla.isNotEmpty || item.english.isNotEmpty;
  }

  int _compareHadithKeys(String a, String b) {
    final aParts = a.split(':');
    final bParts = b.split(':');

    final aBook = int.tryParse(aParts.first) ?? 0;
    final bBook = int.tryParse(bParts.first) ?? 0;

    if (aBook != bBook) {
      return aBook.compareTo(bBook);
    }

    final aNo = aParts.length > 1 ? int.tryParse(aParts[1]) ?? 0 : 0;
    final bNo = bParts.length > 1 ? int.tryParse(bParts[1]) ?? 0 : 0;

    return aNo.compareTo(bNo);
  }

  String _assetLanguageCode(String languageCode) {
    switch (_normalizeLanguage(languageCode)) {
      case 'ar':
        return 'ara';
      case 'en':
        return 'eng';
      case 'bn':
      default:
        return 'ben';
    }
  }

  String _normalizeLanguage(String languageCode) {
    switch (languageCode) {
      case 'ar':
      case 'ara':
        return 'ar';
      case 'en':
      case 'eng':
        return 'en';
      case 'bn':
      case 'ben':
      default:
        return 'bn';
    }
  }

  // --------------------------------------------------------------------------
  // CACHE CONTROL
  // --------------------------------------------------------------------------

  void clearCache() {
    _editionCache.clear();
    _chapterCache.clear();
    _hadithCache.clear();
  }
}

// ============================================================================
// INTERNAL HELPERS
// ============================================================================

class _LoadedEdition {
  final List<Map<String, dynamic>> records;
  final Map<int, String> sectionNames;
  final Map<int, _SectionRange> sectionRanges;

  const _LoadedEdition({
    required this.records,
    required this.sectionNames,
    required this.sectionRanges,
  });
}

class _SectionRange {
  final int firstHadith;
  final int lastHadith;

  const _SectionRange({required this.firstHadith, required this.lastHadith});
}

class _ChapterBuilder {
  final int id;
  final int bookNumber;

  String nameAr = '';
  String nameBn = '';
  String nameEn = '';

  _ChapterBuilder({required this.id, required this.bookNumber});
}

class _ParsedChapter {
  final int id;
  final int bookNumber;
  final String name;

  const _ParsedChapter({
    required this.id,
    required this.bookNumber,
    required this.name,
  });
}