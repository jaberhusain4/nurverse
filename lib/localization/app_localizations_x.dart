import 'app_localizations.dart';

/// Small app-wide localization helpers used by screens that need dynamic
/// labels without duplicating the main localization dictionary.
extension AppLocalizationsX on AppLocalizations {
  String tr(String bn, String en) {
    if (isArabic) return _arabicLabel(en);
    return isBangla ? bn : en;
  }

  String _arabicLabel(String english) {
    const map = <String, String>{
      'Fajr': 'الفجر',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Magrib': 'المغرب',
      'Isha': 'العشاء',
      'Jumu’ah': 'الجمعة',
      'Jama’ah': 'الجماعة',
      'Ishraq': 'الإشراق',
      'Duha': 'الضحى',
      'Awwabin': 'الأوابين',
      'Tahajjud': 'التهجد',
      'Ishar Waqto Cholche': 'وقت العشاء جارٍ',
      'Ishar Waqt Cholche': 'وقت العشاء جارٍ',
      'Isha time is active': 'وقت العشاء جارٍ',
      'Isha time is in progress': 'وقت العشاء جارٍ',
      'Maghrib time is active': 'وقت المغرب جارٍ',
      'Maghrib time is in progress': 'وقت المغرب جارٍ',
      'Tahajjud time is active': 'وقت التهجد جارٍ',
      'Tahajjud time is in progress': 'وقت التهجد جارٍ',
      'Ishraq time is active': 'وقت الإشراق جارٍ',
      'Ishraq time is in progress': 'وقت الإشراق جارٍ',
      'Calculating prayer times...': 'جارٍ حساب أوقات الصلاة...',
      'Prayer times will appear when a location is available.': 'ستظهر أوقات الصلاة عند توفر الموقع.',
      'Times will appear when a location is available.': 'ستظهر الأوقات عند توفر الموقع.',
      'Fajr is about to begin': 'سيبدأ وقت الفجر قريبًا',
      'Fajr time is in progress': 'وقت الفجر جارٍ',
      'Fajr time is active': 'وقت الفجر جارٍ',
      'Next prayer: Jumu’ah': 'الصلاة التالية: الجمعة',
      'Next prayer: Dhuhr': 'الصلاة التالية: الظهر',
      'Jumu’ah time is in progress': 'وقت الجمعة جارٍ',
      'Jumu’ah time is active': 'وقت الجمعة جارٍ',
      'Dhuhr time is in progress': 'وقت الظهر جارٍ',
      'Dhuhr time is active': 'وقت الظهر جارٍ',
      'Asr time is in progress': 'وقت العصر جارٍ',
      'Asr time is active': 'وقت العصر جارٍ',
      'Unknown location': 'موقع غير معروف',
      'Location': 'الموقع',
      'Refresh': 'تحديث',
      'Quick Actions': 'إجراءات سريعة',
      'Next': 'التالي',
      'Previous Prayer': 'الصلاة السابقة',
      'Current': 'الحالي',
      'Start': 'البداية',
      'End': 'النهاية',
      'Friday': 'الجمعة',
      'Current Prayer': 'الصلاة الحالية',
      'Prayer Time': 'وقت الصلاة',
      'An unknown problem occurred.': 'حدثت مشكلة غير معروفة.',
      'Could not load prayer information': 'تعذر تحميل معلومات الصلاة',
      'Location unavailable': 'الموقع غير متاح',
      'Try Again': 'حاول مرة أخرى',
      'Important Times Today': 'أهم أوقات اليوم',
      'Solar Noon': 'الزوال',
      'Makruh Time': 'وقت الكراهة',
      'Prohibited Time': 'الوقت المنهي عنه',
      'Nafl & Other Prayers': 'النوافل والصلوات الأخرى',
      'Important times for optional worship': 'أهم أوقات العبادات النافلة',
      'Today’s Prayer Tracker': 'متابعة صلوات اليوم',
      'Mark the prayers you have performed': 'حدد الصلوات التي أديتها',
      'Prayer times may vary depending on location, date, and calculation method.': 'قد تختلف أوقات الصلاة حسب الموقع والتاريخ وطريقة الحساب.',
      'Shortly after sunrise': 'بعد الشروق بقليل',
      'From morning until before noon': 'من الصباح إلى ما قبل الظهر',
      'After Maghrib': 'بعد المغرب',
      'The latter part of the night': 'الجزء الأخير من الليل',
    };
    return map[english] ?? english;
  }

  String prayerName(String value) {
    final raw = value.trim();
    switch (raw.toLowerCase()) {
      case 'fajr':
      case 'ফজর':
        return tr('ফজর', 'Fajr');
      case 'dhuhr':
      case 'যোহর':
        return tr('যোহর', 'Dhuhr');
      case 'asr':
      case 'আসর':
        return tr('আসর', 'Asr');
      case 'maghrib':
      case 'magrib':
      case 'মাগরিব':
        return tr('মাগরিব', 'Maghrib');
      case 'isha':
      case 'ইশা':
        return tr('ইশা', 'Isha');
      case "jumu'ah":
      case 'jumu’ah':
      case "জুমু'আ":
      case 'জুমু‘আ':
        return tr('জুমু‘আ', 'Jumu’ah');
      case 'ishraq':
      case 'ইশরাক':
        return tr('ইশরাক', 'Ishraq');
      case 'chasht':
      case 'duha':
      case 'চাশত':
      case 'দুহা':
        return tr('চাশত / দুহা', 'Duha');
      case 'awwabin':
      case 'আউওয়াবীন':
        return tr('আউওয়াবীন', 'Awwabin');
      case 'tahajjud':
      case 'তাহাজ্জুদ':
        return tr('তাহাজ্জুদ', 'Tahajjud');
      default:
        return isArabic ? _arabicLabel(raw) : raw;
    }
  }

  String prayerStatus(String value) {
    final raw = value.trim();
    if (isArabic) {
      const arabicStatuses = <String, String>{
        'ইশার ওয়াক্ত চলছে': 'وقت العشاء جارٍ',
        'ইশরাকের ওয়াক্ত চলছে': 'وقت الإشراق جارٍ',
        'ইশরাক ওয়াক্ত চলছে': 'وقت الإشراق جارٍ',
        'তাহাজ্জুদের ওয়াক্ত চলছে': 'وقت التهجد جارٍ',
        'তাহাজ্জুদ ওয়াক্ত চলছে': 'وقت التهجد جارٍ',
        'মাগরিবের ওয়াক্ত চলছে': 'وقت المغرب جارٍ',
        'Magrib time is active': 'وقت المغرب جارٍ',
        'Ishar Waqto Cholche': 'وقت العشاء جارٍ',
        'Ishar Waqt Cholche': 'وقت العشاء جارٍ',
        'Isha time is active': 'وقت العشاء جارٍ',
        'Isha time is in progress': 'وقت العشاء جارٍ',
        'Ishraq time is active': 'وقت الإشراق جارٍ',
        'Ishraq time is in progress': 'وقت الإشراق جارٍ',
        'Tahajjud time is active': 'وقت التهجد جارٍ',
        'Tahajjud time is in progress': 'وقت التهجد جارٍ',
      };
      return arabicStatuses[raw] ?? _arabicLabel(raw);
    }
    if (isBangla) return raw;
    const map = <String, String>{
      'সালাতের সময় গণনা করা হচ্ছে...': 'Calculating prayer times...',
      'লোকেশন পাওয়া গেলে সালাতের সময় দেখানো হবে': 'Prayer times will appear when a location is available.',
      'লোকেশন পাওয়া গেলে সময় দেখানো হবে': 'Times will appear when a location is available.',
      'ফজরের সময় শুরু হতে চলেছে': 'Fajr is about to begin',
      'ফজরের ওয়াক্ত চলছে': 'Fajr time is active',
      'পরবর্তী সালাত: জুমু‘আ': 'Next prayer: Jumu’ah',
      'পরবর্তী সালাত: যোহর': 'Next prayer: Dhuhr',
      'জুমু‘আর ওয়াক্ত চলছে': 'Jumu’ah time is active',
      'যোহরের ওয়াক্ত চলছে': 'Dhuhr time is active',
      'আসরের ওয়াক্ত চলছে': 'Asr time is active',
      'মাগরিবের ওয়াক্ত চলছে': 'Maghrib time is active',
      'ইশার ওয়াক্ত চলছে': 'Isha time is active',
      'ইশরাকের ওয়াক্ত চলছে': 'Ishraq time is active',
      'ইশরাক ওয়াক্ত চলছে': 'Ishraq time is active',
      'তাহাজ্জুদের ওয়াক্ত চলছে': 'Tahajjud time is active',
      'তাহাজ্জুদ ওয়াক্ত চলছে': 'Tahajjud time is active',
      'Ishar Waqto Cholche': 'Isha time is active',
      'Ishar Waqt Cholche': 'Isha time is active',
      'Magrib time is active': 'Maghrib time is active',
    };
    return map[raw] ?? raw;
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
      default: return isArabic ? _arabicLabel(key) : key;
    }
  }

  String hadithCount(int count) {
    if (isArabic) return '$count حديث';
    return isBangla ? '$countটি হাদিস' : '$count hadiths';
  }
}
