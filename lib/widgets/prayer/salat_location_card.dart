import 'package:flutter/material.dart';

/// Compact location presentation for the Salat screen.
/// Uses the same location string supplied by PrayerController; this widget
/// only changes presentation and does not alter location detection/formatting.
class SalatLocationCard extends StatelessWidget {
  final String location;
  final VoidCallback? onRefresh;

  const SalatLocationCard({super.key, required this.location, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: .055)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, size: 19, color: primary),
          const SizedBox(width: 7),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                location.isEmpty ? 'Location unavailable' : location,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ),
          if (onRefresh != null) ...[
            const SizedBox(width: 6),
            IconButton(
              onPressed: onRefresh,
              tooltip: 'Refresh location',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: Icon(Icons.refresh_rounded, size: 18, color: primary),
            ),
          ],
        ],
      ),
    );
  }
}
