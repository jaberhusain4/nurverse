// lib/widgets/prayer/prayer_schedule.dart

import 'package:flutter/material.dart';
import '../../controllers/prayer_controller.dart';
import '../../theme/app_theme.dart';

class PrayerSchedule extends StatelessWidget {
  final PrayerController controller;
  final bool isFriday;

  const PrayerSchedule({
    super.key,
    required this.controller,
    required this.isFriday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          controller.prayers.map((prayer) {
            final bool isCurrent = prayer['isCurrent'] == true;

            final String name =
                prayer['nameBn']?.toString() ??
                prayer['name']?.toString() ??
                '';

            final String start = prayer['start']?.toString() ?? '';

            final String end = prayer['end']?.toString() ?? '';

            final String jamaat = prayer['jamaat']?.toString() ?? '';

            return PrayerScheduleTile(
              name: name,
              start: start,
              end: end,
              jamaat: jamaat,
              isCurrent: isCurrent,
              isFriday: isFriday && name == "জুমু'আ",
            );
          }).toList(),
    );
  }
}

class PrayerScheduleTile extends StatelessWidget {
  final String name;
  final String start;
  final String end;
  final String jamaat;
  final bool isCurrent;
  final bool isFriday;

  const PrayerScheduleTile({
    super.key,
    required this.name,
    required this.start,
    required this.end,
    required this.jamaat,
    required this.isCurrent,
    required this.isFriday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrent ? primary.withValues(alpha: .07) : context.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              isCurrent
                  ? primary.withValues(alpha: .18)
                  : primary.withValues(alpha: .06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  isCurrent
                      ? primary.withValues(alpha: .12)
                      : theme.dividerColor.withValues(alpha: .30),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isFriday ? Icons.groups_rounded : Icons.access_time_rounded,
              size: 20,
              color: isCurrent ? primary : context.secondaryTextColor,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.w600,
                          color: isCurrent ? primary : null,
                        ),
                      ),
                    ),

                    if (isCurrent) ...[
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'বর্তমান',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  '$start - $end',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                jamaat.isEmpty ? '--' : jamaat,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isCurrent ? primary : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'জামাআত',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 9,
                  color: context.secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
