import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/surah_model.dart';

class QuranService {
  static const String _baseUrl = "https://api.alquran.cloud/v1";

  /// Surah List
  Future<List<SurahModel>> getSurahs() async {
    final response = await http.get(
      Uri.parse("$_baseUrl/surah"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load Surahs");
    }

    final json = jsonDecode(response.body);

    return (json["data"] as List)
        .map((e) => SurahModel.fromJson(e))
        .toList();
  }

  /// Single Surah with Ayahs
  Future<SurahModel> getSurah(int number) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/surah/$number"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load Surah");
    }

    final json = jsonDecode(response.body);

    return SurahModel.fromJson(json["data"]);
  }
}