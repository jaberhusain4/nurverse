import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeModeService extends ChangeNotifier {
  HomeModeService._();

  static final HomeModeService instance = HomeModeService._();

  static const String _key = 'home_screen_mode';

  bool _isSimple = false;
  bool _loaded = false;

  bool get isSimple => _isSimple;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isSimple = prefs.getString(_key) == 'simple';
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
