import 'hadith_service.dart';
import 'generated_hadith_chapter_metadata.dart';

/// Language-aware chapter index backed exclusively by the canonical bundled
/// multilingual chapter catalog.
///
/// The UI uses this service directly, so it must never invent chapter names
/// through transliteration or word-by-word translation.
class HadithChapterIndexService {
  HadithChapterIndexService._();

  static final HadithChapterIndexService instance =
      HadithChapterIndexService._();

  final Map<String, Map<String, List<HadithChapter>>> _cache = {};

  Future<List<HadithChapter>> getChapters(
    String bookKey, {
    required String languageCode,
  }) async {
    final language = _normalizeLanguage(languageCode);
    final cachedBook = _cache[bookKey];
    final cached = cachedBook?[language];
    if (cached != null) return cached;

    final catalog = GeneratedHadithChapterMetadata.books[bookKey];
    if (catalog == null || catalog.isEmpty) {
      throw StateError('No canonical chapter metadata found for $bookKey.');
    }

    final result = <HadithChapter>[];
    for (final entry in catalog.entries) {
      final id = entry.key;
      final title = entry.value;
      final name = switch (language) {
        'ar' => title.ar,
        'en' => title.en,
        _ => title.bn,
      };

      if (name.trim().isEmpty) {
        throw StateError(
          'Missing ${_languageName(language)} chapter title: $bookKey/$id',
        );
      }

      result.add(
        HadithChapter(
          id: id,
          bookNumber: id,
          nameAr: title.ar,
          nameBn: title.bn,
          nameEn: title.en,
        ),
      );
    }

    if (result.isEmpty) {
      throw StateError('No chapter metadata found for $bookKey.');
    }

    result.sort((a, b) {
      final byBook = a.bookNumber.compareTo(b.bookNumber);
      if (byBook != 0) return byBook;
      return a.id.compareTo(b.id);
    });

    _cache.putIfAbsent(bookKey, () => {})[language] = result;
    return result;
  }

  String _normalizeLanguage(String code) {
    final value = code.trim().toLowerCase();
    if (value.startsWith('ar')) return 'ar';
    if (value.startsWith('en')) return 'en';
    return 'bn';
  }

  String _languageName(String language) {
    switch (language) {
      case 'ar':
        return 'Arabic';
      case 'en':
        return 'English';
      default:
        return 'Bengali';
    }
  }

  void clearCache() => _cache.clear();
}
