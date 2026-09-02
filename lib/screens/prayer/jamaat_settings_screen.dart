import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class JamaatSettingsScreen extends StatelessWidget {
  const JamaatSettingsScreen({super.key});

  static const List<String> _prayers = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  static const Map<String, String> _bnNames = {
    'Fajr': 'ফজর',
    'Dhuhr': 'যোহর / জুমু\'আ',
    'Asr': 'আসর',
    'Maghrib': 'মাগরিব',
    'Isha': 'ইশা',
  };

  Future<void> _pickTime(BuildContext context, String prayer) async {
    final settings = context.read<SettingsProvider>();
    final current = _parseTime(settings.getJamaat(prayer));

    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
      helpText: settings.isEnglish
          ? 'Select Jamaat time'
          : 'জামাআতের সময় নির্বাচন করুন',
      cancelText: settings.isEnglish ? 'Cancel' : 'বাতিল',
      confirmText: settings.isEnglish ? 'OK' : 'ঠিক আছে',
    );

    if (picked == null || !context.mounted) return;

    final value = _formatTime(picked, settings.is24Hour);
    await settings.setJamaatTime(prayer, value);
  }

  TimeOfDay? _parseTime(String value) {
    final text = value.trim();
    if (text.isEmpty || text == '--:--') return null;

    final amPm = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(text);

    if (amPm != null) {
      var hour = int.tryParse(amPm.group(1)!) ?? 12;
      final minute = int.tryParse(amPm.group(2)!) ?? 0;
      final period = amPm.group(3)!.toUpperCase();

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      if (hour > 23 || minute > 59) return null;
      return TimeOfDay(hour: hour, minute: minute);
    }

    final twentyFour = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text);
    if (twentyFour != null) {
      final hour = int.tryParse(twentyFour.group(1)!) ?? -1;
      final minute = int.tryParse(twentyFour.group(2)!) ?? -1;

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
      return TimeOfDay(hour: hour, minute: minute);
    }

    return null;
  }

  String _formatTime(TimeOfDay time, bool is24Hour) {
    final minute = time.minute.toString().padLeft(2, '0');

    if (is24Hour) {
      return '${time.hour.toString().padLeft(2, '0')}:$minute';
    }

    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = context.secondaryTextColor;
    final isEnglish = settings.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Jamaat Times' : 'জামাআত সেটিংস'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.groups_rounded, color: primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEnglish
                        ? 'Set the local mosque Jamaat time for each prayer. These times are saved on this device.'
                        : 'আপনার এলাকার মসজিদের প্রতিটি ওয়াক্তের জামাআত সময় এখানে সেট করুন। সময়গুলো এই ডিভাইসেই সংরক্ষিত থাকবে।',
                    style: TextStyle(
                      color: secondary,
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ..._prayers.map(
            (prayer) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _JamaatTimeCard(
                name: _bnNames[prayer] ?? prayer,
                time: settings.getJamaat(prayer),
                is24Hour: settings.is24Hour,
                isEnglish: isEnglish,
                onTap: () => _pickTime(context, prayer),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isEnglish
                ? '12-hour mode uses AM/PM. 24-hour mode uses HH:mm. Jamaat times never show seconds.'
                : '১২ ঘণ্টা ফরম্যাটে AM/PM এবং ২৪ ঘণ্টা ফরম্যাটে HH:mm দেখানো হবে। জামাআতের নির্দিষ্ট সময়ে কখনো সেকেন্ড দেখানো হবে না।',
            style: TextStyle(color: secondary, fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _JamaatTimeCard extends StatelessWidget {
  final String name;
  final String time;
  final bool is24Hour;
  final bool isEnglish;
  final VoidCallback onTap;

  const _JamaatTimeCard({
    required this.name,
    required this.time,
    required this.is24Hour,
    required this.isEnglish,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondary = context.secondaryTextColor;

    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 14, 10, 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.schedule_rounded, color: primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isEnglish ? 'Tap to set local Jamaat time' : 'ট্যাপ করে স্থানীয় জামাআতের সময় সেট করুন',
                      style: TextStyle(color: secondary, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: TextStyle(
                  color: text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: secondary),
            ],
          ),
        ),
      ),
    );
  }
}
