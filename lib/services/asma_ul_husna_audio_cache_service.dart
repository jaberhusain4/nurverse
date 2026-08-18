import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Permanent offline storage for the 99 Names of Allah audio library.
///
/// Valid local files are always preferred. Playback never contacts the
/// network when a valid file already exists on the device.
class AsmaUlHusnaAudioCacheService {
  AsmaUlHusnaAudioCacheService._();

  static final AsmaUlHusnaAudioCacheService instance =
      AsmaUlHusnaAudioCacheService._();

  static const String _baseUrl =
      'https://commons.wikimedia.org/wiki/Special:Redirect/file/';
  static const int _maxConcurrentDownloads = 1;
  static const int _maxAttempts = 4;
  static const Duration _downloadTimeout = Duration(seconds: 45);

  Directory? _audioDirectory;
  final http.Client _client = http.Client();

  Future<Directory> _getAudioDirectory() async {
    if (_audioDirectory != null) return _audioDirectory!;
    final root = await getApplicationSupportDirectory();
    final directory = Directory(p.join(root.path, 'asma_ul_husna_audio'));
    if (!await directory.exists()) await directory.create(recursive: true);
    _audioDirectory = directory;
    return directory;
  }

  String urlFor(String fileName) =>
      '$_baseUrl${Uri.encodeComponent(fileName)}';

  Future<File> _localFile(String fileName) async {
    final directory = await _getAudioDirectory();
    return File(p.join(directory.path, fileName));
  }

  Future<bool> _isValidOgg(File file) async {
    try {
      if (!await file.exists() || await file.length() < 4) return false;
      final bytes = await file.openRead(0, 4).fold<List<int>>(
        <int>[],
        (previous, chunk) => previous..addAll(chunk),
      );
      return bytes.length >= 4 &&
          bytes[0] == 0x4f &&
          bytes[1] == 0x67 &&
          bytes[2] == 0x67 &&
          bytes[3] == 0x53;
    } catch (_) {
      return false;
    }
  }

  Future<File?> getCachedFile(String fileName) async {
    final file = await _localFile(fileName);
    if (await _isValidOgg(file)) return file;
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
    return null;
  }

  Future<File> getFile(String fileName) async {
    final cached = await getCachedFile(fileName);
    if (cached != null) return cached;

    final target = await _localFile(fileName);
    final temporary = File('${target.path}.download');
    Object? lastError;

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        if (await temporary.exists()) await temporary.delete();
        final response = await _client
            .get(
              Uri.parse(urlFor(fileName)),
              headers: const {
                'User-Agent': 'NurVerse/1.0',
                'Accept': 'audio/ogg,application/ogg,*/*;q=0.8',
              },
            )
            .timeout(_downloadTimeout);

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw HttpException(
            'Audio server returned HTTP ${response.statusCode}.',
          );
        }
        if (response.bodyBytes.length < 4) {
          throw const HttpException('Downloaded audio is empty.');
        }

        await temporary.writeAsBytes(response.bodyBytes, flush: true);
        if (!await _isValidOgg(temporary)) {
          throw const FormatException('Downloaded file is not a valid OGG audio file.');
        }

        if (await target.exists()) await target.delete();
        await temporary.rename(target.path);
        final saved = await getCachedFile(fileName);
        if (saved == null) {
          throw const FormatException('Saved audio failed local verification.');
        }
        return saved;
      } catch (error) {
        lastError = error;
        try {
          if (await temporary.exists()) await temporary.delete();
        } catch (_) {}
        if (attempt < _maxAttempts) {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      }
    }

    throw lastError ?? const HttpException('Audio download failed.');
  }

  Future<bool> isCached(String fileName) async =>
      await getCachedFile(fileName) != null;

  /// Stable resumable queue. One file at a time avoids Wikimedia connection
  /// throttling; valid files are skipped, and only missing files are retried.
  Future<List<String>> downloadAll(
    List<String> fileNames, {
    void Function(int completed, int total)? onProgress,
  }) async {
    if (fileNames.isEmpty) return const [];

    var completed = await downloadedCount(fileNames);
    onProgress?.call(completed, fileNames.length);

    final missing = <String>[];
    for (final fileName in fileNames) {
      if (await isCached(fileName)) continue;
      try {
        await getFile(fileName);
        completed++;
        onProgress?.call(completed, fileNames.length);
      } catch (_) {
        missing.add(fileName);
        // Keep going. A single bad/slow source must never stop the other 98.
        onProgress?.call(completed, fileNames.length);
      }
    }

    // Re-scan the device so the completion state is authoritative.
    final stillMissing = <String>[];
    for (final fileName in fileNames) {
      if (!await isCached(fileName)) stillMissing.add(fileName);
    }
    onProgress?.call(
      fileNames.length - stillMissing.length,
      fileNames.length,
    );
    return stillMissing;
  }

  Future<int> downloadedCount(List<String> fileNames) async {
    var count = 0;
    for (final fileName in fileNames) {
      if (await isCached(fileName)) count++;
    }
    return count;
  }

  Future<bool> isAllDownloaded(List<String> fileNames) async {
    if (fileNames.length != 99) return false;
    for (final fileName in fileNames) {
      if (!await isCached(fileName)) return false;
    }
    return true;
  }

  void dispose() => _client.close();
}
