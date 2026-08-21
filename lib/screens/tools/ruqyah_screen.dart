import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/quran_surah.dart';
import '../../services/quran_data_service.dart';
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
    'সুরক্ষা',
    'সকাল ও সন্ধ্যা',
  ];

  final List<RuqyahItem> _items = const [
    RuqyahItem(
      id: 'fatiha',
      title: 'সূরা আল-ফাতিহা',
      subtitle: 'রুকইয়াহ হিসেবে সরাসরি প্রমাণিত',
      category: 'কুরআনিক রুকইয়াহ',
      icon: Icons.menu_book_rounded,
      type: RuqyahType.quran,
      source: 'সহীহ আল-বুখারী ৫৭৩৬',
      repetition: 'নির্দিষ্ট সংখ্যা নির্ধারিত নয়',
      surahNumber: 1,
      from: 1,
      to: 7,
      translation:
          'এক সাহাবি সূরা আল-ফাতিহা পড়ে একজন দংশিত ব্যক্তির ওপর রুকইয়াহ করেছিলেন এবং সে সুস্থ হয়। নবী ﷺ এটিকে অনুমোদন করেন।',
      note:
          'সূরা আল-ফাতিহা দিয়ে রুকইয়াহ করার সরাসরি সহীহ হাদিস রয়েছে।',
      referenceUrl: 'Sahih al-Bukhari 5736',
    ),
    RuqyahItem(
      id: 'ayatul-kursi',
      title: 'আয়াতুল কুরসি',
      subtitle: 'সূরা আল-বাকারা ২:২৫৫ — তাওহীদ ও আল্লাহর হিফাজতের আয়াত',
      category: 'কুরআনিক রুকইয়াহ',
      icon: Icons.shield_rounded,
      type: RuqyahType.quran,
      source: 'সূরা আল-বাকারা ২:২৫৫',
      repetition: 'নির্দিষ্ট রুকইয়াহ সংখ্যা নির্ধারিত নয়',
      surahNumber: 2,
      from: 255,
      to: 255,
      translation: 'আয়াতুল কুরসি।',
      note:
          'এটি কুরআনের একটি গুরুত্বপূর্ণ আয়াত। NurVerse এটিকে নির্দিষ্ট রুকইয়াহ repetition হিসেবে দাবি করছে না।',
      referenceUrl: 'Quran 2:255',
    ),
    RuqyahItem(
      id: 'baqarah-last-two',
      title: 'সূরা আল-বাকারা ২:২৮৫–২৮৬',
      subtitle: 'শেষ দুই আয়াত — ঈমান, ক্ষমা ও সাহায্যের দো‘আ',
      category: 'সুরক্ষা',
      icon: Icons.security_rounded,
      type: RuqyahType.quran,
      source: 'সূরা আল-বাকারা ২:২৮৫–২৮৬',
      repetition: 'রাতের আমল হিসেবে প্রসিদ্ধ',
      surahNumber: 2,
      from: 285,
      to: 286,
      translation: 'সূরা আল-বাকারার শেষ দুই আয়াত।',
      note:
          'সহীহ হাদিসে রাতের বেলায় এ দুই আয়াত পাঠের ফযীলত এসেছে।',
      referenceUrl: 'Quran 2:285-286',
    ),
    RuqyahItem(
      id: 'araf-magic',
      title: 'সূরা আল-আ‘রাফ ৭:১১৭–১২২',
      subtitle: 'মূসা (আ.)-এর জাদু বাতিলের ঘটনার আয়াত',
      category: 'কুরআনিক রুকইয়াহ',
      icon: Icons.auto_awesome_rounded,
      type: RuqyahType.quran,
      source: 'সূরা আল-আ‘রাফ ৭:১১৭–১২২',
      repetition: 'নির্দিষ্ট সংখ্যা নির্ধারিত নয়',
      surahNumber: 7,
      from: 117,
      to: 122,
      translation: 'মূসা (আ.)-এর সঙ্গে জাদুকরদের ঘটনার কুরআনিক আয়াতসমূহ।',
      note:
          'এই অংশে আল্লাহর সাহায্যে বাতিল ও জাদুর ব্যর্থতার ঘটনা বর্ণিত হয়েছে। নির্দিষ্ট repetition-কে Sunnah বলা হচ্ছে না।',
      referenceUrl: 'Quran 7:117-122',
    ),
    RuqyahItem(
      id: 'yunus-magic',
      title: 'সূরা ইউনুস ১০:৮১–৮২',
      subtitle: 'জাদু বাতিল হওয়া ও আল্লাহর সত্য প্রতিষ্ঠার আয়াত',
      category: 'কুরআনিক রুকইয়াহ',
      icon: Icons.bolt_rounded,
      type: RuqyahType.quran,
      source: 'সূরা ইউনুস ১০:৮১–৮২',
      repetition: 'নির্দিষ্ট সংখ্যা নির্ধারিত নয়',
      surahNumber: 10,
      from: 81,
      to: 82,
      translation: 'মূসা (আ.) ও জাদুকরদের ঘটনার আয়াত।',
      note:
          'এই আয়াতগুলোতে আল্লাহ জাদু বাতিল করে দেবেন এবং মুফসিদদের কাজ সফল করেন না—এ কথা এসেছে।',
      referenceUrl: 'Quran 10:81-82',
    ),
    RuqyahItem(
      id: 'taha-magic',
      title: 'সূরা ত্ব-হা ২০:৬৮–৭০',
      subtitle: 'ভয় না পাওয়ার নির্দেশ ও জাদুর পরাজয়ের আয়াত',
      category: 'কুরআনিক রুকইয়াহ',
      icon: Icons.wb_sunny_outlined,
      type: RuqyahType.quran,
      source: 'সূরা ত্ব-হা ২০:৬৮–৭০',
      repetition: 'নির্দিষ্ট সংখ্যা নির্ধারিত নয়',
      surahNumber: 20,
      from: 68,
      to: 70,
      translation: 'মূসা (আ.)-কে সান্ত্বনা ও জাদুকরদের পরাজয়ের আয়াতসমূহ।',
      note:
          'রুকইয়াহর জন্য কুরআনের আয়াত ব্যবহার করার ক্ষেত্রে এটি একটি প্রচলিত Quranic passage; নির্দিষ্ট সংখ্যা শরিয়ত-নির্ধারিত বলা হচ্ছে না।',
      referenceUrl: 'Quran 20:68-70',
    ),
    RuqyahItem(
      id: 'muminun',
      title: 'সূরা আল-মু’মিনূন ২৩:১১৫–১১৮',
      subtitle: 'আল্লাহর সৃষ্টির উদ্দেশ্য, তাওহীদ ও রহমতের আয়াত',
      category: 'কুরআনিক রুকইয়াহ',
      icon: Icons.favorite_outline_rounded,
      type: RuqyahType.quran,
      source: 'সূরা আল-মু’মিনূন ২৩:১১৫–১১৮',
      repetition: 'নির্দিষ্ট সংখ্যা নির্ধারিত নয়',
      surahNumber: 23,
      from: 115,
      to: 118,
      translation: 'সূরা আল-মু’মিনূনের শেষাংশের নির্বাচিত আয়াত।',
      note: 'আল্লাহর রাজত্ব, তাওহীদ, ক্ষমা ও রহমতের অর্থবহ আয়াতসমূহ।',
      referenceUrl: 'Quran 23:115-118',
    ),
    RuqyahItem(
      id: 'isra-shifa',
      title: 'সূরা আল-ইসরা ১৭:৮১–৮২',
      subtitle: 'সত্যের আগমন, বাতিলের বিলুপ্তি এবং কুরআনের শিফা',
      category: 'কুরআনিক রুকইয়াহ',
      icon: Icons.healing_rounded,
      type: RuqyahType.quran,
      source: 'সূরা আল-ইসরা ১৭:৮১–৮২',
      repetition: 'নির্দিষ্ট সংখ্যা নির্ধারিত নয়',
      surahNumber: 17,
      from: 81,
      to: 82,
      translation: 'সত্যের বিজয় ও মুমিনদের জন্য কুরআনের শিফা ও রহমতের আয়াত।',
      note:
          'আয়াত ৮২-এ কুরআনকে মুমিনদের জন্য শিফা ও রহমত বলা হয়েছে।',
      referenceUrl: 'Quran 17:81-82',
    ),
    RuqyahItem(
      id: 'ikhlas',
      title: 'সূরা আল-ইখলাস',
      subtitle: 'মু‘আউইযাতের অন্তর্ভুক্ত',
      category: 'সুরক্ষা',
      icon: Icons.shield_outlined,
      type: RuqyahType.quran,
      source: 'সহীহ আল-বুখারী ৫৭৩৫',
      repetition: 'মু‘আউইযাতের আমল',
      surahNumber: 112,
      from: 1,
      to: 4,
      translation: 'আল্লাহর একত্ব ও অমুখাপেক্ষিতার ঘোষণা।',
      note:
          'রাসূলুল্লাহ ﷺ মু‘আউইযাত পাঠ করে নিজের ওপর ফুঁ দিতেন।',
      referenceUrl: 'Sahih al-Bukhari 5735',
    ),
    RuqyahItem(
      id: 'falaq',
      title: 'সূরা আল-ফালাক',
      subtitle: 'বাহ্যিক অনিষ্ট থেকে আশ্রয়',
      category: 'সুরক্ষা',
      icon: Icons.wb_twilight_rounded,
      type: RuqyahType.quran,
      source: 'সহীহ আল-বুখারী ৫৭৩৫',
      repetition: 'মু‘আউইযাতের আমল',
      surahNumber: 113,
      from: 1,
      to: 5,
      translation: 'সৃষ্টির অনিষ্ট, অন্ধকার, গিরায় ফুঁ দেওয়া ও হিংসুকের অনিষ্ট থেকে আশ্রয়।',
      note:
          'রাসূলুল্লাহ ﷺ মু‘আউইযাত পাঠ করে নিজের ওপর ফুঁ দিতেন।',
      referenceUrl: 'Sahih al-Bukhari 5735',
    ),
    RuqyahItem(
      id: 'nas',
      title: 'সূরা আন-নাস',
      subtitle: 'ওয়াসওয়াসা ও শয়তানের অনিষ্ট থেকে আশ্রয়',
      category: 'সুরক্ষা',
      icon: Icons.security_rounded,
      type: RuqyahType.quran,
      source: 'সহীহ আল-বুখারী ৫৭৩৫',
      repetition: 'মু‘আউইযাতের আমল',
      surahNumber: 114,
      from: 1,
      to: 6,
      translation: 'মানুষের অন্তরে কুমন্ত্রণা দেওয়া জিন ও মানুষের অনিষ্ট থেকে আশ্রয়।',
      note:
          'রাসূলুল্লাহ ﷺ মু‘আউইযাত পাঠ করে নিজের ওপর ফুঁ দিতেন।',
      referenceUrl: 'Sahih al-Bukhari 5735',
    ),
    RuqyahItem(
      id: 'morning-protection',
      title: 'সকাল-সন্ধ্যার সুরক্ষার দু‘আ',
      subtitle: '“বিসমিল্লাহিল্লাযী লা ইয়াদুররু...”',
      category: 'সকাল ও সন্ধ্যা',
      icon: Icons.wb_sunny_outlined,
      type: RuqyahType.dua,
      source: 'জামে‘ আত-তিরমিযী ৩৩৮৮',
      repetition: 'সকাল ও সন্ধ্যায় ৩ বার',
      arabic: '''بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ''',
      translation:
          'আল্লাহর নামে, যাঁর নামের সাথে পৃথিবী ও আকাশে কোনো কিছুই ক্ষতি করতে পারে না। তিনি সর্বশ্রোতা, সর্বজ্ঞ।',
      note: 'হাদিসে সকাল ও সন্ধ্যায় এই দু‘আ তিনবার বলার কথা এসেছে।',
      referenceUrl: 'Jami at-Tirmidhi 3388',
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.shield_rounded, color: primary, size: 24),
              ),
              const SizedBox(width: 11),
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
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            'কুরআনের আয়াত ও বৈধ দু‘আ দ্বারা আল্লাহর কাছে শিফা ও সুরক্ষা চাওয়া। শিফা একমাত্র আল্লাহর পক্ষ থেকেই আসে।',
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.45),
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
              const Expanded(
                child: Text(
                  'মনজিল — ৩৩ আয়াতের আমল',
                  style: TextStyle(fontSize: 15, height: 1.3, fontWeight: FontWeight.w700),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: primary.withValues(alpha: .45)),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildSectionHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          _selectedCategory == 'সব' ? 'রুকইয়াহ সংগ্রহ' : _selectedCategory,
          style: const TextStyle(fontSize: 15, height: 1.35, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        Text(
          '${_filteredItems.length}টি',
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
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
                    Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(item.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, height: 1.3)),
                    const SizedBox(height: 5),
                    Text(item.source, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: primary.withValues(alpha: .5)),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Text(
          'রুকইয়াহ হলো কুরআনের আয়াত ও বৈধ দু‘আ দ্বারা আল্লাহর কাছে শিফা ও সুরক্ষা চাওয়া। NurVerse নির্দিষ্ট ভিত্তিহীন repetition-কে Sunnah হিসেবে উপস্থাপন করে না।',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
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
  final int? surahNumber;
  final int? from;
  final int? to;
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
    this.surahNumber,
    this.from,
    this.to,
    this.arabic = '',
    this.transliteration = '',
    required this.translation,
    required this.note,
    required this.referenceUrl,
  });

  bool get isQuran => surahNumber != null && from != null && to != null;
}

enum RuqyahType { quran, dua }

class RuqyahDetailScreen extends StatefulWidget {
  final RuqyahItem item;
  const RuqyahDetailScreen({super.key, required this.item});

  @override
  State<RuqyahDetailScreen> createState() => _RuqyahDetailScreenState();
}

class _RuqyahDetailScreenState extends State<RuqyahDetailScreen> {
  final _quran = QuranDataService.instance;
  bool _loadingQuran = false;
  QuranSurah? _surah;

  @override
  void initState() {
    super.initState();
    if (widget.item.isQuran) _loadQuran();
  }

  Future<void> _loadQuran() async {
    setState(() => _loadingQuran = true);
    await _quran.init();
    if (!mounted) return;
    final surah = _quran.getSurah(widget.item.surahNumber!);
    setState(() {
      _surah = surah;
      _loadingQuran = false;
    });
  }

  String _ar(int number) {
    const digits = '٠١٢٣٤٥٦٧٨٩';
    return number.toString().split('').map((d) => digits[int.parse(d)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: _loadingQuran
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
              children: [
                _buildMetaCard(context),
                const SizedBox(height: 10),
                if (widget.item.isQuran && _surah != null)
                  _buildQuranReading(context, primary)
                else
                  _buildDuaReading(context),
              ],
            ),
    );
  }

  Widget _buildMetaCard(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.item.subtitle, style: const TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          Text(widget.item.source, style: TextStyle(fontSize: 11, color: primary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(widget.item.repetition, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildQuranReading(BuildContext context, Color primary) {
    final verses = _surah!.verses
        .where((v) => v.number >= widget.item.from! && v.number <= widget.item.to!)
        .toList();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(13, 14, 13, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              ...verses.map(
                (verse) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: verse.arabic.trim(),
                              style: const TextStyle(
                                fontSize: 20,
                                height: 1.58,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: '  ۝${_ar(verse.number)}',
                              style: TextStyle(
                                color: primary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildTranslationSection(context, verses),
        const SizedBox(height: 10),
        _buildNoteCard(context),
      ],
    );
  }

  Widget _buildTranslationSection(BuildContext context, List<QuranVerse> verses) {
    final primary = Theme.of(context).colorScheme.primary;
    final translated = verses.where((v) => v.bangla != null && v.bangla!.trim().isNotEmpty).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('বাংলা অর্থ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primary)),
          const SizedBox(height: 7),
          if (translated.isEmpty)
            Text(widget.item.translation, style: const TextStyle(fontSize: 13, height: 1.5))
          else
            ...translated.map((v) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text('${v.number}. ${v.bangla!.trim()}', style: const TextStyle(fontSize: 13, height: 1.5)),
            )),
        ],
      ),
    );
  }

  Widget _buildDuaReading(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.item.arabic.trim(),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.65,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withValues(alpha: .72),
                      width: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .045),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(widget.item.translation, style: const TextStyle(fontSize: 13, height: 1.5)),
        ),
        const SizedBox(height: 10),
        _buildNoteCard(context),
      ],
    );
  }

  Widget _buildNoteCard(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .035),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('নোট', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primary)),
          const SizedBox(height: 5),
          Text(widget.item.note, style: const TextStyle(fontSize: 12.5, height: 1.5)),
        ],
      ),
    );
  }
}
