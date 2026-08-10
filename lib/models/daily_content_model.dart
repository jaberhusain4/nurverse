enum DailyContentType { ayah, hadith, dua }

class DailyContentModel {
  final DailyContentType type;

  final String title;

  final String arabic;

  final String bangla;

  final String reference;

  const DailyContentModel({
    required this.type,
    required this.title,
    required this.arabic,
    required this.bangla,
    required this.reference,
  });
}
