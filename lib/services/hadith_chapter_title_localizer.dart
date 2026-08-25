import '../localization/app_localizations.dart';
import 'hadith_bengali_title_builder.dart';
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

    // Settings -> Arabic: always use the Arabic metadata title.
    if (l10n.isArabic) {
      final ar = chapter.nameAr.trim();
      if (ar.isNotEmpty && !_genericArabic(ar)) {
        return 'الفصل ${_arabicDigits(number)} — ${_stripArabicChapterPrefix(ar)}';
      }
      return 'الفصل ${_arabicDigits(number)}';
    }

    // Settings -> English: always use the English metadata title.
    if (l10n.isEnglish) {
      final en = chapter.nameEn.trim();
      if (en.isNotEmpty && !_genericEnglish(en)) {
        return 'Chapter $number — ${_stripEnglishChapterPrefix(en)}';
      }
      return 'Chapter $number';
    }

    // Settings -> Bangla: use bundled Bengali metadata when it is a genuine
    // Bengali title. Many bundled Bengali JSON files contain English section
    // metadata, so that is deliberately rejected here.
    final bengali = chapter.nameBn.trim();
    if (bengali.isNotEmpty && !_genericBengali(bengali) && !_containsLatin(bengali)) {
      return 'অধ্যায় ${_banglaDigits(number)} — ${_stripBengaliChapterPrefix(bengali)}';
    }

    // First use the existing curated offline localization map.
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

    // Final deterministic offline guarantee: every chapter receives a Bengali
    // title generated from its canonical English metadata. This path never
    // returns English text, an empty string, or “অন্যান্য বিষয়”.
    final generated = HadithBengaliTitleBuilder.build(chapter.nameEn).trim();
    final safeGenerated = _stripBengaliChapterPrefix(generated);
    if (safeGenerated.isNotEmpty && !_containsLatin(safeGenerated)) {
      return 'অধ্যায় ${_banglaDigits(number)} — $safeGenerated';
    }

    // This is intentionally only a last-resort invariant guard. The builder
    // is deterministic and normally makes this branch unreachable.
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
