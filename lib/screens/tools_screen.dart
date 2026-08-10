import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'dua/dua_screen.dart';
import 'hadith/saved_hadith_screen.dart';
import 'qibla/qibla_screen.dart';
import 'quran/audio_quran_screen.dart';
import 'tools/asma_ul_husna.dart';
import 'tools/calendar_screen.dart';
import 'tools/ruqyah_screen.dart';
import 'tools/tasbih_screen.dart';
import 'tools/zakat_calculator_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ইসলামিক টুলস',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            4,
            AppSpacing.md,
            28,
          ),
          children: [
            const _ToolsHero(),
            const SizedBox(height: 22),
            const _SectionTitle(
              title: 'ইবাদত ও আমল',
              subtitle: 'দৈনন্দিন ইবাদতের প্রয়োজনীয় সরঞ্জাম',
            ),
            const SizedBox(height: 10),
            _ToolsGrid(
              items: [
                _ToolItem(
                  icon: Icons.favorite_outline_rounded,
                  title: "দু'আ",
                  subtitle: 'দু‘আ ও মুনাজাত',
                  accent: AppColors.seaBlue,
                  onTap: () => _open(context, const DuaScreen()),
                ),
                _ToolItem(
                  icon: Icons.fingerprint_rounded,
                  title: 'তাসবিহ',
                  subtitle: 'যিকির গণনা ও আমল',
                  accent: AppColors.seaBlue,
                  onTap: () => _open(context, const TasbihScreen()),
                ),
                _ToolItem(
                  icon: Icons.shield_outlined,
                  title: 'রুকইয়াহ',
                  subtitle: 'কুরআন ও সহিহ দু‘আ',
                  accent: AppColors.seaBlue,
                  onTap: () => _open(context, const RuqyahScreen()),
                ),
                _ToolItem(
                  icon: Icons.auto_awesome_outlined,
                  title: 'আল্লাহর ৯৯ নাম',
                  subtitle: 'আসমাউল হুসনা',
                  accent: AppColors.seaBlue,
                  onTap: () => _open(context, const AsmaUlHusnaScreen()),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionTitle(
              title: 'কুরআন ও হাদিস',
              subtitle: 'পাঠ, শ্রবণ ও সংরক্ষিত জ্ঞান',
            ),
            const SizedBox(height: 10),
            _ToolsGrid(
              items: [
                _ToolItem(
                  icon: Icons.headphones_rounded,
                  title: 'অডিও কুরআন',
                  subtitle: 'কুরআন তিলাওয়াত শুনুন',
                  accent: AppColors.seaBlue,
                  onTap: () => _open(context, const AudioQuranScreen()),
                ),
                _ToolItem(
                  icon: Icons.bookmark_outline_rounded,
                  title: 'সংরক্ষিত হাদিস',
                  subtitle: 'আপনার পছন্দের হাদিস',
                  accent: AppColors.seaBlue,
                  onTap: () => _open(context, const SavedHadithScreen()),
                ),
                _ToolItem(
                  icon: Icons.menu_book_outlined,
                  title: 'হাদিস',
                  subtitle: 'হাদিস গ্রন্থসমূহ',
                  accent: AppColors.seaBlue,
                  onTap: () => _showInfo(context, 'হাদিস'),
                ),
                _ToolItem(
                  icon: Icons.library_books_outlined,
                  title: 'ইসলামিক বই',
                  subtitle: 'জ্ঞানভাণ্ডার',
                  accent: AppColors.seaBlue,
                  onTap: () => _showInfo(context, 'ইসলামিক বই'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionTitle(
              title: 'সময় ও দিকনির্দেশনা',
              subtitle: 'ইসলামিক সময়, তারিখ ও কিবলা',
            ),
            const SizedBox(height: 10),
            _ToolsGrid(
              items: [
                _ToolItem(
                  icon: Icons.explore_outlined,
                  title: 'কিবলা',
                  subtitle: 'কাবার দিক নির্ণয়',
                  accent: AppColors.seaBlue,
                  onTap: () => _open(context, const QiblaScreen()),
                ),
                _ToolItem(
                  icon: Icons.calendar_month_outlined,
                  title: 'ক্যালেন্ডার',
                  subtitle: 'হিজরি ও ইসলামিক তারিখ',
                  accent: AppColors.seaBlue,
                  onTap: () => _open(context, const CalendarScreen()),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionTitle(
              title: 'ইসলামিক হিসাব',
              subtitle: 'আর্থিক ইবাদতের প্রয়োজনীয় হিসাব',
            ),
            const SizedBox(height: 10),
            _ToolsGrid(
              items: [
                _ToolItem(
                  icon: Icons.calculate_outlined,
                  title: 'যাকাত ক্যালকুলেটর',
                  subtitle: 'যাকাতের হিসাব করুন',
                  accent: AppColors.seaBlue,
                  onTap: () => _open(context, const ZakatCalculatorScreen()),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const _FutureToolsCard(),
          ],
        ),
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static void _showInfo(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature ফিচারটি আরও উন্নত সংস্করণে যুক্ত করা হবে ইনশাআল্লাহ।'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _ToolsHero extends StatelessWidget {
  const _ToolsHero();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            primary.withValues(alpha: 0.78),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'আপনার ইসলামিক টুলস',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'ইবাদত, জ্ঞান ও দৈনন্দিন প্রয়োজন—সব এক জায়গায়।',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.primaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            color: context.secondaryTextColor,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ToolsGrid extends StatelessWidget {
  final List<_ToolItem> items;

  const _ToolsGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 126,
        crossAxisSpacing: 11,
        mainAxisSpacing: 11,
      ),
      itemBuilder: (context, index) => _ToolCard(item: items[index]),
    );
  }
}

class _ToolItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  const _ToolItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });
}

class _ToolCard extends StatelessWidget {
  final _ToolItem item;

  const _ToolCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.10 : 0.035,
                ),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: item.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.accent, size: 21),
                ),
                const Spacer(),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.secondaryTextColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FutureToolsCard extends StatelessWidget {
  const _FutureToolsCard();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: 0.13)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add_rounded, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'আরও উপকারী টুল আসছে',
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'যিকির, রোজা ও কাজা নামাজ ট্র্যাকারসহ আরও প্রয়োজনীয় ফিচার ধাপে ধাপে যোগ হবে।',
                  style: TextStyle(
                    color: context.secondaryTextColor,
                    fontSize: 11.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
