import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeModeService extends ChangeNotifier {
  HomeModeService._();

  static final HomeModeService instance = HomeModeService._();

  static const String _key = 'home_screen_mode';

  // Informative Home is NurVerse's default for new installs.
  bool _isSimple = false;
  bool _loaded = false;

  bool get isSimple => _isSimple;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_key);
      // Preserve an explicitly saved user choice. New installs/default state
      // use Informative Home until the user selects Simple Home.
      _isSimple = stored == 'simple';
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
    } catch (_) {
      // Keep the in-memory choice active even if persistence fails.
    }
  }

  Future<void> reset() => setSimple(false);
}
