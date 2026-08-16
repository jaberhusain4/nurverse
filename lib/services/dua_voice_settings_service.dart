import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DuaVoiceSettingsService {
  static const String _key = 'dua_audio_voice_gender';

  static const String female = 'female';
  static const String male = 'male';

  static Future<String> getVoiceGender() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    return value == male ? male : female;
  }

  static Future<void> setVoiceGender(String value) async {
    final gender = value == male ? male : female;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, gender);
  }

  static Future<void> apply(FlutterTts tts) async {
    final gender = await getVoiceGender();

    await tts.setLanguage('ar-SA');
    await tts.setSpeechRate(0.42);
    await tts.setVolume(1.0);

    // Android's flutter_tts voice metadata does not expose gender. When the
    // installed engine provides a gender-labelled Arabic voice, prefer it.
    // Otherwise use a natural pitch profile as a reliable device-independent
    // fallback so the user's Male/Female preference still has an effect.
    Map<String, String>? nativeVoice;
    try {
      final rawVoices = await tts.getVoices;
      final voices = rawVoices
          .whereType<Map>()
          .map((voice) => Map<String, String>.from(
                voice.map((key, value) => MapEntry(key.toString(), value.toString())),
              ))
          .where((voice) => (voice['locale'] ?? '').toLowerCase().startsWith('ar'))
          .toList();

      final keywords = gender == male
          ? <String>['male', 'man', 'masculine', 'm']
          : <String>['female', 'woman', 'feminine', 'f'];

      for (final voice in voices) {
        final name = (voice['name'] ?? '').toLowerCase();
        final features = (voice['features'] ?? '').toLowerCase();
        final haystack = '$name $features';
        if (keywords.any(haystack.contains)) {
          nativeVoice = voice;
          break;
        }
      }

      if (nativeVoice != null) {
        await tts.setVoice(nativeVoice);
      }
    } catch (_) {
      // Pitch fallback below remains available.
    }

    await tts.setPitch(gender == male ? 0.78 : 1.12);
  }
}
