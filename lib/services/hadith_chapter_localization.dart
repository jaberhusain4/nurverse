// lib/services/hadith_chapter_localization.dart

/// Offline Bengali chapter-title localization for all bundled Hadith collections.
///
/// Bengali assets may contain generic placeholders or incomplete section
/// metadata. In those cases we use the English canonical title as the source
/// and translate it through a conservative offline vocabulary.
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

    final genericBn = _isGenericPlaceholder(bn) || _isGenericChapter(bn);
    final genericEn = _isGenericPlaceholder(en) || _isGenericChapter(en);
    final genericAr = RegExp(r'^الفصل\s*\d+$').hasMatch(ar);

    // Never let a placeholder such as “অধ্যায় ২১ - অন্যান্য বিষয়” win.
    if (bn.isNotEmpty && !_containsLatin(bn) && !genericBn) {
      return _withChapterNumber(chapterIndex, bn);
    }

    final direct = _subjects[_normalize(en)] ?? _subjects[_normalize(bn)];
    if (direct != null) {
      return _withChapterNumber(chapterIndex, direct);
    }

    if (!genericEn && en.isNotEmpty) {
      final translated = _translateEnglishTitle(en);
      if (translated.isNotEmpty) {
        return _withChapterNumber(chapterIndex, translated);
      }
    }

    if (!genericAr && ar.isNotEmpty) {
      return _withChapterNumber(chapterIndex, ar);
    }

    // Never manufacture “অন্যান্য বিষয়” as a chapter title.
    return 'অধ্যায় ${_bnDigits(chapterIndex)}';
  }

  static String _withChapterNumber(int chapterIndex, String title) =>
      'অধ্যায় ${_bnDigits(chapterIndex)} — $title';

  static bool _containsLatin(String value) => RegExp(r'[A-Za-z]').hasMatch(value);

  static bool _isGenericChapter(String value) =>
      RegExp(r'^(অধ্যায়|অধ্যায়)\s*\d+(\s*-\s*.*)?$', caseSensitive: false)
          .hasMatch(value.trim()) ||
      RegExp(r'^chapter\s*\d+(\s*-\s*.*)?$', caseSensitive: false)
          .hasMatch(value.trim());

  static bool _isGenericPlaceholder(String value) {
    final normalized = _normalize(value);
    if (normalized.isEmpty) return false;

    return normalized.contains('অন্যান্য বিষয়') ||
        normalized.contains('অন্যান্য বিষয়') ||
        normalized.contains('other topics') ||
        normalized.contains('other subjects') ||
        normalized.contains('other matters') ||
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

  static String _translateEnglishTitle(String value) {
    var text = _normalize(value);

    // Exact/common chapter titles first.
    final exact = _subjects[text];
    if (exact != null) return exact;

    const phraseMap = <String, String>{
      'actions while praying': 'সালাতের সময়কার কাজ',
      'forgetfulness in prayer': 'সালাতে ভুল-ত্রুটি ও সাহু সিজদা',
      'the book of ': '',
      'book of ': '',
      'chapter on ': '',
      'chapters on ': '',
      'virtues of ': 'ফযীলত ও মর্যাদা: ',
      'merits of ': 'ফযীলত ও মর্যাদা: ',
      'description of ': 'বিবরণ: ',
      'characteristics of ': 'বৈশিষ্ট্য: ',
      'times of ': 'সময়সমূহ: ',
      'during ': 'চলাকালীন ',
      'regarding ': 'সম্পর্কে ',
      'according to ': 'অনুযায়ী ',
      'with ': 'সহ ',
      'without ': 'ব্যতীত ',
      'after ': 'পর ',
      'before ': 'আগে ',
      'from ': 'থেকে ',
      'for ': 'জন্য ',
      'about ': 'সম্পর্কে ',
      'on ': 'সম্পর্কে ',
      'of ': 'এর ',
      'and ': 'ও ',
      'the ': '',
      'a ': '',
      'an ': '',
    };

    for (final entry in phraseMap.entries) {
      text = text.replaceAll(entry.key, entry.value);
    }

    const tokenMap = <String, String>{
      'revelation': 'ওহী',
      'faith': 'ঈমান',
      'belief': 'আকীদা',
      'islam': 'ইসলাম',
      'knowledge': 'ইলম ও জ্ঞান',
      'purification': 'পবিত্রতা',
      'ablution': 'উযূ',
      'ablutions': 'উযূ',
      'wudu': 'উযূ',
      'bathing': 'গোসল',
      'ghusl': 'গোসল',
      'menstruation': 'হায়েয',
      'menstrual': 'হায়েয',
      'tayammum': 'তায়াম্মুম',
      'prayer': 'সালাত',
      'prayers': 'সালাত',
      'salat': 'সালাত',
      'call': 'আযান',
      'adhaan': 'আযান',
      'friday': 'জুমুআ',
      'festival': 'ঈদ',
      'festivals': 'ঈদসমূহ',
      'eid': 'ঈদ',
      'eids': 'ঈদসমূহ',
      'witr': 'বিতর',
      'night': 'রাত',
      'tahajjud': 'তাহাজ্জুদ',
      'eclipse': 'গ্রহণ',
      'eclipses': 'গ্রহণসমূহ',
      'prostration': 'সিজদা',
      'recital': 'তিলাওয়াত',
      'quran': 'কুরআন',
      'shortening': 'কসর',
      'fasting': 'সিয়াম ও রোযা',
      'fast': 'রোযা',
      'zakat': 'যাকাত',
      'charity': 'সদকা',
      'pilgrimage': 'হজ্জ',
      'hajj': 'হজ্জ',
      'umrah': 'উমরাহ',
      'madinah': 'মদিনা',
      'medina': 'মদিনা',
      'makkah': 'মক্কা',
      'mecca': 'মক্কা',
      'qadr': 'কদর',
      'itikaf': 'ইতিকাফ',
      "i'tikaf": 'ইতিকাফ',
      'remembrance': 'যিকির',
      'invocations': 'দোয়া ও যিকির',
      'supplication': 'দোয়া',
      'repentance': 'তওবা',
      'sales': 'ক্রয়-বিক্রয়',
      'sale': 'বিক্রয়',
      'trade': 'ব্যবসা',
      'transactions': 'লেনদেন',
      'transaction': 'লেনদেন',
      'agriculture': 'কৃষি',
      'water': 'পানি',
      'distribution': 'বণ্টন',
      'loans': 'ঋণ',
      'loan': 'ঋণ',
      'partnership': 'অংশীদারিত্ব',
      'mortgaging': 'বন্ধক',
      'hiring': 'নিয়োগ ও শ্রম',
      'gifts': 'উপহার',
      'gift': 'উপহার',
      'witnesses': 'সাক্ষ্য',
      'testimonies': 'সাক্ষ্য',
      'peacemaking': 'মীমাংসা ও সন্ধি',
      'peace': 'শান্তি',
      'conditions': 'শর্তাবলি',
      'condition': 'শর্ত',
      'oppressions': 'জুলুম ও নির্যাতন',
      'oppression': 'জুলুম ও নির্যাতন',
      'funerals': 'জানাযা',
      'funeral': 'জানাযা',
      'wills': 'অছিয়ত',
      'will': 'অছিয়ত',
      'inheritance': 'উত্তরাধিকার',
      'oaths': 'শপথ',
      'oath': 'শপথ',
      'vows': 'মানত',
      'vow': 'মানত',
      'divorce': 'তালাক',
      'marriage': 'বিবাহ',
      'food': 'খাদ্য',
      'drinks': 'পানীয়',
      'drink': 'পানীয়',
      'clothing': 'পোশাক',
      'dress': 'পোশাক',
      'greetings': 'সালাম',
      'manners': 'আদব ও শিষ্টাচার',
      'medicine': 'চিকিৎসা',
      'patients': 'রোগীগণ',
      'patient': 'রোগী',
      'dreams': 'স্বপ্ন',
      'dream': 'স্বপ্ন',
      'virtues': 'ফযীলত',
      'virtue': 'ফযীলত',
      'destiny': 'তাকদীর',
      'divine': 'আল্লাহর',
      'judgment': 'বিচার ও ফয়সালা',
      'judgments': 'বিচার ও ফয়সালা',
      'jihad': 'জিহাদ',
      'leadership': 'নেতৃত্ব',
      'fitnah': 'ফিতনা',
      'tribulations': 'ফিতনা ও বিপদ',
      'paradise': 'জান্নাত',
      'heaven': 'জান্নাত',
      'hellfire': 'জাহান্নাম',
      'hell': 'জাহান্নাম',
      'punishments': 'শাস্তি',
      'punishment': 'শাস্তি',
      'legal': 'শরয়ী',
      'blood-money': 'রক্তপণ',
      'sacrifice': 'কুরবানী',
      'hunting': 'শিকার',
      'creation': 'সৃষ্টি',
      'beginning': 'সূচনা',
      'prophets': 'নবীগণ',
      'prophet': 'নবী',
      'companions': 'সাহাবায়ে কেরাম',
      'companion': 'সাহাবী',
      'manumission': 'দাসমুক্তি',
      'slaves': 'দাসগণ',
      'slave': 'দাস',
      'permission': 'অনুমতি',
      'asking': 'প্রার্থনা',
      'booty': 'গনীমত',
      'fighting': 'সংগ্রাম',
      'cause': 'পথ',
      'jizyah': 'জিযিয়া',
      'justice': 'ন্যায়বিচার',
      'righteousness': 'নেক আমল',
      'hypocrisy': 'মুনাফিকী',
      'hypocrites': 'মুনাফিকগণ',
      'scholars': 'আলিমগণ',
      'muslims': 'মুসলিমগণ',
      'muslim': 'মুসলিম',
      'allah': 'আল্লাহ',
      'messenger': 'রাসূল',
      'messengers': 'রাসূলগণ',
      'prophecy': 'নবুওত',
      'community': 'উম্মাহ',
      'people': 'মানুষ',
      'men': 'পুরুষগণ',
      'women': 'নারীগণ',
      'children': 'শিশুগণ',
      'child': 'শিশু',
      'parents': 'পিতা-মাতা',
      'father': 'পিতা',
      'mother': 'মাতা',
      'brother': 'ভাই',
      'sister': 'বোন',
      'house': 'ঘর',
      'mosque': 'মসজিদ',
      'market': 'বাজার',
      'travel': 'সফর',
      'travelling': 'সফর',
      'journey': 'সফর',
      'rings': 'আংটি',
      'ring': 'আংটি',
      'hair': 'চুল',
      'beard': 'দাড়ি',
      'names': 'নামসমূহ',
      'name': 'নাম',
      'character': 'চরিত্র',
      'characteristics': 'বৈশিষ্ট্য',
      'description': 'বিবরণ',
      'stories': 'ঘটনাবলি',
      'story': 'ঘটনা',
      'signs': 'নিদর্শনসমূহ',
      'sign': 'নিদর্শন',
      'miracles': 'মুজিযা',
      'miracle': 'মুজিযা',
      'kings': 'বাদশাহগণ',
      'king': 'বাদশাহ',
      'government': 'শাসন',
      'ruler': 'শাসক',
      'rulers': 'শাসকগণ',
      'army': 'সেনাবাহিনী',
      'armies': 'সেনাবাহিনীসমূহ',
      'battle': 'যুদ্ধ',
      'battles': 'যুদ্ধসমূহ',
      'treatment': 'আচরণ',
      'rights': 'অধিকারসমূহ',
      'right': 'অধিকার',
      'duty': 'কর্তব্য',
      'duties': 'কর্তব্যসমূহ',
      'obligations': 'বাধ্যবাধকতা',
      'obligation': 'বাধ্যবাধকতা',
      'prohibition': 'নিষেধ',
      'prohibitions': 'নিষেধাজ্ঞাসমূহ',
      'law': 'বিধান',
      'laws': 'বিধানসমূহ',
      'commandments': 'নির্দেশসমূহ',
      'commandment': 'নির্দেশ',
      'questions': 'প্রশ্নসমূহ',
      'question': 'প্রশ্ন',
      'answers': 'উত্তরসমূহ',
      'answer': 'উত্তর',
      'evidence': 'প্রমাণ',
      'proof': 'প্রমাণ',
      'interpretation': 'ব্যাখ্যা',
      'explanation': 'ব্যাখ্যা',
      'traditions': 'হাদিসসমূহ',
      'tradition': 'হাদিস',
      'hadith': 'হাদিস',
      'book': 'কিতাব',
      'books': 'কিতাবসমূহ',
    };

    // Prefer longer phrases by replacing multi-word entries first.
    final ordered = tokenMap.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

    for (final entry in ordered) {
      text = text.replaceAll(
        RegExp(r'\b' + RegExp.escape(entry.key) + r'\b', caseSensitive: false),
        entry.value,
      );
    }

    // Clean grammar artifacts created by the English-to-Bengali phrase map.
    text = text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(' ,', ',')
        .replaceAll(' .', '.')
        .replaceAll(' :', ':')
        .trim();

    if (text.isEmpty || _containsLatin(text)) {
      return '';
    }

    return text;
  }

  static const Map<String, String> _subjects = {
    'revelation': 'ওহীর সূচনা',
    'faith': 'ঈমান',
    'belief': 'আকীদা',
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
    'fasting': 'সিয়াম ও রোযা',
    'zakat': 'যাকাত',
    'hajj': 'হজ্জ',
    'umrah': 'উমরাহ',
    'night of qadr': 'লাইলাতুল কদর',
    "i'tikaf": 'ইতিকাফ',
    'sales and trade': 'ক্রয়-বিক্রয় ও ব্যবসা',
    'sales': 'ক্রয়-বিক্রয়',
    'transactions': 'লেনদেন',
    'agriculture': 'কৃষি',
    'loans': 'ঋণ',
    'partnership': 'অংশীদারিত্ব',
    'gifts': 'উপহার',
    'witnesses': 'সাক্ষ্য',
    'peacemaking': 'মীমাংসা ও সন্ধি',
    'oppressions': 'জুলুম ও নির্যাতন',
    'funerals': 'জানাযা',
    'wills': 'অছিয়ত',
    'inheritance': 'উত্তরাধিকার',
    'oaths': 'শপথ',
    'vows': 'মানত',
    'divorce': 'তালাক',
    'marriage': 'বিবাহ',
    'food': 'খাদ্য',
    'drinks': 'পানীয়',
    'clothing': 'পোশাক',
    'manners': 'আদব ও শিষ্টাচার',
    'medicine': 'চিকিৎসা',
    'dreams': 'স্বপ্ন',
    'invocations': 'দোয়া ও যিকির',
    'supplication': 'দোয়া',
    'remembrance': 'যিকির',
    'repentance': 'তওবা',
    'virtues': 'ফযীলত',
    'destiny': 'তাকদীর',
    'judgment': 'বিচার ও ফয়সালা',
    'judgments': 'বিচার ও ফয়সালা',
    'jihad': 'জিহাদ',
    'leadership': 'নেতৃত্ব',
    'fitnah': 'ফিতনা',
    'tribulations': 'ফিতনা ও বিপদ',
    'paradise': 'জান্নাত',
    'hellfire': 'জাহান্নাম',
    'punishments': 'দণ্ডবিধি',
    'sacrifice': 'কুরবানী',
    'hunting': 'শিকার',
    'creation': 'সৃষ্টির সূচনা',
    'beginning of creation': 'সৃষ্টির সূচনা',
    'prophets': 'নবীগণ',
    'companions': 'সাহাবায়ে কেরাম',
    'manumission': 'দাসমুক্তি',
    'asking permission': 'অনুমতি প্রার্থনা',
    'actions while praying': 'সালাতের সময়কার কাজ',
    'forgetfulness in prayer': 'সালাতে ভুল-ত্রুটি ও সাহু সিজদা',
  };

  static String _bnDigits(int value) {
    const digits = '০১২৩৪৫৬৭৮৯';
    return value.toString().split('').map((d) => digits[int.parse(d)]).join();
  }
}
