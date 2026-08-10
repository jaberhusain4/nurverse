class QuranVerse {
  final int number; // ayah number within the surah (1-based)
  final String arabic;
  String? bangla; // null until the Bangla translation is available

  QuranVerse({required this.number, required this.arabic, this.bangla});
}

class QuranSurah {
  final int number;
  final String arabicName;
  final String transliteration;
  final String type; // meccan / medinan
  final int totalVerses;
  String? banglaName;
  final List<QuranVerse> verses;

  QuranSurah({
    required this.number,
    required this.arabicName,
    required this.transliteration,
    required this.type,
    required this.totalVerses,
    required this.verses,
    this.banglaName,
  });
}
