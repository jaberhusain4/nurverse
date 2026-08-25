import 'app_localizations.dart';

/// Provides a direct three-locale lookup for small dynamic UI labels.
extension AppLocalizationsLocaleTextX on AppLocalizations {
  String localeText({required Map<String, String> values}) {
    return values[locale.languageCode] ?? values['en'] ?? values.values.first;
  }
}
