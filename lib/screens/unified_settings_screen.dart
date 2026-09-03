import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/premium_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/text_scale_provider.dart';
import '../theme/app_theme.dart';
import 'home_mode_settings_screen.dart';
import 'prayer/jamaat_settings_screen.dart';

/// The single canonical Settings UI for NurVerse.
///
/// Legacy SettingsScreen and SettingsHubScreenV4 are thin wrappers around this
/// screen so the app cannot drift into multiple settings implementations.
class UnifiedSettingsScreen extends StatelessWidget {
  const UnifiedSettingsScreen({super.key});

  String _t(String language, String bn, String en, [String? ar]) {
    if (language == 'ar') return ar ?? en;
    if (language == 'en') return en;
    return bn;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final textScale = context.watch<TextScaleProvider>();
    final premium = context.watch<PremiumProvider>();
    final language = settings.languageCode;
    final isEnglish = language == 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(language, 'সেটিংস', 'Settings', 'الإعدادات')),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _premiumCard(context, settings, premium),
          const SizedBox(height: 16),

          _section(context, _t(language, 'ব্যক্তিগতকরণ', 'Personalization'), Icons.tune_rounded, [
            _tile(
              context,
              Icons.dashboard_customize_outlined,
              _t(language, 'হোম স্ক্রিন', 'Home Screen'),
              _t(language, 'সহজ বা বিস্তারিত হোম স্ক্রিন বেছে নিন', 'Choose Simple or Informative Home'),
              () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeModeSettingsScreen())),
            ),
          ]),
          const SizedBox(height: 20),

          _section(context, _t(language, 'অ্যাপের চেহারা', 'Appearance'), Icons.palette_outlined, [
            _tile(
              context,
              Icons.palette_outlined,
              _t(language, 'থিম', 'Theme'),
              _themeLabel(settings),
              () => _showChoiceSheet(
                context,
                _t(language, 'থিম', 'Theme'),
                const ['system', 'light', 'dark', 'amoled'],
                (value) async {
                  switch (value) {
                    case 'system': await settings.setSystemTheme(); break;
                    case 'light': await settings.setLightTheme(); break;
                    case 'dark': await settings.setDarkTheme(); break;
                    case 'amoled': await settings.setAmoledTheme(); break;
                  }
                },
                selectedValue: settings.isAmoledMode ? 'amoled' : settings.themeMode.name,
              ),
            ),
            _divider(),
            _tile(
              context,
              Icons.language_rounded,
              _t(language, 'ভাষা', 'Language', 'اللغة'),
              _t(language, 'বাংলা', 'English', 'العربية'),
              () => _showChoiceSheet(
                context,
                _t(language, 'ভাষা', 'Language', 'اللغة'),
                const ['bn', 'en', 'ar'],
                settings.setLanguage,
                selectedValue: settings.languageCode,
              ),
            ),
            _divider(),
            _tile(
              context,
              Icons.text_fields_rounded,
              _t(language, 'অ্যাপের লেখা', 'App Text Size'),
              _textSizeLabel(textScale.level, language),
              () => _showTextSizeSheet(context, textScale),
            ),
            _divider(),
            _tile(
              context,
              Icons.access_time_rounded,
              _t(language, 'সময় ফরম্যাট', 'Time Format', 'تنسيق الوقت'),
              settings.is24Hour ? _t(language, '২৪ ঘণ্টা', '24-hour', '24 ساعة') : _t(language, '১২ ঘণ্টা', '12-hour', '12 ساعة'),
              () => _showChoiceSheet(
                context,
                _t(language, 'সময় ফরম্যাট', 'Time Format', 'تنسيق الوقت'),
                const ['12', '24'],
                settings.setTimeFormat,
                selectedValue: settings.timeFormat,
              ),
            ),
            _divider(),
            _switchTile(
              context,
              Icons.timer_outlined,
              _t(language, 'সেকেন্ড দেখান', 'Show Seconds'),
              _t(language, 'যেখানে সমর্থিত সেখানে সেকেন্ড দেখাবে', 'Show seconds where supported'),
              settings.showSeconds,
              settings.toggleShowSeconds,
            ),
            _divider(),
            _switchTile(
              context,
              Icons.vibration_rounded,
              _t(language, 'ভাইব্রেশন', 'Vibration'),
              _t(language, 'সমর্থিত অ্যাকশনে হ্যাপটিক ফিডব্যাক চালু রাখুন', 'Allow supported haptic feedback'),
              settings.vibrationEnabled,
              settings.toggleVibration,
            ),
          ]),
          const SizedBox(height: 20),

          _section(context, _t(language, 'সালাত ও আজান', 'Prayer & Adhan'), Icons.mosque_outlined, [
            _tile(
              context,
              Icons.calculate_outlined,
              _t(language, 'সালাতের হিসাব পদ্ধতি', 'Prayer Calculation'),
              _choiceLabel(settings.calculationMethod, language),
              () => _showChoiceSheet(context, _t(language, 'সালাতের হিসাব পদ্ধতি', 'Prayer Calculation'), SettingsProvider.calculationMethods, settings.setCalculationMethod, selectedValue: settings.calculationMethod),
            ),
            _divider(),
            _tile(
              context,
              Icons.mosque_outlined,
              _t(language, 'মাযহাব', 'Madhhab'),
              _choiceLabel(settings.madhhab, language),
              () => _showChoiceSheet(context, _t(language, 'মাযহাব', 'Madhhab'), SettingsProvider.madhabs, settings.setMadhhab, selectedValue: settings.madhhab),
            ),
            _divider(),
            _tile(
              context,
              Icons.location_on_outlined,
              _t(language, 'লোকেশন', 'Location'),
              settings.autoLocation ? _t(language, 'স্বয়ংক্রিয়', 'Automatic') : _t(language, 'ম্যানুয়াল', 'Manual'),
              () => _showChoiceSheet(context, _t(language, 'লোকেশন', 'Location'), const ['automatic', 'manual'], settings.setLocationMode, selectedValue: settings.locationMode),
            ),
            _divider(),
            _switchTile(
              context,
              Icons.notifications_active_outlined,
              _t(language, 'আজান নোটিফিকেশন', 'Adhan Notifications'),
              _t(language, 'প্রতিটি সালাতের সময় আজানের নোটিফিকেশন চালু রাখুন', 'Enable Adhan notifications for prayer times'),
              settings.isAdhanNotificationEnabled,
              settings.toggleAdhanNotification,
            ),
            _divider(),
            _tile(
              context,
              Icons.volume_up_outlined,
              _t(language, 'আজানের শব্দ', 'Adhan Sound'),
              _choiceLabel(settings.notificationSound, language),
              () => _showChoiceSheet(context, _t(language, 'আজানের শব্দ', 'Adhan Sound'), const ['Default', 'Silent'], settings.setNotificationSound, selectedValue: settings.notificationSound),
            ),
            _divider(),
            _tile(
              context,
              Icons.alarm_outlined,
              _t(language, 'সালাতের আগে স্মরণ', 'Prayer Reminder'),
              _reminderLabel(settings.prayerReminderMinutes, language),
              () => _showChoiceSheet(context, _t(language, 'সালাতের আগে স্মরণ', 'Prayer Reminder'), const ['0', '5', '10', '15', '20', '30'], (value) => settings.setPrayerReminderMinutes(int.parse(value)), selectedValue: settings.prayerReminderMinutes.toString()),
            ),
            _divider(),
            _tile(
              context,
              Icons.tune_rounded,
              _t(language, 'সালাতের সময় সমন্বয়', 'Prayer Adjustments'),
              _adjustmentLabel(settings, language),
              () => _showPrayerAdjustmentsSheet(context, settings),
            ),
            _divider(),
            _tile(
              context,
              Icons.calendar_today_outlined,
              _t(language, 'হিজরি তারিখ সমন্বয়', 'Hijri Date Adjustment'),
              _hijriLabel(settings, language),
              () => _showChoiceSheet(context, _t(language, 'হিজরি তারিখ সমন্বয়', 'Hijri Date Adjustment'), List<String>.generate(7, (i) => (i - 3).toString()), (value) => settings.setHijriAdjustment(int.parse(value)), selectedValue: settings.hijriAdjustment.toString()),
            ),
            _divider(),
            _tile(
              context,
              Icons.groups_rounded,
              _t(language, 'জামাতের সময়', 'Jamaat Times'),
              _t(language, 'প্রতিটি ওয়াক্তের স্থানীয় জামাতের সময় সেট করুন', 'Set local Jamaat times for each prayer'),
              () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const JamaatSettingsScreen())),
            ),
          ]),
          const SizedBox(height: 20),

          _section(context, _t(language, 'কুরআন', 'Quran'), Icons.menu_book_outlined, [
            _tile(
              context,
              Icons.format_size_rounded,
              _t(language, 'কুরআন পড়ার সেটিংস', 'Quran Reading'),
              '${settings.quranFontSize.round()} / ${settings.translationFontSize.round()}',
              () => _showQuranFontSheet(context, settings),
            ),
            _divider(),
            _tile(
              context,
              Icons.translate_rounded,
              _t(language, 'অনুবাদ', 'Translation'),
              _choiceLabel(settings.quranTranslation, language),
              () => _showChoiceSheet(context, _t(language, 'অনুবাদ', 'Translation'), const ['Bangla', 'English'], settings.setQuranTranslation, selectedValue: settings.quranTranslation),
            ),
            _divider(),
            _tile(
              context,
              Icons.font_download_outlined,
              _t(language, 'আরবি ফন্ট', 'Arabic Font'),
              _choiceLabel(settings.quranArabicFont, language),
              () => _showChoiceSheet(context, _t(language, 'আরবি ফন্ট', 'Arabic Font'), const ['Default', 'Amiri', 'Scheherazade'], settings.setQuranArabicFont, selectedValue: settings.quranArabicFont),
            ),
            _divider(),
            _switchTile(
              context,
              Icons.skip_next_rounded,
              _t(language, 'পরবর্তী আয়াত স্বয়ংক্রিয়ভাবে চালু', 'Auto-play next'),
              _t(language, 'সমর্থিত অডিওতে পরেরটি স্বয়ংক্রিয়ভাবে চালাবে', 'Continue with the next supported audio item'),
              settings.autoPlayNext,
              settings.toggleAutoPlayNext,
            ),
            _divider(),
            _switchTile(
              context,
              Icons.wifi_outlined,
              _t(language, 'শুধু Wi-Fi দিয়ে ডাউনলোড', 'Wi-Fi only downloads'),
              _t(language, 'ডাউনলোডযোগ্য কুরআন রিসোর্সে Wi-Fi অগ্রাধিকার দিন', 'Prefer Wi-Fi for downloadable Quran resources'),
              settings.downloadWifiOnly,
              settings.toggleDownloadWifiOnly,
            ),
          ]),
          const SizedBox(height: 20),

          _section(context, _t(language, 'ইবাদত ও তারিখ', 'Worship & Dates'), Icons.event_available_outlined, [
            _tile(
              context,
              Icons.today_outlined,
              _t(language, 'দৈনিক কনটেন্ট', 'Daily Content'),
              _t(language, 'আয়াত, হাদিস ও দোয়ার দৃশ্যমানতা', 'Ayah, Hadith and Dua visibility'),
              () => _showDailyContentSheet(context, settings),
            ),
            _divider(),
            _tile(
              context,
              Icons.calendar_month_outlined,
              _t(language, 'তারিখের পছন্দ', 'Date Preferences'),
              _dateLabel(settings, language),
              () => _showChoiceSheet(context, _t(language, 'তারিখের পছন্দ', 'Date Preferences'), const ['hijri', 'gregorian', 'both'], settings.setDateDisplayPreference, selectedValue: settings.dateDisplayPreference),
            ),
          ]),
          const SizedBox(height: 20),

          _section(context, _t(language, 'ডেটা ও অ্যাপ', 'Data & App'), Icons.settings_applications_outlined, [
            _tile(
              context,
              Icons.restart_alt_rounded,
              _t(language, 'সব সেটিংস রিসেট', 'Reset Settings'),
              _t(language, 'সব কনফিগারযোগ্য সেটিংস ডিফল্টে ফিরিয়ে দিন', 'Restore configurable preferences'),
              () => _resetDialog(context, settings),
            ),
            _divider(),
            _tile(
              context,
              Icons.info_outline_rounded,
              _t(language, 'নূরভার্স সম্পর্কে', 'About NurVerse'),
              'Version 1.0.0',
              () => showAboutDialog(context: context, applicationName: 'NurVerse', applicationVersion: '1.0.0'),
            ),
            _divider(),
            _tile(
              context,
              Icons.code_rounded,
              _t(language, 'ওপেন সোর্স লাইসেন্স', 'Open Source Licenses'),
              _t(language, 'নূরভার্সে ব্যবহৃত লাইব্রেরি', 'Libraries used in NurVerse'),
              () => showLicensePage(context: context, applicationName: 'NurVerse', applicationVersion: '1.0.0'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _premiumCard(BuildContext context, SettingsProvider settings, PremiumProvider premium) {
    final language = settings.languageCode;
    final active = premium.isPremium;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: AppColors.seaBlue, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'NurVerse Premium',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                if (active) const Icon(Icons.verified_rounded, color: AppColors.seaBlue, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              active
                  ? _t(language, 'আপনার প্রিমিয়াম অভিজ্ঞতা সক্রিয়', 'Your premium experience is active')
                  : _t(language, 'আরও সমৃদ্ধ ও সুন্দর নূরভার্স উপভোগ করুন', 'Unlock a richer, calmer NurVerse'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => premium.activatePremium(),
                icon: Icon(active ? Icons.settings_rounded : Icons.auto_awesome_rounded, size: 18),
                label: Text(active ? _t(language, 'প্রিমিয়াম সক্রিয়', 'Premium Active') : _t(language, 'প্রিমিয়াম দেখুন', 'Explore Premium')),
              ),
            ),
          ],
        ),
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
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: .72))),
            ],
          ),
        ),
        Card(margin: EdgeInsets.zero, elevation: 0, clipBehavior: Clip.antiAlias, child: Column(children: children)),
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
              Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: .10), borderRadius: BorderRadius.circular(13)), child: Icon(icon, size: 21, color: AppColors.seaBlue)),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, height: 1.35, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: .62)))])),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Theme.of(context).iconTheme.color?.withValues(alpha: .38)),
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
          Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: .10), borderRadius: BorderRadius.circular(13)), child: Icon(icon, size: 21, color: AppColors.seaBlue)),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), if (subtitle.isNotEmpty) ...[const SizedBox(height: 3), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, height: 1.35, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: .62)))]])),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 70);

  String _themeLabel(SettingsProvider settings) {
    if (settings.isAmoledMode) return _t(settings.languageCode, 'অ্যামোলেড কালো', 'AMOLED Black');
    switch (settings.themeMode) {
      case ThemeMode.light: return _t(settings.languageCode, 'লাইট মোড', 'Light Mode');
      case ThemeMode.dark: return _t(settings.languageCode, 'ডার্ক মোড', 'Dark Mode');
      case ThemeMode.system: return _t(settings.languageCode, 'সিস্টেম অনুযায়ী', 'System Default');
    }
  }

  String _textSizeLabel(int level, String language) {
    switch (level) {
      case 0: return _t(language, 'ছোট', 'Small');
      case 2: return _t(language, 'বড়', 'Large');
      case 3: return _t(language, 'খুব বড়', 'Very Large');
      default: return _t(language, 'স্বাভাবিক', 'Normal');
    }
  }

  String _choiceLabel(String option, String language) {
    if (language == 'en') return option == 'bn' ? 'Bangla' : option == 'en' ? 'English' : option == 'Default' ? 'Default' : option == 'Adhan' ? 'Adhan' : option == 'Silent' ? 'Silent' : option;
    if (language == 'ar') return option;
    const labels = <String, String>{
      'Karachi': 'করাচি', 'Muslim World League': 'মুসলিম ওয়ার্ল্ড লীগ', 'Egyptian': 'মিশরীয়', 'Umm Al Qura': 'উম্মুল কুরা', 'Dubai': 'দুবাই', 'Qatar': 'কাতার', 'Kuwait': 'কুয়েত', 'Singapore': 'সিঙ্গাপুর', 'North America': 'উত্তর আমেরিকা', 'Moonsighting Committee': 'চাঁদ দেখা কমিটি',
      'Hanafi': 'হানাফি', 'Shafi': 'শাফেয়ী', 'Maliki': 'মালিকি', 'Hanbali': 'হাম্বলি', 'Bangla': 'বাংলা', 'English': 'ইংরেজি', 'Default': 'ডিফল্ট', 'Adhan': 'আজান', 'Silent': 'নীরব', 'Amiri': 'আমিরি', 'Scheherazade': 'শেহেরাজাদে',
    };
    return labels[option] ?? option;
  }

  String _reminderLabel(int minutes, String language) => minutes <= 0 ? _t(language, 'সময় হলে', 'At prayer time') : '$minutes ${_t(language, 'মিনিট আগে', 'min before')}';

  String _hijriLabel(SettingsProvider settings, String language) {
    final value = settings.hijriAdjustment;
    if (value == 0) return _t(language, 'কোনো সমন্বয় নেই', 'No adjustment');
    if (value == 1) return _t(language, 'ঢাকা ডিফল্ট (+1 দিন)', 'Dhaka Default (+1 day)');
    final sign = value > 0 ? '+' : '';
    return '$sign$value ${_t(language, 'দিন', 'day')}';
  }

  String _adjustmentLabel(SettingsProvider settings, String language) {
    final nonZero = settings.prayerAdjustments.entries.where((e) => e.value != 0).toList();
    if (nonZero.isEmpty) return _t(language, 'কোনো সমন্বয় নেই', 'No adjustments');
    return nonZero.map((e) => '${e.key}: ${e.value > 0 ? '+' : ''}${e.value}m').join(', ');
  }

  String _dateLabel(SettingsProvider settings, String language) {
    switch (settings.dateDisplayPreference) {
      case 'hijri': return _t(language, 'শুধু হিজরি', 'Hijri only');
      case 'gregorian': return _t(language, 'শুধু গ্রেগরিয়ান', 'Gregorian only');
      default: return _t(language, 'উভয় তারিখ', 'Both dates');
    }
  }

  Future<void> _showChoiceSheet(BuildContext context, String title, List<String> options, Future<void> Function(String) onSelected, {String? selectedValue}) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            return ListTile(
              title: Text(_choiceLabel(option, Localizations.localeOf(context).languageCode)),
              trailing: option == selectedValue ? const Icon(Icons.check_circle_rounded, color: AppColors.seaBlue) : null,
              onTap: () async {
                await onSelected(option);
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showTextSizeSheet(BuildContext context, TextScaleProvider provider) async {
    final language = Localizations.localeOf(context).languageCode;
    final labels = language == 'en' ? const ['Small', 'Normal', 'Large', 'Very Large'] : language == 'ar' ? const ['صغير', 'عادي', 'كبير', 'كبير جدًا'] : const ['ছোট', 'স্বাভাবিক', 'বড়', 'খুব বড়'];
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.all(18), child: Text(_t(language, 'অ্যাপের লেখা', 'App Text Size'), style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
          for (int i = 0; i < labels.length; i++) ListTile(title: Text(labels[i]), trailing: i == provider.level ? const Icon(Icons.check_circle_rounded, color: AppColors.seaBlue) : null, onTap: () async { await provider.setLevel(i); if (sheetContext.mounted) Navigator.pop(sheetContext); }),
        ]),
      ),
    );
  }

  Future<void> _showQuranFontSheet(BuildContext context, SettingsProvider settings) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _slider(sheetContext, _t(settings.languageCode, 'কুরআন আরবি', 'Quran Arabic'), settings.quranFontSize, 14, 50, settings.updateQuranFontSize),
            const SizedBox(height: 14),
            _slider(sheetContext, _t(settings.languageCode, 'অনুবাদ', 'Translation'), settings.translationFontSize, 10, 30, settings.updateTranslationFontSize),
          ]),
        ),
      ),
    );
  }

  Widget _slider(BuildContext context, String title, double value, double min, double max, ValueChanged<double> onChanged) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))), Text(value.round().toString(), style: const TextStyle(color: AppColors.seaBlue, fontWeight: FontWeight.w900))]), Slider(value: value.clamp(min, max), min: min, max: max, divisions: (max - min).round(), onChanged: onChanged)]);

  Future<void> _showPrayerAdjustmentsSheet(BuildContext context, SettingsProvider settings) async {
    final prayers = const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: Column(
                children: [
                  Text(_t(settings.languageCode, 'সালাতের সময় সমন্বয়', 'Prayer Adjustments'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  for (final prayer in prayers) ...[
                    Row(children: [Expanded(child: Text(_choiceLabel(prayer, settings.languageCode), style: const TextStyle(fontWeight: FontWeight.w700))), Text('${settings.prayerAdjustments[prayer] ?? 0} min')]),
                    Slider(min: -60, max: 60, divisions: 120, value: (settings.prayerAdjustments[prayer] ?? 0).toDouble(), onChanged: (value) async { await settings.setPrayerAdjustment(prayer, value.round()); setState(() {}); }),
                  ],
                  const SizedBox(height: 6),
                  TextButton(onPressed: () async { await settings.resetPrayerAdjustments(); setState(() {}); }, child: Text(_t(settings.languageCode, 'সব সমন্বয় রিসেট', 'Reset all adjustments'))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDailyContentSheet(BuildContext context, SettingsProvider settings) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _switchTile(sheetContext, Icons.menu_book_outlined, _t(settings.languageCode, 'দৈনিক আয়াত', 'Daily Ayah'), '', settings.showDailyAyah, (v) => settings.setDailyContentPreferences(ayah: v)),
          _switchTile(sheetContext, Icons.auto_stories_outlined, _t(settings.languageCode, 'দৈনিক হাদিস', 'Daily Hadith'), '', settings.showDailyHadith, (v) => settings.setDailyContentPreferences(hadith: v)),
          _switchTile(sheetContext, Icons.volunteer_activism_outlined, _t(settings.languageCode, 'দৈনিক দোয়া', 'Daily Dua'), '', settings.showDailyDua, (v) => settings.setDailyContentPreferences(dua: v)),
        ]),
      ),
    );
  }

  Future<void> _resetDialog(BuildContext context, SettingsProvider settings) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_t(settings.languageCode, 'সেটিংস রিসেট করবেন?', 'Reset settings?')),
        content: Text(_t(settings.languageCode, 'সব সংরক্ষিত সেটিংস ডিফল্ট অবস্থায় ফিরে যাবে।', 'All saved preferences will return to their default values.')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(_t(settings.languageCode, 'বাতিল', 'Cancel'))),
          FilledButton(onPressed: () async { await settings.resetSettings(); if (dialogContext.mounted) Navigator.pop(dialogContext); }, child: Text(_t(settings.languageCode, 'রিসেট', 'Reset'))),
        ],
      ),
    );
  }
}
