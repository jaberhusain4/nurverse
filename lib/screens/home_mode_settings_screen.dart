import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../services/home_mode_service.dart';
import '../theme/app_theme.dart';

class HomeModeSettingsScreen extends StatelessWidget {
  const HomeModeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = HomeModeService.instance;
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final isArabic = l10n.isArabic;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.tr('হোম স্ক্রিন', 'Home Screen'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              Text(
                isArabic
                    ? 'আপনার পছন্দের হোম স্ক্রিনের ধরন নির্বাচন করুন।'
                    : l10n.tr(
                        'আপনার পছন্দের হোম স্ক্রিনের ধরন নির্বাচন করুন।',
                        'Choose the Home layout you prefer.',
                      ),
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
                title: isArabic ? 'تفصيلي' : l10n.tr('ইনফরমেটিভ', 'Informative'),
                subtitle: isArabic
                    ? 'تفاصيل أكثر ومعلومات الصلاة والمحتوى اليومي.'
                    : l10n.tr(
                        'আরও তথ্য, সালাতের তথ্য ও দৈনিক কনটেন্টসহ বিস্তারিত হোম।',
                        'More details, prayer information and daily content.',
                      ),
                badge: isArabic ? 'تفصيلي' : l10n.tr('বিস্তারিত', 'Detailed'),
                onTap: () => service.setSimple(false),
              ),
              const SizedBox(height: 10),
              _ModeCard(
                selected: service.isSimple,
                icon: Icons.home_rounded,
                title: isArabic ? 'بسيط' : l10n.tr('সিম্পল', 'Simple'),
                subtitle: isArabic
                    ? 'تصميم هادئ ونظيف يركز على الأساسيات اليومية.'
                    : l10n.tr(
                        'পরিষ্কার, শান্ত এবং প্রতিদিনের প্রয়োজনীয় বিষয়গুলোকে গুরুত্ব দেয়।',
                        'Clean, calm and focused on everyday essentials.',
                      ),
                badge: isArabic ? 'نظيف' : l10n.tr('সহজ', 'Clean'),
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
                        isArabic
                            ? 'يمكنك تغيير هذا الاختيار في أي وقت. ستبقى بيانات الصلاة وتقدم القرآن دون تغيير.'
                            : l10n.tr(
                                'আপনি যেকোনো সময় এই পছন্দ পরিবর্তন করতে পারবেন। আপনার সালাতের তথ্য ও কুরআনের অগ্রগতি অপরিবর্তিত থাকবে।',
                                'You can change this choice anytime. Your prayer data and Quran progress stay unchanged.',
                              ),
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
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
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
            color: selected ? primary.withValues(alpha: .07) : context.cardColor,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: selected ? primary.withValues(alpha: .35) : primary.withValues(alpha: .08),
              width: selected ? 1.2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: primary, size: 22),
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
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, height: 1.15),
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
                            style: TextStyle(fontSize: 9.5, color: primary, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, height: 1.35, color: context.secondaryTextColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? primary : context.secondaryTextColor,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
