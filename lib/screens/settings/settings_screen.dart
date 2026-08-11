import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../prayer/jamaat_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    if (settings.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'সেটিংস',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator(color: primary)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'সেটিংস',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ==================================================================
          // APP
          // ==================================================================
          _buildSectionLabel(context, 'অ্যাপ', Icons.tune_rounded),

          const SizedBox(height: 8),

          _buildSettingsCard(
            context,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.language_rounded,
                title: 'ভাষা',
                subtitle: settings.isBangla ? 'বাংলা' : 'English',
                onTap: () => _showLanguageDialog(context),
              ),

              _buildDivider(context),

              _buildSettingTile(
                context,
                icon: Icons.palette_outlined,
                title: 'থিম',
                subtitle: _themeLabel(settings),
                onTap: () => _showThemeDialog(context),
              ),

              _buildDivider(context),

              _buildSettingTile(
                context,
                icon: Icons.contrast_rounded,
                title: 'AMOLED Black',
                subtitle: settings.isAmoledMode ? 'চালু' : 'বন্ধ',
                trailing: Switch.adaptive(
                  value: settings.isAmoledMode,
                  onChanged: (value) {
                    settings.toggleAmoledMode(value);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ==================================================================
          // SALAT
          // ==================================================================
          _buildSectionLabel(context, 'সালাত', Icons.mosque_outlined),

          const SizedBox(height: 8),

          _buildSettingsCard(
            context,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.calculate_outlined,
                title: 'হিসাব পদ্ধতি',
                subtitle: _calculationMethodLabel(settings.calculationMethod),
                onTap: () => _showCalculationMethodDialog(context),
              ),

              _buildDivider(context),

              _buildSettingTile(
                context,
                icon: Icons.menu_book_outlined,
                title: 'মাযহাব',
                subtitle: _madhhabLabel(settings.madhhab),
                onTap: () => _showMadhhabDialog(context),
              ),

              _buildDivider(context),

              _buildSettingTile(
                context,
                icon: Icons.location_on_outlined,
                title: 'লোকেশন',
                subtitle: settings.autoLocation ? 'স্বয়ংক্রিয়' : 'ম্যানুয়াল',
                onTap: () => _showLocationModeDialog(context),
              ),

              _buildDivider(context),

              _buildSettingTile(
                context,
                icon: Icons.notifications_active_outlined,
                title: 'আজান নোটিফিকেশন',
                subtitle: settings.isAdhanNotificationEnabled ? 'চালু' : 'বন্ধ',
                trailing: Switch.adaptive(
                  value: settings.isAdhanNotificationEnabled,
                  onChanged: (value) {
                    settings.toggleAdhanNotification(value);
                  },
                ),
              ),

              _buildDivider(context),

              _buildSettingTile(
                context,
                icon: Icons.alarm_outlined,
                title: 'সালাত রিমাইন্ডার',
                subtitle: _reminderLabel(settings.prayerReminderMinutes),
                onTap: () => _showPrayerReminderDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ==================================================================
          // JAMAAT
          // ==================================================================
          _buildSectionLabel(context, 'জামাআত', Icons.groups_rounded),

          const SizedBox(height: 8),

          _buildSettingsCard(
            context,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.tune_rounded,
                title: 'জামাআত মোড ও সময়',
                subtitle: 'Automatic / Manual এবং প্রতিটি ওয়াক্তের সময়',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const JamaatSettingsScreen(),
                    ),
                  );
                },
              ),

              _buildDivider(context),

              _buildJamaatTimeRow(
                context,
                prayer: 'Fajr',
                title: 'ফজর',
                subtitle: 'Fajr',
                icon: Icons.nights_stay_outlined,
                value: settings.fajrJamaat,
              ),

              _buildDivider(context),

              _buildJamaatTimeRow(
                context,
                prayer: 'Dhuhr',
                title: 'যোহর',
                subtitle: 'Dhuhr',
                icon: Icons.wb_sunny_outlined,
                value: settings.dhuhrJamaat,
              ),

              _buildDivider(context),

              _buildJamaatTimeRow(
                context,
                prayer: 'Asr',
                title: 'আসর',
                subtitle: 'Asr',
                icon: Icons.wb_twilight_outlined,
                value: settings.asrJamaat,
              ),

              _buildDivider(context),

              _buildJamaatTimeRow(
                context,
                prayer: 'Maghrib',
                title: 'মাগরিব',
                subtitle: 'Maghrib',
                icon: Icons.wb_twilight_rounded,
                value: settings.maghribJamaat,
              ),

              _buildDivider(context),

              _buildJamaatTimeRow(
                context,
                prayer: 'Isha',
                title: 'এশা',
                subtitle: 'Isha',
                icon: Icons.nights_stay_rounded,
                value: settings.ishaJamaat,
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ==================================================================
          // DATE & TIME
          // ==================================================================
          _buildSectionLabel(
            context,
            'তারিখ ও সময়',
            Icons.calendar_month_outlined,
          ),

          const SizedBox(height: 8),

          _buildSettingsCard(
            context,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.date_range_outlined,
                title: 'হিজরি তারিখ সমন্বয়',
                subtitle: _hijriAdjustmentLabel(settings.hijriAdjustment),
                onTap: () => _showHijriAdjustmentDialog(context),
              ),

              _buildDivider(context),

              _buildSettingTile(
                context,
                icon: Icons.timer_outlined,
                title: 'ঘড়িতে সেকেন্ড দেখান',
                subtitle: settings.showSeconds ? 'চালু' : 'বন্ধ',
                trailing: Switch.adaptive(
                  value: settings.showSeconds,
                  onChanged: (value) {
                    settings.toggleShowSeconds(value);
                  },
                ),
              ),

              _buildDivider(context),

              _buildSettingTile(
                context,
                icon: Icons.vibration_rounded,
                title: 'ভাইব্রেশন',
                subtitle: settings.vibrationEnabled ? 'চালু' : 'বন্ধ',
                trailing: Switch.adaptive(
                  value: settings.vibrationEnabled,
                  onChanged: (value) {
                    settings.toggleVibration(value);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ==================================================================
          // QURAN
          // ==================================================================
          _buildSectionLabel(context, 'কুরআন', Icons.menu_book_rounded),

          const SizedBox(height: 8),

          _buildSettingsCard(
            context,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.text_fields_rounded,
                title: 'আরবি ফন্টের আকার',
                subtitle: settings.quranFontSize.toStringAsFixed(0),
                onTap: () => _showQuranFontSizeDialog(context),
              ),

              _buildDivider(context),

              _buildSettingTile(
                context,
                icon: Icons.translate_rounded,
                title: 'অনুবাদ',
                subtitle: settings.quranTranslation,
                onTap: () => _showQuranTranslationDialog(context),
              ),

              _buildDivider(context),

              _buildSettingTile(
                context,
                icon: Icons.font_download_outlined,
                title: 'আরবি ফন্ট',
                subtitle: settings.quranArabicFont,
                onTap: () => _showQuranArabicFontDialog(context),
              ),

              _buildDivider(context),

              _buildSettingTile(
                context,
                icon: Icons.translate_outlined,
                title: 'অনুবাদের ফন্টের আকার',
                subtitle: settings.translationFontSize.toStringAsFixed(0),
                onTap: () => _showTranslationFontSizeDialog(context),
              ),

              _buildDivider(context),

              _buildSettingTile(
                context,
                icon: Icons.play_circle_outline_rounded,
                title: 'পরবর্তী আয়াত স্বয়ংক্রিয়ভাবে চালু',
                subtitle: settings.autoPlayNext ? 'চালু' : 'বন্ধ',
                trailing: Switch.adaptive(
                  value: settings.autoPlayNext,
                  onChanged: (value) {
                    settings.toggleAutoPlayNext(value);
                  },
                ),
              ),

              _buildDivider(context),

              _buildSettingTile(
                context,
                icon: Icons.wifi_rounded,
                title: 'শুধু Wi-Fi দিয়ে ডাউনলোড',
                subtitle: settings.downloadWifiOnly ? 'চালু' : 'বন্ধ',
                trailing: Switch.adaptive(
                  value: settings.downloadWifiOnly,
                  onChanged: (value) {
                    settings.toggleDownloadWifiOnly(value);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ==================================================================
          // NOTIFICATIONS
          // ==================================================================
          _buildSectionLabel(
            context,
            'নোটিফিকেশন',
            Icons.notifications_none_rounded,
          ),

          const SizedBox(height: 8),

          _buildSettingsCard(
            context,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.music_note_outlined,
                title: 'নোটিফিকেশন সাউন্ড',
                subtitle: settings.notificationSound,
                onTap: () => _showNotificationSoundDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ==================================================================
          // SETTINGS MANAGEMENT
          // ==================================================================
          _buildSectionLabel(
            context,
            'সেটিংস ব্যবস্থাপনা',
            Icons.settings_backup_restore_rounded,
          ),

          const SizedBox(height: 8),

          _buildSettingsCard(
            context,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.restart_alt_rounded,
                title: 'সব সেটিংস রিসেট',
                subtitle: 'ডিফল্ট সেটিংসে ফিরে যান',
                iconColor: Colors.redAccent,
                titleColor: Colors.redAccent,
                onTap: () => _confirmReset(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Center(
            child: Text(
              'NurVerse',
              style: theme.textTheme.titleSmall?.copyWith(
                color: context.secondaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 3),

          Center(
            child: Text(
              'আপনার ইবাদতের প্রতিদিনের সঙ্গী',
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // JAMAAT TIME ROW
  // ==========================================================================

  Widget _buildJamaatTimeRow(
    BuildContext context, {
    required String prayer,
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showJamaatTimeDialog(
          context,
          prayer: prayer,
          title: title,
          currentValue: value,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 21, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 82),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: primary.withValues(alpha: .13)),
                ),
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .2,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Icon(Icons.edit_outlined, size: 18, color: context.secondaryTextColor),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // JAMAAT TIME INPUT DIALOG
  // ==========================================================================

  Future<void> _showJamaatTimeDialog(
    BuildContext context, {
    required String prayer,
    required String title,
    required String currentValue,
  }) async {
    final settings = context.read<SettingsProvider>();
    final controller = TextEditingController(text: currentValue);
    final focusNode = FocusNode();
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.access_time_rounded, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  Text('$title জামাআতের সময়', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('জামাআতের সঠিক সময় লিখুন.', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: InputDecoration(
                      labelText: 'সময়',
                      hintText: 'যেমন 8:45',
                      prefixIcon: const Icon(Icons.schedule_rounded),
                      suffixText: 'সময়',
                      errorText: errorText,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onSubmitted: (_) async {
                      final success = await _saveJamaatTime(context, settings, prayer, controller.text);
                      if (success && dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      } else {
                        setDialogState(() => errorText = 'সঠিক সময় লিখুন, যেমন 8:45');
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'উদাহরণ: 5:00, 1:30, 8:45',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('বাতিল')),
                FilledButton(
                  onPressed: () async {
                    final success = await _saveJamaatTime(context, settings, prayer, controller.text);
                    if (success && dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    } else {
                      setDialogState(() => errorText = 'সঠিক সময় লিখুন, যেমন 8:45');
                      focusNode.requestFocus();
                    }
                  },
                  child: const Text('সংরক্ষণ'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    focusNode.dispose();
  }

  Future<bool> _saveJamaatTime(
    BuildContext context,
    SettingsProvider settings,
    String prayer,
    String value,
  ) async {
    final input = value.trim();
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(input);
    if (match == null) return false;

    final hour = int.tryParse(match.group(1)!) ?? 0;
    final minute = int.tryParse(match.group(2)!) ?? 0;
    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) return false;

    final normalized = '$hour:${minute.toString().padLeft(2, '0')}';
    return settings.setJamaatTime(prayer, normalized);
  }

  Widget _buildSectionLabel(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      children: [
        Icon(icon, size: 18, color: primary),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleSmall?.copyWith(color: primary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: .07)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .035), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (iconColor ?? primary).withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 21, color: iconColor ?? primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(color: titleColor, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: context.secondaryTextColor)),
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: context.secondaryTextColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: .6,
      indent: 69,
      endIndent: 15,
      color: Theme.of(context).dividerColor.withValues(alpha: .18),
    );
  }

  Future<void> _showThemeDialog(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'থিম নির্বাচন করুন',
        icon: Icons.palette_outlined,
        children: [
          _buildChoiceTile(context, icon: Icons.brightness_auto_rounded, title: 'সিস্টেম', subtitle: 'ডিভাইসের থিম অনুসরণ করবে', selected: settings.themeMode == ThemeMode.system && !settings.isAmoledMode, onTap: () async { await settings.setSystemTheme(); if (context.mounted) Navigator.pop(context); }),
          _buildChoiceTile(context, icon: Icons.light_mode_outlined, title: 'লাইট', subtitle: 'উজ্জ্বল থিম', selected: settings.themeMode == ThemeMode.light, onTap: () async { await settings.setLightTheme(); if (context.mounted) Navigator.pop(context); }),
          _buildChoiceTile(context, icon: Icons.dark_mode_outlined, title: 'ডার্ক', subtitle: 'ডার্ক থিম', selected: settings.themeMode == ThemeMode.dark && !settings.isAmoledMode, onTap: () async { await settings.setDarkTheme(); if (context.mounted) Navigator.pop(context); }),
          _buildChoiceTile(context, icon: Icons.contrast_rounded, title: 'AMOLED Black', subtitle: 'সম্পূর্ণ কালো ব্যাকগ্রাউন্ড', selected: settings.isAmoledMode, onTap: () async { await settings.setAmoledTheme(); if (context.mounted) Navigator.pop(context); }),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'ভাষা নির্বাচন করুন',
        icon: Icons.language_rounded,
        children: [
          _buildChoiceTile(context, icon: Icons.translate_rounded, title: 'বাংলা', subtitle: 'অ্যাপের ভাষা বাংলা হবে', selected: settings.isBangla, onTap: () async { await settings.setBangla(); if (context.mounted) Navigator.pop(context); }),
          _buildChoiceTile(context, icon: Icons.language_outlined, title: 'English', subtitle: 'App language will be English', selected: settings.isEnglish, onTap: () async { await settings.setEnglish(); if (context.mounted) Navigator.pop(context); }),
        ],
      ),
    );
  }

  Future<void> _showCalculationMethodDialog(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final methods = [
      {'value': 'Karachi', 'title': 'Karachi', 'subtitle': 'University of Islamic Sciences, Karachi'},
      {'value': 'Muslim World League', 'title': 'Muslim World League', 'subtitle': 'Muslim World League'},
      {'value': 'Egyptian', 'title': 'Egyptian', 'subtitle': 'Egyptian General Authority of Survey'},
      {'value': 'Umm Al Qura', 'title': 'Umm Al Qura', 'subtitle': 'Umm Al-Qura University, Makkah'},
      {'value': 'Dubai', 'title': 'Dubai', 'subtitle': 'UAE calculation method'},
      {'value': 'Moonsighting Committee', 'title': 'Moonsighting Committee', 'subtitle': 'Moonsighting Committee'},
    ];
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'হিসাব পদ্ধতি',
        icon: Icons.calculate_outlined,
        children: methods.map((method) => _buildChoiceTile(context, icon: Icons.calculate_rounded, title: method['title']!, subtitle: method['subtitle']!, selected: settings.calculationMethod == method['value'], onTap: () async { await settings.setCalculationMethod(method['value']!); if (context.mounted) Navigator.pop(context); })).toList(),
      ),
    );
  }

  Future<void> _showMadhhabDialog(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'মাযহাব নির্বাচন করুন',
        icon: Icons.menu_book_outlined,
        children: [
          _buildChoiceTile(context, icon: Icons.menu_book_rounded, title: 'Hanafi', subtitle: 'হানাফি মাযহাব', selected: settings.madhhab == 'Hanafi', onTap: () async { await settings.setMadhhab('Hanafi'); if (context.mounted) Navigator.pop(context); }),
          _buildChoiceTile(context, icon: Icons.menu_book_rounded, title: 'Shafi', subtitle: 'শাফেয়ি মাযহাব', selected: settings.madhhab == 'Shafi', onTap: () async { await settings.setMadhhab('Shafi'); if (context.mounted) Navigator.pop(context); }),
        ],
      ),
    );
  }

  Future<void> _showLocationModeDialog(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'লোকেশন',
        icon: Icons.location_on_outlined,
        children: [
          _buildChoiceTile(context, icon: Icons.my_location_rounded, title: 'স্বয়ংক্রিয়', subtitle: 'GPS দিয়ে অবস্থান নির্ধারণ', selected: settings.autoLocation, onTap: () async { await settings.setAutoLocation(true); if (context.mounted) Navigator.pop(context); }),
          _buildChoiceTile(context, icon: Icons.location_city_rounded, title: 'ম্যানুয়াল', subtitle: 'নিজে অবস্থান নির্বাচন করুন', selected: !settings.autoLocation, onTap: () async { await settings.setAutoLocation(false); if (context.mounted) Navigator.pop(context); }),
        ],
      ),
    );
  }

  Future<void> _showHijriAdjustmentDialog(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('হিজরি তারিখ সমন্বয়', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('হিজরি তারিখ প্রয়োজন অনুযায়ী -২ থেকে +২ দিন পর্যন্ত সমন্বয় করতে পারবেন।', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 18),
            DropdownButtonFormField<int>(
              initialValue: settings.hijriAdjustment,
              decoration: InputDecoration(labelText: 'সমন্বয়', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
              items: List.generate(5, (index) {
                final value = index - 2;
                return DropdownMenuItem<int>(value: value, child: Text(value == 0 ? 'কোনো সমন্বয় নেই' : value > 0 ? '+$value দিন' : '$value দিন'));
              }),
              onChanged: (value) { if (value != null) settings.setHijriAdjustment(value); },
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('সম্পন্ন'))],
      ),
    );
  }

  Future<void> _showPrayerReminderDialog(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    const values = [0, 5, 10, 15, 20, 30, 45, 60];
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'সালাত রিমাইন্ডার',
        icon: Icons.alarm_outlined,
        children: values.map((minutes) => _buildChoiceTile(context, icon: Icons.alarm_rounded, title: minutes == 0 ? 'রিমাইন্ডার বন্ধ' : '$minutes মিনিট আগে', subtitle: minutes == 0 ? 'কোনো প্রি-প্রেয়ার রিমাইন্ডার থাকবে না' : 'সালাতের আগে নোটিফিকেশন', selected: settings.prayerReminderMinutes == minutes, onTap: () async { await settings.setPrayerReminderMinutes(minutes); if (context.mounted) Navigator.pop(context); })).toList(),
      ),
    );
  }

  Future<void> _showQuranFontSizeDialog(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    double value = settings.quranFontSize;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('আরবি ফন্টের আকার', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)), Slider(min: 14, max: 50, divisions: 36, value: value, onChanged: (newValue) => setDialogState(() => value = newValue))]),
          actions: [TextButton(onPressed: () { settings.updateQuranFontSize(value); Navigator.pop(dialogContext); }, child: const Text('সম্পন্ন'))],
        ),
      ),
    );
  }

  Future<void> _showTranslationFontSizeDialog(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    double value = settings.translationFontSize;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('অনুবাদের ফন্টের আকার', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)), Slider(min: 10, max: 30, divisions: 20, value: value, onChanged: (newValue) => setDialogState(() => value = newValue))]),
          actions: [TextButton(onPressed: () { settings.updateTranslationFontSize(value); Navigator.pop(dialogContext); }, child: const Text('সম্পন্ন'))],
        ),
      ),
    );
  }

  Future<void> _showQuranTranslationDialog(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'কুরআন অনুবাদ',
        icon: Icons.translate_rounded,
        children: [
          _buildChoiceTile(context, icon: Icons.translate_rounded, title: 'Bangla', subtitle: 'বাংলা অনুবাদ', selected: settings.quranTranslation == 'Bangla', onTap: () async { await settings.setQuranTranslation('Bangla'); if (context.mounted) Navigator.pop(context); }),
          _buildChoiceTile(context, icon: Icons.language_rounded, title: 'English', subtitle: 'English translation', selected: settings.quranTranslation == 'English', onTap: () async { await settings.setQuranTranslation('English'); if (context.mounted) Navigator.pop(context); }),
        ],
      ),
    );
  }

  Future<void> _showQuranArabicFontDialog(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    const fonts = ['Default', 'Amiri', 'Scheherazade', 'Noto Naskh Arabic'];
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'আরবি ফন্ট',
        icon: Icons.font_download_outlined,
        children: fonts.map((font) => _buildChoiceTile(context, icon: Icons.font_download_rounded, title: font, subtitle: 'কুরআনের আরবি লেখার ফন্ট', selected: settings.quranArabicFont == font, onTap: () async { await settings.setQuranArabicFont(font); if (context.mounted) Navigator.pop(context); })).toList(),
      ),
    );
  }

  Future<void> _showNotificationSoundDialog(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    const sounds = ['Default', 'Silent'];
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'নোটিফিকেশন সাউন্ড',
        icon: Icons.music_note_outlined,
        children: sounds.map((sound) => _buildChoiceTile(context, icon: sound == 'Silent' ? Icons.volume_off_outlined : Icons.volume_up_outlined, title: sound, subtitle: sound == 'Silent' ? 'কোনো সাউন্ড বাজবে না' : 'ডিফল্ট নোটিফিকেশন সাউন্ড', selected: settings.notificationSound == sound, onTap: () async { await settings.setNotificationSound(sound); if (context.mounted) Navigator.pop(context); })).toList(),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('সব সেটিংস রিসেট করবেন?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('আপনার অ্যাপের কাস্টম সেটিংসগুলো ডিফল্ট অবস্থায় ফিরে যাবে।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('বাতিল')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('রিসেট')),
        ],
      ),
    );
    if (confirmed != true) return;
    await settings.resetSettings();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('সব সেটিংস ডিফল্ট অবস্থায় ফিরিয়ে দেওয়া হয়েছে।'), behavior: SnackBarBehavior.floating));
  }

  Widget _buildBottomSheet(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 650),
        decoration: BoxDecoration(color: context.cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(width: 42, height: 4, decoration: BoxDecoration(color: theme.dividerColor.withValues(alpha: .45), borderRadius: BorderRadius.circular(20))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: primary.withValues(alpha: .09), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: primary, size: 21)),
                  const SizedBox(width: 11),
                  Expanded(child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            Flexible(child: ListView(shrinkWrap: true, physics: const BouncingScrollPhysics(), padding: const EdgeInsets.fromLTRB(12, 0, 12, 18), children: children)),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required bool selected, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(color: selected ? primary.withValues(alpha: .07) : Colors.transparent, borderRadius: BorderRadius.circular(17), border: Border.all(color: selected ? primary.withValues(alpha: .14) : Colors.transparent)),
          child: Row(
            children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: selected ? primary.withValues(alpha: .11) : theme.dividerColor.withValues(alpha: .22), borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 20, color: selected ? primary : context.secondaryTextColor)),
              const SizedBox(width: 11),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: selected ? FontWeight.bold : FontWeight.w600, color: selected ? primary : null)), const SizedBox(height: 2), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: context.secondaryTextColor))])),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? primary : Colors.transparent, border: Border.all(color: selected ? primary : context.secondaryTextColor.withValues(alpha: .35), width: 1.5)),
                child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _themeLabel(SettingsProvider settings) {
    if (settings.isAmoledMode) return 'AMOLED Black';
    switch (settings.themeMode) {
      case ThemeMode.light:
        return 'লাইট';
      case ThemeMode.dark:
        return 'ডার্ক';
      case ThemeMode.system:
        return 'সিস্টেম';
    }
  }

  String _calculationMethodLabel(String method) {
    switch (method) {
      case 'Karachi':
        return 'Karachi';
      case 'Muslim World League':
        return 'Muslim World League';
      case 'Egyptian':
        return 'Egyptian';
      case 'Umm Al Qura':
        return 'Umm Al Qura';
      case 'Dubai':
        return 'Dubai';
      case 'Moonsighting Committee':
        return 'Moonsighting Committee';
      default:
        return method;
    }
  }

  String _madhhabLabel(String madhhab) {
    switch (madhhab) {
      case 'Hanafi':
        return 'Hanafi';
      case 'Shafi':
        return 'Shafi';
      case 'Maliki':
        return 'Maliki';
      case 'Hanbali':
        return 'Hanbali';
      default:
        return madhhab;
    }
  }

  String _reminderLabel(int minutes) {
    if (minutes <= 0) return 'বন্ধ';
    return '$minutes মিনিট আগে';
  }

  String _hijriAdjustmentLabel(int adjustment) {
    if (adjustment == 0) return 'কোনো সমন্বয় নেই';
    if (adjustment > 0) return '+$adjustment দিন';
    return '$adjustment দিন';
  }
}
