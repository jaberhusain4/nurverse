import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  static const String _languageKey = 'app_language';

  Locale _locale = const Locale('bn');

  Locale get locale => _locale;

  bool get isBangla => _locale.languageCode == 'bn';

  bool get isEnglish => _locale.languageCode == 'en';

  // ============================================================
  // LOAD SAVED LANGUAGE
  // ============================================================

  Future<void> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedLanguage = prefs.getString(_languageKey);

      if (savedLanguage == 'en') {
        _locale = const Locale('en');
      } else {
        _locale = const Locale('bn');
      }

      notifyListeners();
    } catch (_) {
      // Keep Bangla as the safe default.
    }
  }

  // ============================================================
  // SET LANGUAGE
  // ============================================================

  Future<void> setLanguage(String languageCode) async {
    final normalizedCode = languageCode.toLowerCase();

    // NurVerse currently supports Bangla and English.
    if (normalizedCode != 'bn' && normalizedCode != 'en') {
      return;
    }

    final newLocale = Locale(normalizedCode);

    if (_locale.languageCode == newLocale.languageCode) {
      return;
    }

    _locale = newLocale;

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_languageKey, normalizedCode);
    } catch (_) {
      // UI already changed; keep the current in-memory language.
    }
  }

  // ============================================================
  // SHORTCUTS
  // ============================================================

  Future<void> setBangla() async {
    await setLanguage('bn');
  }

  Future<void> setEnglish() async {
    await setLanguage('en');
  }
}
