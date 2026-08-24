// lib/widgets/prayer/daily_time_card.dart

import 'package:flutter/material.dart';

import '../../controllers/prayer_controller.dart';
import '../../localization/app_localizations.dart';
import '../../theme/app_theme.dart';

class DailyTimeCard extends StatelessWidget {
  final PrayerController controller;

  const DailyTimeCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: .08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.wb_twilight_rounded, color: primary, size: 21),
              const SizedBox(width: 8),
              Text(
                l10n.importantTimes,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DailyTimeItem(
                  icon: Icons.wb_sunny_outlined,
                  title: l10n.sunrise,
                  value: controller.sunriseTime,
                ),
              ),
              const _VerticalDivider(),
              Expanded(
                child: _DailyTimeItem(
                  icon: Icons.light_mode_outlined,
                  title: l10n.solarNoon,
                  value: controller.solarNoonTime,
                ),
              ),
              const _VerticalDivider(),
              Expanded(
                child: _DailyTimeItem(
                  icon: Icons.nights_stay_outlined,
                  title: l10n.sunset,
                  value: controller.sunsetTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SpecialTimeRow(
            icon: Icons.warning_amber_rounded,
            title: l10n.makruhTime,
            value: controller.makruhTimeText,
            color: Colors.orange,
          ),
          const SizedBox(height: 8),
          _SpecialTimeRow(
            icon: Icons.block_rounded,
            title: l10n.prohibitedTime,
            value: controller.prohibitedTimeText,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

class _DailyTimeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DailyTimeItem({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Column(
      children: [
        Icon(icon, color: primary, size: 21),
        const SizedBox(height: 5),
        Text(title, textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: context.secondaryTextColor, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }
}

class _SpecialTimeRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _SpecialTimeRow({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(color: color.withValues(alpha: .06), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, textAlign: TextAlign.end, style: theme.textTheme.bodySmall?.copyWith(color: context.secondaryTextColor, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 38, color: Theme.of(context).dividerColor.withValues(alpha: .30));
  }
}
