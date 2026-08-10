// lib/services/jamaat_service.dart

class JamaatService {
  // ==========================================================================
  // DEFAULT JAMAAT TIMES
  // ==========================================================================

  static const Map<String, String> _defaultJamaat = {
    'Fajr': '05:00 AM',
    'Dhuhr': '01:30 PM',
    'Asr': '05:15 PM',
    'Maghrib': '06:57 PM',
    'Isha': '08:45 PM',
  };

  // ==========================================================================
  // CURRENT JAMAAT TIMES
  // ==========================================================================

  static final Map<String, String> _jamaat = {..._defaultJamaat};

  // ==========================================================================
  // GET
  // ==========================================================================

  static String get(String prayer) {
    return _jamaat[prayer] ?? '--:--';
  }

  // ==========================================================================
  // SET
  // ==========================================================================

  static void set(String prayer, String time) {
    if (!_jamaat.containsKey(prayer)) {
      return;
    }

    final normalizedTime = time.trim();

    if (normalizedTime.isEmpty) {
      return;
    }

    _jamaat[prayer] = normalizedTime;
  }

  // ==========================================================================
  // SET ALL
  // ==========================================================================

  static void setAll({
    required String fajr,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
  }) {
    set('Fajr', fajr);
    set('Dhuhr', dhuhr);
    set('Asr', asr);
    set('Maghrib', maghrib);
    set('Isha', isha);
  }

  // ==========================================================================
  // RESET
  // ==========================================================================

  static void reset() {
    _jamaat
      ..clear()
      ..addAll(_defaultJamaat);
  }

  // ==========================================================================
  // DEFAULT VALUE
  // ==========================================================================

  static String defaultTime(String prayer) {
    return _defaultJamaat[prayer] ?? '--:--';
  }

  // ==========================================================================
  // ALL TIMES
  // ==========================================================================

  static Map<String, String> get all {
    return Map.unmodifiable(_jamaat);
  }
}
