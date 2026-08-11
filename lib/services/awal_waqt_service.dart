import 'package:adhan/adhan.dart';

/// Represents NurVerse's early-prayer guidance window.
///
/// The Qur'an and Sunnah establish the valid boundaries of the prayers and
/// strongly encourage praying at the proper/early time. They do not define one
/// universal number of minutes that ends "awal waqt" for all five prayers.
///
/// NurVerse therefore uses the first third of each prayer interval as an
/// app-level early-prayer guidance window. This is a practical reminder and
/// must not be presented as a Shar'i deadline.
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

  bool hasStarted(DateTime moment) => !moment.isBefore(start);

  bool hasEnded(DateTime moment) => !moment.isBefore(end);

  Duration remainingFrom(DateTime moment) {
    if (!contains(moment)) return Duration.zero;
    return end.difference(moment);
  }

  Duration elapsedFrom(DateTime moment) {
    if (moment.isBefore(start)) return Duration.zero;
    if (!moment.isBefore(end)) return duration;
    return moment.difference(start);
  }
}

/// Live state used by Home and Prayer screens.
class AwalWaqtStatus {
  final AwalWaqtWindow window;
  final DateTime now;

  const AwalWaqtStatus({
    required this.window,
    required this.now,
  });

  bool get isActive => window.contains(now);

  bool get hasStarted => window.hasStarted(now);

  bool get hasEnded => window.hasEnded(now);

  Duration get remaining => window.remainingFrom(now);

  Duration get elapsed => window.elapsedFrom(now);

  double get progress {
    final total = window.duration.inMilliseconds;
    if (total <= 0) return 0;
    return (elapsed.inMilliseconds / total).clamp(0.0, 1.0);
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

  AwalWaqtStatus? activeStatus(
    List<AwalWaqtWindow> windows,
    DateTime moment,
  ) {
    final window = activeWindow(windows, moment);
    if (window == null) return null;
    return AwalWaqtStatus(window: window, now: moment);
  }

  AwalWaqtStatus? statusForPrayer(
    List<AwalWaqtWindow> windows,
    String prayerKey,
    DateTime moment,
  ) {
    final window = windowForPrayer(windows, prayerKey);
    if (window == null) return null;
    return AwalWaqtStatus(window: window, now: moment);
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
