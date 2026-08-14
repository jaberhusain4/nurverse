import 'package:flutter/material.dart';

class LiveClockCard extends StatelessWidget {
  final String currentTime;

  const LiveClockCard({super.key, required this.currentTime});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const seaBlue = Color(0xFF0288D1);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF102A43) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: seaBlue.withValues(alpha: .15)),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 8),
              color: Colors.black.withValues(alpha: .06),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time_rounded, color: seaBlue, size: 17),
            const SizedBox(width: 7),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  currentTime,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
