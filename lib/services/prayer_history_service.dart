/// Resolves which completed prayer should be shown as the previous prayer.
///
/// The current UI intentionally keeps Fajr as the previous prayer throughout
/// the Dhuhr interval; this service preserves that established behavior.
class PreviousPrayerInfo {
  final String name;
  final DateTime time;
  final String description;

  const PreviousPrayerInfo({
    required this.name,
    required this.time,
    required this.description,
  });
}

class PrayerHistoryService {
  const PrayerHistoryService();

  static PreviousPrayerInfo resolvePreviousPrayer({
    required DateTime now,
    required DateTime fajr,
    required DateTime sunrise,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime maghrib,
    required DateTime isha,
    required DateTime yesterdayIsha,
  }) {
    if (now.isBefore(sunrise)) {
      return PreviousPrayerInfo(
        name: 'ইশা',
        time: yesterdayIsha,
        description: 'ইশা শেষ হয়েছে',
      );
    }
    if (now.isBefore(dhuhr)) {
      return PreviousPrayerInfo(
        name: 'ফজর',
        time: fajr,
        description: 'ফজর সম্পন্ন হয়েছে',
      );
    }
    if (now.isBefore(asr)) {
      return PreviousPrayerInfo(
        name: 'ফজর',
        time: fajr,
        description: 'ফজর শেষ হয়েছে',
      );
    }
    if (now.isBefore(maghrib)) {
      return PreviousPrayerInfo(
        name: 'যোহর',
        time: dhuhr,
        description: 'যোহর শেষ হয়েছে',
      );
    }
    if (now.isBefore(isha)) {
      return PreviousPrayerInfo(
        name: 'আসর',
        time: asr,
        description: 'আসর শেষ হয়েছে',
      );
    }
    return PreviousPrayerInfo(
      name: 'মাগরিব',
      time: maghrib,
      description: 'মাগরিব শেষ হয়েছে',
    );
  }
}
