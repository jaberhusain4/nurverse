import 'package:adhan/adhan.dart';

void main() {
  const coordinates = Coordinates(23.8486, 90.2500);
  final date = DateTime(2026, 9, 19);
  final params = CalculationMethod.karachi.getParameters()..madhab = Madhab.hanafi;
  final times = PrayerTimes(coordinates, DateComponents.from(date), params);
  print('localNow=' + DateTime.now().toString());
  print('tz=' + DateTime.now().timeZoneName + ' offset=' + DateTime.now().timeZoneOffset.toString());
  print('fajr=' + times.fajr.toIso8601String());
  print('sunrise=' + times.sunrise.toIso8601String());
  print('dhuhr=' + times.dhuhr.toIso8601String());
  print('asr=' + times.asr.toIso8601String());
  print('maghrib=' + times.maghrib.toIso8601String());
  print('isha=' + times.isha.toIso8601String());
}