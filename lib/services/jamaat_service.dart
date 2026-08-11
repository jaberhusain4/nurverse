import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for resolved Jamaat times.
///
/// Automatic mode derives Jamaat from calculated prayer times using the
/// configured offsets. Manual mode uses user-defined times. Per-prayer custom
/// values are retained for backwards compatibility, and legacy SettingsProvider
/// values are migrated without silently discarding an existing user's times.
class JamaatService {
  static const Map<String, int> _defaultOffsets = {
    'Fajr': 20,
    'Dhuhr': 20,
    'Asr': 20,
    'Maghrib': 10,
    'Isha': 20,
  };

  static const String _customPrefix = 'nurverse_jamaat_custom_';
  static const String _modeKey = 'nurverse_jamaat_mode';

  // Legacy SettingsProvider keys. These are read only during migration.
  static const Map<String, String> _legacyKeys = {
    'Fajr': 'jamaat_fajr',
    'Dhuhr': 'jamaat_dhuhr',
    'Asr': 'jamaat_asr',
    'Maghrib': 'jamaat_maghrib',
    'Isha': 'jamaat_isha',
  };

  static final Map<String, String> _dynamicDefaults = {
    'Fajr': '--:--',
    'Dhuhr': '--:--',
    'Asr': '--:--',
    'Maghrib': '--:--',
    'Isha': '--:--',
  };

  static final Map<String, String> _jamaat = {..._dynamicDefaults};
  static final Set<String> _customPrayers = <String>{};
  static bool _initialized = false;
  static bool _automaticMode = true;

  static const List<String> prayers = <String>[
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  static bool get isAutomatic => _automaticMode;
  static bool get isManual => !_automaticMode;

  static Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();

    final bool hasExplicitMode = prefs.containsKey(_modeKey);
    _automaticMode = prefs.getBool(_modeKey) ?? true;

    // ------------------------------------------------------------------------
    // MIGRATION
    // ------------------------------------------------------------------------
    // Older versions stored five Jamaat values directly in SettingsProvider.
    // If a user already had those values and no new global mode exists, keep
    // them by migrating them into the new manual source before proceeding.
    if (!hasExplicitMode) {
      bool foundLegacyValue = false;

      for (final prayer in prayers) {
        final legacyKey = _legacyKeys[prayer]!;
        final legacyValue = prefs.getString(legacyKey);

        if (legacyValue != null && legacyValue.trim().isNotEmpty) {
          final normalized = legacyValue.trim();
          _customPrayers.add(prayer);
          _jamaat[prayer] = normalized;
          await prefs.setString('$_customPrefix$prayer', normalized);
          foundLegacyValue = true;
        }
      }

      // Legacy Jamaat values represented user-defined times, so preserving
      // them means the migrated state must be manual rather than automatic.
      _automaticMode = !foundLegacyValue;
      await prefs.setBool(_modeKey, _automaticMode);
    }

    // Load current custom values. Migrated values are naturally picked up.
    for (final prayer in prayers) {
      final value = prefs.getString('$_customPrefix$prayer');
      if (value != null && value.isNotEmpty) {
        _customPrayers.add(prayer);
        _jamaat[prayer] = value;
      }
    }

    _initialized = true;
  }

  /// Enables or disables global automatic Jamaat calculation.
  ///
  /// Automatic mode does not delete manual values. Switching back to manual
  /// therefore restores the user's previously saved custom times.
  static Future<void> setAutomaticMode(bool value) async {
    await initialize();

    _automaticMode = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modeKey, value);

    if (_automaticMode) {
      for (final prayer in prayers) {
        final dynamicDefault = _dynamicDefaults[prayer];
        if (dynamicDefault != null) {
          _jamaat[prayer] = dynamicDefault;
        }
      }
    } else {
      for (final prayer in prayers) {
        if (_customPrayers.contains(prayer)) {
          final prefsValue = prefs.getString('$_customPrefix$prayer');
          if (prefsValue != null && prefsValue.isNotEmpty) {
            _jamaat[prayer] = prefsValue;
          }
        } else {
          _jamaat[prayer] = '--:--';
        }
      }
    }
  }

  static void configureDefaults(Map<String, DateTime> prayerTimes) {
    for (final prayer in prayers) {
      final start = prayerTimes[prayer];
      if (start == null) continue;

      final offset = _defaultOffsets[prayer] ?? 20;
      _dynamicDefaults[prayer] = _formatTime(
        start.add(Duration(minutes: offset)),
      );

      if (_automaticMode) {
        _jamaat[prayer] = _dynamicDefaults[prayer]!;
      }
    }
  }

  static void configureDefaultsFromPrayerList(
    List<Map<String, dynamic>> prayerList,
  ) {
    final times = <String, DateTime>{};
    final now = DateTime.now();

    for (final item in prayerList) {
      final name = item['name']?.toString();
      final start = item['start']?.toString();
      if (name == null || start == null) continue;

      final key = name == 'Jumuah' ? 'Dhuhr' : name;
      if (!prayers.contains(key)) continue;

      final parsed = _parseTime(start, now);
      if (parsed != null) times[key] = parsed;
    }

    if (times.isNotEmpty) configureDefaults(times);
  }

  /// Returns the currently resolved Jamaat time.
  static String get(String prayer) => _jamaat[prayer] ?? '--:--';

  /// Returns the automatically calculated Jamaat time, regardless of mode.
  static String defaultTime(String prayer) =>
      _dynamicDefaults[prayer] ?? '--:--';

  static bool isCustom(String prayer) => _customPrayers.contains(prayer);

  static Map<String, String> get all => Map.unmodifiable(_jamaat);

  /// Compatibility bridge for the legacy SettingsProvider.
  ///
  /// In automatic mode, calculated Jamaat remains authoritative, so legacy
  /// provider initialization must not overwrite it. In manual mode, this
  /// updates the resolved values for compatibility while the persisted custom
  /// records remain the source of truth.
  static void setAll({
    required String fajr,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
  }) {
    if (_automaticMode) return;

    _jamaat['Fajr'] = fajr;
    _jamaat['Dhuhr'] = dhuhr;
    _jamaat['Asr'] = asr;
    _jamaat['Maghrib'] = maghrib;
    _jamaat['Isha'] = isha;
  }

  static Future<void> set(String prayer, String time) async {
    if (!prayers.contains(prayer)) return;

    final normalized = time.trim();
    if (normalized.isEmpty) return;

    await initialize();

    _jamaat[prayer] = normalized;
    _customPrayers.add(prayer);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_customPrefix$prayer', normalized);
  }

  static Future<void> useDefault(String prayer) async {
    if (!prayers.contains(prayer)) return;

    await initialize();

    _customPrayers.remove(prayer);
    _jamaat[prayer] = _dynamicDefaults[prayer] ?? '--:--';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_customPrefix$prayer');
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();

    _automaticMode = true;
    await prefs.setBool(_modeKey, true);

    for (final prayer in prayers) {
      _customPrayers.remove(prayer);
      _jamaat[prayer] = _dynamicDefaults[prayer] ?? '--:--';
      await prefs.remove('$_customPrefix$prayer');
    }

    // Remove legacy values so a reset cannot be undone by a later migration.
    for (final key in _legacyKeys.values) {
      await prefs.remove(key);
    }
  }

  static String _formatTime(DateTime value) {
    return DateFormat('hh:mm a').format(value);
  }

  static DateTime? _parseTime(String value, DateTime base) {
    try {
      final parsed = DateFormat('hh:mm a').parseStrict(value.trim());
      return DateTime(
        base.year,
        base.month,
        base.day,
        parsed.hour,
        parsed.minute,
      );
    } catch (_) {
      return null;
    }
  }
}
