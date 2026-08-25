import '../localization/app_localizations.dart';
import 'hadith_chapter_localization.dart';
import 'hadith_service.dart';

class HadithChapterTitleLocalizer {
  const HadithChapterTitleLocalizer._();

  static String resolve({
    required HadithChapter chapter,
    required AppLocalizations l10n,
    required int index,
  }) {
    final number = index + 1;

    if (l10n.isArabic) {
      final ar = chapter.nameAr.trim();
      return ar.isNotEmpty && !_genericArabic(ar)
          ? 'الفصل ${_arabicDigits(number)} — $ar'
          : 'الفصل ${_arabicDigits(number)}';
    }

    if (l10n.isEnglish) {
      final en = chapter.nameEn.trim();
      return en.isNotEmpty && !_genericEnglish(en)
          ? 'Chapter $number — $en'
          : 'Chapter $number';
    }

    final bengali = chapter.nameBn.trim();
    if (bengali.isNotEmpty && !_genericBengali(bengali)) {
      return 'অধ্যায় ${_banglaDigits(number)} — ${_stripChapterPrefix(bengali)}';
    }

    final localized = HadithChapterLocalization.localize(
      bengali: chapter.nameBn,
      english: chapter.nameEn,
      arabic: chapter.nameAr,
      chapterIndex: number,
    ).trim();
    final localizedTitle = _stripChapterPrefix(localized);

    if (localizedTitle.isNotEmpty &&
        !_containsLatin(localizedTitle) &&
        !_genericBengali(localizedTitle)) {
      return 'অধ্যায় ${_banglaDigits(number)} — $localizedTitle';
    }

    // Never replace a real chapter title with the misleading
    // “অন্যান্য বিষয়”. Preserve the canonical English title when a Bengali
    // translation is unavailable.
    final english = chapter.nameEn.trim();
    if (english.isNotEmpty && !_genericEnglish(english)) {
      return 'অধ্যায় ${_banglaDigits(number)} — $english';
    }

    final arabic = chapter.nameAr.trim();
    if (arabic.isNotEmpty && !_genericArabic(arabic)) {
      return 'অধ্যায় ${_banglaDigits(number)} — $arabic';
    }

    return 'অধ্যায় ${_banglaDigits(number)}';
  }

  static String _stripChapterPrefix(String value) => value
      .replaceFirst(RegExp(r'^অধ্যায়\s*[০-৯0-9]+\s*—\s*'), '')
      .replaceFirst(RegExp(r'^অধ্যায়\s*[০-৯0-9]+\s*—\s*'), '')
      .trim();

  static bool _genericBengali(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return true;
    return RegExp(
      r'^(অধ্যায়|অধ্যায়)\s*\d+(\s*-\s*.*)?$',
      caseSensitive: false,
    ).hasMatch(normalized) ||
        normalized.contains('অন্যান্য বিষয়') ||
        normalized.contains('অন্যান্য বিষয়');
  }

  static bool _genericEnglish(String value) => RegExp(
        r'^chapter\s*\d+(\s*-\s*.*)?$',
        caseSensitive: false,
      ).hasMatch(value.trim()) ||
      value.trim().toLowerCase().contains('other topics') ||
      value.trim().toLowerCase().contains('other subjects') ||
      value.trim().toLowerCase().contains('miscellaneous');

  static bool _genericArabic(String value) => RegExp(
        r'^الفصل\s*\d+(\s*-\s*.*)?$',
      ).hasMatch(value.trim());

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
