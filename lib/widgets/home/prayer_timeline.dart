import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class PrayerTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> prayers;

  const PrayerTimeline({super.key, required this.prayers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primary = theme.colorScheme.primary;

    final cardColor = context.cardColor;

    final secondaryText = context.secondaryTextColor;

    final titleColor =
        theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;

    int currentIndex = -1;

    for (int i = 0; i < prayers.length; i++) {
      if (prayers[i]['isCurrent'] == true) {
        currentIndex = i;
        break;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================================================
          // HEADER
          // ========================================================
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prayer Timeline',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'সালাতের সময়সূচি',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ========================================================
          // EMPTY STATE
          // ========================================================
          if (prayers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'সালাতের সময় পাওয়া যাচ্ছে না',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: secondaryText,
                  ),
                ),
              ),
            ),

          // ========================================================
          // TIMELINE
          // ========================================================
          if (prayers.isNotEmpty)
            ...List.generate(prayers.length, (index) {
              final prayer = prayers[index];

              final bool isCurrent = prayer['isCurrent'] == true;

              final bool isCompleted =
                  currentIndex >= 0 && index < currentIndex;

              final bool isNext =
                  currentIndex >= 0 && index == currentIndex + 1;

              final bool isLast = index == prayers.length - 1;

              final String name =
                  prayer['nameBn']?.toString().trim().isNotEmpty == true
                      ? prayer['nameBn'].toString()
                      : prayer['name']?.toString() ?? '';

              final String arabic = prayer['nameAr']?.toString() ?? '';

              final String start = prayer['start']?.toString() ?? '--:--';

              final String end = prayer['end']?.toString() ?? '--:--';

              final String jamaat =
                  prayer['jamaat']?.toString().trim().isNotEmpty == true
                      ? prayer['jamaat'].toString()
                      : '--:--';

              return _TimelineItem(
                name: name,
                arabic: arabic,
                start: start,
                end: end,
                jamaat: jamaat,
                isCurrent: isCurrent,
                isCompleted: isCompleted,
                isNext: isNext,
                isLast: isLast,
                primaryColor: primary,
                secondaryTextColor: secondaryText,
                titleColor: titleColor,
              );
            }),
        ],
      ),
    );
  }
}

// ============================================================================
// TIMELINE ITEM
// ============================================================================

class _TimelineItem extends StatelessWidget {
  final String name;
  final String arabic;
  final String start;
  final String end;
  final String jamaat;

  final bool isCurrent;
  final bool isCompleted;
  final bool isNext;
  final bool isLast;

  final Color primaryColor;
  final Color secondaryTextColor;
  final Color titleColor;

  const _TimelineItem({
    required this.name,
    required this.arabic,
    required this.start,
    required this.end,
    required this.jamaat,
    required this.isCurrent,
    required this.isCompleted,
    required this.isNext,
    required this.isLast,
    required this.primaryColor,
    required this.secondaryTextColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color dotColor =
        isCurrent
            ? primaryColor
            : isCompleted
            ? primaryColor.withValues(alpha: 0.55)
            : primaryColor.withValues(alpha: 0.18);

    final Color lineColor =
        isCompleted || isCurrent
            ? primaryColor.withValues(alpha: 0.32)
            : primaryColor.withValues(alpha: 0.10);

    final Color itemBackground =
        isCurrent ? primaryColor.withValues(alpha: 0.07) : Colors.transparent;

    final Color itemBorder =
        isCurrent ? primaryColor.withValues(alpha: 0.14) : Colors.transparent;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ========================================================
          // TIMELINE RAIL
          // ========================================================
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 3),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isCurrent ? 15 : 10,
                  height: isCurrent ? 15 : 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border:
                        isCurrent
                            ? Border.all(
                              color: primaryColor.withValues(alpha: 0.18),
                              width: 4,
                            )
                            : null,
                  ),
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: lineColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 7),

          // ========================================================
          // CONTENT
          // ========================================================
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: itemBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: itemBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ==================================================
                  // NAME + TIME
                  // ==================================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight:
                                      isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                  color: isCurrent ? primaryColor : titleColor,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                            if (isCurrent)
                              _StatusBadge(
                                label: 'বর্তমান',
                                color: primaryColor,
                                filled: true,
                              ),

                            if (isNext && !isCurrent)
                              _StatusBadge(
                                label: 'পরবর্তী',
                                color: primaryColor,
                                filled: false,
                              ),
                          ],
                        ),

                        if (arabic.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(
                              arabic,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: secondaryTextColor,
                                fontSize: 11,
                              ),
                            ),
                          ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Icon(
                              Icons.schedule_outlined,
                              size: 12,
                              color: secondaryTextColor,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '$start – $end',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: secondaryTextColor,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ==================================================
                  // JAMAAT
                  // ==================================================
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        jamaat,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? primaryColor : titleColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'জামাত',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 8,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border:
            filled ? null : Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: filled ? Colors.white : color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
