import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.islamicTools, style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 4, AppSpacing.md, 28),
          children: [
            _ToolsHero(l10n: l10n),
            const SizedBox(height: 22),
            _SectionTitle(title: l10n.worshipAndPractice, subtitle: l10n.dailyWorshipTools),
            const SizedBox(height: 10),
            _ToolsGrid(
              items: [
                _ToolItem(icon: Icons.favorite_outline_rounded, title: l10n.dua, subtitle: l10n.duaSubtitle, onTap: () => _open(context, const DuaScreen())),
                _ToolItem(icon: Icons.fingerprint_rounded, title: l10n.tasbih, subtitle: l10n.tasbihSubtitle, onTap: () => _open(context, const TasbihScreen())),
                _ToolItem(icon: Icons.shield_outlined, title: l10n.ruqyah, subtitle: l10n.ruqyahSubtitle, onTap: () => _open(context, const RuqyahScreen())),
                _ToolItem(icon: Icons.auto_awesome_outlined, title: l10n.names99, subtitle: l10n.asmaUlHusna, onTap: () => _open(context, const AsmaUlHusnaScreen())),
              ],
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.quranAndHadith, subtitle: l10n.readingAudioSavedKnowledge),
            const SizedBox(height: 10),
            _ToolsGrid(
              items: [
                _ToolItem(icon: Icons.headphones_rounded, title: l10n.audioQuran, subtitle: l10n.audioQuranSubtitle, onTap: () => _open(context, const AudioQuranScreen())),
                _ToolItem(icon: Icons.bookmark_outline_rounded, title: l10n.savedHadith, subtitle: l10n.savedHadithSubtitle, onTap: () => _open(context, const SavedHadithScreen())),
                _ToolItem(icon: Icons.library_books_outlined, title: l10n.islamicBooks, subtitle: l10n.islamicBooksSubtitle, onTap: () => _open(context, const IslamicBooksScreen())),
              ],
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.timeAndDirection, subtitle: l10n.islamicTimeDateQibla),
            const SizedBox(height: 10),
            _ToolsGrid(
              items: [
                _ToolItem(icon: Icons.explore_outlined, title: l10n.qibla, subtitle: l10n.qiblaSubtitle, onTap: () => _open(context, const QiblaScreen())),
                _ToolItem(icon: Icons.calendar_month_outlined, title: l10n.calendar, subtitle: l10n.calendarSubtitle, onTap: () => _open(context, const CalendarScreen())),
              ],
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.islamicCalculations, subtitle: l10n.financialWorshipCalculations),
            const SizedBox(height: 10),
            _ToolsGrid(
              items: [
                _ToolItem(icon: Icons.calculate_outlined, title: l10n.zakatCalculator, subtitle: l10n.zakatCalculatorSubtitle, onTap: () => _open(context, const ZakatCalculatorScreen())),
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
  final AppLocalizations l10n;
  const _ToolsHero({required this.l10n});

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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 17),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: primary.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(15)),
            child: Icon(Icons.auto_awesome_rounded, color: primary, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.toolsHeroTitle, style: TextStyle(color: context.primaryTextColor, fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(l10n.toolsHeroSubtitle, style: TextStyle(color: secondary, fontSize: 11.5, height: 1.45, fontWeight: FontWeight.w500)),
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
        Text(title, style: TextStyle(color: context.primaryTextColor, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(subtitle, style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5, fontWeight: FontWeight.w500)),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 126, crossAxisSpacing: 11, mainAxisSpacing: 11),
      itemBuilder: (context, index) => _ToolCard(item: items[index]),
    );
  }
}

class _ToolItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ToolItem({required this.icon, required this.title, required this.subtitle, required this.onTap});
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.045), blurRadius: 16, offset: const Offset(0, 7))],
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
                  decoration: BoxDecoration(color: primary.withValues(alpha: 0.09), borderRadius: BorderRadius.circular(12)),
                  child: Icon(item.icon, color: primary, size: 21),
                ),
                const Spacer(),
                Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.primaryTextColor, fontSize: 13.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.secondaryTextColor, fontSize: 10.5, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
