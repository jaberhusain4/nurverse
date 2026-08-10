enum PrayerType { fajr, sunrise, dhuhr, asr, maghrib, isha }

class PrayerInfoModel {
  final PrayerType type;

  final String nameEn;
  final String nameBn;
  final String nameAr;

  final DateTime adhanTime;
  final DateTime startTime;
  final DateTime endTime;

  final DateTime? iqamahTime;

  const PrayerInfoModel({
    required this.type,
    required this.nameEn,
    required this.nameBn,
    required this.nameAr,
    required this.adhanTime,
    required this.startTime,
    required this.endTime,
    this.iqamahTime,
  });

  // ----------------------------
  // Compatibility Getters
  // ----------------------------

  /// Existing UI uses prayer.name
  String get name => nameBn;

  /// Existing UI uses prayer.jamaatTime
  DateTime? get jamaatTime => iqamahTime;

  /// Existing UI uses prayer.isRunning
  bool get isRunning => isCurrent;

  // ----------------------------

  bool get isCurrent {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool get isFinished => DateTime.now().isAfter(endTime);

  bool get isUpcoming => DateTime.now().isBefore(startTime);

  /// Existing UI uses prayer.isCompleted
  bool get isCompleted => isFinished;

  /// Existing UI uses prayer.timeString
  String get timeString {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(startTime.hour)}:${two(startTime.minute)}';
  }

  /// Existing UI uses prayer.displayName
  String get displayName => nameBn;

  Duration get remaining {
    final d = endTime.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  Duration get untilStart {
    final d = startTime.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  double get progress {
    final now = DateTime.now();

    if (now.isBefore(startTime)) return 0;
    if (now.isAfter(endTime)) return 1;

    final total = endTime.difference(startTime).inSeconds;
    final current = now.difference(startTime).inSeconds;

    if (total <= 0) return 0;

    return current / total;
  }
}
