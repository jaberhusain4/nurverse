import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/premium_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/text_scale_provider.dart';
import 'auth/google_login_screen.dart';
import '../theme/app_theme.dart';
import 'home_mode_settings_screen.dart';
import 'prayer/jamaat_settings_screen.dart';

class CanonicalSettingsScreen extends StatelessWidget {
  const CanonicalSettingsScreen({super.key});

  String t(String l, String bn, String en, [String? ar]) => l == 'en'
      ? en
      : l == 'ar'
      ? (ar ?? en)
      : bn;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final scale = context.watch<TextScaleProvider>();
    final premium = context.watch<PremiumProvider>();
    final l = s.languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(t(l, 'সেটিংস', 'Settings', 'الإعدادات')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _premium(context, s, premium),
          const SizedBox(height: 18),
          _section(
            context,
            t(l, 'ব্যক্তিগতকরণ', 'Personalization'),
            Icons.tune_rounded,
            [
              _tile(
                context,
                Icons.dashboard_customize_outlined,
                t(l, 'হোম স্ক্রিন', 'Home Screen'),
                t(
                  l,
                  'সহজ বা বিস্তারিত হোম স্ক্রিন বেছে নিন',
                  'Choose your Home Screen style',
                ),
                () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const HomeModeSettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 20),
          _section(
            context,
            t(l, 'অ্যাপের চেহারা', 'Appearance'),
            Icons.palette_outlined,
            [
              _choice(
                context,
                Icons.palette_outlined,
                t(l, 'থিম', 'Theme'),
                themeLabel(s),
                ['system', 'light', 'dark', 'amoled'],
                s.themeId,
                (v) async {
                  if (v == 'system')
                    await s.setSystemTheme();
                  else if (v == 'light')
                    await s.setLightTheme();
                  else if (v == 'dark')
                    await s.setDarkTheme();
                  else
                    await s.setAmoledTheme();
                },
              ),
              _divider(),
              _choice(
                context,
                Icons.language_rounded,
                t(l, 'ভাষা', 'Language', 'اللغة'),
                l == 'bn'
                    ? 'বাংলা'
                    : l == 'ar'
                    ? 'العربية'
                    : 'English',
                ['bn', 'en', 'ar'],
                l,
                s.setLanguage,
              ),
              _divider(),
              _tile(
                context,
                Icons.text_fields_rounded,
                t(l, 'অ্যাপের লেখা', 'App Text Size'),
                textSizeLabel(scale.level, l),
                () => textSizeSheet(context, scale, l),
              ),
              _divider(),
              _timeFormatTile(context, s, l),
              _divider(),
              _switch(
                context,
                Icons.timer_outlined,
                t(l, 'সেকেন্ড দেখান', 'Show Seconds'),
                t(
                  l,
                  'যেখানে সমর্থিত সেখানে সেকেন্ড দেখাবে',
                  'Show seconds where supported',
                ),
                s.showSeconds,
                s.toggleShowSeconds,
              ),
              _divider(),
              _switch(
                context,
                Icons.vibration_rounded,
                t(l, 'ভাইব্রেশন', 'Vibration'),
                t(
                  l,
                  'সমর্থিত অ্যাকশনে হ্যাপটিক ফিডব্যাক',
                  'Allow supported haptic feedback',
                ),
                s.vibrationEnabled,
                s.toggleVibration,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            t(l, 'সালাত ও আজান', 'Prayer & Adhan'),
            Icons.mosque_outlined,
            [
              _choice(
                context,
                Icons.calculate_outlined,
                t(l, 'সালাতের হিসাব পদ্ধতি', 'Prayer Calculation'),
                choice(s.calculationMethod, l),
                SettingsProvider.calculationMethods,
                s.calculationMethod,
                s.setCalculationMethod,
              ),
              _divider(),
              _choice(
                context,
                Icons.mosque_outlined,
                t(l, 'মাযহাব', 'Madhhab'),
                choice(s.madhhab, l),
                SettingsProvider.madhabs,
                s.madhhab,
                s.setMadhhab,
              ),
              _divider(),
              _choice(
                context,
                Icons.location_on_outlined,
                t(l, 'লোকেশন', 'Location'),
                s.autoLocation
                    ? t(l, 'স্বয়ংক্রিয়', 'Automatic')
                    : t(l, 'ম্যানুয়াল', 'Manual'),
                ['automatic', 'manual'],
                s.locationMode,
                s.setLocationMode,
              ),
              _divider(),
              _switch(
                context,
                Icons.notifications_active_outlined,
                t(l, 'আজান নোটিফিকেশন', 'Adhan Notifications'),
                t(
                  l,
                  'সালাতের সময় নোটিফিকেশন চালু রাখুন',
                  'Enable prayer-time notifications',
                ),
                s.isAdhanNotificationEnabled,
                s.toggleAdhanNotification,
              ),
              _divider(),
              _choice(
                context,
                Icons.volume_up_outlined,
                t(l, 'আজানের শব্দ', 'Adhan Sound'),
                choice(s.notificationSound, l),
                ['Default', 'Silent'],
                s.notificationSound,
                s.setNotificationSound,
              ),
              _divider(),
              _choice(
                context,
                Icons.alarm_outlined,
                t(l, 'সালাতের আগে স্মরণ', 'Prayer Reminder'),
                reminder(s.prayerReminderMinutes, l),
                ['0', '5', '10', '15', '20', '30'],
                '${s.prayerReminderMinutes}',
                (v) => s.setPrayerReminderMinutes(int.parse(v)),
              ),
              _divider(),
              _choice(
                context,
                Icons.calendar_today_outlined,
                t(l, 'হিজরি তারিখ সমন্বয়', 'Hijri Date Adjustment'),
                hijri(s.hijriAdjustment, l),
                ['-3', '-2', '-1', '0', '1', '2', '3'],
                '${s.hijriAdjustment}',
                (v) => s.setHijriAdjustment(int.parse(v)),
              ),
              _divider(),
              _tile(
                context,
                Icons.today_outlined,
                t(l, 'দৈনিক কনটেন্ট', 'Daily Content'),
                t(l, 'আয়াত, হাদিস ও দোয়া', 'Ayah, Hadith and Dua'),
                () => dailySheet(context, s, l),
              ),
              _divider(),
              _choice(
                context,
                Icons.calendar_month_outlined,
                t(l, 'তারিখের পছন্দ', 'Date Preferences'),
                dateLabel(s.dateDisplayPreference, l),
                ['hijri', 'gregorian', 'both'],
                s.dateDisplayPreference,
                s.setDateDisplayPreference,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            t(l, 'ডেটা ও অ্যাপ', 'Data & App'),
            Icons.settings_applications_outlined,
            [
              _tile(
                context,
                Icons.restart_alt_rounded,
                t(l, 'সব সেটিংস রিসেট', 'Reset Settings'),
                t(
                  l,
                  'সব সেটিংস ডিফল্টে ফিরিয়ে দিন',
                  'Restore all configurable settings',
                ),
                () => resetDialog(context, s, l),
              ),
              _divider(),
              _tile(
                context,
                Icons.info_outline_rounded,
                t(l, 'নূরভার্স সম্পর্কে', 'About NurVerse'),
                'NurVerse',
                () => showAboutDialog(
                  context: context,
                  applicationName: 'NurVerse',
                  applicationVersion: '1.0.0',
                ),
              ),
              _divider(),
              _tile(
                context,
                Icons.code_rounded,
                t(l, 'ওপেন সোর্স লাইসেন্স', 'Open Source Licenses'),
                t(
                  l,
                  'নূরভার্সে ব্যবহৃত লাইব্রেরি',
                  'Libraries used by NurVerse',
                ),
                () => showLicensePage(
                  context: context,
                  applicationName: 'NurVerse',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _premium(
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
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(30),
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
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.seaBlue.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(
                      isActive
                          ? Icons.verified_rounded
                          : Icons.workspace_premium_rounded,
                      color: AppColors.seaBlue,
                      size: 32,
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(width: 7),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
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
                              ? t(
                                  languageCode,
                                  'আপনার প্রিমিয়াম অভিজ্ঞতা সক্রিয়',
                                  'Your premium experience is active',
                                  'تجربة بريميوم الخاصة بك مفعلة',
                                )
                              : t(
                                  languageCode,
                                  'আরও সমৃদ্ধ ও সুন্দর নূরভার্স উপভোগ করুন',
                                  'Unlock a richer, calmer NurVerse',
                                  'اكتشف تجربة نورفيرس أكثر ثراءً وهدوءًا',
                                ),
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
                            MaterialPageRoute<void>(
                              builder: (_) => const GoogleLoginScreen(),
                            ),
                          );
                          return;
                        }

                        if (!context.mounted) return;
                        await showModalBottomSheet<void>(
                          context: context,
                          showDragHandle: true,
                          builder: (sheetContext) {
                            return SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 34,
                                      backgroundImage: user.photoURL == null
                                          ? null
                                          : NetworkImage(user.photoURL!),
                                      child: user.photoURL == null
                                          ? const Icon(Icons.person_rounded, size: 34)
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      user.displayName?.trim().isNotEmpty == true
                                          ? user.displayName!
                                          : 'Google Account',
                                      style: Theme.of(sheetContext)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(fontWeight: FontWeight.w800),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (user.email?.isNotEmpty == true) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        user.email!,
                                        style: Theme.of(sheetContext).textTheme.bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                        onPressed: () async {
                                          await FirebaseAuth.instance.signOut();
                                          if (sheetContext.mounted) {
                                            Navigator.of(sheetContext).pop();
                                          }
                                        },
                                        icon: const Icon(Icons.logout_rounded),
                                        label: Text(
                                          t(languageCode, 'লগআউট', 'Log out', 'تسجيل الخروج'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
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
                            ? const Center(
                                child: Text(
                                  'G',
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.seaBlue,
                                  ),
                                ),
                              )
                            : (user.photoURL?.isNotEmpty == true
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.network(
                                      user.photoURL!,
                                      width: 42,
                                      height: 42,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person_rounded,
                                        color: AppColors.seaBlue,
                                        size: 22,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    color: AppColors.seaBlue,
                                    size: 22,
                                  )),
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
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.seaBlue.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.seaBlue),
        const SizedBox(width: 5),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.seaBlue,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Widget _section(
    BuildContext c,
    String title,
    IconData icon,
    List<Widget> children,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 9),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.seaBlue),
            const SizedBox(width: 7),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    ],
  );

  Widget _tile(
    BuildContext c,
    IconData icon,
    String title,
    String sub,
    VoidCallback onTap,
  ) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.seaBlue.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.seaBlue, size: 21),
    ),
    title: Text(title),
    subtitle: Text(sub),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );

  Widget _divider() => const Divider(height: 1, indent: 70, endIndent: 15);

  Widget _choice(
    BuildContext c,
    IconData icon,
    String title,
    String sub,
    List<String> options,
    String selected,
    ValueChanged<String> onChanged,
  ) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.seaBlue.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.seaBlue, size: 21),
    ),
    title: Text(title),
    subtitle: Text(sub),
    trailing: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selected,
        items: options
            .map((v) => DropdownMenuItem<String>(value: v, child: Text(choice(v, sLanguageCode(c)))))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    ),
  );

  Widget _switch(
    BuildContext c,
    IconData icon,
    String title,
    String sub,
    bool value,
    ValueChanged<bool> onChanged,
  ) => SwitchListTile.adaptive(
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
    secondary: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.seaBlue.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.seaBlue, size: 21),
    ),
    title: Text(title),
    subtitle: Text(sub),
    value: value,
    onChanged: onChanged,
  );

  Widget _timeFormatTile(BuildContext context, SettingsProvider s, String l) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.seaBlue.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.schedule_rounded, color: AppColors.seaBlue, size: 21),
      ),
      title: Text(t(l, 'সময় ফরম্যাট', 'Time Format')),
      subtitle: Text(s.use24HourFormat ? '24-hour' : '12-hour'),
      trailing: SegmentedButton<bool>(
        segments: const [
          ButtonSegment<bool>(value: false, label: Text('12h')),
          ButtonSegment<bool>(value: true, label: Text('24h')),
        ],
        selected: {s.use24HourFormat},
        onSelectionChanged: (v) {
          if (v.isNotEmpty) s.set24HourFormat(v.first);
        },
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.seaBlue;
            return null;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const BorderSide(color: AppColors.seaBlue);
            }
            return null;
          }),
        ),
      ),
    );
  }

  String sLanguageCode(BuildContext c) => c.read<SettingsProvider>().languageCode;

  String themeLabel(SettingsProvider s) => choice(s.themeId, s.languageCode);
  String textSizeLabel(TextScaleLevel level, String l) => choice(level.name, l);
  String choice(String value, String l) => value;
  String reminder(int value, String l) => value == 0 ? t(l, 'বন্ধ', 'Off') : '$value min';
  String hijri(int value, String l) => value == 0 ? t(l, 'কোনো সমন্বয় নেই', 'No adjustment') : '${value > 0 ? '+' : ''}$value day';
  String dateLabel(String value, String l) => value == 'hijri' ? t(l, 'হিজরি', 'Hijri') : value == 'gregorian' ? t(l, 'ইংরেজি', 'Gregorian') : t(l, 'উভয়', 'Both');

  Future<void> dailySheet(BuildContext context, SettingsProvider s, String l) async {}
  Future<void> resetDialog(BuildContext context, SettingsProvider s, String l) async {}
  String choiceFallback(String value) => value;
  Future<void> textSizeSheet(BuildContext context, TextScaleProvider scale, String l) async {}
}
