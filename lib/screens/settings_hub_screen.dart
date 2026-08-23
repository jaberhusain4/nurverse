import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'home_mode_settings_screen.dart';

class SettingsHubScreen extends StatelessWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isEnglish = settings.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Settings' : 'সেটিংস',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _section(
            context,
            isEnglish ? 'Personalization' : 'ব্যক্তিগতকরণ',
            Icons.tune_rounded,
            [
              _tile(
                context,
                Icons.dashboard_customize_outlined,
                isEnglish ? 'Home Screen' : 'হোম স্ক্রিন',
                isEnglish
                    ? 'Choose Simple or Informative Home'
                    : 'Simple বা Informative Home বেছে নিন',
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const HomeModeSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            isEnglish ? 'Appearance' : 'অ্যাপের চেহারা',
            Icons.palette_outlined,
            [
              _tile(
                context,
                Icons.palette_outlined,
                isEnglish ? 'Theme' : 'থিম',
                _themeLabel(settings),
                () => _themeSheet(context, settings),
              ),
              _divider(),
              _tile(
                context,
                Icons.language_rounded,
                isEnglish ? 'Language' : 'ভাষা',
                isEnglish ? 'English' : 'বাংলা',
                () => _languageSheet(context, settings),
              ),
              _divider(),
              _tile(
                context,
                Icons.text_fields_rounded,
                isEnglish ? 'Reading & Font' : 'পাঠ ও ফন্ট',
                isEnglish
                    ? 'Quran and translation text size'
                    : 'কুরআন ও অনুবাদের লেখার আকার',
                () => _readingSheet(context, settings),
              ),
              _divider(),
              _switchTile(
                context,
                Icons.timer_outlined,
                isEnglish ? 'Show seconds' : 'সেকেন্ড দেখান',
                isEnglish
                    ? 'Show seconds where a live clock supports it'
                    : 'যেখানে লাইভ ঘড়ি আছে সেখানে সেকেন্ড দেখাবে',
                settings.showSeconds,
                settings.toggleShowSeconds,
              ),
              _divider(),
              _switchTile(
                context,
                Icons.vibration_rounded,
                isEnglish ? 'Vibration' : 'ভাইব্রেশন',
                isEnglish
                    ? 'Allow haptic feedback for supported actions'
                    : 'সমর্থিত action-এ haptic feedback চালু রাখুন',
                settings.vibrationEnabled,
                settings.toggleVibration,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            isEnglish ? 'Prayer & Adhan' : 'সালাত ও আজান',
            Icons.mosque_outlined,
            [
              _tile(
                context,
                Icons.calculate_outlined,
                isEnglish ? 'Prayer Calculation' : 'সালাতের হিসাব পদ্ধতি',
                settings.calculationMethod,
                () => _selectionSheet(
                  context,
                  isEnglish ? 'Prayer Calculation' : 'সালাতের হিসাব পদ্ধতি',
                  SettingsProvider.calculationMethods,
                  settings.setCalculationMethod,
                ),
              ),
              _divider(),
              _tile(
                context,
                Icons.mosque_outlined,
                isEnglish ? 'Madhhab' : 'মাযহাব',
                settings.madhhab,
                () => _selectionSheet(
                  context,
                  isEnglish ? 'Madhhab' : 'মাযহাব',
                  SettingsProvider.madhabs,
                  settings.setMadhab,
                ),
              ),
              _divider(),
              _switchTile(
                context,
                Icons.notifications_active_outlined,
                isEnglish ? 'Adhan Notifications' : 'আজান নোটিফিকেশন',
                isEnglish
                    ? 'Enable prayer-time notification scheduling'
                    : 'সালাতের সময়ের নোটিফিকেশন চালু রাখুন',
                settings.isAdhanNotificationEnabled,
                settings.toggleAdhanNotification,
              ),
              _divider(),
              _tile(
                context,
                Icons.tune_rounded,
                isEnglish ? 'Prayer Adjustments' : 'সালাতের সময় সমন্বয়',
                _adjustmentLabel(settings, isEnglish),
                () => _adjustmentsDialog(context, settings),
              ),
              _divider(),
              _tile(
                context,
                Icons.access_time_rounded,
                isEnglish ? 'Jamaat Times' : 'জামাতের সময়',
                isEnglish
                    ? 'Set your local Jamaat times'
                    : 'নিজের এলাকার জামাতের সময় সেট করুন',
                () => _jamaatDialog(context, settings),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            isEnglish ? 'Quran' : 'কুরআন',
            Icons.menu_book_outlined,
            [
              _tile(
                context,
                Icons.format_size_rounded,
                isEnglish ? 'Quran Reading' : 'কুরআন পড়ার সেটিংস',
                '${settings.quranFontSize.round()} / ${settings.translationFontSize.round()}',
                () => _readingSheet(context, settings),
              ),
              _divider(),
              _tile(
                context,
                Icons.translate_rounded,
                isEnglish ? 'Translation' : 'অনুবাদ',
                settings.quranTranslation,
                () => _selectionSheet(
                  context,
                  isEnglish ? 'Translation' : 'অনুবাদ',
                  const ['Bangla', 'English'],
                  settings.setQuranTranslation,
                ),
              ),
              _divider(),
              _tile(
                context,
                Icons.font_download_outlined,
                isEnglish ? 'Arabic Font' : 'আরবি ফন্ট',
                settings.quranArabicFont,
                () => _selectionSheet(
                  context,
                  isEnglish ? 'Arabic Font' : 'আরবি ফন্ট',
                  const ['Default', 'Amiri', 'Scheherazade'],
                  settings.setQuranArabicFont,
                ),
              ),
              _divider(),
              _switchTile(
                context,
                Icons.skip_next_rounded,
                isEnglish ? 'Auto-play next' : 'পরেরটি স্বয়ংক্রিয় চালান',
                isEnglish
                    ? 'Continue with the next audio item when supported'
                    : 'সমর্থিত অডিওতে পরেরটি স্বয়ংক্রিয়ভাবে চালাবে',
                settings.autoPlayNext,
                settings.toggleAutoPlayNext,
              ),
              _divider(),
              _switchTile(
                context,
                Icons.wifi_outlined,
                isEnglish ? 'Wi-Fi only downloads' : 'শুধু Wi-Fi ডাউনলোড',
                isEnglish
                    ? 'Prefer Wi-Fi for downloadable Quran resources'
                    : 'ডাউনলোডযোগ্য কুরআন রিসোর্সে Wi-Fi অগ্রাধিকার দিন',
                settings.downloadWifiOnly,
                settings.toggleDownloadWifiOnly,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            isEnglish ? 'Worship & Dates' : 'ইবাদত ও তারিখ',
            Icons.event_available_outlined,
            [
              _tile(
                context,
                Icons.today_outlined,
                isEnglish ? 'Daily Content' : 'দৈনিক কনটেন্ট',
                isEnglish
                    ? 'Ayah, Hadith and Dua visibility'
                    : 'আয়াত, হাদিস ও দোয়ার দৃশ্যমানতা',
                () => _dailyContentSheet(context, settings),
              ),
              _divider(),
              _tile(
                context,
                Icons.calendar_month_outlined,
                isEnglish ? 'Date Preferences' : 'তারিখের পছন্দ',
                _dateLabel(settings, isEnglish),
                () => _dateSheet(context, settings),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            isEnglish ? 'Data & App' : 'ডেটা ও অ্যাপ',
            Icons.settings_applications_outlined,
            [
              _tile(
                context,
                Icons.restart_alt_rounded,
                isEnglish ? 'Reset Settings' : 'সেটিংস রিসেট',
                isEnglish
                    ? 'Restore all configurable preferences'
                    : 'সব configurable preference ডিফল্টে ফিরিয়ে দিন',
                () => _resetDialog(context, settings),
              ),
              _divider(),
              _tile(
                context,
                Icons.info_outline_rounded,
                isEnglish ? 'About NurVerse' : 'NurVerse সম্পর্কে',
                'Version 1.0.0',
                () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'NurVerse',
                    applicationVersion: '1.0.0',
                    children: [
                      Text(
                        isEnglish
                            ? 'A calm companion for everyday Islamic practice.'
                            : 'প্রতিদিনের ইসলামিক জীবনের শান্ত সঙ্গী।',
                      ),
                    ],
                  );
                },
              ),
              _divider(),
              _tile(
                context,
                Icons.code_rounded,
                isEnglish ? 'Open Source Licenses' : 'ওপেন সোর্স লাইসেন্স',
                isEnglish
                    ? 'Libraries used by NurVerse'
                    : 'NurVerse-এ ব্যবহৃত লাইব্রেরি',
                () {
                  showLicensePage(
                    context: context,
                    applicationName: 'NurVerse',
                    applicationVersion: '1.0.0',
                  );
                },
              ),
            ],
          ),
        ],
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
                        height: 1.35,
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
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Theme.of(context)
                    .iconTheme
                    .color
                    ?.withValues(alpha: .38),
              ),
            ],
          ),
        ),
      ),
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
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.35,
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
          const SizedBox(width: 8),
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

  String _adjustmentLabel(SettingsProvider settings, bool isEnglish) {
    final active = settings.prayerAdjustments.entries
        .where((entry) => entry.value != 0)
        .toList();

    if (active.isEmpty) {
      return isEnglish ? 'No adjustments' : 'কোনো সমন্বয় নেই';
    }

    final first = active.first;
    final sign = first.value > 0 ? '+' : '';
    return '${first.key}: $sign${first.value} min';
  }

  String _dateLabel(SettingsProvider settings, bool isEnglish) {
    switch (settings.dateDisplayPreference) {
      case 'hijri':
        return isEnglish ? 'Hijri only' : 'শুধু হিজরি';
      case 'gregorian':
        return isEnglish ? 'Gregorian only' : 'শুধু ইংরেজি';
      default:
        return isEnglish ? 'Both dates' : 'উভয় তারিখ';
    }
  }

  Future<void> _themeSheet(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _choiceList(
        sheetContext,
        settings.isEnglish ? 'Theme' : 'থিম',
        const ['system', 'light', 'dark', 'amoled'],
        (value) async {
          if (value == 'system') await settings.setSystemTheme();
          if (value == 'light') await settings.setLightTheme();
          if (value == 'dark') await settings.setDarkTheme();
          if (value == 'amoled') await settings.setAmoledTheme();
          if (sheetContext.mounted) Navigator.pop(sheetContext);
        },
      ),
    );
  }

  Future<void> _languageSheet(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _choiceList(
        sheetContext,
        settings.isEnglish ? 'Language' : 'ভাষা',
        const ['bn', 'en'],
        (value) async {
          await settings.setLanguage(value);
          if (sheetContext.mounted) Navigator.pop(sheetContext);
        },
      ),
    );
  }

  Future<void> _selectionSheet(
    BuildContext context,
    String title,
    List<String> options,
    ValueChanged<String> onSelected,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _choiceList(
        sheetContext,
        title,
        options,
        (value) async {
          onSelected(value);
          if (sheetContext.mounted) Navigator.pop(sheetContext);
        },
      ),
    );
  }

  Widget _choiceList(
    BuildContext context,
    String title,
    List<String> options,
    Future<void> Function(String) onTap,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...options.map(
              (option) => ListTile(
                title: Text(option),
                onTap: () => onTap(option),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _readingSheet(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                settings.isEnglish ? 'Reading & Font' : 'পাঠ ও ফন্ট',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),
              _slider(
                sheetContext,
                settings.isEnglish ? 'Quran Arabic' : 'কুরআন আরবি',
                settings.quranFontSize,
                14,
                50,
                settings.updateQuranFontSize,
              ),
              const SizedBox(height: 14),
              _slider(
                sheetContext,
                settings.isEnglish ? 'Translation' : 'অনুবাদ',
                settings.translationFontSize,
                10,
                30,
                settings.updateTranslationFontSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slider(
    BuildContext context,
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              value.round().toString(),
              style: const TextStyle(
                color: AppColors.seaBlue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _adjustmentsDialog(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final prayerKeys = const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          settings.isEnglish ? 'Prayer Adjustments' : 'সালাতের সময় সমন্বয়',
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              for (final prayer in prayerKeys)
                ListTile(
                  title: Text(prayer),
                  subtitle: Text('${settings.prayerAdjustments[prayer] ?? 0} min'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => settings.setPrayerAdjustment(
                          prayer,
                          (settings.prayerAdjustments[prayer] ?? 0) - 1,
                        ),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      IconButton(
                        onPressed: () => settings.setPrayerAdjustment(
                          prayer,
                          (settings.prayerAdjustments[prayer] ?? 0) + 1,
                        ),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(settings.isEnglish ? 'Done' : 'সম্পন্ন'),
          ),
        ],
      ),
    );
  }

  Future<void> _jamaatDialog(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final prayerKeys = const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final controllers = <String, TextEditingController>{
      for (final prayer in prayerKeys)
        prayer: TextEditingController(text: settings.getJamaat(prayer)),
    };

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(settings.isEnglish ? 'Jamaat Times' : 'জামাতের সময়'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              for (final prayer in prayerKeys)
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
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(settings.isEnglish ? 'Cancel' : 'বাতিল'),
          ),
          FilledButton(
            onPressed: () async {
              for (final prayer in prayerKeys) {
                await settings.setJamaatTime(
                  prayer,
                  controllers[prayer]!.text,
                );
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(settings.isEnglish ? 'Save' : 'সংরক্ষণ'),
          ),
        ],
      ),
    );

    for (final controller in controllers.values) {
      controller.dispose();
    }
  }

  Future<void> _dailyContentSheet(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Consumer<SettingsProvider>(
            builder: (context, current, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    current.isEnglish ? 'Daily Content' : 'দৈনিক কনটেন্ট',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  _switchTile(
                    context,
                    Icons.menu_book_outlined,
                    current.isEnglish ? 'Daily Ayah' : 'দৈনিক আয়াত',
                    '',
                    current.showDailyAyah,
                    (value) => current.setDailyContentPreferences(ayah: value),
                  ),
                  _switchTile(
                    context,
                    Icons.auto_stories_outlined,
                    current.isEnglish ? 'Daily Hadith' : 'দৈনিক হাদিস',
                    '',
                    current.showDailyHadith,
                    (value) => current.setDailyContentPreferences(hadith: value),
                  ),
                  _switchTile(
                    context,
                    Icons.volunteer_activism_outlined,
                    current.isEnglish ? 'Daily Dua' : 'দৈনিক দোয়া',
                    '',
                    current.showDailyDua,
                    (value) => current.setDailyContentPreferences(dua: value),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _dateSheet(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final isEnglish = settings.isEnglish;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _choiceList(
        sheetContext,
        isEnglish ? 'Date Preferences' : 'তারিখের পছন্দ',
        const ['hijri', 'gregorian', 'both'],
        (value) async {
          await settings.setDateDisplayPreference(value);
          if (sheetContext.mounted) Navigator.pop(sheetContext);
        },
      ),
    );
  }

  Future<void> _resetDialog(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          settings.isEnglish ? 'Reset settings?' : 'সেটিংস রিসেট করবেন?',
        ),
        content: Text(
          settings.isEnglish
              ? 'All saved preferences will return to their default values.'
              : 'সব সংরক্ষিত preference ডিফল্ট অবস্থায় ফিরে যাবে।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(settings.isEnglish ? 'Cancel' : 'বাতিল'),
          ),
          FilledButton(
            onPressed: () async {
              await settings.resetSettings();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(settings.isEnglish ? 'Reset' : 'রিসেট'),
          ),
        ],
      ),
    );
  }
}
