// lib/widgets/home/makruh_status_card.dart

import 'package:flutter/material.dart';

import '../../services/makruh_time_service.dart';
import '../../theme/app_theme.dart';
import '../common_widgets.dart';

class MakruhStatusCard extends StatelessWidget {
  final MakruhInfo info;

  const MakruhStatusCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final Color color = info.isMakruh ? AppColors.warning : AppColors.success;

    final IconData icon =
        info.isMakruh ? Icons.warning_amber_rounded : Icons.check_circle;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Makruh Time",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: context.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  info.isMakruh
                      ? "${info.name} time is currently active."
                      : "This is not a Makruh time.",
                  style: TextStyle(
                    color: context.secondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          AppBadge(text: info.isMakruh ? "ACTIVE" : "CLEAR", color: color),
        ],
      ),
    );
  }
}
