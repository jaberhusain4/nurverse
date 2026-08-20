import 'package:shared_preferences/shared_preferences.dart';

class LastReadService {
  static const String _surahNameKey = 'last_read_surah_name';
  static const String _paraNoKey = 'last_read_para_no';
  static const String _pageNoKey = 'last_read_page_no';
  static const String _progressKey = 'last_read_progress';
  static const String _modeKey = 'last_read_mode';
  static const String _surahNumberKey = 'last_read_surah_number';
  static const String _ayahNumberKey = 'last_read_ayah_number';

  static Future<void> saveLastRead({
    required String surahName,
    required int paraNo,
    required int pageNo,
    required double progress,
    String mode = 'onudhabon',
    int? surahNumber,
    int? ayahNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_surahNameKey, surahName);
    await prefs.setInt(_paraNoKey, paraNo);
    await prefs.setInt(_pageNoKey, pageNo);
    await prefs.setDouble(_progressKey, progress.clamp(0.0, 1.0));
    await prefs.setString(_modeKey, mode);

    if (surahNumber != null) {
      await prefs.setInt(_surahNumberKey, surahNumber);
    }
    if (ayahNumber != null) {
      await prefs.setInt(_ayahNumberKey, ayahNumber);
    }
  }

  static Future<Map<String, dynamic>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final surahName = prefs.getString(_surahNameKey);

    if (surahName == null || surahName.isEmpty) {
      return null;
    }

    final surahNumber = prefs.getInt(_surahNumberKey);
    final ayahNumber = prefs.getInt(_ayahNumberKey);

    // Continue Reading is an Onudhabon action. Always normalize an existing
    // saved reading record to Onudhabon so stale mode values from older app
    // versions can never send the user to the generic Quran tab.
    const mode = 'onudhabon';

    return {
      'surahName': surahName,
      'paraNo': prefs.getInt(_paraNoKey) ?? 1,
      'pageNo': prefs.getInt(_pageNoKey) ?? 1,
      'progress': prefs.getDouble(_progressKey) ?? 0.0,
      'mode': mode,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
    };
  }

  static Future<void> clearLastRead() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_surahNameKey);
    await prefs.remove(_paraNoKey);
    await prefs.remove(_pageNoKey);
    await prefs.remove(_progressKey);
    await prefs.remove(_modeKey);
    await prefs.remove(_surahNumberKey);
    await prefs.remove(_ayahNumberKey);
  }
}
