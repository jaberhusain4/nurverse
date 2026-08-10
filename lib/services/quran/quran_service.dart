import 'package:flutter/material.dart';

import '../../models/surah_model.dart';

class QuranService {
  static final QuranService _instance = QuranService._internal();

  factory QuranService() => _instance;

  QuranService._internal();

  final List<SurahModel> _surahList = [
    SurahModel(
      id: 1,
      nameBangla: 'আল-ফাতিহা',
      nameArabic: 'الفاتحة',
      nameEnglish: 'Al-Fatihah',
      meaning: 'সূচনা',
      versesCount: 7,
      revelationType: 'মাক্কী',
      ayahs: const [],
    ),
    SurahModel(
      id: 2,
      nameBangla: 'আল-বাকারা',
      nameArabic: 'البقرة',
      nameEnglish: 'Al-Baqarah',
      meaning: 'গাভী',
      versesCount: 286,
      revelationType: 'মাদানী',
      ayahs: const [],
    ),
    SurahModel(
      id: 3,
      nameBangla: 'আলে-ইমরান',
      nameArabic: 'آل عمران',
      nameEnglish: "Ali 'Imran",
      meaning: 'ইমরানের পরিবার',
      versesCount: 200,
      revelationType: 'মাদানী',
      ayahs: const [],
    ),
    SurahModel(
      id: 36,
      nameBangla: 'ইয়াসীন',
      nameArabic: 'يس',
      nameEnglish: 'Ya-Sin',
      meaning: 'ইয়াসীন',
      versesCount: 83,
      revelationType: 'মাক্কী',
      ayahs: const [],
    ),
    SurahModel(
      id: 67,
      nameBangla: 'আল-মুলক',
      nameArabic: 'الملك',
      nameEnglish: 'Al-Mulk',
      meaning: 'রাজত্ব',
      versesCount: 30,
      revelationType: 'মাক্কী',
      ayahs: const [],
    ),
    SurahModel(
      id: 112,
      nameBangla: 'আল-ইখলাস',
      nameArabic: 'الإخلاص',
      nameEnglish: 'Al-Ikhlas',
      meaning: 'একনিষ্ঠতা',
      versesCount: 4,
      revelationType: 'মাক্কী',
      ayahs: const [],
    ),
  ];

  List<SurahModel> getAllSurahs() => List.unmodifiable(_surahList);

  SurahModel? getSurahById(int id) {
    try {
      return _surahList.firstWhere((surah) => surah.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Compatibility API for QuranController.
  /// The controller currently works with map records.
  Future<List<Map<String, dynamic>>> loadQuran() async {
    return _surahList
        .map(
          (surah) => <String, dynamic>{
            'surah': surah.id,
            'para': _paraForSurah(surah.id),
            'nameAr': surah.nameArabic,
            'nameBn': surah.nameBangla,
            'nameEn': surah.nameEnglish,
            'totalAyah': surah.versesCount,
          },
        )
        .toList();
  }

  int _paraForSurah(int surahNumber) {
    // This lightweight offline list does not contain complete Juz boundaries.
    // Keep the compatibility value deterministic until the full Quran data
    // source is connected.
    if (surahNumber == 1) return 1;
    if (surahNumber == 2) return 1;
    if (surahNumber == 3) return 3;
    if (surahNumber == 36) return 22;
    if (surahNumber == 67) return 29;
    if (surahNumber == 112) return 30;
    return 1;
  }

  Future<Map<String, dynamic>> getLastRead() async {
    return {
      'surahId': 2,
      'surahName': 'আল-বাকারা',
      'ayahNumber': 255,
    };
  }

  Future<void> toggleBookmark(int surahId, int ayahNumber) async {
    debugPrint('Toggled Bookmark: Surah $surahId, Ayah $ayahNumber');
  }
}
