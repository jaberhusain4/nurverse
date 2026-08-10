class DuaModel {
  final int id;
  final String title;
  final String arabic;
  final String translation;
  final String transliteration;
  final String reference;
  final String category;
  final bool isFavorite;

  DuaModel({
    required this.id,
    required this.title,
    required this.arabic,
    required this.translation,
    this.transliteration = '',
    required this.reference,
    required this.category,
    this.isFavorite = false,
  });

  DuaModel copyWith({
    int? id,
    String? title,
    String? arabic,
    String? translation,
    String? transliteration,
    String? reference,
    String? category,
    bool? isFavorite,
  }) {
    return DuaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      arabic: arabic ?? this.arabic,
      translation: translation ?? this.translation,
      transliteration: transliteration ?? this.transliteration,
      reference: reference ?? this.reference,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory DuaModel.fromJson(Map<String, dynamic> json) {
    return DuaModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      arabic: json['arabic'] ?? '',
      translation: json['translation'] ?? '',
      transliteration: json['transliteration'] ?? '',
      reference: json['reference'] ?? '',
      category: json['category'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'arabic': arabic,
      'translation': translation,
      'transliteration': transliteration,
      'reference': reference,
      'category': category,
      'isFavorite': isFavorite,
    };
  }
}
