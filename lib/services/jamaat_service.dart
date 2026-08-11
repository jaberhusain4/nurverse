import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for resolved Jamaat times.
///
/// Automatic mode derives Jamaat from calculated prayer times using the
/// configured offsets. Manual mode uses user-defined times. Per-prayer custom
/// values are retained for backwards compatibility, but the global mode takes
/// precedence when set to automatic.
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

    _automaticMode = prefs.getBool(_modeKey) ?? true;

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
    _automaticMode = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modeKey, value);

    if (!_initialized) {
      await initialize();
    }

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
      } else if (_customPrayers.contains(prayer)) {
        // Keep the user's manual value untouched.
        continue;
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

  /// Compatibility bridge for SettingsProvider.
  ///
  /// This updates the in-memory resolved values without changing the global
  /// mode or creating custom persistence records.
  static void setAll({
    required String fajr,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
  }) {
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

    _jamaat[prayer] = normalized;
    _customPrayers.add(prayer);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_customPrefix$prayer', normalized);
  }

  static Future<void> useDefault(String prayer) async {
    if (!prayers.contains(prayer)) return;

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
