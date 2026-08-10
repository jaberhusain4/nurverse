import 'hadith_service.dart';

/// Provides a compact, deterministic daily hadith for the home/hadith UI.
///
/// This service stays fully offline by using the bundled HadithService data.
class DailyHadithService {
  DailyHadithService._();

  static final DailyHadithService instance = DailyHadithService._();

  Future<HadithItem> getTodayHadith() async {
    final books = kHadithBooks;
    if (books.isEmpty) {
      throw StateError('No hadith books configured.');
    }

    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;

    // Start from a different collection each day, then search a small,
    // deterministic window for a genuinely short Bengali hadith.
    for (var bookOffset = 0; bookOffset < books.length; bookOffset++) {
      final book = books[(seed + bookOffset) % books.length];

      try {
        final chapters = await HadithService.instance.getChapters(
          book.key,
          languageCode: 'bn',
        );

        if (chapters.isEmpty) continue;

        final start = (seed + bookOffset * 7) % chapters.length;
        final scanCount = chapters.length < 12 ? chapters.length : 12;

        final candidates = <HadithItem>[];

        for (var i = 0; i < scanCount; i++) {
          final chapter = chapters[(start + i) % chapters.length];

          final hadiths = await HadithService.instance.getHadiths(
            book.key,
            chapter.id,
            bookNumber: chapter.bookNumber,
            languageCode: 'bn',
          );

          for (final hadith in hadiths) {
            if (_isShortAndUsable(hadith)) {
              candidates.add(hadith);
            }
          }

          if (candidates.length >= 12) break;
        }

        if (candidates.isNotEmpty) {
          final selected = candidates[seed % candidates.length];
          return _withFallbackReference(selected, book);
        }
      } catch (_) {
        // Continue to the next bundled collection.
      }
    }

    // Last-resort fallback: preserve the existing daily selection if the
    // compact candidate scan cannot find a short translation.
    return HadithService.instance.getTodayHadith();
  }

  bool _isShortAndUsable(HadithItem hadith) {
    final text = hadith.bangla.trim();
    if (text.isEmpty) return false;

    final normalized = text.replaceAll(RegExp(r'\s+'), ' ');
    final words = normalized.split(' ').where((e) => e.isNotEmpty).length;

    // Keep the daily card visually compact without cutting the translation.
    return normalized.length <= 260 && words <= 42;
  }

  HadithItem _withFallbackReference(HadithItem hadith, HadithBook book) {
    if (hadith.reference.trim().isNotEmpty) {
      return hadith;
    }

    return HadithItem(
      hadithNo: hadith.hadithNo,
      arabic: hadith.arabic,
      bangla: hadith.bangla,
      english: hadith.english,
      narrator: hadith.narrator,
      reference: '${book.nameBn} • হাদিস: ${hadith.hadithNo}',
      grade: hadith.grade,
    );
  }
}
