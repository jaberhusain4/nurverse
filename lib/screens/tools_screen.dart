import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'dua/dua_screen.dart';
import 'hadith/saved_hadith_screen.dart';
import 'qibla/qibla_screen.dart';
import 'quran/audio_quran_screen.dart';
import 'tools/asma_ul_husna.dart';
import 'tools/calendar_screen.dart';
import 'tools/islamic_books_screen.dart';
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
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 4, AppSpacing.md, 28),
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
                  onTap: () => _open(context, const DuaScreen()),
                ),
                _ToolItem(
                  icon: Icons.fingerprint_rounded,
                  title: 'তাসবিহ',
                  subtitle: 'যিকির গণনা ও আমল',
                  onTap: () => _open(context, const TasbihScreen()),
                ),
                _ToolItem(
                  icon: Icons.shield_outlined,
                  title: 'রুকইয়াহ',
                  subtitle: 'কুরআন ও সহিহ দু‘আ',
                  onTap: () => _open(context, const RuqyahScreen()),
                ),
                _ToolItem(
                  icon: Icons.auto_awesome_outlined,
                  title: 'আল্লাহর ৯৯ নাম',
                  subtitle: 'আসমাউল হুসনা',
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
                  onTap: () => _open(context, const AudioQuranScreen()),
                ),
                _ToolItem(
                  icon: Icons.bookmark_outline_rounded,
                  title: 'সংরক্ষিত হাদিস',
                  subtitle: 'আপনার পছন্দের হাদিস',
                  onTap: () => _open(context, const SavedHadithScreen()),
                ),
                _ToolItem(
                  icon: Icons.library_books_outlined,
                  title: 'ইসলামিক বই',
                  subtitle: 'অনলাইন জ্ঞানভাণ্ডার',
                  onTap: () => _open(context, const IslamicBooksScreen()),
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
                  onTap: () => _open(context, const QiblaScreen()),
                ),
                _ToolItem(
                  icon: Icons.calendar_month_outlined,
                  title: 'ক্যালেন্ডার',
                  subtitle: 'হিজরি ও ইসলামিক তারিখ',
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
                  onTap: () => _open(context, const ZakatCalculatorScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _ToolsHero extends StatelessWidget {
  const _ToolsHero();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 17),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: primary, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'আপনার ইসলামিক টুলস',
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ইবাদত, জ্ঞান ও দৈনন্দিন প্রয়োজন—সব এক জায়গায়।',
                  style: TextStyle(
                    color: secondary,
                    fontSize: 11.5,
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
  final VoidCallback onTap;

  const _ToolItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _ToolCard extends StatelessWidget {
  final _ToolItem item;

  const _ToolCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: primary, size: 21),
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
