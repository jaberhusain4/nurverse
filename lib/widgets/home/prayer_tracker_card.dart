// lib/widgets/home/prayer_tracker_card.dart

import 'package:flutter/material.dart';

import '../../services/prayer_tracker_service.dart';
import '../../theme/app_theme.dart';
import '../common_widgets.dart';

class PrayerTrackerCard extends StatelessWidget {
  final PrayerTrackerInfo tracker;

  const PrayerTrackerCard({super.key, required this.tracker});

  String _format(Duration duration) {
    if (duration.isNegative) {
      return "00:00";
    }

    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);

    return "${h.toString().padLeft(2, "0")}:${m.toString().padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Prayer Progress",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.primaryTextColor,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Elapsed",
                      style: TextStyle(color: context.secondaryTextColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _format(tracker.elapsed),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: context.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Remaining",
                      style: TextStyle(color: context.secondaryTextColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _format(tracker.remaining),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: context.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: tracker.progress,
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${(tracker.progress * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                color: AppColors.seaBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
