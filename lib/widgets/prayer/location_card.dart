// lib/widgets/prayer/location_card.dart

import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../theme/app_theme.dart';

class PrayerLocationCard extends StatelessWidget {
  final String location;
  final VoidCallback? onTap;

  const PrayerLocationCard({super.key, required this.location, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: primary.withValues(alpha: .08)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.location_on_rounded, color: primary, size: 20),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.location,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location.isEmpty ? l10n.locationUnavailable : location,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: context.secondaryTextColor,
                size: 21,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
