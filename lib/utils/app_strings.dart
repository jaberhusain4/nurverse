import 'package:flutter/material.dart';

/// Small bilingual dictionary. Covers navigation, screen titles and the
/// most common recurring labels. New keys can be added over time to
/// extend coverage to more of the app.
class AppStrings {
  static const Map<String, Map<String, String>> _dict = {
    'nav_home': {'bn': 'হোম', 'en': 'Home'},
    'nav_prayer': {'bn': 'নামাজ', 'en': 'Prayer'},
    'nav_quran': {'bn': 'কুরআন', 'en': 'Quran'},
    'nav_hadith': {'bn': 'হাদিস', 'en': 'Hadith'},
    'nav_tools': {'bn': 'টুলস', 'en': 'Tools'},
    'nav_more': {'bn': 'আরও', 'en': 'More'},
    'title_prayer': {'bn': 'নামাজের সময়সূচী', 'en': 'Prayer Times'},
    'title_quran': {'bn': 'কুরআন', 'en': 'Quran'},
    'title_hadith': {'bn': 'হাদিস', 'en': 'Hadith'},
    'title_tools': {'bn': 'টুলস', 'en': 'Tools'},
    'title_more': {'bn': 'আরও', 'en': 'More'},
    'title_settings': {'bn': 'সেটিংস', 'en': 'Settings'},
    'title_language': {'bn': 'ভাষা', 'en': 'Language'},
    'tab_hifz': {'bn': 'হিফজ কুরআন (পারা)', 'en': 'Hifz Quran (Para)'},
    'tab_study': {'bn': 'অধ্যয়ন কুরআন (সূরা)', 'en': 'Study Quran (Surah)'},
    'coming_soon': {'bn': 'এই ফিচারটি শীঘ্রই যুক্ত হবে', 'en': 'This feature is coming soon'},
    'downloading': {'bn': 'ডাউনলোড হচ্ছে…', 'en': 'Downloading…'},
    'offline_ready': {'bn': 'অফলাইনে প্রস্তুত', 'en': 'Ready offline'},
  };

  static String t(BuildContext context, String key) {
    final code = Localizations.localeOf(context).languageCode;
    final entry = _dict[key];
    if (entry == null) return key;
    return entry[code] ?? entry['bn'] ?? key;
  }
}
