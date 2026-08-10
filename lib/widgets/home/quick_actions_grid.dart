// lib/widgets/home/quick_actions_grid.dart

import 'package:flutter/material.dart';

import 'quick_action_card.dart';

class QuickActionsGrid extends StatelessWidget {
  final void Function(String action)? onActionTap;

  const QuickActionsGrid({super.key, this.onActionTap});

  static const List<_QuickAction> _actions = [
    _QuickAction(
      id: 'qibla',
      title: 'কিবলা',
      subtitle: 'কিবলার দিক',
      icon: Icons.explore_rounded,
    ),
    _QuickAction(
      id: 'tasbih',
      title: 'তাসবিহ',
      subtitle: 'ডিজিটাল তাসবিহ',
      icon: Icons.fingerprint_rounded,
    ),
    _QuickAction(
      id: 'asma',
      title: 'আসমাউল হুসনা',
      subtitle: '৯৯ নাম',
      icon: Icons.auto_awesome_rounded,
    ),
    _QuickAction(
      id: 'calendar',
      title: 'ক্যালেন্ডার',
      subtitle: 'হিজরি ও বাংলা',
      icon: Icons.calendar_month_rounded,
    ),
    _QuickAction(
      id: 'dua',
      title: 'দোয়া',
      subtitle: 'দৈনন্দিন দোয়া',
      icon: Icons.menu_book_rounded,
    ),
    _QuickAction(
      id: 'hadith',
      title: 'হাদিস',
      subtitle: 'হাদিস সংগ্রহ',
      icon: Icons.auto_stories_rounded,
    ),
    _QuickAction(
      id: 'ruqyah',
      title: 'রুকইয়াহ',
      subtitle: 'কুরআনি রুকইয়াহ',
      icon: Icons.shield_outlined,
    ),
    _QuickAction(
      id: 'zakat',
      title: 'যাকাত',
      subtitle: 'যাকাত হিসাব',
      icon: Icons.calculate_outlined,
    ),
    _QuickAction(
      id: 'more',
      title: 'আরও',
      subtitle: 'সব টুলস',
      icon: Icons.grid_view_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          title: action.title,
          subtitle: action.subtitle,
          icon: action.icon,
          onTap: () => onActionTap?.call(action.id),
        );
      },
    );
  }
}

class _QuickAction {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const _QuickAction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
