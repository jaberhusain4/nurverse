enum DailyContentType { ayah, hadith, dua }

class DailyContentModel {
  final DailyContentType type;

  final String title;
  final String arabic;
  final String bangla;
  final String english;
  final String reference;
  final String englishReference;

  const DailyContentModel({
    required this.type,
    required this.title,
    required this.arabic,
    required this.bangla,
    required this.english,
    required this.reference,
    required this.englishReference,
  });
}
