class BookmarkModel {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String ayahText;

  BookmarkModel({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
  });

  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'ayahText': ayahText,
    };
  }

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      surahNumber: json['surahNumber'],
      surahName: json['surahName'],
      ayahNumber: json['ayahNumber'],
      ayahText: json['ayahText'],
    );
  }
}