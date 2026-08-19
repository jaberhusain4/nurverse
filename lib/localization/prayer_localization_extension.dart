import 'app_localizations.dart';

extension PrayerLocalization on AppLocalizations {
  String get refreshTooltip => _text('সালাতের সময় আপডেট করুন', 'Refresh prayer times');

  String get trackerTitle => _text('আজকের সালাত ট্র্যাকার', 'Today’s Prayer Tracker');

  String get trackerSubtitle => _text('পড়া সালাতগুলো চিহ্নিত করুন', 'Mark the prayers you have performed');

  String get fridayLabel => _text('শুক্রবার', 'Friday');

  String prayerName(String name) {
    switch (name.trim().toLowerCase()) {
      case 'fajr':
      case 'ফজর':
        return fajr;
      case 'dhuhr':
      case 'যোহর':
        return dhuhr;
      case 'asr':
      case 'আসর':
        return asr;
      case 'maghrib':
      case 'মাগরিব':
        return maghrib;
      case 'isha':
      case 'ইশা':
        return isha;
      case 'jumuah':
      case 'jummah':
      case 'জুমু‘আ':
      case 'জুমুআ':
        return jumuah;
      default:
        return name;
    }
  }

  String _text(String bn, String en) => isBangla ? bn : en;
}
