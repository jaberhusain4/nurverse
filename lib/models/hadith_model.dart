class HadithModel {
  final int id;
  final String bookName;
  final int chapterId;
  final String chapterTitle;
  final int hadithNumber;
  final String arabicText;
  final String banglaText;
  final String narrator;
  final String grade; // সহীহ, হাসান ইত্যাদি
  final bool isFavorite;

  HadithModel({
    required this.id,
    required this.bookName,
    required this.chapterId,
    required this.chapterTitle,
    required this.hadithNumber,
    required this.arabicText,
    required this.banglaText,
    required this.narrator,
    required this.grade,
    this.isFavorite = false,
  });

  HadithModel copyWith({
    int? id,
    String? bookName,
    int? chapterId,
    String? chapterTitle,
    int? hadithNumber,
    String? arabicText,
    String? banglaText,
    String? narrator,
    String? grade,
    bool? isFavorite,
  }) {
    return HadithModel(
      id: id ?? this.id,
      bookName: bookName ?? this.bookName,
      chapterId: chapterId ?? this.chapterId,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      hadithNumber: hadithNumber ?? this.hadithNumber,
      arabicText: arabicText ?? this.arabicText,
      banglaText: banglaText ?? this.banglaText,
      narrator: narrator ?? this.narrator,
      grade: grade ?? this.grade,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      id: json['id'] ?? 0,
      bookName: json['bookName'] ?? '',
      chapterId: json['chapterId'] ?? 0,
      chapterTitle: json['chapterTitle'] ?? '',
      hadithNumber: json['hadithNumber'] ?? 0,
      arabicText: json['arabicText'] ?? '',
      banglaText: json['banglaText'] ?? '',
      narrator: json['narrator'] ?? '',
      grade: json['grade'] ?? 'সহীহ',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookName': bookName,
      'chapterId': chapterId,
      'chapterTitle': chapterTitle,
      'hadithNumber': hadithNumber,
      'arabicText': arabicText,
      'banglaText': banglaText,
      'narrator': narrator,
      'grade': grade,
      'isFavorite': isFavorite,
    };
  }
}
