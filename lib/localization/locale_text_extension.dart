import 'app_localizations.dart';

/// Future-proof locale resolver for user-facing strings.
///
/// Callers provide the translations they currently support. The resolver uses
/// the active locale when available, then falls back to English, then the
/// first supplied value. This keeps UI code independent from language
/// branching and makes future locale additions incremental.
extension LocaleTextExtension on AppLocalizations {
  String localeText({
    required Map<String, String> values,
    String fallbackLocale = 'en',
  }) {
    final active = values[locale.languageCode];
    if (active != null) return active;

    final fallback = values[fallbackLocale];
    if (fallback != null) return fallback;

    return values.values.isNotEmpty ? values.values.first : '';
  }
}
