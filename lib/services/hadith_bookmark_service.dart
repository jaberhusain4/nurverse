// lib/services/hadith_bookmark_service.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HadithBookmarkService {
  HadithBookmarkService._();

  static final HadithBookmarkService instance = HadithBookmarkService._();

  static const String _storageKey = 'nurverse_saved_hadiths';

  Future<Set<String>> _loadKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? const <String>[];
    return raw.toSet();
  }

  Future<bool> isSaved(String key) async {
    final keys = await _loadKeys();
    return keys.contains(key);
  }

  Future<bool> toggle(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = await _loadKeys();

    final saved = keys.contains(key);
    if (saved) {
      keys.remove(key);
    } else {
      keys.add(key);
    }

    await prefs.setStringList(_storageKey, keys.toList());
    return !saved;
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = await _loadKeys();
    keys.remove(key);
    await prefs.setStringList(_storageKey, keys.toList());
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
