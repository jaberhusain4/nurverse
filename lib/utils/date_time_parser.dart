import '../models/prayer_info_model.dart';

class DateTimeParser {
  const DateTimeParser._();

  static PrayerInfoModel? currentPrayer(List<PrayerInfoModel> prayers) {
    try {
      return prayers.firstWhere((e) => e.isCurrent);
    } catch (_) {
      return null;
    }
  }

  static PrayerInfoModel? nextPrayer(List<PrayerInfoModel> prayers) {
    try {
      return prayers.firstWhere((e) => e.isUpcoming);
    } catch (_) {
      return null;
    }
  }

  static String formatCountdown(Duration duration) {
    if (duration.isNegative) {
      return "00:00:00";
    }

    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return "$hours:$minutes:$seconds";
  }
}
