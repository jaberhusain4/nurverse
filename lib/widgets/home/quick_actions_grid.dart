// lib/widgets/home/quick_actions_grid.dart

import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../localization/locale_text_extension.dart';
import 'quick_action_card.dart';

class QuickActionsGrid extends StatelessWidget {
  final void Function(String action)? onActionTap;

  const QuickActionsGrid({super.key, this.onActionTap});

  static const List<_QuickAction> _actions = [
    _QuickAction(
      id: 'qibla',
      titleBn: 'কিবলা',
      titleEn: 'Qibla',
      titleAr: 'القبلة',
      subtitleBn: 'কিবলার দিক',
      subtitleEn: 'Qibla direction',
      subtitleAr: 'اتجاه القبلة',
      icon: Icons.explore_rounded,
    ),
    _QuickAction(
      id: 'tasbih',
      titleBn: 'তাসবিহ',
      titleEn: 'Tasbih',
      titleAr: 'التسبيح',
      subtitleBn: 'ডিজিটাল তাসবিহ',
      subtitleEn: 'Digital Tasbih',
      subtitleAr: 'التسبيح الرقمي',
      icon: Icons.fingerprint_rounded,
    ),
    _QuickAction(
      id: 'asma',
      titleBn: 'আসমাউল হুসনা',
      titleEn: '99 Names',
      titleAr: 'أسماء الله الحسنى',
      subtitleBn: '৯৯ নাম',
      subtitleEn: '99 Names of Allah',
      subtitleAr: 'أسماء الله التسعة والتسعون',
      icon: Icons.auto_awesome_rounded,
    ),
    _QuickAction(
      id: 'calendar',
      titleBn: 'ক্যালেন্ডার',
      titleEn: 'Calendar',
      titleAr: 'التقويم',
      subtitleBn: 'হিজরি ও বাংলা',
      subtitleEn: 'Hijri & Bangla',
      subtitleAr: 'هجري وبنغالي',
      icon: Icons.calendar_month_rounded,
    ),
    _QuickAction(
      id: 'dua',
      titleBn: 'দোয়া',
      titleEn: 'Dua',
      titleAr: 'الدعاء',
      subtitleBn: 'দৈনন্দিন দোয়া',
      subtitleEn: 'Daily Duas',
      subtitleAr: 'الأدعية اليومية',
      icon: Icons.menu_book_rounded,
    ),
    _QuickAction(
      id: 'hadith',
      titleBn: 'হাদিস',
      titleEn: 'Hadith',
      titleAr: 'الحديث',
      subtitleBn: 'হাদিস সংগ্রহ',
      subtitleEn: 'Hadith collections',
      subtitleAr: 'مجموعات الحديث',
      icon: Icons.auto_stories_rounded,
    ),
    _QuickAction(
      id: 'ruqyah',
      titleBn: 'রুকইয়াহ',
      titleEn: 'Ruqyah',
      titleAr: 'الرقية',
      subtitleBn: 'কুরআনি রুকইয়াহ',
      subtitleEn: 'Quranic Ruqyah',
      subtitleAr: 'الرقية القرآنية',
      icon: Icons.shield_outlined,
    ),
    _QuickAction(
      id: 'zakat',
      titleBn: 'যাকাত',
      titleEn: 'Zakat',
      titleAr: 'الزكاة',
      subtitleBn: 'যাকাত হিসাব',
      subtitleEn: 'Zakat calculator',
      subtitleAr: 'حاسبة الزكاة',
      icon: Icons.calculate_outlined,
    ),
    _QuickAction(
      id: 'more',
      titleBn: 'আরও',
      titleEn: 'More',
      titleAr: 'المزيد',
      subtitleBn: 'সব টুলস',
      subtitleEn: 'All tools',
      subtitleAr: 'جميع الأدوات',
      icon: Icons.grid_view_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: _actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final action = _actions[index];

        return QuickActionCard(
          title: l10n.localeText(values: {
            'bn': action.titleBn,
            'en': action.titleEn,
            'ar': action.titleAr,
          }),
          subtitle: l10n.localeText(values: {
            'bn': action.subtitleBn,
            'en': action.subtitleEn,
            'ar': action.subtitleAr,
          }),
          icon: action.icon,
          onTap: () => onActionTap?.call(action.id),
        );
      },
    );
  }
}

class _QuickAction {
  final String id;
  final String titleBn;
  final String titleEn;
  final String titleAr;
  final String subtitleBn;
  final String subtitleEn;
  final String subtitleAr;
  final IconData icon;

  const _QuickAction({
    required this.id,
    required this.titleBn,
    required this.titleEn,
    required this.titleAr,
    required this.subtitleBn,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.icon,
  });
}
