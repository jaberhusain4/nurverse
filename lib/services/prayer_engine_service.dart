import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

import 'prayer_calculation_config.dart';

class PrayerEngineService {
  const PrayerEngineService();

  // ==========================================================================
  // PRAYER TIMES
  // ==========================================================================

  PrayerTimes getPrayerTimes({
    required Position position,
    required DateTime date,
    PrayerCalculationConfig config = PrayerCalculationConfig.defaults,
  }) {
    final Coordinates coordinates = Coordinates(
      position.latitude,
      position.longitude,
    );

    final CalculationParameters params =
        config.method.getParameters()..madhab = config.madhab;

    return PrayerTimes(coordinates, DateComponents.from(date), params);
  }

  // ==========================================================================
  // PRAYER MAP
  // ==========================================================================

  Map<String, DateTime> prayerMap({
    required Position position,
    required DateTime date,
    PrayerCalculationConfig config = PrayerCalculationConfig.defaults,
  }) {
    final PrayerTimes prayerTimes = getPrayerTimes(
      position: position,
      date: date,
      config: config,
    );

    return {
      'Fajr': prayerTimes.fajr,
      'Sunrise': prayerTimes.sunrise,
      'Dhuhr': prayerTimes.dhuhr,
      'Asr': prayerTimes.asr,
      'Maghrib': prayerTimes.maghrib,
      'Isha': prayerTimes.isha,
    };
  }

  // ==========================================================================
  // CURRENT PRAYER
  // ==========================================================================

  Prayer getCurrentPrayer({
    required Position position,
    DateTime? date,
    PrayerCalculationConfig config = PrayerCalculationConfig.defaults,
  }) {
    final DateTime calculationDate = date ?? DateTime.now();

    final PrayerTimes prayerTimes = getPrayerTimes(
      position: position,
      date: calculationDate,
      config: config,
    );

    return prayerTimes.currentPrayer();
  }

  // ==========================================================================
  // NEXT PRAYER
  // ==========================================================================

  Prayer getNextPrayer({
    required Position position,
    DateTime? date,
    PrayerCalculationConfig config = PrayerCalculationConfig.defaults,
  }) {
    final DateTime calculationDate = date ?? DateTime.now();

    final PrayerTimes prayerTimes = getPrayerTimes(
      position: position,
      date: calculationDate,
      config: config,
    );

    return prayerTimes.nextPrayer();
  }

  // ==========================================================================
  // TIME UNTIL NEXT PRAYER
  // ==========================================================================

  Duration timeUntilNextPrayer({
    required Position position,
    DateTime? date,
    PrayerCalculationConfig config = PrayerCalculationConfig.defaults,
  }) {
    final DateTime now = date ?? DateTime.now();

    final PrayerTimes prayerTimes = getPrayerTimes(
      position: position,
      date: now,
      config: config,
    );

    final Prayer nextPrayer = prayerTimes.nextPrayer();

    final DateTime? nextTime = prayerTimes.timeForPrayer(nextPrayer);

    if (nextTime == null) {
      return Duration.zero;
    }

    final Duration difference = nextTime.difference(now);

    if (difference.isNegative) {
      return Duration.zero;
    }

    return difference;
  }

  // ==========================================================================
  // SINGLE PRAYER TIME
  // ==========================================================================

  DateTime? prayerTime({
    required Position position,
    required Prayer prayer,
    DateTime? date,
    PrayerCalculationConfig config = PrayerCalculationConfig.defaults,
  }) {
    final PrayerTimes prayerTimes = getPrayerTimes(
      position: position,
      date: date ?? DateTime.now(),
      config: config,
    );

    return prayerTimes.timeForPrayer(prayer);
  }

  // ==========================================================================
  // SETTINGS → CALCULATION METHOD
  // ==========================================================================

  /// Backward-compatible helper.
  CalculationMethod calculationMethodFromString(String value) {
    return PrayerCalculationConfig.fromSettings(
      calculationMethod: value,
      madhhab: 'Hanafi',
    ).method;
  }

  // ==========================================================================
  // SETTINGS → MADAB
  // ==========================================================================

  /// Backward-compatible helper.
  Madhab madhabFromString(String value) {
    return PrayerCalculationConfig.fromSettings(
      calculationMethod: 'Karachi',
      madhhab: value,
    ).madhab;
  }

  // ==========================================================================
  // BUILD CONFIG FROM SETTINGS
  // ==========================================================================

  PrayerCalculationConfig configFromSettings({
    required String calculationMethod,
    required String madhhab,
  }) {
    return PrayerCalculationConfig.fromSettings(
      calculationMethod: calculationMethod,
      madhhab: madhhab,
    );
  }
}
