from pathlib import Path
import re

p = Path('lib/screens/settings_hub_screen_v4.dart')
s = p.read_text(encoding='utf-8')

# Repair references introduced by the first localization pass.
s = s.replace('settings._t(languageCode,', '_t(settings.languageCode,')
s = s.replace('current._t(languageCode,', '_t(current.languageCode,')

# The premium status dialog needs its own locale because it is a helper method.
s = s.replace(
    "Future<void> _showPremiumStatus(BuildContext context, PremiumProvider premium, bool isEnglish) async {\n    await showDialog<void>(",
    "Future<void> _showPremiumStatus(BuildContext context, PremiumProvider premium, bool isEnglish) async {\n    final languageCode = Localizations.localeOf(context).languageCode;\n    await showDialog<void>(",
    1,
)

# Keep Arabic font's Default label localized instead of falling back to Bangla.
s = s.replace(
    "settings.quranArabicFont == 'Default' && !isEnglish ? 'ডিফল্ট' : settings.quranArabicFont",
    "settings.quranArabicFont == 'Default' ? _t(languageCode, 'ডিফল্ট', 'Default') : settings.quranArabicFont",
)

# Ensure the top-level language row remains explicit and correct in every mode.
s = s.replace(
    "_t(languageCode, 'বাংলা', 'English', 'العربية')",
    "_t(languageCode, 'বাংলা', 'English', 'العربية')",
)

# Remove any accidental direct helper references that cannot compile.
s = s.replace('settings._t(', '_t(settings.languageCode,')
s = s.replace('current._t(', '_t(current.languageCode,')

p.write_text(s, encoding='utf-8')
print('Arabic Settings cleanup applied')
