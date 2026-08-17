import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/dua_data.dart';

class DuaAudioService {
  DuaAudioService._();
  static final AudioPlayer player = AudioPlayer();
  static final AudioRecorder recorder = AudioRecorder();
  static SharedPreferences? _prefs;
  static String? _currentKey;
  static String? _recordingKey;
  static bool _migrationStarted = false;

  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    if (!_migrationStarted) {
      _migrationStarted = true;
      Future<void>(() async { try { await publishAllExistingRecordings(); } catch (_) {} });
    }
  }

  static String keyFor(DuaItem item) => sha256.convert('${item.titleEn}|${item.reference}|${item.arabic}'.codeUnits).toString();
  static String? recordedPath(DuaItem item) => _prefs?.getString('dua_recording_${keyFor(item)}');
  static String? cachedPath(DuaItem item) => _prefs?.getString('dua_cached_${keyFor(item)}');
  static bool hasAudio(DuaItem item) {
    final a = recordedPath(item); if (a != null && File(a).existsSync()) return true;
    final b = cachedPath(item); return b != null && File(b).existsSync();
  }
  static bool hasDownloadedAudio(DuaItem item) { final p = cachedPath(item); return p != null && File(p).existsSync(); }
  static bool isRecording(DuaItem item) => _recordingKey == keyFor(item);
  static bool isPlaying(DuaItem item) => _currentKey == keyFor(item) && player.state == PlayerState.playing;
  static bool isPaused(DuaItem item) => _currentKey == keyFor(item) && player.state == PlayerState.paused;
  static Reference _remoteRef(DuaItem item) => FirebaseStorage.instance.ref('dua_audio/${keyFor(item)}.m4a');

  static Future<String> _dir(String name) async {
    final root = await getApplicationDocumentsDirectory();
    final d = Directory('${root.path}/$name');
    if (!d.existsSync()) await d.create(recursive: true);
    return d.path;
  }

  static Future<bool> publishRecording(DuaItem item) async {
    await initialize(); final p = recordedPath(item);
    if (p == null || !File(p).existsSync()) return false;
    try {
      await _remoteRef(item).putFile(File(p), SettableMetadata(contentType: 'audio/mp4', cacheControl: 'public,max-age=31536000', customMetadata: {'nurverse_type':'dua_recitation','dua_key':keyFor(item)}));
      return true;
    } catch (_) { return false; }
  }

  static Future<void> publishAllExistingRecordings() async {
    await initialize();
    for (final c in duaCategories) { for (final item in c.items) { if (recordedPath(item) != null) await publishRecording(item); } }
  }

  static Future<bool> download(DuaItem item) async {
    await initialize(); final existing = cachedPath(item);
    if (existing != null && File(existing).existsSync()) return true;
    try {
      final p = '${await _dir('dua_audio_cache')}/${keyFor(item)}.m4a';
      await _remoteRef(item).writeToFile(File(p));
      await _prefs!.setString('dua_cached_${keyFor(item)}', p); return true;
    } catch (_) { return false; }
  }

  static Future<bool> _play(DuaItem item, String path) async { await player.stop(); _currentKey = keyFor(item); await player.play(DeviceFileSource(path)); return true; }
  static Future<bool> downloadAndPlay(DuaItem item) async { if (!await download(item)) return false; final p=cachedPath(item); return p == null ? false : _play(item,p); }

  // Development-only recording support; final user UI no longer exposes it.
  static Future<bool> startRecording(DuaItem item) async {
    await initialize(); if (_recordingKey != null) return false;
    final permission = await Permission.microphone.request(); if (!permission.isGranted || !await recorder.hasPermission()) return false;
    final key=keyFor(item); final p='${await _dir('dua_recordings')}/$key.m4a'; await player.stop(); _currentKey=null;
    final old=_prefs!.getString('dua_recording_$key'); if(old!=null){final f=File(old);if(f.existsSync())await f.delete();await _prefs!.remove('dua_recording_$key');}
    await recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc,bitRate:128000,sampleRate:44100,numChannels:1),path:p); _recordingKey=key; return true;
  }
  static Future<String?> stopRecording(DuaItem item) async { final key=keyFor(item); if(_recordingKey!=key)return null; final p=await recorder.stop();_recordingKey=null;if(p==null||p.isEmpty)return null;await initialize();await _prefs!.setString('dua_recording_$key',p);await publishRecording(item);return p; }
  static Future<void> deleteRecording(DuaItem item) async { await initialize(); final key=keyFor(item); final p=_prefs!.getString('dua_recording_$key');if(_currentKey==key){await player.stop();_currentKey=null;}if(p!=null){final f=File(p);if(f.existsSync())await f.delete();}await _prefs!.remove('dua_recording_$key'); }

  static Future<void> toggle(DuaItem item) async {
    await initialize(); final key=keyFor(item);
    if(_currentKey==key&&player.state==PlayerState.playing){await player.pause();return;}
    if(_currentKey==key&&player.state==PlayerState.paused){await player.resume();return;}
    final c=cachedPath(item);if(c!=null&&File(c).existsSync()){await _play(item,c);return;}
    final r=recordedPath(item);if(r!=null&&File(r).existsSync()){await _play(item,r);return;}
    await downloadAndPlay(item);
  }
  static Future<void> stopPlayback() async { await player.stop();_currentKey=null; }
  static Future<void> stop() async { _currentKey=null;await player.stop();if(_recordingKey!=null){await recorder.stop();_recordingKey=null;} }
}
