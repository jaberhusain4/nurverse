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

    // Settings -> Arabic: use the Arabic chapter title only.
    if (l10n.isArabic) {
      final ar = chapter.nameAr.trim();
      return ar.isNotEmpty && !_genericArabic(ar)
          ? 'الفصل ${_arabicDigits(number)} — ${_stripArabicChapterPrefix(ar)}'
          : 'الفصل ${_arabicDigits(number)}';
    }

    // Settings -> English: use the English chapter title only.
    if (l10n.isEnglish) {
      final en = chapter.nameEn.trim();
      return en.isNotEmpty && !_genericEnglish(en)
          ? 'Chapter $number — ${_stripEnglishChapterPrefix(en)}'
          : 'Chapter $number';
    }

    // Settings -> Bangla: prefer the real bundled Bengali title.
    final bengali = chapter.nameBn.trim();
    if (bengali.isNotEmpty && !_genericBengali(bengali) && !_containsLatin(bengali)) {
      return 'অধ্যায় ${_banglaDigits(number)} — ${_stripBengaliChapterPrefix(bengali)}';
    }

    // If the Bengali asset does not contain a usable title, use the existing
    // offline Bengali localization map. Never fall back to English/Arabic in
    // Bangla mode.
    final localized = HadithChapterLocalization.localize(
      bengali: chapter.nameBn,
      english: chapter.nameEn,
      arabic: chapter.nameAr,
      chapterIndex: number,
    ).trim();
    final localizedTitle = _stripBengaliChapterPrefix(localized);

    if (localizedTitle.isNotEmpty &&
        !_containsLatin(localizedTitle) &&
        !_genericBengali(localizedTitle)) {
      return 'অধ্যায় ${_banglaDigits(number)} — $localizedTitle';
    }

    // No cross-language fallback. Keep only the chapter number in the
    // selected language instead of showing an English title in Bangla mode.
    return 'অধ্যায় ${_banglaDigits(number)}';
  }

  static String _stripBengaliChapterPrefix(String value) => value
      .replaceFirst(RegExp(r'^অধ্যায়\s*[০-৯0-9]+\s*[-—:]\s*'), '')
      .replaceFirst(RegExp(r'^অধ্যায়\s*[০-৯0-9]+\s*[-—:]\s*'), '')
      .trim();

  static String _stripEnglishChapterPrefix(String value) => value
      .replaceFirst(RegExp(r'^chapter\s*\d+\s*[-—:]\s*', caseSensitive: false), '')
      .trim();

  static String _stripArabicChapterPrefix(String value) => value
      .replaceFirst(RegExp(r'^الفصل\s*[٠-٩0-9]+\s*[-—:]\s*'), '')
      .trim();

  static bool _genericBengali(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return true;
    return RegExp(r'^(অধ্যায়|অধ্যায়)\s*[০-৯0-9]+$', caseSensitive: false)
            .hasMatch(normalized) ||
        normalized.contains('অন্যান্য বিষয়') ||
        normalized.contains('অন্যান্য বিষয়');
  }

  static bool _genericEnglish(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return true;
    return RegExp(r'^chapter\s*\d+$', caseSensitive: false).hasMatch(normalized) ||
        normalized.toLowerCase().contains('other topics') ||
        normalized.toLowerCase().contains('other subjects') ||
        normalized.toLowerCase().contains('miscellaneous');
  }

  static bool _genericArabic(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return true;
    return RegExp(r'^الفصل\s*[٠-٩0-9]+$').hasMatch(normalized);
  }

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
