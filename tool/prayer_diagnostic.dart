import 'package:adhan/adhan.dart';

void main() {
  final coordinates = Coordinates(23.8486, 90.2500);
  final date = DateTime(2026, 9, 19);
  final params = CalculationMethod.karachi.getParameters()..madhab = Madhab.hanafi;
  final times = PrayerTimes(coordinates, DateComponents.from(date), params);
  print('fajr=' + times.fajr.toString());
  print('sunrise=' + times.sunrise.toString());
  print('dhuhr=' + times.dhuhr.toString());
  print('asr=' + times.asr.toString());
  print('maghrib=' + times.maghrib.toString());
  print('isha=' + times.isha.toString());
}