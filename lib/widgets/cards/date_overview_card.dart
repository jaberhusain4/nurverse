import 'package:flutter/material.dart';

class DateOverviewCard extends StatelessWidget {
  const DateOverviewCard({
    required this.hijriDate,
    required this.bengaliDate,
    required this.sunrise,
    required this.sunset,
    super.key,
  });

  final String hijriDate;
  final String bengaliDate;
  final String sunrise;
  final String sunset;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month_outlined, color: colors.primary),
                const SizedBox(width: 8),
                Text('Today', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Text(hijriDate, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(bengaliDate, style: Theme.of(context).textTheme.bodyMedium),
            const Divider(height: 28),
            Row(
              children: [
                Expanded(
                  child: _SunTime(
                    icon: Icons.wb_sunny_outlined,
                    label: 'Sunrise',
                    time: sunrise,
                  ),
                ),
                Expanded(
                  child: _SunTime(
                    icon: Icons.wb_twilight_outlined,
                    label: 'Sunset',
                    time: sunset,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SunTime extends StatelessWidget {
  const _SunTime({required this.icon, required this.label, required this.time});

  final IconData icon;
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            Text(time, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ],
    );
  }
}
