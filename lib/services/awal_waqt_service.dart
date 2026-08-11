import 'package:adhan/adhan.dart';

/// Represents NurVerse's early-prayer guidance window.
///
/// Important fiqh note:
/// "Awal waqt" means the beginning of a prayer's valid time. The Qur'an and
/// Sunnah establish prayer-time boundaries, and the Sunnah encourages praying
/// at the proper/early time, but they do not define one universal number of
/// minutes that marks the end of "awal waqt" for all five prayers.
///
/// Therefore this service must NOT present its calculated end as a Shar'i
/// deadline. NurVerse uses the first third of the interval to the next prayer
/// as an app-level "early-prayer guidance window" so the user can have a
/// useful live timer without inventing a religious cutoff.
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

  static const List<String> obligatoryPrayerKeys = <String>[
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  List<AwalWaqtWindow> buildWindows({
    required Map<String, DateTime> prayerTimes,
    required DateTime nextFajr,
  }) {
    final windows = <AwalWaqtWindow>[];

    for (var i = 0; i < obligatoryPrayerKeys.length; i++) {
      final prayer = obligatoryPrayerKeys[i];
      final start = prayerTimes[prayer];
      if (start == null) continue;

      final nextStart = i < obligatoryPrayerKeys.length - 1
          ? prayerTimes[obligatoryPrayerKeys[i + 1]]
          : nextFajr;

      if (nextStart == null || !nextStart.isAfter(start)) continue;

      windows.add(_makeGuidanceWindow(prayer, start, nextStart));
    }

    return windows;
  }

  List<AwalWaqtWindow> buildWindowsFromPrayerList(
    List<Map<String, dynamic>> prayers, {
    required DateTime now,
  }) {
    final starts = <String, DateTime>{};

    for (final prayer in prayers) {
      final key = prayer['name']?.toString();
      final startText = prayer['start']?.toString();
      if (key == null || startText == null) continue;

      final normalizedKey = key == 'Jumuah' ? 'Dhuhr' : key;
      if (!obligatoryPrayerKeys.contains(normalizedKey)) continue;

      final start = _parseDisplayTime(startText, now);
      if (start != null) starts[normalizedKey] = start;
    }

    final windows = <AwalWaqtWindow>[];

    for (var i = 0; i < obligatoryPrayerKeys.length; i++) {
      final key = obligatoryPrayerKeys[i];
      final start = starts[key];
      if (start == null) continue;

      DateTime? nextStart;
      if (i < obligatoryPrayerKeys.length - 1) {
        nextStart = starts[obligatoryPrayerKeys[i + 1]];
      } else {
        final fajr = starts['Fajr'];
        if (fajr != null) {
          nextStart = fajr.isAfter(start)
              ? fajr
              : fajr.add(const Duration(days: 1));
        }
      }

      if (nextStart == null || !nextStart.isAfter(start)) continue;
      windows.add(_makeGuidanceWindow(key, start, nextStart));
    }

    return windows;
  }

  AwalWaqtWindow _makeGuidanceWindow(
    String prayerKey,
    DateTime start,
    DateTime nextStart,
  ) {
    final interval = nextStart.difference(start);
    final end = start.add(
      Duration(milliseconds: interval.inMilliseconds ~/ 3),
    );

    return AwalWaqtWindow(
      prayerKey: prayerKey,
      start: start,
      end: end,
    );
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
