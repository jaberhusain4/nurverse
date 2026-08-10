// lib/services/hadith_chapter_localization.dart

/// Offline Bengali chapter-title localization for Hadith collections.
///
/// The bundled Bengali editions do not consistently contain Bengali section
/// metadata. This layer keeps the UI Bengali-first without changing the
/// underlying hadith IDs, book numbers, or bundled JSON assets.
class HadithChapterLocalization {
  const HadithChapterLocalization._();

  static String localize({
    required String bengali,
    required String english,
    required String arabic,
    required int chapterIndex,
  }) {
    final bn = bengali.trim();
    if (bn.isNotEmpty && !_containsLatin(bn)) return bn;

    final direct = _map[_normalize(bn)] ?? _map[_normalize(english)];
    if (direct != null) return direct;

    final generated = _generateFromEnglish(english);
    if (generated != null) return generated;

    // Do not leak English metadata into the Bengali UI.
    final ar = arabic.trim();
    if (ar.isNotEmpty) return ar;

    return 'অধ্যায় ${_bnDigits(chapterIndex)}';
  }

  static bool _containsLatin(String value) => RegExp(r'[A-Za-z]').hasMatch(value);

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
    if (normalized.isEmpty) return null;

    const exactPrefixes = <String, String>{
      'the book of ': 'কিতাবুল ',
      'book of ': 'কিতাবুল ',
    };

    for (final entry in exactPrefixes.entries) {
      if (normalized.startsWith(entry.key)) {
        final subject = normalized.substring(entry.key.length).trim();
        final translated = _subjects[subject];
        if (translated != null) return '${translated}-এর কিতাব';
      }
    }

    final exact = _subjects[normalized];
    if (exact != null) return exact;

    return null;
  }

  static const Map<String, String> _subjects = {
    'faith': 'ঈমান',
    'belief': 'ঈমান',
    'iman': 'ঈমান',
    'purification': 'পবিত্রতা',
    'ablution': 'উযূ',
    'ablutions': 'উযূ',
    'prayer': 'সালাত',
    'prayers': 'সালাত',
    'fasting': 'সিয়াম ও রোযা',
    'zakat': 'যাকাত',
    'hajj': 'হজ্জ',
    'umrah': 'উমরাহ',
    'marriage': 'বিবাহ',
    'divorce': 'তালাক',
    'inheritance': 'উত্তরাধিকার',
    'wills': 'অছিয়ত',
    'oaths': 'শপথ',
    'vows': 'মানত',
    'business': 'ব্যবসা-বাণিজ্য',
    'transactions': 'লেনদেন',
    'sales': 'ক্রয়-বিক্রয়',
    'gifts': 'উপহার',
    'food': 'খাদ্য',
    'drinks': 'পানীয়',
    'clothing': 'পোশাক',
    'greetings': 'সালাম ও অভিবাদন',
    'manners': 'আদব ও শিষ্টাচার',
    'knowledge': 'ইলম',
    'remembrance': 'যিকির',
    'supplication': 'দোয়া',
    'repentance': 'তওবা',
    'virtues': 'ফযীলত',
    'destiny': 'তাকদীর',
    'judgment': 'বিচার',
    'judgments': 'বিচার ও ফয়সালা',
    'jihad': 'জিহাদ',
    'leadership': 'নেতৃত্ব',
    'fitnah': 'ফিতনা',
    'paradise': 'জান্নাত',
    'hellfire': 'জাহান্নাম',
    'punishments': 'দণ্ডবিধি',
    'legal punishments': 'শরয়ী দণ্ড',
    'blood-money': 'রক্তপণ',
    'medicine': 'চিকিৎসা',
    'patients': 'রোগী ও চিকিৎসা',
    'dreams': 'স্বপ্ন',
    'creation': 'সৃষ্টির সূচনা',
    'prophets': 'নবীগণ',
    'companions': 'সাহাবায়ে কেরাম',
    'revelation': 'ওহী',
    'divine will': 'তাকদীর',
    'tribulations': 'ফিতনা ও বিপদ',
    'funerals': 'জানাযা',
    'sacrifice': 'কুরবানী',
    'hunting': 'শিকার',
    'agriculture': 'কৃষি',
    'loans': 'ঋণ',
    'partnership': 'অংশীদারিত্ব',
    'witnesses': 'সাক্ষ্য',
    'testimonies': 'সাক্ষ্যসমূহ',
    'peacemaking': 'মীমাংসা ও সন্ধি',
    'conditions': 'শর্তাবলি',
    'manumission': 'দাসমুক্তি',
    'asking permission': 'অনুমতি প্রার্থনা',
    'invocations': 'দোয়া ও যিকির',
    'night prayer': 'রাতের সালাত',
    'friday prayer': 'জুমুআর সালাত',
    'witr prayer': 'বিতর সালাত',
    'eclipses': 'সূর্য ও চন্দ্রগ্রহণ',
    'the two festivals': 'দুই ঈদের সালাত',
    'times of the prayers': 'সালাতের ওয়াক্ত',
    'call to prayers': 'আযান',
    'fear prayer': 'ভয়ের সময়ের সালাত',
    'bathing': 'গোসল',
    'menstrual periods': 'হায়েয',
    'tayammum': 'তায়াম্মুম',
    'prostration': 'সিজদা',
    'shortening the prayers': 'সালাত কসর করা',
    'night of qadr': 'লাইলাতুল কদর',
    'i\'tikaf': 'ইতিকাফ',
    'beginning of creation': 'সৃষ্টির সূচনা',
    'virtues of madinah': 'মদিনার ফযীলত',
  };

  static String _bnDigits(int value) {
    const digits = '০১২৩৪৫৬৭৮৯';
    return value.toString().split('').map((d) => digits[int.parse(d)]).join();
  }
}
