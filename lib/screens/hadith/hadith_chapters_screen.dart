// lib/screens/hadith/hadith_chapters_screen.dart

import 'package:flutter/material.dart';

import '../../services/hadith_chapter_localization.dart';
import '../../services/hadith_chapter_stats_service.dart';
import '../../services/hadith_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'hadith_list_screen.dart';

class HadithChaptersScreen extends StatefulWidget {
  final HadithBook book;

  const HadithChaptersScreen({super.key, required this.book});

  @override
  State<HadithChaptersScreen> createState() => _HadithChaptersScreenState();
}

class _HadithChaptersScreenState extends State<HadithChaptersScreen> {
  List<HadithChapter>? _chapters;
  Map<int, HadithChapterStats> _stats = const {};
  String? _error;
  bool _isLoading = true;
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _didLoad = true;
      _load();
    }
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final chapters = await HadithService.instance.getChapters(
        widget.book.key,
        languageCode: 'bn',
      );
      final stats = await HadithChapterStatsService.instance.getAllStats(
        widget.book.key,
      );

      if (!mounted) return;

      setState(() {
        _chapters = chapters;
        _stats = stats;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _chapters = null;
        _stats = const {};
        _error = 'অধ্যায় লোড করা যায়নি। আবার চেষ্টা করুন।';
        _isLoading = false;
      });
    }
  }

  void _openChapter(HadithChapter chapter) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HadithListScreen(book: widget.book, chapter: chapter),
      ),
    );
  }

  String _chapterTitle(HadithChapter chapter, int index) {
    return HadithChapterLocalization.localize(
      bengali: chapter.nameBn,
      english: chapter.nameEn,
      arabic: chapter.nameAr,
      chapterIndex: index + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book.nameBn,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
            const SizedBox(height: 14),
            Text(
              'অধ্যায় লোড হচ্ছে...',
              style: TextStyle(
                fontSize: 13,
                color: context.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _load);
    }

    final chapters = _chapters ?? const <HadithChapter>[];
    if (chapters.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 12, AppSpacing.md, 24),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          final stats = _stats[chapter.id];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ChapterCard(
              index: index,
              title: _chapterTitle(chapter, index),
              hadithCount: stats?.count ?? 0,
              onTap: () => _openChapter(chapter),
            ),
          );
        },
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final int index;
  final String title;
  final int hadithCount;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.index,
    required this.title,
    required this.hadithCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final titleColor = context.primaryTextColor;
    final secondary = context.secondaryTextColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
            padding: const EdgeInsets.fromLTRB(15, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _bnDigits(index + 1),
                    style: TextStyle(
                      color: primary,
                      fontSize: 13,
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
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (hadithCount > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${_bnDigits(hadithCount)}টি হাদিস',
                          style: TextStyle(
                            color: secondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: secondary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _bnDigits(int value) {
    const digits = '০১২৩৪৫৬৭৮৯';
    return value
        .toString()
        .split('')
        .map((d) => digits[int.parse(d)])
        .join();
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 46,
              color: context.secondaryTextColor,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.35,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'এই গ্রন্থের কোনো অধ্যায় পাওয়া যায়নি।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: context.secondaryTextColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
