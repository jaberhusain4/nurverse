import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerCompletionService {
  static const List<String> prayers = <String>[
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static const String _prefix = 'prayer_completion_';

  static String dateKey([DateTime? date]) =>
      _dateFormat.format(date ?? DateTime.now());

  static String _key(String date, String prayer) =>
      '$_prefix${date}_$prayer';

  static Future<Map<String, bool>> getDay([DateTime? date]) async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = dateKey(date);
    final result = <String, bool>{};

    for (final prayer in prayers) {
      result[prayer] = prefs.getBool(_key(dateString, prayer)) ?? false;
    }

    return result;
  }

  static Future<void> setCompleted({
    required String prayer,
    required bool completed,
    DateTime? date,
  }) async {
    if (!prayers.contains(prayer)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _key(dateKey(date), prayer),
      completed,
    );
  }

  static Future<int> getCompletedCount([DateTime? date]) async {
    final day = await getDay(date);
    return day.values.where((value) => value).length;
  }

  static Future<List<PrayerDayRecord>> getLastSevenDays() async {
    final now = DateTime.now();
    final records = <PrayerDayRecord>[];

    for (var offset = 6; offset >= 0; offset--) {
      final date = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: offset));
      records.add(
        PrayerDayRecord(
          date: date,
          completed: await getDay(date),
        ),
      );
    }

    return records;
  }
}

class PrayerDayRecord {
  final DateTime date;
  final Map<String, bool> completed;

  const PrayerDayRecord({
    required this.date,
    required this.completed,
  });

  int get completedCount => completed.values.where((value) => value).length;
  double get progress => completedCount / PrayerCompletionService.prayers.length;
}
