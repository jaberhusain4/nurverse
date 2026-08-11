import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JamaatService {
  static const Map<String, int> _defaultOffsets = {
    'Fajr': 20,
    'Dhuhr': 20,
    'Asr': 20,
    'Maghrib': 10,
    'Isha': 20,
  };

  static const String _customPrefix = 'nurverse_jamaat_custom_';

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

  static const List<String> prayers = <String>[
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  static Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();

    for (final prayer in prayers) {
      final value = prefs.getString('$_customPrefix$prayer');
      if (value != null && value.isNotEmpty) {
        _customPrayers.add(prayer);
        _jamaat[prayer] = value;
      }
    }

    _initialized = true;
  }

  static void configureDefaults(Map<String, DateTime> prayerTimes) {
    for (final prayer in prayers) {
      final start = prayerTimes[prayer];
      if (start == null) continue;

      final offset = _defaultOffsets[prayer] ?? 20;
      _dynamicDefaults[prayer] = _formatTime(
        start.add(Duration(minutes: offset)),
      );

      if (!_customPrayers.contains(prayer)) {
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

  static String get(String prayer) => _jamaat[prayer] ?? '--:--';

  static String defaultTime(String prayer) =>
      _dynamicDefaults[prayer] ?? '--:--';

  static bool isCustom(String prayer) => _customPrayers.contains(prayer);

  static Map<String, String> get all => Map.unmodifiable(_jamaat);

  /// Compatibility bridge for SettingsProvider.
  ///
  /// SettingsProvider historically stored Jamaat values in one place while
  /// this service stores them in its own map. Keep this synchronous method so
  /// both layers can stay in sync without introducing an async dependency into
  /// provider initialization/reset flows.
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
