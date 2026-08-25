import 'app_localizations.dart';

/// Extensible locale-aware value resolver.
///
/// UI code should pass locale values by language code instead of branching on
/// `isBangla`, `isEnglish`, or `isArabic`. Missing future locales fall back to
/// English, then Bengali, then the first available value.
extension LocalizedValueX on AppLocalizations {
  String localizedValue(
    Map<String, String> values, {
    String fallback = '',
  }) {
    final current = values[locale.languageCode]?.trim();
    if (current != null && current.isNotEmpty) return current;

    final english = values['en']?.trim();
    if (english != null && english.isNotEmpty) return english;

    final bangla = values['bn']?.trim();
    if (bangla != null && bangla.isNotEmpty) return bangla;

    for (final value in values.values) {
      final candidate = value.trim();
      if (candidate.isNotEmpty) return candidate;
    }

    return fallback;
  }
}
