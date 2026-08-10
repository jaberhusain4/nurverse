// lib/services/current_prayer_service.dart

import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'prayer_engine_service.dart';

class CurrentPrayerInfo {
  final Prayer currentPrayer;
  final Prayer nextPrayer;
  final DateTime currentPrayerTime;
  final DateTime nextPrayerTime;
  final Duration remaining;

  const CurrentPrayerInfo({
    required this.currentPrayer,
    required this.nextPrayer,
    required this.currentPrayerTime,
    required this.nextPrayerTime,
    required this.remaining,
  });

  String get currentName => _displayName(currentPrayer);

  String get nextName => _displayName(nextPrayer);

  String get currentTime => DateFormat.jm().format(currentPrayerTime);

  String get nextTime => DateFormat.jm().format(nextPrayerTime);

  static String _displayName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return "Fajr";
      case Prayer.sunrise:
        return "Sunrise";
      case Prayer.dhuhr:
        return "Dhuhr";
      case Prayer.asr:
        return "Asr";
      case Prayer.maghrib:
        return "Maghrib";
      case Prayer.isha:
        return "Isha";
      case Prayer.none:
        return "-";
    }
  }
}

class CurrentPrayerService {
  const CurrentPrayerService();

  final PrayerEngineService _engine = const PrayerEngineService();

  CurrentPrayerInfo getCurrentPrayerInfo(Position position) {
    final now = DateTime.now();

    final current = _engine.getCurrentPrayer(position: position, date: now);

    final next = _engine.getNextPrayer(position: position, date: now);

    final currentTime =
        _engine.prayerTime(position: position, prayer: current, date: now) ??
        now;

    final nextTime =
        _engine.prayerTime(position: position, prayer: next, date: now) ?? now;

    return CurrentPrayerInfo(
      currentPrayer: current,
      nextPrayer: next,
      currentPrayerTime: currentTime,
      nextPrayerTime: nextTime,
      remaining: nextTime.difference(now),
    );
  }
}
