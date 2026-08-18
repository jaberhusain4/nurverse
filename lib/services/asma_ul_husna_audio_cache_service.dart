import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Persistent cache for Asma ul Husna audio.
///
/// Behaviour:
/// - If the requested audio is already cached, return it immediately.
/// - If it is not cached, download it once and persist it.
/// - A cached file is never re-downloaded just because the device is offline.
class AsmaUlHusnaAudioCacheService {
  AsmaUlHusnaAudioCacheService._();

  static final AsmaUlHusnaAudioCacheService instance =
      AsmaUlHusnaAudioCacheService._();

  static const String _baseUrl =
      'https://commons.wikimedia.org/wiki/Special:Redirect/file/';
  static const String _cachePrefix = 'asma-husna-audio/';

  final CacheManager _cache = CacheManager(
    Config(
      'nurverse_asma_husna_audio',
      stalePeriod: const Duration(days: 3650),
      maxNrOfCacheObjects: 120,
    ),
  );

  String urlFor(String fileName) =>
      '$_baseUrl${Uri.encodeComponent(fileName)}';

  String _key(String fileName) => '$_cachePrefix$fileName';

  /// Returns a cached file immediately when available.
  ///
  /// Only a cache miss is allowed to touch the network. This is important
  /// for true offline playback: cached audio must never wait for the network.
  Future<File> getFile(String fileName) async {
    final key = _key(fileName);

    final cached = await _cache.getFileFromCache(key);
    if (cached != null && await cached.file.exists()) {
      return cached.file;
    }

    // Cache miss: this is the only point where a network request is made.
    return _cache.getSingleFile(urlFor(fileName), key: key);
  }

  Future<bool> isCached(String fileName) async {
    final cached = await _cache.getFileFromCache(_key(fileName));
    return cached != null && await cached.file.exists();
  }

  Future<File?> getCachedFile(String fileName) async {
    final cached = await _cache.getFileFromCache(_key(fileName));
    if (cached == null || !await cached.file.exists()) return null;
    return cached.file;
  }
}
