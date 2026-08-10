// lib/widgets/prayer/current_prayer_card.dart

import 'package:flutter/material.dart';
import '../../controllers/prayer_controller.dart';
import '../../theme/app_theme.dart';

class CurrentPrayerCard extends StatelessWidget {
  final PrayerController controller;
  final bool isFriday;

  const CurrentPrayerCard({
    super.key,
    required this.controller,
    required this.isFriday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withValues(alpha: .10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.mosque_rounded, color: primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'বর্তমান সালাত',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.currentPrayer,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (isFriday)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'শুক্রবার',
                    style: TextStyle(
                      color: primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _MiniInfo(
                  icon: Icons.play_arrow_rounded,
                  title: 'শুরু',
                  value: controller.currentPrayerStart,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniInfo(
                  icon: Icons.stop_rounded,
                  title: 'শেষ',
                  value: controller.currentPrayerEnd,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniInfo(
                  icon: Icons.groups_rounded,
                  title: 'জামাআত',
                  value: controller.currentIqamahTime,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: controller.prayerProgress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: primary.withValues(alpha: .10),
              valueColor: AlwaysStoppedAnimation(primary),
            ),
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Icon(Icons.timelapse_rounded, size: 17, color: primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  controller.prayerStatus,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, size: 19, color: primary),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'পরবর্তী: ${controller.nextPrayerName}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  controller.nextPrayerTime,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  controller.timeRemainingForNextPrayer,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MiniInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: primary, size: 17),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 9,
              color: context.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
