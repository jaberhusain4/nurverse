import 'package:flutter_test/flutter_test.dart';

import 'package:nurverse/services/awal_waqt_service.dart';

void main() {
  const service = AwalWaqtService();

  test('Fajr Awal Waqt uses Fajr-to-sunrise interval', () {
    final now = DateTime(2026, 9, 19, 4, 40);
    final windows = service.buildWindowsFromPrayerList(
      [
        {'name': 'Fajr', 'start': '04:31 AM', 'end': '05:47 AM'},
        {'name': 'Dhuhr', 'start': '11:53 AM', 'end': '03:20 PM'},
        {'name': 'Asr', 'start': '03:20 PM', 'end': '05:59 PM'},
        {'name': 'Maghrib', 'start': '05:59 PM', 'end': '07:14 PM'},
        {'name': 'Isha', 'start': '07:14 PM', 'end': '04:31 AM'},
      ],
      now: now,
    );

    final fajr = service.windowForPrayer(windows, 'Fajr');
    expect(fajr, isNotNull);
    expect(fajr!.duration, const Duration(minutes: 25, seconds: 20));
    expect(fajr.end, DateTime(2026, 9, 19, 4, 56, second: 20));
  });

  test('Isha Awal Waqt rolls Fajr end into the next day', () {
    final now = DateTime(2026, 9, 19, 20);
    final windows = service.buildWindowsFromPrayerList(
      [
        {'name': 'Isha', 'start': '07:14 PM', 'end': '04:31 AM'},
        {'name': 'Fajr', 'start': '04:31 AM', 'end': '05:47 AM'},
        {'name': 'Dhuhr', 'start': '11:53 AM', 'end': '03:20 PM'},
        {'name': 'Asr', 'start': '03:20 PM', 'end': '05:59 PM'},
        {'name': 'Maghrib', 'start': '05:59 PM', 'end': '07:14 PM'},
      ],
      now: now,
    );

    final isha = service.windowForPrayer(windows, 'Isha');
    expect(isha, isNotNull);
    expect(isha!.end, DateTime(2026, 9, 20, 1, 39, 40));
  });

  test('map-based windows also use sunrise as Fajr end', () {
    final times = <String, DateTime>{
      'Fajr': DateTime(2026, 9, 19, 4, 31),
      'Sunrise': DateTime(2026, 9, 19, 5, 47),
      'Dhuhr': DateTime(2026, 9, 19, 11, 53),
      'Asr': DateTime(2026, 9, 19, 15, 20),
      'Maghrib': DateTime(2026, 9, 19, 17, 59),
      'Isha': DateTime(2026, 9, 19, 19, 14),
    };

    final windows = service.buildWindows(
      prayerTimes: times,
      nextFajr: DateTime(2026, 9, 20, 4, 31),
    );

    final fajr = service.windowForPrayer(windows, 'Fajr');
    expect(fajr, isNotNull);
    expect(fajr!.end, DateTime(2026, 9, 19, 4, 56, second: 20));
  });
}
