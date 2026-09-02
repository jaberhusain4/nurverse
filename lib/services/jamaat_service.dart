import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for resolved Jamaat times.
///
/// Jamaat times start with fixed Dhaka reference defaults. Users can replace
/// each prayer independently with their local mosque's actual Jamaat time.
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

  static const Map<String, String> _dhakaDefaults = {
    'Fajr': '5:00 AM',
    'Dhuhr': '1:30 PM',
    'Asr': '5:15 PM',
    'Maghrib': '6:57 PM',
    'Isha': '8:45 PM',
  };

  static final Map<String, String> _jamaat = {..._dhakaDefaults};
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

    // Never let an old automatic-mode flag erase the Dhaka fallback.
    for (final prayer in prayers) {
      if (!_customPrayers.contains(prayer)) {
        _jamaat[prayer] = _dhakaDefaults[prayer]!;
      }
    }
    _initialized = true;
  }

  /// Retained only for backward compatibility. Jamaat is never calculated
  /// from prayer start times.
  static Future<void> setAutomaticMode(bool value) async {
    await initialize();
    _automaticMode = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modeKey, false);
    for (final prayer in prayers) {
      if (!_customPrayers.contains(prayer)) {
        _jamaat[prayer] = _dhakaDefaults[prayer]!;
      }
    }
  }

  static void configureDefaults(Map<String, DateTime> prayerTimes) {}
  static void configureDefaultsFromPrayerList(List<Map<String, dynamic>> prayerList) {}

  static String get(String prayer) => _jamaat[prayer] ?? '--:--';

  static String defaultTime(String prayer) => _dhakaDefaults[prayer] ?? '--:--';

  static bool isDhakaDefault(String prayer) =>
      get(prayer) == defaultTime(prayer) && !_customPrayers.contains(prayer);

  static bool isCustom(String prayer) => _customPrayers.contains(prayer);
  static Map<String, String> get all => Map.unmodifiable(_jamaat);

  static void setAll({
    required String fajr,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
  }) {
    _jamaat['Fajr'] = _normalizeTime(fajr);
    _jamaat['Dhuhr'] = _normalizeTime(dhuhr);
    _jamaat['Asr'] = _normalizeTime(asr);
    _jamaat['Maghrib'] = _normalizeTime(maghrib);
    _jamaat['Isha'] = _normalizeTime(isha);
    for (final prayer in prayers) {
      if (_jamaat[prayer] == '--:--') _jamaat[prayer] = _dhakaDefaults[prayer]!;
    }
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
    _jamaat[prayer] = _dhakaDefaults[prayer]!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_customPrefix$prayer');
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    _automaticMode = false;
    await prefs.setBool(_modeKey, false);
    for (final prayer in prayers) {
      _customPrayers.remove(prayer);
      _jamaat[prayer] = _dhakaDefaults[prayer]!;
      await prefs.remove('$_customPrefix$prayer');
    }
    for (final key in _legacyKeys.values) {
      await prefs.remove(key);
    }
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
