import 'package:flutter/material.dart';

import '../services/home_mode_service.dart';
import '../theme/app_theme.dart';

class HomeModeSettingsScreen extends StatelessWidget {
  const HomeModeSettingsScreen({super.key});

  String _title(bool isEnglish) => isEnglish ? 'Home Screen' : 'হোম স্ক্রিন';

  @override
  Widget build(BuildContext context) {
    final service = HomeModeService.instance;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _title(isEnglish),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              Text(
                isEnglish
                    ? 'Choose the Home layout you prefer.'
                    : 'আপনার পছন্দের হোম স্ক্রিনের ধরন নির্বাচন করুন।',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.secondaryTextColor,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              _ModeCard(
                selected: !service.isSimple,
                icon: Icons.dashboard_customize_rounded,
                title: isEnglish ? 'Informative' : 'ইনফরমেটিভ',
                subtitle: isEnglish
                    ? 'More details, prayer information and daily content.'
                    : 'আরও তথ্য, সালাতের তথ্য ও দৈনিক কনটেন্টসহ বিস্তারিত হোম।',
                badge: isEnglish ? 'Detailed' : 'বিস্তারিত',
                selectedLabel: isEnglish ? 'SELECTED' : 'নির্বাচিত',
                onTap: () => service.setSimple(false),
              ),
              const SizedBox(height: 10),
              _ModeCard(
                selected: service.isSimple,
                icon: Icons.home_rounded,
                title: isEnglish ? 'Simple' : 'সিম্পল',
                subtitle: isEnglish
                    ? 'Clean, calm and focused on everyday essentials.'
                    : 'পরিষ্কার, শান্ত এবং প্রতিদিনের প্রয়োজনীয় বিষয়গুলোকে গুরুত্ব দেয়।',
                badge: isEnglish ? 'Clean' : 'সহজ',
                selectedLabel: isEnglish ? 'SELECTED' : 'নির্বাচিত',
                onTap: () => service.setSimple(true),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      size: 19,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isEnglish
                            ? 'You can change this choice anytime. Your prayer data and Quran progress stay unchanged.'
                            : 'আপনি যেকোনো সময় এই পছন্দ পরিবর্তন করতে পারবেন। আপনার সালাতের তথ্য ও কুরআনের অগ্রগতি অপরিবর্তিত থাকবে।',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          color: context.secondaryTextColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.selectedLabel,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final String selectedLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: .10) : context.cardColor,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: selected ? primary.withValues(alpha: .55) : primary.withValues(alpha: .08),
              width: selected ? 1.7 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: .10),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: selected ? .16 : .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: selected
                    ? Column(
                        key: const ValueKey('selected'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: primary,
                            size: 23,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            selectedLabel,
                            style: TextStyle(
                              color: primary,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      )
                    : Icon(
                        Icons.radio_button_off_rounded,
                        key: const ValueKey('unselected'),
                        color: context.secondaryTextColor,
                        size: 21,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
