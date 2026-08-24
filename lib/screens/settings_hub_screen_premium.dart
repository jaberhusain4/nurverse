import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/premium_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/text_scale_provider.dart';
import '../theme/app_theme.dart';
import 'auth/google_login_screen.dart';
import 'home_mode_settings_screen.dart';

class SettingsHubScreenPremium extends StatelessWidget {
  const SettingsHubScreenPremium({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final textScale = context.watch<TextScaleProvider>();
    final premium = context.watch<PremiumProvider>();
    final english = settings.isEnglish;

    return Scaffold(
      appBar: AppBar(title: Text(english ? 'Settings' : 'সেটিংস')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _section(
            context,
            english ? 'Personalization' : 'ব্যক্তিগতকরণ',
            Icons.tune_rounded,
            [
              _tile(
                context,
                Icons.dashboard_customize_outlined,
                english ? 'Home Screen' : 'হোম স্ক্রিন',
                english ? 'Choose Simple or Informative Home' : 'Simple বা Informative Home বেছে নিন',
                () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HomeModeSettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _premiumHero(context, premium, english),
          const SizedBox(height: 20),
          _section(
            context,
            english ? 'Appearance' : 'অ্যাপের চেহারা',
            Icons.palette_outlined,
            [
              _tile(
                context,
                Icons.palette_outlined,
                english ? 'Theme' : 'থিম',
                _themeLabel(settings),
                () => _choiceSheet(
                  context,
                  english ? 'Theme' : 'থিম',
                  const ['system', 'light', 'dark', 'amoled'],
                  (value) async {
                    switch (value) {
                      case 'system':
                        await settings.setSystemTheme();
                        break;
                      case 'light':
                        await settings.setLightTheme();
                        break;
                      case 'dark':
                        await settings.setDarkTheme();
                        break;
                      case 'amoled':
                        await settings.setAmoledTheme();
                        break;
                    }
                  },
                ),
              ),
              _divider(),
              _tile(
                context,
                Icons.language_rounded,
                english ? 'Language' : 'ভাষা',
                english ? 'English' : 'বাংলা',
                () => _choiceSheet(
                  context,
                  english ? 'Language' : 'ভাষা',
                  const ['bn', 'en'],
                  settings.setLanguage,
                ),
              ),
              _divider(),
              _tile(
                context,
                Icons.text_fields_rounded,
                english ? 'App Text Size' : 'অ্যাপের লেখা',
                _textSizeLabel(textScale.level, english),
                () => _textSizeSheet(context, textScale, english),
              ),
              _divider(),
              _switchTile(
                context,
                Icons.timer_outlined,
                english ? 'Show seconds' : 'সেকেন্ড দেখান',
                english ? 'Show seconds where supported' : 'যেখানে সমর্থিত সেখানে সেকেন্ড দেখাবে',
                settings.showSeconds,
                settings.toggleShowSeconds,
              ),
              _divider(),
              _switchTile(
                context,
                Icons.vibration_rounded,
                english ? 'Vibration' : 'ভাইব্রেশন',
                english ? 'Allow supported haptic feedback' : 'সমর্থিত action-এ haptic feedback',
                settings.vibrationEnabled,
                settings.toggleVibration,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            english ? 'Prayer & Adhan' : 'সালাত ও আজান',
            Icons.mosque_outlined,
            [
              _tile(
                context,
                Icons.calculate_outlined,
                english ? 'Prayer Calculation' : 'সালাতের হিসাব পদ্ধতি',
                settings.calculationMethod,
                () => _choiceSheet(
                  context,
                  english ? 'Prayer Calculation' : 'সালাতের হিসাব পদ্ধতি',
                  SettingsProvider.calculationMethods,
                  settings.setCalculationMethod,
                ),
              ),
              _divider(),
              _tile(
                context,
                Icons.mosque_outlined,
                english ? 'Madhhab' : 'মাযহাব',
                settings.madhhab,
                () => _choiceSheet(
                  context,
                  english ? 'Madhhab' : 'মাযহাব',
                  SettingsProvider.madhabs,
                  settings.setMadhhab,
                ),
              ),
              _divider(),
              _switchTile(
                context,
                Icons.notifications_active_outlined,
                english ? 'Adhan Notifications' : 'আজান নোটিফিকেশন',
                english ? 'Enable prayer-time notifications' : 'সালাতের সময়ের নোটিফিকেশন চালু রাখুন',
                settings.isAdhanNotificationEnabled,
                settings.toggleAdhanNotification,
              ),
              _divider(),
              _tile(
                context,
                Icons.tune_rounded,
                english ? 'Prayer Adjustments' : 'সালাতের সময় সমন্বয়',
                _adjustmentLabel(settings, english),
                () => _adjustmentDialog(context, settings),
              ),
              _divider(),
              _tile(
                context,
                Icons.access_time_rounded,
                english ? 'Jamaat Times' : 'জামাতের সময়',
                english ? 'Set local Jamaat times' : 'নিজের এলাকার জামাতের সময় সেট করুন',
                () => _jamaatDialog(context, settings),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            english ? 'Quran' : 'কুরআন',
            Icons.menu_book_outlined,
            [
              _tile(
                context,
                Icons.format_size_rounded,
                english ? 'Quran Reading' : 'কুরআন পড়ার সেটিংস',
                '${settings.quranFontSize.round()} / ${settings.translationFontSize.round()}',
                () => _quranSheet(context, settings),
              ),
              _divider(),
              _tile(
                context,
                Icons.translate_rounded,
                english ? 'Translation' : 'অনুবাদ',
                settings.quranTranslation,
                () => _choiceSheet(
                  context,
                  english ? 'Translation' : 'অনুবাদ',
                  const ['Bangla', 'English'],
                  settings.setQuranTranslation,
                ),
              ),
              _divider(),
              _tile(
                context,
                Icons.font_download_outlined,
                english ? 'Arabic Font' : 'আরবি ফন্ট',
                settings.quranArabicFont,
                () => _choiceSheet(
                  context,
                  english ? 'Arabic Font' : 'আরবি ফন্ট',
                  const ['Default', 'Amiri', 'Scheherazade'],
                  settings.setQuranArabicFont,
                ),
              ),
              _divider(),
              _switchTile(
                context,
                Icons.skip_next_rounded,
                english ? 'Auto-play next' : 'পরেরটি স্বয়ংক্রিয় চালান',
                english ? 'Continue with the next supported audio item' : 'সমর্থিত অডিওতে পরেরটি স্বয়ংক্রিয়ভাবে চালাবে',
                settings.autoPlayNext,
                settings.toggleAutoPlayNext,
              ),
              _divider(),
              _switchTile(
                context,
                Icons.wifi_outlined,
                english ? 'Wi-Fi only downloads' : 'শুধু Wi-Fi ডাউনলোড',
                english ? 'Prefer Wi-Fi for downloadable Quran resources' : 'ডাউনলোডযোগ্য কুরআন রিসোর্সে Wi-Fi অগ্রাধিকার দিন',
                settings.downloadWifiOnly,
                settings.toggleDownloadWifiOnly,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            english ? 'Worship & Dates' : 'ইবাদত ও তারিখ',
            Icons.event_available_outlined,
            [
              _tile(
                context,
                Icons.today_outlined,
                english ? 'Daily Content' : 'দৈনিক কনটেন্ট',
                english ? 'Ayah, Hadith and Dua visibility' : 'আয়াত, হাদিস ও দোয়ার দৃশ্যমানতা',
                () => _dailySheet(context),
              ),
              _divider(),
              _tile(
                context,
                Icons.calendar_month_outlined,
                english ? 'Date Preferences' : 'তারিখের পছন্দ',
                _dateLabel(settings, english),
                () => _choiceSheet(
                  context,
                  english ? 'Date Preferences' : 'তারিখের পছন্দ',
                  const ['hijri', 'gregorian', 'both'],
                  settings.setDateDisplayPreference,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            english ? 'Data & App' : 'ডেটা ও অ্যাপ',
            Icons.settings_applications_outlined,
            [
              _tile(
                context,
                Icons.restart_alt_rounded,
                english ? 'Reset Settings' : 'সেটিংস রিসেট',
                english ? 'Restore configurable preferences' : 'সব configurable preference ডিফল্টে ফিরিয়ে দিন',
                () => _resetDialog(context, settings),
              ),
              _divider(),
              _tile(
                context,
                Icons.info_outline_rounded,
                english ? 'About NurVerse' : 'NurVerse সম্পর্কে',
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
                english ? 'Open Source Licenses' : 'ওপেন সোর্স লাইসেন্স',
                english ? 'Libraries used by NurVerse' : 'NurVerse-এ ব্যবহৃত লাইব্রেরি',
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

  Widget _premiumHero(BuildContext context, PremiumProvider premium, bool english) {
    final user = FirebaseAuth.instance.currentUser;
    final active = premium.isPremium;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
                  active ? Icons.verified_rounded : Icons.workspace_premium_rounded,
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
                        Expanded(
                          child: Text(
                            'NurVerse Premium',
                            style: const TextStyle(
                              color: AppColors.seaBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (active)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.seaBlue.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              english ? 'ACTIVE' : 'সক্রিয়',
                              style: const TextStyle(
                                color: AppColors.seaBlue,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      active
                          ? (english ? 'Your premium experience is active' : 'আপনার Premium অভিজ্ঞতা সক্রিয়')
                          : (english ? 'Unlock a richer, calmer NurVerse' : 'আরও সমৃদ্ধ ও সুন্দর NurVerse উপভোগ করুন'),
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: .70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const GoogleLoginScreen()),
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.seaBlue.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.seaBlue.withValues(alpha: .12)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'G',
                      style: TextStyle(
                        color: AppColors.seaBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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
              _premiumChip(Icons.contrast_rounded, 'AMOLED'),
              _premiumChip(Icons.palette_outlined, english ? 'Premium Themes' : 'Premium থিম'),
              _premiumChip(Icons.headphones_outlined, english ? 'Recitations' : 'তেলাওয়াত'),
              _premiumChip(Icons.cloud_outlined, english ? 'Cloud Sync' : 'ক্লাউড সিঙ্ক'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                if (premium.isPremium) {
                  await showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('NurVerse Premium'),
                      content: Text(english ? 'Premium is active.' : 'Premium সক্রিয় আছে।'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(english ? 'Done' : 'ঠিক আছে'),
                        ),
                      ],
                    ),
                  );
                } else {
                  await premium.activatePremium();
                }
              },
              icon: Icon(active ? Icons.settings_rounded : Icons.auto_awesome_rounded, size: 18),
              label: Text(active ? (english ? 'Manage Premium' : 'Premium পরিচালনা করুন') : (english ? 'Explore Premium' : 'Premium দেখুন')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumChip(IconData icon, String title) {
    return Container(
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
  }

  Widget _section(BuildContext context, String title, IconData icon, List<Widget> children) {
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
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: .72),
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

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
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
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.35,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: .62),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Theme.of(context).iconTheme.color?.withValues(alpha: .38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchTile(BuildContext context, IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
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
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(fontSize: 10.5, height: 1.35, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: .62))),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 70);

  String _themeLabel(SettingsProvider settings) {
    if (settings.isAmoledMode) return 'AMOLED Black';
    switch (settings.themeMode) {
      case ThemeMode.light:
        return settings.isEnglish ? 'Light Mode' : 'লাইট মোড';
      case ThemeMode.dark:
        return settings.isEnglish ? 'Dark Mode' : 'ডার্ক মোড';
      case ThemeMode.system:
        return settings.isEnglish ? 'System Default' : 'সিস্টেম অনুযায়ী';
    }
  }

  String _textSizeLabel(int level, bool english) {
    switch (level) {
      case 0:
        return english ? 'Small' : 'ছোট';
      case 2:
        return english ? 'Large' : 'বড়';
      case 3:
        return english ? 'Very Large' : 'খুব বড়';
      default:
        return english ? 'Normal' : 'স্বাভাবিক';
    }
  }

  String _adjustmentLabel(SettingsProvider settings, bool english) {
    final active = settings.prayerAdjustments.entries.where((entry) => entry.value != 0).toList();
    if (active.isEmpty) return english ? 'No adjustments' : 'কোনো সমন্বয় নেই';
    final entry = active.first;
    final sign = entry.value > 0 ? '+' : '';
    return '${entry.key}: $sign${entry.value} min';
  }

  String _dateLabel(SettingsProvider settings, bool english) {
    switch (settings.dateDisplayPreference) {
      case 'hijri':
        return english ? 'Hijri only' : 'শুধু হিজরি';
      case 'gregorian':
        return english ? 'Gregorian only' : 'শুধু ইংরেজি';
      default:
        return english ? 'Both dates' : 'উভয় তারিখ';
    }
  }

  Future<void> _choiceSheet(BuildContext context, String title, List<String> options, Future<void> Function(String) onSelected) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              ...options.map((option) => ListTile(
                    title: Text(option),
                    onTap: () async {
                      await onSelected(option);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _textSizeSheet(BuildContext context, TextScaleProvider provider, bool english) async {
    final labels = english ? const ['Small', 'Normal', 'Large', 'Very Large'] : const ['ছোট', 'স্বাভাবিক', 'বড়', 'খুব বড়'];
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(english ? 'App Text Size' : 'অ্যাপের লেখা', style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            ),
            for (int index = 0; index < labels.length; index++)
              ListTile(
                title: Text(labels[index]),
                trailing: index == provider.level ? const Icon(Icons.check_circle_rounded, color: AppColors.seaBlue) : null,
                onTap: () async {
                  await provider.setLevel(index);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _adjustmentDialog(BuildContext context, SettingsProvider settings) async {
    const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(settings.isEnglish ? 'Prayer Adjustments' : 'সালাতের সময় সমন্বয়'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              for (final prayer in prayers)
                ListTile(
                  title: Text(prayer),
                  subtitle: Text('${settings.prayerAdjustments[prayer] ?? 0} min'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(onPressed: () => settings.setPrayerAdjustment(prayer, (settings.prayerAdjustments[prayer] ?? 0) - 1), icon: const Icon(Icons.remove_circle_outline)),
                      IconButton(onPressed: () => settings.setPrayerAdjustment(prayer, (settings.prayerAdjustments[prayer] ?? 0) + 1), icon: const Icon(Icons.add_circle_outline)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(settings.isEnglish ? 'Done' : 'সম্পন্ন'))],
      ),
    );
  }

  Future<void> _jamaatDialog(BuildContext context, SettingsProvider settings) async {
    const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final controllers = <String, TextEditingController>{
      for (final prayer in prayers) prayer: TextEditingController(text: settings.getJamaat(prayer)),
    };
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(settings.isEnglish ? 'Jamaat Times' : 'জামাতের সময়'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                for (final prayer in prayers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: controllers[prayer],
                      decoration: InputDecoration(labelText: prayer),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(settings.isEnglish ? 'Cancel' : 'বাতিল')),
            FilledButton(
              onPressed: () async {
                for (final prayer in prayers) {
                  await settings.setJamaatTime(prayer, controllers[prayer]!.text);
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text(settings.isEnglish ? 'Save' : 'সংরক্ষণ'),
            ),
          ],
        ),
      );
    } finally {
      for (final controller in controllers.values) controller.dispose();
    }
  }

  Future<void> _quranSheet(BuildContext context, SettingsProvider settings) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _slider(sheetContext, settings.isEnglish ? 'Quran Arabic' : 'কুরআন আরবি', settings.quranFontSize, 14, 50, settings.updateQuranFontSize),
              const SizedBox(height: 14),
              _slider(sheetContext, settings.isEnglish ? 'Translation' : 'অনুবাদ', settings.translationFontSize, 10, 30, settings.updateTranslationFontSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slider(BuildContext context, String title, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))), Text(value.round().toString(), style: const TextStyle(color: AppColors.seaBlue, fontWeight: FontWeight.w900))]),
        Slider(value: value.clamp(min, max), min: min, max: max, divisions: (max - min).round(), onChanged: onChanged),
      ],
    );
  }

  Future<void> _dailySheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Consumer<SettingsProvider>(
          builder: (context, current, _) => Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _switchTile(context, Icons.menu_book_outlined, current.isEnglish ? 'Daily Ayah' : 'দৈনিক আয়াত', '', current.showDailyAyah, (value) => current.setDailyContentPreferences(ayah: value)),
                _switchTile(context, Icons.auto_stories_outlined, current.isEnglish ? 'Daily Hadith' : 'দৈনিক হাদিস', '', current.showDailyHadith, (value) => current.setDailyContentPreferences(hadith: value)),
                _switchTile(context, Icons.volunteer_activism_outlined, current.isEnglish ? 'Daily Dua' : 'দৈনিক দোয়া', '', current.showDailyDua, (value) => current.setDailyContentPreferences(dua: value)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resetDialog(BuildContext context, SettingsProvider settings) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(settings.isEnglish ? 'Reset settings?' : 'সেটিংস রিসেট করবেন?'),
        content: Text(settings.isEnglish ? 'All saved preferences will return to their default values.' : 'সব সংরক্ষিত preference ডিফল্ট অবস্থায় ফিরে যাবে।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(settings.isEnglish ? 'Cancel' : 'বাতিল')),
          FilledButton(onPressed: () async { await settings.resetSettings(); if (dialogContext.mounted) Navigator.pop(dialogContext); }, child: Text(settings.isEnglish ? 'Reset' : 'রিসেট')),
        ],
      ),
    );
  }
}
