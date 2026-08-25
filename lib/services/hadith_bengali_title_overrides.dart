class HadithBengaliTitleOverrides {
  const HadithBengaliTitleOverrides._();

  static String? resolve(String english) {
    final key = english
        .trim()
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll('`', "'")
        .replaceAll(RegExp(r'\s+'), ' ');
    return _titles[key];
  }

  static const Map<String, String> _titles = {
    'purity': 'পবিত্রতা',
    "jumu'a": 'জুমুআ',
    'jumua': 'জুমুআ',
    "jumu'ah": 'জুমুআ',
    'jumua prayer': 'জুমুআর সালাত',
    'friday': 'জুমুআ',
    'revelation': 'ওহীর সূচনা',
    'belief': 'ঈমান',
    'faith': 'ঈমান',
    'knowledge': 'ইলম ও জ্ঞান',
    'prayer': 'সালাত',
    'prayers': 'সালাত',
    'the times of prayer': 'সালাতের সময়সমূহ',
    'times of prayer': 'সালাতের সময়সমূহ',
    'fasting': 'সিয়াম ও রোযা',
    'zakat': 'যাকাত',
    'pilgrimage': 'হজ্জ',
    'hajj': 'হজ্জ',
    'marriage': 'বিবাহ',
    'divorce': 'তালাক',
    'inheritance': 'উত্তরাধিকার',
    'funerals': 'জানাযা',
    'charity': 'সদকা',
    'sales': 'ক্রয়-বিক্রয়',
    'vows': 'মানত',
    'oaths': 'শপথ',
    'sacrifices': 'কুরবানী',
    'jihad': 'জিহাদ',
    'judgements': 'বিচার ও ফয়সালা',
    'judgments': 'বিচার ও ফয়সালা',
    'trials': 'ফিতনা ও পরীক্ষা',
    'greetings': 'সালাম',
    'manners': 'আদব ও শিষ্টাচার',
    'dress': 'পোশাক',
    'food': 'খাদ্য',
    'drinks': 'পানীয়',
    'medicine': 'চিকিৎসা',
    'dreams': 'স্বপ্ন',
    'sleeping': 'নিদ্রা',
    'visions': 'স্বপ্ন ও দর্শন',
    'speech': 'কথাবার্তা',
    'purification (kitab al-taharah)': 'পবিত্রতা',
    'the times of prayer (kitab al-mawaqit)': 'সালাতের সময়সমূহ',
    'the book of prayer': 'সালাতের কিতাব',
    'the book of zakat': 'যাকাতের কিতাব',
    'the book of fasting': 'সিয়াম ও রোযার কিতাব',
    'the book of hajj': 'হজ্জের কিতাব',
    'the book of marriage': 'বিবাহের কিতাব',
    'the book of divorce': 'তালাকের কিতাব',
    'the book of sales': 'ক্রয়-বিক্রয়ের কিতাব',
    'the book of vows': 'মানতের কিতাব',
    'the book of oaths': 'শপথের কিতাব',
    'the book of inheritance': 'উত্তরাধিকারের কিতাব',
    'the book of funerals': 'জানাযার কিতাব',
    'the book of charity': 'সদকার কিতাব',
    'the book of sacrifices': 'কুরবানীর কিতাব',
    'time of the jumua prayer': 'জুমুআর সালাতের সময়',
    'the time of the jumua prayer': 'জুমুআর সালাতের সময়',
    'the time of the asr prayer': 'আসর সালাতের সময়',
    'the time of the maghrib prayer': 'মাগরিব সালাতের সময়',
    'the time of the isha prayer': 'ইশা সালাতের সময়',
    'the wudu of a man who has been asleep when he gets up to pray':
        'ঘুম থেকে উঠে সালাত আদায়ের জন্য ব্যক্তির উযূ',
    'how to do wudu': 'কীভাবে উযূ করতে হয়',
    'the ghusl of the two ids, the call to prayer for them, and the iqama':
        'দুই ঈদের গোসল, আযান ও ইকামত',
    'the order to pray before the khutba on the two ids':
        'দুই ঈদের খুতবার আগে সালাত আদায়ের নির্দেশ',
    'actions while praying': 'সালাতের সময়কার কাজ',
    'forgetfulness in prayer': 'সালাতে ভুল-ত্রুটি ও সাহু সিজদা',
    'virtues of prayer at masjid makkah and madinah':
        'মক্কা ও মদিনার মসজিদে সালাতের ফযীলত',
    'obligatory charity tax zakat': 'ফরয যাকাত',
    'beginning of creation': 'সৃষ্টির সূচনা',
    'holding fast to the quran and sunnah': 'কুরআন ও সুন্নাহকে দৃঢ়ভাবে ধারণ',
    'oneness uniqueness of allah tawheed': 'আল্লাহর একত্ব ও তাওহীদ',
  };
}
