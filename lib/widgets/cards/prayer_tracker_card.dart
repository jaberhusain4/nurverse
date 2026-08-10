import 'package:flutter/material.dart';

import '../../models/prayer_info_model.dart';

class PrayerTrackerCard extends StatelessWidget {
  const PrayerTrackerCard({
    required this.prayers,
    required this.completedPrayers,
    required this.onChanged,
    super.key,
  });

  final List<PrayerInfoModel> prayers;
  final Set<String> completedPrayers;
  final void Function(String prayerName, bool completed) onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final completedCount = prayers
        .where((prayer) => completedPrayers.contains(prayer.name))
        .length;

    return Card(
      elevation: 0,
      color: colors.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.task_alt_outlined, color: colors.primary),
              title: Text(
                'Prayer tracker',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              trailing: Text(
                '$completedCount/${prayers.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ),

            Divider(color: colors.outlineVariant),

            ...prayers.map(
              (prayer) => CheckboxListTile(
                activeColor: colors.primary,

                value: completedPrayers.contains(prayer.name),

                onChanged: (completed) {
                  if (completed != null) {
                    onChanged(prayer.name, completed);
                  }
                },

                title: Text(
                  prayer.name,
                  style: TextStyle(color: colors.onSurface),
                ),

                controlAffinity: ListTileControlAffinity.leading,

                dense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
