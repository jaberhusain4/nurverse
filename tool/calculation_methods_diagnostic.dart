import 'package:adhan/adhan.dart';

void main() {
  final coordinates = Coordinates(23.8486, 90.25);
  final methods = <String, CalculationMethod>{
    'Karachi': CalculationMethod.karachi,
    'MWL': CalculationMethod.muslim_world_league,
    'Egyptian': CalculationMethod.egyptian,
    'Umm Al Qura': CalculationMethod.umm_al_qura,
    'Dubai': CalculationMethod.dubai,
    'Qatar': CalculationMethod.qatar,
    'Kuwait': CalculationMethod.kuwait,
    'Singapore': CalculationMethod.singapore,
    'North America': CalculationMethod.north_america,
    'Turkey': CalculationMethod.turkey,
    'Tehran': CalculationMethod.tehran,
  };
  final date = DateComponents(2026, 9, 19);
  for (final entry in methods.entries) {
    final params = entry.value.getParameters()..madhab = Madhab.hanafi;
    final t = PrayerTimes(
      coordinates,
      date,
      params,
      utcOffset: const Duration(hours: 6),
    );
    print('${entry.key}: ${t.fajr.hour.toString().padLeft(2, '0')}:${t.fajr.minute.toString().padLeft(2, '0')}');
  }
}
