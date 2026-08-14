import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../localization/app_localizations_x.dart';
import '../common/app_progress_bar.dart';

class CurrentPrayerCard extends StatelessWidget {
  final String currentPrayer;
  final String currentPrayerTime;
  final String nextPrayer;
  final String nextPrayerTime;
  final String remainingTime;
  final double progress;
  final String status;

  final String? sunrise;
  final String? sunset;

  const CurrentPrayerCard({
    super.key,
    required this.currentPrayer,
    required this.currentPrayerTime,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.remainingTime,
    required this.progress,
    required this.status,
    this.sunrise,
    this.sunset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = const Color(0x220288D1);
    final shadowColor =
        isDark ? Colors.black.withValues(alpha: .35) : const Color(0x140288D1);
    final infoBg = theme.cardColor;

    final localizedStatus = l10n.prayerStatus(status);
    final statusForColor = status.toLowerCase();
    final chipBg = statusForColor.contains('মাকরুহ') ||
            statusForColor.contains('makruh')
        ? Colors.red.withValues(alpha: .10)
        : statusForColor.contains('জামাত') ||
                statusForColor.contains('jama')
            ? Colors.orange.withValues(alpha: .12)
            : Colors.green.withValues(alpha: .10);
    final chipText = statusForColor.contains('মাকরুহ') ||
            statusForColor.contains('makruh')
        ? Colors.red
        : statusForColor.contains('জামাত') ||
                statusForColor.contains('jama')
            ? Colors.orange
            : Colors.green;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xff0288D1).withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: Color(0xff0288D1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.currentPrayer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.prayerName(currentPrayer),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    localizedStatus,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: chipText,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            currentPrayerTime,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${l10n.next} • ${l10n.prayerName(nextPrayer)}  •  $nextPrayerTime',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 20),
          AppProgressBar(value: progress),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  title: l10n.tr('বাকি', 'Remaining'),
                  value: remainingTime,
                  backgroundColor: infoBg,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoItem(
                  title: l10n.next,
                  value: l10n.prayerName(nextPrayer),
                  backgroundColor: infoBg,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoItem(
                  title: l10n.prayerTime,
                  value: nextPrayerTime,
                  backgroundColor: infoBg,
                ),
              ),
            ],
          ),
          if (sunrise != null || sunset != null) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                if (sunrise != null)
                  Expanded(
                    child: _InfoItem(
                      title: l10n.sunrise,
                      value: sunrise!,
                      backgroundColor: infoBg,
                    ),
                  ),
                if (sunrise != null && sunset != null)
                  const SizedBox(width: 10),
                if (sunset != null)
                  Expanded(
                    child: _InfoItem(
                      title: l10n.sunset,
                      value: sunset!,
                      backgroundColor: infoBg,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;

  const _InfoItem({
    required this.title,
    required this.value,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x150288D1)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
