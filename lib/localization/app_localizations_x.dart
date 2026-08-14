import 'app_localizations.dart';

/// Small app-wide localization helpers used by screens that need dynamic
/// labels without duplicating the main localization dictionary.
extension AppLocalizationsX on AppLocalizations {
  String tr(String bn, String en) => isBangla ? bn : en;

  String prayerName(String value) {
    switch (value.trim()) {
      case 'ফজর':
      case 'Fajr': return tr('ফজর', 'Fajr');
      case 'যোহর':
      case 'Dhuhr': return tr('যোহর', 'Dhuhr');
      case 'আসর':
      case 'Asr': return tr('আসর', 'Asr');
      case 'মাগরিব':
      case 'Maghrib': return tr('মাগরিব', 'Maghrib');
      case 'ইশা':
      case 'Isha': return tr('ইশা', 'Isha');
      case "জুমু'আ":
      case 'জুমু‘আ':
      case 'Jumu’ah':
      case "Jumu'ah": return tr('জুমু‘আ', 'Jumu’ah');
      default: return value;
    }
  }

  String prayerStatus(String value) {
    if (isBangla) return value;
    const map = <String, String>{
      'সালাতের সময় গণনা করা হচ্ছে...': 'Calculating prayer times...',
      'লোকেশন পাওয়া গেলে সালাতের সময় দেখানো হবে': 'Prayer times will appear when a location is available.',
      'লোকেশন পাওয়া গেলে সময় দেখানো হবে': 'Times will appear when a location is available.',
      'ফজরের সময় শুরু হতে চলেছে': 'Fajr is about to begin',
      'ফজরের ওয়াক্ত চলছে': 'Fajr time is in progress',
      'পরবর্তী সালাত: জুমু\'আ': 'Next prayer: Jumu’ah',
      'পরবর্তী সালাত: যোহর': 'Next prayer: Dhuhr',
      'জুমু\'আর ওয়াক্ত চলছে': 'Jumu’ah time is in progress',
      'যোহরের ওয়াক্ত চলছে': 'Dhuhr time is in progress',
      'আসরের ওয়াক্ত চলছে': 'Asr time is in progress',
      'মাগরিবের ওয়াক্ত চলছে': 'Maghrib time is in progress',
      'ইশার ওয়াক্ত চলছে': 'Isha time is in progress',
    };
    return map[value] ?? value;
  }

  String prayerTrackerName(String value) => prayerName(value);
  String get unknownLocation => tr('অজানা অবস্থান', 'Unknown location');
  String get locationTooltip => tr('লোকেশন', 'Location');
  String get refreshTooltip => tr('রিফ্রেশ', 'Refresh');
  String get quickActions => tr('কুইক অ্যাকশনস', 'Quick Actions');
  String get nextLabel => tr('পরবর্তী', 'Next');
  String get previousLabel => tr('বিগত সালাত', 'Previous Prayer');
  String get currentLabel => tr('বর্তমান', 'Current');
  String get startLabel => tr('শুরু', 'Start');
  String get endLabel => tr('শেষ', 'End');
  String get jamaatLabel => tr('জামাআত', 'Jama’ah');
  String get fridayLabel => tr('শুক্রবার', 'Friday');
  String get currentPrayerLabel => tr('বর্তমান সালাত', 'Current Prayer');
  String get prayerTimeLabel => tr('সালাতের সময়', 'Prayer Time');
  String get unknownProblem => tr('অজানা সমস্যা হয়েছে।', 'An unknown problem occurred.');
  String get prayerLoadFailed => tr('সালাতের তথ্য লোড করা যায়নি', 'Could not load prayer information');
  String get locationUnavailableLabel => tr('অবস্থান পাওয়া যায়নি', 'Location unavailable');
  String get tryAgainLabel => tr('পুনরায় চেষ্টা করুন', 'Try Again');
  String get todayImportantTimes => tr('আজকের গুরুত্বপূর্ণ সময়', 'Important Times Today');
  String get solarNoonLabel => tr('যাওয়াল', 'Solar Noon');
  String get makruhLabel => tr('মাকরূহ সময়', 'Makruh Time');
  String get prohibitedLabel => tr('নিষিদ্ধ সময়', 'Prohibited Time');
  String get naflTitle => tr('নফল ও অন্যান্য সালাত', 'Nafl & Other Prayers');
  String get naflSubtitle => tr('ঐচ্ছিক ইবাদতের গুরুত্বপূর্ণ সময়', 'Important times for optional worship');
  String get trackerTitle => tr('আজকের সালাত ট্র্যাকার', 'Today’s Prayer Tracker');
  String get trackerSubtitle => tr('পড়া সালাতগুলো চিহ্নিত করুন', 'Mark the prayers you have performed');
  String get prayerTimeNote => tr('সালাতের সময় স্থান, তারিখ ও হিসাব পদ্ধতির উপর নির্ভর করে পরিবর্তিত হতে পারে.', 'Prayer times may vary depending on location, date, and calculation method.');

  String naflDescription(String key) {
    switch (key) {
      case 'ishraq': return tr('সূর্যোদয়ের কিছুক্ষণ পর', 'Shortly after sunrise');
      case 'duha': return tr('সকাল থেকে দুপুরের পূর্ব পর্যন্ত', 'From morning until before noon');
      case 'awwalabin': return tr('মাগরিবের পর', 'After Maghrib');
      case 'tahajjud': return tr('রাতের শেষাংশ', 'The latter part of the night');
      default: return key;
    }
  }

  String hadithCount(int count) => isBangla ? '$countটি হাদিস' : '$count hadiths';
}
