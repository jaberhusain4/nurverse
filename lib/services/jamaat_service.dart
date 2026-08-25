import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for resolved Jamaat times.
///
/// Jamaat times are real user-configured values only. Prayer calculation times
/// must never be converted into synthetic Jamaat times because a calculated
/// salah start time is not the same thing as a mosque's Jamaat time.
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

  static const Map<String, String> _emptyValues = {
    'Fajr': '--:--',
    'Dhuhr': '--:--',
    'Asr': '--:--',
    'Maghrib': '--:--',
    'Isha': '--:--',
  };

  static final Map<String, String> _jamaat = {..._emptyValues};
  static final Set<String> _customPrayers = <String>{};
  static bool _initialized = false;
  static bool _automaticMode = false;

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
    _automaticMode = prefs.getBool(_modeKey) ?? false;

    // Migrate existing user-configured Jamaat values without creating any
    // synthetic/default times.
    if (!hasExplicitMode) {
      bool foundLegacyValue = false;

      for (final prayer in prayers) {
        final legacyKey = _legacyKeys[prayer]!;
        final legacyValue = prefs.getString(legacyKey);
        if (legacyValue == null || legacyValue.trim().isEmpty) continue;

        final normalized = _normalizeTime(prayer, legacyValue);
        _customPrayers.add(prayer);
        _jamaat[prayer] = normalized;
        await prefs.setString('$_customPrefix$prayer', normalized);
        foundLegacyValue = true;
      }

      // Existing legacy values are genuine user configuration, so preserve
      // them in manual mode. Otherwise start with no Jamaat data.
      _automaticMode = false;
      await prefs.setBool(_modeKey, false);
      if (!foundLegacyValue) {
        for (final prayer in prayers) {
          _jamaat[prayer] = '--:--';
        }
      }
    }

    for (final prayer in prayers) {
      final value = prefs.getString('$_customPrefix$prayer');
      if (value != null && value.trim().isNotEmpty) {
        _customPrayers.add(prayer);
        _jamaat[prayer] = _normalizeTime(prayer, value);
      }
    }

    _initialized = true;
  }

  /// Retains the setting for compatibility, but automatic Jamaat calculation
  /// intentionally does not invent mosque times from salah start times.
  static Future<void> setAutomaticMode(bool value) async {
    await initialize();
    _automaticMode = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modeKey, value);

    // Automatic mode has no synthetic timing source. Unconfigured prayers
    // therefore remain unavailable instead of displaying fabricated values.
    for (final prayer in prayers) {
      if (_customPrayers.contains(prayer)) {
        final saved = prefs.getString('$_customPrefix$prayer');
        _jamaat[prayer] = saved?.trim().isNotEmpty == true
            ? _normalizeTime(prayer, saved!)
            : '--:--';
      } else {
        _jamaat[prayer] = '--:--';
      }
    }
  }

  /// Kept as a compatibility method for PrayerController.
  ///
  /// Deliberately does nothing: calculated prayer times are not Jamaat times.
  static void configureDefaults(Map<String, DateTime> prayerTimes) {}

  static void configureDefaultsFromPrayerList(
    List<Map<String, dynamic>> prayerList,
  ) {}

  static String get(String prayer) => _jamaat[prayer] ?? '--:--';

  /// No calculated/default Jamaat time exists unless the user configured one.
  static String defaultTime(String prayer) => '--:--';

  static bool isCustom(String prayer) => _customPrayers.contains(prayer);

  static Map<String, String> get all => Map.unmodifiable(_jamaat);

  /// Compatibility bridge for the legacy SettingsProvider.
  static void setAll({
    required String fajr,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
  }) {
    if (_automaticMode) return;

    _jamaat['Fajr'] = _normalizeTime('Fajr', fajr);
    _jamaat['Dhuhr'] = _normalizeTime('Dhuhr', dhuhr);
    _jamaat['Asr'] = _normalizeTime('Asr', asr);
    _jamaat['Maghrib'] = _normalizeTime('Maghrib', maghrib);
    _jamaat['Isha'] = _normalizeTime('Isha', isha);
  }

  static Future<void> set(String prayer, String time) async {
    if (!prayers.contains(prayer)) return;

    final normalized = _normalizeTime(prayer, time);
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
    _jamaat[prayer] = '--:--';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_customPrefix$prayer');
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();

    _automaticMode = false;
    await prefs.setBool(_modeKey, false);

    for (final prayer in prayers) {
      _customPrayers.remove(prayer);
      _jamaat[prayer] = '--:--';
      await prefs.remove('$_customPrefix$prayer');
    }

    for (final key in _legacyKeys.values) {
      await prefs.remove(key);
    }
  }

  static String _normalizeTime(String prayer, String value) {
    final raw = value.trim();
    if (raw.isEmpty || raw == '--:--') return '--:--';

    final amPm = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
        .firstMatch(raw);
    if (amPm != null) {
      final hour = int.tryParse(amPm.group(1)!);
      final minute = int.tryParse(amPm.group(2)!);
      if (hour == null || minute == null || hour < 1 || hour > 12 || minute < 0 || minute > 59) {
        return '--:--';
      }
      return '$hour:${minute.toString().padLeft(2, '0')} ${amPm.group(3)!.toUpperCase()}';
    }

    final twentyFour = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw);
    if (twentyFour != null) {
      final hour = int.tryParse(twentyFour.group(1)!);
      final minute = int.tryParse(twentyFour.group(2)!);
      if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return '--:--';
      }
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    }

    return raw;
  }

  static String _formatTime(DateTime value) {
    return DateFormat('hh:mm a').format(value);
  }
}
