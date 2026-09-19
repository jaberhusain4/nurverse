import 'package:flutter_test/flutter_test.dart';

import 'package:nurverse/services/awal_waqt_service.dart';

void main() {
  const service = AwalWaqtService();

  group('Awal Waqt', () {
    test('uses Fajr to Sunrise for Fajr early window', () {
      final windows = service.buildWindows(
        prayerTimes: {
          'Fajr': DateTime(2026, 9, 19, 4, 31),
          'Sunrise': DateTime(2026, 9, 19, 5, 47),
          'Dhuhr': DateTime(2026, 9, 19, 11, 53),
          'Asr': DateTime(2026, 9, 19, 16, 16),
          'Maghrib': DateTime(2026, 9, 19, 17, 59),
          'Isha': DateTime(2026, 9, 19, 19, 14),
        },
        nextFajr: DateTime(2026, 9, 20, 4, 31),
      );

      final fajr = windows.firstWhere((window) => window.prayerKey == 'Fajr');
      expect(fajr.start, DateTime(2026, 9, 19, 4, 31));
      expect(fajr.end, DateTime(2026, 9, 19, 4, 56, 20));
      expect(fajr.duration, const Duration(minutes: 25, seconds: 20));
    });

    test('uses overnight Isha-to-Fajr interval for Awal Waqt', () {
      final prayers = [
        {'name': 'Fajr', 'start': '04:31 AM', 'end': '05:47 AM'},
        {'name': 'Dhuhr', 'start': '11:53 AM', 'end': '04:16 PM'},
        {'name': 'Asr', 'start': '04:16 PM', 'end': '05:59 PM'},
        {'name': 'Maghrib', 'start': '05:59 PM', 'end': '07:14 PM'},
        {'name': 'Isha', 'start': '07:14 PM', 'end': '04:31 AM'},
      ];

      final now = DateTime(2026, 9, 19, 20);
      final windows = service.buildWindowsFromPrayerList(prayers, now: now);
      final isha = windows.firstWhere((window) => window.prayerKey == 'Isha');

      expect(isha.start, DateTime(2026, 9, 19, 19, 14));
      expect(isha.end, DateTime(2026, 9, 19, 22, 19, 40));
      expect(isha.duration, const Duration(hours: 3, minutes: 5, seconds: 40));
    });

    test('active Fajr Awal Waqt ends one third into Fajr valid period', () {
      final windows = service.buildWindows(
        prayerTimes: {
          'Fajr': DateTime(2026, 9, 19, 4, 31),
          'Sunrise': DateTime(2026, 9, 19, 5, 47),
          'Dhuhr': DateTime(2026, 9, 19, 11, 53),
          'Asr': DateTime(2026, 9, 19, 16, 16),
          'Maghrib': DateTime(2026, 9, 19, 17, 59),
          'Isha': DateTime(2026, 9, 19, 19, 14),
        },
        nextFajr: DateTime(2026, 9, 20, 4, 31),
      );
      final status = service.activeStatus(
        windows,
        DateTime(2026, 9, 19, 4, 55),
      );

      expect(status?.window.prayerKey, 'Fajr');
      expect(status?.isActive, isTrue);
      expect(status?.window.end, DateTime(2026, 9, 19, 4, 56, 20));
    });
  });
}
