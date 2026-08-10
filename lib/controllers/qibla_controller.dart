import 'package:flutter/foundation.dart';

import '../services/location_service.dart';
import '../services/qibla_service.dart';

class QiblaController extends ChangeNotifier {
  final LocationService _location = const LocationService();
  final QiblaService _qibla = QiblaService();

  double _qiblaBearing = 0;
  double get qiblaBearing => _qiblaBearing;

  bool _initialized = false;
  bool get initialized => _initialized;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final position = await _location.getCurrentLocation();
      _qiblaBearing = _qibla.getQiblaDirection(
        position.latitude,
        position.longitude,
      );
      _initialized = true;
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }
}
