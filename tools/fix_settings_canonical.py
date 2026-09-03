from pathlib import Path
import re

# Canonical Settings repairs. This script is intentionally idempotent.
p = Path('lib/screens/canonical_settings_screen.dart')
s = p.read_text(encoding='utf-8')

# Restore the larger premium hero/card with account icon and premium feature chips.
if "firebase_auth/firebase_auth.dart" not in s:
    s = s.replace("import 'package:flutter/material.dart';", "import 'package:firebase_auth/firebase_auth.dart';\nimport 'package:flutter/material.dart';", 1)
# Keep the imports minimal; GoogleLoginScreen is the only auth screen used here.
if "auth/google_login_screen.dart" not in s:
    s = s.replace("import '../theme/app_theme.dart';", "import 'auth/google_login_screen.dart';\nimport '../theme/app_theme.dart';", 1)
s = s.replace("import '../services/auth_service.dart';\n", "")

start = s.find('  Widget _premium(')
end = s.find('  Widget _section(', start)
if start >= 0 and end > start:
    premium = r'''  Widget _premium(
    BuildContext context,
    SettingsProvider settings,
    PremiumProvider premium,
  ) {
    final languageCode = settings.languageCode;
    final isActive = premium.isPremium;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.seaBlue.withValues(alpha: .20)),
            boxShadow: [
              BoxShadow(
                color: AppColors.seaBlue.withValues(alpha: .07),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.seaBlue.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(
                      isActive ? Icons.verified_rounded : Icons.workspace_premium_rounded,
                      color: AppColors.seaBlue,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'NurVerse Premium',
                                style: const TextStyle(
                                  color: AppColors.seaBlue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(width: 7),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.seaBlue.withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  t(languageCode, 'সক্রিয়', 'ACTIVE', 'نشط'),
                                  style: const TextStyle(
                                    color: AppColors.seaBlue,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isActive
                              ? t(languageCode, 'আপনার প্রিমিয়াম অভিজ্ঞতা সক্রিয়', 'Your premium experience is active', 'تجربة بريميوم الخاصة بك مفعلة')
                              : t(languageCode, 'আরও সমৃদ্ধ ও সুন্দর নূরভার্স উপভোগ করুন', 'Unlock a richer, calmer NurVerse', 'اكتشف تجربة نورفيرس أكثر ثراءً وهدوءًا'),
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: .70),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (user == null) {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => const GoogleLoginScreen()),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.seaBlue.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: user == null
                            ? Icon(Icons.person_outline_rounded, color: theme.colorScheme.primary, size: 22)
                            : Icon(Icons.person_rounded, color: theme.colorScheme.primary, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _premiumChip(Icons.contrast_rounded, t(languageCode, 'অ্যামোলেড', 'AMOLED', 'AMOLED')),
                  _premiumChip(Icons.palette_outlined, t(languageCode, 'প্রিমিয়াম থিম', 'Premium Themes', 'سمات بريميوم')),
                  _premiumChip(Icons.headphones_outlined, t(languageCode, 'তেলাওয়াত', 'Recitations', 'تلاوات')),
                  _premiumChip(Icons.cloud_outlined, t(languageCode, 'ক্লাউড সিঙ্ক', 'Cloud Sync', 'مزامنة سحابية')),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => premium.activatePremium(),
                  icon: Icon(
                    premium.isPremium ? Icons.settings_rounded : Icons.auto_awesome_rounded,
                    size: 18,
                  ),
                  label: Text(
                    premium.isPremium
                        ? t(languageCode, 'প্রিমিয়াম সক্রিয়', 'Premium Active', 'بريميوم نشط')
                        : t(languageCode, 'প্রিমিয়াম দেখুন', 'Explore Premium', 'استكشاف بريميوم'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _premiumChip(IconData icon, String title) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.seaBlue.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.seaBlue),
        const SizedBox(width: 5),
        Text(title, style: const TextStyle(color: AppColors.seaBlue, fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    ),
  );

'''
    s = s[:start] + premium + s[end:]

pattern = re.compile(r"\s*_choice\(\s*context,\s*Icons\.access_time_rounded,\s*t\(l, 'সময় ফরম্যাট', 'Time Format', 'تنسيق الوقت'\),.*?\n\s*\),\n\s*_divider\(\),", re.S)
replacement = r'''
            _timeFormatTile(context, s, l),
            _divider(),'''
s, count = pattern.subn(replacement, s, count=1)
if count == 0 and '_timeFormatTile(context, s, l)' not in s:
    raise SystemExit('time format row not found')

# The call itself is not a reliable guard; check for the method declaration.
if '  Widget _timeFormatTile(' not in s:
    marker = '  Widget _choice(\n'
    helper = r'''  Widget _timeFormatTile(BuildContext c, SettingsProvider s, String l) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
    leading: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.seaBlue.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Icon(Icons.access_time_rounded, size: 21, color: AppColors.seaBlue),
    ),
    title: Text(
      t(l, 'সময় ফরম্যাট', 'Time Format', 'تنسيق الوقت'),
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    ),
    subtitle: Text(
      s.is24Hour ? t(l, '২৪ ঘণ্টা', '24-hour', '24 ساعة') : t(l, '১২ ঘণ্টা', '12-hour', '12 ساعة'),
      style: const TextStyle(fontSize: 10.5, height: 1.3),
    ),
    trailing: SegmentedButton<String>(
      segments: [
        ButtonSegment<String>(value: '12', label: Text(t(l, '১২', '12', '12'))),
        ButtonSegment<String>(value: '24', label: Text(t(l, '২৪', '24', '24'))),
      ],
      selected: <String>{s.timeFormat},
      onSelectionChanged: (values) {
        if (values.isNotEmpty) s.setTimeFormat(values.first);
      },
      showSelectedIcon: false,
    ),
  );

'''
    s = s.replace(marker, helper + marker, 1)

# Localize common choice values in Bangla mode.
old_choice = """    const m = {
      'Karachi': 'করাচি',
      'Muslim World League': 'মুসলিম ওয়ার্ল্ড লীগ',
      'Egyptian': 'মিশরীয়',
      'Umm Al Qura': 'উম্মুল কুরা',
      'Dubai': 'দুবাই',
      'Qatar': 'কাতার',
      'Kuwait': 'কুয়েত',
      'Singapore': 'সিঙ্গাপুর',
      'North America': 'উত্তর আমেরিকা',
      'Moonsighting Committee': 'চাঁদ দেখা কমিটি',
      'Hanafi': 'হানাফি',
      'Shafi': 'শাফেয়ি',
      'Maliki': 'মালিকি',
      'Hanbali': 'হাম্বলি',
      'Bangla': 'বাংলা',
      'English': 'ইংরেজি',
      'Default': 'ডিফল্ট',
      'Silent': 'নীরব',
      'Amiri': 'আমিরি',
      'Scheherazade': 'শেহেরাজাদে',
      'hijri': 'হিজরি',
      'gregorian': 'গ্রেগরিয়ান',
      'both': 'উভয়',
    };"""
new_choice = old_choice.replace("      'both': 'উভয়',", "      'both': 'উভয়',\n      '12': '১২ ঘণ্টা',\n      '24': '২৪ ঘণ্টা',\n      'automatic': 'স্বয়ংক্রিয়',\n      'manual': 'ম্যানুয়াল',")
if old_choice in s:
    s = s.replace(old_choice, new_choice, 1)

p.write_text(s, encoding='utf-8')
print('settings repair applied')
