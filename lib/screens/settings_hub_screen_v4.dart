import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/app_localizations.dart';

import '../localization/app_localizations.dart';

import '../providers/premium_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/text_scale_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'auth/google_login_screen.dart';
import 'home_mode_settings_screen.dart';

class SettingsHubScreenV4 extends StatelessWidget {
  const SettingsHubScreenV4({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context);
    final textScale = context.watch<TextScaleProvider>();
    final premium = context.watch<PremiumProvider>();
    final isEnglish = settings.isEnglish;
    final isArabic = settings.isArabic;

    return Scaffold(
      appBar: AppBar(title: Text(isEnglish ? 'Settings' : isArabic ? 'الإعدادات' : 'সেটিংস')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _buildPremiumHero(context, settings, premium),
          const SizedBox(height: 14),
          _section(context, l10n.tr('ব্যক্তিগতকরণ', 'Personalization'), Icons.tune_rounded, [
            _tile(
              context,
              Icons.dashboard_customize_outlined,
              l10n.tr('হোম স্ক্রিন', 'Home Screen'),
              l10n.tr('সহজ বা বিস্তারিত হোম স্ক্রিন বেছে নিন', 'Choose Simple or Informative Home'),
              () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const HomeModeSettingsScreen()),
                );
              },
            ),
          ]),
          const SizedBox(height: 20),
          _section(context, l10n.tr('অ্যাপের চেহারা', 'Appearance'), Icons.palette_outlined, [
            _tile(
              context,
              Icons.palette_outlined,
              l10n.tr('থিম', 'Theme'),
              _themeLabel(settings),
              () => _showChoiceSheet(
                context,
                l10n.tr('থিম', 'Theme'),
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
                selectedValue: settings.isAmoledMode ? 'amoled' : settings.themeMode.name,
              ),
            ),
            _divider(),
            _tile(
              context,
              Icons.language_rounded,
              isEnglish ? 'Language' : isArabic ? 'اللغة' : 'ভাষা',
              isEnglish ? 'English' : isArabic ? 'العربية' : 'বাংলা',
              () => _showChoiceSheet(
                context,
                isEnglish ? 'Language' : isArabic ? 'اللغة' : 'ভাষা',
                const ['bn', 'en', 'ar'],
                settings.setLanguage,
                selectedValue: settings.languageCode,
              ),
            ),
            _divider(),
            _tile(
              context,
              Icons.text_fields_rounded,
              l10n.tr('অ্যাপের লেখা', 'App Text Size'),
              _textSizeLabel(textScale.level, isEnglish),
              () => _showTextSizeSheet(context, textScale, isEnglish),
            ),
            _divider(),
            _switchTile(
              context,
              Icons.timer_outlined,
              l10n.tr('সেকেন্ড দেখান', 'Show seconds'),
              l10n.tr('যেখানে সমর্থিত সেখানে সেকেন্ড দেখাবে', 'Show seconds where supported'),
              settings.showSeconds,
              settings.toggleShowSeconds,
            ),
            _divider(),
            _switchTile(
              context,
              Icons.vibration_rounded,
              l10n.tr('ভাইব্রেশন', 'Vibration'),
              l10n.tr('সমর্থিত অ্যাকশনে হ্যাপটিক ফিডব্যাক চালু রাখুন', 'Allow supported haptic feedback'),
              settings.vibrationEnabled,
              settings.toggleVibration,
            ),
          ]),
          const SizedBox(height: 20),
          _section(context, l10n.tr('সালাত ও আজান', 'Prayer & Adhan'), Icons.mosque_outlined, [
            _tile(
              context,
              Icons.calculate_outlined,
              l10n.tr('সালাতের হিসাব পদ্ধতি', 'Prayer Calculation'),
              _calculationLabel(settings.calculationMethod, isEnglish),
              () => _showChoiceSheet(
                context,
                l10n.tr('সালাতের হিসাব পদ্ধতি', 'Prayer Calculation'),
                SettingsProvider.calculationMethods,
                settings.setCalculationMethod,
              ),
            ),
            _divider(),
            _tile(
              context,
              Icons.mosque_outlined,
              l10n.tr('মাযহাব', 'Madhhab'),
              _madhabLabel(settings.madhab, isEnglish),
              () => _showChoiceSheet(
                context,
                l10n.tr('মাযহাব', 'Madhhab'),
                SettingsProvider.madhabs,
                settings.setMadhhab,
              ),
            ),
            _divider(),
            _switchTile(
              context,
              Icons.notifications_active_outlined,
              l10n.tr('আজান নোটিফিকেশন', 'Adhan Notifications'),
              l10n.tr('সালাতের সময়ের নোটিফিকেশন চালু রাখুন', 'Enable prayer-time notifications'),
              settings.isAdhanNotificationEnabled,
              settings.toggleAdhanNotification,
            ),
            _divider(),
            _tile(
              context,
              Icons.tune_rounded,
              l10n.tr('সালাতের সময় সমন্বয়', 'Prayer Adjustments'),
              _adjustmentLabel(settings, isEnglish),
              () => _showAdjustmentDialog(context, settings),
            ),
            _divider(),
            _tile(
              context,
              Icons.access_time_rounded,
              l10n.tr('জামাতের সময়', 'Jamaat Times'),
              l10n.tr('নিজের এলাকার জামাতের সময় সেট করুন', 'Set local Jamaat times'),
              () => _showJamaatDialog(context, settings),
            ),
          ]),
          const SizedBox(height: 20),
          _section(context, l10n.tr('কুরআন', 'Quran'), Icons.menu_book_outlined, [
            _tile(
              context,
              Icons.format_size_rounded,
              l10n.tr('কুরআন পড়ার সেটিংস', 'Quran Reading'),
              '${settings.quranFontSize.round()} / ${settings.translationFontSize.round()}',
              () => _showQuranFontSheet(context, settings),
            ),
            _divider(),
            _tile(
              context,
              Icons.translate_rounded,
              l10n.tr('অনুবাদ', 'Translation'),
              _quranTranslationLabel(settings.quranTranslation, isEnglish),
              () => _showChoiceSheet(
                context,
                l10n.tr('অনুবাদ', 'Translation'),
                const ['Bangla', 'English'],
                settings.setQuranTranslation,
              ),
            ),
            _divider(),
            _tile(
              context,
              Icons.font_download_outlined,
              l10n.tr('আরবি ফন্ট', 'Arabic Font'),
              settings.quranArabicFont == 'Default' && !isEnglish ? 'ডিফল্ট' : settings.quranArabicFont,
              () => _showChoiceSheet(
                context,
                l10n.tr('আরবি ফন্ট', 'Arabic Font'),
                const ['Default', 'Amiri', 'Scheherazade'],
                settings.setQuranArabicFont,
              ),
            ),
            _divider(),
            _switchTile(
              context,
              Icons.skip_next_rounded,
              l10n.tr('পরেরটি স্বয়ংক্রিয় চালান', 'Auto-play next'),
              l10n.tr('সমর্থিত অডিওতে পরেরটি স্বয়ংক্রিয়ভাবে চালাবে', 'Continue with the next supported audio item'),
              settings.autoPlayNext,
              settings.toggleAutoPlayNext,
            ),
            _divider(),
            _switchTile(
              context,
              Icons.wifi_outlined,
              l10n.tr('শুধু ওয়াই-ফাই ডাউনলোড', 'Wi-Fi only downloads'),
              l10n.tr('ডাউনলোডযোগ্য কুরআন রিসোর্সে ওয়াই-ফাই অগ্রাধিকার দিন', 'Prefer Wi-Fi for downloadable Quran resources'),
              settings.downloadWifiOnly,
              settings.toggleDownloadWifiOnly,
            ),
          ]),
          const SizedBox(height: 20),
          _section(context, l10n.tr('ইবাদত ও তারিখ', 'Worship & Dates'), Icons.event_available_outlined, [
            _tile(
              context,
              Icons.today_outlined,
              l10n.tr('দৈনিক কনটেন্ট', 'Daily Content'),
              l10n.tr('আয়াত, হাদিস ও দোয়ার দৃশ্যমানতা', 'Ayah, Hadith and Dua visibility'),
              () => _showDailyContentSheet(context),
            ),
            _divider(),
            _tile(
              context,
              Icons.calendar_month_outlined,
              l10n.tr('তারিখের পছন্দ', 'Date Preferences'),
              _dateLabel(settings, isEnglish),
              () => _showChoiceSheet(
                context,
                l10n.tr('তারিখের পছন্দ', 'Date Preferences'),
                const ['hijri', 'gregorian', 'both'],
                settings.setDateDisplayPreference,
              ),
            ),
          ]),
          const SizedBox(height: 20),
          _section(context, l10n.tr('ডেটা ও অ্যাপ', 'Data & App'), Icons.settings_applications_outlined, [
            _tile(
              context,
              Icons.restart_alt_rounded,
              l10n.tr('সেটিংস রিসেট', 'Reset Settings'),
              l10n.tr('সব কনফিগারযোগ্য সেটিংস ডিফল্টে ফিরিয়ে দিন', 'Restore configurable preferences'),
              () => _showResetDialog(context, settings),
            ),
            _divider(),
            _tile(
              context,
              Icons.info_outline_rounded,
              l10n.tr('নূরভার্স সম্পর্কে', 'About NurVerse'),
              l10n.tr('সংস্করণ ১.০.০', 'Version 1.0.0'),
              () => showAboutDialog(
                context: context,
                applicationName: l10n.tr('নূরভার্স', 'NurVerse'),
                applicationVersion: '1.0.0',
              ),
            ),
            _divider(),
            _tile(
              context,
              Icons.code_rounded,
              l10n.tr('ওপেন সোর্স লাইসেন্স', 'Open Source Licenses'),
              l10n.tr('নূরভার্সে ব্যবহৃত লাইব্রেরি', 'Libraries used by NurVerse'),
              () => showLicensePage(
                context: context,
                applicationName: l10n.tr('নূরভার্স', 'NurVerse'),
                applicationVersion: '1.0.0',
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildPremiumHero(BuildContext context, SettingsProvider settings, PremiumProvider premium) {
    final l10n = AppLocalizations.of(context);
    final isEnglish = settings.languageCode == 'en';
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
                                l10n.tr('নূরভার্স প্রিমিয়াম', 'NurVerse Premium'),
                                style: const TextStyle(color: AppColors.seaBlue, fontSize: 18, fontWeight: FontWeight.w900),
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
                                child: Text(l10n.tr('সক্রিয়', 'ACTIVE'), style: const TextStyle(color: AppColors.seaBlue, fontSize: 8, fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isActive
                              ? (l10n.tr('আপনার প্রিমিয়াম অভিজ্ঞতা সক্রিয়', 'Your premium experience is active'))
                              : (l10n.tr('আরও সমৃদ্ধ ও সুন্দর নূরভার্স উপভোগ করুন', 'Unlock a richer, calmer NurVerse')),
                          style: TextStyle(fontSize: 11, height: 1.4, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: .70)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _premiumAccountButton(context, user),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _premiumChip(Icons.contrast_rounded, l10n.tr('অ্যামোলেড', 'AMOLED')),
                  _premiumChip(Icons.palette_outlined, l10n.tr('প্রিমিয়াম থিম', 'Premium Themes')),
                  _premiumChip(Icons.headphones_outlined, l10n.tr('তেলাওয়াত', 'Recitations')),
                  _premiumChip(Icons.cloud_outlined, l10n.tr('ক্লাউড সিঙ্ক', 'Cloud Sync')),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (premium.isPremium) {
                      _showPremiumStatus(context, premium, isEnglish);
                    } else {
                      premium.activatePremium();
                    }
                  },
                  icon: Icon(premium.isPremium ? Icons.settings_rounded : Icons.auto_awesome_rounded, size: 18),
                  label: Text(premium.isPremium
                      ? (l10n.tr('প্রিমিয়াম পরিচালনা করুন', 'Manage Premium'))
                      : (l10n.tr('প্রিমিয়াম দেখুন', 'Explore Premium'))),
                ),
              ),
            ],
          ),
        );
      },
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
          Text(title, style: const TextStyle(color: AppColors.seaBlue, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _premiumAccountButton(BuildContext context, User? user) {
    final theme = Theme.of(context);
    final photoUrl = user?.photoURL?.trim();
    final hasPhoto = user != null && photoUrl != null && photoUrl.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleProfileTap(context, user),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.seaBlue.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.seaBlue.withValues(alpha: .12)),
          ),
          child: hasPhoto
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.network(
                    photoUrl!,
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => Icon(Icons.person_rounded, color: theme.colorScheme.primary, size: 22),
                  ),
                )
              : Icon(
                  user != null ? Icons.person_rounded : Icons.person_outline_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
        ),
      ),
    );
  }

  Future<void> _handleProfileTap(BuildContext context, User? user) async {
    if (user == null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const GoogleLoginScreen()),
      );
      return;
    }
    await _openAccount(context, user);
  }

  Future<void> _openAccount(BuildContext context, User user) async {
    final l10n = AppLocalizations.of(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final photoUrl = user.photoURL?.trim();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: .10),
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null || photoUrl.isEmpty ? Icon(Icons.account_circle_rounded, size: 48, color: theme.colorScheme.primary) : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user.displayName?.trim().isNotEmpty == true ? user.displayName! : (isEnglish ? 'NurVerse User' : 'নূরভার্স ব্যবহারকারী'),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                if (user.email?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(user.email!, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor), textAlign: TextAlign.center),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.of(sheetContext).pop();
                      await AuthService.instance.signOut();
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(isEnglish ? 'Logout' : 'লগআউট'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPremiumStatus(BuildContext context, PremiumProvider premium, bool isEnglish) async {
    final l10n = AppLocalizations.of(context);
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEnglish ? 'NurVerse Premium' : 'নূরভার্স প্রিমিয়াম'),
        content: Text(isEnglish ? 'Premium is active.' : 'প্রিমিয়াম সক্রিয় আছে।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(isEnglish ? 'Done' : 'ঠিক আছে')),
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
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.72))),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, height: 1.35, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.62))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.38)),
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
    if (settings.isAmoledMode) return settings.isEnglish ? 'AMOLED Black' : 'অ্যামোলেড কালো';
    switch (settings.themeMode) {
      case ThemeMode.light:
        return settings.isEnglish ? 'Light Mode' : 'লাইট মোড';
      case ThemeMode.dark:
        return settings.isEnglish ? 'Dark Mode' : 'ডার্ক মোড';
      case ThemeMode.system:
        return settings.isEnglish ? 'System Default' : 'সিস্টেম অনুযায়ী';
    }
  }

  String _textSizeLabel(int level, bool isEnglish) {
    switch (level) {
      case 0:
        return isEnglish ? 'Small' : 'ছোট';
      case 2:
        return isEnglish ? 'Large' : 'বড়';
      case 3:
        return isEnglish ? 'Very Large' : 'খুব বড়';
      default:
        return isEnglish ? 'Normal' : 'স্বাভাবিক';
    }
  }

  String _adjustmentLabel(SettingsProvider settings, bool isEnglish) {
    final active = settings.prayerAdjustments.entries.where((entry) => entry.value != 0).toList();
    if (active.isEmpty) return isEnglish ? 'No adjustments' : 'কোনো সমন্বয় নেই';
    final entry = active.first;
    final sign = entry.value > 0 ? '+' : '';
    final prayer = _prayerLabel(entry.key, isEnglish);
    return '$prayer: $sign${entry.value} ${isEnglish ? 'min' : 'মিনিট'}';
  }

  String _dateLabel(SettingsProvider settings, bool isEnglish) {
    switch (settings.dateDisplayPreference) {
      case 'hijri':
        return isEnglish ? 'Hijri only' : 'শুধু হিজরি';
      case 'gregorian':
        return isEnglish ? 'Gregorian only' : 'শুধু গ্রেগরিয়ান';
      default:
        return isEnglish ? 'Both dates' : 'উভয় তারিখ';
    }
  }

  String _choiceLabel(String option, bool isEnglish) {
    if (isEnglish) {
      if (option == 'bn') return 'Bangla';
      if (option == 'en') return 'English';
      if (option == 'ar') return 'Arabic';
      return option;
    }
    const labels = <String, String>{
      'system': 'সিস্টেম অনুযায়ী',
      'light': 'লাইট মোড',
      'dark': 'ডার্ক মোড',
      'amoled': 'অ্যামোলেড কালো',
      'bn': 'বাংলা',
      'en': 'ইংরেজি',
      'Bangla': 'বাংলা',
      'English': 'ইংরেজি',
      'Default': 'ডিফল্ট',
      'hijri': 'হিজরি',
      'gregorian': 'গ্রেগরিয়ান',
      'both': 'উভয় তারিখ',
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
    };
    return labels[option] ?? option;
  }

  String _prayerLabel(String prayer, bool isEnglish) {
    if (isEnglish) return prayer;
    const labels = <String, String>{
      'Fajr': 'ফজর',
      'Dhuhr': 'জোহর',
      'Asr': 'আসর',
      'Maghrib': 'মাগরিব',
      'Isha': 'এশা',
    };
    return labels[prayer] ?? prayer;
  }

  String _calculationLabel(String method, bool isEnglish) => _choiceLabel(method, isEnglish);

  String _madhabLabel(String madhab, bool isEnglish) => _choiceLabel(madhab, isEnglish);

  String _quranTranslationLabel(String translation, bool isEnglish) => _choiceLabel(translation, isEnglish);

  Future<void> _showChoiceSheet(BuildContext context, String title, List<String> options, Future<void> Function(String) onSelected, {String? selectedValue}) async {
    final l10n = AppLocalizations.of(context);
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final isEnglish = languageCode == 'en';
    final isArabic = languageCode == 'ar';
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                title,
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            ...options.map(
              (option) => ListTile(
                title: Text(
                  options.length == 3 && options.contains('bn') && options.contains('en') && options.contains('ar')
                      ? (isEnglish
                          ? ({'bn': 'Bangla', 'en': 'English', 'ar': 'Arabic'}[option] ?? option)
                          : (isArabic
                              ? ({'bn': 'البنغالية', 'en': 'الإنجليزية', 'ar': 'العربية'}[option] ?? option)
                              : ({'bn': 'বাংলা', 'en': 'ইংরেজি', 'ar': 'আরবি'}[option] ?? option)))
                      : _choiceLabel(option, isEnglish),
                ),
                trailing: option == selectedValue
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.seaBlue)
                    : null,
                onTap: () async {
                  await onSelected(option);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showTextSizeSheet(BuildContext context, TextScaleProvider provider, bool isEnglish) async {
    final l10n = AppLocalizations.of(context);
    final l10n = AppLocalizations.of(context);
    final labels = isEnglish ? const ['Small', 'Normal', 'Large', 'Very Large'] : const ['ছোট', 'স্বাভাবিক', 'বড়', 'খুব বড়'];
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: const EdgeInsets.all(18), child: Text(isEnglish ? 'App Text Size' : 'অ্যাপের লেখা', style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
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

  Future<void> _showAdjustmentDialog(BuildContext context, SettingsProvider settings) async {
    final l10n = AppLocalizations.of(context);
    final l10n = AppLocalizations.of(context);
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
                  title: Text(_prayerLabel(prayer, settings.isEnglish)),
                  subtitle: Text('${settings.prayerAdjustments[prayer] ?? 0} ${settings.isEnglish ? 'min' : 'মিনিট'}'),
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

  Future<void> _showJamaatDialog(BuildContext context, SettingsProvider settings) async {
    final l10n = AppLocalizations.of(context);
    final l10n = AppLocalizations.of(context);
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
                      decoration: InputDecoration(labelText: _prayerLabel(prayer, settings.isEnglish)),
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

  Future<void> _showQuranFontSheet(BuildContext context, SettingsProvider settings) async {
    final l10n = AppLocalizations.of(context);
    final l10n = AppLocalizations.of(context);
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

  Future<void> _showDailyContentSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Consumer<SettingsProvider>(
          builder: (context, current, _) => Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _switchTile(context, Icons.menu_book_outlined, current.isEnglish ? 'Daily Ayah' : 'দৈনিক আয়াত', '', current.showDailyAyah, (v) => current.setDailyContentPreferences(ayah: v)),
                _switchTile(context, Icons.auto_stories_outlined, current.isEnglish ? 'Daily Hadith' : 'দৈনিক হাদিস', '', current.showDailyHadith, (v) => current.setDailyContentPreferences(hadith: v)),
                _switchTile(context, Icons.volunteer_activism_outlined, current.isEnglish ? 'Daily Dua' : 'দৈনিক দোয়া', '', current.showDailyDua, (v) => current.setDailyContentPreferences(dua: v)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showResetDialog(BuildContext context, SettingsProvider settings) async {
    final l10n = AppLocalizations.of(context);
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(settings.isEnglish ? 'Reset settings?' : 'সেটিংস রিসেট করবেন?'),
        content: Text(settings.isEnglish ? 'All saved preferences will return to their default values.' : 'সব সংরক্ষিত সেটিংস ডিফল্ট অবস্থায় ফিরে যাবে।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(settings.isEnglish ? 'Cancel' : 'বাতিল')),
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
