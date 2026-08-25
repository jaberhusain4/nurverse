import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeModeService extends ChangeNotifier {
  HomeModeService._();

  static final HomeModeService instance = HomeModeService._();

  static const String _key = 'home_screen_mode';
  static const String _defaultMigrationKey = 'home_mode_informative_default_applied_v1';

  // Informative Home is the current NurVerse default.
  bool _isSimple = false;
  bool _loaded = false;

  bool get isSimple => _isSimple;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final migrationApplied = prefs.getBool(_defaultMigrationKey) ?? false;
      final stored = prefs.getString(_key);

      // One-time migration: installs that previously used the old Simple
      // default are moved to Informative once. Afterward explicit user choice
      // is preserved normally.
      if (!migrationApplied) {
        _isSimple = false;
        await prefs.setString(_key, 'informative');
        await prefs.setBool(_defaultMigrationKey, true);
      } else {
        _isSimple = stored == 'simple';
      }
    } catch (_) {
      _isSimple = false;
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> setSimple(bool value) async {
    _isSimple = value;
    _loaded = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, value ? 'simple' : 'informative');
      await prefs.setBool(_defaultMigrationKey, true);
    } catch (_) {
      // Keep the in-memory choice active even if persistence fails.
    }
  }

  Future<void> reset() => setSimple(false);
}
