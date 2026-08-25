// lib/services/hadith_chapter_localization.dart

/// Offline Bengali chapter-title localization for Hadith collections.
class HadithChapterLocalization {
  const HadithChapterLocalization._();

  static String localize({
    required String bengali,
    required String english,
    required String arabic,
    required int chapterIndex,
  }) {
    final bn = bengali.trim();
    final en = english.trim();
    final ar = arabic.trim();

    final genericBn = _isGenericPlaceholder(bn) ||
        RegExp(r'^(অধ্যায়|অধ্যায়)\s*\d+$').hasMatch(bn);
    final genericEn = _isGenericPlaceholder(en) ||
        RegExp(r'^chapter\s*\d+$', caseSensitive: false).hasMatch(en);
    final genericAr = RegExp(r'^الفصل\s*\d+$').hasMatch(ar);

    // A Bengali placeholder must never win over a useful English title.
    if (bn.isNotEmpty && !_containsLatin(bn) && !genericBn) {
      return _withChapterNumber(chapterIndex, bn);
    }

    final direct = _subjects[_normalize(bn)] ?? _subjects[_normalize(en)];
    if (direct != null) {
      return _withChapterNumber(chapterIndex, direct);
    }

    final generated = _generateFromEnglish(en);
    if (generated != null && !_containsLatin(generated)) {
      return _withChapterNumber(chapterIndex, generated);
    }

    if (!genericEn && en.isNotEmpty) {
      final translated = _translateEnglishTitle(en);
      if (!_containsLatin(translated)) {
        return _withChapterNumber(chapterIndex, translated);
      }
    }

    if (!genericAr && ar.isNotEmpty) {
      return _withChapterNumber(chapterIndex, ar);
    }

    // Do not manufacture “অন্যান্য বিষয়”. When the source metadata is truly
    // missing, expose only the chapter number instead of a false title.
    return 'অধ্যায় ${_bnDigits(chapterIndex)}';
  }

  static String _withChapterNumber(int chapterIndex, String title) =>
      'অধ্যায় ${_bnDigits(chapterIndex)} — $title';

  static bool _containsLatin(String value) => RegExp(r'[A-Za-z]').hasMatch(value);

  static bool _isGenericPlaceholder(String value) {
    final normalized = _normalize(value);
    if (normalized.isEmpty) return false;

    return normalized.contains('অন্যান্য বিষয়') ||
        normalized.contains('অন্যান্য বিষয়') ||
        normalized.contains('other topics') ||
        normalized.contains('other subjects') ||
        normalized.contains('miscellaneous');
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll('–', '-')
      .replaceAll('—', '-')
      .replaceAll('’', "'")
      .replaceAll('`', "'");

  static String? _generateFromEnglish(String value) {
    final normalized = _normalize(value);
    if (normalized.isEmpty || genericEnglish(normalized)) return null;

    const prefixes = ['the book of ', 'book of '];
    for (final prefix in prefixes) {
      if (normalized.startsWith(prefix)) {
        final subject = normalized.substring(prefix.length).trim();
        final translated = _subjects[subject];
        if (translated != null) return '$translated-এর কিতাব';
      }
    }

    return _subjects[normalized];
  }

  static bool genericEnglish(String value) =>
      _isGenericPlaceholder(value) ||
      RegExp(r'^chapter\s*\d+$', caseSensitive: false).hasMatch(value);

  static String _translateEnglishTitle(String value) {
    final normalized = _normalize(value);
    if (normalized.isEmpty || genericEnglish(normalized)) return '';

    // Keep this fallback conservative. Known collection titles are handled by
    // _subjects above; unknown metadata must not be turned into fake Bengali.
    return _subjects[normalized] ?? '';
  }

  // Canonical Bengali titles for the two Bukhari books that were previously
  // surfacing as the generic placeholder “অন্যান্য বিষয়”. These correspond to
  // Book 21 “Actions while Praying” and Book 22 “Forgetfulness in Prayer”.
  static const Map<String, String> _subjects = {
    'actions while praying': 'সালাতের সাথে সংশ্লিষ্ট কাজ',
    'forgetfulness in prayer': 'সাহু সিজদা',
    'revelation': 'ওহীর সূচনা',
    'faith': 'ঈমান',
    'belief': 'ঈমান',
    'iman': 'ঈমান',
    'knowledge': 'ইলম ও জ্ঞান',
    'purification': 'পবিত্রতা',
    'ablution': 'উযূ',
    'ablutions': 'উযূ',
    "ablutions (wudu')": 'উযূ',
    'bathing': 'গোসল',
    'bathing (ghusl)': 'গোসল',
    'menstrual periods': 'হায়েয',
    'tayammum': 'তায়াম্মুম',
    'prayer': 'সালাত',
    'prayers': 'সালাত',
    'prayers (salat)': 'সালাত',
    'times of the prayers': 'সালাতের ওয়াক্ত',
    'call to prayers': 'আযান',
    'call to prayers (adhaan)': 'আযান',
    'friday prayer': 'জুমুআর সালাত',
    'fear prayer': 'ভয়ের সময়ের সালাত',
    'the two festivals (eids)': 'দুই ঈদের সালাত',
    'witr prayer': 'বিতর সালাত',
    'night prayer': 'রাতের সালাত',
    'prayer at night (tahajjud)': 'রাতের সালাত (তাহাজ্জুদ)',
    'eclipses': 'সূর্য ও চন্দ্রগ্রহণ',
    'prostration': 'সিজদা',
    "prostration during recital of qur'an": 'কুরআন তিলাওয়াতের সময় সিজদা',
    'shortening the prayers': 'সালাত কসর করা',
    'shortening the prayers (at-taqseer)': 'সালাত কসর করা',
    'fasting': 'সিয়াম ও রোযা',
    'zakat': 'যাকাত',
    'obligatory charity tax (zakat)': 'যাকাত',
    'hajj': 'হজ্জ',
    'hajj (pilgrimage)': 'হজ্জ',
    'umrah': 'উমরাহ',
    '`umrah (minor pilgrimage)': 'উমরাহ',
    'virtues of madinah': 'মদিনার ফযীলত',
    'night of qadr': 'লাইলাতুল কদর',
    'virtues of the night of qadr': 'লাইলাতুল কদরের ফযীলত',
    "i'tikaf": 'ইতিকাফ',
    "retiring to a mosque for remembrance of allah (i'tikaf)": 'আল্লাহর স্মরণের জন্য মসজিদে ইতিকাফ',
    'sales and trade': 'ক্রয়-বিক্রয় ও ব্যবসা',
    'sales': 'ক্রয়-বিক্রয়',
    'transactions': 'লেনদেন',
    'agriculture': 'কৃষি',
    'distribution of water': 'পানি বণ্টন ও সেচ',
    'loans': 'ঋণ',
    'partnership': 'অংশীদারিত্ব',
    'mortgaging': 'বন্ধক রাখা',
    'hiring': 'ভাড়া ও শ্রমিক নিয়োগ',
    'gifts': 'উপহার',
    'witnesses': 'সাক্ষ্য',
    'testimonies': 'সাক্ষ্যসমূহ',
    'peacemaking': 'মীমাংসা ও সন্ধি',
    'conditions': 'শর্তাবলি',
    'oppressions': 'জুলুম ও নির্যাতন',
    'funerals': 'জানাযা',
    'wills': 'অছিয়ত',
    'wills and testaments': 'অছিয়ত ও উইল',
    'inheritance': 'উত্তরাধিকার',
    'oaths': 'শপথ',
    'vows': 'মানত',
    'divorce': 'তালাক',
    'marriage': 'বিবাহ',
    'food': 'খাদ্য',
    'drinks': 'পানীয়',
    'clothing': 'পোশাক',
    'greetings': 'সালাম ও অভিবাদন',
    'manners': 'আদব ও শিষ্টাচার',
    'medicine': 'চিকিৎসা',
    'patients': 'রোগী ও চিকিৎসা',
    'dreams': 'স্বপ্ন',
    'invocations': 'দোয়া ও যিকির',
    'supplication': 'দোয়া',
    'remembrance': 'যিকির',
    'repentance': 'তওবা',
    'virtues': 'ফযীলত',
    'destiny': 'তাকদীর',
    'divine will': 'তাকদীর',
    'judgment': 'বিচার ও ফয়সালা',
    'judgments': 'বিচার ও ফয়সালা',
    'jihad': 'জিহাদ',
    'leadership': 'নেতৃত্ব',
    'fitnah': 'ফিতনা',
    'tribulations': 'ফিতনা ও বিপদ',
    'paradise': 'জান্নাত',
    'hellfire': 'জাহান্নাম',
    'punishments': 'দণ্ডবিধি',
    'legal punishments': 'শরয়ী দণ্ড',
    'blood-money': 'রক্তপণ',
    'sacrifice': 'কুরবানী',
    'hunting': 'শিকার',
    'creation': 'সৃষ্টির সূচনা',
    'beginning of creation': 'সৃষ্টির সূচনা',
    'prophets': 'নবীগণ',
    'companions': 'সাহাবায়ে কেরাম',
    'manumission': 'দাসমুক্তি',
    'asking permission': 'অনুমতি প্রার্থনা',
    'one-fifth of booty to the cause of allah (khumus)': 'গনীমতের এক-পঞ্চমাংশ',
    "fighting for the cause of allah (jihaad)": 'আল্লাহর পথে জিহাদ',
    'jizyah and mawaadaah': 'জিযিয়া ও সন্ধিচুক্তি',
  };

  static String _bnDigits(int value) {
    const digits = '০১২৩৪৫৬৭৮৯';
    return value.toString().split('').map((d) => digits[int.parse(d)]).join();
  }
}
