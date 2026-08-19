import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

import 'prayer_calculation_config.dart';

class PrayerTimeWindow {
  final DateTime start;
  final DateTime end;

  const PrayerTimeWindow({required this.start, required this.end});
}

class PrayerEngineService {
  const PrayerEngineService();

  PrayerTimes getPrayerTimes({
    required Position position,
    required DateTime date,
    PrayerCalculationConfig config = PrayerCalculationConfig.defaults,
  }) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = config.method.getParameters()..madhab = config.madhab;
    return PrayerTimes(coordinates, DateComponents.from(date), params);
  }

  Map<String, DateTime> prayerMap({
    required Position position,
    required DateTime date,
    PrayerCalculationConfig config = PrayerCalculationConfig.defaults,
  }) {
    final t = getPrayerTimes(position: position, date: date, config: config);
    return {
      'Fajr': t.fajr,
      'Sunrise': t.sunrise,
      'Dhuhr': t.dhuhr,
      'Asr': t.asr,
      'Maghrib': t.maghrib,
      'Isha': t.isha,
    };
  }

  /// Special daily windows derived from the same Adhan calculation used for
  /// the five daily prayers. This keeps Home and Prayer on one source of
  /// truth and avoids hard-coded clock values.
  Map<String, PrayerTimeWindow> specialTimeWindows({
    required Position position,
    required DateTime date,
    PrayerCalculationConfig config = PrayerCalculationConfig.defaults,
  }) {
    final t = getPrayerTimes(position: position, date: date, config: config);

    final sunriseEnd = t.sunrise.add(const Duration(minutes: 15));
    final zawalStart = t.dhuhr.subtract(const Duration(minutes: 10));
    final sunsetStart = t.maghrib.subtract(const Duration(minutes: 15));

    return {
      'sunriseProhibited': PrayerTimeWindow(
        start: t.sunrise,
        end: sunriseEnd,
      ),
      'zawalProhibited': PrayerTimeWindow(
        start: zawalStart,
        end: t.dhuhr,
      ),
      'sunsetProhibited': PrayerTimeWindow(
        start: sunsetStart,
        end: t.maghrib,
      ),
    };
  }

  Prayer getCurrentPrayer({
    required Position position,
    DateTime? date,
    PrayerCalculationConfig config = PrayerCalculationConfig.defaults,
  }) {
    final calculationDate = date ?? DateTime.now();
    return getPrayerTimes(
      position: position,
      date: calculationDate,
      config: config,
    ).currentPrayer();
  }

  Prayer getNextPrayer({
    required Position position,
    DateTime? date,
    PrayerCalculationConfig config = PrayerCalculationConfig.defaults,
  }) {
    final calculationDate = date ?? DateTime.now();
    return getPrayerTimes(
      position: position,
      date: calculationDate,
      config: config,
    ).nextPrayer();
  }

  Duration timeUntilNextPrayer({
    required Position position,
    DateTime? date,
    PrayerCalculationConfig config = PrayerCalculationConfig.defaults,
  }) {
    final now = date ?? DateTime.now();
    final times = getPrayerTimes(position: position, date: now, config: config);
    final next = times.nextPrayer();
    final nextTime = times.timeForPrayer(next);
    if (nextTime == null) return Duration.zero;
    final difference = nextTime.difference(now);
    return difference.isNegative ? Duration.zero : difference;
  }

  DateTime? prayerTime({
    required Position position,
    required Prayer prayer,
    DateTime? date,
    PrayerCalculationConfig config = PrayerCalculationConfig.defaults,
  }) {
    return getPrayerTimes(
      position: position,
      date: date ?? DateTime.now(),
      config: config,
    ).timeForPrayer(prayer);
  }

  CalculationMethod calculationMethodFromString(String value) {
    return PrayerCalculationConfig.fromSettings(
      calculationMethod: value,
      madhhab: 'Hanafi',
    ).method;
  }

  Madhab madhabFromString(String value) {
    return PrayerCalculationConfig.fromSettings(
      calculationMethod: 'Karachi',
      madhhab: value,
    ).madhab;
  }

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
