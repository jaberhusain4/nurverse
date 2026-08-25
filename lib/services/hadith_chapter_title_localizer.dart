import '../localization/app_localizations.dart';
import 'hadith_chapter_localization.dart';
import 'hadith_service.dart';

class HadithChapterTitleLocalizer {
  const HadithChapterTitleLocalizer._();

  static String resolve({required HadithChapter chapter, required AppLocalizations l10n, required int index}) {
    final number = index + 1;
    if (l10n.isArabic) {
      final ar = chapter.nameAr.trim();
      return ar.isNotEmpty && !_genericArabic(ar) ? 'الفصل ${_arabicDigits(number)} — $ar' : 'الفصل ${_arabicDigits(number)}';
    }
    if (l10n.isEnglish) {
      final en = chapter.nameEn.trim();
      return en.isNotEmpty && !_genericEnglish(en) ? 'Chapter $number — $en' : 'Chapter $number';
    }

    final localized = HadithChapterLocalization.localize(
      bengali: chapter.nameBn,
      english: chapter.nameEn,
      arabic: chapter.nameAr,
      chapterIndex: number,
    ).trim();
    final title = localized
        .replaceFirst(RegExp(r'^অধ্যায়\s*[০-৯0-9]+\s*—\s*'), '')
        .replaceFirst(RegExp(r'^অধ্যায়\s*[০-৯0-9]+\s*—\s*'), '')
        .trim();

    // Never transliterate English into Bengali characters. If no real Bengali
    // translation exists, use a meaningful Bengali fallback instead.
    if (title.isNotEmpty && !_containsLatin(title)) {
      return 'অধ্যায় ${_banglaDigits(number)} — $title';
    }
    return 'অধ্যায় ${_banglaDigits(number)} — অন্যান্য বিষয়';
  }

  static bool _genericEnglish(String value) => RegExp(r'^chapter\s*\d+$', caseSensitive: false).hasMatch(value.trim());
  static bool _genericArabic(String value) => RegExp(r'^الفصل\s*\d+$').hasMatch(value.trim());
  static bool _containsLatin(String value) => RegExp(r'[A-Za-z]').hasMatch(value);

  static String _banglaDigits(int value) {
    const digits = '০১২৩৪৫৬৭৮৯';
    return value.toString().split('').map((d) => digits[int.parse(d)]).join();
  }

  static String _arabicDigits(int value) {
    const digits = '٠١٢٣٤٥٦٧٨٩';
    return value.toString().split('').map((d) => digits[int.parse(d)]).join();
  }
}
