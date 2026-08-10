import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class QuranReciter {
  final String id;
  final String nameBn;
  final String serverBase; // e.g. https://server8.mp3quran.net/afs/
  const QuranReciter({required this.id, required this.nameBn, required this.serverBase});
}

const List<QuranReciter> kReciters = [
  QuranReciter(
    id: 'afasy',
    nameBn: 'মিশারী রাশিদ আল-আফাসী',
    serverBase: 'https://server8.mp3quran.net/afs/',
  ),
  QuranReciter(
    id: 'sudais',
    nameBn: 'আব্দুর রহমান আস-সুদাইস',
    serverBase: 'https://server11.mp3quran.net/sds/',
  ),
];

class AudioQuranService {
  AudioQuranService._();
  static final AudioQuranService instance = AudioQuranService._();

  final AudioPlayer player = AudioPlayer();

  String _surahFileName(int surahNumber) =>
      '${surahNumber.toString().padLeft(3, '0')}.mp3';

  Future<Directory> _cacheDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final d = Directory('${dir.path}/quran_audio_cache');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  Future<File> _localFile(QuranReciter reciter, int surahNumber) async {
    final dir = await _cacheDir();
    return File('${dir.path}/${reciter.id}_${_surahFileName(surahNumber)}');
  }

  Future<bool> isDownloaded(QuranReciter reciter, int surahNumber) async {
    final f = await _localFile(reciter, surahNumber);
    return f.exists();
  }

  /// Downloads a surah's recitation for permanent offline playback.
  Future<bool> download(QuranReciter reciter, int surahNumber) async {
    try {
      final url = '${reciter.serverBase}${_surahFileName(surahNumber)}';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(minutes: 3));
      if (response.statusCode != 200) return false;
      final file = await _localFile(reciter, surahNumber);
      await file.writeAsBytes(response.bodyBytes);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Plays from the local cache if downloaded, otherwise streams online.
  Future<void> play(QuranReciter reciter, int surahNumber) async {
    final local = await _localFile(reciter, surahNumber);
    if (await local.exists()) {
      await player.setAudioSource(
        AudioSource.file(local.path, tag: '${reciter.id}:$surahNumber'),
      );
    } else {
      final url = '${reciter.serverBase}${_surahFileName(surahNumber)}';
      await player.setAudioSource(
        AudioSource.uri(Uri.parse(url), tag: '${reciter.id}:$surahNumber'),
      );
    }
    await player.play();
  }

  Future<void> pause() => player.pause();
  Future<void> stop() => player.stop();
  void dispose() => player.dispose();
}
