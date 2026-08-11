import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controls NurVerse's app-wide text scaling without changing the platform's
/// accessibility setting.
///
/// The value is intentionally kept in a small, dedicated provider so global
/// typography can evolve independently from Quran-specific font preferences.
class TextScaleProvider extends ChangeNotifier {
  static const String _storageKey = 'app_text_scale';

  static const double minScale = 0.85;
  static const double maxScale = 1.25;
  static const double defaultScale = 1.0;

  double _scale = defaultScale;
  bool _isLoading = true;

  TextScaleProvider() {
    _load();
  }

  double get scale => _scale;
  bool get isLoading => _isLoading;

  String get label {
    if (_scale < 0.95) return 'ছোট';
    if (_scale > 1.05) return 'বড়';
    return 'স্বাভাবিক';
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getDouble(_storageKey);

      if (saved != null && saved.isFinite) {
        _scale = saved.clamp(minScale, maxScale).toDouble();
      }
    } catch (_) {
      _scale = defaultScale;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setScale(double value) async {
    final normalized = value.clamp(minScale, maxScale).toDouble();

    if ((_scale - normalized).abs() < 0.001) {
      return;
    }

    _scale = normalized;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_storageKey, _scale);
    } catch (_) {
      // Keep the in-memory value active even if persistence is temporarily
      // unavailable. The next app launch will fall back safely.
    }
  }

  Future<void> increase() => setScale(_scale + 0.05);

  Future<void> decrease() => setScale(_scale - 0.05);

  Future<void> reset() => setScale(defaultScale);
}
