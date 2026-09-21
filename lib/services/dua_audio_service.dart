import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dua_data.dart';

/// Handles Dua audio using Cloudflare R2 as the remote distribution source
/// and the device filesystem as the offline cache.
///
/// All published/recorded Dua audio is normalized before local playback so
/// quiet recordings are substantially easier to hear without uncontrolled
/// clipping.
class DuaAudioService {
  DuaAudioService._();

  static final AudioPlayer player = AudioPlayer();
  static final AudioRecorder recorder = AudioRecorder();
  static SharedPreferences? _prefs;
  static String? _currentKey;
  static String? _recordingKey;

  static const String _audioBaseUrl =
      'https://pub-3a011607dfb94b04a37360a09e98b263.r2.dev';

  static String? get currentKey => _currentKey;

  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String keyFor(DuaItem item) => sha256
      .convert('${item.titleEn}|${item.reference}|${item.arabic}'.codeUnits)
      .toString();

  static String? recordedPath(DuaItem item) =>
      _prefs?.getString('dua_recording_${keyFor(item)}');

  static String? cachedPath(DuaItem item) =>
      _prefs?.getString('dua_cached_${keyFor(item)}');

  static bool hasAudio(DuaItem item) {
    final recorded = recordedPath(item);
    if (recorded != null && File(recorded).existsSync()) return true;
    return hasDownloadedAudio(item);
  }

  static bool hasDownloadedAudio(DuaItem item) {
    final cached = cachedPath(item);
    return cached != null && File(cached).existsSync();
  }

  static bool isRecording(DuaItem item) => _recordingKey == keyFor(item);

  static bool isPlaying(DuaItem item) =>
      _currentKey == keyFor(item) && player.state == PlayerState.playing;

  static bool isPaused(DuaItem item) =>
      _currentKey == keyFor(item) && player.state == PlayerState.paused;

  static String remoteUrl(DuaItem item) =>
      '$_audioBaseUrl/dua_audio/${keyFor(item)}.m4a';

  static Future<String> _dir(String name) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/$name');
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  /// Runs loudness normalization on a local M4A file.
  ///
  /// The target is voice-friendly and capped below digital full scale. This
  /// raises quiet recordings while avoiding the harsh clipping produced by a
  /// blind fixed-gain multiplier.
  static Future<String?> _normalizeAudio(String inputPath) async {
    final input = File(inputPath);
    if (!await input.exists() || await input.length() == 0) return null;

    final directory = await _dir('dua_audio_processed');
    final outputPath = '$directory/${sha256.convert(inputPath.codeUnits)}.m4a';
    final output = File(outputPath);
    if (output.existsSync()) await output.delete();

    final command = [
      '-y',
      '-i',
      '"$inputPath"',
      '-af',
      'loudnorm=I=-16:TP=-1.5:LRA=11',
      '-c:a',
      'aac',
      '-b:a',
      '128k',
      '-ac',
      '1',
      '-ar',
      '44100',
      '"$outputPath"',
    ].join(' ');

    try {
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode) &&
          output.existsSync() &&
          await output.length() > 0) {
        return outputPath;
      }
    } catch (_) {
      // Playback can safely fall back to the original file.
    }
    return null;
  }

  /// Downloads the published R2 audio and normalizes it into the local cache.
  static Future<bool> download(DuaItem item) async {
    await initialize();
    final existing = cachedPath(item);
    if (existing != null && File(existing).existsSync()) return true;

    try {
      final response = await http.get(Uri.parse(remoteUrl(item)));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return false;
      }

      final directory = await _dir('dua_audio_cache');
      final rawPath = '$directory/${keyFor(item)}.raw.m4a';
      final path = '$directory/${keyFor(item)}.m4a';
      final rawFile = File(rawPath);
      await rawFile.writeAsBytes(response.bodyBytes, flush: true);

      if (!rawFile.existsSync() || await rawFile.length() == 0) {
        if (rawFile.existsSync()) await rawFile.delete();
        return false;
      }

      final normalized = await _normalizeAudio(rawPath);
      final finalFile = File(path);
      if (finalFile.existsSync()) await finalFile.delete();

      if (normalized != null) {
        await File(normalized).copy(path);
      } else {
        await rawFile.copy(path);
      }

      if (rawFile.existsSync()) await rawFile.delete();
      await _prefs!.setString('dua_cached_${keyFor(item)}', path);
      return finalFile.existsSync() && await finalFile.length() > 0;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _play(DuaItem item, String path) async {
    await player.stop();
    _currentKey = keyFor(item);
    await player.play(DeviceFileSource(path));
    return true;
  }

  static Future<bool> downloadAndPlay(DuaItem item) async {
    if (!await download(item)) return false;
    final path = cachedPath(item);
    if (path == null || !File(path).existsSync()) return false;
    return _play(item, path);
  }

  static Future<void> toggle(DuaItem item) async {
    await initialize();
    final key = keyFor(item);

    if (_currentKey == key && player.state == PlayerState.playing) {
      await player.pause();
      return;
    }

    if (_currentKey == key && player.state == PlayerState.paused) {
      await player.resume();
      return;
    }

    final cached = cachedPath(item);
    if (cached != null && File(cached).existsSync()) {
      await _play(item, cached);
      return;
    }

    // Legacy creator recording fallback retained for maintenance only.
    final recorded = recordedPath(item);
    if (recorded != null && File(recorded).existsSync()) {
      final normalized = await _normalizeAudio(recorded);
      await _play(item, normalized ?? recorded);
      return;
    }

    await downloadAndPlay(item);
  }

  static Future<bool> startRecording(DuaItem item) async {
    await initialize();
    if (_recordingKey != null) return false;
    final permission = await Permission.microphone.request();
    if (!permission.isGranted || !await recorder.hasPermission()) return false;
    final key = keyFor(item);
    final path = '${await _dir('dua_recordings')}/$key.m4a';
    await player.stop();
    _currentKey = null;
    final old = _prefs!.getString('dua_recording_$key');
    if (old != null) {
      final file = File(old);
      if (file.existsSync()) await file.delete();
      await _prefs!.remove('dua_recording_$key');
    }
    await recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );
    _recordingKey = key;
    return true;
  }

  static Future<String?> stopRecording(DuaItem item) async {
    final key = keyFor(item);
    if (_recordingKey != key) return null;
    final path = await recorder.stop();
    _recordingKey = null;
    if (path == null || path.isEmpty) return null;
    await initialize();

    final normalized = await _normalizeAudio(path);
    final finalPath = normalized ?? path;
    if (finalPath != path) {
      final original = File(path);
      if (original.existsSync()) await original.delete();
    }
    await _prefs!.setString('dua_recording_$key', finalPath);
    return finalPath;
  }

  static Future<void> deleteRecording(DuaItem item) async {
    await initialize();
    final key = keyFor(item);
    final path = _prefs!.getString('dua_recording_$key');
    if (_currentKey == key) {
      await player.stop();
      _currentKey = null;
    }
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    }
    await _prefs!.remove('dua_recording_$key');
  }

  static Future<int> exportRecordings(List<DuaItem> items) async {
    await initialize();
    final files = <XFile>[];
    for (final item in items) {
      final path = recordedPath(item);
      if (path == null || path.isEmpty) continue;
      final file = File(path);
      if (!file.existsSync()) continue;
      files.add(XFile(path, name: '${keyFor(item)}.m4a', mimeType: 'audio/mp4'));
    }
    if (files.isEmpty) return 0;
    await SharePlus.instance.share(ShareParams(
      files: files,
      title: 'NurVerse Dua Recordings',
      text: 'NurVerse recorded Dua audio files',
    ));
    return files.length;
  }

  static Future<void> stopPlayback() async {
    await player.stop();
    _currentKey = null;
  }

  static Future<void> stop() async {
    _currentKey = null;
    await player.stop();
    if (_recordingKey != null) {
      await recorder.stop();
      _recordingKey = null;
    }
  }
}
