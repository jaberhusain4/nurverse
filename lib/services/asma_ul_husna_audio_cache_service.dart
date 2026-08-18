import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Permanent offline storage for the 99 Names of Allah audio library.
///
/// Audio is stored in the app's persistent support directory, not in the
/// temporary/cache directory. Once downloaded successfully, playback never
/// needs the internet again.
class AsmaUlHusnaAudioCacheService {
  AsmaUlHusnaAudioCacheService._();

  static final AsmaUlHusnaAudioCacheService instance =
      AsmaUlHusnaAudioCacheService._();

  static const String _baseUrl =
      'https://commons.wikimedia.org/wiki/Special:Redirect/file/';
  static const Duration _downloadTimeout = Duration(seconds: 30);

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

  /// Returns the permanently stored local audio, or null when it has not
  /// been downloaded yet. This method never makes a network request.
  Future<File?> getCachedFile(String fileName) async {
    final file = await _localFile(fileName);
    if (!await file.exists()) return null;

    final length = await file.length();
    if (length <= 0) {
      await file.delete().catchError((_) {});
      return null;
    }
    return file;
  }

  /// Returns a local file, downloading it only when it is not already stored.
  Future<File> getFile(String fileName) async {
    final cached = await getCachedFile(fileName);
    if (cached != null) return cached;

    final target = await _localFile(fileName);
    final temporary = File('${target.path}.download');

    try {
      final response = await http
          .get(Uri.parse(urlFor(fileName)))
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
      if (await target.exists()) await target.delete();
      await temporary.rename(target.path);
      return target;
    } catch (_) {
      if (await temporary.exists()) {
        await temporary.delete().catchError((_) {});
      }
      rethrow;
    }
  }

  Future<bool> isCached(String fileName) async {
    return await getCachedFile(fileName) != null;
  }

  /// Downloads every Asma ul Husna audio file that is not already local.
  ///
  /// [fileNames] must contain the 99 audio filenames in order.
  /// Returns the number of files newly downloaded during this call.
  Future<int> downloadAll(
    List<String> fileNames, {
    void Function(int completed, int total)? onProgress,
  }) async {
    var completed = 0;
    var downloaded = 0;

    for (final fileName in fileNames) {
      try {
        final existing = await getCachedFile(fileName);
        if (existing == null) {
          await getFile(fileName);
          downloaded++;
        }
      } finally {
        completed++;
        onProgress?.call(completed, fileNames.length);
      }
    }

    return downloaded;
  }

  Future<int> downloadedCount(List<String> fileNames) async {
    var count = 0;
    for (final fileName in fileNames) {
      if (await isCached(fileName)) count++;
    }
    return count;
  }

  Future<bool> isAllDownloaded(List<String> fileNames) async {
    return await downloadedCount(fileNames) == fileNames.length;
  }
}
