import 'dart:io';

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'prayer_calculation_config.dart';
import 'prayer_engine_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  static NotificationService get instance => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final PrayerEngineService _prayerEngine = const PrayerEngineService();

  bool _isInitialized = false;
  bool _syncInProgress = false;
  String? _lastSyncKey;

  Future<bool> get enabled async {
    if (!_isInitialized) await init();
    if (!Platform.isAndroid) return true;
    return await _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;
  }

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    }

    const android = AndroidInitializationSettings('mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: darwin, macOS: darwin);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {},
    );

    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  Future<void> setEnabled(bool enabled, dynamic prayers) async {
    await init();
    if (!enabled) {
      await cancelPrayerNotifications();
      _lastSyncKey = null;
    }
  }

  Future<void> syncPrayerNotifications({
    required bool enabled,
    required Position? position,
    required PrayerCalculationConfig calculationConfig,
    required Map<String, int> prayerAdjustments,
    required int reminderMinutes,
    required String languageCode,
    required String sound,
  }) async {
    await init();

    if (!enabled || position == null) {
      if (!enabled) await cancelPrayerNotifications();
      _lastSyncKey = null;
      return;
    }

    final normalizedReminder = reminderMinutes.clamp(0, 60);
    final adjustmentSignature = prayerAdjustments.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .join('|');
    final key = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}|'
        '${position.latitude.toStringAsFixed(5)},${position.longitude.toStringAsFixed(5)}|'
        '${calculationConfig.method.name}|${calculationConfig.madhab.name}|'
        '$adjustmentSignature|$normalizedReminder|$languageCode|$sound';

    if (_lastSyncKey == key || _syncInProgress) return;
    _syncInProgress = true;
    _lastSyncKey = key;

    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      AndroidScheduleMode scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      if (androidPlugin != null) {
        final canScheduleExact = await androidPlugin.canScheduleExactAlarms();
        if (canScheduleExact != true) {
          await androidPlugin.requestExactAlarmsPermission();
        }
        if (await androidPlugin.canScheduleExactAlarms() != true) {
          scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
        }
      }

      await cancelPrayerNotifications();
      final now = DateTime.now();
      const int days = 7;
      int id = 1000;

      for (int dayOffset = 0; dayOffset < days; dayOffset++) {
        final date = DateTime(now.year, now.month, now.day + dayOffset);
        final prayerTimes = _prayerEngine.getPrayerTimes(
          position: position,
          date: date,
          config: calculationConfig,
        );

        final times = <String, DateTime?>{
          'Fajr': _adjust(prayerTimes.fajr, prayerAdjustments['Fajr']),
          'Dhuhr': _adjust(prayerTimes.dhuhr, prayerAdjustments['Dhuhr']),
          'Asr': _adjust(prayerTimes.asr, prayerAdjustments['Asr']),
          'Maghrib': _adjust(prayerTimes.maghrib, prayerAdjustments['Maghrib']),
          'Isha': _adjust(prayerTimes.isha, prayerAdjustments['Isha']),
        };

        for (final entry in times.entries) {
          final prayerTime = entry.value;
          if (prayerTime == null) continue;
          final scheduled = tz.TZDateTime.from(prayerTime, tz.local);
          final notificationTime = normalizedReminder > 0
              ? scheduled.subtract(Duration(minutes: normalizedReminder))
              : scheduled;
          if (!notificationTime.isAfter(tz.TZDateTime.now(tz.local))) continue;

          final prayerBn = _prayerNameBn(entry.key);
          final prayerEn = _prayerNameEn(entry.key);
          final prayerName = languageCode == 'en' ? prayerEn : prayerBn;
          final title = normalizedReminder > 0
              ? (languageCode == 'en' ? '$prayerName reminder' : '$prayerName-এর স্মরণ করানো')
              : (languageCode == 'en' ? '$prayerName Adhan' : '$prayerName-এর আজান');
          final body = normalizedReminder > 0
              ? (languageCode == 'en'
                  ? '$prayerName begins in $normalizedReminder minutes.'
                  : '$prayerName শুরু হতে আর $normalizedReminder মিনিট বাকি।')
              : (languageCode == 'en'
                  ? 'It is time for $prayerName.'
                  : '$prayerName-এর সময় হয়েছে।');

          await _plugin.zonedSchedule(
            id++,
            title,
            body,
            notificationTime,
            _notificationDetails(sound),
            androidScheduleMode: scheduleMode,
            payload: 'prayer:${entry.key}',
          );
        }
      }
    } catch (error) {
      _lastSyncKey = null;
      debugPrint('NurVerse prayer notification scheduling failed: $error');
    } finally {
      _syncInProgress = false;
    }
  }

  DateTime? _adjust(DateTime? time, int? minutes) {
    if (time == null) return null;
    return time.add(Duration(minutes: (minutes ?? 0).clamp(-60, 60)));
  }

  NotificationDetails _notificationDetails(String sound) {
    final normalized = sound.trim().toLowerCase();
    final bool silent = normalized == 'silent';
    final String channelId = silent ? 'nurverse_prayer_silent_v2' : 'nurverse_prayer_adhan_v2';
    final String channelName = silent ? 'NurVerse Prayer (Silent)' : 'NurVerse Adhan';

    final android = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: silent
          ? 'Silent prayer-time notifications'
          : 'Prayer-time Adhan notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: !silent,
      silent: silent,
      sound: silent ? null : const RawResourceAndroidNotificationSound('azan'),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      icon: 'mipmap/ic_launcher',
    );
    final darwin = DarwinNotificationDetails(presentSound: !silent);
    return NotificationDetails(android: android, iOS: darwin, macOS: darwin);
  }

  Future<void> cancelPrayerNotifications() async {
    if (!_isInitialized) return;
    for (int id = 1000; id < 2000; id++) {
      await _plugin.cancel(id);
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();
    await _plugin.show(id, title, body, _notificationDetails('Adhan'), payload: payload);
  }

  String _prayerNameBn(String prayer) {
    switch (prayer) {
      case 'Fajr': return 'ফজর';
      case 'Dhuhr': return 'যোহর';
      case 'Asr': return 'আসর';
      case 'Maghrib': return 'মাগরিব';
      case 'Isha': return 'ইশা';
      default: return prayer;
    }
  }

  String _prayerNameEn(String prayer) {
    switch (prayer) {
      case 'Fajr': return 'Fajr';
      case 'Dhuhr': return 'Dhuhr';
      case 'Asr': return 'Asr';
      case 'Maghrib': return 'Maghrib';
      case 'Isha': return 'Isha';
      default: return prayer;
    }
  }
}
