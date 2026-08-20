import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/settings_provider.dart';

/// Syncs NurVerse's local settings with the signed-in Google/Firebase account.
///
/// Settings remain local and offline-first. Firestore is only used as the
/// account backup/sync layer when a user is signed in.
class SettingsSyncService {
  SettingsSyncService._();

  static final SettingsSyncService instance = SettingsSyncService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> syncCurrentUser() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final DocumentReference<Map<String, dynamic>> ref =
        _users.doc(user.uid).collection('private').doc('settings');

    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();

      if (snapshot.exists && snapshot.data() != null) {
        await _restoreToLocal(prefs, snapshot.data()!);
      } else {
        await _saveLocalToCloud(prefs, ref);
      }
    } catch (_) {
      // Settings remain fully usable offline if cloud sync is unavailable.
    }
  }

  Future<void> applyToProvider(SettingsProvider settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool amoled = prefs.getBool('amoled_mode') ?? false;
    final String theme = prefs.getString('theme_mode') ?? 'system';
    final String language = prefs.getString('app_language') ?? 'bn';
    final String calculation =
        prefs.getString('calculation_method') ?? 'Karachi';
    final String madhab = prefs.getString('madhab') ?? 'Hanafi';

    if (amoled) {
      await settings.setAmoledTheme();
    } else {
      switch (theme) {
        case 'light':
          await settings.setLightTheme();
          break;
        case 'dark':
          await settings.setDarkTheme();
          break;
        default:
          await settings.setSystemTheme();
      }
    }

    await settings.setLanguage(language);
    await settings.setCalculationMethod(calculation);
    await settings.setMadhhab(madhab);
    await settings.updateQuranFontSize(
      prefs.getDouble('quran_font_size') ?? 24.0,
    );
    await settings.updateTranslationFontSize(
      prefs.getDouble('translation_font_size') ?? 14.0,
    );
    await settings.toggleAdhanNotification(
      prefs.getBool('adhan_notification_enabled') ?? true,
    );
    await settings.setLocationMode(
      prefs.getString('location_mode') ?? 'automatic',
    );
    await settings.setAutoLocation(prefs.getBool('auto_location') ?? true);
    await settings.setHijriAdjustment(prefs.getInt('hijri_adjustment') ?? 0);
    await settings.toggleShowSeconds(prefs.getBool('show_seconds') ?? false);
    await settings.toggleVibration(
      prefs.getBool('vibration_enabled') ?? true,
    );
    await settings.setQuranTranslation(
      prefs.getString('quran_translation') ?? 'Bangla',
    );
    await settings.setQuranArabicFont(
      prefs.getString('quran_arabic_font') ?? 'Default',
    );
    await settings.toggleAutoPlayNext(
      prefs.getBool('auto_play_next') ?? false,
    );
    await settings.toggleDownloadWifiOnly(
      prefs.getBool('download_wifi_only') ?? true,
    );
    await settings.setNotificationSound(
      prefs.getString('notification_sound') ?? 'Default',
    );
    await settings.setPrayerReminderMinutes(
      prefs.getInt('prayer_reminder_minutes') ?? 0,
    );
    await settings.setDailyContentPreferences(
      ayah: prefs.getBool('daily_content_ayah') ?? true,
      hadith: prefs.getBool('daily_content_hadith') ?? true,
      dua: prefs.getBool('daily_content_dua') ?? true,
    );
    await settings.setDateDisplayPreference(
      prefs.getString('date_display_preference') ?? 'both',
    );

    final String? adjustmentsJson = prefs.getString('prayer_adjustments');
    if (adjustmentsJson != null) {
      try {
        final dynamic decoded = jsonDecode(adjustmentsJson);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            final String prayer = entry.key.toString();
            final int value = entry.value is int
                ? entry.value as int
                : int.tryParse(entry.value.toString()) ?? 0;
            await settings.setPrayerAdjustment(prayer, value);
          }
        }
      } catch (_) {}
    }

    const Map<String, String> jamaatKeys = <String, String>{
      'Fajr': 'jamaat_fajr',
      'Dhuhr': 'jamaat_dhuhr',
      'Asr': 'jamaat_asr',
      'Maghrib': 'jamaat_maghrib',
      'Isha': 'jamaat_isha',
    };

    const Map<String, String> jamaatDefaults = <String, String>{
      'Fajr': '5:00',
      'Dhuhr': '1:30',
      'Asr': '5:15',
      'Maghrib': '6:57',
      'Isha': '8:45',
    };

    for (final entry in jamaatKeys.entries) {
      await settings.setJamaatTime(
        entry.key,
        prefs.getString(entry.value) ?? jamaatDefaults[entry.key]!,
      );
    }
  }

  Future<void> _saveLocalToCloud(
    SharedPreferences prefs,
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    final Map<String, dynamic> settings = <String, dynamic>{};

    for (final String key in prefs.getKeys()) {
      final Object? value = prefs.get(key);
      if (value is String ||
          value is bool ||
          value is int ||
          value is double ||
          value is List<String>) {
        settings[key] = value;
      }
    }

    await ref.set(<String, dynamic>{
      'settings': settings,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _restoreToLocal(
    SharedPreferences prefs,
    Map<String, dynamic> cloudDocument,
  ) async {
    final dynamic rawSettings = cloudDocument['settings'];
    if (rawSettings is! Map) return;

    for (final MapEntry<dynamic, dynamic> entry in rawSettings.entries) {
      final String key = entry.key.toString();
      final dynamic value = entry.value;

      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is List) {
        final List<String> strings = value
            .whereType<String>()
            .toList(growable: false);
        if (strings.length == value.length) {
          await prefs.setStringList(key, strings);
        }
      }
    }
  }
}
