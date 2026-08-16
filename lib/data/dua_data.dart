class DuaItem {
  final String titleBn;
  final String titleEn;
  final String arabic;
  final String translationBn;
  final String translationEn;
  final String reference;
  final String? repeat;

  const DuaItem({
    required this.titleBn,
    required this.titleEn,
    required this.arabic,
    required this.translationBn,
    required this.translationEn,
    required this.reference,
    this.repeat,
  });
}

class DuaCategory {
  final String titleBn;
  final String titleEn;
  final String subtitleBn;
  final String subtitleEn;
  final String iconName;
  final List<DuaItem> items;

  const DuaCategory({
    required this.titleBn,
    required this.titleEn,
    required this.subtitleBn,
    required this.subtitleEn,
    required this.iconName,
    required this.items,
  });
}

const duaCategories = <DuaCategory>[
  DuaCategory(
    titleBn: 'সকাল ও সন্ধ্যার যিকির',
    titleEn: 'Morning & Evening Dhikr',
    subtitleBn: 'দিনের শুরু ও শেষের সহিহ যিকির',
    subtitleEn: 'Authentic remembrance for morning and evening',
    iconName: 'wb_twilight',
    items: [
      DuaItem(
        titleBn: 'আল্লাহর নামে নিরাপত্তার যিকির',
        titleEn: 'Protection with Allah’s Name',
        arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
        translationBn: 'আল্লাহর নামে, যাঁর নামের সঙ্গে পৃথিবী ও আকাশে কোনো কিছুই ক্ষতি করতে পারে না। তিনি সর্বশ্রোতা, সর্বজ্ঞ।',
        translationEn: 'In the name of Allah, with whose name nothing can cause harm on earth or in heaven. He is the All-Hearing, All-Knowing.',
        reference: 'Hisn al-Muslim 86; Abu Dawud, Tirmidhi',
        repeat: '৩ বার',
      ),
      DuaItem(
        titleBn: 'সকাল-সন্ধ্যার শ্রেষ্ঠ ইস্তিগফার',
        titleEn: 'Sayyid al-Istighfar',
        arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
        translationBn: 'হে আল্লাহ! আপনি আমার রব। আপনি ছাড়া কোনো উপাস্য নেই। আপনি আমাকে সৃষ্টি করেছেন এবং আমি আপনার বান্দা। আমি আপনার অঙ্গীকার ও প্রতিশ্রুতির ওপর যথাসাধ্য অটল আছি। আমি আমার কৃতকর্মের অনিষ্ট থেকে আপনার আশ্রয় চাই। আমার প্রতি আপনার নিয়ামত স্বীকার করছি এবং আমার গুনাহ স্বীকার করছি। অতএব আমাকে ক্ষমা করুন; আপনি ছাড়া কেউ গুনাহ ক্ষমা করতে পারে না।',
        translationEn: 'O Allah, You are my Lord. There is no deity except You. You created me and I am Your servant. I acknowledge Your blessings and my sins, so forgive me; none forgives sins except You.',
        reference: 'Sahih al-Bukhari 6306',
        repeat: 'সকাল ও সন্ধ্যায়',
      ),
      DuaItem(
        titleBn: 'সকাল-সন্ধ্যায় তিন কুল',
        titleEn: 'The Three Quls',
        arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ • قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ • قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
        translationBn: 'সূরা ইখলাস, সূরা ফালাক ও সূরা নাস পড়ুন। এগুলো সকাল ও সন্ধ্যায় তিনবার পড়ার নির্দেশ এসেছে।',
        translationEn: 'Recite Surah Al-Ikhlas, Al-Falaq and An-Nas three times at dawn and dusk.',
        reference: 'Riyad as-Salihin 1456; Abu Dawud, Tirmidhi',
        repeat: 'প্রতিটি ৩ বার',
      ),
    ],
  ),
  DuaCategory(
    titleBn: 'নামাজ ও অজু',
    titleEn: 'Prayer & Wudu',
    subtitleBn: 'নামাজ ও পবিত্রতার গুরুত্বপূর্ণ যিকির',
    subtitleEn: 'Essential supplications for prayer and purification',
    iconName: 'mosque_outlined',
    items: [
      DuaItem(
        titleBn: 'অজুর পরের সাক্ষ্য',
        titleEn: 'After Wudu',
        arabic: 'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
        translationBn: 'আমি সাক্ষ্য দিচ্ছি, আল্লাহ ছাড়া কোনো উপাস্য নেই; তিনি এক, তাঁর কোনো শরিক নেই। আমি আরও সাক্ষ্য দিচ্ছি, মুহাম্মদ তাঁর বান্দা ও রাসূল।',
        translationEn: 'I testify that there is no deity except Allah, alone without partner, and that Muhammad is His servant and Messenger.',
        reference: 'Sahih Muslim 234a',
      ),
      DuaItem(
        titleBn: 'নামাজের পরের দোয়া',
        titleEn: 'After Every Prescribed Prayer',
        arabic: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
        translationBn: 'হে আল্লাহ! আপনার যিকির, আপনার শুকরিয়া এবং সুন্দরভাবে আপনার ইবাদত করতে আমাকে সাহায্য করুন।',
        translationEn: 'O Allah, help me remember You, thank You and worship You well.',
        reference: 'Sunan Abi Dawud 1522',
      ),
      DuaItem(
        titleBn: 'নামাজে হিদায়াত ও ক্ষমার দোয়া',
        titleEn: 'Supplication for Guidance and Forgiveness',
        arabic: 'اللَّهُمَّ اغْفِرْ لِي وَارْحَمْنِي وَاهْدِنِي وَعَافِنِي وَارْزُقْنِي',
        translationBn: 'হে আল্লাহ! আমাকে ক্ষমা করুন, আমার প্রতি দয়া করুন, আমাকে হিদায়াত দিন, আমাকে নিরাপদ ও সুস্থ রাখুন এবং আমাকে রিজিক দিন।',
        translationEn: 'O Allah, forgive me, have mercy on me, guide me, grant me well-being and provide for me.',
        reference: 'Sahih Muslim 2697',
      ),
    ],
  ),
  DuaCategory(
    titleBn: 'দৈনন্দিন জীবন',
    titleEn: 'Daily Life',
    subtitleBn: 'প্রতিদিনের কাজের সময় পড়ার সহিহ দোয়া',
    subtitleEn: 'Authentic supplications for everyday moments',
    iconName: 'wb_sunny_outlined',
    items: [
      DuaItem(
        titleBn: 'খাবার শুরু করার সময়',
        titleEn: 'Before Eating',
        arabic: 'بِسْمِ اللَّهِ',
        translationBn: 'আল্লাহর নামে শুরু করছি।',
        translationEn: 'In the name of Allah.',
        reference: 'Sunan Abi Dawud 3767',
      ),
      DuaItem(
        titleBn: 'টয়লেটে প্রবেশের সময়',
        titleEn: 'Before Entering the Toilet',
        arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
        translationBn: 'হে আল্লাহ! আমি অপবিত্র পুরুষ ও নারী শয়তান থেকে আপনার আশ্রয় চাই।',
        translationEn: 'O Allah, I seek refuge in You from the male and female devils.',
        reference: 'Sahih al-Bukhari 142',
      ),
      DuaItem(
        titleBn: 'টয়লেট থেকে বের হওয়ার পর',
        titleEn: 'After Leaving the Toilet',
        arabic: 'غُفْرَانَكَ',
        translationBn: 'হে আল্লাহ! আমি আপনার ক্ষমা প্রার্থনা করছি।',
        translationEn: 'I seek Your forgiveness, O Allah.',
        reference: 'Sunan Abi Dawud 30; Jami at-Tirmidhi 7',
      ),
      DuaItem(
        titleBn: 'খাবার ভুলে বিসমিল্লাহ না বললে',
        titleEn: 'If You Forgot Bismillah',
        arabic: 'بِسْمِ اللَّهِ أَوَّلَهُ وَآخِرَهُ',
        translationBn: 'শুরু ও শেষে আল্লাহর নামে।',
        translationEn: 'In the name of Allah at its beginning and at its end.',
        reference: 'Sunan Abi Dawud 3767',
      ),
    ],
  ),
  DuaCategory(
    titleBn: 'বিপদ ও দুশ্চিন্তা',
    titleEn: 'Hardship & Anxiety',
    subtitleBn: 'দুঃখ, ভয় ও কঠিন সময়ে পড়ার দোয়া',
    subtitleEn: 'Supplications for distress, fear and hardship',
    iconName: 'sentiment_dissatisfied_outlined',
    items: [
      DuaItem(
        titleBn: 'ইউনুস (আ.)-এর দোয়া',
        titleEn: 'Dua of Yunus',
        arabic: 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
        translationBn: 'আপনি ছাড়া কোনো উপাস্য নেই। আপনি পবিত্র। নিশ্চয়ই আমি জালিমদের অন্তর্ভুক্ত ছিলাম।',
        translationEn: 'There is no deity except You. Glory be to You. Indeed, I have been among the wrongdoers.',
        reference: 'Quran 21:87',
      ),
      DuaItem(
        titleBn: 'দুনিয়া ও আখিরাতের কল্যাণ',
        titleEn: 'Good in This World and the Hereafter',
        arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
        translationBn: 'হে আমাদের রব! আমাদের দুনিয়ায় কল্যাণ দিন, আখিরাতেও কল্যাণ দিন এবং আমাদের আগুনের শাস্তি থেকে রক্ষা করুন।',
        translationEn: 'Our Lord, give us good in this world and good in the Hereafter and protect us from the punishment of the Fire.',
        reference: 'Quran 2:201',
      ),
      DuaItem(
        titleBn: 'হৃদয়কে দ্বীনের ওপর অটল রাখা',
        titleEn: 'Keeping the Heart Firm',
        arabic: 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ',
        translationBn: 'হে আমাদের রব! হিদায়াত দেওয়ার পর আমাদের অন্তর বক্র করে দেবেন না এবং আপনার পক্ষ থেকে আমাদের রহমত দান করুন। নিশ্চয়ই আপনি মহাদাতা।',
        translationEn: 'Our Lord, do not let our hearts deviate after You have guided us, and grant us mercy from You. You are the Bestower.',
        reference: 'Quran 3:8',
      ),
    ],
  ),
  DuaCategory(
    titleBn: 'খাওয়া ও পোশাক',
    titleEn: 'Food & Clothing',
    subtitleBn: 'খাবার, পানীয় ও পোশাকের সময়ের দোয়া',
    subtitleEn: 'Supplications for food, drink and clothing',
    iconName: 'restaurant_outlined',
    items: [
      DuaItem(
        titleBn: 'খাবার শেষে',
        titleEn: 'After Eating',
        arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
        translationBn: 'সমস্ত প্রশংসা আল্লাহর, যিনি আমাকে এই খাবার খাইয়েছেন এবং আমার কোনো শক্তি ও সামর্থ্য ছাড়াই আমাকে তা রিজিক হিসেবে দিয়েছেন।',
        translationEn: 'Praise is for Allah who fed me this and provided it for me without any power or strength from me.',
        reference: 'Sunan Abi Dawud 4023; Jami at-Tirmidhi 3458',
      ),
      DuaItem(
        titleBn: 'নতুন পোশাক পরলে',
        titleEn: 'When Wearing New Clothes',
        arabic: 'اللَّهُمَّ لَكَ الْحَمْدُ أَنْتَ كَسَوْتَنِيهِ أَسْأَلُكَ خَيْرَهُ وَخَيْرَ مَا صُنِعَ لَهُ وَأَعُوذُ بِكَ مِنْ شَرِّهِ وَشَرِّ مَا صُنِعَ لَهُ',
        translationBn: 'হে আল্লাহ! সব প্রশংসা আপনার। আপনিই আমাকে এটি পরিয়েছেন। আমি এর কল্যাণ ও যে উদ্দেশ্যে এটি তৈরি হয়েছে তার কল্যাণ চাই; এবং এর অকল্যাণ ও যে উদ্দেশ্যে এটি তৈরি হয়েছে তার অকল্যাণ থেকে আপনার আশ্রয় চাই।',
        translationEn: 'O Allah, praise belongs to You. You have clothed me with it. I ask You for its good and the good for which it was made, and seek refuge from its evil and the evil for which it was made.',
        reference: 'Sunan Abi Dawud 4020; Jami at-Tirmidhi 1767',
      ),
      DuaItem(
        titleBn: 'পোশাক খুললে',
        titleEn: 'When Removing Clothes',
        arabic: 'بِسْمِ اللَّهِ',
        translationBn: 'আল্লাহর নামে।',
        translationEn: 'In the name of Allah.',
        reference: 'Sunan Abi Dawud 4017; Jami at-Tirmidhi 606',
      ),
    ],
  ),
  DuaCategory(
    titleBn: 'সফর ও বাহন',
    titleEn: 'Travel & Transportation',
    subtitleBn: 'যাত্রা শুরু ও বাহনে ওঠার দোয়া',
    subtitleEn: 'Supplications for travel and riding',
    iconName: 'directions_bus_outlined',
    items: [
      DuaItem(
        titleBn: 'বাহনে ওঠার সময়',
        titleEn: 'When Riding',
        arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
        translationBn: 'পবিত্র তিনি, যিনি এটিকে আমাদের অনুগত করে দিয়েছেন; আমরা নিজেরা এটি নিয়ন্ত্রণ করতে সক্ষম ছিলাম না। আর নিশ্চয়ই আমরা আমাদের রবের কাছেই ফিরে যাব।',
        translationEn: 'Glory is to Him who has subjected this to us, and we could not have controlled it ourselves. Surely to our Lord we will return.',
        reference: 'Quran 43:13–14',
      ),
      DuaItem(
        titleBn: 'সফরের দোয়া',
        titleEn: 'Travel Supplication',
        arabic: 'اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى وَمِنَ الْعَمَلِ مَا تَرْضَى',
        translationBn: 'হে আল্লাহ! আমরা এই সফরে আপনার কাছে নেকি, তাকওয়া এবং এমন আমল চাই যা আপনি পছন্দ করেন।',
        translationEn: 'O Allah, we ask You in this journey for righteousness, piety and deeds that please You.',
        reference: 'Sahih Muslim 1342',
      ),
      DuaItem(
        titleBn: 'সফর থেকে ফিরে',
        titleEn: 'Returning from Travel',
        arabic: 'آيِبُونَ تَائِبُونَ عَابِدُونَ لِرَبِّنَا حَامِدُونَ',
        translationBn: 'আমরা প্রত্যাবর্তনকারী, তওবাকারী, ইবাদতকারী এবং আমাদের রবের প্রশংসাকারী।',
        translationEn: 'We return, repent, worship and praise our Lord.',
        reference: 'Sahih Muslim 1342',
      ),
    ],
  ),
  DuaCategory(
    titleBn: 'ক্ষমা ও তওবা',
    titleEn: 'Forgiveness & Tawbah',
    subtitleBn: 'গুনাহ থেকে ফিরে ক্ষমা চাওয়ার দোয়া',
    subtitleEn: 'Supplications for repentance and forgiveness',
    iconName: 'favorite_border_rounded',
    items: [
      DuaItem(
        titleBn: 'ক্ষমা ও রহমতের দোয়া',
        titleEn: 'Forgiveness and Mercy',
        arabic: 'رَبِّ اغْفِرْ وَارْحَمْ وَأَنْتَ خَيْرُ الرَّاحِمِينَ',
        translationBn: 'হে আমার রব! ক্ষমা করুন ও দয়া করুন; আপনিই সর্বশ্রেষ্ঠ দয়ালু।',
        translationEn: 'My Lord, forgive and have mercy; You are the best of those who show mercy.',
        reference: 'Quran 23:118',
      ),
      DuaItem(
        titleBn: 'আদম (আ.)-এর তওবার দোয়া',
        titleEn: 'Dua of Adam',
        arabic: 'رَبَّنَا ظَلَمْنَا أَنْفُسَنَا وَإِنْ لَمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
        translationBn: 'হে আমাদের রব! আমরা নিজেদের ওপর জুলুম করেছি। আপনি যদি আমাদের ক্ষমা না করেন ও দয়া না করেন, তবে আমরা অবশ্যই ক্ষতিগ্রস্তদের অন্তর্ভুক্ত হব।',
        translationEn: 'Our Lord, we have wronged ourselves. If You do not forgive us and have mercy on us, we will surely be among the losers.',
        reference: 'Quran 7:23',
      ),
      DuaItem(
        titleBn: 'জ্ঞান বৃদ্ধির দোয়া',
        titleEn: 'Increase in Knowledge',
        arabic: 'رَبِّ زِدْنِي عِلْمًا',
        translationBn: 'হে আমার রব! আমার জ্ঞান বৃদ্ধি করুন।',
        translationEn: 'My Lord, increase me in knowledge.',
        reference: 'Quran 20:114',
      ),
    ],
  ),
];
