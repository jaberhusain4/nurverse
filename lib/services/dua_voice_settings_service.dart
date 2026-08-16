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
    // Male is the NurVerse default. Preserve an explicitly saved female choice.
    return value == female ? female : male;
  }

  static Future<void> setVoiceGender(String value) async {
    final gender = value == female ? female : male;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, gender);
  }

  static String _normalizeLocale(String value) =>
      value.toLowerCase().replaceAll('_', '-');

  static String _normalizeName(String value) => value.toLowerCase().trim();

  static List<Map<String, String>> _voiceMaps(dynamic rawVoices) {
    if (rawVoices is! List) return const [];

    return rawVoices.whereType<Map>().map((voice) {
      return Map<String, String>.from(
        voice.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        ),
      );
    }).toList();
  }

  static bool _isArabic(Map<String, String> voice) {
    final locale = _normalizeLocale(voice['locale'] ?? '');
    return locale == 'ar-xa' ||
        locale == 'ar-sa' ||
        locale.startsWith('ar-');
  }

  static bool _hasFeature(Map<String, String> voice, String feature) {
    final features = (voice['features'] ?? '').toLowerCase();
    return features.contains(feature);
  }

  static Map<String, String>? _findAndroidVoice(
    List<Map<String, String>> voices,
    String gender,
  ) {
    final maleNames = <String>[
      'ar-xa-x-ard-local',
      'ar-xa-x-are-local',
      'ar-xa-x-ard-network',
      'ar-xa-x-are-network',
    ];
    final femaleNames = <String>[
      'ar-xa-x-arc-local',
      'ar-xa-x-arz-local',
      'ar-xa-x-arc-network',
      'ar-xa-x-arz-network',
    ];
    final exactNames = gender == male ? maleNames : femaleNames;

    // 1. Prefer the known Google Arabic voice identifiers. These are
    //    gender-specific and are not inferred from pitch.
    for (final wanted in exactNames) {
      for (final voice in voices) {
        if (_normalizeName(voice['name'] ?? '') == wanted) {
          return voice;
        }
      }
    }

    // 2. Some TTS engines expose gender in Voice.features. Prefer that over
    //    guessing from an arbitrary voice name.
    final featureMatch = voices.where((voice) {
      if (gender == male) return _hasFeature(voice, 'male');
      return _hasFeature(voice, 'female');
    }).toList();
    if (featureMatch.isNotEmpty) return featureMatch.first;

    // 3. Google Android voice names use the final voice code to distinguish
    //    these Arabic voices. Keep this only as a last identifier-based check.
    final suffixes = gender == male
        ? const ['-ard-local', '-are-local', '-ard-network', '-are-network']
        : const ['-arc-local', '-arz-local', '-arc-network', '-arz-network'];

    for (final suffix in suffixes) {
      for (final voice in voices) {
        final name = _normalizeName(voice['name'] ?? '');
        if (name.startsWith('ar-xa-x-') && name.endsWith(suffix)) {
          return voice;
        }
      }
    }

    return null;
  }

  static Future<bool> apply(FlutterTts tts) async {
    final gender = await getVoiceGender();

    await tts.stop();
    await tts.setSpeechRate(0.42);
    await tts.setVolume(1.0);
    // Never use pitch to simulate gender.
    await tts.setPitch(1.0);

    try {
      if (Platform.isAndroid) {
        final voices = _voiceMaps(await tts.getVoices)
            .where(_isArabic)
            .toList();

        final match = _findAndroidVoice(voices, gender);
        if (match != null) {
          await tts.setVoice(match);
          // Keep the locale consistent with the selected Arabic voice.
          final locale = match['locale'];
          if (locale != null && locale.isNotEmpty) {
            await tts.setLanguage(locale);
          } else {
            await tts.setLanguage('ar-XA');
          }
          return true;
        }

        // Do not silently fall back to the other gender. That was the reason
        // both options could sound identical on devices without a selected
        // voice. Returning false lets the caller know a real gendered voice
        // was not available from the current TTS engine.
        await tts.setLanguage('ar-XA');
        return false;
      }

      // iOS/macOS can expose gender through the voice metadata. Use it when
      // available and never change pitch to imitate a gender.
      final voices = _voiceMaps(await tts.getVoices)
          .where((voice) => _isArabic(voice))
          .toList();
      final wanted = gender == male ? 'male' : 'female';

      for (final voice in voices) {
        if ((voice['gender'] ?? '').toLowerCase() == wanted) {
          await tts.setVoice(voice);
          final locale = voice['locale'];
          if (locale != null && locale.isNotEmpty) {
            await tts.setLanguage(locale);
          }
          return true;
        }
      }
    } catch (_) {
      // Keep the engine stable; callers can treat false as unavailable.
    }

    await tts.setLanguage('ar-XA');
    return false;
  }
}
