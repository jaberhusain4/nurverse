import 'package:flutter/material.dart';

class CurrentPrayerPremiumCard extends StatelessWidget {
  final String previousPrayer;
  final String previousPrayerTime;
  final String currentPrayer;
  final String currentPrayerTime;
  final String nextPrayer;
  final String nextPrayerTime;
  final String remainingTime;
  final double progress;
  final String sunrise;
  final String sunset;
  final String iqamahTime;
  final String status;
  final bool showExtraInfo;

  const CurrentPrayerPremiumCard({
    super.key,
    required this.previousPrayer,
    required this.previousPrayerTime,
    required this.currentPrayer,
    required this.currentPrayerTime,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.remainingTime,
    required this.progress,
    required this.sunrise,
    required this.sunset,
    required this.iqamahTime,
    required this.status,
    this.showExtraInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? colorScheme.onSurface;
    final secondaryColor =
        theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.68) ??
        colorScheme.onSurface.withValues(alpha: 0.68);
    final primaryColor = colorScheme.primary;

    final safeProgress = progress.clamp(0.0, 1.0);
    final progressPercent = (safeProgress * 100).round();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: primaryColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================================
            // PREVIOUS / CURRENT / NEXT
            // ==========================================================
            Row(
              children: [
                Expanded(
                  child: _PrayerSideItem(
                    label: 'পূর্ববর্তী',
                    prayer: previousPrayer.isEmpty ? '--' : previousPrayer,
                    time:
                        previousPrayerTime.isEmpty
                            ? '--:--'
                            : previousPrayerTime,
                    icon: Icons.history_rounded,
                    primaryColor: primaryColor,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    alignment: CrossAxisAlignment.start,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  flex: 1,
                  child: _CurrentPrayerItem(
                    prayer:
                        currentPrayer.isEmpty ? 'ওয়াক্ত নেই' : currentPrayer,
                    time:
                        currentPrayerTime.isEmpty ? '--:--' : currentPrayerTime,
                    primaryColor: primaryColor,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _PrayerSideItem(
                    label: 'পরবর্তী',
                    prayer: nextPrayer.isEmpty ? '--' : nextPrayer,
                    time: nextPrayerTime.isEmpty ? '--:--' : nextPrayerTime,
                    icon: Icons.arrow_forward_rounded,
                    primaryColor: primaryColor,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    alignment: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ==========================================================
            // REMAINING TIME
            // ==========================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.055),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      size: 18,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'পরবর্তী সালাত পর্যন্ত',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          remainingTime.isEmpty ? '--:--:--' : remainingTime,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (nextPrayer.isNotEmpty)
                    Text(
                      nextPrayer,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==========================================================
            // REAL-TIME PROGRESS
            // ==========================================================
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: safeProgress,
                      minHeight: 7,
                      backgroundColor: primaryColor.withValues(alpha: 0.10),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$progressPercent%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ==========================================================
            // START / END
            // ==========================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentPrayerTime.isEmpty ? '--:--' : currentPrayerTime,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: secondaryColor,
                  ),
                ),
                Text(
                  _extractEndTime(status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ==========================================================
            // STATUS
            // ==========================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 15, color: primaryColor),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    status.isEmpty ? 'সালাতের সময় গণনা করা হচ্ছে...' : status,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                      color: secondaryColor,
                    ),
                  ),
                ),
              ],
            ),

            // ==========================================================
            // NOTE:
            // Sunrise / Sunset / Iqamah are intentionally NOT shown.
            // Their parameters remain in the constructor so the existing
            // HomeScreen call does not break.
            // ==========================================================
          ],
        ),
      ),
    );
  }

  String _extractEndTime(String value) {
    // The current controller exposes status separately and does not expose
    // currentPrayerEnd through the existing HomeScreen constructor.
    //
    // Therefore we intentionally do not invent an end time here.
    // The card uses the real current prayer start time and real progress.
    return '--:--';
  }
}

// ==========================================================================
// PREVIOUS / NEXT ITEM
// ==========================================================================

class _PrayerSideItem extends StatelessWidget {
  final String label;
  final String prayer;
  final String time;
  final IconData icon;
  final Color primaryColor;
  final Color textColor;
  final Color secondaryColor;
  final CrossAxisAlignment alignment;

  const _PrayerSideItem({
    required this.label,
    required this.prayer,
    required this.time,
    required this.icon,
    required this.primaryColor,
    required this.textColor,
    required this.secondaryColor,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Icon(icon, size: 16, color: secondaryColor),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: secondaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          prayer,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign:
              alignment == CrossAxisAlignment.end
                  ? TextAlign.end
                  : TextAlign.start,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: secondaryColor,
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// CURRENT PRAYER
// ==========================================================================

class _CurrentPrayerItem extends StatelessWidget {
  final String prayer;
  final String time;
  final Color primaryColor;
  final Color textColor;
  final Color secondaryColor;

  const _CurrentPrayerItem({
    required this.prayer,
    required this.time,
    required this.primaryColor,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mosque_rounded, size: 15, color: primaryColor),
        ),
        const SizedBox(height: 5),
        Text(
          'বর্তমান',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: secondaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          prayer,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: secondaryColor,
          ),
        ),
      ],
    );
  }
}
