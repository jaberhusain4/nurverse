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
  PrayerCalculationConfig _calculationConfig = PrayerCalculationConfig.defaults;
  Map<String, int> _prayerAdjustments = {
    'Fajr': 0,
    'Dhuhr': 0,
    'Asr': 0,
    'Maghrib': 0,
    'Isha': 0,
  };
  PrayerCalculationConfig get calculationConfig => _calculationConfig;
  CalculationMethod get calculationMethod => _calculationConfig.method;
  Madhab get madhhab => _calculationConfig.madhab;
  String _currentLocationName = 'লোকেশন লোড হচ্ছে...';
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
  String _sunriseTime = '--:--';
  String _sunsetTime = '--:--';
  String _solarNoonTime = '--:--';
  String _makruhTimeText = 'সময় গণনা করা হচ্ছে...';
  String _prohibitedTimeText = 'সময় গণনা করা হচ্ছে...';
  double _prayerProgress = 0.0;
  String _prayerStatus = 'সালাতের সময় গণনা করা হচ্ছে...';
  final List<Map<String, dynamic>> _prayers = [];
  DateTime? _ishraqStart,
      _ishraqEnd,
      _duhaStart,
      _duhaEnd,
      _awwwabinStart,
      _awwwabinEnd,
      _tahajjudStart,
      _tahajjudEnd,
      _prohibitedStart,
      _prohibitedEnd,
      _makruhStart,
      _makruhEnd;

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
  double? get latitude => _position?.latitude;
  double? get longitude => _position?.longitude;
  bool get hasLocation => _position != null;
  Position? get position => _position;
  String get currentPrayerTime => _currentPrayerStart;
  String get iqamahTime => _currentIqamahTime;
  DateTime? get ishraqStart => _ishraqStart;
  DateTime? get ishraqEnd => _ishraqEnd;
  DateTime? get duhaStart => _duhaStart;
  DateTime? get duhaEnd => _duhaEnd;
  DateTime? get awwabinStart => _awwwabinStart;
  DateTime? get awwabinEnd => _awwwabinEnd;
  DateTime? get tahajjudStart => _tahajjudStart;
  DateTime? get tahajjudEnd => _tahajjudEnd;
  DateTime? get prohibitedStart => _prohibitedStart;
  DateTime? get prohibitedEnd => _prohibitedEnd;
  DateTime? get makruhStart => _makruhStart;
  DateTime? get makruhEnd => _makruhEnd;
  String get ishraqTime => _windowText(_ishraqStart, _ishraqEnd);
  String get duhaTime => _windowText(_duhaStart, _duhaEnd);
  String get awwabinTime => _windowText(_awwwabinStart, _awwwabinEnd);
  String get tahajjudTime => _windowText(_tahajjudStart, _tahajjudEnd);

  PrayerController({PrayerCalculationConfig? calculationConfig}) {
    _calculationConfig = calculationConfig ?? PrayerCalculationConfig.defaults;
    _updateWithoutLocation();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _safeTick());
    JamaatService.initialize().then((_) {
      if (_position != null) {
        _safeRefresh();
      }
    });
    determinePositionAndAddress();
  }

  void _safeTick() {
    try {
      updatePrayerTimes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _safeRefresh() {
    try {
      updatePrayerTimes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void setCalculationConfig(PrayerCalculationConfig config) {
    if (_calculationConfig.method == config.method &&
        _calculationConfig.madhab == config.madhab) {
      return;
    }
    _calculationConfig = config;
    _safeRefresh();
  }

  void updateCalculationSettings({
    required String calculationMethod,
    required String madhhab,
  }) {
    setCalculationConfig(
      PrayerCalculationConfig.fromSettings(
        calculationMethod: calculationMethod,
        madhhab: madhhab,
      ),
    );
  }

  void updatePrayerAdjustments(Map<String, int> adjustments) {
    _prayerAdjustments = {
      'Fajr': adjustments['Fajr']?.clamp(-60, 60) ?? 0,
      'Dhuhr': adjustments['Dhuhr']?.clamp(-60, 60) ?? 0,
      'Asr': adjustments['Asr']?.clamp(-60, 60) ?? 0,
      'Maghrib': adjustments['Maghrib']?.clamp(-60, 60) ?? 0,
      'Isha': adjustments['Isha']?.clamp(-60, 60) ?? 0,
    };
    _safeRefresh();
  }

  Future<void> determinePositionAndAddress({bool forceFresh = false}) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      final Position position = forceFresh
          ? await _locationService.getFreshCurrentPosition()
          : await _locationService.getCurrentPosition();
      _position = position;
      try {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks.first;
          final String subLocality =
              place.subLocality?.trim().isNotEmpty == true
                  ? place.subLocality!.trim()
                  : '';
          final String locality = place.locality?.trim().isNotEmpty == true
              ? place.locality!.trim()
              : '';
          String district =
              place.subAdministrativeArea?.trim().isNotEmpty == true
                  ? place.subAdministrativeArea!.trim()
                  : (place.administrativeArea?.trim() ?? '');
          final String country = place.country?.trim().isNotEmpty == true
              ? place.country!.trim()
              : '';
          district = district.replaceAll(RegExp(r'\s+[Dd]istrict$'), '').trim();
          final List<String> parts = [];
          if (subLocality.isNotEmpty) parts.add(subLocality);
          if (locality.isNotEmpty && locality != subLocality)
            parts.add(locality);
          if (district.isNotEmpty &&
              district != locality &&
              district != subLocality) {
            parts.add(district);
          }
          if (country.isNotEmpty && country.toLowerCase() == 'bangladesh') {
            parts.add('Bangladesh');
          }
          _currentLocationName =
              parts.isNotEmpty ? parts.join(', ') : 'লোকেশন পাওয়া যায়নি';
        } else {
          _currentLocationName = _coordinateFallback(position);
        }
      } catch (_) {
        _currentLocationName = _coordinateFallback(position);
      }
      _safeRefresh();
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

  String _coordinateFallback(Position position) =>
      '${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)}';

  Future<void> refreshLocation() async =>
      determinePositionAndAddress(forceFresh: true);

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

  void updatePrayerTimes({bool notify = true}) {
    final Position? position = _position;
    if (position == null) {
      _updateWithoutLocation();
      if (notify) notifyListeners();
      return;
    }
    final DateTime now = DateTime.now();
    final PrayerTimes prayerTimes = _prayerEngine.getPrayerTimes(
      position: position,
      date: now,
      config: _calculationConfig,
    );
    final DateTime fajr = _applyPrayerAdjustment(
      'Fajr',
      _safeTime(prayerTimes.fajr, DateTime(now.year, now.month, now.day, 5)),
    );
    final DateTime sunrise =
        _safeTime(prayerTimes.sunrise, fajr.add(const Duration(hours: 1)));
    final DateTime dhuhr = _applyPrayerAdjustment(
      'Dhuhr',
      _safeTime(prayerTimes.dhuhr, DateTime(now.year, now.month, now.day, 12)),
    );
    final DateTime asr = _applyPrayerAdjustment(
      'Asr',
      _safeTime(prayerTimes.asr, dhuhr.add(const Duration(hours: 4))),
    );
    final DateTime maghrib = _applyPrayerAdjustment(
      'Maghrib',
      _safeTime(prayerTimes.maghrib, asr.add(const Duration(hours: 4))),
    );
    final DateTime isha = _applyPrayerAdjustment(
      'Isha',
      _safeTime(
          prayerTimes.isha, maghrib.add(const Duration(hours: 1, minutes: 30))),
    );
    final Map<String, DateTime> times = {
      'Fajr': fajr,
      'Sunrise': sunrise,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Maghrib': maghrib,
      'Isha': isha,
    };
    JamaatService.configureDefaults(times);
    _sunriseTime = _formatTime(sunrise);
    _sunsetTime = _formatTime(maghrib);
    _solarNoonTime = _formatTime(dhuhr);
    _calculateSpecialWindows(times: times, now: now);
    _buildPrayerList(times: times, now: now);
    _updatePrayerState(times: times, now: now);
    _updateRemainingTime(times: times, now: now);
    _updatePrayerProgress(times: times, now: now);
    _updateDailyTimeInformation(times: times, now: now);
    if (notify) notifyListeners();
  }

  DateTime _safeTime(DateTime? value, DateTime fallback) => value ?? fallback;

  DateTime _applyPrayerAdjustment(String prayerName, DateTime time) => time.add(
      Duration(minutes: _prayerAdjustments[prayerName]?.clamp(-60, 60) ?? 0));

  void _calculateSpecialWindows({
    required Map<String, DateTime> times,
    required DateTime now,
  }) {
    final DateTime sunrise = times['Sunrise']!;
    final DateTime dhuhr = times['Dhuhr']!;
    final DateTime maghrib = times['Maghrib']!;
    final DateTime isha = times['Isha']!;
    final DateTime tomorrowFajr = _tomorrowPrayerTime(now, PrayerField.fajr);
    _ishraqStart = sunrise.add(const Duration(minutes: 15));
    _ishraqEnd = dhuhr.subtract(const Duration(minutes: 10));
    _duhaStart = sunrise.add(const Duration(minutes: 15));
    _duhaEnd = dhuhr.subtract(const Duration(minutes: 10));
    _awwwabinStart = maghrib;
    _awwwabinEnd = isha;
    _tahajjudStart = _calculateTahajjudStart(
        now: now, todayIsha: isha, tomorrowFajr: tomorrowFajr);
    _tahajjudEnd = tomorrowFajr;
    final DateTime sunriseProhibitedEnd =
        sunrise.add(const Duration(minutes: 15));
    final DateTime zawalStart = dhuhr.subtract(const Duration(minutes: 10));
    final DateTime sunsetStart = maghrib.subtract(const Duration(minutes: 15));
    final List<List<DateTime>> prohibitedWindows = [
      [sunrise, sunriseProhibitedEnd],
      [zawalStart, dhuhr],
      [sunsetStart, maghrib],
    ];
    final List<List<DateTime>> makruhWindows = [
      [sunrise.subtract(const Duration(minutes: 15)), sunriseProhibitedEnd],
      [zawalStart, dhuhr.add(const Duration(minutes: 5))],
      [sunsetStart, maghrib.add(const Duration(minutes: 15))],
    ];
    final List<DateTime>? prohibited =
        _selectCurrentOrNextWindow(prohibitedWindows, now);
    final List<DateTime>? makruh =
        _selectCurrentOrNextWindow(makruhWindows, now);
    _prohibitedStart = prohibited?[0];
    _prohibitedEnd = prohibited?[1];
    _makruhStart = makruh?[0];
    _makruhEnd = makruh?[1];
  }

  List<DateTime>? _selectCurrentOrNextWindow(
      List<List<DateTime>> windows, DateTime now) {
    for (final window in windows) {
      final DateTime start = window[0];
      final DateTime end = window[1];
      if (!now.isBefore(start) && now.isBefore(end)) return [start, end];
    }
    for (final window in windows) {
      if (now.isBefore(window[0])) return [window[0], window[1]];
    }
    return null;
  }

  void _buildPrayerList(
      {required Map<String, DateTime> times, required DateTime now}) {
    final bool isFriday = now.weekday == DateTime.friday;
    _prayers.clear();
    void add(String name, String nameBn, String nameAr, DateTime start,
        DateTime end, String jamaat, String category) {
      _prayers.add({
        'name': name,
        'nameBn': nameBn,
        'nameAr': nameAr,
        'start': _formatTime(start),
        'end': _formatTime(end),
        'jamaat': jamaat,
        'isCurrent': false,
        'category': category,
      });
    }

    add('Fajr', 'ফজর', 'الفجر', times['Fajr']!, times['Sunrise']!,
        JamaatService.get('Fajr'), 'obligatory');
    add(
        isFriday ? 'Jumuah' : 'Dhuhr',
        isFriday ? 'জুমুআ' : 'যোহর',
        isFriday ? 'الجمعة' : 'الظهر',
        times['Dhuhr']!,
        times['Asr']!,
        JamaatService.get('Dhuhr'),
        'obligatory');
    add('Asr', 'আসর', 'العصر', times['Asr']!, times['Maghrib']!,
        JamaatService.get('Asr'), 'obligatory');
    add('Maghrib', 'মাগরিব', 'المغرب', times['Maghrib']!, times['Isha']!,
        JamaatService.get('Maghrib'), 'obligatory');
    add(
        'Isha',
        'ইশা',
        'العشاء',
        times['Isha']!,
        _tomorrowPrayerTime(now, PrayerField.fajr),
        JamaatService.get('Isha'),
        'obligatory');
  }

  void _updatePrayerState(
      {required Map<String, DateTime> times, required DateTime now}) {
    final DateTime fajr = times['Fajr']!;
    final DateTime dhuhr = times['Dhuhr']!;
    final DateTime asr = times['Asr']!;
    final DateTime maghrib = times['Maghrib']!;
    final DateTime isha = times['Isha']!;
    final DateTime tomorrowFajr = _tomorrowPrayerTime(now, PrayerField.fajr);
    _clearCurrentPrayer();
    if (now.isBefore(fajr)) {
      final DateTime yesterdayIsha =
          _yesterdayPrayerTime(now, PrayerField.isha);
      _currentPrayer = 'ওয়াক্ত নেই';
      _currentPrayerStart = '--:--';
      _currentPrayerEnd = _formatTime(fajr);
      _currentIqamahTime = '--:--';
      _previousPrayer = 'ইশা';
      _previousPrayerTime = _formatTime(yesterdayIsha);
      _previousPrayerText = 'ইশা শেষ হয়েছে';
      _nextPrayerName = 'ফজর';
      _nextPrayer = 'ফজর';
      _nextPrayerTime = _formatTime(fajr);
      _prayerStatus = 'পরবর্তী সালাত ফজর';
      return;
    }
    if (now.isBefore(dhuhr)) {
      _setPrayerRange('ফজর', fajr, dhuhr, 'Fajr');
      _previousPrayer = 'ফজর';
      _previousPrayerTime = _formatTime(fajr);
      _previousPrayerText = 'ফজর সম্পন্ন হয়েছে';
      _nextPrayerName = 'যোহর';
      _nextPrayer = 'যোহর';
      _nextPrayerTime = _formatTime(dhuhr);
      _prayerStatus = 'ফজরের পরের সময়';
      return;
    }
    if (now.isBefore(asr)) {
      _setPrayerRange('যোহর', dhuhr, asr, 'Dhuhr');
      _previousPrayer = 'যোহর';
      _previousPrayerTime = _formatTime(dhuhr);
      _previousPrayerText = 'যোহর সম্পন্ন হয়েছে';
      _nextPrayerName = 'আসর';
      _nextPrayer = 'আসর';
      _nextPrayerTime = _formatTime(asr);
      _prayerStatus = 'যোহরের পরের সময়';
      return;
    }
    if (now.isBefore(maghrib)) {
      _setPrayerRange('আসর', asr, maghrib, 'Asr');
      _previousPrayer = 'আসর';
      _previousPrayerTime = _formatTime(asr);
      _previousPrayerText = 'আসর সম্পন্ন হয়েছে';
      _nextPrayerName = 'মাগরিব';
      _nextPrayer = 'মাগরিব';
      _nextPrayerTime = _formatTime(maghrib);
      _prayerStatus = 'আসরের পরের সময়';
      return;
    }
    if (now.isBefore(isha)) {
      _setPrayerRange('মাগরিব', maghrib, isha, 'Maghrib');
      _previousPrayer = 'মাগরিব';
      _previousPrayerTime = _formatTime(maghrib);
      _previousPrayerText = 'মাগরিব সম্পন্ন হয়েছে';
      _nextPrayerName = 'ইশা';
      _nextPrayer = 'ইশা';
      _nextPrayerTime = _formatTime(isha);
      _prayerStatus = 'মাগরিবের ওয়াক্ত চলছে';
      return;
    }
    _currentPrayer = 'ইশা';
    _currentPrayerStart = _formatTime(isha);
    _currentPrayerEnd = _formatTime(tomorrowFajr);
    _currentIqamahTime = JamaatService.get('Isha');
    _previousPrayer = 'মাগরিব';
    _previousPrayerTime = _formatTime(maghrib);
    _previousPrayerText = 'মাগরিব শেষ হয়েছে';
    if (now.isBefore(_tahajjudStart!)) {
      _nextPrayerName = 'তাহাজ্জুদ';
      _nextPrayer = 'তাহাজ্জুদ';
      _nextPrayerTime = _formatTime(_tahajjudStart!);
    } else {
      _nextPrayerName = 'ফজর';
      _nextPrayer = 'ফজর';
      _nextPrayerTime = _formatTime(tomorrowFajr);
    }
    _prayerStatus = 'ইশার ওয়াক্ত চলছে';
    _setCurrentPrayer('Isha');
  }

  void _setPrayerRange(
      String displayName, DateTime start, DateTime end, String prayerName) {
    _currentPrayer = displayName;
    _currentPrayerStart = _formatTime(start);
    _currentPrayerEnd = _formatTime(end);
    _currentIqamahTime = JamaatService.get(prayerName);
    _setCurrentPrayer(prayerName);
  }

  void _setCurrentPrayer(String prayerName) {
    for (final prayer in _prayers) {
      prayer['isCurrent'] = prayer['name'] == prayerName;
    }
  }

  void _clearCurrentPrayer() {
    for (final prayer in _prayers) {
      prayer['isCurrent'] = false;
    }
  }

  void _updateRemainingTime(
      {required Map<String, DateTime> times, required DateTime now}) {
    late final DateTime target;
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
      target = now.isBefore(_tahajjudStart!) ? _tahajjudStart! : _tahajjudEnd!;
    }
    _timeRemainingForNextPrayer = _formatDuration(target.difference(now));
  }

  void _updatePrayerProgress(
      {required Map<String, DateTime> times, required DateTime now}) {
    DateTime? start;
    DateTime? end;
    if (!now.isBefore(times['Fajr']!) && now.isBefore(times['Sunrise']!)) {
      start = times['Fajr'];
      end = times['Sunrise'];
    } else if (!now.isBefore(times['Dhuhr']!) && now.isBefore(times['Asr']!)) {
      start = times['Dhuhr'];
      end = times['Asr'];
    } else if (!now.isBefore(times['Asr']!) &&
        now.isBefore(times['Maghrib']!)) {
      start = times['Asr'];
      end = times['Maghrib'];
    } else if (!now.isBefore(times['Maghrib']!) &&
        now.isBefore(times['Isha']!)) {
      start = times['Maghrib'];
      end = times['Isha'];
    } else if (!now.isBefore(times['Isha']!)) {
      start = times['Isha'];
      end = _tahajjudEnd;
    }
    if (start == null || end == null) {
      _prayerProgress = 0.0;
      return;
    }
    final int totalSeconds = end.difference(start).inSeconds;
    final int elapsedSeconds = now.difference(start).inSeconds;
    _prayerProgress = totalSeconds <= 0
        ? 0.0
        : (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  void _updateDailyTimeInformation(
      {required Map<String, DateTime> times, required DateTime now}) {
    final DateTime sunrise = times['Sunrise']!;
    final DateTime dhuhr = times['Dhuhr']!;
    final DateTime zawalStart = dhuhr.subtract(const Duration(minutes: 10));
    final List<DateTime> prohibited =
        _prohibitedStart != null && _prohibitedEnd != null
            ? [_prohibitedStart!, _prohibitedEnd!]
            : [];
    if (prohibited.isEmpty) {
      _prohibitedTimeText = 'আজ আর কোনো নিষিদ্ধ সময় নেই';
    } else if (!now.isBefore(prohibited[0]) && now.isBefore(prohibited[1])) {
      if (prohibited[0] == sunrise) {
        _prohibitedTimeText = 'সূর্যোদয়ের সময় — নামাজ আদায় থেকে বিরত থাকুন';
      } else if (prohibited[0] == zawalStart) {
        _prohibitedTimeText = 'জাওয়ালের সময় — নামাজ আদায় থেকে বিরত থাকুন';
      } else {
        _prohibitedTimeText = 'সূর্যাস্তের সময় — নামাজ আদায় থেকে বিরত থাকুন';
      }
    } else {
      if (prohibited[0] == sunrise) {
        _prohibitedTimeText = 'পরবর্তী নিষিদ্ধ সময়: সূর্যোদয়';
      } else if (prohibited[0] == zawalStart) {
        _prohibitedTimeText = 'পরবর্তী নিষিদ্ধ সময়: জাওয়াল';
      } else {
        _prohibitedTimeText = 'পরবর্তী নিষিদ্ধ সময়: সূর্যাস্ত';
      }
    }
    final List<DateTime> makruh = _makruhStart != null && _makruhEnd != null
        ? [_makruhStart!, _makruhEnd!]
        : [];
    if (makruh.isEmpty) {
      _makruhTimeText = 'আজ আর কোনো বিশেষ মাকরূহ সময় নেই';
    } else if (!now.isBefore(makruh[0]) && now.isBefore(makruh[1])) {
      if (makruh[0] == sunrise.subtract(const Duration(minutes: 15))) {
        _makruhTimeText = 'সূর্যোদয়ের আশেপাশের মাকরূহ সময়';
      } else if (makruh[0] == zawalStart) {
        _makruhTimeText = 'জাওয়ালের আশেপাশের মাকরূহ সময়';
      } else {
        _makruhTimeText = 'সূর্যাস্তের আশেপাশের মাকরূহ সময়';
      }
    } else {
      if (makruh[0] == sunrise.subtract(const Duration(minutes: 15))) {
        _makruhTimeText = 'পরবর্তী মাকরূহ সময়: সূর্যোদয়';
      } else if (makruh[0] == zawalStart) {
        _makruhTimeText = 'পরবর্তী মাকরূহ সময়: জাওয়াল';
      } else {
        _makruhTimeText = 'পরবর্তী মাকরূহ সময়: সূর্যাস্ত';
      }
    }
  }

  DateTime _calculateTahajjudStart(
      {required DateTime now,
      required DateTime todayIsha,
      required DateTime tomorrowFajr}) {
    final Duration nightDuration = tomorrowFajr.difference(todayIsha);
    if (nightDuration.isNegative || nightDuration.inSeconds <= 0)
      return tomorrowFajr;
    final Duration lastThird =
        Duration(milliseconds: (nightDuration.inMilliseconds / 3).round());
    return tomorrowFajr.subtract(lastThird);
  }

  String _windowText(DateTime? start, DateTime? end) =>
      start == null || end == null
          ? '--:--'
          : '${_formatTime(start)} – ${_formatTime(end)}';

  DateTime _tomorrowPrayerTime(DateTime now, PrayerField field) {
    final Position? position = _position;
    if (position == null) return _fallbackPrayerTime(now, field);
    final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    final PrayerTimes tomorrowTimes = _prayerEngine.getPrayerTimes(
        position: position, date: tomorrow, config: _calculationConfig);
    switch (field) {
      case PrayerField.fajr:
        return tomorrowTimes.fajr;
      case PrayerField.sunrise:
        return tomorrowTimes.sunrise;
      case PrayerField.dhuhr:
        return tomorrowTimes.dhuhr;
      case PrayerField.asr:
        return tomorrowTimes.asr;
      case PrayerField.maghrib:
        return tomorrowTimes.maghrib;
      case PrayerField.isha:
        return tomorrowTimes.isha;
    }
  }

  DateTime _yesterdayPrayerTime(DateTime now, PrayerField field) {
    final Position? position = _position;
    final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    if (position == null) return _fallbackPrayerTime(yesterday, field);
    final PrayerTimes yesterdayTimes = _prayerEngine.getPrayerTimes(
        position: position, date: yesterday, config: _calculationConfig);
    final DateTime rawTime = switch (field) {
      PrayerField.fajr => yesterdayTimes.fajr,
      PrayerField.sunrise => yesterdayTimes.sunrise,
      PrayerField.dhuhr => yesterdayTimes.dhuhr,
      PrayerField.asr => yesterdayTimes.asr,
      PrayerField.maghrib => yesterdayTimes.maghrib,
      PrayerField.isha => yesterdayTimes.isha,
    };
    if (field == PrayerField.sunrise) return rawTime;
    final String prayerName = switch (field) {
      PrayerField.fajr => 'Fajr',
      PrayerField.dhuhr => 'Dhuhr',
      PrayerField.asr => 'Asr',
      PrayerField.maghrib => 'Maghrib',
      PrayerField.isha => 'Isha',
      PrayerField.sunrise => 'Sunrise',
    };
    return _applyPrayerAdjustment(prayerName, rawTime);
  }

  DateTime _fallbackPrayerTime(DateTime now, PrayerField field) {
    final DateTime day = DateTime(
        now.year,
        now.month,
        now.day +
            (field == PrayerField.fajr || field == PrayerField.sunrise
                ? 1
                : 0));
    switch (field) {
      case PrayerField.fajr:
        return DateTime(day.year, day.month, day.day, 5);
      case PrayerField.sunrise:
        return DateTime(day.year, day.month, day.day, 6);
      case PrayerField.dhuhr:
        return DateTime(day.year, day.month, day.day, 12);
      case PrayerField.asr:
        return DateTime(day.year, day.month, day.day, 15);
      case PrayerField.maghrib:
        return DateTime(day.year, day.month, day.day, 18);
      case PrayerField.isha:
        return DateTime(day.year, day.month, day.day, 19);
    }
  }

  String _formatTime(DateTime value) => DateFormat('hh:mm').format(value);

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _updateWithoutLocation() {
    _currentLocationName = 'লোকেশন পাওয়া যাচ্ছে না';
    _currentPrayer = 'লোকেশন প্রয়োজন';
    _previousPrayer = '';
    _nextPrayerName = 'লোকেশন প্রয়োজন';
    _nextPrayer = 'লোকেশন প্রয়োজন';
    _nextPrayerTime = '--:--';
    _currentPrayerStart = '--:--';
    _currentPrayerEnd = '--:--';
    _currentIqamahTime = '--:--';
    _timeRemainingForNextPrayer = '00:00:00';
    _sunriseTime = '--:--';
    _sunsetTime = '--:--';
    _solarNoonTime = '--:--';
    _prayerProgress = 0.0;
    _prayerStatus = 'লোকেশন দিলে লাইভ সালাতের সময় দেখাবে';
    _prayers.clear();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
