import 'dart:io';

import 'package:esmaulhusna_muslimbg/esmaulhusna_muslimbg.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Permanent offline storage for the 99 Names of Allah audio library.
///
/// The 99 pronunciation MP3 files are bundled by the
/// esmaulhusna_muslimbg package. They are copied once to the app's permanent
/// support directory when the user chooses Download for Offline. After that,
/// playback is always local and never depends on Internet connectivity.
class AsmaUlHusnaAudioCacheService {
  AsmaUlHusnaAudioCacheService._();

  static final AsmaUlHusnaAudioCacheService instance =
      AsmaUlHusnaAudioCacheService._();

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
      if (audio is String && audio.isNotEmpty) paths.add(audio);
    }

    if (paths.length != 99) {
      throw StateError(
        'Asma ul Husna bundled audio manifest contains ${paths.length} files; expected 99.',
      );
    }

    _bundledAudioPaths = List.unmodifiable(paths);
    return _bundledAudioPaths!;
  }

  Future<File> _localFile(String fileName) async {
    final directory = await _getAudioDirectory();
    final baseName = p.basenameWithoutExtension(fileName);
    // The UI keeps its existing .ogg source IDs, but the bundled files are
    // MP3. Store them with the real extension so just_audio selects the right
    // decoder and old .ogg cache files cannot be mistaken for valid audio.
    return File(p.join(directory.path, '$baseName.mp3'));
  }

  Future<bool> _isValidAudio(File file) async {
    try {
      if (!await file.exists()) return false;
      return await file.length() > 1024;
    } catch (_) {
      return false;
    }
  }

  /// Local-only lookup. Never performs a network request.
  Future<File?> getCachedFile(String fileName) async {
    final file = await _localFile(fileName);
    if (await _isValidAudio(file)) return file;
    return null;
  }

  Future<File> getFile(String fileName) async {
    final cached = await getCachedFile(fileName);
    if (cached != null) return cached;

    final bundledAudioPaths = await _getBundledAudioPaths();
    final index = _sourceIndexForFileName(fileName);
    if (index < 0 || index >= bundledAudioPaths.length) {
      throw StateError('No bundled Asma ul Husna audio found for $fileName.');
    }

    final assetPath = bundledAudioPaths[index];
    final bytes = await rootBundle.load(assetPath);
    final target = await _localFile(fileName);
    final temporary = File('${target.path}.download');
    await temporary.writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      flush: true,
    );

    if (!await _isValidAudio(temporary)) {
      try {
        await temporary.delete();
      } catch (_) {}
      throw const FormatException('Bundled Asma ul Husna audio is invalid.');
    }

    if (await target.exists()) await target.delete();
    await temporary.rename(target.path);
    return target;
  }

  int _sourceIndexForFileName(String fileName) {
    final match = RegExp(r'^(\d+)[ -]').firstMatch(fileName);
    if (match == null) return -1;
    final number = int.tryParse(match.group(1)!);
    if (number == null || number < 1 || number > 99) return -1;
    return number - 1;
  }

  Future<bool> isCached(String fileName) async =>
      await getCachedFile(fileName) != null;

  /// Copies the bundled 99-name audio library to permanent local storage.
  /// This is intentionally offline: no HTTP request is made.
  Future<List<String>> downloadAll(
    List<String> fileNames, {
    void Function(int completed, int total)? onProgress,
  }) async {
    if (fileNames.length != 99) return List<String>.from(fileNames);

    var completed = await downloadedCount(fileNames);
    onProgress?.call(completed, fileNames.length);

    for (final fileName in fileNames) {
      if (await isCached(fileName)) continue;
      try {
        await getFile(fileName);
        completed++;
        onProgress?.call(completed, fileNames.length);
      } catch (_) {
        // Continue so one broken package asset cannot stop the other names.
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
    if (fileNames.length != 99) return false;
    for (final fileName in fileNames) {
      if (!await isCached(fileName)) return false;
    }
    return true;
  }
}
