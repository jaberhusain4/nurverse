import '../localization/app_localizations.dart';
import 'hadith_service.dart';

/// Resolves a Hadith chapter title strictly from the currently selected UI language.
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
      if (ar.isNotEmpty && !_generic(ar)) {
        return 'الفصل ${_arabicDigits(number)} — $ar';
      }
      return 'الفصل ${_arabicDigits(number)}';
    }

    if (l10n.isEnglish) {
      final en = chapter.nameEn.trim();
      if (en.isNotEmpty && !_generic(en)) {
        return 'Chapter $number — $en';
      }
      return 'Chapter $number';
    }

    final bn = chapter.nameBn.trim();
    final english = chapter.nameEn.trim();
    final bangla = _banglaTitle(bn, english);
    return 'অধ্যায় ${_banglaDigits(number)} — $bangla';
  }

  static String _banglaTitle(String bangla, String english) {
    if (bangla.isNotEmpty && !_containsLatin(bangla) && !_generic(bangla)) {
      return bangla;
    }

    final source = english.isNotEmpty && !_generic(english) ? english : bangla;
    if (source.isEmpty) return 'অন্যান্য বিষয়';

    final normalized = source.toLowerCase().trim();

    const exact = <String, String>{
      'rubbing hands and feet with dust (tayammum)': 'তায়াম্মুমের জন্য হাত ও পা মাটি দিয়ে মুছে নেওয়া',
      'rubbing hands and feet with dust (tayammum': 'তায়াম্মুমের জন্য হাত ও পা মাটি দিয়ে মুছে নেওয়া',
      'the book of tayammum': 'তায়াম্মুমের কিতাব',
      'book of tayammum': 'তায়াম্মুমের কিতাব',
      'tayammum': 'তায়াম্মুম',
      'the call to prayer': 'আযান',
      'call to prayer': 'আযান',
      'the times of prayer': 'সালাতের সময়সমূহ',
      'times of prayer': 'সালাতের সময়সমূহ',
    };
    final exactHit = exact[normalized];
    if (exactHit != null) return exactHit;

    var text = normalized;
    const phrases = <String, String>{
      'rubbing hands and feet with dust': 'হাত ও পা মাটি দিয়ে মুছে নেওয়া',
      'with dust': 'মাটি দিয়ে',
      'hands and feet': 'হাত ও পা',
      'hands': 'হাত',
      'feet': 'পা',
      'dust': 'মাটি',
      'tayammum': 'তায়াম্মুম',
      'ablution': 'উযূ',
      'ablutions': 'উযূ',
      'purification': 'পবিত্রতা',
      'prayer': 'সালাত',
      'prayers': 'সালাতসমূহ',
      'call to prayer': 'আযান',
      'fasting': 'সিয়াম',
      'fast': 'রোযা',
      'zakat': 'যাকাত',
      'charity': 'সদকা',
      'hajj': 'হজ্জ',
      'umrah': 'উমরাহ',
      'marriage': 'বিবাহ',
      'divorce': 'তালাক',
      'food': 'খাদ্য',
      'drinks': 'পানীয়',
      'clothing': 'পোশাক',
      'greetings': 'সালাম',
      'manners': 'আদব',
      'medicine': 'চিকিৎসা',
      'funeral': 'জানাযা',
      'funerals': 'জানাযা',
      'inheritance': 'উত্তরাধিকার',
      'oaths': 'শপথ',
      'vows': 'মানত',
      'knowledge': 'ইলম',
      'faith': 'ঈমান',
      'belief': 'আকীদা',
      'revelation': 'ওহী',
      'prophets': 'নবীগণ',
      'prophet': 'নবী',
      'companions': 'সাহাবীগণ',
      'companion': 'সাহাবী',
      'paradise': 'জান্নাত',
      'hell': 'জাহান্নাম',
      'punishment': 'শাস্তি',
      'punishments': 'শাস্তিসমূহ',
      'justice': 'ন্যায়বিচার',
      'oppression': 'জুলুম',
      'oppressions': 'জুলুম',
      'supplication': 'দোয়া',
      'remembrance': 'যিকির',
      'repentance': 'তওবা',
      'travel': 'সফর',
      'travelling': 'সফর',
      'journey': 'সফর',
      'mosque': 'মসজিদ',
      'market': 'বাজার',
      'gift': 'উপহার',
      'gifts': 'উপহারসমূহ',
      'witnesses': 'সাক্ষীগণ',
      'testimonies': 'সাক্ষ্যসমূহ',
      'conditions': 'শর্তাবলি',
      'condition': 'শর্ত',
      'transactions': 'লেনদেনসমূহ',
      'transaction': 'লেনদেন',
      'trade': 'ব্যবসা',
      'sales': 'ক্রয়-বিক্রয়',
      'loan': 'ঋণ',
      'loans': 'ঋণসমূহ',
    };

    final ordered = phrases.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in ordered) {
      text = text.replaceAll(entry.key, entry.value);
    }

    text = text
        .replaceAll(RegExp(r'^the book of\s+'), '')
        .replaceAll(RegExp(r'^book of\s+'), '')
        .replaceAll(RegExp(r'^the\s+'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (!_containsLatin(text)) return text;
    return _transliterate(text);
  }

  static bool _generic(String value) => RegExp(
        r'^(chapter|অধ্যায়|অধ্যায়|الفصل)\s*\d+$',
        caseSensitive: false,
      ).hasMatch(value.trim());

  static bool _containsLatin(String value) => RegExp(r'[A-Za-z]').hasMatch(value);

  static String _transliterate(String value) {
    var text = value.toLowerCase();
    const digraphs = <String, String>{
      'tsh': 'টশ', 'sch': 'শ', 'sh': 'শ', 'ch': 'চ', 'kh': 'খ', 'gh': 'ঘ',
      'ph': 'ফ', 'th': 'থ', 'dh': 'ধ', 'bh': 'ভ', 'jh': 'ঝ', 'ck': 'ক',
      'qu': 'কু', 'oo': 'ু', 'ee': 'ী', 'aa': 'া', 'ai': 'ঐ', 'au': 'ঔ',
      'tion': 'শন', 'sion': 'শন',
    };
    for (final entry in digraphs.entries) {
      text = text.replaceAll(entry.key, entry.value);
    }

    const letters = <String, String>{
      'a': 'আ', 'b': 'ব', 'c': 'ক', 'd': 'দ', 'e': 'এ', 'f': 'ফ', 'g': 'গ', 'h': 'হ',
      'i': 'ই', 'j': 'জ', 'k': 'ক', 'l': 'ল', 'm': 'ম', 'n': 'ন', 'o': 'ও', 'p': 'প',
      'q': 'ক', 'r': 'র', 's': 'স', 't': 'ত', 'u': 'উ', 'v': 'ভ', 'w': 'ও', 'x': 'ক্স',
      'y': 'ই', 'z': 'জ',
    };

    final out = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      out.write(letters[char] ?? char);
    }
    return out.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _banglaDigits(int value) {
    const digits = '০১২৩৪৫৬৭৮৯';
    return value.toString().split('').map((d) => digits[int.parse(d)]).join();
  }

  static String _arabicDigits(int value) {
    const digits = '٠١٢٣٤٥٦٧٨٩';
    return value.toString().split('').map((d) => digits[int.parse(d)]).join();
  }
}
