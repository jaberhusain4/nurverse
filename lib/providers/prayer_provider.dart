import 'package:flutter/material.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class PrayerProvider extends ChangeNotifier {
  bool isLoading = true;
  Position? position;

  final LocationService _locationService = LocationService();

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    position = await _locationService.getCurrentLocation();

    isLoading = false;
    notifyListeners();
  }
}
