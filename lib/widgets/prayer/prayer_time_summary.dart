// lib/widgets/prayer/prayer_time_summary.dart

import 'package:flutter/material.dart';
import '../../controllers/prayer_controller.dart';
import '../../theme/app_theme.dart';

class PrayerTimeSummary extends StatelessWidget {
  final PrayerController controller;

  const PrayerTimeSummary({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.access_time_rounded, color: primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'সালাতের সময়',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'পরবর্তী ${controller.nextPrayerName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _TimeBox(
                  title: 'বিগত সালাত',
                  prayer: controller.previousPrayer,
                  time: controller.previousPrayerTime,
                  icon: Icons.history_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimeBox(
                  title: 'বর্তমান',
                  prayer: controller.currentPrayer,
                  time: controller.currentPrayerStart,
                  icon: Icons.mosque_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimeBox(
                  title: 'পরবর্তী',
                  prayer: controller.nextPrayerName,
                  time: controller.nextPrayerTime,
                  icon: Icons.arrow_forward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String title;
  final String prayer;
  final String time;
  final IconData icon;

  const _TimeBox({
    required this.title,
    required this.prayer,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 17, color: primary),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 9,
              color: context.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            prayer,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
