import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Downloads Asma ul Husna audio once and keeps it in persistent local cache.
/// First play: network -> cache -> local file playback.
/// Later plays: local cache -> immediate playback, with no network required.
class AsmaUlHusnaAudioCacheService {
  AsmaUlHusnaAudioCacheService._();

  static final AsmaUlHusnaAudioCacheService instance =
      AsmaUlHusnaAudioCacheService._();

  static const String _baseUrl =
      'https://commons.wikimedia.org/wiki/Special:Redirect/file/';

  final CacheManager _cache = CacheManager(
    Config(
      'nurverse_asma_husna_audio',
      stalePeriod: const Duration(days: 3650),
      maxNrOfCacheObjects: 120,
    ),
  );

  String urlFor(String fileName) =>
      '$_baseUrl${Uri.encodeComponent(fileName)}';

  Future<File> getFile(String fileName) async {
    final key = 'asma-husna-audio/$fileName';
    final cached = await _cache.getFileFromCache(key);
    if (cached != null && await cached.file.exists()) {
      return cached.file;
    }

    // Download once. CacheManager stores the bytes persistently.
    final file = await _cache.getSingleFile(urlFor(fileName), key: key);
    return file;
  }

  Future<bool> isCached(String fileName) async {
    final cached = await _cache.getFileFromCache('asma-husna-audio/$fileName');
    return cached != null && await cached.file.exists();
  }
}
