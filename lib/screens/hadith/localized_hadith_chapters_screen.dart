import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../localization/app_localizations_x.dart';
import '../../services/hadith_chapter_localization.dart';
import '../../services/hadith_chapter_stats_service.dart';
import '../../services/hadith_service.dart';
import '../../theme/app_theme.dart';
import 'localized_hadith_list_screen.dart';

class LocalizedHadithChaptersScreen extends StatefulWidget {
  final HadithBook book;
  const LocalizedHadithChaptersScreen({super.key, required this.book});
  @override
  State<LocalizedHadithChaptersScreen> createState() => _LocalizedHadithChaptersScreenState();
}

class _LocalizedHadithChaptersScreenState extends State<LocalizedHadithChaptersScreen> {
  List<HadithChapter>? _chapters;
  Map<int, HadithChapterStats> _stats = const {};
  String? _error;
  bool _loading = true;
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
    final languageCode = AppLocalizations.of(context).locale.languageCode;
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final chapters = await HadithService.instance.getChapters(
        widget.book.key,
        languageCode: languageCode,
      );
      final stats = await HadithChapterStatsService.instance.getAllStats(widget.book.key);
      if (!mounted) return;
      setState(() { _chapters = chapters; _stats = stats; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _chapters = null;
        _stats = const {};
        _error = AppLocalizations.of(context).tr(
          'অধ্যায় লোড করা যায়নি। আবার চেষ্টা করুন।',
          'Could not load chapters. Please try again.',
        );
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n.isArabic
        ? (widget.book.key == 'bukhari'
            ? 'صحيح البخاري'
            : widget.book.key == 'muslim'
                ? 'صحيح مسلم'
                : widget.book.nameEn)
        : l10n.isBangla
            ? widget.book.nameBn
            : widget.book.nameEn;
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(child: _body(context, l10n)),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.6)),
            const SizedBox(height: 14),
            Text(l10n.tr('অধ্যায় লোড হচ্ছে...', 'Loading chapters...'), style: TextStyle(fontSize: 13, color: context.secondaryTextColor)),
          ],
        ),
      );
    }
    if (_error != null) return _errorState(context, l10n, _error!);
    final chapters = _chapters ?? const <HadithChapter>[];
    if (chapters.isEmpty) {
      return Center(
        child: Text(
          l10n.isArabic
              ? 'لم يتم العثور على فصول في هذه المجموعة.'
              : l10n.tr('এই গ্রন্থের কোনো অধ্যায় পাওয়া যায়নি।', 'No chapters were found in this collection.'),
          textAlign: TextAlign.center,
          style: TextStyle(color: context.secondaryTextColor),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 12, AppSpacing.md, 24),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          final title = l10n.isArabic
              ? (chapter.nameAr.trim().isNotEmpty ? chapter.nameAr.trim() : 'الفصل ${index + 1}')
              : l10n.isBangla
                  ? HadithChapterLocalization.localize(
                      bengali: chapter.nameBn,
                      english: chapter.nameEn,
                      arabic: chapter.nameAr,
                      chapterIndex: index + 1,
                    )
                  : (chapter.nameEn.trim().isNotEmpty ? chapter.nameEn.trim() : 'Chapter ${index + 1}');
          final stats = _stats[chapter.id];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _chapterCard(
              context,
              l10n,
              index,
              title,
              stats?.count ?? 0,
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LocalizedHadithListScreen(book: widget.book, chapter: chapter),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chapterCard(BuildContext context, AppLocalizations l10n, int index, String title, int count, VoidCallback onTap) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 14, 12, 14),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.seaBlue.withValues(alpha: .10),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _digits(index + 1, l10n),
                    style: TextStyle(color: AppColors.seaBlue, fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.primaryTextColor, fontSize: 15, height: 1.45, fontWeight: FontWeight.w700)),
                      if (count > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          l10n.isArabic
                              ? '$count حديثًا'
                              : l10n.isBangla
                                  ? '${_digits(count, l10n)}টি হাদিস'
                                  : '$count hadiths',
                          style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.seaBlue, size: 22),
              ],
            ),
          ),
        ),
      );

  String _digits(int value, AppLocalizations l10n) {
    if (l10n.isBangla) {
      const d = '০১২৩৪৫৬৭৮৯';
      return value.toString().split('').map((x) => d[int.parse(x)]).join();
    }
    if (l10n.isArabic) {
      const d = '٠١٢٣٤٥٦٧٨٩';
      return value.toString().split('').map((x) => d[int.parse(x)]).join();
    }
    return value.toString();
  }

  Widget _errorState(BuildContext context, AppLocalizations l10n, String message) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 46, color: context.secondaryTextColor),
              const SizedBox(height: 14),
              Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 1.55, color: context.primaryTextColor)),
              const SizedBox(height: 18),
              FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh_rounded), label: Text(l10n.tryAgainLabel)),
            ],
          ),
        ),
      );
}
