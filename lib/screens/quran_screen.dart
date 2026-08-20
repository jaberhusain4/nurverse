import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../theme/app_theme.dart';
import 'quran/audio_quran_screen.dart';
import 'quran/hafezi_quran_screen.dart';
import 'quran/onudhabon_quran_screen.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          Text(l10n.alQuran, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(l10n.quranSubtitle, style: TextStyle(color: context.secondaryTextColor)),
          const SizedBox(height: 20),
          _QuranModeCard(
            icon: Icons.menu_book_rounded,
            title: l10n.hafeziQuran,
            subtitle: l10n.hafeziSubtitle,
            badge: l10n.tr('১৫ লাইন • অফলাইন', '15 lines • Offline'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HafeziQuranScreen())),
          ),
          const SizedBox(height: 14),
          _QuranModeCard(
            icon: Icons.auto_stories_rounded,
            title: l10n.tr('অনুধাবন কুরআন', 'Understanding Quran'),
            subtitle: l10n.tr('অনুবাদ ও তাফসীরসহ কুরআন পড়ুন', 'Read Quran with translation and tafsir'),
            badge: l10n.tr('অনুবাদ • তাফসীর', 'Translation • Tafsir'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnudhabonQuranScreen())),
          ),
          const SizedBox(height: 14),
          _QuranModeCard(
            icon: Icons.headphones_rounded,
            title: l10n.tr('অডিও কুরআন', 'Audio Quran'),
            subtitle: l10n.tr('তিলাওয়াত শুনুন এবং ক্যাশ করে অফলাইনে চালান', 'Listen to recitation and cache it for offline playback'),
            badge: l10n.tr('অডিও • অফলাইন ক্যাশ', 'Audio • Offline cache'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AudioQuranScreen())),
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

  const _QuranModeCard({required this.icon, required this.title, required this.subtitle, required this.badge, required this.onTap});

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
                decoration: BoxDecoration(color: primary.withValues(alpha: .10), shape: BoxShape.circle),
                child: Icon(icon, color: primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: TextStyle(fontSize: 12.5, height: 1.45, color: context.secondaryTextColor)),
                    if (badge != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(20)),
                        child: Text(badge!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: primary)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: context.secondaryTextColor),
            ],
          ),
        ),
      ),
    );
  }
}
