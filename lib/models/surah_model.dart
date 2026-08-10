class SurahModel {
  final int id;
  final String nameBangla;
  final String nameArabic;
  final String nameEnglish;
  final String meaning;
  final int versesCount;
  final String revelationType; // মাক্কী বা মাদানী
  final List<AyahModel> ayahs;

  // SurahDetailsScreen-এর সুবিধার জন্য গেটারসমূহ
  String get englishName => nameEnglish;
  String get name => nameArabic;
  int get numberOfAyahs => versesCount;
  int get number => id;

  SurahModel({
    required this.id,
    required this.nameBangla,
    required this.nameArabic,
    required this.nameEnglish,
    required this.meaning,
    required this.versesCount,
    required this.revelationType,
    required this.ayahs,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      id: json['id'] ?? json['number'] ?? 0,
      nameBangla: json['nameBangla'] ?? '',
      nameArabic: json['nameArabic'] ?? json['name'] ?? '',
      nameEnglish: json['nameEnglish'] ?? json['englishName'] ?? '',
      meaning: json['meaning'] ?? '',
      versesCount: json['versesCount'] ?? json['numberOfAyahs'] ?? 0,
      revelationType: json['revelationType'] ?? 'মাক্কী',
      ayahs:
          json['ayahs'] != null
              ? (json['ayahs'] as List)
                  .map((a) => AyahModel.fromJson(a as Map<String, dynamic>))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameBangla': nameBangla,
      'nameArabic': nameArabic,
      'nameEnglish': nameEnglish,
      'meaning': meaning,
      'versesCount': versesCount,
      'revelationType': revelationType,
      'ayahs': ayahs.map((a) => a.toJson()).toList(),
    };
  }
}

class AyahModel {
  final int number;
  final String text;
  final int numberInSurah;

  AyahModel({
    required this.number,
    required this.text,
    required this.numberInSurah,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      number: json['number'] ?? 0,
      text: json['text'] ?? '',
      numberInSurah: json['numberInSurah'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'number': number, 'text': text, 'numberInSurah': numberInSurah};
  }
}
