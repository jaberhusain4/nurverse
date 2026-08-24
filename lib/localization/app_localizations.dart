import 'package:flutter/material.dart';
import 'arabic_strings.dart';

class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);
  static const supportedLocales = [Locale('bn'), Locale('en'), Locale('ar')];
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (result == null) throw FlutterError('AppLocalizations could not be found in the widget tree.');
    return result;
  }

  bool get isBangla => locale.languageCode == 'bn';
  bool get isArabic => locale.languageCode == 'ar';
  String _text(String bn, String en) => isArabic ? (kArabicStrings[en] ?? en) : (isBangla ? bn : en);
  String tr(String bn, String en) => _text(bn, en);

  String get appName => 'NurVerse';
  String get home => _text('হোম', 'Home');
  String get prayer => _text('সালাত', 'Prayer');
  String get quran => _text('কুরআন', 'Quran');
  String get hadith => _text('হাদিস', 'Hadith');
  String get tools => _text('টুলস', 'Tools');
  String get more => _text('আরও', 'More');
  String get refresh => _text('রিফ্রেশ', 'Refresh');
  String get refreshTooltip => _text('সালাতের সময় আপডেট করুন', 'Refresh prayer times');
  String get retry => _text('পুনরায় চেষ্টা করুন', 'Try Again');
  String get cancel => _text('বাতিল', 'Cancel');
  String get save => _text('সংরক্ষণ করুন', 'Save');
  String get close => _text('বন্ধ করুন', 'Close');
  String get done => _text('সম্পন্ন', 'Done');
  String get search => _text('অনুসন্ধান', 'Search');
  String get settings => _text('সেটিংস', 'Settings');
  String get currentPrayer => _text('বর্তমান সালাত', 'Current Prayer');
  String get nextPrayer => _text('পরবর্তী সালাত', 'Next Prayer');
  String get prayerTime => _text('সালাতের সময়', 'Prayer Time');
  String get today => _text('আজ', 'Today');
  String get sunrise => _text('সূর্যোদয়', 'Sunrise');
  String get sunset => _text('সূর্যাস্ত', 'Sunset');
  String get location => _text('বর্তমান অবস্থান', 'Current Location');
  String get todaysPrayer => _text('আজকের সালাত', 'Today’s Prayer');
  String get fullPrayerSchedule => _text('প্রতিটি ওয়াক্তের পূর্ণ সময়সূচি', 'Complete prayer schedule');
  String get prayerTimes => _text('সালাতের সময়', 'Prayer Times');
  String get previousPrayer => _text('বিগত সালাত', 'Previous Prayer');
  String get current => _text('বর্তমান', 'Current');
  String get next => _text('পরবর্তী', 'Next');
  String get completed => _text('সম্পন্ন', 'Completed');
  String get noPrayerWindow => _text('ওয়াক্ত নেই', 'No prayer window');
  String get start => _text('শুরু', 'Start');
  String get end => _text('শেষ', 'End');
  String get jamaat => _text('জামাআত', 'Jama’ah');
  String get friday => _text('শুক্রবার', 'Friday');
  String get fridayLabel => friday;
  String get importantTimes => _text('আজকের গুরুত্বপূর্ণ সময়', 'Important Times Today');
  String get solarNoon => _text('যাওয়াল', 'Solar Noon');
  String get makruhTime => _text('মাকরূহ সময়', 'Makruh Time');
  String get prohibitedTime => _text('নিষিদ্ধ সময়', 'Prohibited Time');
  String get naflAndOtherPrayers => _text('নফল ও অন্যান্য সালাত', 'Nafl & Other Prayers');
  String get optionalWorshipTimes => _text('ঐচ্ছিক ইবাদতের গুরুত্বপূর্ণ সময়', 'Important times for optional worship');
  String get ishraq => _text('ইশরাক', 'Ishraq');
  String get duha => _text('চাশত / দুহা', 'Duha');
  String get awwabin => _text('আউওয়াবীন', 'Awwabin');
  String get tahajjud => _text('তাহাজ্জুদ', 'Tahajjud');
  String get prayerTracker => _text('আজকের সালাত ট্র্যাকার', 'Prayer Tracker');
  String get trackerTitle => prayerTracker;
  String get markPrayers => _text('পড়া সালাতগুলো চিহ্নিত করুন', 'Mark the prayers you have performed');
  String get trackerSubtitle => markPrayers;
  String get prayerLoadError => _text('সালাতের তথ্য লোড করা যায়নি', 'Could not load prayer information');
  String get prayerTimeNote => _text('সালাতের সময় স্থান, তারিখ ও হিসাব পদ্ধতির উপর নির্ভর করে পরিবর্তিত হতে পারে।', 'Prayer times may vary depending on location, date, and calculation method.');
  String get fajr => _text('ফজর', 'Fajr');
  String get dhuhr => _text('যোহর', 'Dhuhr');
  String get asr => _text('আসর', 'Asr');
  String get maghrib => _text('মাগরিব', 'Maghrib');
  String get isha => _text('ইশা', 'Isha');
  String get jumuah => _text('জুমু‘আ', 'Jumu’ah');

  String prayerName(String name) {
    switch (name.trim().toLowerCase()) {
      case 'fajr': case 'ফজর': return fajr;
      case 'dhuhr': case 'যোহর': return dhuhr;
      case 'asr': case 'আসর': return asr;
      case 'maghrib': case 'মাগরিব': return maghrib;
      case 'isha': case 'ইশা': return isha;
      case 'jumuah': case 'জুমু‘আ': case 'জুমুআ': return jumuah;
      case 'ishraq': case 'ইশরাক': return ishraq;
      case 'duha': case 'চাশত': case 'দুহা': return duha;
      case 'awwabin': case 'আউওয়াবীন': return awwabin;
      case 'tahajjud': case 'তাহাজ্জুদ': return tahajjud;
      default: return name;
    }
  }

  String get qibla => _text('কিবলা', 'Qibla');
  String get tasbih => _text('তাসবিহ', 'Tasbih');
  String get asmaUlHusna => _text('আসমাউল হুসনা', 'Asma ul Husna');
  String get ruqyah => _text('রুকইয়াহ', 'Ruqyah');
  String get zakatCalculator => _text('যাকাত ক্যালকুলেটর', 'Zakat Calculator');
  String get islamicCalendar => _text('ইসলামিক ক্যালেন্ডার', 'Islamic Calendar');
  String get nearbyMosque => _text('কাছের মসজিদ', 'Nearby Mosque');
  String get islamicBooks => _text('ইসলামিক বই', 'Islamic Books');
  String get dailyAyah => _text('আজকের আয়াত', 'Ayah of the Day');
  String get dailyHadith => _text('আজকের হাদিস', 'Hadith of the Day');
  String get dailyDua => _text('আজকের দোয়া', 'Dua of the Day');
  String get continueReading => _text('কুরআন পড়া চালিয়ে যান', 'Continue Reading');
  String get lastRead => _text('সর্বশেষ পড়া', 'Last Read');
  String get seeAll => _text('সব দেখুন', 'See All');
  String get language => _text('ভাষা', 'Language');
  String get theme => _text('থিম', 'Theme');
  String get lightTheme => _text('লাইট', 'Light');
  String get darkTheme => _text('ডার্ক', 'Dark');
  String get amoledTheme => 'AMOLED';
  String get systemTheme => _text('সিস্টেম', 'System');
  String get bangla => _text('বাংলা', 'Bangla');
  String get english => _text('ইংরেজি', 'English');
  String get arabic => isArabic ? 'العربية' : (isBangla ? 'আরবি' : 'Arabic');
  String get locationUnavailable => _text('অবস্থান পাওয়া যায়নি', 'Location unavailable');
  String get noData => _text('কোনো তথ্য পাওয়া যায়নি', 'No data available');
  String get somethingWentWrong => _text('কিছু একটা সমস্যা হয়েছে', 'Something went wrong');
  String get loading => _text('লোড হচ্ছে...', 'Loading...');

  String get islamicTools => _text('ইসলামিক টুলস', 'Islamic Tools');
  String get worshipAndPractice => _text('ইবাদত ও আমল', 'Worship & Practice');
  String get dailyWorshipTools => _text('দৈনন্দিন ইবাদতের প্রয়োজনীয় সরঞ্জাম', 'Essential tools for daily worship');
  String get dua => _text("দু'আ", 'Dua');
  String get duaSubtitle => _text('দু‘আ ও মুনাজাত', 'Dua and supplication');
  String get tasbihSubtitle => _text('যিকির গণনা ও আমল', 'Dhikr counting and practice');
  String get ruqyahSubtitle => _text('কুরআন ও সহিহ দু‘আ', 'Quran and authentic duas');
  String get names99 => _text('আল্লাহর ৯৯ নাম', '99 Names of Allah');
  String get quranAndHadith => _text('কুরআন ও হাদিস', 'Quran & Hadith');
  String get readingAudioSavedKnowledge => _text('পাঠ, শ্রবণ ও সংরক্ষিত জ্ঞান', 'Reading, audio and saved knowledge');
  String get audioQuran => _text('অডিও কুরআন', 'Audio Quran');
  String get audioQuranSubtitle => _text('কুরআন তিলাওয়াত শুনুন', 'Listen to Quran recitation');
  String get savedHadith => _text('সংরক্ষিত হাদিস', 'Saved Hadith');
  String get savedHadithSubtitle => _text('আপনার পছন্দের হাদিস', 'Your favorite hadith');
  String get islamicBooksSubtitle => _text('অনলাইন জ্ঞানভাণ্ডার', 'Islamic knowledge library');
  String get timeAndDirection => _text('সময় ও দিকনির্দেশনা', 'Time & Direction');
  String get islamicTimeDateQibla => _text('ইসলামিক সময়, তারিখ ও কিবলা', 'Islamic time, date and Qibla');
  String get qiblaSubtitle => _text('কাবার দিক নির্ণয়', 'Find the direction of the Kaaba');
  String get calendar => _text('ক্যালেন্ডার', 'Calendar');
  String get calendarSubtitle => _text('হিজরি ও ইসলামিক তারিখ', 'Hijri and Islamic dates');
  String get islamicCalculations => _text('ইসলামিক হিসাব', 'Islamic Calculations');
  String get financialWorshipCalculations => _text('আর্থিক ইবাদতের প্রয়োজনীয় হিসাব', 'Essential calculations for financial worship');
  String get zakatCalculatorSubtitle => _text('যাকাতের হিসাব করুন', 'Calculate your Zakat');
  String get toolsHeroTitle => _text('আপনার ইসলামিক টুলস', 'Your Islamic Tools');
  String get toolsHeroSubtitle => _text('ইবাদত, জ্ঞান ও দৈনন্দিন প্রয়োজন—সব এক জায়গায়।', 'Worship, knowledge and daily needs—all in one place.');
  String get alQuran => _text('আল-কুরআন', 'Al-Quran');
  String get quranSubtitle => _text('হাফেজি পাঠ, অনুধাবন এবং তিলাওয়াত — তিনটি আলাদা অভিজ্ঞতা।', 'Hifzi reading, understanding and recitation — three distinct experiences.');
  String get hafeziQuran => _text('হাফেজি কুরআন', 'Hafezi Quran');
  String get hafeziSubtitle => _text('১৫ লাইনের অফলাইন হাফেজি কুরআন', '15-line offline Hifzi Quran');
  String get fifteenLinesOffline => _text('১৫ লাইন • অফলাইন', '15 lines • Offline');
  String get onudhabonQuran => _text('অনুধাবন কুরআন', 'Onudhabon Quran');
  String get onudhabonSubtitle => _text('আরবি আয়াত, বাংলা অনুবাদ ও তাফসির', 'Arabic verses, Bangla translation and Tafsir');
  String get translationTafsir => _text('অনুবাদ • তাফসির', 'Translation • Tafsir');
  String get audioQuranMode => _text('অডিও কুরআন', 'Audio Quran');
  String get audioQuranModeSubtitle => _text('তিলাওয়াত শুনুন ও অফলাইনে ক্যাশ করুন', 'Listen and cache recitation offline');
  String get audioOfflineCache => _text('অফলাইন ক্যাশ', 'Offline cache');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override bool isSupported(Locale locale) => ['bn', 'en', 'ar'].contains(locale.languageCode);
  @override Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);
  @override bool shouldReload(_AppLocalizationsDelegate old) => false;
}
