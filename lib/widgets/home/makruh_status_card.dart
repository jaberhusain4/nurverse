// lib/widgets/home/makruh_status_card.dart

import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../services/makruh_time_service.dart';
import '../../theme/app_theme.dart';
import '../common_widgets.dart';

class MakruhStatusCard extends StatelessWidget {
  final MakruhInfo info;

  const MakruhStatusCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final Color color = info.isMakruh ? AppColors.warning : AppColors.success;
    final IconData icon = info.isMakruh ? Icons.warning_amber_rounded : Icons.check_circle;

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
                  l10n.tr('মাকরূহের সময়', 'Makruh Time'),
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: context.primaryTextColor),
                ),
                const SizedBox(height: 6),
                Text(
                  info.isMakruh
                      ? l10n.tr('${info.name} সময়টি বর্তমানে চলছে।', '${info.name} time is currently active.')
                      : l10n.tr('এটি মাকরূহের সময় নয়।', 'This is not a Makruh time.'),
                  style: TextStyle(color: context.secondaryTextColor, height: 1.4),
                ),
              ],
            ),
          ),
          AppBadge(text: info.isMakruh ? l10n.tr('চলছে', 'ACTIVE') : l10n.tr('স্বাভাবিক', 'CLEAR'), color: color),
        ],
      ),
    );
  }
}
