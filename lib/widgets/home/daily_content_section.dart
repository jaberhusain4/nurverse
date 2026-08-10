import 'package:flutter/material.dart';

import '../../services/daily_content_service.dart';
import '../../theme/app_theme.dart';
import 'daily_content_card.dart';

class DailyContentSection extends StatelessWidget {
  const DailyContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primary = theme.colorScheme.primary;

    final secondary = context.secondaryTextColor;

    // ============================================================
    // REAL DAILY CONTENT
    // ============================================================

    final ayah = DailyContentService.getTodayAyah();

    final hadith = DailyContentService.getTodayHadith();

    final dua = DailyContentService.getTodayDua();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================================
        // SECTION HEADER
        // ==========================================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(Icons.auto_awesome_rounded, color: primary, size: 20),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Inspiration',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'আজকের আয়াত, হাদিস ও দোয়া',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ==========================================================
        // AYAH
        // ==========================================================
        DailyContentCard(
          content: ayah,
          icon: Icons.auto_stories_rounded,
          iconColor: primary,
        ),

        // ==========================================================
        // HADITH
        // ==========================================================
        DailyContentCard(
          content: hadith,
          icon: Icons.menu_book_rounded,
          iconColor: primary,
        ),

        // ==========================================================
        // DUA
        // ==========================================================
        DailyContentCard(
          content: dua,
          icon: Icons.favorite_rounded,
          iconColor: primary,
        ),
      ],
    );
  }
}
