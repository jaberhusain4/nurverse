// lib/widgets/prayer/prayer_tracker.dart

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PrayerTracker extends StatefulWidget {
  final bool isFriday;

  const PrayerTracker({super.key, required this.isFriday});

  @override
  State<PrayerTracker> createState() => _PrayerTrackerState();
}

class _PrayerTrackerState extends State<PrayerTracker> {
  final Map<String, bool> _prayerTracker = {
    'ফজর': false,
    'যোহর': false,
    'জুমু\'আ': false,
    'আসর': false,
    'মাগরিব': false,
    'ইশা': false,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final List<String> prayers =
        widget.isFriday
            ? ['ফজর', 'জুমু\'আ', 'আসর', 'মাগরিব', 'ইশা']
            : ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'ইশা'];

    final int completed =
        prayers.where((prayer) => _prayerTracker[prayer] ?? false).length;

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
              Expanded(
                child: Text(
                  '$completed / ${prayers.length} ওয়াক্ত সম্পন্ন',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (completed == prayers.length)
                Icon(Icons.verified_rounded, color: primary, size: 19),
            ],
          ),

          const SizedBox(height: 13),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: prayers.isEmpty ? 0 : completed / prayers.length,
              minHeight: 6,
              backgroundColor: primary.withValues(alpha: .08),
              valueColor: AlwaysStoppedAnimation(primary),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                prayers.map((prayer) {
                  final bool isDone = _prayerTracker[prayer] ?? false;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _prayerTracker[prayer] = !isDone;
                      });
                    },
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                isDone
                                    ? primary
                                    : primary.withValues(alpha: .08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDone
                                ? Icons.check_rounded
                                : Icons.circle_outlined,
                            color: isDone ? Colors.white : primary,
                            size: 20,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          prayer,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
