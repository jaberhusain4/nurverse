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

  // ==========================================================================
  // DEFAULT CONFIGURATION
  // ==========================================================================

  static const PrayerCalculationConfig defaults = PrayerCalculationConfig(
    method: CalculationMethod.karachi,
    madhab: Madhab.hanafi,
  );

  // ==========================================================================
  // FROM SETTINGS
  // ==========================================================================

  factory PrayerCalculationConfig.fromSettings({
    required String calculationMethod,
    required String madhhab,
  }) {
    return PrayerCalculationConfig(
      method: _parseCalculationMethod(calculationMethod),
      madhab: _parseMadhab(madhhab),
    );
  }

  // ==========================================================================
  // CALCULATION METHOD
  // ==========================================================================

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

  // ==========================================================================
  // MADHAB
  // ==========================================================================

  static Madhab _parseMadhab(String value) {
    final String normalized = value.trim().toLowerCase();

    switch (normalized) {
      case 'hanafi':
        return Madhab.hanafi;

      case 'shafi':
      case 'shafii':
      case 'shafi’i':
      case "shafi'i":
        return Madhab.shafi;

      case 'maliki':
        return Madhab.maliki;

      case 'hanbali':
        return Madhab.hanbali;

      case 'standard':
      case 'shafi_maliki_hanbali':
        return Madhab.shafi;

      default:
        return Madhab.hanafi;
    }
  }

  // ==========================================================================
  // DISPLAY VALUES
  // ==========================================================================

  String get methodId {
    switch (method) {
      case CalculationMethod.muslim_world_league:
        return 'Muslim World League';

      case CalculationMethod.egyptian:
        return 'Egyptian';

      case CalculationMethod.karachi:
        return 'Karachi';

      case CalculationMethod.umm_al_qura:
        return 'Umm Al-Qura';

      case CalculationMethod.dubai:
        return 'Dubai';

      case CalculationMethod.moon_sighting_committee:
        return 'Moon Sighting Committee';

      case CalculationMethod.north_america:
        return 'North America';

      case CalculationMethod.kuwait:
        return 'Kuwait';

      case CalculationMethod.qatar:
        return 'Qatar';

      case CalculationMethod.singapore:
        return 'Singapore';

      case CalculationMethod.turkey:
        return 'Turkey';

      case CalculationMethod.tehran:
        return 'Tehran';

      case CalculationMethod.other:
        return 'Other';
    }
  }

  String get madhhabId {
    switch (madhab) {
      case Madhab.hanafi:
        return 'Hanafi';
      case Madhab.shafi:
        return 'Shafi';
      case Madhab.maliki:
        return 'Maliki';
      case Madhab.hanbali:
        return 'Hanbali';
    }
  }

  // ==========================================================================
  // COPY
  // ==========================================================================

  PrayerCalculationConfig copyWith({
    CalculationMethod? method,
    Madhab? madhab,
  }) {
    return PrayerCalculationConfig(
      method: method ?? this.method,
      madhab: madhab ?? this.madhab,
    );
  }

  // ==========================================================================
  // EQUALITY
  // ==========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PrayerCalculationConfig &&
        other.method == method &&
        other.madhab == madhab;
  }

  @override
  int get hashCode => Object.hash(method, madhab);

  @override
  String toString() {
    return 'PrayerCalculationConfig('
        'method: $method, '
        'madhab: $madhab'
        ')';
  }
}
