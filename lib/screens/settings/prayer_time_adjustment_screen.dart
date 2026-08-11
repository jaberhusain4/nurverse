import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../services/jamaat_service.dart';
import '../prayer/jamaat_settings_screen.dart';

class PrayerTimeAdjustmentScreen extends StatelessWidget {
  const PrayerTimeAdjustmentScreen({super.key});

  static const List<_PrayerAdjustmentItem> _prayers = [
    _PrayerAdjustmentItem('Fajr', 'ফজর', Icons.nights_stay_outlined),
    _PrayerAdjustmentItem('Dhuhr', 'যোহর', Icons.wb_sunny_outlined),
    _PrayerAdjustmentItem('Asr', 'আসর', Icons.wb_twilight_outlined),
    _PrayerAdjustmentItem('Maghrib', 'মাগরিব', Icons.wb_twilight_rounded),
    _PrayerAdjustmentItem('Isha', 'এশা', Icons.nights_stay_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'সালাতের সময় সমন্বয়',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _InfoCard(
            icon: Icons.tune_rounded,
            title: 'সালাতের সময়',
            message:
                'হিসাব অনুযায়ী নির্ধারিত সময় প্রয়োজন হলে প্রতি ওয়াক্তে ±৬০ মিনিট পর্যন্ত সমন্বয় করতে পারবেন।',
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'সালাতের সময় সমন্বয়',
            icon: Icons.access_time_rounded,
            child: Column(
              children: [
                for (var i = 0; i < _prayers.length; i++) ...[
                  _AdjustmentRow(
                    prayer: _prayers[i],
                    value: settings.prayerAdjustments[_prayers[i].key] ?? 0,
                    onChanged: (value) =>
                        settings.setPrayerAdjustment(_prayers[i].key, value),
                  ),
                  if (i != _prayers.length - 1) const Divider(height: 1),
                ],
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => settings.resetPrayerAdjustments(),
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('ডিফল্টে ফিরুন'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'জামাআত',
            icon: Icons.groups_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: primary.withValues(alpha: .10),
                    foregroundColor: primary,
                    child: const Icon(Icons.tune_rounded),
                  ),
                  title: const Text(
                    'জামাআত মোড ও সময়',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    JamaatService.isAutomatic
                        ? 'Automatic — সমন্বয় করা সালাতের সময় থেকে হিসাব হবে'
                        : 'Manual — আপনার নির্ধারিত সময় ব্যবহার হবে',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const JamaatSettingsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                const SizedBox(height: 8),
                _JamaatPreview(prayer: 'Fajr', title: 'ফজর'),
                _JamaatPreview(prayer: 'Dhuhr', title: 'যোহর'),
                _JamaatPreview(prayer: 'Asr', title: 'আসর'),
                _JamaatPreview(prayer: 'Maghrib', title: 'মাগরিব'),
                _JamaatPreview(prayer: 'Isha', title: 'এশা'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerAdjustmentItem {
  const _PrayerAdjustmentItem(this.key, this.title, this.icon);

  final String key;
  final String title;
  final IconData icon;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: .12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(message, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: .45)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 21, color: primary),
                const SizedBox(width: 9),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _AdjustmentRow extends StatelessWidget {
  const _AdjustmentRow({required this.prayer, required this.value, required this.onChanged});

  final _PrayerAdjustmentItem prayer;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(prayer.icon, size: 21, color: primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(prayer.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          IconButton(
            tooltip: 'এক মিনিট কমান',
            onPressed: value > -60 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          SizedBox(
            width: 62,
            child: Text(
              '${value > 0 ? '+' : ''}$value মি.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            tooltip: 'এক মিনিট বাড়ান',
            onPressed: value < 60 ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _JamaatPreview extends StatelessWidget {
  const _JamaatPreview({required this.prayer, required this.title});

  final String prayer;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = JamaatService.get(prayer);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
