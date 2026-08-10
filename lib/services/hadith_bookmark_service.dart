// lib/services/hadith_bookmark_service.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_hadith.dart';

class HadithBookmarkService {
  HadithBookmarkService._();

  static final HadithBookmarkService instance = HadithBookmarkService._();

  static const String _storageKey = 'nurverse_saved_hadiths';

  Future<List<SavedHadith>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? const <String>[];
    final result = <SavedHadith>[];

    for (final item in raw) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>) {
          result.add(SavedHadith.fromJson(decoded));
        }
      } catch (_) {
        // Ignore malformed legacy entries safely.
      }
    }

    result.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return result;
  }

  Future<List<SavedHadith>> getAll() => _load();

  Future<bool> isSaved(String key) async {
    final items = await _load();
    return items.any((item) => item.key == key);
  }

  Future<void> save(SavedHadith hadith) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await _load();
    items.removeWhere((item) => item.key == hadith.key);
    items.insert(0, hadith);
    await prefs.setStringList(
      _storageKey,
      items.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await _load();
    items.removeWhere((item) => item.key == key);
    await prefs.setStringList(
      _storageKey,
      items.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<bool> toggle(SavedHadith hadith) async {
    final saved = await isSaved(hadith.key);
    if (saved) {
      await remove(hadith.key);
      return false;
    }
    await save(hadith);
    return true;
  }

  String buildKey({
    required String bookKey,
    required String hadithNo,
    required String arabic,
  }) {
    final source = '$bookKey|$hadithNo|$arabic';
    return base64UrlEncode(utf8.encode(source));
  }
}
