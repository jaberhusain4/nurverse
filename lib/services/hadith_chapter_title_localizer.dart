import '../localization/app_localizations.dart';
import 'hadith_bengali_title_builder.dart';
import 'hadith_bengali_title_overrides.dart';
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
    final english = chapter.nameEn.trim();

    if (l10n.isArabic) {
      final ar = chapter.nameAr.trim();
      return ar.isNotEmpty && !_genericArabic(ar)
          ? 'الفصل ${_arabicDigits(number)} — ${_stripArabicChapterPrefix(ar)}'
          : 'الفصل ${_arabicDigits(number)}';
    }

    if (l10n.isEnglish) {
      return english.isNotEmpty && !_genericEnglish(english)
          ? 'Chapter $number — ${_stripEnglishChapterPrefix(english)}'
          : 'Chapter $number';
    }

    // Bangla is the default language. Show the canonical English chapter
    // name together with its verified Bengali meaning, so users can identify
    // the exact subject even where the Bengali asset has weak metadata.
    if (english.isNotEmpty && !_genericEnglish(english)) {
      String? meaning = HadithBengaliTitleOverrides.resolve(english)?.trim();

      if (meaning == null || meaning.isEmpty) {
        final bengali = chapter.nameBn.trim();
        if (bengali.isNotEmpty &&
            !_genericBengali(bengali) &&
            !_containsLatin(bengali)) {
          meaning = _stripBengaliChapterPrefix(bengali);
        }
      }

      if (meaning == null || meaning.isEmpty) {
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
          meaning = localizedTitle;
        }
      }

      if (meaning == null || meaning.isEmpty) {
        final generated = HadithBengaliTitleBuilder.build(english).trim();
        final safeGenerated = _stripBengaliChapterPrefix(generated);
        if (safeGenerated.isNotEmpty && !_containsLatin(safeGenerated)) {
          meaning = safeGenerated;
        }
      }

      if (meaning != null &&
          meaning.isNotEmpty &&
          !_containsLatin(meaning) &&
          !_genericBengali(meaning)) {
        return 'অধ্যায় ${_banglaDigits(number)} — ${_stripEnglishChapterPrefix(english)} ($meaning)';
      }

      return 'অধ্যায় ${_banglaDigits(number)} — ${_stripEnglishChapterPrefix(english)}';
    }

    final ar = chapter.nameAr.trim();
    if (ar.isNotEmpty && !_genericArabic(ar)) {
      return 'অধ্যায় ${_banglaDigits(number)} — $ar';
    }

    return 'অধ্যায় ${_banglaDigits(number)} — হাদিসের বিষয়';
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
    return RegExp(r'^(অধ্যায়|অধ্যায়)\s*[০-৯0-9]+$', caseSensitive: false).hasMatch(normalized) ||
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
