import 'dart:io';

import 'package:esmaulhusna_muslimbg/esmaulhusna_muslimbg.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Permanent offline storage for the 99 Names of Allah audio library.
///
/// The pronunciation MP3 files are bundled with the package. The user can
/// copy all 99 files to permanent app storage once, after which playback is
/// local-only and does not depend on Internet access.
class AsmaUlHusnaAudioCacheService {
  AsmaUlHusnaAudioCacheService._();

  static final AsmaUlHusnaAudioCacheService instance =
      AsmaUlHusnaAudioCacheService._();

  static const int expectedAudioCount = 99;
  static const int minimumAudioBytes = 1024;
  static const int maxDownloadPasses = 5;

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

  /// Returns the stable 1-based ID for an audio entry.
  ///
  /// The UI supplies IDs such as `01-...ogg`. If an unprefixed filename is
  /// supplied, resolve it from the package manifest. Storage is always keyed
  /// by the 1-based ID, so duplicate English basenames can never collide.
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

    return -1;
  }

  Future<File> _localFile(String fileName) async {
    final directory = await _getAudioDirectory();
    final number = await _numberForFileName(fileName);
    if (number < 1) {
      throw StateError('Invalid Asma ul Husna audio file name: $fileName');
    }

    // Always use the numeric ID. The source extension is irrelevant because
    // the bundled package supplies MP3 bytes and the local file is .mp3.
    return File(
      p.join(
        directory.path,
        '${number.toString().padLeft(2, '0')}.mp3',
      ),
    );
  }

  /// The package is a trusted bundled MP3 source. Do not reject an otherwise
  /// valid bundled recording because its first bytes contain an uncommon MP3
  /// metadata layout. The audio player is the final format parser.
  Future<bool> _isValidCachedFile(File file) async {
    try {
      if (!await file.exists()) return false;
      return await file.length() > minimumAudioBytes;
    } catch (_) {
      return false;
    }
  }

  /// Local-only lookup. Never performs a network request.
  Future<File?> getCachedFile(String fileName) async {
    try {
      final file = await _localFile(fileName);
      if (await _isValidCachedFile(file)) return file;
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
    final temporary = File('${target.path}.tmp');

    try {
      await temporary.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true,
      );

      if (!await _isValidCachedFile(temporary)) {
        throw const FormatException(
          'Bundled Asma ul Husna audio is empty or incomplete.',
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

  /// Copies all 99 bundled recordings to permanent local storage.
  /// No HTTP/network operation is performed anywhere in this method.
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
          // Continue so another entry cannot be blocked by one failure.
        }
        completed = await downloadedCount(fileNames);
        onProgress?.call(completed, fileNames.length);
      }

      final currentCount = await downloadedCount(fileNames);
      onProgress?.call(currentCount, fileNames.length);
      if (currentCount == expectedAudioCount) {
        return const <String>[];
      }
    }

    final missing = <String>[];
    for (final fileName in fileNames) {
      if (!await isCached(fileName)) missing.add(fileName);
    }

    onProgress?.call(fileNames.length - missing.length, fileNames.length);
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
