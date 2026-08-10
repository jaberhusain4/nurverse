// lib/services/asma_ul_husna_service.dart

class AsmaUlHusnaModel {
  final int id;
  final String arabic;
  final String transliteration;
  final String meaning;

  const AsmaUlHusnaModel({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
  });
}

class AsmaUlHusnaService {
  const AsmaUlHusnaService();

  // TODO:
  // Replace this list with the complete 99 Names dataset.
  static const List<AsmaUlHusnaModel> _names = [
    AsmaUlHusnaModel(
      id: 1,
      arabic: "ٱلرَّحْمَٰنُ",
      transliteration: "Ar-Rahman",
      meaning: "The Most Compassionate",
    ),
    AsmaUlHusnaModel(
      id: 2,
      arabic: "ٱلرَّحِيمُ",
      transliteration: "Ar-Rahim",
      meaning: "The Most Merciful",
    ),
    AsmaUlHusnaModel(
      id: 3,
      arabic: "ٱلْمَلِكُ",
      transliteration: "Al-Malik",
      meaning: "The King",
    ),
    AsmaUlHusnaModel(
      id: 4,
      arabic: "ٱلْقُدُّوسُ",
      transliteration: "Al-Quddus",
      meaning: "The Most Holy",
    ),
    AsmaUlHusnaModel(
      id: 5,
      arabic: "ٱلسَّلَامُ",
      transliteration: "As-Salam",
      meaning: "The Source of Peace",
    ),
  ];

  List<AsmaUlHusnaModel> getAll() => _names;

  AsmaUlHusnaModel? byId(int id) {
    try {
      return _names.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  AsmaUlHusnaModel get dailyName {
    final day = DateTime.now().difference(DateTime(2025, 1, 1)).inDays;

    return _names[day % _names.length];
  }

  List<AsmaUlHusnaModel> search(String keyword) {
    final q = keyword.trim().toLowerCase();

    if (q.isEmpty) return _names;

    return _names.where((item) {
      return item.transliteration.toLowerCase().contains(q) ||
          item.meaning.toLowerCase().contains(q) ||
          item.arabic.contains(keyword);
    }).toList();
  }
}
