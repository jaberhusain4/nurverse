from pathlib import Path
import re

path = Path('lib/screens/canonical_settings_screen.dart')
s = path.read_text(encoding='utf-8')

if "package:firebase_auth/firebase_auth.dart" not in s:
    s = s.replace("import 'package:flutter/material.dart';\n", "import 'package:firebase_auth/firebase_auth.dart';\nimport 'package:flutter/material.dart';\n", 1)
if "auth/google_login_screen.dart" not in s:
    s = s.replace("import 'home_mode_settings_screen.dart';\n", "import 'auth/google_login_screen.dart';\nimport 'home_mode_settings_screen.dart';\n", 1)

s = re.sub(r"\n\s*_divider\(\),\n\s*_tile\(\n\s*context,\n\s*Icons\.tune_rounded,\n\s*t\(lang, 'সালাতের সময় সমন্বয়', 'Prayer Adjustments'\),\n\s*_adjustmentLabel\(s, lang\),\n\s*\(\) => _adjustments\(context, s, lang\),\n\s*\),", '', s, count=1, flags=re.S)

if "t(lang, 'সময় ফরম্যাট', 'Time Format')" not in s:
    anchor = """              _divider(),
              _switchTile(
                context,
                Icons.timer_outlined,
                t(lang, 'সেকেন্ড দেখান', 'Show Seconds'),"""
    insert = """              _divider(),
              _choiceTile(
                context,
                Icons.access_time_rounded,
                t(lang, 'সময় ফরম্যাট', 'Time Format'),
                s.is24Hour ? t(lang, '২৪ ঘণ্টা', '24-hour') : t(lang, '১২ ঘণ্টা', '12-hour'),
                const ['12', '24'],
                s.timeFormat,
                s.setTimeFormat,
              ),
              _divider(),
              _switchTile(
                context,
                Icons.timer_outlined,
                t(lang, 'সেকেন্ড দেখান', 'Show Seconds'),"""
    if anchor not in s:
        raise SystemExit('Show Seconds anchor not found.')
    s = s.replace(anchor, insert, 1)


def replace_method(source, signature, replacement):
    start = source.find(signature)
    if start < 0:
        return source, False
    brace = source.find('{', start)
    if brace < 0:
        raise SystemExit(f'No opening brace for {signature}')
    depth = 0
    quote = None
    esc = False
    for i in range(brace, len(source)):
        c = source[i]
        if quote:
            if esc:
                esc = False
            elif c == '\\':
                esc = True
            elif c == quote:
                quote = None
            continue
        if c in "'\"":
            quote = c
        elif c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return source[:start] + replacement + source[i + 1:], True
    raise SystemExit(f'Unclosed method {signature}')

choice_helper = r'''  String _choiceLabel(String value, String languageCode) {
    const bn = <String, String>{
      'system': 'সিস্টেম', 'light': 'লাইট', 'dark': 'ডার্ক', 'amoled': 'AMOLED',
      'bn': 'বাংলা', 'en': 'ইংরেজি', 'ar': 'আরবি', '12': '১২ ঘণ্টা', '24': '২৪ ঘণ্টা',
      'automatic': 'স্বয়ংক্রিয়', 'manual': 'ম্যানুয়াল', 'Karachi': 'করাচি',
      'Muslim World League': 'মুসলিম ওয়ার্ল্ড লীগ', 'Egyptian': 'মিশরীয়', 'Umm Al Qura': 'উম্মুল কুরা',
      'Dubai': 'দুবাই', 'Qatar': 'কাতার', 'Kuwait': 'কুয়েত', 'Singapore': 'সিঙ্গাপুর',
      'North America': 'উত্তর আমেরিকা', 'Moonsighting Committee': 'চাঁদ দেখা কমিটি',
      'Tehran': 'তেহরান', 'Turkey': 'তুরস্ক', 'Other': 'অন্যান্য', 'Hanafi': 'হানাফি',
      'Shafi': 'শাফেয়ি', 'Maliki': 'মালিকি', 'Hanbali': 'হাম্বলি', 'Bangla': 'বাংলা',
      'English': 'ইংরেজি', 'Arabic': 'আরবি', 'Default': 'ডিফল্ট', 'Silent': 'নীরব',
      'hijri': 'হিজরি', 'gregorian': 'ইংরেজি', 'both': 'উভয়',
    };
    if (languageCode == 'bn') return bn[value] ?? value;
    if (languageCode == 'en') {
      if (value == '12') return '12-hour';
      if (value == '24') return '24-hour';
      return value;
    }
    const ar = <String, String>{
      'system': 'النظام', 'light': 'فاتح', 'dark': 'داكن', 'amoled': 'AMOLED',
      'bn': 'البنغالية', 'en': 'الإنجليزية', 'ar': 'العربية', '12': '12 ساعة', '24': '24 ساعة',
      'automatic': 'تلقائي', 'manual': 'يدوي', 'Karachi': 'كراتشي',
      'Muslim World League': 'رابطة العالم الإسلامي', 'Egyptian': 'المصري', 'Umm Al Qura': 'أم القرى',
      'Dubai': 'دبي', 'Qatar': 'قطر', 'Kuwait': 'الكويت', 'Singapore': 'سنغافورة',
      'North America': 'أمريكا الشمالية', 'Moonsighting Committee': 'لجنة رؤية الهلال',
      'Tehran': 'طهران', 'Turkey': 'تركيا', 'Other': 'أخرى', 'Hanafi': 'حنفي',
      'Shafi': 'شافعي', 'Maliki': 'مالكي', 'Hanbali': 'حنبلي', 'Bangla': 'البنغالية',
      'English': 'الإنجليزية', 'Arabic': 'العربية', 'Default': 'افتراضي', 'Silent': 'صامت',
      'hijri': 'هجري', 'gregorian': 'ميلادي', 'both': 'كلاهما',
    };
    return ar[value] ?? value;
  }'''
s, _ = replace_method(s, '  String _choiceLabel(', choice_helper)

premium = r'''  Widget _premiumCard(BuildContext context, PremiumProvider premium, String lang) {
    final user = FirebaseAuth.instance.currentUser;
    final active = premium.isPremium;
    final loggedIn = user != null;
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: loggedIn
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const GoogleLoginScreen()),
                ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: AppColors.seaBlue.withValues(alpha: .12),
                backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null
                    ? Icon(
                        loggedIn ? Icons.person_rounded : Icons.login_rounded,
                        color: AppColors.seaBlue,
                        size: 28,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NurVerse Premium', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(
                      loggedIn
                          ? (active
                              ? t(lang, 'Premium সক্রিয়', 'Premium active')
                              : (user.displayName ?? user.email ?? t(lang, 'অ্যাকাউন্ট সংযুক্ত', 'Account connected')))
                          : t(lang, 'Google দিয়ে লগইন করুন', 'Sign in with Google'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.35,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: .72),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                loggedIn ? Icons.verified_user_outlined : Icons.login_rounded,
                color: AppColors.seaBlue,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }'''
s, ok = replace_method(s, '  Widget _premiumCard(', premium)
if not ok:
    raise SystemExit('Premium card method not found.')

path.write_text(s, encoding='utf-8')
print('canonical settings patched')
