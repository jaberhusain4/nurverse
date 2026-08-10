import 'package:flutter/material.dart';

/// Shows whether the current moment falls inside one of the three
/// disliked (Makruh) prayer windows: sunrise, zawal (solar noon), sunset.
class MakruhStatusCard extends StatelessWidget {
  const MakruhStatusCard({
    required this.isMakruhNow,
    required this.makruhName,
    required this.remaining,
    super.key,
  });

  final bool isMakruhNow;
  final String makruhName;
  final Duration remaining;

  String _label(String name) {
    switch (name) {
      case 'sunrise':
        return 'Sunrise Makruh time';
      case 'zawal':
        return 'Zawal (solar noon) Makruh time';
      case 'sunset':
        return 'Sunset Makruh time';
      default:
        return 'Makruh time';
    }
  }

  String _formatRemaining(Duration d) {
    final safe = d.isNegative ? Duration.zero : d;
    final minutes = safe.inMinutes.toString().padLeft(2, '0');
    final seconds = (safe.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (!isMakruhNow) {
      return Card(
        elevation: 0,
        color: colors.secondaryContainer.withValues(alpha: 0.4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No Makruh restriction right now — prayer is permitted.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colors.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _label(makruhName),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colors.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Avoid starting prayer now · clears in ${_formatRemaining(remaining)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
