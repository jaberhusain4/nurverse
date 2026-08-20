import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'hafezi_quran_screen.dart';
import 'onudhabon_quran_screen.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Text(
            'কুরআন',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 16,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'দুইভাবে কুরআন পড়ুন — হিফজ ও অনুধাবন।',
            style: TextStyle(fontSize: 13, color: context.secondaryTextColor),
          ),
          const SizedBox(height: 18),
          _QuranModeCard(
            icon: Icons.menu_book_rounded,
            title: 'Hafezi Quran',
            subtitle: '১৫ লাইনের অফলাইন হাফেজি/ইন্দো-পাক স্টাইল মুসহাফ',
            badge: '15 লাইন',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HafeziQuranScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _QuranModeCard(
            icon: Icons.auto_stories_rounded,
            title: 'Onudhabon Quran',
            subtitle: 'সূরা, আয়াত, বাংলা অনুবাদ ও অনুধাবনভিত্তিক পাঠ',
            badge: 'পড়ার জন্য খুলুন',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OnudhabonQuranScreen(
                  openLastRead: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuranModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _QuranModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.softAqua.withValues(alpha: .16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.seaBlueDark,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: context.secondaryTextColor,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softAqua.withValues(alpha: .13),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            fontSize: 10,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                            color: AppColors.seaBlueDark,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 21,
                color: context.secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
