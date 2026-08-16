import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DuaVoiceSettingsService {
  static const String _key = 'dua_audio_voice_gender';

  static const String female = 'female';
  static const String male = 'male';

  static Future<String> getVoiceGender() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    // Male is the NurVerse default. Existing female preference is preserved.
    return value == female ? female : male;
  }

  static Future<void> setVoiceGender(String value) async {
    final gender = value == female ? female : male;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, gender);
  }

  /// Applies a real device voice when the platform exposes one.
  ///
  /// Android/Google TTS exposes Arabic voice identifiers such as:
  ///   ar-xa-x-ard-local  -> male
  ///   ar-xa-x-are-local  -> male
  ///   ar-xa-x-arc-local  -> female
  ///   ar-xa-x-arz-local  -> female
  ///
  /// We deliberately do NOT use pitch as a gender substitute. If a requested
  /// gender voice is unavailable on the device, the engine's Arabic default is
  /// used at neutral pitch rather than pretending that a female voice is male.
  static Future<void> apply(FlutterTts tts) async {
    final gender = await getVoiceGender();

    await tts.setLanguage('ar-SA');
    await tts.setSpeechRate(0.42);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);

    try {
      if (Platform.isAndroid) {
        final rawVoices = await tts.getVoices;
        final voices = rawVoices
            .whereType<Map>()
            .map(
              (voice) => Map<String, String>.from(
                voice.map(
                  (key, value) => MapEntry(key.toString(), value.toString()),
                ),
              ),
            )
            .where(
              (voice) =>
                  (voice['locale'] ?? '').toLowerCase().replaceAll('_', '-') ==
                  'ar-xa',
            )
            .toList();

        final maleNames = <String>[
          'ar-xa-x-ard-local',
          'ar-xa-x-are-local',
        ];
        final femaleNames = <String>[
          'ar-xa-x-arc-local',
          'ar-xa-x-arz-local',
        ];
        final candidates = gender == male ? maleNames : femaleNames;

        for (final candidate in candidates) {
          Map<String, String>? match;
          for (final voice in voices) {
            final name = (voice['name'] ?? '').toLowerCase();
            if (name == candidate) {
              match = voice;
              break;
            }
          }
          if (match != null) {
            await tts.setVoice(match);
            return;
          }
        }

        // Some Android engines expose the exact voice name but a slightly
        // different locale string. Match the voice name only as a secondary
        // check; the identifier itself is gender-specific.
        for (final candidate in candidates) {
          final match = voices.cast<Map<String, String>?>().firstWhere(
            (voice) => (voice?['name'] ?? '').toLowerCase() == candidate,
            orElse: () => null,
          );
          if (match != null) {
            await tts.setVoice(match);
            return;
          }
        }
      } else {
        // iOS/macOS expose gender metadata through flutter_tts. Use it when
        // available instead of guessing from voice names.
        final rawVoices = await tts.getVoices;
        final voices = rawVoices
            .whereType<Map>()
            .map(
              (voice) => Map<String, String>.from(
                voice.map(
                  (key, value) => MapEntry(key.toString(), value.toString()),
                ),
              ),
            )
            .where(
              (voice) =>
                  (voice['locale'] ?? '').toLowerCase().startsWith('ar'),
            )
            .toList();

        final wanted = gender == male ? 'male' : 'female';
        for (final voice in voices) {
          if ((voice['gender'] ?? '').toLowerCase() == wanted) {
            await tts.setVoice(voice);
            return;
          }
        }
      }
    } catch (_) {
      // Keep the device's Arabic default voice at neutral pitch.
    }
  }
}
