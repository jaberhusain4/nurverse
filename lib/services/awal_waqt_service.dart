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

  /// Converts PrayerController's display-ready prayer list into DateTimes.
  ///
  /// The controller already owns the authoritative offline prayer calculation,
  /// so the UI does not calculate prayer times a second time. This keeps the
  /// Home and Prayer screens synchronized with the same source of truth.
  List<AwalWaqtWindow> buildWindowsFromPrayerList(
    List<Map<String, dynamic>> prayers, {
    required DateTime now,
  }) {
    final starts = <String, DateTime>{};
    final ends = <String, DateTime>{};

    for (final prayer in prayers) {
      final key = prayer['name']?.toString();
      final startText = prayer['start']?.toString();
      final endText = prayer['end']?.toString();
      if (key == null || startText == null || endText == null) continue;

      final normalizedKey = key == 'Jumuah' ? 'Dhuhr' : key;
      final start = _parseDisplayTime(startText, now);
      var end = _parseDisplayTime(endText, now);

      if (start == null || end == null) continue;
      if (!end.isAfter(start)) {
        end = end.add(const Duration(days: 1));
      }

      starts[normalizedKey] = start;
      ends[normalizedKey] = end;
    }

    final ordered = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final windows = <AwalWaqtWindow>[];

    for (var i = 0; i < ordered.length; i++) {
      final key = ordered[i];
      final start = starts[key];
      if (start == null) continue;

      DateTime? nextStart;
      if (i < ordered.length - 1) {
        nextStart = starts[ordered[i + 1]];
      } else {
        final fajr = starts['Fajr'];
        if (fajr != null) {
          nextStart = fajr.isAfter(start)
              ? fajr
              : fajr.add(const Duration(days: 1));
        }
      }

      if (nextStart == null || !nextStart.isAfter(start)) {
        final end = ends[key];
        if (end == null || !end.isAfter(start)) continue;
        nextStart = end;
      }

      final interval = nextStart.difference(start);
      if (interval.inSeconds <= 0) continue;

      windows.add(
        AwalWaqtWindow(
          prayerKey: key,
          start: start,
          end: start.add(
            Duration(milliseconds: interval.inMilliseconds ~/ 3),
          ),
        ),
      );
    }

    return windows;
  }

  DateTime? _parseDisplayTime(String value, DateTime base) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (match == null) return null;

    var hour = int.tryParse(match.group(1)!) ?? -1;
    final minute = int.tryParse(match.group(2)!) ?? -1;
    final period = match.group(3)!.toUpperCase();
    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) return null;

    if (period == 'AM') {
      if (hour == 12) hour = 0;
    } else if (hour != 12) {
      hour += 12;
    }

    return DateTime(base.year, base.month, base.day, hour, minute);
  }

  String formatTime(DateTime time) {
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour12.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
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
