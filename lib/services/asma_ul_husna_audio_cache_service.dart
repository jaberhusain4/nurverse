import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Permanent offline storage for the 99 Names of Allah audio library.
///
/// A file is considered downloaded only when it is a non-empty, valid OGG
/// audio file. Cached files are always preferred and never trigger a network
/// request during playback.
class AsmaUlHusnaAudioCacheService {
  AsmaUlHusnaAudioCacheService._();

  static final AsmaUlHusnaAudioCacheService instance =
      AsmaUlHusnaAudioCacheService._();

  static const String _baseUrl =
      'https://commons.wikimedia.org/wiki/Special:Redirect/file/';
  static const Duration _downloadTimeout = Duration(seconds: 60);
  static const int _maxConcurrentDownloads = 2;
  static const int _maxAttempts = 3;

  Directory? _audioDirectory;

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
      final length = await file.length();
      if (length < 4) return false;
      final bytes = await file.openRead(0, 4).fold<List<int>>(
        <int>[],
        (previous, chunk) => previous..addAll(chunk),
      );
      return bytes.length >= 4 &&
          bytes[0] == 0x4f && // O
          bytes[1] == 0x67 && // g
          bytes[2] == 0x67 && // g
          bytes[3] == 0x53; // S
    } catch (_) {
      return false;
    }
  }

  /// Returns the permanently stored local audio, or null when it has not
  /// been downloaded yet. This method never makes a network request.
  Future<File?> getCachedFile(String fileName) async {
    final file = await _localFile(fileName);
    if (await _isValidOgg(file)) return file;

    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
    return null;
  }

  /// Returns a local file, downloading it only when it is not already stored.
  Future<File> getFile(String fileName) async {
    final cached = await getCachedFile(fileName);
    if (cached != null) return cached;

    final target = await _localFile(fileName);
    final temporary = File('${target.path}.download');
    Object? lastError;

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        if (await temporary.exists()) await temporary.delete();

        final response = await http
            .get(
              Uri.parse(urlFor(fileName)),
              headers: const {
                'User-Agent': 'NurVerse/1.0 (offline Islamic app)',
                'Accept': 'audio/ogg,application/ogg,*/*;q=0.8',
              },
            )
            .timeout(_downloadTimeout);

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw HttpException(
            'Audio server returned HTTP ${response.statusCode}.',
          );
        }
        if (response.bodyBytes.isEmpty) {
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
          await Future<void>.delayed(Duration(seconds: attempt * 2));
        }
      }
    }

    throw lastError ?? const HttpException('Audio download failed.');
  }

  Future<bool> isCached(String fileName) async {
    return await getCachedFile(fileName) != null;
  }

  /// Downloads every Asma ul Husna audio file that is not already local.
  ///
  /// Existing valid files are skipped. Invalid/partial files are removed and
  /// downloaded again. A failed item never marks the library as complete.
  Future<List<String>> downloadAll(
    List<String> fileNames, {
    void Function(int completed, int total)? onProgress,
  }) async {
    if (fileNames.isEmpty) return const [];

    var nextIndex = 0;
    var completed = 0;
    final failed = <String>[];

    Future<void> worker() async {
      while (true) {
        if (nextIndex >= fileNames.length) return;

        final index = nextIndex++;
        final fileName = fileNames[index];

        try {
          final existing = await getCachedFile(fileName);
          if (existing == null) {
            await getFile(fileName);
          }
        } catch (_) {
          failed.add(fileName);
        } finally {
          completed++;
          onProgress?.call(completed, fileNames.length);
        }
      }
    }

    final workerCount = fileNames.length < _maxConcurrentDownloads
        ? fileNames.length
        : _maxConcurrentDownloads;

    await Future.wait(
      List.generate(workerCount, (_) => worker()),
    );

    return failed;
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
}
