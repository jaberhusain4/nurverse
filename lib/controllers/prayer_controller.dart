// lib/controllers/prayer_controller.dart

import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../services/jamaat_service.dart';
import '../services/location_service.dart';
import '../services/prayer_calculation_config.dart';
import '../services/prayer_engine_service.dart';

enum PrayerField { fajr, sunrise, dhuhr, asr, maghrib, isha }

class PrayerController extends ChangeNotifier {
  final PrayerEngineService _prayerEngine = const PrayerEngineService();

  final LocationService _locationService = const LocationService();

  Timer? _ticker;

  bool _loading = false;
  String? _error;

  Position? _position;

  // ==========================================================================
  // PRAYER CALCULATION CONFIGURATION
  // ==========================================================================

  PrayerCalculationConfig _calculationConfig = PrayerCalculationConfig.defaults;

  Map<String, int> _prayerAdjustments = <String, int>{
    'Fajr': 0,
    'Dhuhr': 0,
    'Asr': 0,
    'Maghrib': 0,
    'Isha': 0,
  };

  PrayerCalculationConfig get calculationConfig => _calculationConfig;

  CalculationMethod get calculationMethod => _calculationConfig.method;

  Madhab get madhhab => _calculationConfig.madhab;

  // ==========================================================================
  // LOCATION
  // ==========================================================================

  String _currentLocationName = 'লোকেশন লোড হচ্ছে...';

  // ==========================================================================
  // CURRENT / PREVIOUS / NEXT
  // ==========================================================================

  String _currentPrayer = 'ওয়াক্ত নেই';

  String _previousPrayer = '';
  String _previousPrayerTime = '';
  String _previousPrayerText = '';

  String _nextPrayerName = 'ফজর';
  String _nextPrayer = 'ফজর';
  String _nextPrayerTime = '--:--';

  String _currentPrayerStart = '--:--';
  String _currentPrayerEnd = '--:--';
  String _currentIqamahTime = '--:--';

  String _timeRemainingForNextPrayer = '00:00:00';

  // ==========================================================================
  // SUN / DAILY TIMES
  // ==========================================================================

  String _sunriseTime = '--:--';
  String _sunsetTime = '--:--';
  String _solarNoonTime = '--:--';

  // ==========================================================================
  // SPECIAL TIMES
  // ==========================================================================

  String _makruhTimeText = 'সময় গণনা করা হচ্ছে...';
  String _prohibitedTimeText = 'সময় গণনা করা হচ্ছে...';

  // ==========================================================================
  // PROGRESS / STATUS
  // ==========================================================================

  double _prayerProgress = 0.0;

  String _prayerStatus = 'সালাতের সময় গণনা করা হচ্ছে...';

  // ==========================================================================
  // PRAYER LIST
  // ==========================================================================

  final List<Map<String, dynamic>> _prayers = [];

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  bool get loading => _loading;

  String? get error => _error;

  String get currentLocationName => _currentLocationName;

  String get currentPrayer => _currentPrayer;

  String get previousPrayer => _previousPrayer;

  String get previousPrayerTime => _previousPrayerTime;

  String get previousPrayerText => _previousPrayerText;

  String get nextPrayerName => _nextPrayerName;

  String get nextPrayer => _nextPrayer;

  String get nextPrayerTime => _nextPrayerTime;

  String get currentPrayerStart => _currentPrayerStart;

  String get currentPrayerEnd => _currentPrayerEnd;

  String get currentIqamahTime => _currentIqamahTime;

  String get timeRemainingForNextPrayer => _timeRemainingForNextPrayer;

  String get sunriseTime => _sunriseTime;

  String get sunsetTime => _sunsetTime;

  String get solarNoonTime => _solarNoonTime;

  String get makruhTimeText => _makruhTimeText;

  String get prohibitedTimeText => _prohibitedTimeText;

  double get prayerProgress => _prayerProgress;

  int get prayerProgressPercentage =>
      (_prayerProgress * 100).round().clamp(0, 100);

  String get prayerStatus => _prayerStatus;

  List<Map<String, dynamic>> get prayers => List.unmodifiable(_prayers);

  // ==========================================================================
  // LOCATION COORDINATES
  // ==========================================================================

  double? get latitude => _position?.latitude;

  double? get longitude => _position?.longitude;

  bool get hasLocation => _position != null;

  Position? get position => _position;

  // ==========================================================================
  // BACKWARD COMPATIBILITY
  // ==========================================================================

  String get currentPrayerTime => _currentPrayerStart;

  String get iqamahTime => _currentIqamahTime;

  // ==========================================================================
  // CONSTRUCTOR
  // ==========================================================================

  PrayerController({PrayerCalculationConfig? calculationConfig}) {
    _calculationConfig = calculationConfig ?? PrayerCalculationConfig.defaults;

    _updateWithoutLocation();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      updatePrayerTimes();
    });

    determinePositionAndAddress();
  }

  // ==========================================================================
  // UPDATE CALCULATION CONFIG
  // ==========================================================================

  void setCalculationConfig(PrayerCalculationConfig config) {
    if (_calculationConfig.method == config.method &&
        _calculationConfig.madhab == config.madhab) {
      return;
    }

    _calculationConfig = config;

    updatePrayerTimes();
  }

  // ==========================================================================
  // UPDATE FROM SETTINGS VALUES
  // ==========================================================================

  void updateCalculationSettings({
    required String calculationMethod,
    required String madhhab,
  }) {
    final PrayerCalculationConfig config = PrayerCalculationConfig.fromSettings(
      calculationMethod: calculationMethod,
      madhhab: madhhab,
    );
 
    setCalculationConfig(config);
  }
 
  void updatePrayerAdjustments(Map<String, int> adjustments) {
    _prayerAdjustments = {
      'Fajr': adjustments['Fajr']?.clamp(-60, 60) ?? 0,
      'Dhuhr': adjustments['Dhuhr']?.clamp(-60, 60) ?? 0,
      'Asr': adjustments['Asr']?.clamp(-60, 60) ?? 0,
      'Maghrib': adjustments['Maghrib']?.clamp(-60, 60) ?? 0,
      'Isha': adjustments['Isha']?.clamp(-60, 60) ?? 0,
    };
 
    updatePrayerTimes();
  }
 
  // ==========================================================================
  // LOCATION
  // ==========================================================================

  Future<void> determinePositionAndAddress() async {
    try {
      _loading = true;
      _error = null;

      notifyListeners();

      final Position position = await _locationService.getCurrentPosition();

      _position = position;

      // ----------------------------------------------------------------------
      // REVERSE GEOCODING
      // ----------------------------------------------------------------------

      try {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks.first;

          final String street =
              place.street?.trim().isNotEmpty == true
                  ? place.street!.trim()
                  : '';

          final String subLocality =
              place.subLocality?.trim().isNotEmpty == true
                  ? place.subLocality!.trim()
                  : '';

          final String locality =
              place.locality?.trim().isNotEmpty == true
                  ? place.locality!.trim()
                  : '';

          final String district =
              place.subAdministrativeArea?.trim().isNotEmpty == true
                  ? place.subAdministrativeArea!.trim()
                  : (place.administrativeArea?.trim() ?? '');

          final List<String> parts = [];

          if (street.isNotEmpty) {
            parts.add(street);
          }

          if (subLocality.isNotEmpty && subLocality != street) {
            parts.add(subLocality);
          }

          if (locality.isNotEmpty &&
              locality != subLocality &&
              locality != street) {
            parts.add(locality);
          }

          if (district.isNotEmpty &&
              district != locality &&
              district != subLocality) {
            parts.add(district);
          }

          _currentLocationName =
              parts.isNotEmpty ? parts.join(', ') : 'লোকেশন পাওয়া যায়নি';
        } else {
          _currentLocationName = _coordinateFallback(position);
        }
      } catch (_) {
        _currentLocationName = _coordinateFallback(position);
      }

      updatePrayerTimes(notify: false);
    } catch (e) {
      _error = e.toString();

      final String message = e.toString().toLowerCase();

      if (message.contains('disabled')) {
        _currentLocationName = 'লোকেশন সার্ভিস বন্ধ আছে';
      } else if (message.contains('permission')) {
        _currentLocationName = 'লোকেশন পারমিশন দেওয়া হয়নি';
      } else {
        _currentLocationName = 'লোকেশন পাওয়া যায়নি';
      }
    } finally {
      _loading = false;

      notifyListeners();
    }
  }

  // ==========================================================================
  // COORDINATE FALLBACK
  // ==========================================================================

  String _coordinateFallback(Position position) {
    return '${position.latitude.toStringAsFixed(3)}, '
        '${position.longitude.toStringAsFixed(3)}';
  }

  // ==========================================================================
  // REFRESH LOCATION
  // ==========================================================================

  Future<void> refreshLocation() async {
    await determinePositionAndAddress();
  }

  // ==========================================================================
  // REFRESH PRAYER TIMES
  // ==========================================================================

  Future<void> refreshPrayerTimes() async {
    _loading = true;
    _error = null;

    notifyListeners();

    try {
      if (_position == null) {
        await determinePositionAndAddress();
      } else {
        updatePrayerTimes(notify: false);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;

      notifyListeners();
    }
  }

  // ==========================================================================
  // UPDATE EVERYTHING
  // ==========================================================================

  void updatePrayerTimes({bool notify = true}) {
    final Position? position = _position;

    if (position == null) {
      _updateWithoutLocation();

      if (notify) {
        notifyListeners();
      }

      return;
    }

    final DateTime now = DateTime.now();

    final PrayerTimes prayerTimes = _prayerEngine.getPrayerTimes(
      position: position,
      date: now,
      config: _calculationConfig,
    );

    // ========================================================================
    // NULL-SAFE PRAYER TIMES
    // ========================================================================

    final DateTime fajr = _applyPrayerAdjustment(
      'Fajr',
      _safeTime(
        prayerTimes.fajr,
        DateTime(now.year, now.month, now.day, 5),
      ),
    );

    final DateTime sunrise = _safeTime(
      prayerTimes.sunrise,
      fajr.add(const Duration(hours: 1)),
    );

    final DateTime dhuhr = _applyPrayerAdjustment(
      'Dhuhr',
      _safeTime(
        prayerTimes.dhuhr,
        DateTime(now.year, now.month, now.day, 12),
      ),
    );

    final DateTime asr = _applyPrayerAdjustment(
      'Asr',
      _safeTime(
        prayerTimes.asr,
        dhuhr.add(const Duration(hours: 4)),
      ),
    );

    final DateTime maghrib = _applyPrayerAdjustment(
      'Maghrib',
      _safeTime(
        prayerTimes.maghrib,
        asr.add(const Duration(hours: 4)),
      ),
    );

    final DateTime isha = _applyPrayerAdjustment(
      'Isha',
      _safeTime(
        prayerTimes.isha,
        maghrib.add(const Duration(hours: 1, minutes: 30)),
      ),
    );

    final Map<String, DateTime> times = {
      'Fajr': fajr,
      'Sunrise': sunrise,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Maghrib': maghrib,
      'Isha': isha,
    };

    // ========================================================================
    // SUN TIMES
    // ========================================================================

    _sunriseTime = _formatTime(sunrise);

    _sunsetTime = _formatTime(maghrib);

    _solarNoonTime = _formatTime(dhuhr);

    // ========================================================================
    // BUILD PRAYER LIST
    // ========================================================================

    _buildPrayerList(times: times, now: now);

    // ========================================================================
    // CURRENT / NEXT / PREVIOUS
    // ========================================================================

    _updatePrayerState(times: times, now: now);

    // ========================================================================
    // COUNTDOWN
    // ========================================================================

    _updateRemainingTime(times: times, now: now);

    // ========================================================================
    // PROGRESS
    // ========================================================================

    _updatePrayerProgress(times: times, now: now);

    // ========================================================================
    // SPECIAL TIMES
    // ========================================================================

    _updateDailyTimeInformation(times: times, now: now);

    if (notify) {
      notifyListeners();
    }
  }

  // ==========================================================================
  // SAFE DATETIME
  // ==========================================================================

  DateTime _safeTime(DateTime? value, DateTime fallback) {
    return value ?? fallback;
  }

  DateTime _applyPrayerAdjustment(String prayerName, DateTime time) {
    final int minutes = _prayerAdjustments[prayerName]?.clamp(-60, 60) ?? 0;
    return time.add(Duration(minutes: minutes));
  }

  // ==========================================================================
  // BUILD PRAYER LIST
  // ==========================================================================

  void _buildPrayerList({
    required Map<String, DateTime> times,
    required DateTime now,
  }) {
    final bool isFriday = now.weekday == DateTime.friday;

    _prayers.clear();

    // ------------------------------------------------------------------------
    // FAJR
    // ------------------------------------------------------------------------

    _prayers.add({
      'name': 'Fajr',
      'nameBn': 'ফজর',
      'nameAr': 'الفجر',
      'start': _formatTime(times['Fajr']!),
      'end': _formatTime(times['Sunrise']!),
      'jamaat': JamaatService.get('Fajr'),
      'isCurrent': false,
      'category': 'obligatory',
    });

    // ------------------------------------------------------------------------
    // DHUHR / JUMUAH
    // ------------------------------------------------------------------------

    _prayers.add({
      'name': isFriday ? 'Jumuah' : 'Dhuhr',
      'nameBn': isFriday ? "জুমু'আ" : 'যোহর',
      'nameAr': isFriday ? 'الجمعة' : 'الظهر',
      'start': _formatTime(times['Dhuhr']!),
      'end': _formatTime(times['Asr']!),
      'jamaat': JamaatService.get('Dhuhr'),
      'isCurrent': false,
      'category': 'obligatory',
    });

    // ------------------------------------------------------------------------
    // ASR
    // ------------------------------------------------------------------------

    _prayers.add({
      'name': 'Asr',
      'nameBn': 'আসর',
      'nameAr': 'العصر',
      'start': _formatTime(times['Asr']!),
      'end': _formatTime(times['Maghrib']!),
      'jamaat': JamaatService.get('Asr'),
      'isCurrent': false,
      'category': 'obligatory',
    });

    // ------------------------------------------------------------------------
    // MAGHRIB
    // ------------------------------------------------------------------------

    _prayers.add({
      'name': 'Maghrib',
      'nameBn': 'মাগরিব',
      'nameAr': 'المغرب',
      'start': _formatTime(times['Maghrib']!),
      'end': _formatTime(times['Isha']!),
      'jamaat': JamaatService.get('Maghrib'),
      'isCurrent': false,
      'category': 'obligatory',
    });

    // ------------------------------------------------------------------------
    // ISHA
    // ------------------------------------------------------------------------

    final DateTime tomorrowFajr = _tomorrowPrayerTime(now, PrayerField.fajr);

    _prayers.add({
      'name': 'Isha',
      'nameBn': 'ইশা',
      'nameAr': 'العشاء',
      'start': _formatTime(times['Isha']!),
      'end': _formatTime(tomorrowFajr),
      'jamaat': JamaatService.get('Isha'),
      'isCurrent': false,
      'category': 'obligatory',
    });
  }

  // ==========================================================================
  // CURRENT / PREVIOUS / NEXT
  // ==========================================================================

  void _updatePrayerState({
    required Map<String, DateTime> times,
    required DateTime now,
  }) {
    final DateTime fajr = times['Fajr']!;

    final DateTime sunrise = times['Sunrise']!;

    final DateTime dhuhr = times['Dhuhr']!;

    final DateTime asr = times['Asr']!;

    final DateTime maghrib = times['Maghrib']!;

    final DateTime isha = times['Isha']!;

    final bool isFriday = now.weekday == DateTime.friday;

    final DateTime tomorrowFajr = _tomorrowPrayerTime(now, PrayerField.fajr);

    final DateTime tahajjudStart = _calculateTahajjudStart(
      now: now,
      todayIsha: isha,
      tomorrowFajr: tomorrowFajr,
    );

    _clearCurrentPrayer();

    // ========================================================================
    // BEFORE FAJR
    // ========================================================================

    if (now.isBefore(fajr)) {
      _currentPrayer = 'ইশা';

      _currentPrayerStart = _formatTime(_yesterdayIsha(now));

      _currentPrayerEnd = _formatTime(fajr);

      _currentIqamahTime = JamaatService.get('Isha');

      _previousPrayer = 'ইশা';

      _previousPrayerTime = JamaatService.get('Isha');

      _previousPrayerText = 'ইশার ওয়াক্ত চলছে';

      _nextPrayerName = 'ফজর';

      _nextPrayer = 'ফজর';

      _nextPrayerTime = _formatTime(fajr);

      _prayerStatus = 'ফজরের সময় শুরু হতে চলেছে';

      return;
    }

    // ========================================================================
    // FAJR
    // ========================================================================

    if (now.isBefore(sunrise)) {
      _currentPrayer = 'ফজর';

      _currentPrayerStart = _formatTime(fajr);

      _currentPrayerEnd = _formatTime(sunrise);

      _currentIqamahTime = JamaatService.get('Fajr');

      _previousPrayer = 'ইশা';

      _previousPrayerTime = JamaatService.get('Isha');

      _previousPrayerText = 'ইশা শেষ হয়েছে';

      _nextPrayerName = isFriday ? "জুমু'আ" : 'যোহর';

      _nextPrayer = _nextPrayerName;

      _nextPrayerTime = _formatTime(dhuhr);

      _prayerStatus = 'ফজরের ওয়াক্ত চলছে';

      _setCurrentPrayer('Fajr');

      return;
    }

    // ========================================================================
    // SUNRISE → DHUHR
    // ========================================================================

    if (now.isBefore(dhuhr)) {
      _currentPrayer = 'ওয়াক্ত নেই';

      _currentPrayerStart = _formatTime(sunrise);

      _currentPrayerEnd = _formatTime(dhuhr);

      _currentIqamahTime = '--:--';

      _previousPrayer = 'ফজর';

      _previousPrayerTime = _formatTime(fajr);

      _previousPrayerText = 'ফজরের ওয়াক্ত শেষ হয়েছে';

      _nextPrayerName = isFriday ? "জুমু'আ" : 'যোহর';

      _nextPrayer = _nextPrayerName;

      _nextPrayerTime = _formatTime(dhuhr);

      _prayerStatus =
          isFriday ? "পরবর্তী সালাত: জুমু'আ" : 'পরবর্তী সালাত: যোহর';

      return;
    }

    // ========================================================================
    // DHUHR / JUMUAH
    // ========================================================================

    if (now.isBefore(asr)) {
      _currentPrayer = isFriday ? "জুমু'আ" : 'যোহর';

      _currentPrayerStart = _formatTime(dhuhr);

      _currentPrayerEnd = _formatTime(asr);

      _currentIqamahTime = JamaatService.get('Dhuhr');

      _previousPrayer = 'ফজর';

      _previousPrayerTime = _formatTime(fajr);

      _previousPrayerText = 'ফজর শেষ হয়েছে';

      _nextPrayerName = 'আসর';

      _nextPrayer = 'আসর';

      _nextPrayerTime = _formatTime(asr);

      _prayerStatus = isFriday ? "জুমু'আর ওয়াক্ত চলছে" : 'যোহরের ওয়াক্ত চলছে';

      _setCurrentPrayer(isFriday ? 'Jumuah' : 'Dhuhr');

      return;
    }

    // ========================================================================
    // ASR
    // ========================================================================

    if (now.isBefore(maghrib)) {
      _currentPrayer = 'আসর';

      _currentPrayerStart = _formatTime(asr);

      _currentPrayerEnd = _formatTime(maghrib);

      _currentIqamahTime = JamaatService.get('Asr');

      _previousPrayer = isFriday ? "জুমু'আ" : 'যোহর';

      _previousPrayerTime = _formatTime(dhuhr);

      _previousPrayerText = '$_previousPrayer শেষ হয়েছে';

      _nextPrayerName = 'মাগরিব';

      _nextPrayer = 'মাগরিব';

      _nextPrayerTime = _formatTime(maghrib);

      _prayerStatus = 'আসরের ওয়াক্ত চলছে';

      _setCurrentPrayer('Asr');

      return;
    }

    // ========================================================================
    // MAGHRIB
    // ========================================================================

    if (now.isBefore(isha)) {
      _currentPrayer = 'মাগরিব';

      _currentPrayerStart = _formatTime(maghrib);

      _currentPrayerEnd = _formatTime(isha);

      _currentIqamahTime = JamaatService.get('Maghrib');

      _previousPrayer = 'আসর';

      _previousPrayerTime = _formatTime(asr);

      _previousPrayerText = 'আসর শেষ হয়েছে';

      _nextPrayerName = 'ইশা';

      _nextPrayer = 'ইশা';

      _nextPrayerTime = _formatTime(isha);

      _prayerStatus = 'মাগরিবের ওয়াক্ত চলছে';

      _setCurrentPrayer('Maghrib');

      return;
    }

    // ========================================================================
    // ISHA
    // ========================================================================

    _currentPrayer = 'ইশা';

    _currentPrayerStart = _formatTime(isha);

    _currentPrayerEnd = _formatTime(tomorrowFajr);

    _currentIqamahTime = JamaatService.get('Isha');

    _previousPrayer = 'মাগরিব';

    _previousPrayerTime = _formatTime(maghrib);

    _previousPrayerText = 'মাগরিব শেষ হয়েছে';

    // ========================================================================
    // TAHAJJUD / FAJR
    // ========================================================================

    if (now.isBefore(tahajjudStart)) {
      _nextPrayerName = 'তাহাজ্জুদ';

      _nextPrayer = 'তাহাজ্জুদ';

      _nextPrayerTime = _formatTime(tahajjudStart);
    } else {
      _nextPrayerName = 'ফজর';

      _nextPrayer = 'ফজর';

      _nextPrayerTime = _formatTime(tomorrowFajr);
    }

    _prayerStatus = 'ইশার ওয়াক্ত চলছে';

    _setCurrentPrayer('Isha');
  }

  // ==========================================================================
  // SET CURRENT PRAYER
  // ==========================================================================

  void _setCurrentPrayer(String prayerName) {
    for (final prayer in _prayers) {
      prayer['isCurrent'] = prayer['name'] == prayerName;
    }
  }

  // ==========================================================================
  // CLEAR CURRENT PRAYER
  // ==========================================================================

  void _clearCurrentPrayer() {
    for (final prayer in _prayers) {
      prayer['isCurrent'] = false;
    }
  }

  // ==========================================================================
  // REMAINING TIME
  // ==========================================================================

  void _updateRemainingTime({
    required Map<String, DateTime> times,
    required DateTime now,
  }) {
    DateTime target;

    if (now.isBefore(times['Fajr']!)) {
      target = times['Fajr']!;
    } else if (now.isBefore(times['Dhuhr']!)) {
      target = times['Dhuhr']!;
    } else if (now.isBefore(times['Asr']!)) {
      target = times['Asr']!;
    } else if (now.isBefore(times['Maghrib']!)) {
      target = times['Maghrib']!;
    } else if (now.isBefore(times['Isha']!)) {
      target = times['Isha']!;
    } else {
      target = _tomorrowPrayerTime(now, PrayerField.fajr);
    }

    final Duration difference = target.difference(now);

    _timeRemainingForNextPrayer = _formatDuration(difference);
  }

  // ==========================================================================
  // CURRENT PRAYER PROGRESS
  // ==========================================================================

  void _updatePrayerProgress({
    required Map<String, DateTime> times,
    required DateTime now,
  }) {
    DateTime? start;
    DateTime? end;

    // ------------------------------------------------------------------------
    // FAJR
    // ------------------------------------------------------------------------

    if (!now.isBefore(times['Fajr']!) && now.isBefore(times['Sunrise']!)) {
      start = times['Fajr'];
      end = times['Sunrise'];
    }
    // ------------------------------------------------------------------------
    // DHUHR
    // ------------------------------------------------------------------------
    else if (!now.isBefore(times['Dhuhr']!) && now.isBefore(times['Asr']!)) {
      start = times['Dhuhr'];
      end = times['Asr'];
    }
    // ------------------------------------------------------------------------
    // ASR
    // ------------------------------------------------------------------------
    else if (!now.isBefore(times['Asr']!) && now.isBefore(times['Maghrib']!)) {
      start = times['Asr'];
      end = times['Maghrib'];
    }
    // ------------------------------------------------------------------------
    // MAGHRIB
    // ------------------------------------------------------------------------
    else if (!now.isBefore(times['Maghrib']!) && now.isBefore(times['Isha']!)) {
      start = times['Maghrib'];
      end = times['Isha'];
    }
    // ------------------------------------------------------------------------
    // ISHA
    // ------------------------------------------------------------------------
    else if (!now.isBefore(times['Isha']!)) {
      start = times['Isha'];

      end = _tomorrowPrayerTime(now, PrayerField.fajr);
    }

    // ------------------------------------------------------------------------
    // NO ACTIVE PRAYER
    // ------------------------------------------------------------------------

    if (start == null || end == null) {
      _prayerProgress = 0.0;
      return;
    }

    final int totalSeconds = end.difference(start).inSeconds;

    final int elapsedSeconds = now.difference(start).inSeconds;

    if (totalSeconds <= 0) {
      _prayerProgress = 0.0;
      return;
    }

    _prayerProgress = (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  // ==========================================================================
  // DAILY TIME INFORMATION
  // ==========================================================================

  void _updateDailyTimeInformation({
    required Map<String, DateTime> times,
    required DateTime now,
  }) {
    final DateTime sunrise = times['Sunrise']!;

    final DateTime dhuhr = times['Dhuhr']!;

    final DateTime sunset = times['Maghrib']!;

    // ========================================================================
    // PROHIBITED WINDOWS
    // ========================================================================

    final DateTime sunriseProhibitedEnd = sunrise.add(
      const Duration(minutes: 15),
    );

    final DateTime zawalStart = dhuhr.subtract(const Duration(minutes: 10));

    final DateTime sunsetStart = sunset.subtract(const Duration(minutes: 15));

    if (!now.isBefore(sunrise) && now.isBefore(sunriseProhibitedEnd)) {
      _prohibitedTimeText = 'সূর্যোদয়ের সময় — নামাজ আদায় থেকে বিরত থাকুন';
    } else if (!now.isBefore(zawalStart) && now.isBefore(dhuhr)) {
      _prohibitedTimeText = 'জাওয়ালের সময় — নামাজ আদায় থেকে বিরত থাকুন';
    } else if (!now.isBefore(sunsetStart) && now.isBefore(sunset)) {
      _prohibitedTimeText = 'সূর্যাস্তের সময় — নামাজ আদায় থেকে বিরত থাকুন';
    } else {
      _prohibitedTimeText = 'বর্তমানে কোনো নিষিদ্ধ সময় নেই';
    }

    // ========================================================================
    // MAKRUH WINDOWS
    // ========================================================================

    final DateTime morningMakruhStart = sunrise.subtract(
      const Duration(minutes: 15),
    );

    final DateTime zawalMakruhEnd = dhuhr.add(const Duration(minutes: 5));

    final DateTime eveningMakruhEnd = sunset.add(const Duration(minutes: 15));

    if (!now.isBefore(morningMakruhStart) &&
        now.isBefore(sunriseProhibitedEnd)) {
      _makruhTimeText = 'সূর্যোদয়ের আশেপাশের মাকরূহ সময়';
    } else if (!now.isBefore(zawalStart) && now.isBefore(zawalMakruhEnd)) {
      _makruhTimeText = 'জাওয়ালের আশেপাশের মাকরূহ সময়';
    } else if (!now.isBefore(sunsetStart) && now.isBefore(eveningMakruhEnd)) {
      _makruhTimeText = 'সূর্যাস্তের আশেপাশের মাকরূহ সময়';
    } else {
      _makruhTimeText = 'বর্তমানে কোনো বিশেষ মাকরূহ সময় নেই';
    }
  }

  // ==========================================================================
  // TAHAJJUD START
  // ==========================================================================

  DateTime _calculateTahajjudStart({
    required DateTime now,
    required DateTime todayIsha,
    required DateTime tomorrowFajr,
  }) {
    final Duration nightDuration = tomorrowFajr.difference(todayIsha);

    if (nightDuration.isNegative || nightDuration.inSeconds <= 0) {
      return tomorrowFajr;
    }

    final Duration lastThird = Duration(
      milliseconds: (nightDuration.inMilliseconds / 3).round(),
    );

    return tomorrowFajr.subtract(lastThird);
  }

  // ==========================================================================
  // TOMORROW PRAYER TIME
  // ==========================================================================

  DateTime _tomorrowPrayerTime(DateTime now, PrayerField field) {
    final Position? position = _position;

    if (position == null) {
      return _fallbackPrayerTime(now, field);
    }

    final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);

    final PrayerTimes tomorrowTimes = _prayerEngine.getPrayerTimes(
      position: position,
      date: tomorrow,
      config: _calculationConfig,
    );

    switch (field) {
      case PrayerField.fajr:
        return _applyPrayerAdjustment(
          'Fajr',
          _safeTime(
            tomorrowTimes.fajr,
            DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 5),
          ),
        );
 
      case PrayerField.sunrise:
        return _safeTime(
          tomorrowTimes.sunrise,
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 6),
        );
 
      case PrayerField.dhuhr:
        return _applyPrayerAdjustment(
          'Dhuhr',
          _safeTime(
            tomorrowTimes.dhuhr,
            DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12),
          ),
        );
 
      case PrayerField.asr:
        return _applyPrayerAdjustment(
          'Asr',
          _safeTime(
            tomorrowTimes.asr,
            DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 16),
          ),
        );
 
      case PrayerField.maghrib:
        return _applyPrayerAdjustment(
          'Maghrib',
          _safeTime(
            tomorrowTimes.maghrib,
            DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 18),
          ),
        );
 
      case PrayerField.isha:
        return _applyPrayerAdjustment(
          'Isha',
          _safeTime(
            tomorrowTimes.isha,
            DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 20),
          ),
        );
    }
  }

  // ==========================================================================
  // FALLBACK PRAYER TIME
  // ==========================================================================

  DateTime _fallbackPrayerTime(DateTime now, PrayerField field) {
    final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);

    switch (field) {
      case PrayerField.fajr:
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 5);

      case PrayerField.sunrise:
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 6);

      case PrayerField.dhuhr:
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12);

      case PrayerField.asr:
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 16);

      case PrayerField.maghrib:
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 18);

      case PrayerField.isha:
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 20);
    }
  }

  // ==========================================================================
  // YESTERDAY ISHA
  // ==========================================================================

  DateTime _yesterdayIsha(DateTime now) {
    final Position? position = _position;

    if (position == null) {
      return DateTime(now.year, now.month, now.day - 1, 20);
    }

    final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

    final PrayerTimes yesterdayTimes = _prayerEngine.getPrayerTimes(
      position: position,
      date: yesterday,
      config: _calculationConfig,
    );

    return _applyPrayerAdjustment(
      'Isha',
      _safeTime(
        yesterdayTimes.isha,
        DateTime(yesterday.year, yesterday.month, yesterday.day, 20),
      ),
    );
  }

  // ==========================================================================
  // NO LOCATION FALLBACK
  // ==========================================================================

  void _updateWithoutLocation() {
    _currentPrayer = 'ওয়াক্ত নেই';

    _previousPrayer = '';

    _previousPrayerTime = '';

    _previousPrayerText = '';

    _nextPrayerName = 'ফজর';

    _nextPrayer = 'ফজর';

    _nextPrayerTime = '--:--';

    _currentPrayerStart = '--:--';

    _currentPrayerEnd = '--:--';

    _currentIqamahTime = '--:--';

    _timeRemainingForNextPrayer = '--:--:--';

    _sunriseTime = '--:--';

    _sunsetTime = '--:--';

    _solarNoonTime = '--:--';

    _prayerProgress = 0.0;

    _prayerStatus = 'লোকেশন পাওয়া গেলে সালাতের সময় দেখানো হবে';

    _makruhTimeText = 'লোকেশন পাওয়া গেলে সময় দেখানো হবে';

    _prohibitedTimeText = 'লোকেশন পাওয়া গেলে সময় দেখানো হবে';

    _prayers.clear();
  }

  // ==========================================================================
  // FORMAT TIME
  // ==========================================================================

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  // ==========================================================================
  // FORMAT DURATION
  // ==========================================================================

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return '00:00:00';
    }

    final int hours = duration.inHours;

    final int minutes = duration.inMinutes.remainder(60);

    final int seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _ticker?.cancel();

    _ticker = null;

    super.dispose();
  }
}
