import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../screens/dua/dua_screen.dart';
import '../../screens/tools/asma_ul_husna.dart';
import '../../screens/hadith_screen.dart';
import '../../screens/more_screen.dart';
import '../../screens/prayer_screen.dart';
import '../../screens/tools/calendar_screen.dart';
import '../../screens/tools/qibla_screen.dart';
import '../../screens/quran_screen.dart';
import '../../screens/tools/tasbih_screen.dart';
import '../../screens/tools_screen.dart';

import 'quick_action_card.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = [
      (
        l10n.prayer,
        Icons.mosque_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrayerScreen()),
        ),
      ),
      (
        l10n.quran,
        Icons.menu_book_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuranScreen()),
        ),
      ),
      (
        l10n.hadith,
        Icons.auto_stories_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HadithScreen()),
        ),
      ),
      (
        l10n.qibla,
        Icons.explore_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QiblaScreen()),
        ),
      ),
      (
        l10n.tasbih,
        Icons.radio_button_checked_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TasbihScreen()),
        ),
      ),
      (
        l10n.asmaUlHusna,
        Icons.star_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AsmaUlHusnaScreen()),
        ),
      ),
      (
        l10n.dua,
        Icons.favorite_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DuaScreen()),
        ),
      ),
      (
        l10n.calendar,
        Icons.calendar_month_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CalendarScreen()),
        ),
      ),
      (
        l10n.tools,
        Icons.handyman_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ToolsScreen()),
        ),
      ),
      (
        l10n.more,
        Icons.more_horiz_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MoreScreen()),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tr('দ্রুত অ্যাকশন', 'Quick Actions'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: .95,
          ),
          itemBuilder: (_, index) {
            final action = actions[index];
            return QuickActionCard(
              title: action.$1,
              icon: action.$2,
              onTap: action.$3,
            );
          },
        ),
      ],
    );
  }
}
