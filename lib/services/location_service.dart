import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  const LocationService();

  static const Duration _startupCacheMaxAge = Duration(minutes: 30);

  // ==========================================================================
  // LOCATION SERVICE STATUS
  // ==========================================================================

  Future<bool> isLocationEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  // ==========================================================================
  // PERMISSION
  // ==========================================================================

  Future<LocationPermission> requestPermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  // ==========================================================================
  // CURRENT POSITION
  // ==========================================================================

  Future<Position> getCurrentPosition() async {
    final enabled = await isLocationEnabled();

    if (!enabled) {
      throw Exception('Location service is disabled.');
    }

    final permission = await requestPermission();

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    final lastKnown = await getLastKnownPosition();

    if (_isRecentEnough(lastKnown)) {
      return lastKnown!;
    }

    return _getFreshPosition();
  }

  Future<Position> getFreshCurrentPosition() async {
    final enabled = await isLocationEnabled();

    if (!enabled) {
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

  Future<Position> _getFreshPosition() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  bool _isRecentEnough(Position? position) {
    if (position == null) return false;

    final age = DateTime.now().difference(position.timestamp);

    return !age.isNegative && age <= _startupCacheMaxAge;
  }

  // ==========================================================================
  // COMPATIBILITY API
  // ==========================================================================

  Future<Position> getCurrentLocation() {
    return getCurrentPosition();
  }

  // ==========================================================================
  // LAST KNOWN POSITION
  // ==========================================================================

  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  // ==========================================================================
  // OFFLINE-FIRST POSITION
  // ==========================================================================

  Future<Position> getBestAvailablePosition() async {
    final lastKnown = await getLastKnownPosition();

    if (lastKnown != null) {
      return lastKnown;
    }

    return getCurrentPosition();
  }

  // ==========================================================================
  // REVERSE GEOCODING
  // ==========================================================================
  //
  // Returns a short, human-friendly hierarchy only:
  // Locality/Sub-locality -> City/District -> Division -> Country.
  // Street names, house/road details, postal codes and plus codes are omitted.
  // ==========================================================================

  Future<String?> getAddress(Position position) async {
    try {
      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (places.isEmpty) {
        return null;
      }

      final place = places.first;

      final subLocality = place.subLocality?.trim() ?? '';
      final locality = place.locality?.trim() ?? '';
      final district = place.subAdministrativeArea?.trim() ?? '';
      final administrativeArea = place.administrativeArea?.trim() ?? '';
      final country = place.country?.trim() ?? '';

      final parts = <String>[];

      void addIfUnique(String value) {
        if (value.isEmpty) {
          return;
        }

        // Plus codes / coordinate-like values are not useful as a display
        // location and should never appear in the Home Screen address.
        if (_looksLikePlusCode(value) || _looksLikeCoordinates(value)) {
          return;
        }

        if (parts.any(
          (existing) => existing.toLowerCase() == value.toLowerCase(),
        )) {
          return;
        }

        parts.add(value);
      }

      // Keep the most useful human-readable hierarchy. In Bangladesh,
      // subLocality + locality + district commonly produces values such as:
      // "Nagar Konda, Savar, Dhaka".
      addIfUnique(subLocality);
      addIfUnique(locality);
      addIfUnique(district);
      addIfUnique(administrativeArea);
      addIfUnique(country);

      if (parts.isEmpty) {
        return null;
      }

      return parts.join(', ');
    } catch (_) {
      // Reverse geocoding failure must NEVER break offline core features.
      return null;
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

  // ==========================================================================
  // SAFE ADDRESS
  // ==========================================================================

  Future<String> getSafeAddress(Position position) async {
    final address = await getAddress(position);

    if (address != null && address.trim().isNotEmpty) {
      return address;
    }

    return _formatCoordinates(position);
  }

  // ==========================================================================
  // LOCATION + ADDRESS
  // ==========================================================================

  Future<(Position, String)> getLocationWithAddress() async {
    final position = await getCurrentPosition();

    final address = await getSafeAddress(position);

    return (position, address);
  }

  // ==========================================================================
  // LOCATION + OPTIONAL ADDRESS
  // ==========================================================================

  Future<(Position, String?)> getLocationWithOptionalAddress() async {
    final position = await getCurrentPosition();

    final address = await getAddress(position);

    return (position, address);
  }

  // ==========================================================================
  // COORDINATE FALLBACK
  // ==========================================================================

  String _formatCoordinates(Position position) {
    return '${position.latitude.toStringAsFixed(3)}, '
        '${position.longitude.toStringAsFixed(3)}';
  }
}
