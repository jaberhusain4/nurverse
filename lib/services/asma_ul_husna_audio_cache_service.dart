import 'dart:io';

import 'package:esmaulhusna_muslimbg/esmaulhusna_muslimbg.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Permanent offline storage for the 99 Names of Allah audio library.
///
/// The pronunciation MP3 files are bundled by the package. They are copied
/// once to the app's permanent support directory when the user chooses
/// Download for Offline. Playback then uses only the local files.
class AsmaUlHusnaAudioCacheService {
  AsmaUlHusnaAudioCacheService._();

  static final AsmaUlHusnaAudioCacheService instance =
      AsmaUlHusnaAudioCacheService._();

  static const int expectedAudioCount = 99;
  static const int minimumAudioBytes = 1024;
  static const int maxDownloadPasses = 3;

  Directory? _audioDirectory;
  List<String>? _bundledAudioPaths;

  Future<Directory> _getAudioDirectory() async {
    if (_audioDirectory != null) return _audioDirectory!;
    final root = await getApplicationSupportDirectory();
    final directory = Directory(p.join(root.path, 'asma_ul_husna_audio'));
    if (!await directory.exists()) await directory.create(recursive: true);
    _audioDirectory = directory;
    return directory;
  }

  Future<List<String>> _getBundledAudioPaths() async {
    if (_bundledAudioPaths != null) return _bundledAudioPaths!;

    final names = await EsmaulHusna.getNames('en');
    final paths = <String>[];
    for (final name in names) {
      final audio = name['audio'];
      if (audio is String && audio.trim().isNotEmpty) {
        paths.add(audio.trim());
      }
    }

    if (paths.length != expectedAudioCount) {
      throw StateError(
        'Asma ul Husna bundled audio manifest contains ${paths.length} files; '
        'expected $expectedAudioCount.',
      );
    }

    _bundledAudioPaths = List.unmodifiable(paths);
    return _bundledAudioPaths!;
  }

  int _numberPrefix(String fileName) {
    final match = RegExp(r'^(\d+)[ -]').firstMatch(p.basename(fileName));
    if (match == null) return -1;
    final number = int.tryParse(match.group(1)!);
    if (number == null || number < 1 || number > expectedAudioCount) return -1;
    return number;
  }

  /// Resolves the 1-based name index deterministically.
  ///
  /// Some callers may provide an audio filename without the numeric prefix.
  /// In that case we resolve it against the package's authoritative 99-entry
  /// manifest instead of guessing from the basename. This prevents one entry
  /// from being permanently stuck at 98/99 while its bundled audio still plays.
  Future<int> _numberForFileName(String fileName) async {
    final prefixed = _numberPrefix(fileName);
    if (prefixed > 0) return prefixed;

    final paths = await _getBundledAudioPaths();
    final requestedBase = p.basenameWithoutExtension(fileName).toLowerCase();

    for (var i = 0; i < paths.length; i++) {
      final manifestBase =
          p.basenameWithoutExtension(paths[i]).toLowerCase();
      if (manifestBase == requestedBase) return i + 1;
    }

    // Last-resort normalized comparison for package paths containing minor
    // punctuation/casing differences.
    String normalize(String value) =>
        value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');

    final normalizedRequested = normalize(requestedBase);
    for (var i = 0; i < paths.length; i++) {
      if (normalize(p.basenameWithoutExtension(paths[i])) ==
          normalizedRequested) {
        return i + 1;
      }
    }

    return -1;
  }

  Future<File> _localFile(String fileName) async {
    final directory = await _getAudioDirectory();
    final number = await _numberForFileName(fileName);
    if (number < 1) {
      throw StateError('Invalid Asma ul Husna audio file name: $fileName');
    }

    final baseName = p.basenameWithoutExtension(fileName);
    return File(
      p.join(
        directory.path,
        '${number.toString().padLeft(2, '0')}-$baseName.mp3',
      ),
    );
  }

  Future<bool> _isValidMp3(File file) async {
    try {
      if (!await file.exists()) return false;
      final length = await file.length();
      if (length <= minimumAudioBytes) return false;

      final bytes = await file.openRead(0, 4).fold<List<int>>(
        <int>[],
        (previous, chunk) => previous..addAll(chunk),
      );

      if (bytes.length >= 3 &&
          bytes[0] == 0x49 &&
          bytes[1] == 0x44 &&
          bytes[2] == 0x33) {
        return true;
      }
      if (bytes.length >= 2 &&
          bytes[0] == 0xff &&
          (bytes[1] & 0xe0) == 0xe0) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Local-only lookup. Never performs a network request.
  Future<File?> getCachedFile(String fileName) async {
    try {
      final file = await _localFile(fileName);
      if (await _isValidMp3(file)) return file;
    } catch (_) {}
    return null;
  }

  Future<File> getFile(String fileName) async {
    final cached = await getCachedFile(fileName);
    if (cached != null) return cached;

    final bundledAudioPaths = await _getBundledAudioPaths();
    final number = await _numberForFileName(fileName);
    final index = number - 1;
    if (index < 0 || index >= bundledAudioPaths.length) {
      throw StateError('No bundled Asma ul Husna audio found for $fileName.');
    }

    final assetPath = bundledAudioPaths[index];
    final bytes = await rootBundle.load(assetPath);
    final target = await _localFile(fileName);
    final temporary = File('${target.path}.download');

    try {
      await temporary.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true,
      );

      if (!await _isValidMp3(temporary)) {
        throw const FormatException(
          'Bundled Asma ul Husna audio is not a valid MP3.',
        );
      }

      if (await target.exists()) await target.delete();
      await temporary.rename(target.path);

      final saved = await getCachedFile(fileName);
      if (saved == null) {
        throw const FormatException(
          'Saved Asma ul Husna audio failed local verification.',
        );
      }
      return saved;
    } catch (_) {
      try {
        if (await temporary.exists()) await temporary.delete();
      } catch (_) {}
      rethrow;
    }
  }

  Future<bool> isCached(String fileName) async =>
      await getCachedFile(fileName) != null;

  /// Copies the bundled 99-name audio library to permanent local storage.
  /// No HTTP request is made.
  Future<List<String>> downloadAll(
    List<String> fileNames, {
    void Function(int completed, int total)? onProgress,
  }) async {
    if (fileNames.length != expectedAudioCount) {
      return List<String>.from(fileNames);
    }

    for (var pass = 0; pass < maxDownloadPasses; pass++) {
      var completed = await downloadedCount(fileNames);
      onProgress?.call(completed, fileNames.length);

      for (final fileName in fileNames) {
        if (await isCached(fileName)) continue;
        try {
          await getFile(fileName);
        } catch (_) {
          // Retry unresolved entries on the next pass.
        }
        completed = await downloadedCount(fileNames);
        onProgress?.call(completed, fileNames.length);
      }

      final currentCount = await downloadedCount(fileNames);
      onProgress?.call(currentCount, fileNames.length);
      if (currentCount == expectedAudioCount) return const <String>[];
    }

    final missing = <String>[];
    for (final fileName in fileNames) {
      if (!await isCached(fileName)) missing.add(fileName);
    }

    onProgress?.call(
      fileNames.length - missing.length,
      fileNames.length,
    );
    return missing;
  }

  Future<int> downloadedCount(List<String> fileNames) async {
    var count = 0;
    for (final fileName in fileNames) {
      if (await isCached(fileName)) count++;
    }
    return count;
  }

  Future<bool> isAllDownloaded(List<String> fileNames) async {
    if (fileNames.length != expectedAudioCount) return false;
    for (final fileName in fileNames) {
      if (!await isCached(fileName)) return false;
    }
    return true;
  }
}
