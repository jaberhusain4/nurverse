import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../localization/app_localizations.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});
  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  List<Map<String, dynamic>> _categories(AppLocalizations l10n) => [
    {'title': l10n.tr('সকাল ও সন্ধ্যার জিকির', 'Morning & Evening Dhikr'), 'icon': Icons.wb_twilight, 'count': 24},
    {'title': l10n.tr('নামাজ ও অজু', 'Prayer & Wudu'), 'icon': Icons.mosque_outlined, 'count': 18},
    {'title': l10n.tr('দৈনন্দিন জীবন', 'Daily Life'), 'icon': Icons.wb_sunny_outlined, 'count': 35},
    {'title': l10n.tr('বিপদ ও দুশ্চিন্তা', 'Hardship & Anxiety'), 'icon': Icons.sentiment_dissatisfied_outlined, 'count': 12},
    {'title': l10n.tr('খাওয়া ও পোশাক', 'Food & Clothing'), 'icon': Icons.restaurant_outlined, 'count': 10},
    {'title': l10n.tr('সফর ও বাহন', 'Travel & Transportation'), 'icon': Icons.directions_bus_outlined, 'count': 8},
    {'title': l10n.tr('ক্ষমা ও তওবা', 'Forgiveness & Tawbah'), 'icon': Icons.favorite_border_rounded, 'count': 14},
  ];

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  List<Map<String, dynamic>> _filtered(AppLocalizations l10n) {
    final query = _query.trim().toLowerCase();
    final categories = _categories(l10n);
    if (query.isEmpty) return categories;
    return categories.where((c) => c['title'].toString().toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final categories = _filtered(l10n);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr("দু'আ ও জিকির", "Dua & Dhikr"), style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [IconButton(tooltip: l10n.tr("সংরক্ষিত দু'আ", "Saved Duas"), icon: const Icon(Icons.bookmark_outline_rounded), onPressed: () => _showComingSoon(context, l10n.tr("সংরক্ষিত দু'আ", "Saved Duas")))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSearchBar(context, l10n),
          const SizedBox(height: 22),
          Text(l10n.tr("আজকের গুরুত্বপূর্ণ দু'আ", "Today's Important Dua"), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _buildDailyDuaCard(context, l10n),
          const SizedBox(height: 24),
          Text(l10n.tr("দু'আ ও জিকিরের বিভাগ", "Dua & Dhikr Categories"), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (categories.isEmpty) _buildEmptySearch(context, l10n) else GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.55),
            itemBuilder: (context, index) => _buildCategoryCard(context, categories[index], l10n),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context); final primary = theme.colorScheme.primary;
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        hintText: l10n.tr("দু'আ বা জিকির খুঁজুন...", 'Search Dua or Dhikr...'),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _query.isEmpty ? null : IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () { _searchController.clear(); setState(() => _query = ''); }),
        filled: true, fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide(color: primary.withValues(alpha: .08))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide(color: primary.withValues(alpha: .08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide(color: primary.withValues(alpha: .35))),
      ),
    );
  }

  Widget _buildDailyDuaCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context); final primary = theme.colorScheme.primary;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: primary.withValues(alpha: .08)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 14, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: primary.withValues(alpha: .10), shape: BoxShape.circle), child: Icon(Icons.auto_awesome_rounded, color: primary)), const SizedBox(width: 12), Expanded(child: Text(l10n.tr("আজকের দু'আ", "Dua of the Day"), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)))]),
        const SizedBox(height: 16),
        Text('رَبِّ زِدْنِي عِلْمًا', textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.9)),
        const SizedBox(height: 10),
        Text(l10n.tr('হে আমার রব, আমার জ্ঞান বৃদ্ধি করুন।', 'My Lord, increase me in knowledge.'), style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
        const SizedBox(height: 12),
        Text(l10n.tr('সূরা ত্ব-হা, ২০:১১৪', 'Surah Taha, 20:114'), style: theme.textTheme.bodySmall?.copyWith(color: primary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [IconButton(tooltip: l10n.tr('শেয়ার', 'Share'), onPressed: () => SharePlus.instance.share(ShareParams(text: "رَبِّ زِدْنِي عِلْمًا\n\n${l10n.tr('হে আমার রব, আমার জ্ঞান বৃদ্ধি করুন।', 'My Lord, increase me in knowledge.')}\n\nNurVerse")), icon: const Icon(Icons.share_outlined))]),
      ]),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category, AppLocalizations l10n) {
    final theme = Theme.of(context); final primary = theme.colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _showComingSoon(context, category['title'].toString()),
      child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: primary.withValues(alpha: .08))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: primary.withValues(alpha: .10), shape: BoxShape.circle), child: Icon(category['icon'] as IconData, color: primary, size: 21)),
        Text(category['title'].toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, height: 1.35)),
        Text(l10n.isBangla ? '${category['count']}টি দু\'আ' : '${category['count']} duas', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
      ])),
    );
  }

  Widget _buildEmptySearch(BuildContext context, AppLocalizations l10n) => Padding(padding: const EdgeInsets.symmetric(vertical: 35), child: Center(child: Text(l10n.tr("কোনো দু'আ পাওয়া যায়নি", 'No Dua found'), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor))));

  void _showComingSoon(BuildContext context, String title) => showDialog<void>(context: context, builder: (context) => AlertDialog(title: Text(title), content: Text(AppLocalizations.of(context).tr('এই বিভাগটি শীঘ্রই আসছে।', 'This section is coming soon.')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context).tr('ঠিক আছে', 'OK')))]));
}
