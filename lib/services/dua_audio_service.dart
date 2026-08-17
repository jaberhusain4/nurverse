import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dua_data.dart';

/// Temporary voice-recording layer for collecting the user's own Dua recitations.
/// Recordings are stored privately on the device and mapped to the exact Dua.
class DuaAudioService {
  DuaAudioService._();

  static final AudioPlayer player = AudioPlayer();
  static final AudioRecorder recorder = AudioRecorder();
  static SharedPreferences? _prefs;
  static String? _currentKey;
  static String? _recordingKey;

  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String keyFor(DuaItem item) {
    final raw = '${item.titleEn}|${item.reference}|${item.arabic}';
    return sha256.convert(raw.codeUnits).toString();
  }

  static Future<String> _recordingDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/dua_recordings');
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  static String? recordedPath(DuaItem item) {
    final key = keyFor(item);
    return _prefs?.getString('dua_recording_$key');
  }

  static bool hasAudio(DuaItem item) {
    final path = recordedPath(item);
    return path != null && File(path).existsSync();
  }

  static bool isRecording(DuaItem item) => _recordingKey == keyFor(item);

  static bool isPlaying(DuaItem item) =>
      _currentKey == keyFor(item) && player.state == PlayerState.playing;

  static bool isPaused(DuaItem item) =>
      _currentKey == keyFor(item) && player.state == PlayerState.paused;

  static Future<bool> startRecording(DuaItem item) async {
    await initialize();
    if (_recordingKey != null) return false;
    if (!await recorder.hasPermission()) return false;

    final directory = await _recordingDirectory();
    final key = keyFor(item);
    final path = '$directory/$key.m4a';

    await player.stop();
    _currentKey = null;
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

  static Future<void> toggle(DuaItem item) async {
    final path = recordedPath(item);
    if (path == null || !File(path).existsSync()) return;

    final key = keyFor(item);
    if (_currentKey == key && player.state == PlayerState.playing) {
      await player.pause();
      return;
    }
    if (_currentKey == key && player.state == PlayerState.paused) {
      await player.resume();
      return;
    }

    await player.stop();
    _currentKey = key;
    await player.play(DeviceFileSource(path));
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
