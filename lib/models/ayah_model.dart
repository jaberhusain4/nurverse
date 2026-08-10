class AyahModel {
  final int numberInSurah;
  final String text;

  AyahModel({
    required this.numberInSurah,
    required this.text,
  });


  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      numberInSurah: json["numberInSurah"] ?? json["number"] ?? 0,
      text: json["text"] ?? "",
    );
  }
}