import 'package:adhan/adhan.dart';

/// Represents NurVerse's early-time window for a prayer.
///
/// The actual beginning of a prayer is the calculated prayer start. Because
/// "awal waqt" is not a single fixed number of minutes for every prayer or
/// every madhhab, NurVerse models it as an app-level early-time window: the
/// first third of the interval between the prayer's start and the next prayer
/// start. The underlying prayer boundaries still come from adhan.
class AwalWaqtWindow {
  final String prayerKey;
  final DateTime start;
  final DateTime end;

  const AwalWaqtWindow({
    required this.prayerKey,
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);

  bool contains(DateTime moment) {
    return !moment.isBefore(start) && moment.isBefore(end);
  }

  Duration remainingFrom(DateTime moment) {
    if (!contains(moment)) return Duration.zero;
    return end.difference(moment);
  }
}

class AwalWaqtService {
  const AwalWaqtService();

  /// Builds the early-time window for each of the five obligatory prayers.
  ///
  /// [prayerTimes] should contain the calculated starts for Fajr, Dhuhr,
  /// Asr, Maghrib and Isha. [nextFajr] is tomorrow's Fajr and is required to
  /// close the Isha interval correctly.
  List<AwalWaqtWindow> buildWindows({
    required Map<String, DateTime> prayerTimes,
    required DateTime nextFajr,
  }) {
    final ordered = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final windows = <AwalWaqtWindow>[];

    for (var i = 0; i < ordered.length; i++) {
      final prayer = ordered[i];
      final start = prayerTimes[prayer];
      if (start == null) continue;

      final nextStart = i < ordered.length - 1
          ? prayerTimes[ordered[i + 1]]
          : nextFajr;

      if (nextStart == null || !nextStart.isAfter(start)) continue;

      final interval = nextStart.difference(start);
      final earlyEnd = start.add(
        Duration(milliseconds: interval.inMilliseconds ~/ 3),
      );

      windows.add(
        AwalWaqtWindow(
          prayerKey: prayer,
          start: start,
          end: earlyEnd,
        ),
      );
    }

    return windows;
  }

  AwalWaqtWindow? activeWindow(
    List<AwalWaqtWindow> windows,
    DateTime moment,
  ) {
    for (final window in windows) {
      if (window.contains(moment)) return window;
    }
    return null;
  }

  AwalWaqtWindow? windowForPrayer(
    List<AwalWaqtWindow> windows,
    String prayerKey,
  ) {
    for (final window in windows) {
      if (window.prayerKey == prayerKey) return window;
    }
    return null;
  }

  /// Maps an adhan Prayer enum to NurVerse's display key.
  String prayerKey(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return '';
    }
  }
}
