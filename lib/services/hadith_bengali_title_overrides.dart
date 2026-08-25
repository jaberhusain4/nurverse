class HadithBengaliTitleOverrides {
  const HadithBengaliTitleOverrides._();

  static String? resolve(String english) {
    final key = english.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    return _titles[key];
  }

  static const Map<String, String> _titles = {
    'purity': 'পবিত্রতা',
    'times of prayer': 'সালাতের সময়সমূহ',
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
  };
}
