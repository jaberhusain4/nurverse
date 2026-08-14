import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../localization/app_localizations_x.dart';
import '../services/daily_hadith_service.dart';
import '../services/hadith_service.dart';
import '../theme/app_theme.dart';
import 'hadith/hadith_chapters_screen.dart';

class LocalizedHadithScreen extends StatefulWidget {
  const LocalizedHadithScreen({super.key});

  @override
  State<LocalizedHadithScreen> createState() => _LocalizedHadithScreenState();
}

class _LocalizedHadithScreenState extends State<LocalizedHadithScreen> {
  List<HadithBook> get _collections => kHadithBooks;

  void _openBook(HadithBook book) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HadithChaptersScreen(book: book)),
    );
  }

  Future<void> _refresh() async {
    HadithService.instance.clearCache();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final secondary = context.secondaryTextColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.hadith,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: l10n.tr('হাদিস গ্রন্থ খুঁজুন', 'Search hadith books'),
            onPressed: () => _showSearch(context, l10n),
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
              _hero(context, l10n, secondary),
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
                          l10n.tr('হাদিস গ্রন্থসমূহ', 'Hadith Collections'),
                          style: TextStyle(
                            color: context.primaryTextColor,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.isBangla
                              ? '${_collections.length}টি প্রামাণ্য সংকলন'
                              : '${_collections.length} authentic collections',
                          style: TextStyle(color: secondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _offlineBadge(l10n),
                ],
              ),
              const SizedBox(height: 13),
              ..._collections.map(
                (book) => Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: _collectionCard(
                    context,
                    book,
                    l10n,
                    () => _openBook(book),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero(
    BuildContext context,
    AppLocalizations l10n,
    Color secondary,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 19, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.seaBlue.withValues(alpha: .17),
            AppColors.seaBlue.withValues(alpha: .045),
          ],
        ),
        border: Border.all(color: AppColors.seaBlue.withValues(alpha: .12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.seaBlue.withValues(alpha: .13),
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
                Text(
                  l10n.tr('হাদিসের আলোয় জীবন', 'A Life Guided by Hadith'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.tr(
                    'রাসূলুল্লাহ ﷺ-এর বাণী, কর্ম ও আদর্শ থেকে জ্ঞান অর্জন করুন।',
                    'Learn from the words, actions and example of the Messenger of Allah ﷺ.',
                  ),
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
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    l10n.tr(
                      'জ্ঞান • আমল • আখলাক',
                      'Knowledge • Worship • Character',
                    ),
                    style: const TextStyle(
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

  Widget _offlineBadge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.seaBlue.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 13,
            color: AppColors.seaBlue,
          ),
          const SizedBox(width: 4),
          Text(
            l10n.tr('অফলাইন', 'Offline'),
            style: const TextStyle(
              color: AppColors.seaBlue,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _collectionCard(
    BuildContext context,
    HadithBook book,
    AppLocalizations l10n,
    VoidCallback onTap,
  ) {
    final name = l10n.isBangla ? book.nameBn : book.nameEn;
    final secondaryName = l10n.isBangla ? book.nameEn : book.nameBn;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 12, 11, 12),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.seaBlue.withValues(alpha: .1),
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
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      secondaryName,
                      style: TextStyle(
                        color: context.secondaryTextColor,
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
                  color: AppColors.seaBlue.withValues(alpha: .07),
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
      ),
    );
  }

  void _showSearch(BuildContext context, AppLocalizations l10n) {
    showSearch<HadithBook?>(
      context: context,
      delegate: _HadithSearchDelegate(_collections, l10n),
    ).then((book) {
      if (!mounted || book == null) return;
      _openBook(book);
    });
  }
}

class _TodayHadithCard extends StatefulWidget {
  const _TodayHadithCard();

  @override
  State<_TodayHadithCard> createState() => _TodayHadithCardState();
}

class _TodayHadithCardState extends State<_TodayHadithCard> {
  HadithItem? _hadith;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final hadith = await DailyHadithService.instance.getTodayHadith();
      if (!mounted) return;
      setState(() {
        _hadith = hadith;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hadith = null;
        _error = AppLocalizations.of(context).tr(
          'আজকের হাদিস লোড করা যায়নি।',
          'Today’s hadith could not be loaded.',
        );
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final secondary = context.secondaryTextColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 17),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.seaBlue.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.seaBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dailyHadith,
                      style: const TextStyle(
                        color: AppColors.seaBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.tr(
                        'প্রতিদিন একটি ছোট হাদিস পড়ুন',
                        'Read a short hadith every day',
                      ),
                      style: const TextStyle(
                        fontSize: 10.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.refresh,
                onPressed: _loading ? null : _load,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.refresh_rounded, size: 19),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            Padding(
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
                    const Text('...', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            )
          else if (_error != null || _hadith == null)
            Column(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 31,
                  color: secondary.withValues(alpha: .55),
                ),
                const SizedBox(height: 7),
                Text(
                  _error ??
                      l10n.tr(
                        'আজকের হাদিস পাওয়া যায়নি।',
                        'Today’s hadith is unavailable.',
                      ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: secondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh_rounded, size: 17),
                  label: Text(l10n.tryAgainLabel),
                ),
              ],
            )
          else
            _content(context, _hadith!),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, HadithItem hadith) {
    final l10n = AppLocalizations.of(context);
    final secondary = context.secondaryTextColor;
    final text = hadith.bangla.trim();

    if (text.isEmpty) {
      return Text(
        l10n.tr(
          'আজকের হাদিস পাওয়া যায়নি।',
          'Today’s hadith is unavailable.',
        ),
        textAlign: TextAlign.center,
        style: TextStyle(color: secondary, fontSize: 13),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 13),
      decoration: BoxDecoration(
        color: AppColors.seaBlue.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.seaBlue.withValues(alpha: .075),
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
            style: const TextStyle(
              fontSize: 15,
              height: 1.75,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: AppColors.seaBlue.withValues(alpha: .09),
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
                      ? '${l10n.tr('রেফারেন্স', 'Reference')}: ${hadith.reference}'
                      : '${l10n.hadith}: ${hadith.hadithNo}',
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

class _HadithSearchDelegate extends SearchDelegate<HadithBook?> {
  final List<HadithBook> books;
  final AppLocalizations l10n;

  _HadithSearchDelegate(this.books, this.l10n);

  @override
  String get searchFieldLabel =>
      l10n.tr('হাদিস গ্রন্থ খুঁজুন', 'Search hadith books');

  List<HadithBook> _results(String value) {
    final q = value.trim().toLowerCase();
    if (q.isEmpty) return books;

    return books
        .where(
          (b) =>
              b.nameBn.toLowerCase().contains(q) ||
              b.nameEn.toLowerCase().contains(q) ||
              b.key.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            tooltip: l10n.tr('মুছে ফেলুন', 'Clear'),
            onPressed: () => query = '',
            icon: const Icon(Icons.clear_rounded),
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        tooltip: l10n.tr('ফিরে যান', 'Back'),
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back_rounded),
      );

  @override
  Widget buildResults(BuildContext context) => _list(context);

  @override
  Widget buildSuggestions(BuildContext context) => _list(context);

  Widget _list(BuildContext context) {
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
                l10n.tr(
                  'কোনো হাদিস গ্রন্থ পাওয়া যায়নি',
                  'No hadith collection found',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.primaryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                l10n.tr(
                  'অন্য কোনো নাম দিয়ে আবার চেষ্টা করুন।',
                  'Try another name.',
                ),
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
        final name = l10n.isBangla ? book.nameBn : book.nameEn;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(l10n.isBangla ? book.nameEn : book.nameBn),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => close(context, book),
          ),
        );
      },
    );
  }
}
