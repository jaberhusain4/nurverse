import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide bold text accessibility preference for NurVerse.
///
/// This preference is intentionally independent from TextScaleProvider so
/// users can combine any text size with either normal or bold text.
class BoldTextProvider extends ChangeNotifier {
  static const String _storageKey = 'app_bold_text';

  bool _isBold = false;
  bool _isLoading = true;

  BoldTextProvider() {
    _load();
  }

  bool get isBold => _isBold;
  bool get isLoading => _isLoading;

  Future<void> _load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _isBold = prefs.getBool(_storageKey) ?? false;
    } catch (_) {
      _isBold = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setBold(bool value) async {
    if (_isBold == value) return;

    _isBold = value;
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_storageKey, _isBold);
    } catch (_) {}
  }

  Future<void> toggle() async => setBold(!_isBold);

  Future<void> reset() async => setBold(false);
}
