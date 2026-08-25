class HadithBengaliTitleBuilder {
  const HadithBengaliTitleBuilder._();

  static String build(String english) {
    var text = _normalize(english);
    text = _removeStructuralPhrases(text);

    final exact = _exact[text];
    if (exact != null) return exact;

    final words = text.split(RegExp(r"[^a-z0-9\-']+")).where((w) => w.isNotEmpty);
    final translated = <String>[];
    for (final raw in words) {
      final word = raw.toLowerCase();
      translated.add(_words[word] ?? _transliterate(word));
    }

    final result = translated.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    return result.isEmpty ? 'হাদিসের বিষয়' : result;
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('’', "'")
      .replaceAll('`', "'")
      .replaceAll('–', '-')
      .replaceAll('—', '-')
      .replaceAll(RegExp(r'\s+'), ' ');

  static String _removeStructuralPhrases(String value) {
    var text = value;
    const phrases = [
      'the book of ', 'book of ', 'chapter on ', 'chapters on ',
      'chapter about ', 'the chapter of ', 'the chapter on ',
    ];
    for (final phrase in phrases) text = text.replaceFirst(phrase, '');
    return text.trim();
  }

  static const Map<String, String> _exact = {
    'actions while praying': 'সালাতের সময়কার কাজ',
    'forgetfulness in prayer': 'সালাতে ভুল-ত্রুটি ও সাহু সিজদা',
    'virtues of prayer at masjid makkah and madinah': 'মক্কা ও মদিনার মসজিদে সালাতের ফযীলত',
    'obligatory charity tax zakat': 'ফরয যাকাত',
    'beginning of creation': 'সৃষ্টির সূচনা',
    'holding fast to the quran and sunnah': 'কুরআন ও সুন্নাহকে দৃঢ়ভাবে ধারণ',
    'oneness uniqueness of allah tawheed': 'আল্লাহর একত্ব ও তাওহীদ',
  };

  static const Map<String, String> _words = {
    'revelation': 'ওহী', 'faith': 'ঈমান', 'belief': 'আকীদা', 'islam': 'ইসলাম',
    'knowledge': 'ইলম', 'purification': 'পবিত্রতা', 'ablution': 'উযূ', 'ablutions': 'উযূ',
    'wudu': 'উযূ', 'bathing': 'গোসল', 'ghusl': 'গোসল', 'menstrual': 'হায়েয', 'periods': 'মাসিক',
    'tayammum': 'তায়াম্মুম', 'prayer': 'সালাত', 'prayers': 'সালাত', 'salat': 'সালাত',
    'call': 'আযান', 'adhaan': 'আযান', 'friday': 'জুমুআ', 'fear': 'ভয়', 'festival': 'ঈদ',
    'festivals': 'ঈদসমূহ', 'eid': 'ঈদ', 'eids': 'ঈদসমূহ', 'witr': 'বিতর', 'night': 'রাত',
    'tahajjud': 'তাহাজ্জুদ', 'eclipse': 'গ্রহণ', 'eclipses': 'গ্রহণসমূহ', 'prostration': 'সিজদা',
    'recital': 'তিলাওয়াত', 'quran': 'কুরআন', 'shortening': 'কসর', 'fasting': 'সিয়াম ও রোযা',
    'fast': 'রোযা', 'zakat': 'যাকাত', 'charity': 'সদকা', 'pilgrimage': 'হজ্জ', 'hajj': 'হজ্জ',
    'umrah': 'উমরাহ', 'madinah': 'মদিনা', 'medina': 'মদিনা', 'makkah': 'মক্কা', 'mecca': 'মক্কা',
    'qadr': 'কদর', 'itikaf': 'ইতিকাফ', "i'tikaf": 'ইতিকাফ', 'remembrance': 'যিকির',
    'invocations': 'দোয়া ও যিকির', 'invocation': 'দোয়া', 'supplication': 'দোয়া', 'repentance': 'তওবা',
    'sales': 'ক্রয়-বিক্রয়', 'sale': 'বিক্রয়', 'trade': 'ব্যবসা', 'transactions': 'লেনদেন',
    'transaction': 'লেনদেন', 'agriculture': 'কৃষি', 'water': 'পানি', 'distribution': 'বণ্টন',
    'loans': 'ঋণসমূহ', 'loan': 'ঋণ', 'partnership': 'অংশীদারিত্ব', 'mortgaging': 'বন্ধক',
    'hiring': 'নিয়োগ ও শ্রম', 'gifts': 'উপহার', 'gift': 'উপহার', 'witnesses': 'সাক্ষ্য',
    'witness': 'সাক্ষী', 'testimonies': 'সাক্ষ্য', 'peacemaking': 'মীমাংসা ও সন্ধি', 'peace': 'শান্তি',
    'conditions': 'শর্তাবলি', 'condition': 'শর্ত', 'oppressions': 'জুলুম ও নির্যাতন',
    'oppression': 'জুলুম ও নির্যাতন', 'funerals': 'জানাযা', 'funeral': 'জানাযা', 'wills': 'অছিয়ত',
    'will': 'অছিয়ত', 'inheritance': 'উত্তরাধিকার', 'oaths': 'শপথ', 'oath': 'শপথ', 'vows': 'মানত',
    'vow': 'মানত', 'divorce': 'তালাক', 'marriage': 'বিবাহ', 'wedlock': 'বিবাহ', 'food': 'খাদ্য',
    'drinks': 'পানীয়', 'drink': 'পানীয়', 'clothing': 'পোশাক', 'dress': 'পোশাক',
    'greetings': 'সালাম', 'manners': 'আদব ও শিষ্টাচার', 'medicine': 'চিকিৎসা', 'patients': 'রোগীগণ',
    'patient': 'রোগী', 'dreams': 'স্বপ্ন', 'dream': 'স্বপ্ন', 'virtues': 'ফযীলত', 'virtue': 'ফযীলত',
    'merits': 'মর্যাদা ও ফযীলত', 'merit': 'ফযীলত', 'destiny': 'তাকদীর', 'divine': 'আল্লাহর',
    'judgment': 'বিচার ও ফয়সালা', 'judgments': 'বিচার ও ফয়সালা', 'jihad': 'জিহাদ', 'leadership': 'নেতৃত্ব',
    'fitnah': 'ফিতনা', 'tribulations': 'ফিতনা ও বিপদ', 'paradise': 'জান্নাত', 'heaven': 'জান্নাত',
    'hellfire': 'জাহান্নাম', 'hell': 'জাহান্নাম', 'punishments': 'শাস্তি', 'punishment': 'শাস্তি',
    'legal': 'শরয়ী', 'blood-money': 'রক্তপণ', 'sacrifice': 'কুরবানী', 'hunting': 'শিকার',
    'slaughtering': 'জবাই', 'creation': 'সৃষ্টি', 'beginning': 'সূচনা', 'prophets': 'নবীগণ',
    'prophet': 'নবী', 'companions': 'সাহাবায়ে কেরাম', 'companion': 'সাহাবী', 'manumission': 'দাসমুক্তি',
    'slaves': 'দাসগণ', 'slave': 'দাস', 'permission': 'অনুমতি', 'permissions': 'অনুমতিসমূহ',
    'asking': 'চাওয়া', 'booty': 'গনীমত', 'fighting': 'যুদ্ধ', 'cause': 'পথ', 'jizyah': 'জিযিয়া',
    'justice': 'ন্যায়বিচার', 'righteousness': 'নেক আমল', 'hypocrisy': 'মুনাফিকী',
    'hypocrites': 'মুনাফিকগণ', 'scholars': 'আলিমগণ', 'muslims': 'মুসলিমগণ', 'muslim': 'মুসলিম',
    'allah': 'আল্লাহ', 'messenger': 'রাসূল', 'messengers': 'রাসূলগণ', 'prophecy': 'নবুওত',
    'community': 'উম্মাহ', 'people': 'লোকজন', 'children': 'শিশুগণ', 'child': 'শিশু',
    'parents': 'পিতা-মাতা', 'father': 'পিতা', 'mother': 'মাতা', 'family': 'পরিবার',
    'wives': 'স্ত্রীগণ', 'wife': 'স্ত্রী', 'husbands': 'স্বামীগণ', 'husband': 'স্বামী',
    'property': 'সম্পদ', 'wealth': 'সম্পদ', 'money': 'অর্থ', 'debts': 'ঋণসমূহ', 'debt': 'ঋণ',
    'bankruptcy': 'দেউলিয়াত্ব', 'lost': 'হারানো', 'things': 'বস্তুসমূহ', 'picked': 'কুড়ানো',
    'supporting': 'ভরণ-পোষণ', 'support': 'সহায়তা', 'accepting': 'গ্রহণ', 'information': 'তথ্য',
    'truthful': 'সত্যবাদী', 'holding': 'ধরে রাখা', 'times': 'সময়সমূহ', 'time': 'সময়', 'days': 'দিনসমূহ',
    'day': 'দিন', 'first': 'প্রথম', 'last': 'শেষ', 'price': 'মূল্য', 'paid': 'পরিশোধকৃত',
    'pay': 'পরিশোধ', 'goods': 'পণ্য', 'delivered': 'সরবরাহকৃত', 'later': 'পরবর্তীতে',
    'meals': 'খাদ্য ও আহার', 'heart': 'হৃদয়', 'tender': 'কোমল', 'expiation': 'কাফফারা',
    'unfulfilled': 'অপূর্ণ', 'laws': 'বিধানসমূহ', 'limits': 'হদ্দসমূহ', 'apostates': 'মুরতাদগণ',
    'coercion': 'জবরদস্তি', 'tricks': 'কৌশল', 'afflictions': 'বিপদ-আপদ', 'end': 'শেষ', 'world': 'দুনিয়া',
    'wishes': 'আকাঙ্ক্ষা', 'oneness': 'একত্ব', 'uniqueness': 'অদ্বিতীয়তা', 'tawheed': 'তাওহীদ',
    'book': 'কিতাব', 'chapter': 'অধ্যায়', 'at': 'এ', 'in': 'মধ্যে', 'on': 'সম্পর্কে', 'of': 'এর',
    'and': 'ও', 'the': '', 'a': '', 'an': '', 'to': 'প্রতি', 'for': 'জন্য', 'with': 'সহ',
    'without': 'ব্যতীত', 'after': 'পর', 'before': 'আগে', 'from': 'থেকে', 'during': 'চলাকালীন',
    'while': 'চলাকালীন', 'under': 'অধীনে', 'according': 'অনুযায়ী', 'regarding': 'সম্পর্কে',
    'about': 'সম্পর্কে', 'which': 'যেখানে', 'where': 'যেখানে', 'who': 'যারা', 'whom': 'যাদের',
    'when': 'যখন', 'what': 'যা', 'how': 'কীভাবে', 'by': 'দ্বারা', 'one': 'এক', 'two': 'দুই',
    'five': 'পাঁচ', 'one-fifth': 'এক-পঞ্চমাংশ',
  };

  static String _transliterate(String word) {
    const special = <String, String>{
      'as-salam': 'আস-সালাম', 'shuf\'a': 'শুফআ', 'kafalah': 'কাফালা', 'khumus': 'খুমুস',
      'luqatah': 'লুকতা', 'makaatib': 'মুকাতাবাত', 'mawaada\'ah': 'মুআহাদা',
      'khusoomaat': 'বিবাদ', 'adaahi': 'কুরবানী', 'maghaazi': 'মাগাযী', 'ahkaam': 'আহকাম',
      'hudood': 'হুদূদ', 'diyat': 'দিয়াত', 'wasaayaa': 'অছিয়ত', 'faraa\'id': 'ফারায়েয',
      'al-adab': 'আদব', 'al-qadar': 'তাকদীর', 'al-janaa\'iz': 'জানাযা', 'at-taqseer': 'কসর',
      'istiqsaa': 'বৃষ্টি প্রার্থনা', 'taraweeh': 'তারাবীহ',
    };
    final exact = special[word];
    if (exact != null) return exact;

    var value = word;
    const replacements = <String, String>{
      'tions': 'শনস', 'tion': 'শন', 'th': 'থ', 'dh': 'ধ', 'sh': 'শ', 'ch': 'চ',
      'kh': 'খ', 'gh': 'গ', 'ph': 'ফ', 'bh': 'ভ', 'aa': 'া', 'ee': 'ী', 'oo': 'ু',
      'ou': 'ৌ', 'ai': 'ৈ',
    };
    for (final entry in replacements.entries) value = value.replaceAll(entry.key, entry.value);

    const consonants = <String, String>{
      'b': 'ব','c': 'ক','d': 'দ','f': 'ফ','g': 'গ','h': 'হ','j': 'জ','k': 'ক','l': 'ল',
      'm': 'ম','n': 'ন','p': 'প','q': 'ক','r': 'র','s': 'স','t': 'ত','v': 'ভ','w': 'ও',
      'x': 'ক্স','y': 'য়','z': 'জ',
    };
    const vowels = <String, String>{'a': 'া','e': 'ে','i': 'ি','o': 'ো','u': 'ু'};

    final buffer = StringBuffer();
    for (final ch in value.split('')) {
      if (consonants.containsKey(ch)) buffer.write(consonants[ch]);
      else if (vowels.containsKey(ch)) buffer.write(vowels[ch]);
      else if (RegExp(r'[0-9]').hasMatch(ch)) buffer.write(ch);
      else if (ch == '-') buffer.write('-');
    }
    return buffer.toString().replaceAll(RegExp(r'া{2,}'), 'া');
  }
}
