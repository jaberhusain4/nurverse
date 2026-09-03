from pathlib import Path
import re

path = Path('lib/screens/canonical_settings_screen.dart')
s = path.read_text(encoding='utf-8')

# Dedicated Jamaat screen.
if "prayer/jamaat_settings_screen.dart" not in s:
    s = s.replace("import 'home_mode_settings_screen.dart';\n", "import 'home_mode_settings_screen.dart';\nimport 'prayer/jamaat_settings_screen.dart';\n", 1)

# Replace the five inline Jamaat rows with one entry that opens Jamaat Settings.
pattern = re.compile(r"\n\s*_divider\(\),\n\s*_jamaatTile\(context, s, 'Fajr'.*?_jamaatTile\(context, s, 'Isha'.*?\),", re.S)
replacement = """\n            _divider(),\n            _tile(\n              context,\n              Icons.groups_rounded,\n              t(lang, 'জামাতের সময়', 'Jamaat Times'),\n              t(lang, 'ফজর, যোহর, আসর, মাগরিব ও ইশার জামাতের সময়', 'Set Fajr, Dhuhr, Asr, Maghrib and Isha Jamaat times'),\n              () => Navigator.push(\n                context,\n                MaterialPageRoute<void>(builder: (_) => const JamaatSettingsScreen()),\n              ),\n            ),"""
s, count = pattern.subn(replacement, s, count=1)
if count == 0:
    raise SystemExit('Inline Jamaat rows not found.')

# Remove Prayer Adjustments from the main Settings screen.
s = re.sub(r"\n\s*_divider\(\),\n\s*_tile\(\s*context,\s*Icons\.tune_rounded,\s*t\(lang, 'সালাতের সময় সমন্বয়'.*?\),", '', s, count=1, flags=re.S)

# Restore the account/login Premium hero used by the previous Settings UI.
start = s.find('  Widget _buildPremiumHero(')
if start < 0:
    raise SystemExit('Premium hero method not found.')
brace = s.find('{', start)
depth = 0
quote = None
esc = False
end = None
for i in range(brace, len(s)):
    c = s[i]
    if quote:
        if esc: esc = False
        elif c == '\\': esc = True
        elif c == quote: quote = None
        continue
    if c in "'\"": quote = c
    elif c == '{': depth += 1
    elif c == '}':
        depth -= 1
        if depth == 0:
            end = i + 1
            break
if end is None:
    raise SystemExit('Premium hero method is unclosed.')

premium = '''  Widget _buildPremiumHero(BuildContext context, SettingsProvider settings, PremiumProvider premium) {
    final lang = settings.languageCode;
    final user = FirebaseAuth.instance.currentUser;
    final active = premium.isPremium;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.seaBlue.withValues(alpha: .20)),
        boxShadow: [
          BoxShadow(color: AppColors.seaBlue.withValues(alpha: .07), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.seaBlue.withValues(alpha: .12),
            backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null
                ? Icon(user == null ? Icons.login_rounded : Icons.person_rounded, color: AppColors.seaBlue, size: 30)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NurVerse Premium', style: TextStyle(color: AppColors.seaBlue, fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  active
                      ? t(lang, 'প্রিমিয়াম সক্রিয়', 'Premium active')
                      : (user?.displayName ?? t(lang, 'Google দিয়ে লগইন করুন', 'Sign in with Google')),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, height: 1.35, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: .72)),
                ),
              ],
            ),
          ),
          Icon(user == null ? Icons.login_rounded : Icons.account_circle_outlined, color: AppColors.seaBlue, size: 24),
        ],
      ),
    );
  }'''
s = s[:start] + premium + s[end:]

# Localize all internal enum/value labels used by the canonical screen.
start = s.find('  String _choiceLabel(')
if start >= 0:
    brace = s.find('{', start)
    depth = 0
    quote = None
    esc = False
    end = None
    for i in range(brace, len(s)):
        c = s[i]
        if quote:
            if esc: esc = False
            elif c == '\\': esc = True
            elif c == quote: quote = None
            continue
        if c in "'\"": quote = c
        elif c == '{': depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                end = i + 1
                break
    if end is None: raise SystemExit('Choice label method is unclosed.')
    helper = '''  String _choiceLabel(String value, String languageCode) {
    const bn = <String, String>{
      'system': 'সিস্টেম অনুযায়ী', 'light': 'লাইট মোড', 'dark': 'ডার্ক মোড', 'amoled': 'অ্যামোলেড',
      'bn': 'বাংলা', 'en': 'ইংরেজি', 'ar': 'আরবি', '12': '১২ ঘণ্টা', '24': '২৪ ঘণ্টা',
      'automatic': 'স্বয়ংক্রিয়', 'manual': 'ম্যানুয়াল', 'Karachi': 'করাচি', 'Muslim World League': 'মুসলিম ওয়ার্ল্ড লীগ',
      'Egyptian': 'মিশরীয়', 'Umm Al Qura': 'উম্মুল কুরা', 'Dubai': 'দুবাই', 'Qatar': 'কাতার', 'Kuwait': 'কুয়েত',
      'Singapore': 'সিঙ্গাপুর', 'North America': 'উত্তর আমেরিকা', 'Moonsighting Committee': 'চাঁদ দেখা কমিটি',
      'Tehran': 'তেহরান', 'Turkey': 'তুরস্ক', 'Other': 'অন্যান্য', 'Hanafi': 'হানাফি', 'Shafi': 'শাফেয়ি',
      'Maliki': 'মালিকি', 'Hanbali': 'হাম্বলি', 'Bangla': 'বাংলা', 'English': 'ইংরেজি', 'Arabic': 'আরবি',
      'Default': 'ডিফল্ট', 'Silent': 'নীরব', 'Amiri': 'আমিরি', 'Scheherazade': 'শেহেরাজাদে',
      'hijri': 'হিজরি', 'gregorian': 'গ্রেগরিয়ান', 'both': 'উভয়',
    };
    if (languageCode == 'bn') return bn[value] ?? value;
    if (languageCode == 'en') {
      if (value == '12') return '12-hour';
      if (value == '24') return '24-hour';
      return value;
    }
    const ar = <String, String>{
      'system': 'النظام', 'light': 'فاتح', 'dark': 'داكن', 'amoled': 'AMOLED', 'bn': 'البنغالية',
      'en': 'الإنجليزية', 'ar': 'العربية', '12': '12 ساعة', '24': '24 ساعة', 'automatic': 'تلقائي',
      'manual': 'يدوي', 'Karachi': 'كراتشي', 'Muslim World League': 'رابطة العالم الإسلامي', 'Egyptian': 'المصري',
      'Umm Al Qura': 'أم القرى', 'Dubai': 'دبي', 'Qatar': 'قطر', 'Kuwait': 'الكويت', 'Singapore': 'سنغافورة',
      'North America': 'أمريكا الشمالية', 'Moonsighting Committee': 'لجنة رؤية الهلال', 'Tehran': 'طهران',
      'Turkey': 'تركيا', 'Other': 'أخرى', 'Hanafi': 'حنفي', 'Shafi': 'شافعي', 'Maliki': 'مالكي',
      'Hanbali': 'حنبلي', 'Bangla': 'البنغالية', 'English': 'الإنجليزية', 'Arabic': 'العربية',
      'Default': 'افتراضي', 'Silent': 'صامت', 'Amiri': 'أميري', 'Scheherazade': 'شهرزاد',
      'hijri': 'هجري', 'gregorian': 'ميلادي', 'both': 'كلاهما',
    };
    return ar[value] ?? value;
  }'''
    s = s[:start] + helper + s[end:]

# Localize the remaining English labels inside the Quran reading sheet.
s = s.replace("Text('Arabic: ${s.quranFontSize.round()}')", "Text(t(lang, 'আরবি: ${s.quranFontSize.round()}', 'Arabic: ${s.quranFontSize.round()}'))")
s = s.replace("Text('Translation: ${s.translationFontSize.round()}')", "Text(t(lang, 'অনুবাদ: ${s.translationFontSize.round()}', 'Translation: ${s.translationFontSize.round()}'))")

path.write_text(s, encoding='utf-8')
print('canonical settings patched')
