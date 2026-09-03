import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/premium_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/text_scale_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'auth/google_login_screen.dart';
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
          _buildPremiumHero(context, s, premium),
          const SizedBox(height: 16),
          _section(context, t(lang, 'ব্যক্তিগতকরণ', 'Personalization'), Icons.tune_rounded, [
            _tile(
              context,
              Icons.dashboard_customize_outlined,
              t(lang, 'হোম স্ক্রিন', 'Home Screen'),
              t(lang, 'সহজ বা বিস্তারিত হোম স্ক্রিন বেছে নিন', 'Choose Simple or Informative Home'),
              () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const HomeModeSettingsScreen())),
            ),
          ]),
          const SizedBox(height: 20),
          _section(context, t(lang, 'অ্যাপের চেহারা', 'Appearance'), Icons.palette_outlined, [
            _choiceTile(context, Icons.palette_outlined, t(lang, 'থিম', 'Theme'), _themeLabel(s), const ['system', 'light', 'dark', 'amoled'], s.isAmoledMode ? 'amoled' : s.themeMode.name, (v) async {
              switch (v) {
                case 'system': await s.setSystemTheme();
                case 'light': await s.setLightTheme();
                case 'dark': await s.setDarkTheme();
                case 'amoled': await s.setAmoledTheme();
              }
            }),
            _divider(),
            _choiceTile(context, Icons.language_rounded, t(lang, 'ভাষা', 'Language'), lang == 'en' ? 'English' : lang == 'ar' ? 'العربية' : 'বাংলা', const ['bn', 'en', 'ar'], lang, s.setLanguage),
            _divider(),
            _tile(context, Icons.text_fields_rounded, t(lang, 'অ্যাপের লেখা', 'App Text Size'), _textSizeLabel(scale.level, lang), () => _textSizeSheet(context, scale, lang)),
            _divider(),
            _choiceTile(context, Icons.access_time_rounded, t(lang, 'সময় ফরম্যাট', 'Time Format'), s.is24Hour ? t(lang, '২৪ ঘণ্টা', '24-hour') : t(lang, '১২ ঘণ্টা', '12-hour'), const ['12', '24'], s.timeFormat, s.setTimeFormat),
            _divider(),
            _switchTile(context, Icons.timer_outlined, t(lang, 'সেকেন্ড দেখান', 'Show Seconds'), t(lang, 'যেখানে সমর্থিত সেখানে সেকেন্ড দেখাবে', 'Show seconds where supported'), s.showSeconds, s.toggleShowSeconds),
            _divider(),
            _switchTile(context, Icons.vibration_rounded, t(lang, 'ভাইব্রেশন', 'Vibration'), t(lang, 'সমর্থিত অ্যাকশনে হ্যাপটিক ফিডব্যাক চালু রাখুন', 'Allow supported haptic feedback'), s.vibrationEnabled, s.toggleVibration),
          ]),
          const SizedBox(height: 20),
          _section(context, t(lang, 'সালাত ও আজান', 'Prayer & Adhan'), Icons.mosque_outlined, [
            _choiceTile(context, Icons.calculate_outlined, t(lang, 'সালাতের হিসাব পদ্ধতি', 'Prayer Calculation'), _choiceLabel(s.calculationMethod, lang), SettingsProvider.calculationMethods, s.calculationMethod, s.setCalculationMethod),
            _divider(),
            _choiceTile(context, Icons.mosque_outlined, t(lang, 'মাযহাব', 'Madhhab'), _choiceLabel(s.madhhab, lang), SettingsProvider.madhabs, s.madhhab, s.setMadhhab),
            _divider(),
            _choiceTile(context, Icons.location_on_outlined, t(lang, 'লোকেশন', 'Location'), s.autoLocation ? t(lang, 'স্বয়ংক্রিয়', 'Automatic') : t(lang, 'ম্যানুয়াল', 'Manual'), const ['automatic', 'manual'], s.locationMode, s.setLocationMode),
            _divider(),
            _switchTile(context, Icons.notifications_active_outlined, t(lang, 'আজান নোটিফিকেশন', 'Adhan Notifications'), t(lang, 'সালাতের সময়ের নোটিফিকেশন চালু রাখুন', 'Enable prayer-time notifications'), s.isAdhanNotificationEnabled, s.toggleAdhanNotification),
            _divider(),
            _choiceTile(context, Icons.volume_up_outlined, t(lang, 'আজানের শব্দ', 'Adhan Sound'), _choiceLabel(s.notificationSound, lang), const ['Default', 'Silent'], s.notificationSound, s.setNotificationSound),
            _divider(),
            _choiceTile(context, Icons.alarm_outlined, t(lang, 'সালাতের আগে স্মরণ', 'Prayer Reminder'), _reminderLabel(s.prayerReminderMinutes, lang), const ['0', '5', '10', '15', '20', '30'], s.prayerReminderMinutes.toString(), (v) => s.setPrayerReminderMinutes(int.parse(v))),
            _divider(),
            _choiceTile(context, Icons.calendar_today_outlined, t(lang, 'হিজরি তারিখ সমন্বয়', 'Hijri Date Adjustment'), _hijriLabel(s, lang), List<String>.generate(7, (i) => '${i - 3}'), s.hijriAdjustment.toString(), (v) => s.setHijriAdjustment(int.parse(v))),
            _divider(),
            _tile(
              context,
              Icons.groups_rounded,
              t(lang, 'জামাতের সময়', 'Jamaat Times'),
              t(lang, 'ফজর, যোহর, আসর, মাগরিব ও ইশার জামাতের সময়', 'Set Fajr, Dhuhr, Asr, Maghrib and Isha Jamaat times'),
              () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const JamaatSettingsScreen())),
            ), s.ishaJamaat),
          ]),
          const SizedBox(height: 20),
          _section(context, t(lang, 'কুরআন', 'Quran'), Icons.menu_book_outlined, [
            _tile(context, Icons.format_size_rounded, t(lang, 'কুরআন পড়ার সেটিংস', 'Quran Reading'), '${s.quranFontSize.round()} / ${s.translationFontSize.round()}', () => _quranSheet(context, s, lang)),
            _divider(),
            _choiceTile(context, Icons.translate_rounded, t(lang, 'অনুবাদ', 'Translation'), _choiceLabel(s.quranTranslation, lang), const ['Bangla', 'English'], s.quranTranslation, s.setQuranTranslation),
            _divider(),
            _choiceTile(context, Icons.font_download_outlined, t(lang, 'আরবি ফন্ট', 'Arabic Font'), _choiceLabel(s.quranArabicFont, lang), const ['Default', 'Amiri', 'Scheherazade'], s.quranArabicFont, s.setQuranArabicFont),
            _divider(),
            _switchTile(context, Icons.skip_next_rounded, t(lang, 'পরবর্তী আয়াত স্বয়ংক্রিয়ভাবে চালু', 'Auto-play next'), t(lang, 'পরের সমর্থিত অডিও স্বয়ংক্রিয়ভাবে চালাবে', 'Continue with the next supported audio item'), s.autoPlayNext, s.toggleAutoPlayNext),
            _divider(),
            _switchTile(context, Icons.wifi_outlined, t(lang, 'শুধু Wi-Fi দিয়ে ডাউনলোড', 'Wi-Fi only downloads'), t(lang, 'ডাউনলোডযোগ্য কুরআন রিসোর্সে Wi-Fi অগ্রাধিকার দিন', 'Prefer Wi-Fi for downloadable Quran resources'), s.downloadWifiOnly, s.toggleDownloadWifiOnly),
          ]),
          const SizedBox(height: 20),
          _section(context, t(lang, 'ইবাদত ও তারিখ', 'Worship & Dates'), Icons.event_available_outlined, [
            _tile(context, Icons.today_outlined, t(lang, 'দৈনিক কনটেন্ট', 'Daily Content'), t(lang, 'আয়াত, হাদিস ও দোয়ার দৃশ্যমানতা', 'Ayah, Hadith and Dua visibility'), () => _dailySheet(context, s, lang)),
            _divider(),
            _choiceTile(context, Icons.calendar_month_outlined, t(lang, 'তারিখের পছন্দ', 'Date Preferences'), _dateLabel(s, lang), const ['hijri', 'gregorian', 'both'], s.dateDisplayPreference, s.setDateDisplayPreference),
          ]),
          const SizedBox(height: 20),
          _section(context, t(lang, 'ডেটা ও অ্যাপ', 'Data & App'), Icons.settings_applications_outlined, [
            _tile(context, Icons.restart_alt_rounded, t(lang, 'সব সেটিংস রিসেট', 'Reset Settings'), t(lang, 'সব কনফিগারযোগ্য সেটিংস ডিফল্টে ফিরিয়ে দিন', 'Restore configurable preferences'), () => _reset(context, s, lang)),
            _divider(),
            _tile(context, Icons.info_outline_rounded, t(lang, 'NurVerse সম্পর্কে', 'About NurVerse'), t(lang, 'সংস্করণ ১.০.০', 'Version 1.0.0'), () => showAboutDialog(context: context, applicationName: 'NurVerse', applicationVersion: '1.0.0')),
            _divider(),
            _tile(context, Icons.code_rounded, t(lang, 'ওপেন সোর্স লাইসেন্স', 'Open Source Licenses'), t(lang, 'NurVerse-এ ব্যবহৃত লাইব্রেরি', 'Libraries used by NurVerse'), () => showLicensePage(context: context, applicationName: 'NurVerse', applicationVersion: '1.0.0')),
          ]),
        ],
      ),
    );
  }

  Widget _buildPremiumHero(BuildContext context, SettingsProvider settings, PremiumProvider premium) {
    final languageCode = settings.languageCode;
    final isActive = premium.isPremium;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.seaBlue.withValues(alpha: .20)),
            boxShadow: [BoxShadow(color: AppColors.seaBlue.withValues(alpha: .07), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 54, height: 54, decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: .14), borderRadius: BorderRadius.circular(17)), child: Icon(isActive ? Icons.verified_rounded : Icons.workspace_premium_rounded, color: AppColors.seaBlue, size: 30)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Flexible(child: Text('NurVerse Premium', style: const TextStyle(color: AppColors.seaBlue, fontSize: 18, fontWeight: FontWeight.w900))),
                        if (isActive) ...[
                          const SizedBox(width: 7),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)), child: Text(t(languageCode, 'সক্রিয়', 'ACTIVE'), style: const TextStyle(color: AppColors.seaBlue, fontSize: 8, fontWeight: FontWeight.w900))),
                        ],
                      ]),
                      const SizedBox(height: 4),
                      Text(isActive ? t(languageCode, 'আপনার প্রিমিয়াম অভিজ্ঞতা সক্রিয়', 'Your premium experience is active') : t(languageCode, 'আরও সমৃদ্ধ ও সুন্দর নূরভার্স উপভোগ করুন', 'Unlock a richer, calmer NurVerse'), style: TextStyle(fontSize: 11, height: 1.4, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: .70))),
                    ]),
                  ),
                  const SizedBox(width: 10),
                  _premiumAccountButton(context, user),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(spacing: 7, runSpacing: 7, children: [
                _premiumChip(Icons.contrast_rounded, t(languageCode, 'অ্যামোলেড', 'AMOLED')),
                _premiumChip(Icons.palette_outlined, t(languageCode, 'প্রিমিয়াম থিম', 'Premium Themes')),
                _premiumChip(Icons.headphones_outlined, t(languageCode, 'তেলাওয়াত', 'Recitations')),
                _premiumChip(Icons.cloud_outlined, t(languageCode, 'ক্লাউড সিঙ্ক', 'Cloud Sync')),
              ]),
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { if (premium.isPremium) { _showPremiumStatus(context, premium); } else { premium.activatePremium(); } }, icon: Icon(premium.isPremium ? Icons.settings_rounded : Icons.auto_awesome_rounded, size: 18), label: Text(premium.isPremium ? t(languageCode, 'প্রিমিয়াম পরিচালনা করুন', 'Manage Premium') : t(languageCode, 'প্রিমিয়াম দেখুন', 'Explore Premium')))),
            ],
          ),
        );
      },
    );
  }

  Widget _premiumChip(IconData icon, String title) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: .09), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: AppColors.seaBlue), const SizedBox(width: 5), Text(title, style: const TextStyle(color: AppColors.seaBlue, fontSize: 10, fontWeight: FontWeight.w700))]));

  Widget _premiumAccountButton(BuildContext context, User? user) {
    final theme = Theme.of(context);
    final photoUrl = user?.photoURL?.trim();
    final hasPhoto = user != null && photoUrl != null && photoUrl.isNotEmpty;
    return Material(color: Colors.transparent, child: InkWell(onTap: () => _handleProfileTap(context, user), borderRadius: BorderRadius.circular(14), child: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: .10), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.seaBlue.withValues(alpha: .12))), child: hasPhoto ? ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.network(photoUrl, width: 42, height: 42, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.person_rounded, color: theme.colorScheme.primary, size: 22))) : Icon(user != null ? Icons.person_rounded : Icons.person_outline_rounded, color: theme.colorScheme.primary, size: 22))));
  }

  Future<void> _handleProfileTap(BuildContext context, User? user) async {
    if (user == null) {
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GoogleLoginScreen()));
      return;
    }
    await _openAccount(context, user);
  }

  Future<void> _openAccount(BuildContext context, User user) async {
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final photoUrl = user.photoURL?.trim();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(radius: 36, backgroundColor: theme.colorScheme.primary.withValues(alpha: .10), backgroundImage: photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null, child: photoUrl == null || photoUrl.isEmpty ? Icon(Icons.account_circle_rounded, size: 48, color: theme.colorScheme.primary) : null),
            const SizedBox(height: 12),
            Text(user.displayName?.trim().isNotEmpty == true ? user.displayName! : t(languageCode, 'নূরভার্স ব্যবহারকারী', 'NurVerse User'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            if (user.email?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(user.email!, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () async { Navigator.of(sheetContext).pop(); await AuthService.instance.signOut(); }, icon: const Icon(Icons.logout_rounded), label: Text(t(languageCode, 'লগআউট', 'Logout')))),
          ]),
        ),
      ),
    );
  }

  Future<void> _showPremiumStatus(BuildContext context, PremiumProvider premium) async {
    final languageCode = Localizations.localeOf(context).languageCode;
    await showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(title: const Text('NurVerse Premium'), content: Text(t(languageCode, 'প্রিমিয়াম সক্রিয় আছে।', 'Premium is active.')), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(t(languageCode, 'ঠিক আছে', 'Done')))]));
  }

  Widget _section(BuildContext context, String title, IconData icon, List<Widget> children) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 4, bottom: 9), child: Row(children: [Icon(icon, size: 16, color: AppColors.seaBlue), const SizedBox(width: 7), Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: .72)))])), Card(margin: EdgeInsets.zero, elevation: 0, clipBehavior: Clip.antiAlias, child: Column(children: children))]);

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: .10), borderRadius: BorderRadius.circular(13)), child: Icon(icon, size: 21, color: AppColors.seaBlue)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), if (subtitle.isNotEmpty) ...[const SizedBox(height: 3), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, height: 1.35, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: .62)))]])), const Icon(Icons.arrow_forward_ios_rounded, size: 14)]))));

  Widget _choiceTile(BuildContext context, IconData icon, String title, String subtitle, List<String> options, String selected, Future<void> Function(String) onChanged) => _tile(context, icon, title, subtitle, () => _choiceSheet(context, title, options, onChanged, selected));

  Widget _switchTile(BuildContext context, IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) => Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: .10), borderRadius: BorderRadius.circular(13)), child: Icon(icon, size: 21, color: AppColors.seaBlue)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), if (subtitle.isNotEmpty) ...[const SizedBox(height: 3), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, height: 1.35, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: .62)))]])), Switch.adaptive(value: value, onChanged: onChanged)]));

  Widget _divider() => const Divider(height: 1, indent: 70);

  String _themeLabel(SettingsProvider s) {
    if (s.isAmoledMode) return t(s.languageCode, 'অ্যামোলেড কালো', 'AMOLED Black');
    switch (s.themeMode) {
      case ThemeMode.light: return t(s.languageCode, 'লাইট মোড', 'Light Mode');
      case ThemeMode.dark: return t(s.languageCode, 'ডার্ক মোড', 'Dark Mode');
      case ThemeMode.system: return t(s.languageCode, 'সিস্টেম অনুযায়ী', 'System Default');
    }
  }

  String _textSizeLabel(int n, String lang) => [t(lang, 'ছোট', 'Small'), t(lang, 'স্বাভাবিক', 'Normal'), t(lang, 'বড়', 'Large'), t(lang, 'খুব বড়', 'Very Large')][n.clamp(0, 3)];

  String _choiceLabel(String value, String languageCode) {
    const bn = <String, String>{'system':'সিস্টেম অনুযায়ী','light':'লাইট মোড','dark':'ডার্ক মোড','amoled':'অ্যামোলেড','bn':'বাংলা','en':'ইংরেজি','ar':'আরবি','12':'১২ ঘণ্টা','24':'২৪ ঘণ্টা','automatic':'স্বয়ংক্রিয়','manual':'ম্যানুয়াল','Karachi':'করাচি','Muslim World League':'মুসলিম ওয়ার্ল্ড লীগ','Egyptian':'মিশরীয়','Umm Al Qura':'উম্মুল কুরা','Dubai':'দুবাই','Qatar':'কাতার','Kuwait':'কুয়েত','Singapore':'সিঙ্গাপুর','North America':'উত্তর আমেরিকা','Moonsighting Committee':'চাঁদ দেখা কমিটি','Tehran':'তেহরান','Turkey':'তুরস্ক','Other':'অন্যান্য','Hanafi':'হানাফি','Shafi':'শাফেয়ি','Maliki':'মালিকি','Hanbali':'হাম্বলি','Bangla':'বাংলা','English':'ইংরেজি','Arabic':'আরবি','Default':'ডিফল্ট','Silent':'নীরব','Amiri':'আমিরি','Scheherazade':'শেহেরাজাদে','hijri':'হিজরি','gregorian':'গ্রেগরিয়ান','both':'উভয়'};
    if (languageCode == 'bn') return bn[value] ?? value;
    if (languageCode == 'en') { if (value == '12') return '12-hour'; if (value == '24') return '24-hour'; return value; }
    const ar = <String, String>{'system':'النظام','light':'فاتح','dark':'داكن','amoled':'AMOLED','bn':'البنغالية','en':'الإنجليزية','ar':'العربية','12':'12 ساعة','24':'24 ساعة','automatic':'تلقائي','manual':'يدوي','Karachi':'كراتشي','Muslim World League':'رابطة العالم الإسلامي','Egyptian':'المصري','Umm Al Qura':'أم القرى','Dubai':'دبي','Qatar':'قطر','Kuwait':'الكويت','Singapore':'سنغافورة','North America':'أمريكا الشمالية','Moonsighting Committee':'لجنة رؤية الهلال','Tehran':'طهران','Turkey':'تركيا','Other':'أخرى','Hanafi':'حنفي','Shafi':'شافعي','Maliki':'مالكي','Hanbali':'حنبلي','Bangla':'البنغالية','English':'الإنجليزية','Arabic':'العربية','Default':'افتراضي','Silent':'صامت','Amiri':'أميري','Scheherazade':'شهرزاد','hijri':'هجري','gregorian':'ميلادي','both':'كلاهما'};
    return ar[value] ?? value;
  }

  String _reminderLabel(int minutes, String lang) => minutes <= 0 ? t(lang, 'সময় হলে', 'At prayer time') : '$minutes ${t(lang, 'মিনিট আগে', 'min before')}';

  String _hijriLabel(SettingsProvider s, String lang) {
    if (s.hijriAdjustment == 0) return t(lang, 'কোনো সমন্বয় নেই', 'No adjustment');
    if (s.hijriAdjustment == 1) return t(lang, 'ঢাকা ডিফল্ট (+1 দিন)', 'Dhaka Default (+1 day)');
    return '${s.hijriAdjustment > 0 ? '+' : ''}${s.hijriAdjustment} ${t(lang, 'দিন', 'day')}';
  }

  String _dateLabel(SettingsProvider s, String lang) {
    switch (s.dateDisplayPreference) {
      case 'hijri': return t(lang, 'শুধু হিজরি', 'Hijri only');
      case 'gregorian': return t(lang, 'শুধু গ্রেগরিয়ান', 'Gregorian only');
      default: return t(lang, 'উভয় তারিখ', 'Both dates');
    }
  }

  Widget _jamaatTile(BuildContext context, SettingsProvider s, String prayer, String title, String value) => _tile(context, Icons.groups_outlined, title, value, () => _showJamaatDialog(context, s, prayer, title));

  Future<void> _showJamaatDialog(BuildContext context, SettingsProvider s, String prayer, String title) async {
    final controller = TextEditingController(text: s.getJamaat(prayer));
    String? error;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text('$title ${t(s.languageCode, 'জামাতের সময়', 'Jamaat Time')}'),
          content: TextField(controller: controller, keyboardType: TextInputType.datetime, decoration: InputDecoration(labelText: t(s.languageCode, 'সময়', 'Time'), hintText: s.is24Hour ? '17:00' : '5:00 PM', errorText: error)),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(t(s.languageCode, 'বাতিল', 'Cancel'))),
            FilledButton(onPressed: () async { final ok = await s.setJamaatTime(prayer, controller.text); if (ok) { if (dialogContext.mounted) Navigator.of(dialogContext).pop(); } else { setState(() => error = t(s.languageCode, 'সঠিক সময় দিন, যেমন 5:00 PM বা 17:00', 'Enter a valid time, e.g. 5:00 PM or 17:00')); } }, child: Text(t(s.languageCode, 'সংরক্ষণ', 'Save'))),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  Future<void> _choiceSheet(BuildContext context, String title, List<String> options, Future<void> Function(String) onChanged, String selected) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(child: ListView(shrinkWrap: true, children: options.map((value) => ListTile(title: Text(_choiceLabel(value, Localizations.localeOf(sheetContext).languageCode)), trailing: value == selected ? const Icon(Icons.check_circle_rounded, color: AppColors.seaBlue) : null, onTap: () async { await onChanged(value); if (sheetContext.mounted) Navigator.pop(sheetContext); })).toList())),
    );
  }

  Future<void> _textSizeSheet(BuildContext context, TextScaleProvider provider, String lang) async {
    final labels = [t(lang, 'ছোট', 'Small'), t(lang, 'স্বাভাবিক', 'Normal'), t(lang, 'বড়', 'Large'), t(lang, 'খুব বড়', 'Very Large')];
    await showModalBottomSheet<void>(context: context, builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [for (int i = 0; i < labels.length; i++) ListTile(title: Text(labels[i]), trailing: i == provider.level ? const Icon(Icons.check_circle_rounded, color: AppColors.seaBlue) : null, onTap: () async { await provider.setLevel(i); if (sheetContext.mounted) Navigator.pop(sheetContext); })])));
  }

  Future<void> _quranSheet(BuildContext context, SettingsProvider s, String lang) async {
    await showModalBottomSheet<void>(context: context, builder: (sheetContext) => SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(t(lang, 'কুরআন পড়ার সেটিংস', 'Quran Reading'), style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 12), Text('${t(lang, 'আরবি', 'Arabic')}: ${s.quranFontSize.round()}'), Slider(value: s.quranFontSize.clamp(14.0, 50.0).toDouble(), min: 14, max: 50, divisions: 36, onChanged: s.updateQuranFontSize), Text('${t(lang, 'অনুবাদ', 'Translation')}: ${s.translationFontSize.round()}'), Slider(value: s.translationFontSize.clamp(10.0, 30.0).toDouble(), min: 10, max: 30, divisions: 20, onChanged: s.updateTranslationFontSize)]))));
  }

  Future<void> _dailySheet(BuildContext context, SettingsProvider s, String lang) async {
    await showModalBottomSheet<void>(context: context, builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      _switchTile(sheetContext, Icons.menu_book_outlined, t(lang, 'দৈনিক আয়াত', 'Daily Ayah'), '', s.showDailyAyah, (v) => s.setDailyContentPreferences(ayah: v)),
      _switchTile(sheetContext, Icons.auto_stories_outlined, t(lang, 'দৈনিক হাদিস', 'Daily Hadith'), '', s.showDailyHadith, (v) => s.setDailyContentPreferences(hadith: v)),
      _switchTile(sheetContext, Icons.volunteer_activism_outlined, t(lang, 'দৈনিক দোয়া', 'Daily Dua'), '', s.showDailyDua, (v) => s.setDailyContentPreferences(dua: v)),
    ])));
  }

  Future<void> _reset(BuildContext context, SettingsProvider s, String lang) async {
    final yes = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(title: Text(t(lang, 'সেটিংস রিসেট করবেন?', 'Reset settings?')), content: Text(t(lang, 'সব সংরক্ষিত সেটিংস ডিফল্টে ফিরে যাবে।', 'All saved preferences will return to their defaults.')), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(t(lang, 'বাতিল', 'Cancel'))), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(t(lang, 'রিসেট', 'Reset')))]));
    if (yes == true) await s.resetSettings();
  }
}
