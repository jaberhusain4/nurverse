import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  // ============================================================
  // DUA CATEGORIES
  // Ruqyah intentionally lives separately under Tools.
  // ============================================================

  final List<Map<String, dynamic>> _duaCategories = [
    {'title': 'সকাল ও সন্ধ্যার জিকির', 'icon': Icons.wb_twilight, 'count': 24},
    {'title': 'নামাজ ও অজু', 'icon': Icons.mosque_outlined, 'count': 18},
    {'title': 'দৈনন্দিন জীবন', 'icon': Icons.wb_sunny_outlined, 'count': 35},
    {
      'title': 'বিপদ ও দুশ্চিন্তা',
      'icon': Icons.sentiment_dissatisfied_outlined,
      'count': 12,
    },
    {'title': 'খাওয়া ও পোশাক', 'icon': Icons.restaurant_outlined, 'count': 10},
    {'title': 'সফর ও বাহন', 'icon': Icons.directions_bus_outlined, 'count': 8},
    {
      'title': 'ক্ষমা ও তওবা',
      'icon': Icons.favorite_border_rounded,
      'count': 14,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // FILTERED CATEGORIES
  // ============================================================

  List<Map<String, dynamic>> get _filteredCategories {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) {
      return _duaCategories;
    }

    return _duaCategories.where((category) {
      final title = category['title'].toString().toLowerCase();

      return title.contains(query);
    }).toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'দু\'আ ও জিকির',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'সংরক্ষিত দু\'আ',
            icon: const Icon(Icons.bookmark_outline_rounded),
            onPressed: () {
              _showComingSoon(context, 'সংরক্ষিত দু\'আ');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------
            // SEARCH
            // ----------------------------------------------------
            _buildSearchBar(context),

            const SizedBox(height: 22),

            // ----------------------------------------------------
            // DAILY DUA
            // ----------------------------------------------------
            Text(
              'আজকের গুরুত্বপূর্ণ দু\'আ',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            _buildDailyDuaCard(context),

            const SizedBox(height: 24),

            // ----------------------------------------------------
            // CATEGORIES
            // ----------------------------------------------------
            Text(
              'দু\'আ ও জিকিরের বিভাগ',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            if (_filteredCategories.isEmpty)
              _buildEmptySearch(context)
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.55,
                ),
                itemBuilder: (context, index) {
                  return _buildCategoryCard(
                    context,
                    _filteredCategories[index],
                  );
                },
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _query = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'দু\'আ বা জিকির খুঁজুন...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon:
            _query.isEmpty
                ? null
                : IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _query = '';
                    });
                  },
                ),
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: primary.withValues(alpha: .08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: primary.withValues(alpha: .08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: primary.withValues(alpha: .35)),
        ),
      ),
    );
  }

  // ============================================================
  // DAILY DUA
  // ============================================================

  Widget _buildDailyDuaCard(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: .08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'আজকের দু\'আ',
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const Spacer(),

              IconButton(
                tooltip: 'শেয়ার',
                icon: const Icon(Icons.share_outlined, size: 19),
                onPressed: () {
                  _shareDailyDua();
                },
              ),

              IconButton(
                tooltip: 'বুকমার্ক',
                icon: const Icon(Icons.bookmark_border_rounded, size: 20),
                onPressed: () {
                  _showComingSoon(context, 'বুকমার্ক');
                },
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.8,
              ),
              textAlign: TextAlign.right,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'হে আমাদের রব! আমাদেরকে দুনিয়াতে কল্যাণ দিন এবং আখিরাতেও কল্যাণ দিন এবং আমাদেরকে জাহান্নামের শাস্তি থেকে রক্ষা করুন।',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),

          const SizedBox(height: 10),

          Text(
            'সূরা আল-বাকারা — ২০১',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: .65),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SHARE DAILY DUA
  // ============================================================

  Future<void> _shareDailyDua() async {
    const duaText =
        'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ';

    const translation =
        'হে আমাদের রব! আমাদেরকে দুনিয়াতে কল্যাণ দিন এবং আখিরাতেও কল্যাণ দিন এবং আমাদেরকে জাহান্নামের শাস্তি থেকে রক্ষা করুন।';

    const source = 'সূরা আল-বাকারা — ২০১';

    const shareText = '''
আজকের দু'আ

$duaText

অর্থ:
$translation

$source

— NurVerse
''';

    try {
      await SharePlus.instance.share(
        ShareParams(text: shareText, subject: 'আজকের দু\'আ — NurVerse'),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('দু\'আ শেয়ার করা যায়নি।')));
    }
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _buildCategoryCard(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          _showCategoryMessage(context, category['title'].toString());
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: primary.withValues(alpha: .08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  category['icon'] as IconData,
                  color: primary,
                  size: 22,
                ),
              ),

              const Spacer(),

              Text(
                category['title'].toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                '${category['count']} টি দু\'আ',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: .65,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY SEARCH
  // ============================================================

  Widget _buildEmptySearch(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 42,
            color: primary.withValues(alpha: .55),
          ),

          const SizedBox(height: 10),

          const Text(
            'কোনো দু\'আ পাওয়া যায়নি',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 4),

          Text(
            'অন্য কোনো শব্দ দিয়ে আবার চেষ্টা করুন।',
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: .65),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY MESSAGE
  // ============================================================

  void _showCategoryMessage(BuildContext context, String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$category-এর পূর্ণ দু\'আসমূহ শীঘ্রই যুক্ত করা হবে ইনশাআল্লাহ।',
        ),
      ),
    );
  }

  // ============================================================
  // COMING SOON
  // ============================================================

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature ফিচারটি শীঘ্রই যুক্ত করা হবে ইনশাআল্লাহ।'),
      ),
    );
  }
}
