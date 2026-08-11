import 'package:flutter/material.dart';

import '../../services/jamaat_service.dart';
import '../../theme/app_theme.dart';

class JamaatSettingsScreen extends StatefulWidget {
  const JamaatSettingsScreen({super.key});

  @override
  State<JamaatSettingsScreen> createState() => _JamaatSettingsScreenState();
}

class _JamaatSettingsScreenState extends State<JamaatSettingsScreen> {
  static const Map<String, String> _bnNames = {
    'Fajr': 'ফজর',
    'Dhuhr': 'যোহর / জুমু\'আ',
    'Asr': 'আসর',
    'Maghrib': 'মাগরিব',
    'Isha': 'ইশা',
  };

  bool _loading = true;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await JamaatService.initialize();

    for (final prayer in JamaatService.prayers) {
      _controllers[prayer] = TextEditingController(
        text: _displayTime(prayer),
      );
    }

    if (mounted) setState(() => _loading = false);
  }

  String _displayTime(String prayer) {
    if (JamaatService.isAutomatic) {
      return JamaatService.defaultTime(prayer);
    }
    return JamaatService.get(prayer);
  }

  Future<void> _setMode(bool automatic) async {
    await JamaatService.setAutomaticMode(automatic);

    for (final prayer in JamaatService.prayers) {
      _controllers[prayer]?.text = _displayTime(prayer);
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickTime(String prayer) async {
    final current = _parseTime(_controllers[prayer]?.text ?? '');
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
      helpText: 'জামাআতের সময় নির্বাচন করুন',
      cancelText: 'বাতিল',
      confirmText: 'ঠিক আছে',
    );

    if (picked == null) return;

    final formatted = _formatTimeOfDay(picked);
    _controllers[prayer]?.text = formatted;
    await JamaatService.set(prayer, formatted);

    for (final item in JamaatService.prayers) {
      _controllers[item]?.text = _displayTime(item);
    }

    if (mounted) setState(() {});
  }

  Future<void> _useDefault(String prayer) async {
    await JamaatService.useDefault(prayer);
    _controllers[prayer]?.text = _displayTime(prayer);
    if (mounted) setState(() {});
  }

  Future<void> _resetAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ডিফল্ট সময় ফিরিয়ে আনবেন?'),
        content: const Text(
          'সব জামাআত সময় আবার আপনার অবস্থানের আজকের সালাতের সময় অনুযায়ী স্বয়ংক্রিয় ডিফল্টে ফিরে যাবে।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ফিরিয়ে আনুন'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await JamaatService.reset();
    for (final prayer in JamaatService.prayers) {
      _controllers[prayer]?.text = _displayTime(prayer);
    }

    if (mounted) setState(() {});
  }

  TimeOfDay? _parseTime(String value) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (match == null) return null;

    var hour = int.tryParse(match.group(1)!) ?? 12;
    final minute = int.tryParse(match.group(2)!) ?? 0;
    final period = match.group(3)!.toUpperCase();

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = context.secondaryTextColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('জামাআত সেটিংস'),
        actions: [
          IconButton(
            tooltip: 'ডিফল্টে ফিরিয়ে আনুন',
            onPressed: _loading ? null : _resetAll,
            icon: const Icon(Icons.restore_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.groups_rounded, color: primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'আপনার স্থানীয় মসজিদের জামাআত সময় এখানে সেট করুন। Automatic mode-এ সময় আজকের সালাতের হিসাব থেকে নির্ধারিত হবে; Manual mode-এ আপনি নিজে সময় সেট করবেন।',
                              style: TextStyle(
                                color: secondary,
                                fontSize: 12.5,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SwitchListTile.adaptive(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 2,
                          ),
                          secondary: Icon(
                            JamaatService.isAutomatic
                                ? Icons.auto_awesome_rounded
                                : Icons.edit_calendar_rounded,
                            color: primary,
                          ),
                          title: Text(
                            JamaatService.isAutomatic
                                ? 'Automatic Jamaat'
                                : 'Manual Jamaat',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(
                            JamaatService.isAutomatic
                                ? 'সালাতের সময় অনুযায়ী স্বয়ংক্রিয়ভাবে নির্ধারিত হবে'
                                : 'প্রতিটি ওয়াক্তের সময় আপনি নিজে নির্ধারণ করবেন',
                          ),
                          value: JamaatService.isAutomatic,
                          onChanged: _setMode,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ...JamaatService.prayers.map(
                  (prayer) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _JamaatTimeCard(
                      prayer: prayer,
                      name: _bnNames[prayer] ?? prayer,
                      controller: _controllers[prayer]!,
                      isCustom: JamaatService.isCustom(prayer),
                      automatic: JamaatService.isAutomatic,
                      defaultTime: JamaatService.defaultTime(prayer),
                      onPick: JamaatService.isAutomatic
                          ? null
                          : () => _pickTime(prayer),
                      onDefault: () => _useDefault(prayer),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'নোট: Automatic mode-এ জামাআত সময় সালাতের calculated time-এর ওপর নির্ধারিত হয়। Manual mode-এ স্থানীয় মসজিদের প্রকৃত ইকামাহ সময় বসানোই সবচেয়ে উপযুক্ত।',
                  style: TextStyle(color: secondary, fontSize: 11, height: 1.5),
                ),
              ],
            ),
    );
  }
}

class _JamaatTimeCard extends StatelessWidget {
  final String prayer;
  final String name;
  final TextEditingController controller;
  final bool isCustom;
  final bool automatic;
  final String defaultTime;
  final VoidCallback? onPick;
  final VoidCallback onDefault;

  const _JamaatTimeCard({
    required this.prayer,
    required this.name,
    required this.controller,
    required this.isCustom,
    required this.automatic,
    required this.defaultTime,
    required this.onPick,
    required this.onDefault,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondary = context.secondaryTextColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 10, 14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.07)),
      ),
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
                  automatic
                      ? 'স্বয়ংক্রিয়: $defaultTime'
                      : isCustom
                          ? 'স্থানীয় মসজিদের সময়'
                          : 'Manual mode-এ সময় সেট করুন',
                  style: TextStyle(color: secondary, fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: TextField(
              controller: controller,
              readOnly: true,
              enabled: !automatic,
              textAlign: TextAlign.center,
              onTap: onPick,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: primary.withValues(alpha: automatic ? 0.03 : 0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 11,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                color: text,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'জামাআত সময়',
            onSelected: (value) {
              if (value == 'default') onDefault();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'default',
                child: Text('স্বয়ংক্রিয় ডিফল্ট ব্যবহার করুন'),
              ),
            ],
            icon: Icon(Icons.more_vert_rounded, color: secondary),
          ),
        ],
      ),
    );
  }
}
