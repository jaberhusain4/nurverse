import 'app_localizations.dart';

/// Text-size labels kept as an extension so the main localization file does
/// not need a large manual rewrite just to add these four settings labels.
extension AppLocalizationsTextSize on AppLocalizations {
  String get textSizeSmall => tr('ছোট', 'Small');
  String get textSizeNormal => tr('স্বাভাবিক', 'Normal');
  String get textSizeLarge => tr('বড়', 'Large');
  String get textSizeExtraLarge => tr('অতিরিক্ত বড়', 'Extra Large');
}
