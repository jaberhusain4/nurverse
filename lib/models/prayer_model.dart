enum PrayerType { fajr, sunrise, dhuhr, asr, maghrib, isha }

class PrayerModel {
  final String name;
  final String englishName;
  final String startTime;
  final String endTime;
  final String jamaatTime;
  final bool isCompleted;
  final bool isCurrent;
  final PrayerType type;

  PrayerModel({
    required this.name,
    required this.englishName,
    required this.startTime,
    required this.endTime,
    required this.jamaatTime,
    this.isCompleted = false,
    this.isCurrent = false,
    this.type = PrayerType.fajr,
  });

  String get nameBn => name;
  String get adhanTime => startTime;

  PrayerModel copyWith({
    String? name,
    String? englishName,
    String? startTime,
    String? endTime,
    String? jamaatTime,
    bool? isCompleted,
    bool? isCurrent,
    PrayerType? type,
  }) {
    return PrayerModel(
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      jamaatTime: jamaatTime ?? this.jamaatTime,
      isCompleted: isCompleted ?? this.isCompleted,
      isCurrent: isCurrent ?? this.isCurrent,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'englishName': englishName,
      'startTime': startTime,
      'endTime': endTime,
      'jamaatTime': jamaatTime,
      'isCompleted': isCompleted,
      'isCurrent': isCurrent,
    };
  }

  factory PrayerModel.fromJson(Map<String, dynamic> json) {
    return PrayerModel(
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      jamaatTime: json['jamaatTime'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      isCurrent: json['isCurrent'] ?? false,
    );
  }
}
