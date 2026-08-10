import 'package:flutter/material.dart';

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
  final TextEditingController _searchController = TextEditingController();

  List<HadithBook> get _collections => kHadithBooks;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openBook(HadithBook book) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => HadithChaptersScreen(book: book)));
  }

  void _showSearch() {
    showSearch<HadithBook?>(
      context: context,
      delegate: _HadithSearchDelegate(_collections),
    ).then((book) {
      if (!mounted || book == null) {
        return;
      }

      _openBook(book);
    });
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
            tooltip: 'হাদিস খুঁজুন',
            onPressed: _showSearch,
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            HadithService.instance.clearCache();

            if (mounted) {
              setState(() {});
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              8,
              AppSpacing.md,
              28,
            ),
            children: [
              const _HadithHeroCard(),
              const SizedBox(height: 18),
              _TodayHadithCard(secondary: secondary),
              const SizedBox(height: 24),
              Row(
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
                  Text(
                    'হাদিস গ্রন্থসমূহ',
                    style: TextStyle(
                      color: primary,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'প্রামাণ্য হাদিসের বিভিন্ন সংকলন থেকে পড়ুন',
                style: TextStyle(color: secondary, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 14),
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
// HERO CARD
// =============================================================================

class _HadithHeroCard extends StatelessWidget {
  const _HadithHeroCard();

  @override
  Widget build(BuildContext context) {
    final secondary = context.secondaryTextColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 21, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.seaBlue.withValues(alpha: 0.16),
            AppColors.seaBlue.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: AppColors.seaBlue.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.seaBlue.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.seaBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
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
                const SizedBox(height: 6),
                Text(
                  'রাসূলুল্লাহ ﷺ-এর বাণী, কর্ম ও আদর্শ থেকে জ্ঞান অর্জন করুন।',
                  style: TextStyle(
                    color: secondary,
                    fontSize: 13,
                    height: 1.55,
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
  final Color secondary;

  const _TodayHadithCard({required this.secondary});

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
      final hadith = await HadithService.instance.getTodayHadith();

      if (!mounted) {
        return;
      }

      setState(() {
        _hadith = hadith;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _hadith = null;
        _error = 'আজকের হাদিস লোড করা যায়নি।';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NvCard(
      padding: const EdgeInsets.all(18),
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
                      'প্রতিদিন একটি হাদিস পড়ুন',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'আবার লোড করুন',
                onPressed: _isLoading ? null : _load,
                icon: const Icon(Icons.refresh_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
              const SizedBox(height: 10),
              Text(
                'হাদিস লোড হচ্ছে...',
                style: TextStyle(fontSize: 12, color: widget.secondary),
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
            size: 32,
            color: widget.secondary.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'আজকের হাদিস পাওয়া যায়নি।',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: widget.secondary,
            ),
          ),
          const SizedBox(height: 9),
          TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('আবার চেষ্টা করুন'),
          ),
        ],
      );
    }

    final hadith = _hadith!;

    if (hadith.arabic.isEmpty && hadith.bangla.isEmpty) {
      return Text(
        'এই হাদিসের তথ্য পাওয়া যায়নি।',
        textAlign: TextAlign.center,
        style: TextStyle(color: widget.secondary, fontSize: 13),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hadith.arabic.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
            decoration: BoxDecoration(
              color: AppColors.seaBlue.withValues(alpha: 0.045),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              hadith.arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 19,
                height: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (hadith.bangla.isNotEmpty)
          Text(
            hadith.bangla,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontSize: 15,
              height: 1.8,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (hadith.narrator.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'বর্ণনাকারী: ${hadith.narrator}',
            style: TextStyle(
              color: widget.secondary,
              fontSize: 11.5,
              height: 1.5,
            ),
          ),
        ],
        if (hadith.reference.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'রেফারেন্স: ${hadith.reference}',
            style: TextStyle(color: widget.secondary, fontSize: 11),
          ),
        ],
      ],
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
        padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
        child: Row(
          children: [
            Container(
              width: 49,
              height: 49,
              decoration: BoxDecoration(
                color: AppColors.seaBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: Text(
                _toBanglaNumber(index + 1),
                style: const TextStyle(
                  color: AppColors.seaBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 13),
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
                  const SizedBox(height: 4),
                  Text(
                    book.nameEn,
                    style: TextStyle(
                      color: secondary,
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.seaBlue.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.seaBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _toBanglaNumber(int number) {
    const english = '0123456789';
    const bangla = '০১২৩৪৫৬৭৮৯';

    return number.toString().split('').map((char) {
      final index = english.indexOf(char);
      return index == -1 ? char : bangla[index];
    }).join();
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
  TextStyle? get searchFieldStyle {
    return const TextStyle(fontSize: 15, fontWeight: FontWeight.w500);
  }

  List<HadithBook> _results(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      return books;
    }

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
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

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
