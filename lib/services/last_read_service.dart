import 'package:shared_preferences/shared_preferences.dart';

class LastReadService {
  static const String _surahNameKey = 'last_read_surah_name';
  static const String _paraNoKey = 'last_read_para_no';
  static const String _pageNoKey = 'last_read_page_no';
  static const String _progressKey = 'last_read_progress';

  // ============================================================
  // SAVE LAST READ
  // ============================================================

  static Future<void> saveLastRead({
    required String surahName,
    required int paraNo,
    required int pageNo,
    required double progress,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_surahNameKey, surahName);

    await prefs.setInt(_paraNoKey, paraNo);

    await prefs.setInt(_pageNoKey, pageNo);

    await prefs.setDouble(_progressKey, progress.clamp(0.0, 1.0));
  }

  // ============================================================
  // GET LAST READ
  // ============================================================

  static Future<Map<String, dynamic>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();

    final surahName = prefs.getString(_surahNameKey);

    if (surahName == null || surahName.isEmpty) {
      return null;
    }

    return {
      'surahName': surahName,
      'paraNo': prefs.getInt(_paraNoKey) ?? 1,
      'pageNo': prefs.getInt(_pageNoKey) ?? 1,
      'progress': prefs.getDouble(_progressKey) ?? 0.0,
    };
  }

  // ============================================================
  // CLEAR LAST READ
  // ============================================================

  static Future<void> clearLastRead() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_surahNameKey);
    await prefs.remove(_paraNoKey);
    await prefs.remove(_pageNoKey);
    await prefs.remove(_progressKey);
  }
}
