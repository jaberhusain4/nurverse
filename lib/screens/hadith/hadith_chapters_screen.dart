// lib/screens/hadith/hadith_chapters_screen.dart

import 'package:flutter/material.dart';

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
  String? _error;
  bool _isLoading = true;
  bool _didLoad = false;

  // ---------------------------------------------------------------------------
  // LANGUAGE
  // ---------------------------------------------------------------------------

  String get _languageCode {
    final locale = Localizations.localeOf(context);

    if (locale.languageCode == 'ar') {
      return 'ar';
    }

    if (locale.languageCode == 'en') {
      return 'en';
    }

    return 'bn';
  }

  bool get _isArabic => _languageCode == 'ar';

  bool get _isEnglish => _languageCode == 'en';

  String get _loadingText {
    if (_isArabic) {
      return 'جارٍ تحميل الفصول...';
    }

    if (_isEnglish) {
      return 'Loading chapters...';
    }

    return 'অধ্যায় লোড হচ্ছে...';
  }

  String get _errorText {
    if (_isArabic) {
      return 'تعذر تحميل الفصول. تحقق من اتصال الإنترنت أو حاول مرة أخرى.';
    }

    if (_isEnglish) {
      return 'Unable to load chapters. Check your internet connection or try again.';
    }

    return 'অধ্যায় লোড করা যায়নি। ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';
  }

  String get _retryText {
    if (_isArabic) {
      return 'حاول مرة أخرى';
    }

    if (_isEnglish) {
      return 'Try again';
    }

    return 'আবার চেষ্টা করুন';
  }

  String get _emptyText {
    if (_isArabic) {
      return 'لا توجد فصول في هذه المجموعة.';
    }

    if (_isEnglish) {
      return 'No chapters are available in this collection.';
    }

    return 'এই গ্রন্থের কোনো অধ্যায় পাওয়া যায়নি।';
  }

  String get _chapterLabel {
    if (_isArabic) {
      return 'الفصل';
    }

    if (_isEnglish) {
      return 'Chapter';
    }

    return 'অধ্যায়';
  }

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didLoad) {
      _didLoad = true;
      _load();
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD
  // ---------------------------------------------------------------------------

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
        languageCode: _languageCode,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _chapters = chapters;
        _isLoading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _chapters = null;
        _error = _errorText;
        _isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // OPEN CHAPTER
  // ---------------------------------------------------------------------------

  void _openChapter(HadithChapter chapter) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HadithListScreen(book: widget.book, chapter: chapter),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final title = _bookTitle();

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  // ---------------------------------------------------------------------------
  // BODY
  // ---------------------------------------------------------------------------

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
              style: TextStyle(fontSize: 13, color: context.secondaryTextColor),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    final chapters = _chapters ?? const <HadithChapter>[];

    if (chapters.isEmpty) {
      return _buildEmptyState();
    }

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
              subtitle: _chapterSubtitle(chapter),
              fallbackTitle: '$_chapterLabel ${index + 1}',
              isArabic: _isArabic,
              onTap: () => _openChapter(chapter),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR STATE
  // ---------------------------------------------------------------------------

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
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

  // ---------------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // BOOK TITLE
  // ---------------------------------------------------------------------------

  String _bookTitle() {
    if (_isArabic) {
      return widget.book.nameEn;
    }

    if (_isEnglish) {
      return widget.book.nameEn;
    }

    return widget.book.nameBn;
  }

  // ---------------------------------------------------------------------------
  // CHAPTER TITLE
  // ---------------------------------------------------------------------------

  String _chapterTitle(HadithChapter chapter) {
    if (_isArabic) {
      if (chapter.nameAr.trim().isNotEmpty) {
        return chapter.nameAr.trim();
      }

      if (chapter.nameEn.trim().isNotEmpty) {
        return chapter.nameEn.trim();
      }

      return chapter.nameBn.trim();
    }

    if (_isEnglish) {
      if (chapter.nameEn.trim().isNotEmpty) {
        return chapter.nameEn.trim();
      }

      if (chapter.nameBn.trim().isNotEmpty) {
        return chapter.nameBn.trim();
      }

      return chapter.nameAr.trim();
    }

    if (chapter.nameBn.trim().isNotEmpty) {
      return chapter.nameBn.trim();
    }

    if (chapter.nameEn.trim().isNotEmpty) {
      return chapter.nameEn.trim();
    }

    return chapter.nameAr.trim();
  }

  // ---------------------------------------------------------------------------
  // CHAPTER SUBTITLE
  // ---------------------------------------------------------------------------

  String _chapterSubtitle(HadithChapter chapter) {
    if (_isArabic) {
      if (chapter.nameEn.trim().isNotEmpty &&
          chapter.nameEn.trim() != chapter.nameAr.trim()) {
        return chapter.nameEn.trim();
      }

      return '';
    }

    if (_isEnglish) {
      if (chapter.nameAr.trim().isNotEmpty) {
        return chapter.nameAr.trim();
      }

      return '';
    }

    if (chapter.nameEn.trim().isNotEmpty) {
      return chapter.nameEn.trim();
    }

    return '';
  }
}

// =============================================================================
// CHAPTER CARD
// =============================================================================

class _ChapterCard extends StatelessWidget {
  final HadithChapter chapter;
  final int index;
  final String title;
  final String subtitle;
  final String fallbackTitle;
  final bool isArabic;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.fallbackTitle,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title.trim().isNotEmpty ? title.trim() : fallbackTitle;

    return NvCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.seaBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          alignment: Alignment.center,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: AppColors.seaBlue,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          displayTitle,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.45,
          ),
        ),
        subtitle:
            subtitle.trim().isEmpty
                ? null
                : Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    subtitle.trim(),
                    textDirection:
                        isArabic ? TextDirection.rtl : TextDirection.ltr,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: context.secondaryTextColor,
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
}
