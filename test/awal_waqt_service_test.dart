import 'package:flutter_test/flutter_test.dart';

import 'package:nurverse/services/awal_waqt_service.dart';

void main() {
  const service = AwalWaqtService();

  final prayerTimes = <String, DateTime>{
    'Fajr': DateTime(2026, 9, 19, 4, 31),
    'Sunrise': DateTime(2026, 9, 19, 5, 47),
    'Dhuhr': DateTime(2026, 9, 19, 11, 54),
    'Asr': DateTime(2026, 9, 19, 16, 16),
    'Maghrib': DateTime(2026, 9, 19, 17, 59),
    'Isha': DateTime(2026, 9, 19, 19, 14),
  };

  test('Fajr Awal Waqt uses sunrise as its prayer boundary', () {
    final windows = service.buildWindows(
      prayerTimes: prayerTimes,
      nextFajr: DateTime(2026, 9, 20, 4, 31),
    );

    final fajr = windows.firstWhere((w) => w.prayerKey == 'Fajr');
    expect(fajr.start, prayerTimes['Fajr']);
    expect(fajr.end, DateTime(2026, 9, 19, 4, 56, 20));
    expect(fajr.end.isBefore(prayerTimes['Sunrise']!), isTrue);
  });

  test('prayer-list builder uses actual prayer end for all windows', () {
    final prayers = <Map<String, dynamic>>[
      {'name': 'Fajr', 'start': '04:31', 'end': '05:47'},
      {'name': 'Dhuhr', 'start': '11:54', 'end': '16:16'},
      {'name': 'Asr', 'start': '16:16', 'end': '17:59'},
      {'name': 'Maghrib', 'start': '17:59', 'end': '19:14'},
      {'name': 'Isha', 'start': '19:14', 'end': '04:31'},
    ];

    final windows = service.buildWindowsFromPrayerList(
      prayers,
      now: DateTime(2026, 9, 19, 10),
    );

    expect(windows.length, 5);
    expect(
      windows.firstWhere((w) => w.prayerKey == 'Fajr').end,
      DateTime(2026, 9, 19, 4, 56, 20),
    );
    expect(
      windows.firstWhere((w) => w.prayerKey == 'Dhuhr').end,
      DateTime(2026, 9, 19, 13, 21, 20),
    );
    expect(
      windows.firstWhere((w) => w.prayerKey == 'Isha').end,
      DateTime(2026, 9, 19, 22, 19, 40),
    );
  });
}
