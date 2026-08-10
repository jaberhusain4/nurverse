// lib/services/hadith_chapter_stats_service.dart

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class HadithChapterStats {
  final int count;
  final int firstHadith;
  final int lastHadith;

  const HadithChapterStats({
    required this.count,
    required this.firstHadith,
    required this.lastHadith,
  });
}

class HadithChapterStatsService {
  HadithChapterStatsService._();

  static final HadithChapterStatsService instance =
      HadithChapterStatsService._();

  final Map<String, Map<int, HadithChapterStats>> _cache = {};

  Future<Map<int, HadithChapterStats>> getAllStats(String bookKey) {
    return _loadBook(bookKey);
  }

  Future<HadithChapterStats?> getStats(
    String bookKey,
    int chapterId,
  ) async {
    final stats = await _loadBook(bookKey);
    return stats[chapterId];
  }

  Future<Map<int, HadithChapterStats>> _loadBook(String bookKey) async {
    final cached = _cache[bookKey];
    if (cached != null) return cached;

    final path = 'assets/hadith/ara-$bookKey.json';
    final raw = await rootBundle.loadString(path);
    final decoded = jsonDecode(raw);

    final result = <int, HadithChapterStats>{};

    if (decoded is Map) {
      final metadata = decoded['metadata'];
      if (metadata is Map) {
        final details = metadata['section_details'];
        if (details is Map) {
          for (final entry in details.entries) {
            final chapterId = int.tryParse(entry.key.toString());
            final value = entry.value;

            if (chapterId == null || value is! Map) continue;

            final first = _toInt(value['hadithnumber_first']);
            final last = _toInt(value['hadithnumber_last']);

            if (first == null || last == null || first <= 0 || last < first) {
              continue;
            }

            result[chapterId] = HadithChapterStats(
              count: last - first + 1,
              firstHadith: first,
              lastHadith: last,
            );
          }
        }
      }
    }

    _cache[bookKey] = result;
    return result;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '');
  }

  void clearCache() => _cache.clear();
}
