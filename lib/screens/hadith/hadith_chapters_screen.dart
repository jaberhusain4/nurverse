// lib/screens/hadith/hadith_chapters_screen.dart

import 'package:flutter/material.dart';

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

  String get _loadingText => 'অধ্যায় লোড হচ্ছে...';
  String get _errorText => 'অধ্যায় লোড করা যায়নি। আবার চেষ্টা করুন।';
  String get _retryText => 'আবার চেষ্টা করুন';
  String get _emptyText => 'এই গ্রন্থের কোনো অধ্যায় পাওয়া যায়নি।';
  String get _chapterLabel => 'অধ্যায়';

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
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _chapters = null;
        _stats = const {};
        _error = _errorText;
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
              _loadingText,
              style: TextStyle(
                fontSize: 13,
                color: context.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) return _buildErrorState();

    final chapters = _chapters ?? const <HadithChapter>[];
    if (chapters.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ChapterCard(
              chapter: chapter,
              index: index,
              title: _chapterTitle(chapter),
              fallbackTitle: '$_chapterLabel ${_bnDigits(index + 1)}',
              stats: _stats[chapter.id],
              onTap: () => _openChapter(chapter),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
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
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(_retryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.35,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _emptyText,
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
      ),
    );
  }

  String _chapterTitle(HadithChapter chapter) {
    if (chapter.nameBn.trim().isNotEmpty) return chapter.nameBn.trim();
    if (chapter.nameAr.trim().isNotEmpty) return chapter.nameAr.trim();
    if (chapter.nameEn.trim().isNotEmpty) return chapter.nameEn.trim();
    return '';
  }

  static String _bnDigits(int value) {
    const western = '0123456789';
    const bengali = '০১২৩৪৫৬৭৮৯';

    return value
        .toString()
        .split('')
        .map((digit) => bengali[western.indexOf(digit)])
        .join();
  }
}

class _ChapterCard extends StatelessWidget {
  final HadithChapter chapter;
  final int index;
  final String title;
  final String fallbackTitle;
  final HadithChapterStats? stats;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
    required this.index,
    required this.title,
    required this.fallbackTitle,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title.trim().isNotEmpty ? title.trim() : fallbackTitle;

    final statsText = stats == null
        ? 'হাদিসের সংখ্যা পাওয়া যায়নি'
        : 'মোট ${_bnDigits(stats!.count)}টি হাদিস • ${_bnDigits(stats!.firstHadith)} থেকে ${_bnDigits(stats!.lastHadith)}';

    return NvCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.seaBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          alignment: Alignment.center,
          child: Text(
            _bnDigits(index + 1),
            style: const TextStyle(
              color: AppColors.seaBlue,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          displayTitle,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.45,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            statsText,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color: context.secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.seaBlue,
        ),
      ),
    );
  }

  static String _bnDigits(int value) {
    const western = '0123456789';
    const bengali = '০১২৩৪৫৬৭৮৯';

    return value
        .toString()
        .split('')
        .map((digit) => bengali[western.indexOf(digit)])
        .join();
  }
}
