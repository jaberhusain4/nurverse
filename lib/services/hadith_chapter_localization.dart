// lib/services/hadith_chapter_localization.dart

/// Offline Bengali chapter-title localization for Hadith collections.
///
/// The bundled Bengali editions do not consistently contain Bengali section
/// metadata. This layer keeps the UI Bengali-first without changing hadith
/// IDs, book numbers, or the bundled JSON assets.
class HadithChapterLocalization {
  const HadithChapterLocalization._();

  static String localize({
    required String bengali,
    required String english,
    required String arabic,
    required int chapterIndex,
    String? bookKey,
  }) {
    final bn = bengali.trim();
    final normalizedBn = _normalize(bn);

    // Some bundled Bengali metadata contains a generic placeholder such as
    // “অধ্যায় ২১ - অন্যান্য বিষয়”. Never surface that placeholder when a
    // collection-specific title is available.
    final isPlaceholder = _isGenericPlaceholder(normalizedBn);

    if (bn.isNotEmpty && !_containsLatin(bn) && !isPlaceholder) return bn;

    // Sahih al-Bukhari book metadata has a few generic Bengali placeholders.
    // Use the canonical Bengali book titles for those positions instead of
    // leaking “অন্যান্য বিষয়” into the chapter list.
    if (bookKey == 'bukhari') {
      final bukhariTitle = _bukhariBookTitles[chapterIndex];
      if (bukhariTitle != null) return bukhariTitle;
    }

    final direct = _subjects[normalizedBn] ?? _subjects[_normalize(english)];
    if (direct != null) return direct;

    final generated = _generateFromEnglish(english);
    if (generated != null) return generated;

    // Never leak English, Arabic, or a generic placeholder into the Bengali
    // chapter list.
    return 'অধ্যায় ${_bnDigits(chapterIndex)}';
  }

  static bool _containsLatin(String value) => RegExp(r'[A-Za-z]').hasMatch(value);

  static bool _isGenericPlaceholder(String value) {
    if (value.isEmpty) return false;

    return value.contains('অন্যান্য বিষয়') ||
        value.contains('অন্যান্য বিষয়') ||
        value.contains('other topics') ||
        value.contains('other subjects') ||
        value.contains('miscellaneous');
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
    if (normalized.isEmpty || _isGenericPlaceholder(normalized)) return null;

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

  // Canonical Bengali names for Sahih al-Bukhari books 21 and 22. These are
  // the titles used by the Bengali HadithBD edition and correspond to the
  // canonical English books “Actions while Praying” and “Forgetfulness in
  // Prayer”.
  static const Map<int, String> _bukhariBookTitles = {
    21: 'সালাতের সাথে সংশ্লিষ্ট কাজ',
    22: 'সাহু সিজদা',
  };

  static const Map<String, String> _subjects = {
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
