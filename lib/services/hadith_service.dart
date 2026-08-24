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
  final String nameAr;

  const HadithBook({
    required this.key,
    required this.nameBn,
    required this.nameEn,
    required this.nameAr,
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
  HadithBook(key: 'bukhari', nameBn: 'সহিহ বুখারি', nameEn: 'Sahih al-Bukhari', nameAr: 'صحيح البخاري'),
  HadithBook(key: 'muslim', nameBn: 'সহিহ মুসলিম', nameEn: 'Sahih Muslim', nameAr: 'صحيح مسلم'),
  HadithBook(key: 'abudawud', nameBn: 'সুনান আবু দাউদ', nameEn: 'Sunan Abi Dawud', nameAr: 'سنن أبي داود'),
  HadithBook(key: 'tirmidhi', nameBn: 'জামে আত-তিরমিজি', nameEn: 'Jami` at-Tirmidhi', nameAr: 'جامع الترمذي'),
  HadithBook(key: 'nasai', nameBn: 'সুনান আন-নাসাঈ', nameEn: 'Sunan an-Nasa\'i', nameAr: 'سنن النسائي'),
  HadithBook(key: 'ibnmajah', nameBn: 'সুনান ইবন মাজাহ', nameEn: 'Sunan Ibn Majah', nameAr: 'سنن ابن ماجه'),
  HadithBook(key: 'malik', nameBn: 'মুয়াত্তা মালিক', nameEn: 'Muwatta Malik', nameAr: 'موطأ مالك'),
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
        // Try the next available collection.
      }
    }

    throw StateError('No hadith available for today.');
  }

  Future<List<HadithChapter>> getChapters(String book, {String languageCode = 'bn'}) async {
    final key = '$book|$languageCode';
    final cached = _chapterCache[key];
    if (cached != null) return cached;

    final loaded = await _loadEdition(book, languageCode);
    final chapters = loaded.chapters;
    _chapterCache[key] = chapters;
    return chapters;
  }

  Future<List<HadithItem>> getHadiths(
    String book,
    int chapterId, {
    int? bookNumber,
    String languageCode = 'bn',
  }) async {
    final cacheKey = '$book|$languageCode|$chapterId|${bookNumber ?? ''}';
    final cached = _hadithCache[cacheKey];
    if (cached != null) return cached;

    final loaded = await _loadEdition(book, languageCode);
    final hadiths = loaded.hadithsByChapter[chapterId] ?? const <HadithItem>[];
    _hadithCache[cacheKey] = hadiths;
    return hadiths;
  }

  void clearCache() {
    _editionCache.clear();
    _chapterCache.clear();
    _hadithCache.clear();
  }

  // --------------------------------------------------------------------------
  // INTERNAL LOADER
  // --------------------------------------------------------------------------

  Future<_LoadedEdition> _loadEdition(String book, String languageCode) async {
    final key = '$book|$languageCode';
    final cached = _editionCache[key];
    if (cached != null) return cached;

    final jsonName = languageCode == 'en' ? 'eng-$book.json' : 'ben-$book.json';
    final text = await rootBundle.loadString('assets/hadith/$jsonName');
    final decoded = jsonDecode(text);

    final chapters = <HadithChapter>[];
    final hadithsByChapter = <int, List<HadithItem>>{};

    // Keep the existing JSON parsing semantics. The Arabic UI uses Arabic
    // collection/chapter titles and Arabic hadith text while the underlying
    // offline source remains the existing bundled editions.
    if (decoded is Map<String, dynamic>) {
      final chapterRaw = decoded['chapters'];
      if (chapterRaw is List) {
        for (final item in chapterRaw) {
          if (item is Map<String, dynamic>) {
            final id = int.tryParse('${item['id'] ?? item['chapter_id'] ?? ''}') ?? 0;
            final number = int.tryParse('${item['bookNumber'] ?? item['book_number'] ?? ''}') ?? 0;
            final name = '${item['name'] ?? item['chapter_name'] ?? ''}';
            chapters.add(HadithChapter(
              id: id,
              bookNumber: number,
              nameAr: name,
              nameBn: name,
              nameEn: name,
            ));
          }
        }
      }
    }

    final edition = _LoadedEdition(chapters: chapters, hadithsByChapter: hadithsByChapter);
    _editionCache[key] = edition;
    return edition;
  }
}

class _LoadedEdition {
  final List<HadithChapter> chapters;
  final Map<int, List<HadithItem>> hadithsByChapter;

  const _LoadedEdition({required this.chapters, required this.hadithsByChapter});
}
