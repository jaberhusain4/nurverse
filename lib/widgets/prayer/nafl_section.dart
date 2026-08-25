// lib/widgets/prayer/nafl_section.dart

import 'package:flutter/material.dart';
import '../../controllers/prayer_controller.dart';
import '../../localization/app_localizations.dart';
import '../../theme/app_theme.dart';

class NaflSection extends StatelessWidget {
  final PrayerController controller;

  const NaflSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        NaflTile(
          title: l10n.ishraq,
          description: l10n.tr('সূর্যোদয়ের কিছুক্ষণ পর', 'Shortly after sunrise'),
          time: controller.sunriseTime,
          icon: Icons.wb_sunny_outlined,
        ),
        NaflTile(
          title: l10n.duha,
          description: l10n.tr('সকাল থেকে দুপুরের পূর্ব পর্যন্ত', 'From morning until before noon'),
          time: l10n.tr('সূর্যোদয়ের পর', 'After sunrise'),
          icon: Icons.wb_sunny_rounded,
        ),
        NaflTile(
          title: l10n.awwabin,
          description: l10n.tr('মাগরিবের পর', 'After Maghrib'),
          time: controller.sunsetTime,
          icon: Icons.nightlight_outlined,
        ),
        NaflTile(
          title: l10n.tahajjud,
          description: l10n.tr('রাতের শেষাংশ', 'The latter part of the night'),
          time: l10n.tr('শেষ তৃতীয়াংশ', 'Last third of the night'),
          icon: Icons.nights_stay_rounded,
        ),
      ],
    );
  }
}

class NaflTile extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final IconData icon;

  const NaflTile({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: primary.withValues(alpha: .06)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              time,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
