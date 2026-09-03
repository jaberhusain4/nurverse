import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/premium_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/text_scale_provider.dart';
import '../theme/app_theme.dart';
import 'home_mode_settings_screen.dart';
import 'prayer/jamaat_settings_screen.dart';

class CanonicalSettingsScreen extends StatelessWidget {
  const CanonicalSettingsScreen({super.key});

  String t(String lang, String bn, String en) => lang == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final scale = context.watch<TextScaleProvider>();
    final premium = context.watch<PremiumProvider>();
    final lang = s.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(t(lang, 'সেটিংস', 'Settings')),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _premiumCard(context, premium, lang),
          const SizedBox(height: 16),
          _section(
            context,
            t(lang, 'ব্যক্তিগতকরণ', 'Personalization'),
            Icons.tune_rounded,
            [
              _tile(
                context,
                Icons.dashboard_customize_outlined,
                t(lang, 'হোম স্ক্রিন', 'Home Screen'),
                t(lang, 'সহজ বা বিস্তারিত হোম স্ক্রিন বেছে নিন', 'Choose Simple or Informative Home'),
                () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const HomeModeSettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            t(lang, 'অ্যাপের চেহারা', 'Appearance'),
            Icons.palette_outlined,
            [
              _choiceTile(
                context,
                Icons.palette_outlined,
                t(lang, 'থিম', 'Theme'),
                _themeLabel(s),
                const ['system', 'light', 'dark', 'amoled'],
                s.isAmoledMode ? 'amoled' : s.themeMode.name,
                (v) async {
                  switch (v) {
                    case 'system':
                      await s.setSystemTheme();
                    case 'light':
                      await s.setLightTheme();
                    case 'dark':
                      await s.setDarkTheme();
                    case 'amoled':
                      await s.setAmoledTheme();
                  }
                },
              ),
              _divider(),
              _choiceTile(
                context,
                Icons.language_rounded,
                t(lang, 'ভাষা', 'Language'),
                lang == 'en'
                    ? 'English'
                    : lang == 'ar'
                        ? 'العربية'
                        : 'বাংলা',
                const ['bn', 'en', 'ar'],
                lang,
                s.setLanguage,
              ),
              _divider(),
              _tile(
                context,
                Icons.text_fields_rounded,
                t(lang, 'অ্যাপের লেখা', 'App Text Size'),
                _textSizeLabel(scale.level, lang),
                () => _textSizeSheet(context, scale, lang),
              ),
              _divider(),
              _choiceTile(
                context,
                Icons.access_time_rounded,
                t(lang, 'সময় ফরম্যাট', 'Time Format'),
                s.is24Hour
                    ? t(lang, '২৪ ঘণ্টা', '24-hour')
                    : t(lang, '১২ ঘণ্টা', '12-hour'),
                const ['12', '24'],
                s.timeFormat,
                s.setTimeFormat,
              ),
              _divider(),
              _switchTile(
                context,
                Icons.timer_outlined,
                t(lang, 'সেকেন্ড দেখান', 'Show Seconds'),
                t(
                  lang,
                  'যেখানে সমর্থিত সেখানে সেকেন্ড দেখাবে',
                  'Show seconds where supported',
                ),
                s.showSeconds,
                s.toggleShowSeconds,
              ),
              _divider(),
              _switchTile(
                context,
                Icons.vibration_rounded,
                t(lang, 'ভাইব্রেশন', 'Vibration'),
                t(
                  lang,
                  'সমর্থিত অ্যাকশনে হ্যাপটিক ফিডব্যাক চালু রাখুন',
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
            t(lang, 'সালাত ও আজান', 'Prayer & Adhan'),
            Icons.mosque_outlined,
            [
              _choiceTile(
                context,
                Icons.calculate_outlined,
                t(lang, 'সালাতের হিসাব পদ্ধতি', 'Prayer Calculation'),
                _choiceLabel(s.calculationMethod, lang),
                SettingsProvider.calculationMethods,
                s.calculationMethod,
                s.setCalculationMethod,
              ),
              _divider(),
              _choiceTile(
                context,
                Icons.mosque_outlined,
                t(lang, 'মাযহাব', 'Madhhab'),
                _choiceLabel(s.madhhab, lang),
                SettingsProvider.madhabs,
                s.madhhab,
                s.setMadhhab,
              ),
              _divider(),
              _choiceTile(
                context,
                Icons.location_on_outlined,
                t(lang, 'লোকেশন', 'Location'),
                s.autoLocation
                    ? t(lang, 'স্বয়ংক্রিয়', 'Automatic')
                    : t(lang, 'ম্যানুয়াল', 'Manual'),
                const ['automatic', 'manual'],
                s.locationMode,
                s.setLocationMode,
              ),
              _divider(),
              _switchTile(
                context,
                Icons.notifications_active_outlined,
                t(lang, 'আজান নোটিফিকেশন', 'Adhan Notifications'),
                t(
                  lang,
                  'সালাতের সময়ের নোটিফিকেশন চালু রাখুন',
                  'Enable prayer-time notifications',
                ),
                s.isAdhanNotificationEnabled,
                s.toggleAdhanNotification,
              ),
              _divider(),
              _choiceTile(
                context,
                Icons.volume_up_outlined,
                t(lang, 'আজানের শব্দ', 'Adhan Sound'),
                _choiceLabel(s.notificationSound, lang),
                const ['Default', 'Silent'],
                s.notificationSound,
                s.setNotificationSound,
              ),
              _divider(),
              _choiceTile(
                context,
                Icons.alarm_outlined,
                t(lang, 'সালাতের আগে স্মরণ', 'Prayer Reminder'),
                _reminderLabel(s.prayerReminderMinutes, lang),
                const ['0', '5', '10', '15', '20', '30'],
                s.prayerReminderMinutes.toString(),
                (v) => s.setPrayerReminderMinutes(int.parse(v)),
              ),
              _divider(),
              _tile(
                context,
                Icons.tune_rounded,
                t(lang, 'সালাতের সময় সমন্বয়', 'Prayer Adjustments'),
                _adjustmentLabel(s, lang),
                () => _adjustments(context, s, lang),
              ),
              _divider(),
              _choiceTile(
                context,
                Icons.calendar_today_outlined,
                t(lang, 'হিজরি তারিখ সমন্বয়', 'Hijri Date Adjustment'),
                _hijriLabel(s, lang),
                List<String>.generate(7, (i) => '${i - 3}'),
                s.hijriAdjustment.toString(),
                (v) => s.setHijriAdjustment(int.parse(v)),
              ),
              _divider(),
              _tile(
                context,
                Icons.groups_rounded,
                t(lang, 'জামাতের সময়', 'Jamaat Times'),
                t(
                  lang,
                  'প্রতিটি ওয়াক্তের স্থানীয় জামাতের সময় সেট করুন',
                  'Set local Jamaat times for each prayer',
                ),
                () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const JamaatSettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            t(lang, 'কুরআন', 'Quran'),
            Icons.menu_book_outlined,
            [
              _tile(
                context,
                Icons.format_size_rounded,
                t(lang, 'কুরআন পড়ার সেটিংস', 'Quran Reading'),
                '${s.quranFontSize.round()} / ${s.translationFontSize.round()}',
                () => _quranSheet(context, s, lang),
              ),
              _divider(),
              _choiceTile(
                context,
                Icons.translate_rounded,
                t(lang, 'অনুবাদ', 'Translation'),
                _choiceLabel(s.quranTranslation, lang),
                const ['Bangla', 'English'],
                s.quranTranslation,
                s.setQuranTranslation,
              ),
              _divider(),
              _choiceTile(
                context,
                Icons.font_download_outlined,
                t(lang, 'আরবি ফন্ট', 'Arabic Font'),
                _choiceLabel(s.quranArabicFont, lang),
                const ['Default', 'Amiri', 'Scheherazade'],
                s.quranArabicFont,
                s.setQuranArabicFont,
              ),
              _divider(),
              _switchTile(
                context,
                Icons.skip_next_rounded,
                t(lang, 'পরবর্তী আয়াত স্বয়ংক্রিয়ভাবে চালু', 'Auto-play next'),
                t(
                  lang,
                  'পরের সমর্থিত অডিও স্বয়ংক্রিয়ভাবে চালাবে',
                  'Continue with the next supported audio item',
                ),
                s.autoPlayNext,
                s.toggleAutoPlayNext,
              ),
              _divider(),
              _switchTile(
                context,
                Icons.wifi_outlined,
                t(lang, 'শুধু Wi-Fi দিয়ে ডাউনলোড', 'Wi-Fi only downloads'),
                t(
                  lang,
                  'ডাউনলোডযোগ্য কুরআন রিসোর্সে Wi-Fi অগ্রাধিকার দিন',
                  'Prefer Wi-Fi for downloadable Quran resources',
                ),
                s.downloadWifiOnly,
                s.toggleDownloadWifiOnly,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            t(lang, 'ইবাদত ও তারিখ', 'Worship & Dates'),
            Icons.event_available_outlined,
            [
              _tile(
                context,
                Icons.today_outlined,
                t(lang, 'দৈনিক কনটেন্ট', 'Daily Content'),
                t(lang, 'আয়াত, হাদিস ও দোয়ার দৃশ্যমানতা', 'Ayah, Hadith and Dua visibility'),
                () => _dailySheet(context, s, lang),
              ),
              _divider(),
              _choiceTile(
                context,
                Icons.calendar_month_outlined,
                t(lang, 'তারিখের পছন্দ', 'Date Preferences'),
                _dateLabel(s, lang),
                const ['hijri', 'gregorian', 'both'],
                s.dateDisplayPreference,
                s.setDateDisplayPreference,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            t(lang, 'ডেটা ও অ্যাপ', 'Data & App'),
            Icons.settings_applications_outlined,
            [
              _tile(
                context,
                Icons.restart_alt_rounded,
                t(lang, 'সব সেটিংস রিসেট', 'Reset Settings'),
                t(
                  lang,
                  'সব কনফিগারযোগ্য সেটিংস ডিফল্টে ফিরিয়ে দিন',
                  'Restore configurable preferences',
                ),
                () => _reset(context, s, lang),
              ),
              _divider(),
              _tile(
                context,
                Icons.info_outline_rounded,
                t(lang, 'NurVerse সম্পর্কে', 'About NurVerse'),
                'Version 1.0.0',
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
                t(lang, 'ওপেন সোর্স লাইসেন্স', 'Open Source Licenses'),
                t(lang, 'NurVerse-এ ব্যবহৃত লাইব্রেরি', 'Libraries used by NurVerse'),
                () => showLicensePage(
                  context: context,
                  applicationName: 'NurVerse',
                  applicationVersion: '1.0.0',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _premiumCard(BuildContext context, PremiumProvider p, String lang) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.seaBlue,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NurVerse Premium',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p.isPremium
                        ? t(lang, 'প্রিমিয়াম সক্রিয়', 'Premium Active')
                        : t(lang, 'প্রিমিয়াম সুবিধা দেখুন', 'Explore Premium'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (!p.isPremium)
              TextButton(
                onPressed: p.activatePremium,
                child: Text(t(lang, 'দেখুন', 'Explore')),
              ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
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
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: .72),
                ),
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
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.seaBlue.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 21, color: AppColors.seaBlue),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: .62),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choiceTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    List<String> options,
    String selected,
    Future<void> Function(String) onChanged,
  ) {
    return _tile(
      context,
      icon,
      title,
      subtitle,
      () => _choiceSheet(context, title, options, onChanged, selected),
    );
  }

  Widget _switchTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.seaBlue.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 21, color: AppColors.seaBlue),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 70);

  String _themeLabel(SettingsProvider s) {
    if (s.isAmoledMode) {
      return t(s.languageCode, 'অ্যামোলেড কালো', 'AMOLED Black');
    }
    switch (s.themeMode) {
      case ThemeMode.light:
        return t(s.languageCode, 'লাইট মোড', 'Light Mode');
      case ThemeMode.dark:
        return t(s.languageCode, 'ডার্ক মোড', 'Dark Mode');
      case ThemeMode.system:
        return t(s.languageCode, 'সিস্টেম অনুযায়ী', 'System Default');
    }
  }

  String _textSizeLabel(int n, String lang) {
    final labels = [
      t(lang, 'ছোট', 'Small'),
      t(lang, 'স্বাভাবিক', 'Normal'),
      t(lang, 'বড়', 'Large'),
      t(lang, 'খুব বড়', 'Very Large'),
    ];
    return labels[n.clamp(0, 3)];
  }

  String _choiceLabel(String value, String lang) {
    const bn = {
      'Karachi': 'করাচি',
      'Muslim World League': 'মুসলিম ওয়ার্ল্ড লীগ',
      'Egyptian': 'মিশরীয়',
      'Umm Al Qura': 'উম্মুল কুরা',
      'Dubai': 'দুবাই',
      'Qatar': 'কাতার',
      'Kuwait': 'কুয়েত',
      'Singapore': 'সিঙ্গাপুর',
      'North America': 'উত্তর আমেরিকা',
      'Moonsighting Committee': 'চাঁদ দেখা কমিটি',
      'Hanafi': 'হানাফি',
      'Shafi': 'শাফেয়ী',
      'Maliki': 'মালিকি',
      'Hanbali': 'হাম্বলি',
      'Bangla': 'বাংলা',
      'English': 'ইংরেজি',
      'Default': 'ডিফল্ট',
      'Adhan': 'আজান',
      'Silent': 'নীরব',
      'Amiri': 'আমিরি',
      'Scheherazade': 'শেহেরাজাদে',
    };
    return lang == 'en' ? value : bn[value] ?? value;
  }

  String _reminderLabel(int minutes, String lang) {
    return minutes <= 0
        ? t(lang, 'সময় হলে', 'At prayer time')
        : '$minutes ${t(lang, 'মিনিট আগে', 'min before')}';
  }

  String _hijriLabel(SettingsProvider s, String lang) {
    if (s.hijriAdjustment == 0) {
      return t(lang, 'কোনো সমন্বয় নেই', 'No adjustment');
    }
    if (s.hijriAdjustment == 1) {
      return t(lang, 'ঢাকা ডিফল্ট (+1 দিন)', 'Dhaka Default (+1 day)');
    }
    return '${s.hijriAdjustment > 0 ? '+' : ''}${s.hijriAdjustment} ${t(lang, 'দিন', 'day')}';
  }

  String _adjustmentLabel(SettingsProvider s, String lang) {
    final entries = s.prayerAdjustments.entries
        .where((entry) => entry.value != 0)
        .toList();
    if (entries.isEmpty) {
      return t(lang, 'কোনো সমন্বয় নেই', 'No adjustments');
    }
    return entries
        .map((entry) => '${entry.key}: ${entry.value > 0 ? '+' : ''}${entry.value}m')
        .join(', ');
  }

  String _dateLabel(SettingsProvider s, String lang) {
    if (s.dateDisplayPreference == 'hijri') {
      return t(lang, 'শুধু হিজরি', 'Hijri only');
    }
    if (s.dateDisplayPreference == 'gregorian') {
      return t(lang, 'শুধু গ্রেগরিয়ান', 'Gregorian only');
    }
    return t(lang, 'উভয় তারিখ', 'Both dates');
  }

  Future<void> _choiceSheet(
    BuildContext context,
    String title,
    List<String> options,
    Future<void> Function(String) onChanged,
    String selected,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final sheetLang = Localizations.localeOf(sheetContext).languageCode;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: options
                .map(
                  (value) => ListTile(
                    title: Text(_choiceLabel(value, sheetLang)),
                    trailing: value == selected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.seaBlue,
                          )
                        : null,
                    onTap: () async {
                      await onChanged(value);
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Future<void> _textSizeSheet(
    BuildContext context,
    TextScaleProvider provider,
    String lang,
  ) async {
    final labels = [
      t(lang, 'ছোট', 'Small'),
      t(lang, 'স্বাভাবিক', 'Normal'),
      t(lang, 'বড়', 'Large'),
      t(lang, 'খুব বড়', 'Very Large'),
    ];

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < labels.length; i++)
              ListTile(
                title: Text(labels[i]),
                trailing: i == provider.level
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.seaBlue,
                      )
                    : null,
                onTap: () async {
                  await provider.setLevel(i);
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _quranSheet(
    BuildContext context,
    SettingsProvider s,
    String lang,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t(lang, 'কুরআন পড়ার সেটিংস', 'Quran Reading'),
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              Text('Arabic: ${s.quranFontSize.round()}'),
              Slider(
                value: s.quranFontSize.clamp(14.0, 50.0).toDouble(),
                min: 14,
                max: 50,
                divisions: 36,
                onChanged: s.updateQuranFontSize,
              ),
              Text('Translation: ${s.translationFontSize.round()}'),
              Slider(
                value: s.translationFontSize.clamp(10.0, 30.0).toDouble(),
                min: 10,
                max: 30,
                divisions: 20,
                onChanged: s.updateTranslationFontSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _adjustments(
    BuildContext context,
    SettingsProvider s,
    String lang,
  ) async {
    const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: StatefulBuilder(
          builder: (builderContext, setState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    t(lang, 'সালাতের সময় সমন্বয়', 'Prayer Adjustments'),
                    style: Theme.of(builderContext)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  for (final prayer in prayers) ...[
                    Row(
                      children: [
                        Expanded(child: Text(prayer)),
                        Text('${s.prayerAdjustments[prayer] ?? 0} min'),
                      ],
                    ),
                    Slider(
                      min: -60,
                      max: 60,
                      divisions: 120,
                      value: (s.prayerAdjustments[prayer] ?? 0).toDouble(),
                      onChanged: (value) async {
                        await s.setPrayerAdjustment(prayer, value.round());
                        setState(() {});
                      },
                    ),
                  ],
                  TextButton(
                    onPressed: () async {
                      await s.resetPrayerAdjustments();
                      setState(() {});
                    },
                    child: Text(t(lang, 'সব সমন্বয় রিসেট', 'Reset all')),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _dailySheet(
    BuildContext context,
    SettingsProvider s,
    String lang,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _switchTile(
              sheetContext,
              Icons.menu_book_outlined,
              t(lang, 'দৈনিক আয়াত', 'Daily Ayah'),
              '',
              s.showDailyAyah,
              (value) => s.setDailyContentPreferences(ayah: value),
            ),
            _switchTile(
              sheetContext,
              Icons.auto_stories_outlined,
              t(lang, 'দৈনিক হাদিস', 'Daily Hadith'),
              '',
              s.showDailyHadith,
              (value) => s.setDailyContentPreferences(hadith: value),
            ),
            _switchTile(
              sheetContext,
              Icons.volunteer_activism_outlined,
              t(lang, 'দৈনিক দোয়া', 'Daily Dua'),
              '',
              s.showDailyDua,
              (value) => s.setDailyContentPreferences(dua: value),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reset(
    BuildContext context,
    SettingsProvider s,
    String lang,
  ) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t(lang, 'সেটিংস রিসেট করবেন?', 'Reset settings?')),
        content: Text(
          t(
            lang,
            'সব সংরক্ষিত সেটিংস ডিফল্টে ফিরে যাবে।',
            'All saved preferences will return to their defaults.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t(lang, 'বাতিল', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t(lang, 'রিসেট', 'Reset')),
          ),
        ],
      ),
    );

    if (yes == true) {
      await s.resetSettings();
    }
  }
}
