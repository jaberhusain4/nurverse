import 'package:adhan/adhan.dart';

void main() {
  const coordinates = Coordinates(23.8486, 90.25);
  final params = CalculationMethod.karachi.getParameters()
    ..madhab = Madhab.hanafi;

  final prayerTimes = PrayerTimes(
    coordinates,
    DateComponents(2026, 9, 19),
    params,
  );

  print('Savar 2026-09-19');
  print('Fajr=${prayerTimes.fajr}');
  print('Sunrise=${prayerTimes.sunrise}');
  print('Dhuhr=${prayerTimes.dhuhr}');
  print('Asr=${prayerTimes.asr}');
  print('Maghrib=${prayerTimes.maghrib}');
  print('Isha=${prayerTimes.isha}');
}
