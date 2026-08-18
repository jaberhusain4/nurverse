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

  // Keep enough parallel requests for good mobile throughput without
  // hammering Wikimedia with 99 simultaneous connections.
  static const int _maxConcurrentDownloads = 6;
  static const int _maxAttempts = 2;
  static const Duration _downloadTimeout = Duration(seconds: 30);

  Directory? _audioDirectory;
  final http.Client _client = http.Client();

  Future<Directory> _getAudioDirectory() async {
    if (_audioDirectory != null) return _audioDirectory!;

    final root = await getApplicationSupportDirectory();
    final directory = Directory(p.join(root.path, 'asma_ul_husna_audio'));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
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
      if (!await file.exists()) return false;
      if (await file.length() < 4) return false;

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

  /// Local-only lookup. Never performs a network request.
  Future<File?> getCachedFile(String fileName) async {
    final file = await _localFile(fileName);
    if (await _isValidOgg(file)) return file;

    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
    return null;
  }

  /// Gets a permanent local file. Downloads only when it is missing.
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
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    throw lastError ?? const HttpException('Audio download failed.');
  }

  Future<bool> isCached(String fileName) async {
    return await getCachedFile(fileName) != null;
  }

  /// Downloads all missing audio files with limited parallelism.
  ///
  /// Progress counts only completed download attempts. A file is counted as
  /// successful only after local OGG validation. Failed files are returned so
  /// the UI can offer a retry instead of incorrectly reporting 99/99.
  Future<List<String>> downloadAll(
    List<String> fileNames, {
    void Function(int completed, int total)? onProgress,
  }) async {
    if (fileNames.isEmpty) return const [];

    // Deduplicate source filenames while preserving order. The Wikimedia
    // collection legitimately contains repeated names at #48/#65 and
    // #55/#77, so the same local source is not downloaded twice.
    final uniqueFiles = <String>[];
    final seen = <String>{};
    for (final fileName in fileNames) {
      if (seen.add(fileName)) uniqueFiles.add(fileName);
    }

    final pending = <String>[];
    for (final fileName in uniqueFiles) {
      if (!await isCached(fileName)) pending.add(fileName);
    }

    if (pending.isEmpty) {
      onProgress?.call(fileNames.length, fileNames.length);
      return const [];
    }

    var nextIndex = 0;
    var finished = 0;
    final failed = <String>[];

    Future<void> worker() async {
      while (true) {
        final index = nextIndex++;
        if (index >= pending.length) return;

        final fileName = pending[index];
        try {
          await getFile(fileName);
        } catch (_) {
          failed.add(fileName);
        } finally {
          finished++;
          // Report the number of unique source files now present locally.
          final current = await downloadedCount(fileNames);
          onProgress?.call(current, fileNames.length);
        }
      }
    }

    final workerCount = pending.length < _maxConcurrentDownloads
        ? pending.length
        : _maxConcurrentDownloads;

    await Future.wait(
      List.generate(workerCount, (_) => worker()),
    );

    // A final authoritative verification prevents a false 99/99 state.
    final finalCount = await downloadedCount(fileNames);
    onProgress?.call(finalCount, fileNames.length);

    if (finalCount == fileNames.length) return const [];

    // Rebuild failures from the authoritative local state so every missing
    // source can be retried on the next click.
    final missing = <String>[];
    for (final fileName in fileNames) {
      if (!await isCached(fileName)) missing.add(fileName);
    }
    return missing.isEmpty ? failed : missing;
  }

  Future<int> downloadedCount(List<String> fileNames) async {
    var count = 0;
    final seen = <String>{};
    for (final fileName in fileNames) {
      if (!seen.add(fileName)) continue;
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

  void dispose() {
    _client.close();
  }
}
