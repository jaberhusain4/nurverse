import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'quran/audio_quran_screen.dart';
import 'quran/hafezi_quran_screen.dart';
import 'quran/onudhabon_quran_screen.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          Text(
            'আল-কুরআন',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'হাফেজি পাঠ, অনুধাবন এবং তিলাওয়াত — তিনটি আলাদা অভিজ্ঞতা।',
            style: TextStyle(color: context.secondaryTextColor),
          ),
          const SizedBox(height: 20),
          _QuranModeCard(
            icon: Icons.menu_book_rounded,
            title: 'Hafezi Quran',
            subtitle: '১৫ লাইনের অফলাইন হাফেজি/ইন্দো-পাক স্টাইল মুসহাফ।',
            badge: '15 লাইন • Offline',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const HafeziQuranScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _QuranModeCard(
            icon: Icons.auto_stories_rounded,
            title: 'Onudhabon Quran',
            subtitle: 'আরবি আয়াত, বাংলা অনুবাদ এবং বাংলা তাফসির/ব্যাখ্যা।',
            badge: 'Translation + Tafsir',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OnudhabonQuranScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _QuranModeCard(
            icon: Icons.headphones_rounded,
            title: 'Audio Quran',
            subtitle: 'সূরা অনুযায়ী তিলাওয়াত, ক্বারী নির্বাচন, seek এবং offline download।',
            badge: 'Audio • Offline Cache',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AudioQuranScreen(),
                ),
              );
            },
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
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: context.secondaryTextColor,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: context.secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
