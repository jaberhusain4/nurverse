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

class SettingsHubScreenV4 extends StatelessWidget {
  const SettingsHubScreenV4({super.key});

  static const Map<String, String> _ar = {
    'Settings': 'Ø§Ù„Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª',
    'Personalization': 'Ø§Ù„ØªØ®ØµÙŠØµ',
    'Home Screen': 'Ø§Ù„Ø´Ø§Ø´Ø© Ø§Ù„Ø±Ø¦ÙŠØ³ÙŠØ©',
    'Choose Simple or Informative Home':
        'Ø§Ø®ØªØ± Ø§Ù„ØµÙØ­Ø© Ø§Ù„Ø±Ø¦ÙŠØ³ÙŠØ© Ø§Ù„Ø¨Ø³ÙŠØ·Ø© Ø£Ùˆ Ø§Ù„ØªÙØµÙŠÙ„ÙŠØ©',
    'Appearance': 'Ø§Ù„Ù…Ø¸Ù‡Ø±',
    'Theme': 'Ø§Ù„Ø³Ù…Ø©',
    'Language': 'Ø§Ù„Ù„ØºØ©',
    'English': 'Ø§Ù„Ø¥Ù†Ø¬Ù„ÙŠØ²ÙŠØ©',
    'Bangla': 'Ø§Ù„Ø¨Ù†ØºØ§Ù„ÙŠØ©',
    'Arabic': 'Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©',
    'App Text Size': 'Ø­Ø¬Ù… Ù†Øµ Ø§Ù„ØªØ·Ø¨ÙŠÙ‚',
    'Show seconds': 'Ø¥Ø¸Ù‡Ø§Ø± Ø§Ù„Ø«ÙˆØ§Ù†ÙŠ',
    'Show seconds where supported':
        'Ø¥Ø¸Ù‡Ø§Ø± Ø§Ù„Ø«ÙˆØ§Ù†ÙŠ Ø­ÙŠØ«Ù…Ø§ ÙƒØ§Ù†Øª Ù…Ø¯Ø¹ÙˆÙ…Ø©',
    'Vibration': 'Ø§Ù„Ø§Ù‡ØªØ²Ø§Ø²',
    'Allow supported haptic feedback':
        'Ø§Ù„Ø³Ù…Ø§Ø­ Ø¨Ø§Ù„ØªØºØ°ÙŠØ© Ø§Ù„Ù„Ù…Ø³ÙŠØ© Ø§Ù„Ù…Ø¯Ø¹ÙˆÙ…Ø©',
    'Prayer & Adhan': 'Ø§Ù„ØµÙ„Ø§Ø© ÙˆØ§Ù„Ø£Ø°Ø§Ù†',
    'Prayer Calculation': 'Ø­Ø³Ø§Ø¨ Ø£ÙˆÙ‚Ø§Øª Ø§Ù„ØµÙ„Ø§Ø©',
    'Madhhab': 'Ø§Ù„Ù…Ø°Ù‡Ø¨',
    'Adhan Notifications': 'Ø¥Ø´Ø¹Ø§Ø±Ø§Øª Ø§Ù„Ø£Ø°Ø§Ù†',
    'Enable prayer-time notifications':
        'ØªÙØ¹ÙŠÙ„ Ø¥Ø´Ø¹Ø§Ø±Ø§Øª Ø£ÙˆÙ‚Ø§Øª Ø§Ù„ØµÙ„Ø§Ø©',
    'Prayer Adjustments': 'ØªØ¹Ø¯ÙŠÙ„Ø§Øª Ø£ÙˆÙ‚Ø§Øª Ø§Ù„ØµÙ„Ø§Ø©',
    'Jamaat Times': 'Ø£ÙˆÙ‚Ø§Øª Ø§Ù„Ø¬Ù…Ø§Ø¹Ø©',
    'Set local Jamaat times':
        'ØªØ¹ÙŠÙŠÙ† Ø£ÙˆÙ‚Ø§Øª Ø§Ù„Ø¬Ù…Ø§Ø¹Ø© Ø§Ù„Ù…Ø­Ù„ÙŠØ©',
    'Quran': 'Ø§Ù„Ù‚Ø±Ø¢Ù†',
    'Quran Reading': 'Ù‚Ø±Ø§Ø¡Ø© Ø§Ù„Ù‚Ø±Ø¢Ù†',
    'Translation': 'Ø§Ù„ØªØ±Ø¬Ù…Ø©',
    'Arabic Font': 'Ø§Ù„Ø®Ø· Ø§Ù„Ø¹Ø±Ø¨ÙŠ',
    'Auto-play next': 'Ø§Ù„ØªØ´ØºÙŠÙ„ Ø§Ù„ØªÙ„Ù‚Ø§Ø¦ÙŠ Ø§Ù„ØªØ§Ù„ÙŠ',
    'Continue with the next supported audio item':
        'Ø§Ù„Ù…ØªØ§Ø¨Ø¹Ø© Ù…Ø¹ Ø§Ù„Ø¹Ù†ØµØ± Ø§Ù„ØµÙˆØªÙŠ Ø§Ù„ØªØ§Ù„ÙŠ Ø§Ù„Ù…Ø¯Ø¹ÙˆÙ…',
    'Wi-Fi only downloads': 'Ø§Ù„ØªÙ†Ø²ÙŠÙ„ Ø¹Ø¨Ø± Wi-Fi ÙÙ‚Ø·',
    'Prefer Wi-Fi for downloadable Quran resources':
        'ØªÙØ¶ÙŠÙ„ Wi-Fi Ù„Ù…ÙˆØ§Ø±Ø¯ Ø§Ù„Ù‚Ø±Ø¢Ù† Ø§Ù„Ù‚Ø§Ø¨Ù„Ø© Ù„Ù„ØªÙ†Ø²ÙŠÙ„',
    'Worship & Dates': 'Ø§Ù„Ø¹Ø¨Ø§Ø¯Ø© ÙˆØ§Ù„ØªÙˆØ§Ø±ÙŠØ®',
    'Daily Content': 'Ø§Ù„Ù…Ø­ØªÙˆÙ‰ Ø§Ù„ÙŠÙˆÙ…ÙŠ',
    'Ayah, Hadith and Dua visibility':
        'Ø¥Ø¸Ù‡Ø§Ø± Ø§Ù„Ø¢ÙŠØ© ÙˆØ§Ù„Ø­Ø¯ÙŠØ« ÙˆØ§Ù„Ø¯Ø¹Ø§Ø¡',
    'Date Preferences': 'ØªÙØ¶ÙŠÙ„Ø§Øª Ø§Ù„ØªØ§Ø±ÙŠØ®',
    'Data & App': 'Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª ÙˆØ§Ù„ØªØ·Ø¨ÙŠÙ‚',
    'Reset Settings': 'Ø¥Ø¹Ø§Ø¯Ø© Ø¶Ø¨Ø· Ø§Ù„Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª',
    'Restore configurable preferences':
        'Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„ØªÙØ¶ÙŠÙ„Ø§Øª Ø§Ù„Ù‚Ø§Ø¨Ù„Ø© Ù„Ù„ØªÙƒÙˆÙŠÙ† Ø¥Ù„Ù‰ Ø§Ù„ÙˆØ¶Ø¹ Ø§Ù„Ø§ÙØªØ±Ø§Ø¶ÙŠ',
    'About NurVerse': 'Ø­ÙˆÙ„ Ù†ÙˆØ±ÙÙŠØ±Ø³',
    'Open Source Licenses': 'ØªØ±Ø§Ø®ÙŠØµ Ø§Ù„Ù…ØµØ§Ø¯Ø± Ø§Ù„Ù…ÙØªÙˆØ­Ø©',
    'Libraries used by NurVerse':
        'Ø§Ù„Ù…ÙƒØªØ¨Ø§Øª Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…Ø© ÙÙŠ Ù†ÙˆØ±ÙÙŠØ±Ø³',
    'NurVerse': 'Ù†ÙˆØ±ÙÙŠØ±Ø³',
    'NurVerse Premium': 'Ù†ÙˆØ±ÙÙŠØ±Ø³ Ø¨Ø±ÙŠÙ…ÙŠÙˆÙ…',
    'ACTIVE': 'Ù†Ø´Ø·',
    'Your premium experience is active':
        'ØªØ¬Ø±Ø¨Ø© Ø¨Ø±ÙŠÙ…ÙŠÙˆÙ… Ø§Ù„Ø®Ø§ØµØ© Ø¨Ùƒ Ù…ÙØ¹Ù„Ø©',
    'Unlock a richer, calmer NurVerse':
        'Ø§ÙƒØªØ´Ù ØªØ¬Ø±Ø¨Ø© Ù†ÙˆØ±ÙÙŠØ±Ø³ Ø£ÙƒØ«Ø± Ø«Ø±Ø§Ø¡Ù‹ ÙˆÙ‡Ø¯ÙˆØ¡Ù‹Ø§',
    'AMOLED': 'AMOLED',
    'Premium Themes': 'Ø³Ù…Ø§Øª Ø¨Ø±ÙŠÙ…ÙŠÙˆÙ…',
    'Recitations': 'ØªÙ„Ø§ÙˆØ§Øª',
    'Cloud Sync': 'Ù…Ø²Ø§Ù…Ù†Ø© Ø³Ø­Ø§Ø¨ÙŠØ©',
    'Manage Premium': 'Ø¥Ø¯Ø§Ø±Ø© Ø¨Ø±ÙŠÙ…ÙŠÙˆÙ…',
    'Explore Premium': 'Ø§Ø³ØªÙƒØ´Ø§Ù Ø¨Ø±ÙŠÙ…ÙŠÙˆÙ…',
    'NurVerse User': 'Ù…Ø³ØªØ®Ø¯Ù… Ù†ÙˆØ±ÙÙŠØ±Ø³',
    'Logout': 'ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø®Ø±ÙˆØ¬',
    'Premium is active.': 'Ø¨Ø±ÙŠÙ…ÙŠÙˆÙ… Ù…ÙØ¹Ù‘Ù„.',
    'Done': 'ØªÙ…',
    'Light Mode': 'Ø§Ù„ÙˆØ¶Ø¹ Ø§Ù„ÙØ§ØªØ­',
    'Dark Mode': 'Ø§Ù„ÙˆØ¶Ø¹ Ø§Ù„Ø¯Ø§ÙƒÙ†',
    'System Default': 'Ø§ÙØªØ±Ø§Ø¶ÙŠ Ø§Ù„Ù†Ø¸Ø§Ù…',
    'AMOLED Black': 'Ø£Ø³ÙˆØ¯ AMOLED',
    'Small': 'ØµØºÙŠØ±',
    'Normal': 'Ø¹Ø§Ø¯ÙŠ',
    'Large': 'ÙƒØ¨ÙŠØ±',
    'Very Large': 'ÙƒØ¨ÙŠØ± Ø¬Ø¯Ù‹Ø§',
    'No adjustments': 'Ù„Ø§ ØªÙˆØ¬Ø¯ ØªØ¹Ø¯ÙŠÙ„Ø§Øª',
    'min': 'Ø¯',
    'Hijri only': 'Ù‡Ø¬Ø±ÙŠ ÙÙ‚Ø·',
    'Gregorian only': 'Ù…ÙŠÙ„Ø§Ø¯ÙŠ ÙÙ‚Ø·',
    'Both dates': 'ÙƒÙ„Ø§ Ø§Ù„ØªØ§Ø±ÙŠØ®ÙŠÙ†',
    'system': 'Ø§ÙØªØ±Ø§Ø¶ÙŠ Ø§Ù„Ù†Ø¸Ø§Ù…',
    'light': 'Ø§Ù„ÙˆØ¶Ø¹ Ø§Ù„ÙØ§ØªØ­',
    'dark': 'Ø§Ù„ÙˆØ¶Ø¹ Ø§Ù„Ø¯Ø§ÙƒÙ†',
    'amoled': 'Ø£Ø³ÙˆØ¯ AMOLED',
    'Default': 'Ø§ÙØªØ±Ø§Ø¶ÙŠ',
    'hijri': 'Ù‡Ø¬Ø±ÙŠ',
    'gregorian': 'Ù…ÙŠÙ„Ø§Ø¯ÙŠ',
    'both': 'ÙƒÙ„Ø§Ù‡Ù…Ø§',
    'Karachi': 'ÙƒØ±Ø§ØªØ´ÙŠ',
    'Muslim World League': 'Ø±Ø§Ø¨Ø·Ø© Ø§Ù„Ø¹Ø§Ù„Ù… Ø§Ù„Ø¥Ø³Ù„Ø§Ù…ÙŠ',
    'Egyptian': 'Ø§Ù„Ù…ØµØ±ÙŠ',
    'Umm Al Qura': 'Ø£Ù… Ø§Ù„Ù‚Ø±Ù‰',
    'Dubai': 'Ø¯Ø¨ÙŠ',
    'Qatar': 'Ù‚Ø·Ø±',
    'Kuwait': 'Ø§Ù„ÙƒÙˆÙŠØª',
    'Singapore': 'Ø³Ù†ØºØ§ÙÙˆØ±Ø©',
    'North America': 'Ø£Ù…Ø±ÙŠÙƒØ§ Ø§Ù„Ø´Ù…Ø§Ù„ÙŠØ©',
    'Moonsighting Committee': 'Ù„Ø¬Ù†Ø© Ø±Ø¤ÙŠØ© Ø§Ù„Ù‡Ù„Ø§Ù„',
    'Hanafi': 'Ø­Ù†ÙÙŠ',
    'Shafi': 'Ø´Ø§ÙØ¹ÙŠ',
    'Fajr': 'Ø§Ù„ÙØ¬Ø±',
    'Dhuhr': 'Ø§Ù„Ø¸Ù‡Ø±',
    'Asr': 'Ø§Ù„Ø¹ØµØ±',
    'Maghrib': 'Ø§Ù„Ù…ØºØ±Ø¨',
    'Isha': 'Ø§Ù„Ø¹Ø´Ø§Ø¡',
    'Cancel': 'Ø¥Ù„ØºØ§Ø¡',
    'Save': 'Ø­ÙØ¸',
    'Reset': 'Ø¥Ø¹Ø§Ø¯Ø© Ø¶Ø¨Ø·',
    'Premium': 'Ø¨Ø±ÙŠÙ…ÙŠÙˆÙ…',
    'Daily Ayah': 'Ø¢ÙŠØ© Ø§Ù„ÙŠÙˆÙ…',
    'Daily Hadith': 'Ø­Ø¯ÙŠØ« Ø§Ù„ÙŠÙˆÙ…',
    'Daily Dua': 'Ø¯Ø¹Ø§Ø¡ Ø§Ù„ÙŠÙˆÙ…',
    'Quran Arabic': 'Ø¹Ø±Ø¨ÙŠ Ø§Ù„Ù‚Ø±Ø¢Ù†',
  };

  String _t(String languageCode, String bn, String en, [String? ar]) {
    if (languageCode == 'ar') return ar ?? _ar[en] ?? en;
    if (languageCode == 'en') return en;
    return bn;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final textScale = context.watch<TextScaleProvider>();
    final premium = context.watch<PremiumProvider>();
    final languageCode = settings.languageCode;
    final isEnglish = languageCode == 'en';
    final isArabic = languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
          title: Text(isEnglish
              ? 'Settings'
              : isArabic
                  ? 'Ø§Ù„Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª'
                  : 'à¦¸à§‡à¦Ÿà¦¿à¦‚à¦¸')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _buildPremiumHero(context, settings, premium),
          const SizedBox(height: 14),
          _section(
              context,
              _t(languageCode, 'à¦¬à§à¦¯à¦•à§à¦¤à¦¿à¦—à¦¤à¦•à¦°à¦£',
                  'Personalization'),
              Icons.tune_rounded,
              [
                _tile(
                  context,
                  Icons.dashboard_customize_outlined,
                  _t(languageCode, 'à¦¹à§‹à¦® à¦¸à§à¦•à§à¦°à¦¿à¦¨',
                      'Home Screen'),
                  _t(
                      languageCode,
                      'à¦¸à¦¹à¦œ à¦¬à¦¾ à¦¬à¦¿à¦¸à§à¦¤à¦¾à¦°à¦¿à¦¤ à¦¹à§‹à¦® à¦¸à§à¦•à§à¦°à¦¿à¦¨ à¦¬à§‡à¦›à§‡ à¦¨à¦¿à¦¨',
                      'Choose Simple or Informative Home'),
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const HomeModeSettingsScreen()),
                    );
                  },
                ),
              ]),
          const SizedBox(height: 20),
          _section(
              context,
              _t(languageCode, 'à¦…à§à¦¯à¦¾à¦ªà§‡à¦° à¦šà§‡à¦¹à¦¾à¦°à¦¾',
                  'Appearance'),
              Icons.palette_outlined,
              [
                _tile(
                  context,
                  Icons.palette_outlined,
                  _t(languageCode, 'à¦¥à¦¿à¦®', 'Theme'),
                  _themeLabel(settings),
                  () => _showChoiceSheet(
                    context,
                    _t(languageCode, 'à¦¥à¦¿à¦®', 'Theme'),
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
                    selectedValue: settings.isAmoledMode
                        ? 'amoled'
                        : settings.themeMode.name,
                  ),
                ),
                _divider(),
                _tile(
                  context,
                  Icons.language_rounded,
                  _t(languageCode, 'à¦­à¦¾à¦·à¦¾', 'Language', 'Ø§Ù„Ù„ØºØ©'),
                  _t(languageCode, 'à¦¬à¦¾à¦‚à¦²à¦¾', 'English',
                      'Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©'),
                  () => _showChoiceSheet(
                    context,
                    _t(languageCode, 'à¦­à¦¾à¦·à¦¾', 'Language', 'Ø§Ù„Ù„ØºØ©'),
                    const ['bn', 'en', 'ar'],
                    settings.setLanguage,
                    selectedValue: settings.languageCode,
                  ),
                ),
                _divider(),
                _tile(
                  context,
                  Icons.text_fields_rounded,
                  _t(languageCode, 'à¦…à§à¦¯à¦¾à¦ªà§‡à¦° à¦²à§‡à¦–à¦¾',
                      'App Text Size'),
                  _textSizeLabel(textScale.level, languageCode),
                  () => _showTextSizeSheet(context, textScale, isEnglish),
                ),
                _divider(),
                _switchTile(
                  context,
                  Icons.timer_outlined,
                  _t(languageCode, 'à¦¸à§‡à¦•à§‡à¦¨à§à¦¡ à¦¦à§‡à¦–à¦¾à¦¨',
                      'Show seconds'),
                  _t(
                      languageCode,
                      'à¦¯à§‡à¦–à¦¾à¦¨à§‡ à¦¸à¦®à¦°à§à¦¥à¦¿à¦¤ à¦¸à§‡à¦–à¦¾à¦¨à§‡ à¦¸à§‡à¦•à§‡à¦¨à§à¦¡ à¦¦à§‡à¦–à¦¾à¦¬à§‡',
                      'Show seconds where supported'),
                  settings.showSeconds,
                  settings.toggleShowSeconds,
                ),
                _divider(),
                _switchTile(
                  context,
                  Icons.vibration_rounded,
                  _t(languageCode, 'à¦­à¦¾à¦‡à¦¬à§à¦°à§‡à¦¶à¦¨', 'Vibration'),
                  _t(
                      languageCode,
                      'à¦¸à¦®à¦°à§à¦¥à¦¿à¦¤ à¦…à§à¦¯à¦¾à¦•à¦¶à¦¨à§‡ à¦¹à§à¦¯à¦¾à¦ªà¦Ÿà¦¿à¦• à¦«à¦¿à¦¡à¦¬à§à¦¯à¦¾à¦• à¦šà¦¾à¦²à§ à¦°à¦¾à¦–à§à¦¨',
                      'Allow supported haptic feedback'),
                  settings.vibrationEnabled,
                  settings.toggleVibration,
                ),
              ]),
          const SizedBox(height: 20),
          _section(
              context,
              _t(languageCode, 'à¦¸à¦¾à¦²à¦¾à¦¤ à¦“ à¦†à¦œà¦¾à¦¨',
                  'Prayer & Adhan'),
              Icons.mosque_outlined,
              [
                _tile(
                  context,
                  Icons.calculate_outlined,
                  _t(
                      languageCode,
                      'à¦¸à¦¾à¦²à¦¾à¦¤à§‡à¦° à¦¹à¦¿à¦¸à¦¾à¦¬ à¦ªà¦¦à§à¦§à¦¤à¦¿',
                      'Prayer Calculation'),
                  _calculationLabel(settings.calculationMethod, languageCode),
                  () => _showChoiceSheet(
                    context,
                    _t(
                        languageCode,
                        'à¦¸à¦¾à¦²à¦¾à¦¤à§‡à¦° à¦¹à¦¿à¦¸à¦¾à¦¬ à¦ªà¦¦à§à¦§à¦¤à¦¿',
                        'Prayer Calculation'),
                    SettingsProvider.calculationMethods,
                    settings.setCalculationMethod,
                    selectedValue: settings.calculationMethod,
                  ),
                ),
                _divider(),
                _tile(
                  context,
                  Icons.mosque_outlined,
                  _t(languageCode, 'à¦®à¦¾à¦¯à¦¹à¦¾à¦¬', 'Madhhab'),
                  _madhabLabel(settings.madhab, languageCode),
                  () => _showChoiceSheet(
                    context,
                    _t(languageCode, 'à¦®à¦¾à¦¯à¦¹à¦¾à¦¬', 'Madhhab'),
                    SettingsProvider.madhabs,
                    settings.setMadhhab,
                    selectedValue: settings.madhhab,
                  ),
                ),
                _divider(),
                _switchTile(
                  context,
                  Icons.notifications_active_outlined,
                  _t(
                      languageCode,
                      'à¦†à¦œà¦¾à¦¨ à¦¨à§‹à¦Ÿà¦¿à¦«à¦¿à¦•à§‡à¦¶à¦¨',
                      'Adhan Notifications'),
                  _t(
                      languageCode,
                      'à¦¸à¦¾à¦²à¦¾à¦¤à§‡à¦° à¦¸à¦®à§Ÿà§‡à¦° à¦¨à§‹à¦Ÿà¦¿à¦«à¦¿à¦•à§‡à¦¶à¦¨ à¦šà¦¾à¦²à§ à¦°à¦¾à¦–à§à¦¨',
                      'Enable prayer-time notifications'),
                  settings.isAdhanNotificationEnabled,
                  settings.toggleAdhanNotification,
                ),
                _divider(),
                _tile(
                  context,
                  Icons.tune_rounded,
                  _t(
                      languageCode,
                      'à¦¸à¦¾à¦²à¦¾à¦¤à§‡à¦° à¦¸à¦®à§Ÿ à¦¸à¦®à¦¨à§à¦¬à§Ÿ',
                      'Prayer Adjustments'),
                  _adjustmentLabel(settings, languageCode),
                  () => _showAdjustmentDialog(context, settings),
                ),
                _divider(),
                _tile(
                  context,
                  Icons.access_time_rounded,
                  _t(languageCode, 'à¦œà¦¾à¦®à¦¾à¦¤à§‡à¦° à¦¸à¦®à§Ÿ',
                      'Jamaat Times'),
                  _t(
                      languageCode,
                      'à¦¨à¦¿à¦œà§‡à¦° à¦à¦²à¦¾à¦•à¦¾à¦° à¦œà¦¾à¦®à¦¾à¦¤à§‡à¦° à¦¸à¦®à§Ÿ à¦¸à§‡à¦Ÿ à¦•à¦°à§à¦¨',
                      'Set local Jamaat times'),
                  () => _showJamaatDialog(context, settings),
                ),
              ]),
          const SizedBox(height: 20),
          _section(context, _t(languageCode, 'à¦•à§à¦°à¦†à¦¨', 'Quran'),
              Icons.menu_book_outlined, [
            _tile(
              context,
              Icons.format_size_rounded,
              _t(
                  languageCode,
                  'à¦•à§à¦°à¦†à¦¨ à¦ªà¦¡à¦¼à¦¾à¦° à¦¸à§‡à¦Ÿà¦¿à¦‚à¦¸',
                  'Quran Reading'),
              '${settings.quranFontSize.round()} / ${settings.translationFontSize.round()}',
              () => _showQuranFontSheet(context, settings),
            ),
            _divider(),
            _tile(
              context,
              Icons.translate_rounded,
              _t(languageCode, 'à¦…à¦¨à§à¦¬à¦¾à¦¦', 'Translation'),
              _quranTranslationLabel(settings.quranTranslation, languageCode),
              () => _showChoiceSheet(
                context,
                _t(languageCode, 'à¦…à¦¨à§à¦¬à¦¾à¦¦', 'Translation'),
                const ['Bangla', 'English'],
                settings.setQuranTranslation,
              ),
            ),
            _divider(),
            _tile(
              context,
              Icons.font_download_outlined,
              _t(languageCode, 'à¦†à¦°à¦¬à¦¿ à¦«à¦¨à§à¦Ÿ', 'Arabic Font'),
              settings.quranArabicFont == 'Default'
                  ? _t(languageCode, 'à¦¡à¦¿à¦«à¦²à§à¦Ÿ', 'Default')
                  : settings.quranArabicFont,
              () => _showChoiceSheet(
                context,
                _t(languageCode, 'à¦†à¦°à¦¬à¦¿ à¦«à¦¨à§à¦Ÿ', 'Arabic Font'),
                const ['Default', 'Amiri', 'Scheherazade'],
                settings.setQuranArabicFont,
              ),
            ),
            _divider(),
            _switchTile(
              context,
              Icons.skip_next_rounded,
              _t(
                  languageCode,
                  'à¦ªà¦°à§‡à¦°à¦Ÿà¦¿ à¦¸à§à¦¬à¦¯à¦¼à¦‚à¦•à§à¦°à¦¿à¦¯à¦¼ à¦šà¦¾à¦²à¦¾à¦¨',
                  'Auto-play next'),
              _t(
                  languageCode,
                  'à¦¸à¦®à¦°à§à¦¥à¦¿à¦¤ à¦…à¦¡à¦¿à¦“à¦¤à§‡ à¦ªà¦°à§‡à¦°à¦Ÿà¦¿ à¦¸à§à¦¬à¦¯à¦¼à¦‚à¦•à§à¦°à¦¿à¦¯à¦¼à¦­à¦¾à¦¬à§‡ à¦šà¦¾à¦²à¦¾à¦¬à§‡',
                  'Continue with the next supported audio item'),
              settings.autoPlayNext,
              settings.toggleAutoPlayNext,
            ),
            _divider(),
            _switchTile(
              context,
              Icons.wifi_outlined,
              _t(
                  languageCode,
                  'à¦¶à§à¦§à§ à¦“à¦¯à¦¼à¦¾à¦‡-à¦«à¦¾à¦‡ à¦¡à¦¾à¦‰à¦¨à¦²à§‹à¦¡',
                  'Wi-Fi only downloads'),
              _t(
                  languageCode,
                  'à¦¡à¦¾à¦‰à¦¨à¦²à§‹à¦¡à¦¯à§‹à¦—à§à¦¯ à¦•à§à¦°à¦†à¦¨ à¦°à¦¿à¦¸à§‹à¦°à§à¦¸à§‡ à¦“à¦¯à¦¼à¦¾à¦‡-à¦«à¦¾à¦‡ à¦…à¦—à§à¦°à¦¾à¦§à¦¿à¦•à¦¾à¦° à¦¦à¦¿à¦¨',
                  'Prefer Wi-Fi for downloadable Quran resources'),
              settings.downloadWifiOnly,
              settings.toggleDownloadWifiOnly,
            ),
          ]),
          const SizedBox(height: 20),
          _section(
              context,
              _t(languageCode, 'à¦‡à¦¬à¦¾à¦¦à¦¤ à¦“ à¦¤à¦¾à¦°à¦¿à¦–',
                  'Worship & Dates'),
              Icons.event_available_outlined,
              [
                _tile(
                  context,
                  Icons.today_outlined,
                  _t(languageCode, 'à¦¦à§ˆà¦¨à¦¿à¦• à¦•à¦¨à¦Ÿà§‡à¦¨à§à¦Ÿ',
                      'Daily Content'),
                  _t(
                      languageCode,
                      'à¦†à§Ÿà¦¾à¦¤, à¦¹à¦¾à¦¦à¦¿à¦¸ à¦“ à¦¦à§‹à§Ÿà¦¾à¦° à¦¦à§ƒà¦¶à§à¦¯à¦®à¦¾à¦¨à¦¤à¦¾',
                      'Ayah, Hadith and Dua visibility'),
                  () => _showDailyContentSheet(context),
                ),
                _divider(),
                _tile(
                  context,
                  Icons.calendar_month_outlined,
                  _t(languageCode, 'à¦¤à¦¾à¦°à¦¿à¦–à§‡à¦° à¦ªà¦›à¦¨à§à¦¦',
                      'Date Preferences'),
                  _dateLabel(settings, languageCode),
                  () => _showChoiceSheet(
                    context,
                    _t(languageCode, 'à¦¤à¦¾à¦°à¦¿à¦–à§‡à¦° à¦ªà¦›à¦¨à§à¦¦',
                        'Date Preferences'),
                    const ['hijri', 'gregorian', 'both'],
                    settings.setDateDisplayPreference,
                  ),
                ),
              ]),
          const SizedBox(height: 20),
          _section(
              context,
              _t(languageCode, 'à¦¡à§‡à¦Ÿà¦¾ à¦“ à¦…à§à¦¯à¦¾à¦ª',
                  'Data & App'),
              Icons.settings_applications_outlined,
              [
                _tile(
                  context,
                  Icons.restart_alt_rounded,
                  _t(languageCode, 'à¦¸à§‡à¦Ÿà¦¿à¦‚à¦¸ à¦°à¦¿à¦¸à§‡à¦Ÿ',
                      'Reset Settings'),
                  _t(
                      languageCode,
                      'à¦¸à¦¬ à¦•à¦¨à¦«à¦¿à¦—à¦¾à¦°à¦¯à§‹à¦—à§à¦¯ à¦¸à§‡à¦Ÿà¦¿à¦‚à¦¸ à¦¡à¦¿à¦«à¦²à§à¦Ÿà§‡ à¦«à¦¿à¦°à¦¿à§Ÿà§‡ à¦¦à¦¿à¦¨',
                      'Restore configurable preferences'),
                  () => _showResetDialog(context, settings),
                ),
                _divider(),
                _tile(
                  context,
                  Icons.info_outline_rounded,
                  _t(
                      languageCode,
                      'à¦¨à§‚à¦°à¦­à¦¾à¦°à§à¦¸ à¦¸à¦®à§à¦ªà¦°à§à¦•à§‡',
                      'About NurVerse'),
                  _t(languageCode, 'à¦¸à¦‚à¦¸à§à¦•à¦°à¦£ à§§.à§¦.à§¦',
                      'Version 1.0.0'),
                  () => showAboutDialog(
                    context: context,
                    applicationName: _t(
                        languageCode, 'à¦¨à§‚à¦°à¦­à¦¾à¦°à§à¦¸', 'NurVerse'),
                    applicationVersion: '1.0.0',
                  ),
                ),
                _divider(),
                _tile(
                  context,
                  Icons.code_rounded,
                  _t(
                      languageCode,
                      'à¦“à¦ªà§‡à¦¨ à¦¸à§‹à¦°à§à¦¸ à¦²à¦¾à¦‡à¦¸à§‡à¦¨à§à¦¸',
                      'Open Source Licenses'),
                  _t(
                      languageCode,
                      'à¦¨à§‚à¦°à¦­à¦¾à¦°à§à¦¸à§‡ à¦¬à§à¦¯à¦¬à¦¹à§ƒà¦¤ à¦²à¦¾à¦‡à¦¬à§à¦°à§‡à¦°à¦¿',
                      'Libraries used by NurVerse'),
                  () => showLicensePage(
                    context: context,
                    applicationName: _t(
                        languageCode, 'à¦¨à§‚à¦°à¦­à¦¾à¦°à§à¦¸', 'NurVerse'),
                    applicationVersion: '1.0.0',
                  ),
                ),
              ]),
        ],
      ),
    );
  }

  Widget _buildPremiumHero(BuildContext context, SettingsProvider settings,
      PremiumProvider premium) {
    final languageCode = settings.languageCode;
    final isEnglish = languageCode == 'en';
    final isArabic = languageCode == 'ar';
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
                      isActive
                          ? Icons.verified_rounded
                          : Icons.workspace_premium_rounded,
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
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(width: 7),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.seaBlue.withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                    _t(languageCode, 'à¦¸à¦•à§à¦°à¦¿à¦¯à¦¼',
                                        'ACTIVE'),
                                    style: const TextStyle(
                                        color: AppColors.seaBlue,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isActive
                              ? (_t(
                                  languageCode,
                                  'à¦†à¦ªà¦¨à¦¾à¦° à¦ªà§à¦°à¦¿à¦®à¦¿à¦¯à¦¼à¦¾à¦® à¦…à¦­à¦¿à¦œà§à¦žà¦¤à¦¾ à¦¸à¦•à§à¦°à¦¿à¦¯à¦¼',
                                  'Your premium experience is active'))
                              : (_t(
                                  languageCode,
                                  'à¦†à¦°à¦“ à¦¸à¦®à§ƒà¦¦à§à¦§ à¦“ à¦¸à§à¦¨à§à¦¦à¦° à¦¨à§‚à¦°à¦­à¦¾à¦°à§à¦¸ à¦‰à¦ªà¦­à§‹à¦— à¦•à¦°à§à¦¨',
                                  'Unlock a richer, calmer NurVerse')),
                          style: TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: .70)),
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
                  _premiumChip(
                      Icons.contrast_rounded,
                      _t(languageCode, 'à¦…à§à¦¯à¦¾à¦®à§‹à¦²à§‡à¦¡',
                          'AMOLED')),
                  _premiumChip(
                      Icons.palette_outlined,
                      _t(
                          languageCode,
                          'à¦ªà§à¦°à¦¿à¦®à¦¿à¦¯à¦¼à¦¾à¦® à¦¥à¦¿à¦®',
                          'Premium Themes')),
                  _premiumChip(
                      Icons.headphones_outlined,
                      _t(languageCode, 'à¦¤à§‡à¦²à¦¾à¦“à¦¯à¦¼à¦¾à¦¤',
                          'Recitations')),
                  _premiumChip(
                      Icons.cloud_outlined,
                      _t(languageCode, 'à¦•à§à¦²à¦¾à¦‰à¦¡ à¦¸à¦¿à¦™à§à¦•',
                          'Cloud Sync')),
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
                  icon: Icon(
                      premium.isPremium
                          ? Icons.settings_rounded
                          : Icons.auto_awesome_rounded,
                      size: 18),
                  label: Text(premium.isPremium
                      ? (_t(
                          languageCode,
                          'à¦ªà§à¦°à¦¿à¦®à¦¿à¦¯à¦¼à¦¾à¦® à¦ªà¦°à¦¿à¦šà¦¾à¦²à¦¨à¦¾ à¦•à¦°à§à¦¨',
                          'Manage Premium'))
                      : (_t(
                          languageCode,
                          'à¦ªà§à¦°à¦¿à¦®à¦¿à¦¯à¦¼à¦¾à¦® à¦¦à§‡à¦–à§à¦¨',
                          'Explore Premium'))),
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
          Text(title,
              style: const TextStyle(
                  color: AppColors.seaBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
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
                    photoUrl,
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => Icon(Icons.person_rounded,
                        color: theme.colorScheme.primary, size: 22),
                  ),
                )
              : Icon(
                  user != null
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
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
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final isEnglish = languageCode == 'en';
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
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: .10),
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Icon(Icons.account_circle_rounded,
                          size: 48, color: theme.colorScheme.primary)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user.displayName?.trim().isNotEmpty == true
                      ? user.displayName!
                      : (_t(
                          languageCode,
                          'à¦¨à§‚à¦°à¦­à¦¾à¦°à§à¦¸ à¦¬à§à¦¯à¦¬à¦¹à¦¾à¦°à¦•à¦¾à¦°à§€',
                          'NurVerse User')),
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                if (user.email?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(user.email!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: context.secondaryTextColor),
                      textAlign: TextAlign.center),
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
                    label: Text(_t(languageCode, 'à¦²à¦—à¦†à¦‰à¦Ÿ', 'Logout')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPremiumStatus(
      BuildContext context, PremiumProvider premium, bool isEnglish) async {
    final languageCode = Localizations.localeOf(context).languageCode;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('NurVerse Premium'),
        content: Text(_t(
            languageCode,
            'à¦ªà§à¦°à¦¿à¦®à¦¿à¦¯à¦¼à¦¾à¦® à¦¸à¦•à§à¦°à¦¿à¦¯à¦¼ à¦†à¦›à§‡à¥¤',
            'Premium is active.')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(_t(languageCode, 'à¦ à¦¿à¦• à¦†à¦›à§‡', 'Done'))),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, IconData icon,
      List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 9),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.seaBlue),
              const SizedBox(width: 7),
              Text(title,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.72))),
            ],
          ),
        ),
        Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            child: Column(children: children)),
      ],
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
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
                      borderRadius: BorderRadius.circular(13)),
                  child: Icon(icon, size: 21, color: AppColors.seaBlue)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 10.5,
                            height: 1.35,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.62))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Theme.of(context)
                      .iconTheme
                      .color
                      ?.withValues(alpha: 0.38)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchTile(BuildContext context, IconData icon, String title,
      String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      child: Row(
        children: [
          Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: AppColors.seaBlue.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, size: 21, color: AppColors.seaBlue)),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 10.5,
                        height: 1.35,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: .62))),
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
    if (settings.isAmoledMode)
      return _t(settings.languageCode,
          'à¦…à§à¦¯à¦¾à¦®à§‹à¦²à§‡à¦¡ à¦•à¦¾à¦²à§‹', 'AMOLED Black');
    switch (settings.themeMode) {
      case ThemeMode.light:
        return _t(
            settings.languageCode, 'à¦²à¦¾à¦‡à¦Ÿ à¦®à§‹à¦¡', 'Light Mode');
      case ThemeMode.dark:
        return _t(
            settings.languageCode, 'à¦¡à¦¾à¦°à§à¦• à¦®à§‹à¦¡', 'Dark Mode');
      case ThemeMode.system:
        return _t(settings.languageCode,
            'à¦¸à¦¿à¦¸à§à¦Ÿà§‡à¦® à¦…à¦¨à§à¦¯à¦¾à§Ÿà§€', 'System Default');
    }
  }

  String _textSizeLabel(int level, String languageCode) {
    switch (level) {
      case 0:
        return _t(languageCode, 'à¦›à§‹à¦Ÿ', 'Small');
      case 2:
        return _t(languageCode, 'à¦¬à§œ', 'Large');
      case 3:
        return _t(languageCode, 'à¦–à§à¦¬ à¦¬à§œ', 'Very Large');
      default:
        return _t(languageCode, 'à¦¸à§à¦¬à¦¾à¦­à¦¾à¦¬à¦¿à¦•', 'Normal');
    }
  }

  String _adjustmentLabel(SettingsProvider settings, String languageCode) {
    final active = settings.prayerAdjustments.entries
        .where((entry) => entry.value != 0)
        .toList();
    if (active.isEmpty)
      return _t(languageCode, 'à¦•à§‹à¦¨à§‹ à¦¸à¦®à¦¨à§à¦¬à§Ÿ à¦¨à§‡à¦‡',
          'No adjustments');
    final entry = active.first;
    final sign = entry.value > 0 ? '+' : '';
    final prayer = _prayerLabel(entry.key, languageCode);
    return '$prayer: $sign${entry.value} ${_t(languageCode, 'à¦®à¦¿à¦¨à¦¿à¦Ÿ', 'min')}';
  }

  String _dateLabel(SettingsProvider settings, String languageCode) {
    switch (settings.dateDisplayPreference) {
      case 'hijri':
        return _t(languageCode, 'à¦¶à§à¦§à§ à¦¹à¦¿à¦œà¦°à¦¿', 'Hijri only');
      case 'gregorian':
        return _t(languageCode,
            'à¦¶à§à¦§à§ à¦—à§à¦°à§‡à¦—à¦°à¦¿à¦¯à¦¼à¦¾à¦¨', 'Gregorian only');
      default:
        return _t(languageCode, 'à¦‰à¦­à§Ÿ à¦¤à¦¾à¦°à¦¿à¦–', 'Both dates');
    }
  }

  String _choiceLabel(String option, String languageCode) {
    if (languageCode == 'en') {
      if (option == 'bn') return 'Bangla';
      if (option == 'en') return 'English';
      if (option == 'ar') return 'Arabic';
      return option;
    }
    if (languageCode == 'ar') {
      return _ar[option] ?? option;
    }
    const labels = <String, String>{
      'system': 'à¦¸à¦¿à¦¸à§à¦Ÿà§‡à¦® à¦…à¦¨à§à¦¯à¦¾à§Ÿà§€',
      'light': 'à¦²à¦¾à¦‡à¦Ÿ à¦®à§‹à¦¡',
      'dark': 'à¦¡à¦¾à¦°à§à¦• à¦®à§‹à¦¡',
      'amoled': 'à¦…à§à¦¯à¦¾à¦®à§‹à¦²à§‡à¦¡ à¦•à¦¾à¦²à§‹',
      'bn': 'à¦¬à¦¾à¦‚à¦²à¦¾',
      'en': 'à¦‡à¦‚à¦°à§‡à¦œà¦¿',
      'Bangla': 'à¦¬à¦¾à¦‚à¦²à¦¾',
      'English': 'à¦‡à¦‚à¦°à§‡à¦œà¦¿',
      'Default': 'à¦¡à¦¿à¦«à¦²à§à¦Ÿ',
      'hijri': 'à¦¹à¦¿à¦œà¦°à¦¿',
      'gregorian': 'à¦—à§à¦°à§‡à¦—à¦°à¦¿à¦¯à¦¼à¦¾à¦¨',
      'both': 'à¦‰à¦­à§Ÿ à¦¤à¦¾à¦°à¦¿à¦–',
      'Karachi': 'à¦•à¦°à¦¾à¦šà¦¿',
      'Muslim World League':
          'à¦®à§à¦¸à¦²à¦¿à¦® à¦“à¦¯à¦¼à¦¾à¦°à§à¦²à§à¦¡ à¦²à§€à¦—',
      'Egyptian': 'à¦®à¦¿à¦¶à¦°à§€à¦¯à¦¼',
      'Umm Al Qura': 'à¦‰à¦®à§à¦®à§à¦² à¦•à§à¦°à¦¾',
      'Dubai': 'à¦¦à§à¦¬à¦¾à¦‡',
      'Qatar': 'à¦•à¦¾à¦¤à¦¾à¦°',
      'Kuwait': 'à¦•à§à¦¯à¦¼à§‡à¦¤',
      'Singapore': 'à¦¸à¦¿à¦™à§à¦—à¦¾à¦ªà§à¦°',
      'North America': 'à¦‰à¦¤à§à¦¤à¦° à¦†à¦®à§‡à¦°à¦¿à¦•à¦¾',
      'Moonsighting Committee': 'à¦šà¦¾à¦à¦¦ à¦¦à§‡à¦–à¦¾ à¦•à¦®à¦¿à¦Ÿà¦¿',
      'Hanafi': 'à¦¹à¦¾à¦¨à¦¾à¦«à¦¿',
      'Shafi': 'à¦¶à¦¾à¦«à§‡à¦¯à¦¼à§€',
    };
    return labels[option] ?? option;
  }

  String _prayerLabel(String prayer, String languageCode) {
    if (languageCode == 'en') return prayer;
    if (languageCode == 'ar') return _ar[prayer] ?? prayer;
    const labels = <String, String>{
      'Fajr': 'à¦«à¦œà¦°',
      'Dhuhr': 'à¦œà§‹à¦¹à¦°',
      'Asr': 'à¦†à¦¸à¦°',
      'Maghrib': 'à¦®à¦¾à¦—à¦°à¦¿à¦¬',
      'Isha': 'à¦à¦¶à¦¾',
    };
    return labels[prayer] ?? prayer;
  }

  String _calculationLabel(String method, String languageCode) =>
      _choiceLabel(method, languageCode);

  String _madhabLabel(String madhab, String languageCode) =>
      _choiceLabel(madhab, languageCode);

  String _quranTranslationLabel(String translation, String languageCode) =>
      _choiceLabel(translation, languageCode);

  Future<void> _showChoiceSheet(BuildContext context, String title,
      List<String> options, Future<void> Function(String) onSelected,
      {String? selectedValue}) async {
    final languageCode = Localizations.localeOf(context).languageCode;
    final isEnglish = languageCode == 'en';
    final isArabic = languageCode == 'ar';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.82;

        return SafeArea(
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: Theme.of(sheetContext).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                  child: Text(
                    title,
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];

                      final label = options.length == 3 &&
                              options.contains('bn') &&
                              options.contains('en') &&
                              options.contains('ar')
                          ? (isEnglish
                              ? ({
                                    'bn': 'Bangla',
                                    'en': 'English',
                                    'ar': 'Arabic'
                                  }[option] ??
                                  option)
                              : (isArabic
                                  ? ({
                                        'bn': 'البنغالية',
                                        'en': 'الإنجليزية',
                                        'ar': 'العربية'
                                      }[option] ??
                                      option)
                                  : ({
                                        'bn': 'বাংলা',
                                        'en': 'ইংরেজি',
                                        'ar': 'আরবি'
                                      }[option] ??
                                      option)))
                          : _choiceLabel(option, languageCode);

                      return ListTile(
                        title: Text(label),
                        trailing: option == selectedValue
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.seaBlue,
                              )
                            : null,
                        onTap: () async {
                          await onSelected(option);
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showTextSizeSheet(
      BuildContext context, TextScaleProvider provider, bool isEnglish) async {
    final languageCode = Localizations.localeOf(context).languageCode;
    final labels = languageCode == 'en'
        ? const ['Small', 'Normal', 'Large', 'Very Large']
        : languageCode == 'ar'
            ? const ['ØµØºÙŠØ±', 'Ø¹Ø§Ø¯ÙŠ', 'ÙƒØ¨ÙŠØ±', 'ÙƒØ¨ÙŠØ± Ø¬Ø¯Ù‹Ø§']
            : const [
                'à¦›à§‹à¦Ÿ',
                'à¦¸à§à¦¬à¦¾à¦­à¦¾à¦¬à¦¿à¦•',
                'à¦¬à§œ',
                'à¦–à§à¦¬ à¦¬à§œ'
              ];
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                    _t(languageCode, 'à¦…à§à¦¯à¦¾à¦ªà§‡à¦° à¦²à§‡à¦–à¦¾',
                        'App Text Size'),
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900))),
            for (int index = 0; index < labels.length; index++)
              ListTile(
                title: Text(labels[index]),
                trailing: index == provider.level
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.seaBlue)
                    : null,
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

  Future<void> _showAdjustmentDialog(
      BuildContext context, SettingsProvider settings) async {
    const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_t(
            settings.languageCode,
            'à¦¸à¦¾à¦²à¦¾à¦¤à§‡à¦° à¦¸à¦®à§Ÿ à¦¸à¦®à¦¨à§à¦¬à§Ÿ',
            'Prayer Adjustments')),
        content: SingleChildScrollView(
          child: Column(
            children: [
              for (final prayer in prayers)
                ListTile(
                  title: Text(_prayerLabel(prayer, settings.languageCode)),
                  subtitle: Text(
                      '${settings.prayerAdjustments[prayer] ?? 0} ${_t(settings.languageCode, 'à¦®à¦¿à¦¨à¦¿à¦Ÿ', 'min')}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () => settings.setPrayerAdjustment(prayer,
                              (settings.prayerAdjustments[prayer] ?? 0) - 1),
                          icon: const Icon(Icons.remove_circle_outline)),
                      IconButton(
                          onPressed: () => settings.setPrayerAdjustment(prayer,
                              (settings.prayerAdjustments[prayer] ?? 0) + 1),
                          icon: const Icon(Icons.add_circle_outline)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                  _t(settings.languageCode, 'à¦¸à¦®à§à¦ªà¦¨à§à¦¨', 'Done')))
        ],
      ),
    );
  }

  Future<void> _showJamaatDialog(
      BuildContext context, SettingsProvider settings) async {
    const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final controllers = <String, TextEditingController>{
      for (final prayer in prayers)
        prayer: TextEditingController(text: settings.getJamaat(prayer)),
    };
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(_t(settings.languageCode,
              'à¦œà¦¾à¦®à¦¾à¦¤à§‡à¦° à¦¸à¦®à§Ÿ', 'Jamaat Times')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                for (final prayer in prayers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: controllers[prayer],
                      decoration: InputDecoration(
                          labelText:
                              _prayerLabel(prayer, settings.languageCode)),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                    _t(settings.languageCode, 'à¦¬à¦¾à¦¤à¦¿à¦²', 'Cancel'))),
            FilledButton(
              onPressed: () async {
                for (final prayer in prayers) {
                  await settings.setJamaatTime(
                      prayer, controllers[prayer]!.text);
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text(
                  _t(settings.languageCode, 'à¦¸à¦‚à¦°à¦•à§à¦·à¦£', 'Save')),
            ),
          ],
        ),
      );
    } finally {
      for (final controller in controllers.values) controller.dispose();
    }
  }

  Future<void> _showQuranFontSheet(
      BuildContext context, SettingsProvider settings) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _slider(
                  sheetContext,
                  _t(settings.languageCode, 'à¦•à§à¦°à¦†à¦¨ à¦†à¦°à¦¬à¦¿',
                      'Quran Arabic'),
                  settings.quranFontSize,
                  14,
                  50,
                  settings.updateQuranFontSize),
              const SizedBox(height: 14),
              _slider(
                  sheetContext,
                  _t(settings.languageCode, 'à¦…à¦¨à§à¦¬à¦¾à¦¦',
                      'Translation'),
                  settings.translationFontSize,
                  10,
                  30,
                  settings.updateTranslationFontSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slider(BuildContext context, String title, double value, double min,
      double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w800))),
          Text(value.round().toString(),
              style: const TextStyle(
                  color: AppColors.seaBlue, fontWeight: FontWeight.w900))
        ]),
        Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged),
      ],
    );
  }

  Future<void> _showDailyContentSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Consumer<SettingsProvider>(
          builder: (context, current, _) => Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _switchTile(
                    context,
                    Icons.menu_book_outlined,
                    _t(current.languageCode, 'à¦¦à§ˆà¦¨à¦¿à¦• à¦†à§Ÿà¦¾à¦¤',
                        'Daily Ayah'),
                    '',
                    current.showDailyAyah,
                    (v) => current.setDailyContentPreferences(ayah: v)),
                _switchTile(
                    context,
                    Icons.auto_stories_outlined,
                    _t(current.languageCode, 'à¦¦à§ˆà¦¨à¦¿à¦• à¦¹à¦¾à¦¦à¦¿à¦¸',
                        'Daily Hadith'),
                    '',
                    current.showDailyHadith,
                    (v) => current.setDailyContentPreferences(hadith: v)),
                _switchTile(
                    context,
                    Icons.volunteer_activism_outlined,
                    _t(current.languageCode, 'à¦¦à§ˆà¦¨à¦¿à¦• à¦¦à§‹à§Ÿà¦¾',
                        'Daily Dua'),
                    '',
                    current.showDailyDua,
                    (v) => current.setDailyContentPreferences(dua: v)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showResetDialog(
      BuildContext context, SettingsProvider settings) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_t(
            settings.languageCode,
            'à¦¸à§‡à¦Ÿà¦¿à¦‚à¦¸ à¦°à¦¿à¦¸à§‡à¦Ÿ à¦•à¦°à¦¬à§‡à¦¨?',
            'Reset settings?')),
        content: Text(_t(
            settings.languageCode,
            'à¦¸à¦¬ à¦¸à¦‚à¦°à¦•à§à¦·à¦¿à¦¤ à¦¸à§‡à¦Ÿà¦¿à¦‚à¦¸ à¦¡à¦¿à¦«à¦²à§à¦Ÿ à¦…à¦¬à¦¸à§à¦¥à¦¾à§Ÿ à¦«à¦¿à¦°à§‡ à¦¯à¦¾à¦¬à§‡à¥¤',
            'All saved preferences will return to their default values.')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child:
                  Text(_t(settings.languageCode, 'à¦¬à¦¾à¦¤à¦¿à¦²', 'Cancel'))),
          FilledButton(
            onPressed: () async {
              await settings.resetSettings();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(_t(settings.languageCode, 'à¦°à¦¿à¦¸à§‡à¦Ÿ', 'Reset')),
          ),
        ],
      ),
    );
  }
}
