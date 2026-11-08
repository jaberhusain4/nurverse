// Centralized offline dataset for the 99 Names of Allah.
// Bengali transliterations and short meanings are the existing in-app content.

class AsmaUlHusnaModel {
  final int id;
  final String arabic;
  final String transliteration;
  final String meaning;

  const AsmaUlHusnaModel({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
  });
}

class AsmaUlHusnaService {
  const AsmaUlHusnaService();

  static const List<AsmaUlHusnaModel> _names = [
    AsmaUlHusnaModel(id: 1, arabic: "الرَّحْمَنُ", transliteration: "আর-রহমান", meaning: "পরম দয়ালু"),
    AsmaUlHusnaModel(id: 2, arabic: "الرَّحِيمُ", transliteration: "আর-রহীম", meaning: "অতি দয়ালু"),
    AsmaUlHusnaModel(id: 3, arabic: "الْمَلِكُ", transliteration: "আল-মালিক", meaning: "সর্বময় অধিপতি"),
    AsmaUlHusnaModel(id: 4, arabic: "الْقُدُّوسُ", transliteration: "আল-কুদ্দুস", meaning: "অতি পবিত্র"),
    AsmaUlHusnaModel(id: 5, arabic: "السَّلَامُ", transliteration: "আস-সালাম", meaning: "শান্তিদাতা"),
    AsmaUlHusnaModel(id: 6, arabic: "الْمُؤْمِنُ", transliteration: "আল-মু’মিন", meaning: "নিরাপত্তাদাতা"),
    AsmaUlHusnaModel(id: 7, arabic: "الْمُهَيْمِنُ", transliteration: "আল-মুহাইমিন", meaning: "রক্ষক"),
    AsmaUlHusnaModel(id: 8, arabic: "الْعَزِيزُ", transliteration: "আল-আযীয", meaning: "মহাপরাক্রমশালী"),
    AsmaUlHusnaModel(id: 9, arabic: "الْجَبَّارُ", transliteration: "আল-জাব্বার", meaning: "পরাক্রমশালী"),
    AsmaUlHusnaModel(id: 10, arabic: "الْمُتَكَبِّرُ", transliteration: "আল-মুতাকাব্বির", meaning: "মহিমান্বিত"),
    AsmaUlHusnaModel(id: 11, arabic: "الْخَالِقُ", transliteration: "আল-খালিক", meaning: "সৃষ্টিকর্তা"),
    AsmaUlHusnaModel(id: 12, arabic: "الْبَارِئُ", transliteration: "আল-বারী", meaning: "সৃষ্টির উদ্ভাবক"),
    AsmaUlHusnaModel(id: 13, arabic: "الْمُصَوِّرُ", transliteration: "আল-মুসাওয়ির", meaning: "আকৃতিদাতা"),
    AsmaUlHusnaModel(id: 14, arabic: "الْغَفَّارُ", transliteration: "আল-গাফ্ফার", meaning: "পরম ক্ষমাশীল"),
    AsmaUlHusnaModel(id: 15, arabic: "الْقَهَّارُ", transliteration: "আল-কাহ্হার", meaning: "প্রবল পরাক্রমশালী"),
    AsmaUlHusnaModel(id: 16, arabic: "الْوَهَّابُ", transliteration: "আল-ওয়াহ্হাব", meaning: "পরম দানশীল"),
    AsmaUlHusnaModel(id: 17, arabic: "الرَّزَّاقُ", transliteration: "আর-রাজ্জাক", meaning: "রিজিকদাতা"),
    AsmaUlHusnaModel(id: 18, arabic: "الْفَتَّاحُ", transliteration: "আল-ফাত্তাহ", meaning: "বিজয়দাতা"),
    AsmaUlHusnaModel(id: 19, arabic: "الْعَلِيمُ", transliteration: "আল-আলীম", meaning: "সর্বজ্ঞ"),
    AsmaUlHusnaModel(id: 20, arabic: "الْقَابِضُ", transliteration: "আল-কাবিদ", meaning: "সংকোচনকারী"),
    AsmaUlHusnaModel(id: 21, arabic: "الْبَاسِطُ", transliteration: "আল-বাসিত", meaning: "প্রশস্তকারী"),
    AsmaUlHusnaModel(id: 22, arabic: "الْخَافِضُ", transliteration: "আল-খাফিদ", meaning: "অবনমিতকারী"),
    AsmaUlHusnaModel(id: 23, arabic: "الرَّافِعُ", transliteration: "আর-রাফি", meaning: "উন্নতকারী"),
    AsmaUlHusnaModel(id: 24, arabic: "الْمُعِزُّ", transliteration: "আল-মু’ইয্য", meaning: "সম্মানদাতা"),
    AsmaUlHusnaModel(id: 25, arabic: "الْمُذِلُّ", transliteration: "আল-মুযিল", meaning: "অপমানকারী"),
    AsmaUlHusnaModel(id: 26, arabic: "السَّمِيعُ", transliteration: "আস-সামী", meaning: "সর্বশ্রোতা"),
    AsmaUlHusnaModel(id: 27, arabic: "الْبَصِيرُ", transliteration: "আল-বাছীর", meaning: "সর্বদ্রষ্টা"),
    AsmaUlHusnaModel(id: 28, arabic: "الْحَكَمُ", transliteration: "আল-হাকাম", meaning: "বিচারক"),
    AsmaUlHusnaModel(id: 29, arabic: "الْعَدْلُ", transliteration: "আল-আদল", meaning: "ন্যায়পরায়ণ"),
    AsmaUlHusnaModel(id: 30, arabic: "اللَّطِيفُ", transliteration: "আল-লাতীফ", meaning: "অতি কোমল ও সূক্ষ্মদর্শী"),
    AsmaUlHusnaModel(id: 31, arabic: "الْخَبِيرُ", transliteration: "আল-খাবীর", meaning: "সর্বজ্ঞাত"),
    AsmaUlHusnaModel(id: 32, arabic: "الْحَلِيمُ", transliteration: "আল-হালীম", meaning: "পরম সহনশীল"),
    AsmaUlHusnaModel(id: 33, arabic: "الْعَظِيمُ", transliteration: "আল-আযীম", meaning: "মহামহিম"),
    AsmaUlHusnaModel(id: 34, arabic: "الْغَفُورُ", transliteration: "আল-গফুর", meaning: "অতি ক্ষমাশীল"),
    AsmaUlHusnaModel(id: 35, arabic: "الشَّكُورُ", transliteration: "আশ-শাকুর", meaning: "গুণগ্রাহী"),
    AsmaUlHusnaModel(id: 36, arabic: "الْعَلِيُّ", transliteration: "আল-আলী", meaning: "সর্বোচ্চ"),
    AsmaUlHusnaModel(id: 37, arabic: "الْكَبِيرُ", transliteration: "আল-কাবীর", meaning: "সুমহান"),
    AsmaUlHusnaModel(id: 38, arabic: "الْحَفِيظُ", transliteration: "আল-হাফীয", meaning: "সংরক্ষণকারী"),
    AsmaUlHusnaModel(id: 39, arabic: "الْمُقِيتُ", transliteration: "আল-মুকীত", meaning: "জীবনোপকরণদাতা"),
    AsmaUlHusnaModel(id: 40, arabic: "الْحَسِيبُ", transliteration: "আল-হাসীব", meaning: "হিসাবগ্রহণকারী"),
    AsmaUlHusnaModel(id: 41, arabic: "الْجَلِيلُ", transliteration: "আল-জালীল", meaning: "মহিমান্বিত"),
    AsmaUlHusnaModel(id: 42, arabic: "الْكَرِيمُ", transliteration: "আল-কারীম", meaning: "মহানুভব"),
    AsmaUlHusnaModel(id: 43, arabic: "الرَّقِيبُ", transliteration: "আর-রকীব", meaning: "পর্যবেক্ষক"),
    AsmaUlHusnaModel(id: 44, arabic: "الْمُجِيبُ", transliteration: "আল-মুজীব", meaning: "সাড়াদানকারী"),
    AsmaUlHusnaModel(id: 45, arabic: "الْوَاسِعُ", transliteration: "আল-ওয়াসি", meaning: "সর্বব্যাপী"),
    AsmaUlHusnaModel(id: 46, arabic: "الْحَكِيمُ", transliteration: "আল-হাকীম", meaning: "প্রজ্ঞাময়"),
    AsmaUlHusnaModel(id: 47, arabic: "الْوَدُودُ", transliteration: "আল-ওয়াদূদ", meaning: "পরম স্নেহশীল"),
    AsmaUlHusnaModel(id: 48, arabic: "الْمَجِيدُ", transliteration: "আল-মাজীদ", meaning: "মহিমান্বিত"),
    AsmaUlHusnaModel(id: 49, arabic: "الْبَاعِثُ", transliteration: "আল-বা’ইস", meaning: "পুনরুত্থানকারী"),
    AsmaUlHusnaModel(id: 50, arabic: "الشَّهِيدُ", transliteration: "আশ-শাহীদ", meaning: "সাক্ষী"),
    AsmaUlHusnaModel(id: 51, arabic: "الْحَقُّ", transliteration: "আল-হাক্ক", meaning: "পরম সত্য"),
    AsmaUlHusnaModel(id: 52, arabic: "الْوَكِيلُ", transliteration: "আল-ওয়াকীল", meaning: "অভিভাবক"),
    AsmaUlHusnaModel(id: 53, arabic: "الْقَوِيُّ", transliteration: "আল-কাওয়ী", meaning: "পরম শক্তিশালী"),
    AsmaUlHusnaModel(id: 54, arabic: "الْمَتِينُ", transliteration: "আল-মাতীন", meaning: "সুদৃঢ়"),
    AsmaUlHusnaModel(id: 55, arabic: "الْوَلِيُّ", transliteration: "আল-ওয়ালিয়্য", meaning: "অভিভাবক ও সাহায্যকারী"),
    AsmaUlHusnaModel(id: 56, arabic: "الْحَمِيدُ", transliteration: "আল-হামীদ", meaning: "সকল প্রশংসার যোগ্য"),
    AsmaUlHusnaModel(id: 57, arabic: "الْمُحْصِي", transliteration: "আল-মুহসী", meaning: "গণনাকারী"),
    AsmaUlHusnaModel(id: 58, arabic: "الْمُبْدِئُ", transliteration: "আল-মুবদি", meaning: "প্রথম সৃষ্টিকারী"),
    AsmaUlHusnaModel(id: 59, arabic: "الْمُعِيدُ", transliteration: "আল-মুঈদ", meaning: "পুনঃসৃষ্টিকারী"),
    AsmaUlHusnaModel(id: 60, arabic: "الْمُحْيِي", transliteration: "আল-মুহয়ী", meaning: "জীবনদানকারী"),
    AsmaUlHusnaModel(id: 61, arabic: "الْمُمِيتُ", transliteration: "আল-মুমীত", meaning: "মৃত্যুদানকারী"),
    AsmaUlHusnaModel(id: 62, arabic: "الْحَيُّ", transliteration: "আল-হাইয়্য", meaning: "চিরঞ্জীব"),
    AsmaUlHusnaModel(id: 63, arabic: "الْقَيُّومُ", transliteration: "আল-কাইয়্যুম", meaning: "স্বয়ংসম্পূর্ণ"),
    AsmaUlHusnaModel(id: 64, arabic: "الْوَاجِدُ", transliteration: "আল-ওয়াজিদ", meaning: "প্রাপ্তকারী"),
    AsmaUlHusnaModel(id: 65, arabic: "الْمَاجِدُ", transliteration: "আল-মাজিদ", meaning: "মহিমান্বিত"),
    AsmaUlHusnaModel(id: 66, arabic: "الْوَاحِدُ", transliteration: "আল-ওয়াহিদ", meaning: "একক"),
    AsmaUlHusnaModel(id: 67, arabic: "الْأَحَدُ", transliteration: "আল-আহাদ", meaning: "অদ্বিতীয়"),
    AsmaUlHusnaModel(id: 68, arabic: "الصَّمَدُ", transliteration: "আস-সামাদ", meaning: "অমুখাপেক্ষী"),
    AsmaUlHusnaModel(id: 69, arabic: "الْقَادِرُ", transliteration: "আল-কাদির", meaning: "সর্বশক্তিমান"),
    AsmaUlHusnaModel(id: 70, arabic: "الْمُقْتَدِرُ", transliteration: "আল-মুকতাদির", meaning: "সর্বময় ক্ষমতার অধিকারী"),
    AsmaUlHusnaModel(id: 71, arabic: "الْمُقَدِّمُ", transliteration: "আল-মুকাদ্দিম", meaning: "অগ্রসরকারী"),
    AsmaUlHusnaModel(id: 72, arabic: "الْمُؤَخِّرُ", transliteration: "আল-মুয়াখখির", meaning: "পিছিয়ে দানকারী"),
    AsmaUlHusnaModel(id: 73, arabic: "الْأَوَّلُ", transliteration: "আল-আউয়াল", meaning: "প্রথম"),
    AsmaUlHusnaModel(id: 74, arabic: "الْآخِرُ", transliteration: "আল-আখির", meaning: "শেষ"),
    AsmaUlHusnaModel(id: 75, arabic: "الظَّاهِرُ", transliteration: "আয-যাহির", meaning: "প্রকাশ্য"),
    AsmaUlHusnaModel(id: 76, arabic: "الْبَاطِنُ", transliteration: "আল-বাতিন", meaning: "অপ্রকাশ্য"),
    AsmaUlHusnaModel(id: 77, arabic: "الْوَالِي", transliteration: "আল-ওয়ালী", meaning: "শাসনকর্তা"),
    AsmaUlHusnaModel(id: 78, arabic: "الْمُتَعَالِي", transliteration: "আল-মুতা’আলী", meaning: "সর্বোচ্চ মর্যাদার অধিকারী"),
    AsmaUlHusnaModel(id: 79, arabic: "الْبَرُّ", transliteration: "আল-বার্", meaning: "পরম কল্যাণময়"),
    AsmaUlHusnaModel(id: 80, arabic: "التَّوَابُ", transliteration: "আত-তাওয়াব", meaning: "তওবা কবুলকারী"),
    AsmaUlHusnaModel(id: 81, arabic: "الْمُنْتَقِمُ", transliteration: "আল-মুনতাকিম", meaning: "প্রতিফলদাতা"),
    AsmaUlHusnaModel(id: 82, arabic: "الْعَفُوُّ", transliteration: "আল-আফুউ", meaning: "পরম ক্ষমাকারী"),
    AsmaUlHusnaModel(id: 83, arabic: "الرَّؤُوفُ", transliteration: "আর-রউফ", meaning: "অতি স্নেহশীল"),
    AsmaUlHusnaModel(id: 84, arabic: "مَالِكُ الْمُلْكِ", transliteration: "মালিকুল মুলক", meaning: "সার্বভৌমত্বের মালিক"),
    AsmaUlHusnaModel(id: 85, arabic: "ذُو الْجَلَالِ وَالْإِكْرَامِ", transliteration: "যুল-জালালি ওয়াল-ইকরাম", meaning: "মহিমা ও সম্মানের অধিকারী"),
    AsmaUlHusnaModel(id: 86, arabic: "الْمُقْسِطُ", transliteration: "আল-মুকসিত", meaning: "ন্যায়বিচারকারী"),
    AsmaUlHusnaModel(id: 87, arabic: "الْجَامِعُ", transliteration: "আল-জামি", meaning: "একত্রকারী"),
    AsmaUlHusnaModel(id: 88, arabic: "الْغَنِيُّ", transliteration: "আল-গানী", meaning: "অমুখাপেক্ষী"),
    AsmaUlHusnaModel(id: 89, arabic: "الْمُغْنِي", transliteration: "আল-মুগনী", meaning: "অভাবমোচনকারী"),
    AsmaUlHusnaModel(id: 90, arabic: "الْمَانِعُ", transliteration: "আল-মানি", meaning: "নিবারণকারী"),
    AsmaUlHusnaModel(id: 91, arabic: "الضَّارُّ", transliteration: "আদ-দার্", meaning: "ক্ষতি সাধনে সক্ষম"),
    AsmaUlHusnaModel(id: 92, arabic: "النَّافِعُ", transliteration: "আন-নাফি", meaning: "উপকারকারী"),
    AsmaUlHusnaModel(id: 93, arabic: "النُّورُ", transliteration: "আন-নূর", meaning: "জ্যোতি"),
    AsmaUlHusnaModel(id: 94, arabic: "الْهَادِي", transliteration: "আল-হাদী", meaning: "পথপ্রদর্শক"),
    AsmaUlHusnaModel(id: 95, arabic: "الْبَدِيعُ", transliteration: "আল-বাদী", meaning: "অনুপম সৃষ্টিকর্তা"),
    AsmaUlHusnaModel(id: 96, arabic: "الْبَاقِي", transliteration: "আল-বাকী", meaning: "চিরস্থায়ী"),
    AsmaUlHusnaModel(id: 97, arabic: "الْوَارِثُ", transliteration: "আল-ওয়ারিস", meaning: "উত্তরাধিকারী"),
    AsmaUlHusnaModel(id: 98, arabic: "الرَّشِيدُ", transliteration: "আর-রশীদ", meaning: "সঠিক পথপ্রদর্শক"),
    AsmaUlHusnaModel(id: 99, arabic: "الصَّبُورُ", transliteration: "আস-সবূর", meaning: "পরম ধৈর্যশীল"),
  ];

  List<AsmaUlHusnaModel> getAll() => _names;

  AsmaUlHusnaModel? byId(int id) {
    if (id < 1 || id > _names.length) return null;
    return _names[id - 1];
  }

  AsmaUlHusnaModel get dailyName {
    final day = DateTime.now().difference(DateTime(2025, 1, 1)).inDays;
    return _names[day % _names.length];
  }

  List<AsmaUlHusnaModel> search(String keyword) {
    final q = keyword.trim().toLowerCase();
    if (q.isEmpty) return _names;
    return _names.where((item) =>
      item.transliteration.toLowerCase().contains(q) ||
      item.meaning.toLowerCase().contains(q) ||
      item.arabic.contains(keyword)
    ).toList(growable: false);
  }
}
