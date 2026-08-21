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
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                isEnglish
                    ? 'Choose how NurVerse should look when you open Home.'
                    : 'NurVerse চালু করলে Home screen-এ কোন layout দেখাবেন তা নির্বাচন করুন।',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.secondaryTextColor,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              _ModeCard(
                selected: !service.isSimple,
                icon: Icons.dashboard_customize_rounded,
                title: isEnglish ? 'Informative Home' : 'ইনফরমেটিভ Home',
                subtitle: isEnglish
                    ? 'Prayer timeline, dates, restrictions, quick actions and daily content.'
                    : 'নামাজের টাইমলাইন, তারিখ, নিষিদ্ধ সময়, কুইক অ্যাকশন ও দৈনিক কনটেন্টসহ পূর্ণ dashboard।',
                badge: isEnglish ? 'Detailed' : 'বিস্তারিত',
                onTap: () => service.setSimple(false),
              ),
              const SizedBox(height: 14),
              _ModeCard(
                selected: service.isSimple,
                icon: Icons.home_rounded,
                title: isEnglish ? 'Simple Home' : 'সিম্পল Home',
                subtitle: isEnglish
                    ? 'A clean daily-use home focused on the next prayer, Quran and essential tools.'
                    : 'পরের নামাজ, কুরআন ও প্রয়োজনীয় tools-এ দ্রুত পৌঁছানোর জন্য পরিষ্কার, সহজ layout।',
                badge: isEnglish ? 'Easy & Clean' : 'সহজ ও পরিষ্কার',
                onTap: () => service.setSimple(true),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEnglish
                            ? 'You can switch these layouts anytime. Your prayer data, Quran progress and other settings stay the same.'
                            : 'আপনি যেকোনো সময় layout বদলাতে পারবেন। নামাজের data, কুরআনের progress এবং অন্যান্য settings একই থাকবে।',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.secondaryTextColor,
                          height: 1.45,
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
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: .07) : context.cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? primary.withValues(alpha: .45) : primary.withValues(alpha: .08),
              width: selected ? 1.3 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: primary, size: 25),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.secondaryTextColor,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? primary : context.secondaryTextColor,
                size: 23,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
