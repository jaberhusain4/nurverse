// lib/services/hadith_chapter_localization.dart

/// Offline Bengali chapter-title localization for Hadith collections.
///
/// The bundled Bengali editions do not consistently contain Bengali section
/// metadata. This layer keeps the chapter list Bengali-first without changing
/// hadith IDs, book numbers, or the bundled JSON assets.
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

    final genericBn = RegExp(r'^(অধ্যায়|অধ্যায়)\s*\d+$').hasMatch(bn);
    final genericEn = RegExp(r'^chapter\s*\d+$', caseSensitive: false).hasMatch(en);
    final genericAr = RegExp(r'^الفصل\s*\d+$').hasMatch(ar);

    if (bn.isNotEmpty && !_containsLatin(bn) && !genericBn) {
      return _withChapterNumber(chapterIndex, bn);
    }

    final direct = _subjects[_normalize(bn)] ?? _subjects[_normalize(en)];
    if (direct != null) {
      return _withChapterNumber(chapterIndex, direct);
    }

    final generated = _generateFromEnglish(en);
    if (generated != null) {
      return _withChapterNumber(chapterIndex, generated);
    }

    if (!genericEn && en.isNotEmpty) {
      return _withChapterNumber(chapterIndex, _translateEnglishTitle(en));
    }

    if (!genericAr && ar.isNotEmpty) {
      return _withChapterNumber(chapterIndex, 'আরবি অধ্যায়ের নাম');
    }

    return _withChapterNumber(chapterIndex, 'অন্যান্য বিষয়');
  }

  static String _withChapterNumber(int chapterIndex, String title) =>
      'অধ্যায় ${_bnDigits(chapterIndex)} — $title';

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
    if (normalized.isEmpty || RegExp(r'^chapter\s*\d+$').hasMatch(normalized)) {
      return null;
    }

    const prefixes = ['the book of ', 'book of '];
    for (final prefix in prefixes) {
      if (normalized.startsWith(prefix)) {
        final subject = normalized.substring(prefix.length).trim();
        final translated = _subjects[subject];
        if (translated != null) return '$translated-এর কিতাব';
      }
    }

    return _subjects[normalized] ?? _translateEnglishTitle(value);
  }

  /// Converts common English chapter-title phrasing to natural Bengali.
  ///
  /// This is intentionally offline: the app never needs an internet service
  /// just to render a chapter list.
  static String _translateEnglishTitle(String value) {
    var text = _normalize(value);

    const phraseMap = <String, String>{
      'the book of ': '',
      'book of ': '',
      'the ': '',
      'of the ': 'এর ',
      'and ': 'ও ',
      'with ': 'সহ ',
      'on ': 'সম্পর্কে ',
      'about ': 'সম্পর্কে ',
      'regarding ': 'সম্পর্কে ',
      'during ': 'চলাকালীন ',
      'after ': 'পর ',
      'before ': 'আগে ',
      'in ': 'এর মধ্যে ',
      'from ': 'থেকে ',
      'to ': 'প্রতি ',
      'for ': 'জন্য ',
      'according to ': 'অনুযায়ী ',
      'virtues of ': 'এর ফযীলত ',
      'merits of ': 'এর ফযীলত ',
      'characteristics of ': 'এর বৈশিষ্ট্য ',
      'description of ': 'এর বিবরণ ',
      'times of ': 'এর সময়সমূহ ',
      'chapter on ': '',
      'chapters on ': '',
    };

    for (final entry in phraseMap.entries) {
      text = text.replaceAll(entry.key, entry.value);
    }

    const tokenMap = <String, String>{
      'revelation': 'ওহী',
      'faith': 'ঈমান',
      'belief': 'আকীদা',
      'knowledge': 'ইলম',
      'purification': 'পবিত্রতা',
      'ablution': 'উযূ',
      'ablutions': 'উযূ',
      'wudu': 'উযূ',
      'ghusl': 'গোসল',
      'bathing': 'গোসল',
      'menstruation': 'হায়েয',
      'menstrual': 'হায়েয',
      'tayammum': 'তায়াম্মুম',
      'prayer': 'সালাত',
      'prayers': 'সালাত',
      'salat': 'সালাত',
      'call': 'আযান',
      'adhaan': 'আযান',
      'friday': 'জুমুআ',
      'fear': 'ভয়',
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
      'fasting': 'সিয়াম',
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
      'night of qadr': 'লাইলাতুল কদর',
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
      'loans': 'ঋণ',
      'loan': 'ঋণ',
      'partnership': 'অংশীদারিত্ব',
      'mortgaging': 'বন্ধক',
      'hiring': 'নিয়োগ',
      'gifts': 'উপহার',
      'gift': 'উপহার',
      'witnesses': 'সাক্ষ্য',
      'testimonies': 'সাক্ষ্য',
      'peacemaking': 'মীমাংসা',
      'peace': 'শান্তি',
      'conditions': 'শর্তাবলি',
      'condition': 'শর্ত',
      'oppressions': 'জুলুম',
      'oppression': 'জুলুম',
      'funerals': 'জানাযা',
      'funeral': 'জানাযা',
      'wills': 'অছিয়ত',
      'inheritance': 'উত্তরাধিকার',
      'oaths': 'শপথ',
      'oath': 'শপথ',
      'vows': 'মানত',
      'vow': 'মানত',
      'divorce': 'তালাক',
      'marriage': 'বিবাহ',
      'wives': 'স্ত্রীগণ',
      'wife': 'স্ত্রী',
      'husbands': 'স্বামীগণ',
      'husband': 'স্বামী',
      'food': 'খাদ্য',
      'drinks': 'পানীয়',
      'drink': 'পানীয়',
      'clothing': 'পোশাক',
      'dress': 'পোশাক',
      'greetings': 'সালাম',
      'manners': 'আদব',
      'medicine': 'চিকিৎসা',
      'patients': 'রোগীগণ',
      'patient': 'রোগী',
      'dreams': 'স্বপ্ন',
      'dream': 'স্বপ্ন',
      'virtues': 'ফযীলত',
      'virtue': 'ফযীলত',
      'destiny': 'তাকদীর',
      'divine': 'আল্লাহর',
      'will': 'ইচ্ছা',
      'judgment': 'বিচার',
      'judgments': 'বিচারসমূহ',
      'jihad': 'জিহাদ',
      'leadership': 'নেতৃত্ব',
      'fitnah': 'ফিতনা',
      'tribulations': 'বিপদ ও ফিতনা',
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
      'companions': 'সাহাবীগণ',
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
      'knowledgeable': 'জ্ঞানী',
      'scholars': 'আলিমগণ',
      'islam': 'ইসলাম',
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
      'chapter': 'অধ্যায়',
      'chapters': 'অধ্যায়সমূহ',
      'book': 'কিতাব',
      'books': 'কিতাবসমূহ',
    };

    for (final entry in tokenMap.entries) {
      text = text.replaceAll(
        RegExp('\\b${RegExp.escape(entry.key)}\\b', caseSensitive: false),
        entry.value,
      );
    }

    text = text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('  ', ' ')
        .replaceAll(' ,', ',')
        .replaceAll(' .', '.')
        .trim();

    if (text.isEmpty || _containsLatin(text)) {
      return _transliterateRemaining(text.isEmpty ? value : text);
    }

    return text;
  }

  /// Last-resort Bengali-script transliteration for proper names/terms that
  /// are not in the translation dictionary. This prevents English chapter
  /// titles from leaking into the Bengali UI while retaining recognisable
  /// pronunciation.
  static String _transliterateRemaining(String value) {
    final words = value.split(RegExp(r'(\s+)'));
    final converted = <String>[];

    for (final word in words) {
      if (word.trim().isEmpty || !_containsLatin(word)) {
        converted.add(word);
        continue;
      }

      var w = word.toLowerCase();
      const digraphs = <String, String>{
        'tsh': 'টশ',
        'sch': 'শ',
        'sh': 'শ',
        'ch': 'চ',
        'kh': 'খ',
        'gh': 'ঘ',
        'ph': 'ফ',
        'th': 'থ',
        'dh': 'ধ',
        'bh': 'ভ',
        'jh': 'ঝ',
        'ck': 'ক',
        'qu': 'কু',
        'oo': 'ু',
        'ee': 'ী',
        'aa': 'া',
        'ai': 'ঐ',
        'au': 'ঔ',
      };

      for (final entry in digraphs.entries) {
        w = w.replaceAll(entry.key, entry.value);
      }

      const letters = <String, String>{
        'a': 'আ',
        'b': 'ব',
        'c': 'ক',
        'd': 'দ',
        'e': 'এ',
        'f': 'ফ',
        'g': 'গ',
        'h': 'হ',
        'i': 'ই',
        'j': 'জ',
        'k': 'ক',
        'l': 'ল',
        'm': 'ম',
        'n': 'ন',
        'o': 'ও',
        'p': 'প',
        'q': 'ক',
        'r': 'র',
        's': 'স',
        't': 'ত',
        'u': 'উ',
        'v': 'ভ',
        'w': 'ও',
        'x': 'ক্স',
        'y': 'ই',
        'z': 'জ',
      };

      final buffer = StringBuffer();
      for (final rune in w.runes) {
        final ch = String.fromCharCode(rune);
        buffer.write(letters[ch] ?? ch);
      }

      converted.add(buffer.toString());
    }

    final result = converted.join();
    return _containsLatin(result) ? 'অন্যান্য বিষয়' : result;
  }

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
