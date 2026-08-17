import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dua_data.dart';

/// Handles Dua audio using a free static distribution source and local cache.
///
/// Final production flow:
/// 1. A master recording is published as an `.m4a` file under assets/dua_audio.
/// 2. The app downloads it once from the public GitHub raw URL.
/// 3. The downloaded file is kept in the app's local cache.
/// 4. Playback then works completely offline.
class DuaAudioService {
  DuaAudioService._();

  static final AudioPlayer player = AudioPlayer();
  static final AudioRecorder recorder = AudioRecorder();
  static SharedPreferences? _prefs;
  static String? _currentKey;
  static String? _recordingKey;

  static const String _audioBaseUrl =
      'https://raw.githubusercontent.com/jaberhusain4/nurverse/main/assets/dua_audio';

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
      '$_audioBaseUrl/${keyFor(item)}.m4a';

  static Future<String> _dir(String name) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/$name');
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  /// Downloads the published recording into the device cache.
  /// No Firebase service is involved.
  static Future<bool> download(DuaItem item) async {
    await initialize();

    final existing = cachedPath(item);
    if (existing != null && File(existing).existsSync()) return true;

    try {
      final response = await http.get(Uri.parse(remoteUrl(item)));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return false;
      }

      final path = '${await _dir('dua_audio_cache')}/${keyFor(item)}.m4a';
      final file = File(path);
      await file.writeAsBytes(response.bodyBytes, flush: true);
      await _prefs!.setString('dua_cached_${keyFor(item)}', path);
      return true;
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

  // Development-only recording support. Final user UI can remove this later.
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
    await _prefs!.setString('dua_recording_$key', path);
    return path;
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

  /// Shares all locally recorded Dua files through the Android/iOS share sheet.
  /// This is intentionally file-based rather than Firebase-based so the master
  /// recordings can be copied to a PC and prepared for free static hosting.
  static Future<int> exportRecordings(List<DuaItem> items) async {
    await initialize();

    final files = <XFile>[];
    for (final item in items) {
      final path = recordedPath(item);
      if (path == null || path.isEmpty) continue;
      final file = File(path);
      if (!file.existsSync()) continue;
      files.add(
        XFile(
          path,
          name: '${keyFor(item)}.m4a',
          mimeType: 'audio/mp4',
        ),
      );
    }

    if (files.isEmpty) return 0;

    await SharePlus.instance.share(
      ShareParams(
        files: files,
        title: 'NurVerse Dua Recordings',
        text: 'NurVerse recorded Dua audio files',
      ),
    );
    return files.length;
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

    final recorded = recordedPath(item);
    if (recorded != null && File(recorded).existsSync()) {
      await _play(item, recorded);
      return;
    }

    await downloadAndPlay(item);
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
