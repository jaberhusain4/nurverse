import 'package:flutter/material.dart';

class DailyContentCard extends StatelessWidget {
  const DailyContentCard({
    required this.title,
    required this.icon,
    required this.text,
    required this.reference,
    super.key,
  });

  final String title;
  final IconData icon;
  final String text;
  final String reference;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colors.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 10),
            Text(
              reference,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
