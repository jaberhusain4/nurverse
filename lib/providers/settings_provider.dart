import 'dart:convert';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/jamaat_service.dart';
import '../services/prayer_calculation_config.dart';

class SettingsProvider extends ChangeNotifier {
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
  static const String _timeFormatKey = 'time_format';
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
    'Fajr': 0, 'Dhuhr': 0, 'Asr': 0, 'Maghrib': 0, 'Isha': 0,
  };

  static const String _fajrJamaatKey = 'jamaat_fajr';
  static const String _dhuhrJamaatKey = 'jamaat_dhuhr';
  static const String _asrJamaatKey = 'jamaat_asr';
  static const String _maghribJamaatKey = 'jamaat_maghrib';
  static const String _ishaJamaatKey = 'jamaat_isha';

  static const List<String> calculationMethods = [
    'Karachi', 'Muslim World League', 'Egyptian', 'Umm Al Qura', 'Dubai',
    'Qatar', 'Kuwait', 'Singapore', 'North America', 'Moonsighting Committee',
  ];
  static const List<String> madhabs = ['Hanafi', 'Shafi', 'Maliki', 'Hanbali'];

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
  int _hijriAdjustment = 1;
  bool _showSeconds = false;
  String _timeFormat = '12';
  bool _vibrationEnabled = true;
  String _quranTranslation = 'Bangla';
  String _quranArabicFont = 'Default';
  bool _autoPlayNext = false;
  bool _downloadWifiOnly = true;
  String _notificationSound = 'Default';
  int _prayerReminderMinutes = 0;
  Map<String, int> _prayerAdjustments = Map<String, int>.from(_defaultPrayerAdjustments);
  bool _showDailyAyah = true;
  bool _showDailyHadith = true;
  bool _showDailyDua = true;
  String _dateDisplayPreference = 'both';

  // Dhaka reference Jamaat defaults. Each value retains its AM/PM period.
  String _fajrJamaat = '5:00 AM';
  String _dhuhrJamaat = '1:30 PM';
  String _asrJamaat = '5:15 PM';
  String _maghribJamaat = '6:57 PM';
  String _ishaJamaat = '8:45 PM';
  bool _isLoading = true;

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
  String get timeFormat => _timeFormat;
  bool get is24Hour => _timeFormat == '24';
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

  PrayerCalculationConfig get prayerCalculationConfig => PrayerCalculationConfig.fromSettings(calculationMethod: _calculationMethod, madhhab: _madhab);
  CalculationMethod get prayerCalculationMethod => prayerCalculationConfig.method;
  Madhab get prayerMadhab => prayerCalculationConfig.madhhab;

  // JamaatService is the single source of truth. These provider getters
  // remain as a compatibility API for existing screens/widgets.
  String get fajrJamaat => JamaatService.get('Fajr');
  String get dhuhrJamaat => JamaatService.get('Dhuhr');
  String get asrJamaat => JamaatService.get('Asr');
  String get maghribJamaat => JamaatService.get('Maghrib');
  String get ishaJamaat => JamaatService.get('Isha');

  String getJamaat(String prayer) => JamaatService.get(prayer.trim());

  Map<String, String> get jamaatTimes => JamaatService.all;

  String get themeId {
    if (_isAmoledMode) return 'amoled';
    switch (_themeMode) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      case ThemeMode.system: return 'system';
    }
  }

  SettingsProvider() { _loadSettings(); }

  Future<void> _loadSettings() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedThemeMode = prefs.getString(_themeModeKey);
      switch (savedThemeMode) {
        case 'light': _themeMode = ThemeMode.light; break;
        case 'dark': _themeMode = ThemeMode.dark; break;
        default: _themeMode = ThemeMode.system; break;
      }
      _isAmoledMode = prefs.getBool(_amoledModeKey) ?? false;
      if (_isAmoledMode) _themeMode = ThemeMode.dark;
      final String? savedLanguage = prefs.getString(_languageKey);
      _languageCode = savedLanguage == 'en' || savedLanguage == 'ar' ? savedLanguage! : 'bn';
      final String savedCalculationMethod = prefs.getString(_calculationMethodKey) ?? 'Karachi';
      _calculationMethod = _normalizeCalculationMethod(savedCalculationMethod);
      _madhab = _normalizeMadhab(prefs.getString(_madhabKey) ?? 'Hanafi');
      _quranFontSize = prefs.getDouble(_quranFontSizeKey) ?? 24.0;
      _translationFontSize = prefs.getDouble(_translationFontSizeKey) ?? 14.0;
      _isAdhanNotificationEnabled = prefs.getBool(_adhanNotificationKey) ?? true;
      _locationMode = prefs.getString(_locationModeKey) ?? 'automatic';
      _autoLocation = prefs.getBool(_autoLocationKey) ?? true;
      _hijriAdjustment = (prefs.getInt(_hijriAdjustmentKey) ?? 1).clamp(-3, 3);
      _showSeconds = prefs.getBool(_showSecondsKey) ?? false;
      _timeFormat = prefs.getString(_timeFormatKey) == '24' ? '24' : '12';
      _vibrationEnabled = prefs.getBool(_vibrationKey) ?? true;
      _quranTranslation = prefs.getString(_quranTranslationKey) ?? 'Bangla';
      _quranArabicFont = prefs.getString(_quranArabicFontKey) ?? 'Default';
      _autoPlayNext = prefs.getBool(_autoPlayNextKey) ?? false;
      _downloadWifiOnly = prefs.getBool(_downloadWifiOnlyKey) ?? true;
      _notificationSound = prefs.getString(_notificationSoundKey) ?? 'Default';
      _prayerReminderMinutes = prefs.getInt(_prayerReminderMinutesKey) ?? 0;
      _showDailyAyah = prefs.getBool(_dailyAyahKey) ?? true;
      _showDailyHadith = prefs.getBool(_dailyHadithKey) ?? true;
      _showDailyDua = prefs.getBool(_dailyDuaKey) ?? true;
      _dateDisplayPreference = _normalizeDateDisplayPreference(prefs.getString(_dateDisplayPreferenceKey) ?? 'both');
      final String? savedPrayerAdjustments = prefs.getString(_prayerAdjustmentsKey);
      if (savedPrayerAdjustments != null) {
        try {
          final dynamic decoded = jsonDecode(savedPrayerAdjustments);
          if (decoded is Map) {
            final Map<String, int> parsed = <String, int>{};
            for (final entry in decoded.entries) {
              if (entry.key is! String || !_defaultPrayerAdjustments.containsKey(entry.key)) continue;
              parsed[entry.key.toString()] = (entry.value is int ? entry.value as int : int.tryParse(entry.value.toString()) ?? 0).clamp(-60, 60);
            }
            if (parsed.isNotEmpty) _prayerAdjustments = parsed;
          }
        } catch (_) {
          _prayerAdjustments = Map<String, int>.from(_defaultPrayerAdjustments);
        }
      }
      _fajrJamaat = _normalizeJamaatTime(prefs.getString(_fajrJamaatKey) ?? '5:00 AM', fallback: '5:00 AM');
      _dhuhrJamaat = _normalizeJamaatTime(prefs.getString(_dhuhrJamaatKey) ?? '1:30 PM', fallback: '1:30 PM');
      _asrJamaat = _normalizeJamaatTime(prefs.getString(_asrJamaatKey) ?? '5:15 PM', fallback: '5:15 PM');
      _maghribJamaat = _normalizeJamaatTime(prefs.getString(_maghribJamaatKey) ?? '6:57 PM', fallback: '6:57 PM');
      _ishaJamaat = _normalizeJamaatTime(prefs.getString(_ishaJamaatKey) ?? '8:45 PM', fallback: '8:45 PM');
      JamaatService.setAll(fajr: _fajrJamaat, dhuhr: _dhuhrJamaat, asr: _asrJamaat, maghrib: _maghribJamaat, isha: _ishaJamaat);
    } catch (_) {
      // In-memory Dhaka defaults remain active.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async { if (mode != ThemeMode.dark) _isAmoledMode = false; _themeMode = mode; notifyListeners(); await _persistTheme(); }
  Future<void> setSystemTheme() async { _isAmoledMode = false; _themeMode = ThemeMode.system; notifyListeners(); await _persistTheme(); }
  Future<void> setLightTheme() async { _isAmoledMode = false; _themeMode = ThemeMode.light; notifyListeners(); await _persistTheme(); }
  Future<void> setDarkTheme() async { _isAmoledMode = false; _themeMode = ThemeMode.dark; notifyListeners(); await _persistTheme(); }
  Future<void> setAmoledTheme() async { _isAmoledMode = true; _themeMode = ThemeMode.dark; notifyListeners(); await _persistTheme(); }
  Future<void> toggleAmoledMode(bool value) async { if (value) { await setAmoledTheme(); return; } _isAmoledMode = false; _themeMode = ThemeMode.dark; notifyListeners(); await _persistTheme(); }

  Future<void> _persistTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _themeModeToString(_themeMode));
      await prefs.setBool(_amoledModeKey, _isAmoledMode);
    } catch (_) {}
  }

  Future<void> setLanguage(String code) async { final normalizedCode = code.toLowerCase().trim(); if (!['bn','en','ar'].contains(normalizedCode) || _languageCode == normalizedCode) return; _languageCode = normalizedCode; notifyListeners(); try { await (await SharedPreferences.getInstance()).setString(_languageKey, normalizedCode); } catch (_) {} }
  Future<void> setBangla() async => setLanguage('bn');
  Future<void> setEnglish() async => setLanguage('en');
  Future<void> setArabic() async => setLanguage('ar');
  Future<void> setCalculationMethod(String method) async { final normalized = _normalizeCalculationMethod(method); if (_calculationMethod == normalized) return; _calculationMethod = normalized; notifyListeners(); try { await (await SharedPreferences.getInstance()).setString(_calculationMethodKey, normalized); } catch (_) {} }
  Future<void> setMadhhab(String madhhab) async { final normalized = _normalizeMadhab(madhhab); if (_madhab == normalized) return; _madhab = normalized; notifyListeners(); try { await (await SharedPreferences.getInstance()).setString(_madhabKey, normalized); } catch (_) {} }
  Future<void> setMadhab(String madhhab) async => setMadhhab(madhhab);
  Future<void> updateQuranFontSize(double size) async { _quranFontSize = size.clamp(14.0, 50.0).toDouble(); notifyListeners(); try { await (await SharedPreferences.getInstance()).setDouble(_quranFontSizeKey, _quranFontSize); } catch (_) {} }
  Future<void> updateTranslationFontSize(double size) async { _translationFontSize = size.clamp(10.0, 30.0).toDouble(); notifyListeners(); try { await (await SharedPreferences.getInstance()).setDouble(_translationFontSizeKey, _translationFontSize); } catch (_) {} }
  Future<void> toggleAdhanNotification(bool value) async { _isAdhanNotificationEnabled = value; notifyListeners(); try { await (await SharedPreferences.getInstance()).setBool(_adhanNotificationKey, value); } catch (_) {} }
  Future<void> setLocationMode(String mode) async { if (mode != 'automatic' && mode != 'manual') return; _locationMode = mode; _autoLocation = mode == 'automatic'; notifyListeners(); try { final prefs = await SharedPreferences.getInstance(); await prefs.setString(_locationModeKey, mode); await prefs.setBool(_autoLocationKey, _autoLocation); } catch (_) {} }
  Future<void> setAutoLocation(bool value) async { _autoLocation = value; _locationMode = value ? 'automatic' : 'manual'; notifyListeners(); try { final prefs = await SharedPreferences.getInstance(); await prefs.setBool(_autoLocationKey, value); await prefs.setString(_locationModeKey, _locationMode); } catch (_) {} }
  Future<void> setHijriAdjustment(int value) async { _hijriAdjustment = value.clamp(-3, 3); notifyListeners(); try { await (await SharedPreferences.getInstance()).setInt(_hijriAdjustmentKey, _hijriAdjustment); } catch (_) {} }
  Future<void> setTimeFormat(String value) async { final normalized = value == '24' ? '24' : '12'; if (_timeFormat == normalized) return; _timeFormat = normalized; notifyListeners(); try { await (await SharedPreferences.getInstance()).setString(_timeFormatKey, normalized); } catch (_) {} }
  Future<void> toggleShowSeconds(bool value) async { _showSeconds = value; notifyListeners(); try { await (await SharedPreferences.getInstance()).setBool(_showSecondsKey, value); } catch (_) {} }
  Future<void> toggleVibration(bool value) async { _vibrationEnabled = value; notifyListeners(); try { await (await SharedPreferences.getInstance()).setBool(_vibrationKey, value); } catch (_) {} }
  Future<void> setDailyContentPreferences({bool? ayah, bool? hadith, bool? dua}) async { if (ayah != null) _showDailyAyah = ayah; if (hadith != null) _showDailyHadith = hadith; if (dua != null) _showDailyDua = dua; notifyListeners(); try { final prefs = await SharedPreferences.getInstance(); if (ayah != null) await prefs.setBool(_dailyAyahKey, _showDailyAyah); if (hadith != null) await prefs.setBool(_dailyHadithKey, _showDailyHadith); if (dua != null) await prefs.setBool(_dailyDuaKey, _showDailyDua); } catch (_) {} }
  Future<void> setDateDisplayPreference(String value) async { final normalized = _normalizeDateDisplayPreference(value); if (_dateDisplayPreference == normalized) return; _dateDisplayPreference = normalized; notifyListeners(); try { await (await SharedPreferences.getInstance()).setString(_dateDisplayPreferenceKey, normalized); } catch (_) {} }
  Future<void> setQuranTranslation(String value) async { if (value.trim().isEmpty) return; _quranTranslation = value; notifyListeners(); try { await (await SharedPreferences.getInstance()).setString(_quranTranslationKey, value); } catch (_) {} }
  Future<void> setQuranArabicFont(String value) async { if (value.trim().isEmpty) return; _quranArabicFont = value; notifyListeners(); try { await (await SharedPreferences.getInstance()).setString(_quranArabicFontKey, value); } catch (_) {} }
  Future<void> toggleAutoPlayNext(bool value) async { _autoPlayNext = value; notifyListeners(); try { await (await SharedPreferences.getInstance()).setBool(_autoPlayNextKey, value); } catch (_) {} }
  Future<void> toggleDownloadWifiOnly(bool value) async { _downloadWifiOnly = value; notifyListeners(); try { await (await SharedPreferences.getInstance()).setBool(_downloadWifiOnlyKey, value); } catch (_) {} }
  Future<void> setNotificationSound(String value) async { if (value.trim().isEmpty) return; _notificationSound = value; notifyListeners(); try { await (await SharedPreferences.getInstance()).setString(_notificationSoundKey, value); } catch (_) {} }
  Future<void> setPrayerReminderMinutes(int value) async { _prayerReminderMinutes = value.clamp(0, 60); notifyListeners(); try { await (await SharedPreferences.getInstance()).setInt(_prayerReminderMinutesKey, _prayerReminderMinutes); } catch (_) {} }

  Future<void> setPrayerAdjustment(String prayer, int value) async {
    final normalizedPrayer = prayer.trim();
    if (!_defaultPrayerAdjustments.containsKey(normalizedPrayer)) return;
    _prayerAdjustments[normalizedPrayer] = value.clamp(-60, 60);
    notifyListeners();
    try { await (await SharedPreferences.getInstance()).setString(_prayerAdjustmentsKey, jsonEncode(_prayerAdjustments)); } catch (_) {}
  }
  Future<void> resetPrayerAdjustments() async {
    _prayerAdjustments = Map<String, int>.from(_defaultPrayerAdjustments);
    notifyListeners();
    try { await (await SharedPreferences.getInstance()).remove(_prayerAdjustmentsKey); } catch (_) {}
  }
  Future<bool> setJamaatTime(String prayer, String time) async {
    final normalizedPrayer = prayer.trim();
    final normalizedTime = _normalizeJamaatTime(time);
    if (normalizedTime.isEmpty) return false;
    switch (normalizedPrayer) {
      case 'Fajr': _fajrJamaat = normalizedTime; break;
      case 'Dhuhr': _dhuhrJamaat = normalizedTime; break;
      case 'Asr': _asrJamaat = normalizedTime; break;
      case 'Maghrib': _maghribJamaat = normalizedTime; break;
      case 'Isha': _ishaJamaat = normalizedTime; break;
      default: return false;
    }
    await JamaatService.set(normalizedPrayer, normalizedTime);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = switch (normalizedPrayer) {
        'Fajr' => _fajrJamaatKey,
        'Dhuhr' => _dhuhrJamaatKey,
        'Asr' => _asrJamaatKey,
        'Maghrib' => _maghribJamaatKey,
        'Isha' => _ishaJamaatKey,
        _ => null,
      };
      if (key != null) await prefs.setString(key, normalizedTime);
      return true;
    } catch (_) { return false; }
  }
  Future<void> resetJamaatTimes() async {
    _fajrJamaat = '5:00 AM'; _dhuhrJamaat = '1:30 PM'; _asrJamaat = '5:15 PM'; _maghribJamaat = '6:57 PM'; _ishaJamaat = '8:45 PM';
    await JamaatService.reset();
    notifyListeners();
    try { final prefs = await SharedPreferences.getInstance(); for (final key in [_fajrJamaatKey,_dhuhrJamaatKey,_asrJamaatKey,_maghribJamaatKey,_ishaJamaatKey]) { await prefs.remove(key); } } catch (_) {}
  }
  Future<void> resetSettings() async {
    _themeMode = ThemeMode.system; _isAmoledMode = false; _languageCode = 'bn'; _calculationMethod = 'Karachi'; _madhab = 'Hanafi'; _quranFontSize = 24.0; _translationFontSize = 14.0; _isAdhanNotificationEnabled = true; _locationMode = 'automatic'; _autoLocation = true; _hijriAdjustment = 1; _showSeconds = false; _timeFormat = '12'; _vibrationEnabled = true; _quranTranslation = 'Bangla'; _quranArabicFont = 'Default'; _autoPlayNext = false; _downloadWifiOnly = true; _notificationSound = 'Default'; _prayerReminderMinutes = 0; _prayerAdjustments = Map<String, int>.from(_defaultPrayerAdjustments); _showDailyAyah = true; _showDailyHadith = true; _showDailyDua = true; _dateDisplayPreference = 'both'; _fajrJamaat = '5:00 AM'; _dhuhrJamaat = '1:30 PM'; _asrJamaat = '5:15 PM'; _maghribJamaat = '6:57 PM'; _ishaJamaat = '8:45 PM';
    await JamaatService.reset();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = [_themeModeKey,_amoledModeKey,_languageKey,_calculationMethodKey,_madhabKey,_quranFontSizeKey,_translationFontSizeKey,_adhanNotificationKey,_locationModeKey,_autoLocationKey,_hijriAdjustmentKey,_showSecondsKey,_timeFormatKey,_vibrationKey,_quranTranslationKey,_quranArabicFontKey,_autoPlayNextKey,_downloadWifiOnlyKey,_notificationSoundKey,_prayerReminderMinutesKey,_prayerAdjustmentsKey,_dailyAyahKey,_dailyHadithKey,_dailyDuaKey,_dateDisplayPreferenceKey,_fajrJamaatKey,_dhuhrJamaatKey,_asrJamaatKey,_maghribJamaatKey,_ishaJamaatKey];
      for (final key in keys) await prefs.remove(key);
    } catch (_) {}
  }
  String _normalizeDateDisplayPreference(String value) {
    switch (value.trim().toLowerCase()) { case 'hijri': return 'hijri'; case 'gregorian': return 'gregorian'; default: return 'both'; }
  }
  String _normalizeJamaatTime(String value, {String? fallback}) {
    final input = value.trim();
    if (input.isEmpty) return fallback ?? '';
    final amPm = RegExp(r'^(\d{1,2})\s*:\s*(\d{2})\s*([AaPp][Mm])$').firstMatch(input);
    if (amPm != null) {
      final hour = int.tryParse(amPm.group(1)!);
      final minute = int.tryParse(amPm.group(2)!);
      if (hour == null || minute == null || hour < 1 || hour > 12 || minute > 59) return fallback ?? '';
      return '$hour:${minute.toString().padLeft(2, '0')} ${amPm.group(3)!.toUpperCase()}';
    }
    final twentyFour = RegExp(r'^(\d{1,2})\s*:\s*(\d{2})$').firstMatch(input);
    if (twentyFour != null) {
      final hour = int.tryParse(twentyFour.group(1)!);
      final minute = int.tryParse(twentyFour.group(2)!);
      if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) return fallback ?? '';
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    }
    return fallback ?? '';
  }
  String _normalizeCalculationMethod(String value) {
    final normalized = value.trim().toLowerCase();
    for (final method in calculationMethods) { if (method.toLowerCase() == normalized) return method; }
    switch (normalized) { case 'muslim_world_league': case 'mwl': return 'Muslim World League'; case 'egypt': return 'Egyptian'; case 'umm_al_qura': case 'ummalqura': return 'Umm Al Qura'; case 'north_america': case 'isna': return 'North America'; case 'moonsighting': case 'moonsighting_committee': return 'Moonsighting Committee'; default: return 'Karachi'; }
  }
  String _normalizeMadhab(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'shafi' || normalized == 'shafii' || normalized == "shafi'i" || normalized == 'shafi’i') return 'Shafi';
    return 'Hanafi';
  }
  String _themeModeToString(ThemeMode mode) { switch (mode) { case ThemeMode.light: return 'light'; case ThemeMode.dark: return 'dark'; case ThemeMode.system: return 'system'; } }
}
