import 'package:flutter/material.dart';

import '../services/quran/quran_service.dart';

class QuranController extends ChangeNotifier {
  final QuranService _service = QuranService();

  List<Map<String, dynamic>> quran = [];
  bool loading = true;

  Future<void> initialize() async {
    loading = true;
    notifyListeners();

    try {
      quran = await _service.loadQuran();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getPara(int para) {
    return quran.where((e) => e['para'] == para).toList();
  }

  List<Map<String, dynamic>> getSurah(int surah) {
    return quran.where((e) => e['surah'] == surah).toList();
  }

  List<int> get paras =>
      quran
          .map((e) => e['para'])
          .whereType<int>()
          .toSet()
          .toList()
        ..sort();

  List<int> get surahs =>
      quran
          .map((e) => e['surah'])
          .whereType<int>()
          .toSet()
          .toList()
        ..sort();
}
