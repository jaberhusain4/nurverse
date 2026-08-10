import 'package:flutter/material.dart';
import 'app_language.dart';

class LanguageController extends ChangeNotifier {
  AppLanguage _language = AppLanguage.bangla;

  AppLanguage get language => _language;

  bool get isBangla => _language == AppLanguage.bangla;

  void changeLanguage(AppLanguage language) {
    _language = language;
    notifyListeners();
  }
}
