// lib/services/location_service.dart

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  const LocationService();

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
  // IMPORTANT:
  // GPS/location calculation does NOT require internet.
  //
  // This method intentionally returns Position independently of address
  // lookup or reverse geocoding.
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

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
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
