import 'package:audioplayers/audioplayers.dart';

import '../data/dua_data.dart';

/// Plays licensed human Dua recordings bundled with NurVerse.
///
/// Audio files use the following convention:
/// assets/dua_audio/<stable-key>.mp3
///
/// The key is derived from the Dua reference when possible. Until a
/// redistribution-cleared recording is bundled for a Dua, no fallback TTS is
/// used and the audio button remains unavailable.
class DuaAudioService {
  DuaAudioService._();

  static final AudioPlayer player = AudioPlayer();
  static String? _currentKey;

  static String? keyFor(DuaItem item) {
    final match = RegExp(r'Hisn al-Muslim\s+(\d+)').firstMatch(item.reference);
    if (match != null) return 'hisn_${match.group(1)}';
    return null;
  }

  static String? assetFor(DuaItem item) {
    final key = keyFor(item);
    if (key == null) return null;
    return 'assets/dua_audio/$key.mp3';
  }

  static bool hasAudio(DuaItem item) => assetFor(item) != null;

  static Future<void> toggle(DuaItem item) async {
    final asset = assetFor(item);
    if (asset == null) return;

    final key = keyFor(item);
    if (_currentKey == key && player.state == PlayerState.playing) {
      await player.pause();
      return;
    }

    await player.stop();
    _currentKey = key;
    await player.play(AssetSource(asset.replaceFirst('assets/', '')));
  }

  static Future<void> stop() async {
    _currentKey = null;
    await player.stop();
  }
}
