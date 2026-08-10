import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'prayer_calculation_config.dart';
import 'prayer_engine_service.dart';

class SunTimeInfo {
  final DateTime sunrise;
  final DateTime sunset;
  final Duration daylight;
  final Duration nightLength;

  const SunTimeInfo({
    required this.sunrise,
    required this.sunset,
    required this.daylight,
    required this.nightLength,
  });

  // ==========================================================================
  // FORMATTED VALUES
  // ==========================================================================

  String get sunriseString => DateFormat.jm().format(sunrise);

  String get sunsetString => DateFormat.jm().format(sunset);

  // ==========================================================================
  // ADDITIONAL HELPERS
  // ==========================================================================

  int get daylightMinutes => daylight.inMinutes;

  int get nightMinutes => nightLength.inMinutes;
}

class SunTimeService {
  const SunTimeService();

  final PrayerEngineService _engine = const PrayerEngineService();

  // ==========================================================================
  // GET SUN TIMES
  // ==========================================================================

  SunTimeInfo getSunTimes(
    Position position, {
    DateTime? date,
    CalculationMethod method = CalculationMethod.muslim_world_league,
    Madhab madhab = Madhab.hanafi,
  }) {
    final DateTime targetDate = date ?? DateTime.now();

    final PrayerCalculationConfig config = PrayerCalculationConfig(
      method: method,
      madhab: madhab,
    );

    final PrayerTimes prayerTimes = _engine.getPrayerTimes(
      position: position,
      date: targetDate,
      config: config,
    );

    final DateTime sunrise = prayerTimes.sunrise;

    // Maghrib is used as the sunset boundary.
    final DateTime sunset = prayerTimes.maghrib;

    final Duration daylight = _safeDuration(sunset.difference(sunrise));

    final Duration nightLength = _calculateNightLength(daylight);

    return SunTimeInfo(
      sunrise: sunrise,
      sunset: sunset,
      daylight: daylight,
      nightLength: nightLength,
    );
  }

  // ==========================================================================
  // IS DAY TIME
  // ==========================================================================

  bool isDayTime(
    Position position, {
    DateTime? date,
    CalculationMethod method = CalculationMethod.muslim_world_league,
    Madhab madhab = Madhab.hanafi,
  }) {
    final DateTime now = date ?? DateTime.now();

    final SunTimeInfo info = getSunTimes(
      position,
      date: now,
      method: method,
      madhab: madhab,
    );

    return !now.isBefore(info.sunrise) && now.isBefore(info.sunset);
  }

  // ==========================================================================
  // IS NIGHT TIME
  // ==========================================================================

  bool isNightTime(
    Position position, {
    DateTime? date,
    CalculationMethod method = CalculationMethod.muslim_world_league,
    Madhab madhab = Madhab.hanafi,
  }) {
    return !isDayTime(position, date: date, method: method, madhab: madhab);
  }

  // ==========================================================================
  // TIME UNTIL SUNRISE
  // ==========================================================================

  Duration timeUntilSunrise(
    Position position, {
    DateTime? date,
    CalculationMethod method = CalculationMethod.muslim_world_league,
    Madhab madhab = Madhab.hanafi,
  }) {
    final DateTime now = date ?? DateTime.now();

    final SunTimeInfo today = getSunTimes(
      position,
      date: now,
      method: method,
      madhab: madhab,
    );

    if (now.isBefore(today.sunrise)) {
      return _safeDuration(today.sunrise.difference(now));
    }

    final DateTime tomorrowDate = DateTime(now.year, now.month, now.day + 1);

    final SunTimeInfo tomorrow = getSunTimes(
      position,
      date: tomorrowDate,
      method: method,
      madhab: madhab,
    );

    return _safeDuration(tomorrow.sunrise.difference(now));
  }

  // ==========================================================================
  // TIME UNTIL SUNSET
  // ==========================================================================

  Duration timeUntilSunset(
    Position position, {
    DateTime? date,
    CalculationMethod method = CalculationMethod.muslim_world_league,
    Madhab madhab = Madhab.hanafi,
  }) {
    final DateTime now = date ?? DateTime.now();

    final SunTimeInfo today = getSunTimes(
      position,
      date: now,
      method: method,
      madhab: madhab,
    );

    if (now.isBefore(today.sunset)) {
      return _safeDuration(today.sunset.difference(now));
    }

    final DateTime tomorrowDate = DateTime(now.year, now.month, now.day + 1);

    final SunTimeInfo tomorrow = getSunTimes(
      position,
      date: tomorrowDate,
      method: method,
      madhab: madhab,
    );

    return _safeDuration(tomorrow.sunset.difference(now));
  }

  // ==========================================================================
  // DAYLIGHT DURATION
  // ==========================================================================

  Duration getDaylightDuration(
    Position position, {
    DateTime? date,
    CalculationMethod method = CalculationMethod.muslim_world_league,
    Madhab madhab = Madhab.hanafi,
  }) {
    return getSunTimes(
      position,
      date: date,
      method: method,
      madhab: madhab,
    ).daylight;
  }

  // ==========================================================================
  // NIGHT DURATION
  // ==========================================================================

  Duration getNightDuration(
    Position position, {
    DateTime? date,
    CalculationMethod method = CalculationMethod.muslim_world_league,
    Madhab madhab = Madhab.hanafi,
  }) {
    return getSunTimes(
      position,
      date: date,
      method: method,
      madhab: madhab,
    ).nightLength;
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  Duration _calculateNightLength(Duration daylight) {
    const Duration fullDay = Duration(hours: 24);

    final Duration night = fullDay - daylight;

    if (night.isNegative) {
      return Duration.zero;
    }

    return night;
  }

  Duration _safeDuration(Duration duration) {
    if (duration.isNegative) {
      return Duration.zero;
    }

    return duration;
  }
}
