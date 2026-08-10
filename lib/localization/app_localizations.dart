import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const supportedLocales = [Locale('bn'), Locale('en')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );

    if (result == null) {
      throw FlutterError(
        'AppLocalizations could not be found in the widget tree.',
      );
    }

    return result;
  }

  bool get isBangla => locale.languageCode == 'bn';

  String _text(String bn, String en) {
    return isBangla ? bn : en;
  }

  // ===========================================================================
  // APP
  // ===========================================================================

  String get appName => 'NurVerse';

  String get home => _text('হোম', 'Home');
  String get prayer => _text('সালাত', 'Prayer');
  String get quran => _text('কুরআন', 'Quran');
  String get hadith => _text('হাদিস', 'Hadith');
  String get tools => _text('টুলস', 'Tools');
  String get more => _text('আরও', 'More');

  // ===========================================================================
  // COMMON
  // ===========================================================================

  String get refresh => _text('রিফ্রেশ', 'Refresh');
  String get retry => _text('পুনরায় চেষ্টা করুন', 'Try Again');
  String get cancel => _text('বাতিল', 'Cancel');
  String get save => _text('সংরক্ষণ করুন', 'Save');
  String get close => _text('বন্ধ করুন', 'Close');
  String get done => _text('সম্পন্ন', 'Done');
  String get search => _text('অনুসন্ধান', 'Search');
  String get settings => _text('সেটিংস', 'Settings');

  // ===========================================================================
  // HOME
  // ===========================================================================

  String get welcome => _text('আসসালামু আলাইকুম', 'Assalamu Alaikum');

  String get currentPrayer => _text('বর্তমান সালাত', 'Current Prayer');

  String get nextPrayer => _text('পরবর্তী সালাত', 'Next Prayer');

  String get prayerTime => _text('সালাতের সময়', 'Prayer Time');

  String get today => _text('আজ', 'Today');

  String get sunrise => _text('সূর্যোদয়', 'Sunrise');

  String get sunset => _text('সূর্যাস্ত', 'Sunset');

  String get location => _text('বর্তমান অবস্থান', 'Current Location');

  // ===========================================================================
  // PRAYER
  // ===========================================================================

  String get todaysPrayer => _text('আজকের সালাত', 'Today’s Prayer');

  String get fullPrayerSchedule =>
      _text('প্রতিটি ওয়াক্তের পূর্ণ সময়সূচি', 'Complete prayer schedule');

  String get prayerTimes => _text('সালাতের সময়', 'Prayer Times');

  String get previousPrayer => _text('বিগত সালাত', 'Previous Prayer');

  String get current => _text('বর্তমান', 'Current');

  String get next => _text('পরবর্তী', 'Next');

  String get start => _text('শুরু', 'Start');

  String get end => _text('শেষ', 'End');

  String get jamaat => _text('জামাআত', 'Jama’ah');

  String get currentLabel => _text('বর্তমান', 'Current');

  String get friday => _text('শুক্রবার', 'Friday');

  String get importantTimes =>
      _text('আজকের গুরুত্বপূর্ণ সময়', 'Important Times Today');

  String get solarNoon => _text('যাওয়াল', 'Solar Noon');

  String get makruhTime => _text('মাকরূহ সময়', 'Makruh Time');

  String get prohibitedTime => _text('নিষিদ্ধ সময়', 'Prohibited Time');

  String get naflAndOtherPrayers =>
      _text('নফল ও অন্যান্য সালাত', 'Nafl & Other Prayers');

  String get optionalWorshipTimes => _text(
    'ঐচ্ছিক ইবাদতের গুরুত্বপূর্ণ সময়',
    'Important times for optional worship',
  );

  String get ishraq => _text('ইশরাক', 'Ishraq');

  String get duha => _text('চাশত / দুহা', 'Duha');

  String get awwabin => _text('আউওয়াবীন', 'Awwabin');

  String get tahajjud => _text('তাহাজ্জুদ', 'Tahajjud');

  String get prayerTracker => _text('আজকের সালাত ট্র্যাকার', 'Prayer Tracker');

  String get markPrayers => _text(
    'পড়া সালাতগুলো চিহ্নিত করুন',
    'Mark the prayers you have performed',
  );

  String get prayerLoadError =>
      _text('সালাতের তথ্য লোড করা যায়নি', 'Could not load prayer information');

  String get prayerTimeNote => _text(
    'সালাতের সময় স্থান, তারিখ ও হিসাব পদ্ধতির উপর নির্ভর করে পরিবর্তিত হতে পারে।',
    'Prayer times may vary depending on location, date, and calculation method.',
  );

  // ===========================================================================
  // FIVE DAILY PRAYERS
  // ===========================================================================

  String get fajr => _text('ফজর', 'Fajr');
  String get dhuhr => _text('যোহর', 'Dhuhr');
  String get asr => _text('আসর', 'Asr');
  String get maghrib => _text('মাগরিব', 'Maghrib');
  String get isha => _text('ইশা', 'Isha');
  String get jumuah => _text('জুমু‘আ', 'Jumu’ah');

  // ===========================================================================
  // TOOLS
  // ===========================================================================

  String get qibla => _text('কিবলা', 'Qibla');

  String get tasbih => _text('তাসবিহ', 'Tasbih');

  String get asmaUlHusna => _text('আসমাউল হুসনা', 'Asma ul Husna');

  String get manzil => _text('মানযিল', 'Manzil');

  String get ruqyah => _text('রুকইয়াহ', 'Ruqyah');

  String get zakatCalculator => _text('যাকাত ক্যালকুলেটর', 'Zakat Calculator');

  String get islamicCalendar =>
      _text('ইসলামিক ক্যালেন্ডার', 'Islamic Calendar');

  String get nearbyMosque => _text('কাছের মসজিদ', 'Nearby Mosque');

  String get islamicBooks => _text('ইসলামিক বই', 'Islamic Books');

  // ===========================================================================
  // CONTENT
  // ===========================================================================

  String get dailyAyah => _text('আজকের আয়াত', 'Ayah of the Day');

  String get dailyHadith => _text('আজকের হাদিস', 'Hadith of the Day');

  String get dailyDua => _text('আজকের দোয়া', 'Dua of the Day');

  String get continueReading =>
      _text('কুরআন পড়া চালিয়ে যান', 'Continue Reading');

  String get lastRead => _text('সর্বশেষ পড়া', 'Last Read');

  String get seeAll => _text('সব দেখুন', 'See All');

  // ===========================================================================
  // SETTINGS
  // ===========================================================================

  String get language => _text('ভাষা', 'Language');

  String get theme => _text('থিম', 'Theme');

  String get lightTheme => _text('লাইট', 'Light');

  String get darkTheme => _text('ডার্ক', 'Dark');

  String get amoledTheme => _text('AMOLED', 'AMOLED');

  String get systemTheme => _text('সিস্টেম', 'System');

  String get bangla => _text('বাংলা', 'Bangla');

  String get english => _text('ইংরেজি', 'English');

  // ===========================================================================
  // MESSAGES
  // ===========================================================================

  String get locationUnavailable =>
      _text('অবস্থান পাওয়া যায়নি', 'Location unavailable');

  String get noData => _text('কোনো তথ্য পাওয়া যায়নি', 'No data available');

  String get somethingWentWrong =>
      _text('কিছু একটা সমস্যা হয়েছে', 'Something went wrong');

  String get loading => _text('লোড হচ্ছে...', 'Loading...');

  // ===========================================================================
  // DYNAMIC TEXT
  // ===========================================================================

  String prayerStartsAt(String time) {
    return _text('শুরু হবে $time', 'Starts at $time');
  }

  String prayerEndsAt(String time) {
    return _text('শেষ হবে $time', 'Ends at $time');
  }

  String nextPrayerAt(String name, String time) {
    return _text('পরবর্তী: $name • $time', 'Next: $name • $time');
  }

  String remaining(String value) {
    return _text('$value বাকি', '$value remaining');
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'bn' || locale.languageCode == 'en';
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) {
    return false;
  }
}
