import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../services/daily_content_service.dart';
import '../../theme/app_theme.dart';
import 'daily_content_card.dart';

class DailyContentSection extends StatelessWidget {
  final String? languageCodeOverride;
  final Function(int)? onNavigateTab;

  const DailyContentSection({
    super.key,
    String? languageCode,
    this.onNavigateTab,
  }) : languageCodeOverride = languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final languageCode = languageCodeOverride ?? settings.languageCode;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = context.secondaryTextColor;
    final ayah = DailyContentService.getTodayAyah();
    final hadith = DailyContentService.getTodayHadith();
    final dua = DailyContentService.getTodayDua();

    final showAyah = settings.showDailyAyah;
    final showHadith = settings.showDailyHadith;
    final showDua = settings.showDailyDua;

    if (!showAyah && !showHadith && !showDua) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.auto_awesome_rounded, color: primary, size: 18),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tr('দৈনিক অনুপ্রেরণা', 'Daily Inspiration'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    l10n.tr(
                      'আজকের আয়াত, হাদিস ও দোয়া',
                      'Today’s Ayah, Hadith & Dua',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        if (showAyah)
          DailyContentCard(
            content: ayah,
            languageCode: languageCode,
            icon: Icons.auto_stories_rounded,
            iconColor: primary,
          ),
        if (showHadith)
          DailyContentCard(
            content: hadith,
            languageCode: languageCode,
            icon: Icons.menu_book_rounded,
            iconColor: primary,
          ),
        if (showDua)
          DailyContentCard(
            content: dua,
            languageCode: languageCode,
            icon: Icons.favorite_rounded,
            iconColor: primary,
          ),
      ],
    );
  }
}