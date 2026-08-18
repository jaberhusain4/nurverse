import 'dart:async';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Persistent cache for Asma ul Husna audio.
///
/// Behaviour:
/// - If the requested audio is already cached, return it immediately.
/// - If it is not cached, download it once and persist it.
/// - A cached file is never re-downloaded just because the device is offline.
/// - A network/cache operation can never leave the UI waiting forever.
class AsmaUlHusnaAudioCacheService {
  AsmaUlHusnaAudioCacheService._();

  static final AsmaUlHusnaAudioCacheService instance =
      AsmaUlHusnaAudioCacheService._();

  static const String _baseUrl =
      'https://commons.wikimedia.org/wiki/Special:Redirect/file/';
  static const String _cachePrefix = 'asma-husna-audio/';
  static const Duration _downloadTimeout = Duration(seconds: 20);

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

  /// Returns a cached file without making a network request.
  Future<File?> getCachedFile(String fileName) async {
    final cached = await _cache.getFileFromCache(_key(fileName));
    if (cached == null) return null;

    final file = cached.file;
    if (!await file.exists()) return null;
    return file;
  }

  /// Cache-first playback source.
  ///
  /// Network is touched only after a genuine cache miss. The download is
  /// bounded so an unavailable/slow server cannot keep the player spinner
  /// running forever.
  Future<File> getFile(String fileName) async {
    final cached = await getCachedFile(fileName);
    if (cached != null) return cached;

    final key = _key(fileName);
    try {
      return await _cache
          .getSingleFile(urlFor(fileName), key: key)
          .timeout(_downloadTimeout);
    } on TimeoutException {
      throw TimeoutException(
        'Audio download timed out after ${_downloadTimeout.inSeconds} seconds.',
      );
    }
  }

  Future<bool> isCached(String fileName) async {
    return await getCachedFile(fileName) != null;
  }
}
