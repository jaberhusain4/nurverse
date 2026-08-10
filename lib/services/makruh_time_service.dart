import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

import 'prayer_calculation_config.dart';
import 'prayer_engine_service.dart';

enum MakruhPeriod { none, sunrise, zenith, sunset }

class MakruhInfo {
  final MakruhPeriod period;
  final bool isMakruh;
  final DateTime start;
  final DateTime end;

  const MakruhInfo({
    required this.period,
    required this.isMakruh,
    required this.start,
    required this.end,
  });

  String get name {
    switch (period) {
      case MakruhPeriod.sunrise:
        return 'Sunrise';

      case MakruhPeriod.zenith:
        return 'Zawal';

      case MakruhPeriod.sunset:
        return 'Sunset';

      case MakruhPeriod.none:
        return 'None';
    }
  }
}

class MakruhTimeService {
  const MakruhTimeService();

  final PrayerEngineService _engine = const PrayerEngineService();

  MakruhInfo getCurrentMakruh(
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

    final PrayerTimes prayer = _engine.getPrayerTimes(
      position: position,
      date: now,
      config: config,
    );

    final DateTime sunriseStart = prayer.sunrise;

    final DateTime sunriseEnd = sunriseStart.add(const Duration(minutes: 20));

    final DateTime zawalStart = prayer.dhuhr.subtract(
      const Duration(minutes: 10),
    );

    final DateTime zawalEnd = prayer.dhuhr.add(const Duration(minutes: 5));

    final DateTime sunsetStart = prayer.maghrib.subtract(
      const Duration(minutes: 20),
    );

    final DateTime sunsetEnd = prayer.maghrib;

    if (now.isAfter(sunriseStart) && now.isBefore(sunriseEnd)) {
      return MakruhInfo(
        period: MakruhPeriod.sunrise,
        isMakruh: true,
        start: sunriseStart,
        end: sunriseEnd,
      );
    }

    if (now.isAfter(zawalStart) && now.isBefore(zawalEnd)) {
      return MakruhInfo(
        period: MakruhPeriod.zenith,
        isMakruh: true,
        start: zawalStart,
        end: zawalEnd,
      );
    }

    if (now.isAfter(sunsetStart) && now.isBefore(sunsetEnd)) {
      return MakruhInfo(
        period: MakruhPeriod.sunset,
        isMakruh: true,
        start: sunsetStart,
        end: sunsetEnd,
      );
    }

    return MakruhInfo(
      period: MakruhPeriod.none,
      isMakruh: false,
      start: now,
      end: now,
    );
  }
}
