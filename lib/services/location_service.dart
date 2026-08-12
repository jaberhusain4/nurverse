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
  //
  // OFFLINE-FIRST / FAST STARTUP:
  //
  // A recent last-known GPS position is good enough to calculate prayer times
  // immediately. A fresh high-accuracy GPS fix can take several seconds and
  // should not block the first Home screen when a recent position exists.
  //
  // If the cached position is missing or too old, a fresh GPS fix is requested.
  // This keeps the first calculation fast without accepting stale locations
  // indefinitely.
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

  /// Forces a fresh GPS position.
  ///
  /// Use this when the user explicitly requests a location refresh or when
  /// accuracy is more important than startup speed.
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
  //
  // Used by QiblaController / PrayerProvider and other existing code.
  // ==========================================================================

  Future<Position> getCurrentLocation() {
    return getCurrentPosition();
  }

  // ==========================================================================
  // LAST KNOWN POSITION
  // ==========================================================================
  //
  // This can work even when a fresh GPS fix is temporarily unavailable.
  // It is especially useful for offline-first startup.
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
  //
  // Strategy:
  //
  // 1. Try last known position first.
  // 2. If unavailable, request a fresh GPS position.
  //
  // This keeps location acquisition independent from internet access.
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
  // Address lookup is OPTIONAL.
  //
  // Prayer calculation, Qibla and other core features must NEVER depend on
  // this method succeeding.
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

      final street = place.street?.trim() ?? '';
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

        if (parts.any(
          (existing) => existing.toLowerCase() == value.toLowerCase(),
        )) {
          return;
        }

        parts.add(value);
      }

      addIfUnique(street);
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

  // ==========================================================================
  // SAFE ADDRESS
  // ==========================================================================
  //
  // Always returns something displayable.
  //
  // If reverse geocoding fails, coordinates are used as fallback.
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
  //
  // Address is best-effort only.
  // Position remains the authoritative data.
  // ==========================================================================

  Future<(Position, String)> getLocationWithAddress() async {
    final position = await getCurrentPosition();

    final address = await getSafeAddress(position);

    return (position, address);
  }

  // ==========================================================================
  // LOCATION + OPTIONAL ADDRESS
  // ==========================================================================
  //
  // Recommended API for offline-first core services.
  //
  // The Position is guaranteed independently of reverse geocoding.
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
