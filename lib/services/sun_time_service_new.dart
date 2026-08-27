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

  const SunTimeInfo(
      {required this.sunrise,
      required this.sunset,
      required this.daylight,
      required this.nightLength});
  String get sunriseString => DateFormat.jm().format(sunrise);
  String get sunsetString => DateFormat.jm().format(sunset);
  int get daylightMinutes => daylight.inMinutes;
  int get nightMinutes => nightLength.inMinutes;
}

class SunTimeService {
  const SunTimeService();
  final PrayerEngineService _engine = const PrayerEngineService();

  SunTimeInfo getSunTimes(Position position,
      {DateTime? date,
      CalculationMethod method = CalculationMethod.muslim_world_league,
      Madhab madhab = Madhab.hanafi}) {
    final targetDate = date ?? DateTime.now();
    final config = PrayerCalculationConfig(method: method, madhab: madhab);
    final prayerTimes = _engine.getPrayerTimes(
        position: position, date: targetDate, config: config);
    final sunrise = prayerTimes.sunrise;
    final sunset = prayerTimes.maghrib;
    final daylight = _safeDuration(sunset.difference(sunrise));
    return SunTimeInfo(
        sunrise: sunrise,
        sunset: sunset,
        daylight: daylight,
        nightLength: _calculateNightLength(daylight));
  }

  bool isDayTime(Position position,
      {DateTime? date,
      CalculationMethod method = CalculationMethod.muslim_world_league,
      Madhab madhab = Madhab.hanafi}) {
    final now = date ?? DateTime.now();
    final info =
        getSunTimes(position, date: now, method: method, madhab: madhab);
    return !now.isBefore(info.sunrise) && now.isBefore(info.sunset);
  }

  bool isNightTime(Position position,
          {DateTime? date,
          CalculationMethod method = CalculationMethod.muslim_world_league,
          Madhab madhab = Madhab.hanafi}) =>
      !isDayTime(position, date: date, method: method, madhab: madhab);

  Duration timeUntilSunrise(Position position,
      {DateTime? date,
      CalculationMethod method = CalculationMethod.muslim_world_league,
      Madhab madhab = Madhab.hanafi}) {
    final now = date ?? DateTime.now();
    final today =
        getSunTimes(position, date: now, method: method, madhab: madhab);
    if (now.isBefore(today.sunrise))
      return _safeDuration(today.sunrise.difference(now));
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final tomorrowInfo =
        getSunTimes(position, date: tomorrow, method: method, madhab: madhab);
    return _safeDuration(tomorrowInfo.sunrise.difference(now));
  }

  Duration timeUntilSunset(Position position,
      {DateTime? date,
      CalculationMethod method = CalculationMethod.muslim_world_league,
      Madhab madhab = Madhab.hanafi}) {
    final now = date ?? DateTime.now();
    final today =
        getSunTimes(position, date: now, method: method, madhab: madhab);
    if (now.isBefore(today.sunset))
      return _safeDuration(today.sunset.difference(now));
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final tomorrowInfo =
        getSunTimes(position, date: tomorrow, method: method, madhab: madhab);
    return _safeDuration(tomorrowInfo.sunset.difference(now));
  }

  Duration getDaylightDuration(Position position,
          {DateTime? date,
          CalculationMethod method = CalculationMethod.muslim_world_league,
          Madhab madhab = Madhab.hanafi}) =>
      getSunTimes(position, date: date, method: method, madhab: madhab)
          .daylight;
  Duration getNightDuration(Position position,
          {DateTime? date,
          CalculationMethod method = CalculationMethod.muslim_world_league,
          Madhab madhab = Madhab.hanafi}) =>
      getSunTimes(position, date: date, method: method, madhab: madhab)
          .nightLength;

  Duration _safeDuration(Duration duration) =>
      duration.isNegative ? Duration.zero : duration;
  Duration _calculateNightLength(Duration daylight) {
    const fullDay = Duration(days: 1);
    final night = fullDay - daylight;
    return night.isNegative ? Duration.zero : night;
  }
}
