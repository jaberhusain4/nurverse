// lib/services/hadith_service.dart

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'generated_hadith_chapter_metadata.dart';

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
    nameEn: "Sunan an-Nasa'i",
  ),
  HadithBook(
    key: 'ibnmajah',
    nameBn: 'সুনান ইবন মাজাহ',
    nameEn: 'Sunan Ibn Majah',
  ),
  HadithBook(key: 'malik', nameBn: 'মুয়াত্তা মালিক', nameEn: 'Muwatta Malik'),
];

class HadithService {
  HadithService._();

  static final HadithService instance = HadithService._();

  final Map<String, _LoadedEdition> _editionCache = {};
  final Map<String, List<HadithChapter>> _chapterCache = {};
  final Map<String, List<HadithItem>> _hadithCache = {};

  /// Clears all in-memory Hadith caches so refreshed chapter/index metadata
  /// and bundled content are loaded again on the next request.
  void clearCache() {
    _editionCache.clear();
    _chapterCache.clear();
    _hadithCache.clear();
  }

  Future<HadithItem> getTodayHadith() async {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;

    for (var offset = 0; offset < kHadithBooks.length; offset++) {
      final book = kHadithBooks[(seed + offset) % kHadithBooks.length];
      try {
        final chapters = await getChapters(book.key, languageCode: 'bn');
        if (chapters.isEmpty) continue;

        final chapter = chapters[(seed + offset) % chapters.length];
        final hadiths = await getHadiths(
          book.key,
          chapter.id,
          bookNumber: chapter.bookNumber,
          languageCode: 'bn',
        );
        if (hadiths.isEmpty) continue;

        return hadiths[(seed + offset) % hadiths.length];
      } catch (_) {
        // Try the next collection.
      }
    }

    throw StateError('No hadith content is available from the bundled assets.');
  }

  Future<List<HadithChapter>> getChapters(
    String bookKey, {
    String languageCode = 'bn',
  }) async {
    final language = _normalizeLanguage(languageCode);
    final cacheKey = '$bookKey:$language';
    final cached = _chapterCache[cacheKey];
    if (cached != null) return cached;

    final arabic = await _loadEdition(bookKey, 'ara');
    final english = await _loadEdition(bookKey, 'eng');
    final requested = language == 'ar'
        ? arabic
        : await _loadEdition(bookKey, _assetLanguageCode(language));

    final extractedChapters = _extractChapters(
      arabic: arabic,
      requested: requested,
      english: english,
      languageCode: language,
    );
    final chapters = _applyCanonicalChapterMetadata(bookKey, extractedChapters);

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
    if (cached != null) return cached;

    final arabic = await _loadEdition(bookKey, 'ara');
    final bangla = await _loadEdition(bookKey, 'ben');
    final english = await _loadEdition(bookKey, 'eng');

    final arabicMap = _indexHadiths(arabic, chapterId, bookNumber);
    final banglaMap = _indexHadiths(bangla, chapterId, bookNumber);
    final englishMap = _indexHadiths(english, chapterId, bookNumber);

    final keys = <String>{
      ...arabicMap.keys,
      ...banglaMap.keys,
      ...englishMap.keys,
    }.toList()..sort(_compareHadithKeys);

    final result = <HadithItem>[];
    for (final key in keys) {
      final ar = arabicMap[key];
      final bn = banglaMap[key];
      final en = englishMap[key];

      final item = HadithItem(
        hadithNo: _firstNonEmpty([
          _value(ar, 'hadithnumber'),
          _value(ar, 'hadithNo'),
          _value(ar, 'number'),
          _value(bn, 'hadithnumber'),
          _value(en, 'hadithnumber'),
          key.split(':').last,
        ]),
        arabic: _extractText(ar),
        bangla: _extractText(bn),
        english: _extractText(en),
        narrator: _firstNonEmpty([
          _value(bn, 'narrator'),
          _value(en, 'narrator'),
          _value(ar, 'narrator'),
          _value(bn, 'narratorName'),
          _value(en, 'narratorName'),
        ]),
        reference: _firstNonEmpty([
          _value(bn, 'reference'),
          _value(en, 'reference'),
          _value(ar, 'reference'),
          _value(bn, 'book'),
          _value(en, 'book'),
        ]),
        grade: _firstNonEmpty([
          _value(bn, 'grade'),
          _value(en, 'grade'),
          _value(ar, 'grade'),
        ]),
      );

      if (_hasUsefulText(item)) result.add(item);
    }

    _hadithCache[cacheKey] = result;
    return result;
  }

  Future<_LoadedEdition> _loadEdition(String bookKey, String language) async {
    final cacheKey = '$language-$bookKey';
    final cached = _editionCache[cacheKey];
    if (cached != null) return cached;

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

  List<HadithChapter> _extractChapters({
    required _LoadedEdition arabic,
    required _LoadedEdition requested,
    required _LoadedEdition english,
    required String languageCode,
  }) {
    final chapterMap = <int, _ChapterBuilder>{};

    void process(_LoadedEdition edition, String language) {
      for (final entry in edition.sectionNames.entries) {
        final name = entry.value.trim();
        if (_isGenericChapterName(name)) continue;
        final builder = chapterMap.putIfAbsent(
          entry.key,
          () => _ChapterBuilder(id: entry.key),
        );
        _setName(builder, language, name);
      }

      for (final item in edition.records) {
        final parsed = _chapterFromItem(item);
        if (parsed == null) continue;

        final builder = chapterMap.putIfAbsent(
          parsed.id,
          () => _ChapterBuilder(id: parsed.id),
        );
        if (parsed.bookNumber != 0) builder.bookNumber = parsed.bookNumber;
        if (!_isGenericChapterName(parsed.name)) {
          _setName(builder, language, parsed.name);
        }
      }
    }

    process(arabic, 'ar');
    process(english, 'en');
    if (languageCode != 'ar') {
      process(requested, languageCode);
    }

    final result = chapterMap.values
        .map(
          (chapter) => HadithChapter(
            id: chapter.id,
            bookNumber: chapter.bookNumber,
            nameAr: chapter.nameAr,
            nameBn: chapter.nameBn,
            nameEn: chapter.nameEn,
          ),
        )
        .where(
          (chapter) =>
              chapter.nameAr.isNotEmpty ||
              chapter.nameBn.isNotEmpty ||
              chapter.nameEn.isNotEmpty,
        )
        .toList();

    result.sort((a, b) {
      final byBook = a.bookNumber.compareTo(b.bookNumber);
      if (byBook != 0) return byBook;
      return a.id.compareTo(b.id);
    });

    return result;
  }

  List<HadithChapter> _applyCanonicalChapterMetadata(
    String bookKey,
    List<HadithChapter> chapters,
  ) {
    final catalog = GeneratedHadithChapterMetadata.books[bookKey];
    if (catalog == null || catalog.isEmpty) return chapters;

    final merged = <int, HadithChapter>{
      for (final chapter in chapters) chapter.id: chapter,
    };

    for (final entry in catalog.entries) {
      final existing = merged[entry.key];
      final title = entry.value;
      merged[entry.key] = HadithChapter(
        id: entry.key,
        bookNumber: existing?.bookNumber ?? 0,
        nameAr: title.ar,
        nameBn: title.bn,
        nameEn: title.en,
      );
    }

    final result = merged.values.toList();
    result.sort((a, b) {
      final byBook = a.bookNumber.compareTo(b.bookNumber);
      if (byBook != 0) return byBook;
      return a.id.compareTo(b.id);
    });
    return result;
  }

  void _setName(_ChapterBuilder builder, String language, String name) {
    if (name.isEmpty || _isGenericChapterName(name)) return;
    switch (language) {
      case 'ar':
        builder.nameAr = name;
        break;
      case 'bn':
        builder.nameBn = name;
        break;
      case 'en':
        builder.nameEn = name;
        break;
    }
  }

  bool _isGenericChapterName(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return true;
    return RegExp(
      r'^(chapter\s*\d+|অধ্যায়\s*\d+|অধ্যায়\s*\d+|الفصل\s*\d+)(\s*-\s*.*)?$',
      caseSensitive: false,
    ).hasMatch(normalized);
  }

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
      if (numberText.isEmpty) continue;

      final number = int.tryParse(numberText);
      final matchesChapter = chapter != null
          ? chapter.id == chapterId
          : range != null && number != null
              ? number >= range.firstHadith && number <= range.lastHadith
              : false;
      if (!matchesChapter) continue;

      if (bookNumber != null &&
          chapter != null &&
          chapter.bookNumber != 0 &&
          chapter.bookNumber != bookNumber) {
        continue;
      }

      final key = '${chapter?.bookNumber ?? bookNumber ?? 0}:$numberText';
      result[key] = item;
    }
    return result;
  }

  _ParsedChapter? _chapterFromItem(Map<String, dynamic> item) {
    final chapterObject = item['chapter'] is Map
        ? Map<String, dynamic>.from(item['chapter'] as Map)
        : null;
    final referenceObject = item['reference'] is Map
        ? Map<String, dynamic>.from(item['reference'] as Map)
        : null;

    final chapterId = _intValue(
      item['chapterId'] ??
          item['chapter_id'] ??
          item['chapterNumber'] ??
          item['chapter_number'] ??
          item['bookId'] ??
          item['book_id'] ??
          item['sectionId'] ??
          item['section_id'] ??
          chapterObject?['id'] ??
          item['section'],
    );

    final bookNumber = _intValue(
          item['bookNumber'] ??
              item['book_number'] ??
              referenceObject?['book'] ??
              item['book'],
        ) ??
        0;

    final rawSection = item['section']?.toString().trim() ?? '';
    final rawChapter = item['chapter'];
    final chapterName = _firstNonEmpty([
      item['chapterName']?.toString(),
      item['chapter_name']?.toString(),
      item['chapterTitle']?.toString(),
      item['chapter_title']?.toString(),
      item['name']?.toString(),
      chapterObject?['name']?.toString(),
      chapterObject?['title']?.toString(),
      if (_intValue(rawChapter) == null && rawChapter is String) rawChapter,
      if (_intValue(rawSection) == null) rawSection,
    ]);

    if (chapterId == null ||
        chapterName.isEmpty ||
        _intValue(chapterName) != null) {
      return null;
    }

    return _ParsedChapter(
      id: chapterId,
      bookNumber: bookNumber,
      name: chapterName,
    );
  }

  _LoadedEdition _extractEdition(dynamic decoded) {
    final records = _extractDataList(decoded);
    final sectionNames = <int, String>{};
    final sectionRanges = <int, _SectionRange>{};

    void addSection(dynamic rawKey, dynamic rawValue) {
      final index = _intValue(rawKey) ??
          _intValue(
            _mapValue(rawValue, const [
              'id',
              'section',
              'number',
              'chapterId',
              'chapter_id',
            ]),
          );
      if (index == null) return;

      String name = '';
      if (rawValue is Map) {
        name = _firstNonEmpty([
          rawValue['name']?.toString(),
          rawValue['title']?.toString(),
          rawValue['sectionName']?.toString(),
          rawValue['section_name']?.toString(),
          rawValue['name_ar']?.toString(),
          rawValue['name_bn']?.toString(),
          rawValue['name_en']?.toString(),
        ]);
      } else {
        name = rawValue?.toString() ?? '';
      }
      if (name.trim().isNotEmpty && !_isGenericChapterValue(name)) {
        sectionNames[index] = name.trim();
      }
    }

    void addSectionCollection(dynamic sections) {
      if (sections is Map) {
        for (final entry in sections.entries) {
          addSection(entry.key, entry.value);
        }
      } else if (sections is List) {
        for (final value in sections) {
          addSection(null, value);
        }
      }
    }

    void addRanges(dynamic details) {
      if (details is Map) {
        for (final entry in details.entries) {
          final index = _intValue(entry.key) ??
              _intValue(
                _mapValue(entry.value, const ['id', 'section', 'number']),
              );
          final value = entry.value;
          if (index == null || value is! Map) continue;
          final first = _intValue(
            value['hadithnumber_first'] ??
                value['hadith_first'] ??
                value['first'],
          );
          final last = _intValue(
            value['hadithnumber_last'] ?? value['hadith_last'] ?? value['last'],
          );
          if (first != null && last != null) {
            sectionRanges[index] = _SectionRange(
              firstHadith: first,
              lastHadith: last,
            );
          }
        }
      } else if (details is List) {
        for (final value in details) {
          if (value is! Map) continue;
          final index = _intValue(
            _mapValue(
              value,
              const ['id', 'section', 'number', 'chapterId', 'chapter_id'],
            ),
          );
          final first = _intValue(
            value['hadithnumber_first'] ??
                value['hadith_first'] ??
                value['first'],
          );
          final last = _intValue(
            value['hadithnumber_last'] ??
                value['hadith_last'] ??
                value['last'],
          );
          if (index != null && first != null && last != null) {
            sectionRanges[index] = _SectionRange(
              firstHadith: first,
              lastHadith: last,
            );
          }
        }
      }
    }

    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      addSectionCollection(map['sections']);
      final metadata = map['metadata'];
      if (metadata is Map) {
        addSectionCollection(metadata['sections']);
        addRanges(metadata['section_details']);
      }
    }

    return _LoadedEdition(
      records: records,
      sectionNames: sectionNames,
      sectionRanges: sectionRanges,
    );
  }

  dynamic _mapValue(dynamic value, List<String> keys) {
    if (value is! Map) return null;
    for (final key in keys) {
      if (value.containsKey(key)) return value[key];
    }
    return null;
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
      if (value is List && value.isNotEmpty) return value;
      if (value is Map) {
        final nested = _findFirstList(Map<String, dynamic>.from(value));
        if (nested != null) return nested;
      }
    }
    return null;
  }

  String _normalizeLanguage(String languageCode) {
    final value = languageCode.trim().toLowerCase();
    if (value.startsWith('ar')) return 'ar';
    if (value.startsWith('en')) return 'en';
    return 'bn';
  }

  String _assetLanguageCode(String language) {
    switch (language) {
      case 'ar':
        return 'ara';
      case 'en':
        return 'eng';
      default:
        return 'ben';
    }
  }

  String _firstNonEmpty(Iterable<String?> values) {
    for (final value in values) {
      final text = value?.trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String _value(Map<String, dynamic>? map, String key) =>
      map == null ? '' : (map[key]?.toString().trim() ?? '');

  int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '');
  }

  String _extractText(Map<String, dynamic>? map) {
    if (map == null) return '';
    for (final key in const [
      'text',
      'hadith',
      'content',
      'body',
      'matn',
      'translation',
      'text_bn',
      'text_en',
      'text_ar',
    ]) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is Map) {
        final nested = _firstNonEmpty([
          value['text']?.toString(),
          value['translation']?.toString(),
          value['content']?.toString(),
        ]);
        if (nested.isNotEmpty) return nested;
      }
    }
    return '';
  }

  bool _hasUsefulText(HadithItem item) =>
      item.arabic.trim().isNotEmpty ||
      item.bangla.trim().isNotEmpty ||
      item.english.trim().isNotEmpty;

  int _compareHadithKeys(String a, String b) {
    int number(String key) => int.tryParse(key.split(':').last) ?? 1 << 30;
    final byNumber = number(a).compareTo(number(b));
    if (byNumber != 0) return byNumber;
    return a.compareTo(b);
  }

  bool _isGenericChapterValue(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return true;
    return RegExp(
      r'^(chapter\s*\d+|অধ্যায়\s*\d+|অধ্যায়\s*\d+|الفصل\s*\d+)$',
      caseSensitive: false,
    ).hasMatch(normalized);
  }
}

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

  const _SectionRange({
    required this.firstHadith,
    required this.lastHadith,
  });
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

class _ChapterBuilder {
  final int id;
  int bookNumber = 0;
  String nameAr = '';
  String nameBn = '';
  String nameEn = '';

  _ChapterBuilder({required this.id});
}
