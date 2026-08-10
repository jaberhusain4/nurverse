import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

import 'prayer_calculation_config.dart';
import 'prayer_engine_service.dart';

class PrayerTrackerInfo {
  final Prayer currentPrayer;
  final Prayer nextPrayer;

  final DateTime currentStart;
  final DateTime nextStart;

  final Duration elapsed;
  final Duration remaining;

  final double progress;

  const PrayerTrackerInfo({
    required this.currentPrayer,
    required this.nextPrayer,
    required this.currentStart,
    required this.nextStart,
    required this.elapsed,
    required this.remaining,
    required this.progress,
  });
}

class PrayerTrackerService {
  const PrayerTrackerService();

  final PrayerEngineService _engine = const PrayerEngineService();

  PrayerTrackerInfo getTracker(
    Position position, {
    DateTime? date,
    CalculationMethod method = CalculationMethod.muslim_world_league,
    Madhab madhab = Madhab.hanafi,
  }) {
    final DateTime now = date ?? DateTime.now();

    final PrayerCalculationConfig config = PrayerCalculationConfig(
      method: method,
      madhab: madhab,
    );

    final PrayerTimes prayerTimes = _engine.getPrayerTimes(
      position: position,
      date: now,
      config: config,
    );

    final Prayer currentPrayer = prayerTimes.currentPrayer();

    final Prayer nextPrayer = prayerTimes.nextPrayer();

    final DateTime currentStart =
        prayerTimes.timeForPrayer(currentPrayer) ?? now;

    final DateTime nextStart = prayerTimes.timeForPrayer(nextPrayer) ?? now;

    final Duration total = nextStart.difference(currentStart);

    final Duration elapsed = now.difference(currentStart);

    final Duration remaining = nextStart.difference(now);

    double progress = 0.0;

    if (total.inSeconds > 0) {
      progress = elapsed.inSeconds / total.inSeconds;
    }

    progress = progress.clamp(0.0, 1.0);

    return PrayerTrackerInfo(
      currentPrayer: currentPrayer,
      nextPrayer: nextPrayer,
      currentStart: currentStart,
      nextStart: nextStart,
      elapsed: elapsed,
      remaining: remaining,
      progress: progress,
    );
  }
}
