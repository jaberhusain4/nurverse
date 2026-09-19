import 'package:flutter_test/flutter_test.dart';

import 'package:nurverse/services/awal_waqt_service.dart';

void main() {
  const service = AwalWaqtService();

  final prayerTimes = <String, DateTime>{
    'Fajr': DateTime(2026, 9, 19, 4, 31),
    'Sunrise': DateTime(2026, 9, 19, 5, 47),
    'Dhuhr': DateTime(2026, 9, 19, 11, 53),
    'Asr': DateTime(2026, 9, 19, 16, 16),
    'Maghrib': DateTime(2026, 9, 19, 17, 59),
    'Isha': DateTime(2026, 9, 19, 19, 14),
  };

  test('Fajr Awal Waqt ends at first third of Fajr-to-sunrise window', () {
    final windows = service.buildWindows(
      prayerTimes: prayerTimes,
      nextFajr: DateTime(2026, 9, 20, 4, 31),
    );

    final fajr = windows.firstWhere((w) => w.prayerKey == 'Fajr');
    expect(fajr.start, prayerTimes['Fajr']);
    expect(fajr.end, DateTime(2026, 9, 19, 4, 56, 20));
    expect(fajr.end.isBefore(prayerTimes['Sunrise']!), isTrue);
  });

  test('prayer-list builder uses each prayer end for Fajr', () {
    final prayers = <Map<String, dynamic>>[
      {
        'name': 'Fajr',
        'start': '04:31 AM',
        'end': '05:47 AM',
      },
      {
        'name': 'Dhuhr',
        'start': '11:53 AM',
        'end': '04:16 PM',
      },
      {
        'name': 'Asr',
        'start': '04:16 PM',
        'end': '05:59 PM',
      },
      {
        'name': 'Maghrib',
        'start': '05:59 PM',
        'end': '07:14 PM',
      },
      {
        'name': 'Isha',
        'start': '07:14 PM',
        'end': '04:31 AM',
      },
    ];

    final windows = service.buildWindowsFromPrayerList(
      prayers,
      now: DateTime(2026, 9, 19, 10),
    );

    final fajr = windows.firstWhere((w) => w.prayerKey == 'Fajr');
    expect(fajr.start, DateTime(2026, 9, 19, 4, 31));
    expect(fajr.end, DateTime(2026, 9, 19, 4, 56, 20));
  });
}
