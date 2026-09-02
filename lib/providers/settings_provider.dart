import 'dart:convert';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/jamaat_service.dart';
import '../services/prayer_calculation_config.dart';

class SettingsProvider extends ChangeNotifier {
  // ==========================================================================
  // SHARED PREFERENCES KEYS
  // ==========================================================================

  static const String _themeModeKey = 'theme_mode';
  static const String _amoledModeKey = 'amoled_mode';
  static const String _languageKey = 'app_language';

  static const String _calculationMethodKey = 'calculation_method';
  static const String _madhabKey = 'madhab';

  static const String _quranFontSizeKey = 'quran_font_size';
  static const String _translationFontSizeKey = 'translation_font_size';

  static const String _adhanNotificationKey = 'adhan_notification_enabled';

  static const String _locationModeKey = 'location_mode';
  static const String _autoLocationKey = 'auto_location';

  static const String _hijriAdjustmentKey = 'hijri_adjustment';

  static const String _showSecondsKey = 'show_seconds';
  static const String _vibrationKey = 'vibration_enabled';

  static const String _quranTranslationKey = 'quran_translation';
  static const String _quranArabicFontKey = 'quran_arabic_font';
  static const String _autoPlayNextKey = 'auto_play_next';
  static const String _downloadWifiOnlyKey = 'download_wifi_only';

  static const String _notificationSoundKey = 'notification_sound';
  static const String _prayerReminderMinutesKey = 'prayer_reminder_minutes';
  static const String _prayerAdjustmentsKey = 'prayer_adjustments';
  static const String _dailyAyahKey = 'daily_content_ayah';
  static const String _dailyHadithKey = 'daily_content_hadith';
  static const String _dailyDuaKey = 'daily_content_dua';
  static const String _dateDisplayPreferenceKey = 'date_display_preference';

  static const Map<String, int> _defaultPrayerAdjustments = <String, int>{
    'Fajr': 0,
    'Dhuhr': 0,
    'Asr': 0,
    'Maghrib': 0,
    'Isha': 0,
  };

  // ==========================================================================
  // JAMAAT KEYS
  // ==========================================================================

  static const String _fajrJamaatKey = 'jamaat_fajr';
  static const String _dhuhrJamaatKey = 'jamaat_dhuhr';
  static const String _asrJamaatKey = 'jamaat_asr';
  static const String _maghribJamaatKey = 'jamaat_maghrib';
  static const String _ishaJamaatKey = 'jamaat_isha';

  // ==========================================================================
  // PRAYER CALCULATION OPTIONS
  // ==========================================================================

  static const List<String> calculationMethods = [
    'Karachi',
    'Muslim World League',
    'Egyptian',
    'Umm Al Qura',
    'Dubai',
    'Qatar',
    'Kuwait',
    'Singapore',
    'North America',
    'Moonsighting Committee',
  ];

  static const List<String> madhabs = ['Hanafi', 'Shafi', 'Maliki', 'Hanbali'];

  // ==========================================================================
  // DEFAULTS
  // ==========================================================================

  ThemeMode _themeMode = ThemeMode.system;

  bool _isAmoledMode = false;

  String _languageCode = 'bn';

  String _calculationMethod = 'Karachi';

  String _madhab = 'Hanafi';

  double _quranFontSize = 24.0;

  double _translationFontSize = 14.0;

  bool _isAdhanNotificationEnabled = true;

  String _locationMode = 'automatic';

  bool _autoLocation = true;

  int _hijriAdjustment = 0;

  bool _showSeconds = false;

  bool _vibrationEnabled = true;

  String _quranTranslation = 'Bangla';

  String _quranArabicFont = 'Default';

  bool _autoPlayNext = false;

  bool _downloadWifiOnly = true;

  String _notificationSound = 'Default';

  int _prayerReminderMinutes = 0;

  Map<String, int> _prayerAdjustments = Map<String, int>.from(
    _defaultPrayerAdjustments,
  );

  bool _showDailyAyah = true;
  bool _showDailyHadith = true;
  bool _showDailyDua = true;
  String _dateDisplayPreference = 'both';

  // ==========================================================================
  // JAMAAT DEFAULTS
  // ==========================================================================

  String _fajrJamaat = '5:00';

  String _dhuhrJamaat = '1:30';

  String _asrJamaat = '5:15';

  String _maghribJamaat = '6:57';

  String _ishaJamaat = '8:45';

  bool _isLoading = true;

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  ThemeMode get themeMode => _themeMode;

  bool get isAmoledMode => _isAmoledMode;

  String get languageCode => _languageCode;

  Locale get locale => Locale(_languageCode);

  bool get isBangla => _languageCode == 'bn';

  bool get isEnglish => _languageCode == 'en';

  bool get isArabic => _languageCode == 'ar';

  String get calculationMethod => _calculationMethod;

  String get madhhab => _madhab;

  String get madhab => _madhab;

  double get quranFontSize => _quranFontSize;

  double get translationFontSize => _translationFontSize;

  bool get isAdhanNotificationEnabled => _isAdhanNotificationEnabled;

  String get locationMode => _locationMode;

  bool get autoLocation => _autoLocation;

  int get hijriAdjustment => _hijriAdjustment;

  bool get showSeconds => _showSeconds;

  bool get vibrationEnabled => _vibrationEnabled;

  String get quranTranslation => _quranTranslation;

  String get quranArabicFont => _quranArabicFont;

  bool get autoPlayNext => _autoPlayNext;

  bool get downloadWifiOnly => _downloadWifiOnly;

  String get notificationSound => _notificationSound;

  int get prayerReminderMinutes => _prayerReminderMinutes;

  Map<String, int> get prayerAdjustments => Map.unmodifiable(_prayerAdjustments);

  bool get showDailyAyah => _showDailyAyah;

  bool get showDailyHadith => _showDailyHadith;

  bool get showDailyDua => _showDailyDua;

  String get dateDisplayPreference => _dateDisplayPreference;

  bool get isLoading => _isLoading;

  // ==========================================================================
  // RESOLVED PRAYER CONFIGURATION
  // ==========================================================================

  PrayerCalculationConfig get prayerCalculationConfig {
    return PrayerCalculationConfig.fromSettings(
      calculationMethod: _calculationMethod,
      madhhab: _madhab,
    );
  }

  CalculationMethod get prayerCalculationMethod {
    return prayerCalculationConfig.method;
  }

  Madhab get prayerMadhab {
    return prayerCalculationConfig.madhab;
  }

  // ==========================================================================
  // JAMAAT GETTERS
  // ==========================================================================

  String get fajrJamaat => _fajrJamaat;

  String get dhuhrJamaat => _dhuhrJamaat;

  String get asrJamaat => _asrJamaat;

  String get maghribJamaat => _maghribJamaat;

  String get ishaJamaat => _ishaJamaat;

  String getJamaat(String prayer) {
    switch (prayer.trim()) {
      case 'Fajr':
        return _fajrJamaat;

      case 'Dhuhr':
        return _dhuhrJamaat;

      case 'Asr':
        return _asrJamaat;

      case 'Maghrib':
        return _maghribJamaat;

      case 'Isha':
        return _ishaJamaat;

      default:
        return '--:--';
    }
  }

  // ==========================================================================
  // ALL JAMAAT TIMES
  // ==========================================================================

  Map<String, String> get jamaatTimes {
    return {
      'Fajr': _fajrJamaat,
      'Dhuhr': _dhuhrJamaat,
      'Asr': _asrJamaat,
      'Maghrib': _maghribJamaat,
      'Isha': _ishaJamaat,
    };
  }

  // ==========================================================================
  // THEME ID
  // ==========================================================================

  String get themeId {
    if (_isAmoledMode) {
      return 'amoled';
    }

    switch (_themeMode) {
      case ThemeMode.light:
        return 'light';

      case ThemeMode.dark:
        return 'dark';

      case ThemeMode.system:
        return 'system';
    }
  }

  // ==========================================================================
  // CONSTRUCTOR
  // ==========================================================================

  SettingsProvider() {
    _loadSettings();
  }

  // ==========================================================================
  // LOAD SETTINGS
  // ==========================================================================

  Future<void> _loadSettings() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // ----------------------------------------------------------------------
      // THEME
      // ----------------------------------------------------------------------

      final String? savedThemeMode = prefs.getString(_themeModeKey);

      switch (savedThemeMode) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;

        case 'dark':
          _themeMode = ThemeMode.dark;
          break;

        case 'system':
        default:
          _themeMode = ThemeMode.system;
          break;
      }

      _isAmoledMode = prefs.getBool(_amoledModeKey) ?? false;

      if (_isAmoledMode) {
        _themeMode = ThemeMode.dark;
      }

      // ----------------------------------------------------------------------
      // LANGUAGE
      // ----------------------------------------------------------------------

      final String? savedLanguage = prefs.getString(_languageKey);

      if (savedLanguage == 'en') {
        _languageCode = 'en';
      } else if (savedLanguage == 'ar') {
        _languageCode = 'ar';
      } else {
        _languageCode = 'bn';
      }

      // ----------------------------------------------------------------------
      // PRAYER CALCULATION
      // ----------------------------------------------------------------------

      final String savedCalculationMethod =
          prefs.getString(_calculationMethodKey) ?? 'Karachi';

      _calculationMethod = _normalizeCalculationMethod(savedCalculationMethod);

      final String savedMadhab = prefs.getString(_madhabKey) ?? 'Hanafi';

      _madhab = _normalizeMadhab(savedMadhab);

      // ----------------------------------------------------------------------
      // QURAN
      // ----------------------------------------------------------------------

      _quranFontSize = prefs.getDouble(_quranFontSizeKey) ?? 24.0;

      _translationFontSize = prefs.getDouble(_translationFontSizeKey) ?? 14.0;

      // ----------------------------------------------------------------------
      // ADHAN
      // ----------------------------------------------------------------------

      _isAdhanNotificationEnabled =
          prefs.getBool(_adhanNotificationKey) ?? true;

      // ----------------------------------------------------------------------
      // LOCATION
      // ----------------------------------------------------------------------

      _locationMode = prefs.getString(_locationModeKey) ?? 'automatic';

      _autoLocation = prefs.getBool(_autoLocationKey) ?? true;

      // ----------------------------------------------------------------------
      // HIJRI
      // ----------------------------------------------------------------------

      _hijriAdjustment = prefs.getInt(_hijriAdjustmentKey) ?? 0;

      // ----------------------------------------------------------------------
      // DISPLAY
      // ----------------------------------------------------------------------

      _showSeconds = prefs.getBool(_showSecondsKey) ?? false;

      _vibrationEnabled = prefs.getBool(_vibrationKey) ?? true;

      // ----------------------------------------------------------------------
      // QURAN SETTINGS
      // ----------------------------------------------------------------------

      _quranTranslation = prefs.getString(_quranTranslationKey) ?? 'Bangla';

      _quranArabicFont = prefs.getString(_quranArabicFontKey) ?? 'Default';

      _autoPlayNext = prefs.getBool(_autoPlayNextKey) ?? false;

      _downloadWifiOnly = prefs.getBool(_downloadWifiOnlyKey) ?? true;

      // ----------------------------------------------------------------------
      // NOTIFICATION
      // ----------------------------------------------------------------------

      _notificationSound = prefs.getString(_notificationSoundKey) ?? 'Default';

      _prayerReminderMinutes = prefs.getInt(_prayerReminderMinutesKey) ?? 0;

      _showDailyAyah = prefs.getBool(_dailyAyahKey) ?? true;
      _showDailyHadith = prefs.getBool(_dailyHadithKey) ?? true;
      _showDailyDua = prefs.getBool(_dailyDuaKey) ?? true;
      _dateDisplayPreference = _normalizeDateDisplayPreference(
        prefs.getString(_dateDisplayPreferenceKey) ?? 'both',
      );

      final String? savedPrayerAdjustments = prefs.getString(_prayerAdjustmentsKey);

      if (savedPrayerAdjustments != null) {
        try {
          final dynamic decoded = jsonDecode(savedPrayerAdjustments);

          if (decoded is Map) {
            final Map<String, int> parsedAdjustments = <String, int>{};

            for (final entry in decoded.entries) {
              if (entry.key is! String) {
                continue;
              }

              final String prayer = entry.key.toString();

              if (!_defaultPrayerAdjustments.containsKey(prayer)) {
                continue;
              }

              final int? value = entry.value is int
                  ? entry.value as int
                  : int.tryParse(entry.value.toString());

              parsedAdjustments[prayer] = value?.clamp(-60, 60) ?? 0;
            }

            if (parsedAdjustments.isNotEmpty) {
              _prayerAdjustments = parsedAdjustments;
            }
          }
        } catch (_) {
          _prayerAdjustments = Map<String, int>.from(_defaultPrayerAdjustments);
        }
      }

      // ----------------------------------------------------------------------
      // JAMAAT
      // ----------------------------------------------------------------------

      _fajrJamaat = _normalizeJamaatTime(
        prefs.getString(_fajrJamaatKey) ?? '5:00',
        fallback: '5:00',
      );

      _dhuhrJamaat = _normalizeJamaatTime(
        prefs.getString(_dhuhrJamaatKey) ?? '1:30',
        fallback: '1:30',
      );

      _asrJamaat = _normalizeJamaatTime(
        prefs.getString(_asrJamaatKey) ?? '5:15',
        fallback: '5:15',
      );

      _maghribJamaat = _normalizeJamaatTime(
        prefs.getString(_maghribJamaatKey) ?? '6:57',
        fallback: '6:57',
      );

      _ishaJamaat = _normalizeJamaatTime(
        prefs.getString(_ishaJamaatKey) ?? '8:45',
        fallback: '8:45',
      );

      // ----------------------------------------------------------------------
      // SYNC JAMAAT SERVICE
      // ----------------------------------------------------------------------

      JamaatService.setAll(
        fajr: _fajrJamaat,
        dhuhr: _dhuhrJamaat,
        asr: _asrJamaat,
        maghrib: _maghribJamaat,
        isha: _ishaJamaat,
      );
    } catch (_) {
      // Safe in-memory defaults remain active.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================================================
  // THEME
  // ==========================================================================

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode != ThemeMode.dark) {
      _isAmoledMode = false;
    }

    _themeMode = mode;

    notifyListeners();

    await _persistTheme();
  }

  Future<void> setSystemTheme() async {
    _isAmoledMode = false;
    _themeMode = ThemeMode.system;

    notifyListeners();

    await _persistTheme();
  }

  Future<void> setLightTheme() async {
    _isAmoledMode = false;
    _themeMode = ThemeMode.light;

    notifyListeners();

    await _persistTheme();
  }

  Future<void> setDarkTheme() async {
    _isAmoledMode = false;
    _themeMode = ThemeMode.dark;

    notifyListeners();

    await _persistTheme();
  }

  Future<void> setAmoledTheme() async {
    _isAmoledMode = true;
    _themeMode = ThemeMode.dark;

    notifyListeners();

    await _persistTheme();
  }

  Future<void> toggleAmoledMode(bool value) async {
    if (value) {
      await setAmoledTheme();
      return;
    }

    _isAmoledMode = false;
    _themeMode = ThemeMode.dark;

    notifyListeners();

    await _persistTheme();
  }

  Future<void> _persistTheme() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(_themeModeKey, _themeModeToString(_themeMode));

      await prefs.setBool(_amoledModeKey, _isAmoledMode);
    } catch (_) {}
  }

  // ==========================================================================
  // LANGUAGE
  // ==========================================================================

  Future<void> setLanguage(String code) async {
    final String normalizedCode = code.toLowerCase().trim();

    if (normalizedCode != 'bn' && normalizedCode != 'en' && normalizedCode != 'ar') {
      return;
    }

    if (_languageCode == normalizedCode) {
      return;
    }

    _languageCode = normalizedCode;

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(_languageKey, normalizedCode);
    } catch (_) {}
  }

  Future<void> setBangla() async {
    await setLanguage('bn');
  }

  Future<void> setEnglish() async {
    await setLanguage('en');
  }

  Future<void> setArabic() async {
    await setLanguage('ar');
  }

  // ==========================================================================
  // PRAYER CALCULATION METHOD
  // ==========================================================================

  Future<void> setCalculationMethod(String method) async {
    final String normalizedMethod = _normalizeCalculationMethod(method);

    if (_calculationMethod == normalizedMethod) {
      return;
    }

    _calculationMethod = normalizedMethod;

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(_calculationMethodKey, normalizedMethod);
    } catch (_) {}
  }

  // ==========================================================================
  // MADHAB
  // ==========================================================================

  Future<void> setMadhhab(String madhhab) async {
    final String normalizedMadhab = _normalizeMadhab(madhhab);

    if (_madhab == normalizedMadhab) {
      return;
    }

    _madhab = normalizedMadhab;

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(_madhabKey, normalizedMadhab);
    } catch (_) {}
  }

  Future<void> setMadhab(String madhab) async {
    await setMadhhab(madhab);
  }

  // ==========================================================================
  // QURAN FONT
  // ==========================================================================

  Future<void> updateQuranFontSize(double size) async {
    _quranFontSize = size.clamp(14.0, 50.0).toDouble();

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setDouble(_quranFontSizeKey, _quranFontSize);
    } catch (_) {}
  }

  Future<void> updateTranslationFontSize(double size) async {
    _translationFontSize = size.clamp(10.0, 30.0).toDouble();

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setDouble(_translationFontSizeKey, _translationFontSize);
    } catch (_) {}
  }

  // ==========================================================================
  // ADHAN
  // ==========================================================================

  Future<void> toggleAdhanNotification(bool value) async {
    if (_isAdhanNotificationEnabled == value) {
      return;
    }

    _isAdhanNotificationEnabled = value;

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_adhanNotificationKey, value);
    } catch (_) {}
  }

  // ==========================================================================
  // LOCATION
  // ==========================================================================

  Future<void> setLocationMode(String mode) async {
    if (mode != 'automatic' && mode != 'manual') {
      return;
    }

    _locationMode = mode;
    _autoLocation = mode == 'automatic';

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(_locationModeKey, mode);

      await prefs.setBool(_autoLocationKey, _autoLocation);
    } catch (_) {}
  }

  Future<void> setAutoLocation(bool value) async {
    _autoLocation = value;

    _locationMode = value ? 'automatic' : 'manual';

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_autoLocationKey, value);

      await prefs.setString(_locationModeKey, _locationMode);
    } catch (_) {}
  }

  // ==========================================================================
  // HIJRI ADJUSTMENT
  // ==========================================================================

  Future<void> setHijriAdjustment(int value) async {
    _hijriAdjustment = value.clamp(-2, 2);

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setInt(_hijriAdjustmentKey, _hijriAdjustment);
    } catch (_) {}
  }

  // ==========================================================================
  // DISPLAY
  // ==========================================================================

  Future<void> toggleShowSeconds(bool value) async {
    _showSeconds = value;

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_showSecondsKey, value);
    } catch (_) {}
  }

  Future<void> toggleVibration(bool value) async {
    _vibrationEnabled = value;
 
    notifyListeners();
 
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
 
      await prefs.setBool(_vibrationKey, value);
    } catch (_) {}
  }
 
  Future<void> setDailyContentPreferences({
    bool? ayah,
    bool? hadith,
    bool? dua,
  }) async {
    if (ayah != null) {
      _showDailyAyah = ayah;
    }
 
    if (hadith != null) {
      _showDailyHadith = hadith;
    }
 
    if (dua != null) {
      _showDailyDua = dua;
    }
 
    notifyListeners();
 
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
 
      if (ayah != null) {
        await prefs.setBool(_dailyAyahKey, _showDailyAyah);
      }
 
      if (hadith != null) {
        await prefs.setBool(_dailyHadithKey, _showDailyHadith);
      }
 
      if (dua != null) {
        await prefs.setBool(_dailyDuaKey, _showDailyDua);
      }
    } catch (_) {}
  }
 
  Future<void> setDateDisplayPreference(String value) async {
    final String normalizedValue = _normalizeDateDisplayPreference(value);
 
    if (_dateDisplayPreference == normalizedValue) {
      return;
    }
 
    _dateDisplayPreference = normalizedValue;
 
    notifyListeners();
 
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
 
      await prefs.setString(_dateDisplayPreferenceKey, normalizedValue);
    } catch (_) {}
  }
 
  // ==========================================================================
  // QURAN SETTINGS
  // ==========================================================================

  Future<void> setQuranTranslation(String value) async {
    if (value.trim().isEmpty) {
      return;
    }

    _quranTranslation = value;

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(_quranTranslationKey, value);
    } catch (_) {}
  }

  Future<void> setQuranArabicFont(String value) async {
    if (value.trim().isEmpty) {
      return;
    }

    _quranArabicFont = value;

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(_quranArabicFontKey, value);
    } catch (_) {}
  }

  Future<void> toggleAutoPlayNext(bool value) async {
    _autoPlayNext = value;

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_autoPlayNextKey, value);
    } catch (_) {}
  }

  Future<void> toggleDownloadWifiOnly(bool value) async {
    _downloadWifiOnly = value;

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_downloadWifiOnlyKey, value);
    } catch (_) {}
  }

  // ==========================================================================
  // NOTIFICATIONS
  // ==========================================================================

  Future<void> setNotificationSound(String value) async {
    if (value.trim().isEmpty) {
      return;
    }

    _notificationSound = value;

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(_notificationSoundKey, value);
    } catch (_) {}
  }

  Future<void> setPrayerReminderMinutes(int value) async {
    _prayerReminderMinutes = value.clamp(0, 60);
 
    notifyListeners();
 
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
 
      await prefs.setInt(_prayerReminderMinutesKey, _prayerReminderMinutes);
    } catch (_) {}
  }
 
  Future<void> setPrayerAdjustment(String prayer, int value) async {
    final String normalizedPrayer = prayer.trim();
 
    if (!_defaultPrayerAdjustments.containsKey(normalizedPrayer)) {
      return;
    }
 
    _prayerAdjustments[normalizedPrayer] = value.clamp(-60, 60);
 
    notifyListeners();
 
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
 
      await prefs.setString(_prayerAdjustmentsKey, jsonEncode(_prayerAdjustments));
    } catch (_) {}
  }
 
  Future<void> resetPrayerAdjustments() async {
    _prayerAdjustments = Map<String, int>.from(_defaultPrayerAdjustments);
 
    notifyListeners();
 
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
 
      await prefs.remove(_prayerAdjustmentsKey);
    } catch (_) {}
  }
 
  // ==========================================================================
  // JAMAAT
  // ==========================================================================

  Future<bool> setJamaatTime(String prayer, String time) async {
    final String normalizedPrayer = prayer.trim();

    final String normalizedTime = _normalizeJamaatTime(time);

    if (normalizedTime.isEmpty) {
      return false;
    }

    switch (normalizedPrayer) {
      case 'Fajr':
        _fajrJamaat = normalizedTime;
        break;

      case 'Dhuhr':
        _dhuhrJamaat = normalizedTime;
        break;

      case 'Asr':
        _asrJamaat = normalizedTime;
        break;

      case 'Maghrib':
        _maghribJamaat = normalizedTime;
        break;

      case 'Isha':
        _ishaJamaat = normalizedTime;
        break;

      default:
        return false;
    }

    // Runtime update immediately.
    JamaatService.set(normalizedPrayer, normalizedTime);

    // UI update immediately.
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      switch (normalizedPrayer) {
        case 'Fajr':
          await prefs.setString(_fajrJamaatKey, _fajrJamaat);
          break;

        case 'Dhuhr':
          await prefs.setString(_dhuhrJamaatKey, _dhuhrJamaat);
          break;

        case 'Asr':
          await prefs.setString(_asrJamaatKey, _asrJamaat);
          break;

        case 'Maghrib':
          await prefs.setString(_maghribJamaatKey, _maghribJamaat);
          break;

        case 'Isha':
          await prefs.setString(_ishaJamaatKey, _ishaJamaat);
          break;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  // ==========================================================================
  // RESET JAMAAT
  // ==========================================================================

  Future<void> resetJamaatTimes() async {
    _fajrJamaat = '5:00';
    _dhuhrJamaat = '1:30';
    _asrJamaat = '5:15';
    _maghribJamaat = '6:57';
    _ishaJamaat = '8:45';

    JamaatService.setAll(
      fajr: _fajrJamaat,
      dhuhr: _dhuhrJamaat,
      asr: _asrJamaat,
      maghrib: _maghribJamaat,
      isha: _ishaJamaat,
    );

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.remove(_fajrJamaatKey);
      await prefs.remove(_dhuhrJamaatKey);
      await prefs.remove(_asrJamaatKey);
      await prefs.remove(_maghribJamaatKey);
      await prefs.remove(_ishaJamaatKey);
    } catch (_) {}
  }

  // ==========================================================================
  // RESET ALL SETTINGS
  // ==========================================================================

  Future<void> resetSettings() async {
    _themeMode = ThemeMode.system;
    _isAmoledMode = false;

    _languageCode = 'bn';

    _calculationMethod = 'Karachi';
    _madhab = 'Hanafi';

    _quranFontSize = 24.0;
    _translationFontSize = 14.0;

    _isAdhanNotificationEnabled = true;

    _locationMode = 'automatic';
    _autoLocation = true;

    _hijriAdjustment = 0;

    _showSeconds = false;
    _vibrationEnabled = true;

    _quranTranslation = 'Bangla';
    _quranArabicFont = 'Default';

    _autoPlayNext = false;
    _downloadWifiOnly = true;

    _notificationSound = 'Default';
    _prayerReminderMinutes = 0;
    _prayerAdjustments = Map<String, int>.from(_defaultPrayerAdjustments);
    _showDailyAyah = true;
    _showDailyHadith = true;
    _showDailyDua = true;
    _dateDisplayPreference = 'both';

    // ------------------------------------------------------------------------
    // RESET JAMAAT
    // ------------------------------------------------------------------------

    _fajrJamaat = '5:00';
    _dhuhrJamaat = '1:30';
    _asrJamaat = '5:15';
    _maghribJamaat = '6:57';
    _ishaJamaat = '8:45';

    JamaatService.setAll(
      fajr: _fajrJamaat,
      dhuhr: _dhuhrJamaat,
      asr: _asrJamaat,
      maghrib: _maghribJamaat,
      isha: _ishaJamaat,
    );

    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final List<String> keys = [
        _themeModeKey,
        _amoledModeKey,
        _languageKey,
        _calculationMethodKey,
        _madhabKey,
        _quranFontSizeKey,
        _translationFontSizeKey,
        _adhanNotificationKey,
        _locationModeKey,
        _autoLocationKey,
        _hijriAdjustmentKey,
        _showSecondsKey,
        _vibrationKey,
        _quranTranslationKey,
        _quranArabicFontKey,
        _autoPlayNextKey,
        _downloadWifiOnlyKey,
        _notificationSoundKey,
        _prayerReminderMinutesKey,
        _prayerAdjustmentsKey,
        _dailyAyahKey,
        _dailyHadithKey,
        _dailyDuaKey,
        _dateDisplayPreferenceKey,
        _fajrJamaatKey,
        _dhuhrJamaatKey,
        _asrJamaatKey,
        _maghribJamaatKey,
        _ishaJamaatKey,
      ];

      for (final String key in keys) {
        await prefs.remove(key);
      }
    } catch (_) {}
  }

  // ==========================================================================
  // JAMAAT TIME NORMALIZATION
  // ==========================================================================

  String _normalizeDateDisplayPreference(String value) {
    switch (value.trim().toLowerCase()) {
      case 'hijri':
        return 'hijri';
      case 'gregorian':
        return 'gregorian';
      default:
        return 'both';
    }
  }

  String _normalizeJamaatTime(String value, {String? fallback}) {
    String input = value.trim();

    if (input.isEmpty) {
      return fallback ?? '';
    }

    // ------------------------------------------------------------------------
    // Support old saved values:
    //
    // 05:00 AM
    // 01:30 PM
    // 08:45 PM
    //
    // Convert to:
    //
    // 5:00
    // 1:30
    // 8:45
    // ------------------------------------------------------------------------

    final RegExp amPmPattern = RegExp(
      r'^(\d{1,2})\s*:\s*(\d{2})\s*([AaPp][Mm])$',
    );

    final Match? amPmMatch = amPmPattern.firstMatch(input);

    if (amPmMatch != null) {
      int hour = int.parse(amPmMatch.group(1)!);

      final int minute = int.parse(amPmMatch.group(2)!);

      final String period = amPmMatch.group(3)!.toUpperCase();

      if (hour < 1 || hour > 12 || minute < 0 || minute > 59) {
        return fallback ?? '';
      }

      if (period == 'AM') {
        if (hour == 12) {
          hour = 0;
        }
      } else {
        if (hour != 12) {
          hour += 12;
        }
      }

      // Keep a 12-hour clock representation for display.
      final int displayHour =
          hour == 0
              ? 12
              : hour > 12
              ? hour - 12
              : hour;

      return '$displayHour:${minute.toString().padLeft(2, '0')}';
    }

    // ------------------------------------------------------------------------
    // Normal user input:
    //
    // 8:45
    // 08:45
    // 1:30
    // 05:15
    // ------------------------------------------------------------------------

    final RegExp timePattern = RegExp(r'^(\d{1,2})\s*:\s*(\d{2})$');

    final Match? match = timePattern.firstMatch(input);

    if (match == null) {
      return fallback ?? '';
    }

    final int hour = int.parse(match.group(1)!);

    final int minute = int.parse(match.group(2)!);

    // Jamaat input uses 12-hour clock:
    // 1:00 through 12:59.
    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) {
      return fallback ?? '';
    }

    return '$hour:${minute.toString().padLeft(2, '0')}';
  }

  // ==========================================================================
  // NORMALIZATION HELPERS
  // ==========================================================================

  String _normalizeCalculationMethod(String value) {
    final String normalized = value.trim().toLowerCase();

    for (final String method in calculationMethods) {
      if (method.toLowerCase() == normalized) {
        return method;
      }
    }

    switch (normalized) {
      case 'muslim_world_league':
      case 'mwl':
        return 'Muslim World League';

      case 'egypt':
        return 'Egyptian';

      case 'umm_al_qura':
      case 'ummalqura':
        return 'Umm Al Qura';

      case 'north_america':
      case 'isna':
        return 'North America';

      case 'moonsighting':
      case 'moonsighting_committee':
        return 'Moonsighting Committee';

      case 'karachi':
      default:
        return 'Karachi';
    }
  }

  String _normalizeMadhab(String value) {
    final String normalized = value.trim().toLowerCase();

    if (normalized == 'shafi' ||
        normalized == 'shafii' ||
        normalized == "shafi'i" ||
        normalized == 'shafi’i') {
      return 'Shafi';
    }

    return 'Hanafi';
  }

  // ==========================================================================
  // HELPER
  // ==========================================================================

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';

      case ThemeMode.dark:
        return 'dark';

      case ThemeMode.system:
        return 'system';
    }
  }
}
