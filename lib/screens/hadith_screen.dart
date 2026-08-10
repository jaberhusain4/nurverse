import 'package:flutter/material.dart';

import '../services/daily_hadith_service.dart';
import '../services/hadith_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'hadith/hadith_chapters_screen.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  List<HadithBook> get _collections => kHadithBooks;

  void _openBook(HadithBook book) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HadithChaptersScreen(book: book)),
    );
  }

  void _showSearch() {
    showSearch<HadithBook?>(
      context: context,
      delegate: _HadithSearchDelegate(_collections),
    ).then((book) {
      if (!mounted || book == null) return;
      _openBook(book);
    });
  }

  Future<void> _refresh() async {
    HadithService.instance.clearCache();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryTextColor;
    final secondary = context.secondaryTextColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'হাদিস',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'হাদিস গ্রন্থ খুঁজুন',
            onPressed: _showSearch,
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              8,
              AppSpacing.md,
              30,
            ),
            children: [
              const _HadithHeroCard(),
              const SizedBox(height: 16),
              const _TodayHadithCard(),
              const SizedBox(height: 25),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 4,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.seaBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'হাদিস গ্রন্থসমূহ',
                          style: TextStyle(
                            color: primary,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_collections.length}টি প্রামাণ্য সংকলন',
                          style: TextStyle(
                            color: secondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.seaBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 13,
                          color: AppColors.seaBlue,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'অফলাইন',
                          style: TextStyle(
                            color: AppColors.seaBlue,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              ...List.generate(_collections.length, (index) {
                final book = _collections[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: _HadithCollectionCard(
                    book: book,
                    index: index,
                    onTap: () => _openBook(book),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// HERO
// =============================================================================

class _HadithHeroCard extends StatelessWidget {
  const _HadithHeroCard();

  @override
  Widget build(BuildContext context) {
    final secondary = context.secondaryTextColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 19, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.seaBlue.withValues(alpha: 0.17),
            AppColors.seaBlue.withValues(alpha: 0.045),
          ],
        ),
        border: Border.all(
          color: AppColors.seaBlue.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.seaBlue.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.seaBlue,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'হাদিসের আলোয় জীবন',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'রাসূলুল্লাহ ﷺ-এর বাণী, কর্ম ও আদর্শ থেকে জ্ঞান অর্জন করুন।',
                  style: TextStyle(
                    color: secondary,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Text(
                    'জ্ঞান • আমল • আখলাক',
                    style: TextStyle(
                      color: AppColors.seaBlue,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
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
}

// =============================================================================
// TODAY'S HADITH
// =============================================================================

class _TodayHadithCard extends StatefulWidget {
  const _TodayHadithCard();

  @override
  State<_TodayHadithCard> createState() => _TodayHadithCardState();
}

class _TodayHadithCardState extends State<_TodayHadithCard> {
  HadithItem? _hadith;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final hadith = await DailyHadithService.instance.getTodayHadith();

      if (!mounted) return;

      setState(() {
        _hadith = hadith;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hadith = null;
        _error = 'আজকের হাদিস লোড করা যায়নি।';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final secondary = context.secondaryTextColor;

    return NvCard(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.seaBlue.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.seaBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'আজকের হাদিস',
                      style: TextStyle(
                        color: AppColors.seaBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'প্রতিদিন একটি ছোট হাদিস পড়ুন',
                      style: TextStyle(
                        fontSize: 10.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'আবার লোড করুন',
                onPressed: _isLoading ? null : _load,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.refresh_rounded, size: 19),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildContent(secondary),
        ],
      ),
    );
  }

  Widget _buildContent(Color secondary) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.1),
              ),
              const SizedBox(height: 9),
              Text(
                'হাদিস লোড হচ্ছে...',
                style: TextStyle(fontSize: 12, color: secondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null || _hadith == null) {
      return Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 31,
            color: secondary.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 7),
          Text(
            _error ?? 'আজকের হাদিস পাওয়া যায়নি।',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.5, color: secondary),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('আবার চেষ্টা করুন'),
          ),
        ],
      );
    }

    final hadith = _hadith!;
    final text = hadith.bangla.trim();

    if (text.isEmpty) {
      return Text(
        'আজকের হাদিস পাওয়া যায়নি।',
        textAlign: TextAlign.center,
        style: TextStyle(color: secondary, fontSize: 13),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 13),
      decoration: BoxDecoration(
        color: AppColors.seaBlue.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.seaBlue.withValues(alpha: 0.075),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: AppColors.seaBlue,
            size: 23,
          ),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 15,
              height: 1.75,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: AppColors.seaBlue.withValues(alpha: 0.09),
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 14,
                color: AppColors.seaBlue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hadith.reference.isNotEmpty
                      ? 'রেফারেন্স: ${hadith.reference}'
                      : 'হাদিস: ${hadith.hadithNo}',
                  style: TextStyle(
                    color: secondary,
                    fontSize: 10.8,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COLLECTION CARD
// =============================================================================

class _HadithCollectionCard extends StatelessWidget {
  final HadithBook book;
  final int index;
  final VoidCallback onTap;

  const _HadithCollectionCard({
    required this.book,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = context.secondaryTextColor;

    return NvCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(13, 12, 11, 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.seaBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.seaBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.nameBn,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book.nameEn,
                    style: TextStyle(
                      color: secondary,
                      fontSize: 11.2,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 33,
              height: 33,
              decoration: BoxDecoration(
                color: AppColors.seaBlue.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColors.seaBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SEARCH
// =============================================================================

class _HadithSearchDelegate extends SearchDelegate<HadithBook?> {
  final List<HadithBook> books;

  _HadithSearchDelegate(this.books);

  @override
  String get searchFieldLabel => 'হাদিস গ্রন্থ খুঁজুন';

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      );

  List<HadithBook> _results(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return books;

    return books.where((book) {
      return book.nameBn.toLowerCase().contains(q) ||
          book.nameEn.toLowerCase().contains(q) ||
          book.key.toLowerCase().contains(q);
    }).toList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'মুছে ফেলুন',
          onPressed: () => query = '',
          icon: const Icon(Icons.clear_rounded),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'ফিরে যান',
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final results = _results(query);

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 44,
                color: context.secondaryTextColor,
              ),
              const SizedBox(height: 12),
              Text(
                'কোনো হাদিস গ্রন্থ পাওয়া যায়নি',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.primaryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'অন্য কোনো নাম দিয়ে আবার চেষ্টা করুন।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.secondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final book = results[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _HadithCollectionCard(
            book: book,
            index: index,
            onTap: () => close(context, book),
          ),
        );
      },
    );
  }
}
