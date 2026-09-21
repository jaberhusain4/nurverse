import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  const LocationService();

  static const Duration _startupCacheMaxAge = Duration(minutes: 10);
  static const Duration _freshLocationTimeout = Duration(seconds: 15);
  static const double _maxAcceptedAccuracyMeters = 2000;
  static const String _latitudeKey = 'nurverse_cached_latitude';
  static const String _longitudeKey = 'nurverse_cached_longitude';
  static const String _timestampKey = 'nurverse_cached_location_timestamp';
  static const String _addressKey = 'nurverse_cached_location_address';

  Future<bool> isLocationEnabled() async =>
      Geolocator.isLocationServiceEnabled();

  Future<LocationPermission> requestPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  Future<Position> getCurrentPosition() async {
    final cached = await getPersistedPosition();

    if (!await isLocationEnabled()) {
      if (cached != null && _isUsablePosition(cached)) return cached;
      throw Exception(
        'Location service is disabled and the cached location is stale or inaccurate.',
      );
    }

    final permission = await requestPermission();
    if (permission == LocationPermission.denied) {
      if (cached != null && _isUsablePosition(cached)) return cached;
      throw Exception('Location permission denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      if (cached != null && _isUsablePosition(cached)) return cached;
      throw Exception('Location permission permanently denied.');
    }

    try {
      final fresh = await _getFreshPosition();
      if (_isUsablePosition(fresh)) return fresh;
    } catch (_) {
      // Fall through to the safest recent local fallback.
    }

    final lastKnown = await getLastKnownPosition();
    if (_isUsablePosition(lastKnown)) {
      await _savePosition(lastKnown!);
      return lastKnown;
    }

    if (cached != null && _isUsablePosition(cached)) return cached;

    throw Exception('Unable to obtain a recent accurate location.');
  }

  Future<Position> getFreshCurrentPosition() async {
    if (!await isLocationEnabled()) {
      throw Exception('Location service is disabled.');
    }

    final permission = await requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    return _getFreshPosition();
  }

  Future<Position> _getFreshPosition() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    ).timeout(_freshLocationTimeout);

    if (!_isUsablePosition(position)) {
      throw Exception(
        'Fresh location is too old or inaccurate for prayer-time calculation.',
      );
    }

    await _savePosition(position);
    return position;
  }

  bool _isUsablePosition(Position? position) {
    if (position == null || !_isRecentEnough(position)) return false;
    final accuracy = position.accuracy;
    if (!accuracy.isFinite || accuracy < 0) return false;
    return accuracy == 0 || accuracy <= _maxAcceptedAccuracyMeters;
  }

  bool _isRecentEnough(Position? position) {
    if (position == null) return false;
    final age = DateTime.now().difference(position.timestamp);
    return !age.isNegative && age <= _startupCacheMaxAge;
  }

  Future<void> _savePosition(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_latitudeKey, position.latitude);
      await prefs.setDouble(_longitudeKey, position.longitude);
      await prefs.setInt(
        _timestampKey,
        position.timestamp.millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  Future<Position?> getPersistedPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final latitude = prefs.getDouble(_latitudeKey);
      final longitude = prefs.getDouble(_longitudeKey);
      final timestampMs = prefs.getInt(_timestampKey);

      if (latitude == null || longitude == null || timestampMs == null) {
        return null;
      }

      return Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
        isMocked: false,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> getPersistedAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_addressKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveAddress(String address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_addressKey, address);
    } catch (_) {}
  }

  Future<Position> getCurrentLocation() => getCurrentPosition();

  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  Future<Position> getBestAvailablePosition() async {
    final lastKnown = await getLastKnownPosition();
    if (_isUsablePosition(lastKnown)) {
      await _savePosition(lastKnown!);
      return lastKnown;
    }

    final persisted = await getPersistedPosition();
    if (_isUsablePosition(persisted)) return persisted!;

    return getCurrentPosition();
  }

  Future<String?> getAddress(Position position) async {
    try {
      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (places.isEmpty) return getPersistedAddress();

      final place = places.first;
      final subLocality = place.subLocality?.trim() ?? '';
      final locality = place.locality?.trim() ?? '';
      final district = place.subAdministrativeArea?.trim() ?? '';
      final country = place.country?.trim() ?? '';
      final parts = <String>[];

      void addIfUnique(String value) {
        if (value.isEmpty) return;
        if (_looksLikePlusCode(value) || _looksLikeCoordinates(value)) return;
        if (parts.any(
          (existing) => existing.toLowerCase() == value.toLowerCase(),
        )) {
          return;
        }
        parts.add(value);
      }

      addIfUnique(subLocality);
      addIfUnique(locality);
      addIfUnique(district);
      addIfUnique(country);

      if (parts.isEmpty) return getPersistedAddress();

      final address = parts.join(', ');
      await _saveAddress(address);
      return address;
    } catch (_) {
      return getPersistedAddress();
    }
  }

  bool _looksLikePlusCode(String value) {
    final normalized = value.replaceAll(' ', '').toUpperCase();
    return normalized.contains('+') && normalized.length <= 12;
  }

  bool _looksLikeCoordinates(String value) {
    final coordinatePattern = RegExp(
      r'^[-+]?\d+(\.\d+)?\s*[, ]\s*[-+]?\d+(\.\d+)?$',
    );
    return coordinatePattern.hasMatch(value.trim());
  }

  Future<String> getSafeAddress(Position position) async {
    final address = await getAddress(position);
    return address != null && address.trim().isNotEmpty
        ? address
        : _formatCoordinates(position);
  }

  Future<(Position, String)> getLocationWithAddress() async {
    final position = await getCurrentPosition();
    return (position, await getSafeAddress(position));
  }

  Future<(Position, String?)> getLocationWithOptionalAddress() async {
    final position = await getCurrentPosition();
    return (position, await getAddress(position));
  }

  String _formatCoordinates(Position position) =>
      '${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)}';
}
