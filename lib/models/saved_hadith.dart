// lib/models/saved_hadith.dart

class SavedHadith {
  final String key;
  final String bookKey;
  final String bookNameBn;
  final String chapterNameBn;
  final String hadithNo;
  final String arabic;
  final String bangla;
  final String english;
  final String narrator;
  final String reference;
  final String grade;
  final DateTime savedAt;

  const SavedHadith({
    required this.key,
    required this.bookKey,
    required this.bookNameBn,
    required this.chapterNameBn,
    required this.hadithNo,
    required this.arabic,
    required this.bangla,
    this.english = '',
    required this.narrator,
    required this.reference,
    required this.grade,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'bookKey': bookKey,
        'bookNameBn': bookNameBn,
        'chapterNameBn': chapterNameBn,
        'hadithNo': hadithNo,
        'arabic': arabic,
        'bangla': bangla,
        'english': english,
        'narrator': narrator,
        'reference': reference,
        'grade': grade,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedHadith.fromJson(Map<String, dynamic> json) {
    return SavedHadith(
      key: json['key']?.toString() ?? '',
      bookKey: json['bookKey']?.toString() ?? '',
      bookNameBn: json['bookNameBn']?.toString() ?? '',
      chapterNameBn: json['chapterNameBn']?.toString() ?? '',
      hadithNo: json['hadithNo']?.toString() ?? '',
      arabic: json['arabic']?.toString() ?? '',
      bangla: json['bangla']?.toString() ?? '',
      english: json['english']?.toString() ?? '',
      narrator: json['narrator']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
      savedAt: DateTime.tryParse(json['savedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
