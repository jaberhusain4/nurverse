import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide typography scale for NurVerse.
/// Quran-specific typography remains separate from this app-wide setting.
class TextScaleProvider extends ChangeNotifier {
  static const String _storageKey = 'app_text_scale';

  static const double smallScale = 0.94;
  static const double normalScale = 1.0;
  static const double largeScale = 1.10;
  static const double extraLargeScale = 1.20;
  static const double defaultScale = normalScale;

  double _scale = defaultScale;
  bool _isLoading = true;

  TextScaleProvider() {
    _load();
  }

  double get scale => _scale;
  bool get isLoading => _isLoading;
  int get level {
    if ((_scale - smallScale).abs() < 0.03) return 0;
    if ((_scale - largeScale).abs() < 0.03) return 2;
    if ((_scale - extraLargeScale).abs() < 0.03) return 3;
    return 1;
  }

  static const List<double> levels = <double>[
    smallScale,
    normalScale,
    largeScale,
    extraLargeScale,
  ];

  /// Returns a stable localization key. The visible label must come from
  /// AppLocalizations so changing the app language changes it immediately.
  String get labelKey {
    switch (level) {
      case 0:
        return 'textSizeSmall';
      case 2:
        return 'textSizeLarge';
      case 3:
        return 'textSizeExtraLarge';
      default:
        return 'textSizeNormal';
    }
  }

  Future<void> _load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final double? saved = prefs.getDouble(_storageKey);
      if (saved != null && saved.isFinite) {
        _scale = _nearestLevel(saved);
      }
    } catch (_) {
      _scale = defaultScale;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setScale(double value) async {
    final double normalized = _nearestLevel(value);
    if ((_scale - normalized).abs() < 0.001) return;
    _scale = normalized;
    notifyListeners();
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_storageKey, _scale);
    } catch (_) {}
  }

  Future<void> setLevel(int level) async {
    final int normalizedLevel = level.clamp(0, levels.length - 1);
    await setScale(levels[normalizedLevel]);
  }

  Future<void> increase() async => setLevel(level + 1);
  Future<void> decrease() async => setLevel(level - 1);
  Future<void> reset() async => setScale(defaultScale);

  double _nearestLevel(double value) {
    double nearest = levels.first;
    double distance = (value - nearest).abs();
    for (final double candidate in levels.skip(1)) {
      final double candidateDistance = (value - candidate).abs();
      if (candidateDistance < distance) {
        nearest = candidate;
        distance = candidateDistance;
      }
    }
    return nearest;
  }
}
