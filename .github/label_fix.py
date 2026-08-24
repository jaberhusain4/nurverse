from pathlib import Path

p = Path('lib/screens/settings_hub_screen_v4.dart')
s = p.read_text(encoding='utf-8')

old = """    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    await showModalBottomSheet<void>(
"""
new = """    final languageCode = Localizations.localeOf(context).languageCode;
    final isEnglish = languageCode == 'en';
    final isArabic = languageCode == 'ar';
    await showModalBottomSheet<void>(
"""
if old not in s:
    raise SystemExit('sheet locale pattern not found')
s = s.replace(old, new, 1)

old2 = """                title: Text(_choiceLabel(option, isEnglish)),
"""
new2 = """                title: Text(
                  options.length == 3 && options.contains('bn') && options.contains('en') && options.contains('ar')
                      ? (isEnglish
                          ? ({'bn': 'Bangla', 'en': 'English', 'ar': 'Arabic'}[option] ?? option)
                          : (isArabic
                              ? ({'bn': 'البنغالية', 'en': 'الإنجليزية', 'ar': 'العربية'}[option] ?? option)
                              : ({'bn': 'বাংলা', 'en': 'ইংরেজি', 'ar': 'আরবি'}[option] ?? option)))
                      : _choiceLabel(option, isEnglish),
                ),
"""
if old2 not in s:
    raise SystemExit('choice label pattern not found')
s = s.replace(old2, new2, 1)

p.write_text(s, encoding='utf-8')
