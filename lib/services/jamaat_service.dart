import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'prayer_calculation_config.dart';

/// Single source of truth for resolved Jamaat times.
///
/// Uncustomized Jamaat times are calculated from the daily Dhaka prayer times
/// instead of being fixed clock values. Users can replace each prayer
/// independently with their local mosque's actual Jamaat time.
class JamaatService {
  static const String _customPrefix = 'nurverse_jamaat_custom_';
  static const String _modeKey = 'nurverse_jamaat_mode';

  static const Map<String, String> _legacyKeys = {
    'Fajr': 'jamaat_fajr',
    'Dhuhr': 'jamaat_dhuhr',
    'Asr': 'jamaat_asr',
    'Maghrib': 'jamaat_maghrib',
    'Isha': 'jamaat_isha',
  };

  // Delay after the calculated Dhaka prayer start used as the reference
  // Jamaat. These are offsets, not hard-coded clock times.
  static const Map<String, Duration> _dhakaJamaatOffsets = {
    'Fajr': Duration(minutes: 20),
    'Dhuhr': Duration(minutes: 20),
    'Asr': Duration(minutes: 20),
    'Maghrib': Duration(minutes: 5),
    'Isha': Duration(minutes: 20),
  };

  static final Map<String, String> _jamaat = <String, String>{};
  static final Map<String, String> _dhakaDefaults = <String, String>{};
  static final Set<String> _customPrayers = <String>{};
  static bool _initialized = false;
  static bool _automaticMode = false;

  static const List<String> prayers = <String>[
    'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha',
  ];

  static bool get isAutomatic => _automaticMode;
  static bool get isManual => !_automaticMode;

  static Future<void> initialize() async {
    if (_initialized) return;

    _calculateDhakaDefaults(DateTime.now(), PrayerCalculationConfig.defaults);

    final prefs = await SharedPreferences.getInstance();
    final bool hasExplicitMode = prefs.containsKey(_modeKey);
    _automaticMode = prefs.getBool(_modeKey) ?? false;

    if (!hasExplicitMode) {
      for (final prayer in prayers) {
        final legacyValue = prefs.getString(_legacyKeys[prayer]!);
        if (legacyValue == null || legacyValue.trim().isEmpty) continue;
        final normalized = _normalizeTime(legacyValue);
        if (normalized == '--:--') continue;
        _customPrayers.add(prayer);
        _jamaat[prayer] = normalized;
        await prefs.setString('$_customPrefix$prayer', normalized);
      }
      _automaticMode = false;
      await prefs.setBool(_modeKey, false);
    }

    for (final prayer in prayers) {
      final value = prefs.getString('$_customPrefix$prayer');
      if (value != null && value.trim().isNotEmpty) {
        final normalized = _normalizeTime(value);
        if (normalized != '--:--') {
          _customPrayers.add(prayer);
          _jamaat[prayer] = normalized;
        }
      }
    }

    _applyDhakaDefaultsToUncustomized();
    _initialized = true;
  }

  /// Recalculates the Dhaka reference Jamaat times for the supplied date and
  /// prayer calculation settings. Custom mosque times are never overwritten.
  static void configureDhakaDefaults({
    required DateTime date,
    PrayerCalculationConfig config = PrayerCalculationConfig.defaults,
  }) {
    _calculateDhakaDefaults(date, config);
    _applyDhakaDefaultsToUncustomized();
  }

  /// Backward-compatible entry point used by existing callers. The reference
  /// location remains Dhaka rather than the user's current location.
  static void configureDefaults(Map<String, DateTime> prayerTimes) {
    final reference = prayerTimes['Fajr'] ?? prayerTimes['Dhuhr'] ?? DateTime.now();
    configureDhakaDefaults(date: reference, config: PrayerCalculationConfig.defaults);
  }

  static void configureDefaultsFromPrayerList(List<Map<String, dynamic>> prayerList) {
    DateTime? reference;
    for (final prayer in prayerList) {
      final dynamic value = prayer['time'] ?? prayer['start'] ?? prayer['prayerTime'];
      if (value is DateTime) {
        reference = value;
        break;
      }
    }
    configureDhakaDefaults(
      date: reference ?? DateTime.now(),
      config: PrayerCalculationConfig.defaults,
    );
  }

  static String get(String prayer) => _jamaat[prayer] ?? '--:--';

  static String defaultTime(String prayer) => _dhakaDefaults[prayer] ?? '--:--';

  static bool isDhakaDefault(String prayer) =>
      !_customPrayers.contains(prayer) && _jamaat[prayer] == _dhakaDefaults[prayer];

  static bool isCustom(String prayer) => _customPrayers.contains(prayer);
  static Map<String, String> get all => Map.unmodifiable(_jamaat);

  /// Compatibility bridge for SettingsProvider. Dynamic Dhaka defaults are
  /// preserved when the provider passes its old fixed fallback values.
  static void setAll({
    required String fajr,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
  }) {
    final values = <String, String>{
      'Fajr': fajr,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Maghrib': maghrib,
      'Isha': isha,
    };

    for (final prayer in prayers) {
      final normalized = _normalizeTime(values[prayer]!);
      if (normalized == '--:--') continue;
      if (!_customPrayers.contains(prayer)) continue;
      _jamaat[prayer] = normalized;
    }
    _applyDhakaDefaultsToUncustomized();
  }

  static Future<void> set(String prayer, String time) async {
    if (!prayers.contains(prayer)) return;
    final normalized = _normalizeTime(time);
    if (normalized == '--:--') return;
    await initialize();
    _automaticMode = false;
    _jamaat[prayer] = normalized;
    _customPrayers.add(prayer);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modeKey, false);
    await prefs.setString('$_customPrefix$prayer', normalized);
  }

  static Future<void> useDefault(String prayer) async {
    if (!prayers.contains(prayer)) return;
    await initialize();
    _customPrayers.remove(prayer);
    _jamaat[prayer] = _dhakaDefaults[prayer] ?? '--:--';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_customPrefix$prayer');
  }

  static Future<void> reset() async {
    await initialize();
    _automaticMode = false;
    configureDhakaDefaults(
      date: DateTime.now(),
      config: PrayerCalculationConfig.defaults,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modeKey, false);
    for (final prayer in prayers) {
      _customPrayers.remove(prayer);
      _jamaat[prayer] = _dhakaDefaults[prayer] ?? '--:--';
      await prefs.remove('$_customPrefix$prayer');
    }
    for (final key in _legacyKeys.values) {
      await prefs.remove(key);
    }
  }

  static void _calculateDhakaDefaults(
    DateTime date,
    PrayerCalculationConfig config,
  ) {
    const coordinates = Coordinates(23.8103, 90.4125);
    final params = config.method.getParameters()..madhab = config.madhab;
    final times = PrayerTimes(coordinates, DateComponents.from(date), params);

    final starts = <String, DateTime>{
      'Fajr': times.fajr,
      'Dhuhr': times.dhuhr,
      'Asr': times.asr,
      'Maghrib': times.maghrib,
      'Isha': times.isha,
    };

    _dhakaDefaults.clear();
    for (final prayer in prayers) {
      final start = starts[prayer];
      final offset = _dhakaJamaatOffsets[prayer];
      if (start == null || offset == null) continue;
      _dhakaDefaults[prayer] = _formatTime(start.add(offset));
    }
  }

  static void _applyDhakaDefaultsToUncustomized() {
    for (final prayer in prayers) {
      if (!_customPrayers.contains(prayer) && _dhakaDefaults.containsKey(prayer)) {
        _jamaat[prayer] = _dhakaDefaults[prayer]!;
      }
    }
  }

  static String _formatTime(DateTime value) {
    final hour = value.hour;
    final minute = value.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  static String _normalizeTime(String value) {
    final raw = value.trim();
    if (raw.isEmpty || raw == '--:--') return '--:--';
    final amPm = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false).firstMatch(raw);
    if (amPm != null) {
      final hour = int.tryParse(amPm.group(1)!);
      final minute = int.tryParse(amPm.group(2)!);
      if (hour == null || minute == null || hour < 1 || hour > 12 || minute < 0 || minute > 59) return '--:--';
      return '$hour:${minute.toString().padLeft(2, '0')} ${amPm.group(3)!.toUpperCase()}';
    }
    final twentyFour = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw);
    if (twentyFour != null) {
      final hour = int.tryParse(twentyFour.group(1)!);
      final minute = int.tryParse(twentyFour.group(2)!);
      if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) return '--:--';
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    }
    return '--:--';
  }
}
