import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'manzil_33_ayat_screen.dart';

class RuqyahScreen extends StatefulWidget {
  const RuqyahScreen({super.key});

  @override
  State<RuqyahScreen> createState() => _RuqyahScreenState();
}

class _RuqyahScreenState extends State<RuqyahScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  String _selectedCategory = 'সব';

  final List<String> _categories = const [
    'সব',
    'কুরআনিক রুকইয়াহ',
    'অসুস্থতা ও ব্যথা',
    'সুরক্ষা',
    'সকাল ও সন্ধ্যা',
  ];

  // Content preserved from the existing Ruqyah screen.
  final List<RuqyahItem> _items = const [
    RuqyahItem(
      id: 'fatiha',
      title: 'সূরা আল-ফাতিহা',
      subtitle: 'রুকইয়াহ হিসেবে কুরআনের সূচনা সূরা',
      category: 'কুরআনিক রুকইয়াহ',
      icon: Icons.menu_book_rounded,
      type: RuqyahType.quran,
      source: 'সহীহ আল-বুখারী ৫৭৩৬–৫৭৩৭',
      repetition: 'নির্দিষ্ট সংখ্যা নির্ধারিত নয়',
      arabic: '''
بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ

الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ

الرَّحْمَٰنِ الرَّحِيمِ

مَالِكِ يَوْمِ الدِّينِ

إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ

اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ

صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ
غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ
وَلَا الضَّالِّينَ
''',
      transliteration: '''
Bismillahir-Rahmanir-Rahim.

Alhamdu lillahi Rabbil-'alamin.

Ar-Rahmanir-Rahim.

Maliki Yawmid-Din.

Iyyaka na'budu wa iyyaka nasta'in.

Ihdinas-siratal-mustaqim.

Siratal-ladhina an'amta 'alayhim,
ghayril-maghdubi 'alayhim
wa lad-dallin.
''',
      translation:
          'পরম করুণাময়, অতি দয়ালু আল্লাহর নামে। সকল প্রশংসা আল্লাহর, যিনি সকল জগতের প্রতিপালক। তিনি পরম করুণাময়, অতি দয়ালু। প্রতিফল দিবসের মালিক। আমরা শুধু আপনারই ইবাদত করি এবং শুধু আপনারই সাহায্য চাই। আমাদের সরল পথ দেখান—তাদের পথ, যাদের আপনি অনুগ্রহ করেছেন; তাদের পথ নয়, যারা গজবপ্রাপ্ত এবং যারা পথভ্রষ্ট।',
      note:
          'এক সাহাবি সূরা আল-ফাতিহা পড়ে একজন দংশিত ব্যক্তির ওপর রুকইয়াহ করেছিলেন এবং সে সুস্থ হয়। নবী ﷺ এটিকে অনুমোদন করেন।',
      referenceUrl: 'Sahih al-Bukhari 5736',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RuqyahItem> get _filteredItems {
    final query = _query.trim().toLowerCase();
    return _items.where((item) {
      final matchesCategory =
          _selectedCategory == 'সব' || item.category == _selectedCategory;
      if (!matchesCategory) return false;
      if (query.isEmpty) return true;
      return item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.translation.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'রুকইয়াহ শরইয়াহ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'রুকইয়াহ সম্পর্কে',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeroCard(context),
                const SizedBox(height: 10),
                _buildManzilCard(context),
                const SizedBox(height: 16),
                _buildSearchBar(context),
                const SizedBox(height: 12),
                _buildCategorySelector(context),
                const SizedBox(height: 18),
                _buildSectionHeader(context),
                const SizedBox(height: 10),
                if (_filteredItems.isEmpty)
                  _buildEmptyState(context)
                else
                  ..._filteredItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildRuqyahCard(context, item),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withValues(alpha: .10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.shield_rounded, color: primary, size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'রুকইয়াহ শরইয়াহ',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'কুরআন ও সহীহ সুন্নাহভিত্তিক আমল',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: .68,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'রুকইয়াহ হলো কুরআনের আয়াত ও বৈধ দু‘আ দ্বারা আল্লাহর কাছে শিফা ও সুরক্ষা চাওয়া। শিফা একমাত্র আল্লাহর পক্ষ থেকেই আসে।',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 11),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.cardColor.withValues(alpha: .72),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_outlined, color: primary, size: 17),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'NurVerse-এ অপ্রমাণিত তাবিজ, মন্ত্র বা নির্দিষ্ট ভিত্তিহীন repetition-কে Sunnah হিসেবে দেখানো হবে না।',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManzilCard(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const Manzil33AyatScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .065),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.shield_moon_rounded, color: primary, size: 22),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '\u09ae\u09a8\u099c\u09bf\u09b2 \u2014 \u09e9\u09e9 \u0986\u09df\u09be\u09a4\u09c7\u09b0 \u0986\u09ae\u09b2',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '\u09aa\u09cd\u09b0\u099a\u09b2\u09bf\u09a4 \u0995\u09c1\u09b0\u0986\u09a8\u09bf\u0995 \u09b8\u0982\u0995\u09b2\u09a8 \u2022 \u0986\u09b0\u09ac\u09bf \u09aa\u09be\u09a0 \u2022 \u0985\u09ab\u09b2\u09be\u0987\u09a8',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        height: 1.35,
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: .62,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: primary.withValues(alpha: .45)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          _selectedCategory == 'সব' ? 'রুকইয়াহ সংগ্রহ' : _selectedCategory,
          style: const TextStyle(
            fontSize: 15,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          '${_filteredItems.length}টি',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: .55),
          ),
        ),
      ],
    );
  }

  // Existing helper methods remain unchanged below this point in the source.
  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        hintText: 'রুকইয়াহ বা দু‘আ খুঁজুন...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      cursorColor: primary,
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = category == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? primary : theme.cardColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: selected ? Colors.white : theme.textTheme.bodyMedium?.color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) => const SizedBox.shrink();

  Widget _buildRuqyahCard(BuildContext context, RuqyahItem item) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => RuqyahDetailScreen(item: item)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: primary, size: 22),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {}
}

class RuqyahItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final RuqyahType type;
  final String source;
  final String repetition;
  final String arabic;
  final String transliteration;
  final String translation;
  final String note;
  final String referenceUrl;

  const RuqyahItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.type,
    required this.source,
    required this.repetition,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.note,
    required this.referenceUrl,
  });
}

enum RuqyahType { quran, dua }

class RuqyahDetailScreen extends StatelessWidget {
  final RuqyahItem item;
  const RuqyahDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title, style: const TextStyle(fontSize: 16))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(item.arabic, textAlign: TextAlign.right, textDirection: TextDirection.rtl),
            const SizedBox(height: 16),
            Text(item.translation, style: const TextStyle(fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
