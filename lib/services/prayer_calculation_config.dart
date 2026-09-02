import 'package:adhan/adhan.dart';

/// Centralized offline configuration for all prayer-related calculations.
///
/// SettingsProvider
///       ↓
/// PrayerCalculationConfig
///       ↓
/// PrayerEngineService
///       ↓
/// adhan
class PrayerCalculationConfig {
  final CalculationMethod method;
  final Madhab madhab;

  const PrayerCalculationConfig({required this.method, required this.madhab});

  static const PrayerCalculationConfig defaults = PrayerCalculationConfig(
    method: CalculationMethod.karachi,
    madhab: Madhab.hanafi,
  );

  factory PrayerCalculationConfig.fromSettings({
    required String calculationMethod,
    required String madhhab,
  }) {
    return PrayerCalculationConfig(
      method: _parseCalculationMethod(calculationMethod),
      madhab: _parseMadhab(madhhab),
    );
  }

  static CalculationMethod _parseCalculationMethod(String value) {
    final String normalized = value.trim().toLowerCase();

    switch (normalized) {
      case 'karachi':
        return CalculationMethod.karachi;
      case 'muslim world league':
      case 'muslim_world_league':
      case 'mwl':
        return CalculationMethod.muslim_world_league;
      case 'egyptian':
      case 'egypt':
        return CalculationMethod.egyptian;
      case 'umm al qura':
      case 'umm al-qura':
      case 'umm_al_qura':
      case 'ummalqura':
        return CalculationMethod.umm_al_qura;
      case 'dubai':
        return CalculationMethod.dubai;
      case 'qatar':
        return CalculationMethod.qatar;
      case 'kuwait':
        return CalculationMethod.kuwait;
      case 'singapore':
        return CalculationMethod.singapore;
      case 'north america':
      case 'north_america':
      case 'isna':
        return CalculationMethod.north_america;
      case 'tehran':
        return CalculationMethod.tehran;
      case 'moon sighting committee':
      case 'moon_sighting_committee':
      case 'moonsighting committee':
      case 'moonsighting':
      case 'moonsighting_committee':
        return CalculationMethod.moon_sighting_committee;
      case 'turkey':
      case 'turkiye':
        return CalculationMethod.turkey;
      case 'other':
        return CalculationMethod.other;
      default:
        return CalculationMethod.karachi;
    }
  }

  static Madhab _parseMadhab(String value) {
    final String normalized = value.trim().toLowerCase();
    if (normalized == 'shafi' ||
        normalized == 'shafii' ||
        normalized == "shafi'i" ||
        normalized == 'shafi’i') {
      return Madhab.shafi;
    }
    return Madhab.hanafi;
  }
}
