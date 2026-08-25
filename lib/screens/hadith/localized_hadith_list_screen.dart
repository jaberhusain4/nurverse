import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../localization/app_localizations.dart';
import '../../localization/app_localizations_x.dart';
import '../../models/saved_hadith.dart';
import '../../services/hadith_bookmark_service.dart';
import '../../services/hadith_chapter_localization.dart';
import '../../services/hadith_service.dart';
import '../../theme/app_theme.dart';
import 'saved_hadith_screen.dart';

class LocalizedHadithListScreen extends StatefulWidget {
  final HadithBook book;
  final HadithChapter chapter;

  const LocalizedHadithListScreen({super.key, required this.book, required this.chapter});

  @override
  State<LocalizedHadithListScreen> createState() => _LocalizedHadithListScreenState();
}

class _LocalizedHadithListScreenState extends State<LocalizedHadithListScreen> {
  List<HadithItem>? _hadiths;
  String? _error;
  bool _loading = true;
  bool _didLoad = false;
  final Set<String> _saved = <String>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _didLoad = true;
      _load();
    }
  }

  String _key(HadithItem h) => HadithBookmarkService.instance.buildKey(
        bookKey: widget.book.key,
        hadithNo: h.hadithNo,
        arabic: h.arabic,
      );

  String _content(HadithItem h, AppLocalizations l10n) {
    if (l10n.isArabic) return h.arabic.trim();
    if (l10n.isEnglish) return h.english.trim().isNotEmpty ? h.english.trim() : h.bangla.trim();
    return h.bangla.trim();
  }

  String _contentLabel(AppLocalizations l10n) {
    if (l10n.isArabic) return 'العربية';
    return l10n.isBangla ? 'বাংলা অনুবাদ' : 'Translation';
  }

  String _bookTitle(AppLocalizations l10n) {
    if (l10n.isBangla) return widget.book.nameBn;
    if (l10n.isArabic) {
      switch (widget.book.key) {
        case 'bukhari':
          return 'صحيح البخاري';
        case 'muslim':
          return 'صحيح مسلم';
        default:
          return widget.book.nameEn;
      }
    }
    return widget.book.nameEn;
  }

  String _chapterTitle(AppLocalizations l10n) {
    final index = widget.chapter.id > 0 ? widget.chapter.id : 1;

    if (l10n.isBangla) {
      final localized = HadithChapterLocalization.localize(
        bengali: widget.chapter.nameBn,
        english: widget.chapter.nameEn,
        arabic: widget.chapter.nameAr,
        chapterIndex: index,
      );
      return localized.replaceFirst(
        RegExp(r'^অধ্যায়\s*[০-৯0-9]+\s*—\s*'),
        '',
      );
    }

    if (l10n.isArabic) {
      final ar = widget.chapter.nameAr.trim();
      if (ar.isNotEmpty) return ar;
      final en = widget.chapter.nameEn.trim();
      return en.isNotEmpty ? en : 'الفصل';
    }

    final en = widget.chapter.nameEn.trim();
    if (en.isNotEmpty) return en;
    final ar = widget.chapter.nameAr.trim();
    return ar.isNotEmpty ? ar : 'Chapter';
  }

  Future<void> _load() async {
    final l10n = AppLocalizations.of(context);
    final languageCode = l10n.locale.languageCode;
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final list = await HadithService.instance.getHadiths(
        widget.book.key,
        widget.chapter.id,
        bookNumber: widget.chapter.bookNumber,
        languageCode: languageCode,
      );
      final saved = <String>{};
      for (final h in list) {
        if (await HadithBookmarkService.instance.isSaved(_key(h))) {
          saved.add(_key(h));
        }
      }
      if (!mounted) return;
      setState(() {
        _hadiths = list;
        _saved
          ..clear()
          ..addAll(saved);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hadiths = null;
        _error = AppLocalizations.of(context).tr(
          'হাদিস লোড করা যায়নি।',
          'Could not load hadith.',
        );
        _loading = false;
      });
    }
  }

  SavedHadith _savedModel(HadithItem h) => SavedHadith(
        key: _key(h),
        bookKey: widget.book.key,
        bookNameBn: widget.book.nameBn,
        chapterNameBn: widget.chapter.nameBn,
        hadithNo: h.hadithNo,
        arabic: h.arabic,
        bangla: h.bangla,
        english: h.english,
        narrator: h.narrator,
        reference: h.reference,
        grade: h.grade,
        savedAt: DateTime.now(),
      );

  Future<void> _toggle(HadithItem h) async {
    final key = _key(h);
    final saved = await HadithBookmarkService.instance.toggle(_savedModel(h));
    if (!mounted) return;
    setState(() => saved ? _saved.add(key) : _saved.remove(key));
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            saved
                ? l10n.tr('হাদিসটি সংরক্ষণ করা হয়েছে', 'Hadith saved')
                : l10n.tr('হাদিসটি সংরক্ষণ থেকে সরানো হয়েছে', 'Hadith removed from saved'),
          ),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _share(HadithItem h) async {
    final l10n = AppLocalizations.of(context);
    final b = StringBuffer();
    if (h.arabic.trim().isNotEmpty) b..writeln(h.arabic.trim())..writeln();
    final body = _content(h, l10n);
    if (body.isNotEmpty && body != h.arabic.trim()) b..writeln(body)..writeln();
    if (h.narrator.trim().isNotEmpty) b.writeln('${l10n.tr('বর্ণনাকারী', 'Narrator')}: ${h.narrator.trim()}');
    if (h.reference.trim().isNotEmpty) b.writeln('${l10n.tr('রেফারেন্স', 'Reference')}: ${h.reference.trim()}');
    if (h.grade.trim().isNotEmpty) b.writeln('${l10n.tr('মান', 'Grade')}: ${h.grade.trim()}');
    final number = h.hadithNo.trim();
    final book = _bookTitle(l10n);
    b.writeln(number.isNotEmpty ? '$book • ${l10n.tr('হাদিস নং', 'Hadith No.')} $number' : book);
    b.writeln('\nNurVerse');
    await SharePlus.instance.share(ShareParams(text: b.toString().trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _chapterTitle(l10n);
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: l10n.tr('সংরক্ষিত হাদিস', 'Saved Hadith'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedHadithScreen())),
            icon: const Icon(Icons.bookmarks_rounded),
          ),
        ],
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
            Text(l10n.tr('হাদিস লোড হচ্ছে...', 'Loading hadith...'), style: TextStyle(fontSize: 13, color: context.secondaryTextColor)),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: context.primaryTextColor)),
              const SizedBox(height: 18),
              FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh_rounded), label: Text(l10n.tryAgainLabel)),
            ],
          ),
        ),
      );
    }
    final list = _hadiths ?? const <HadithItem>[];
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * .35,
              child: Center(child: Text(l10n.tr('এই অধ্যায়ে কোনো হাদিস পাওয়া যায়নি।', 'No hadiths were found in this chapter.'), textAlign: TextAlign.center, style: TextStyle(color: context.secondaryTextColor))),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final h = list[index];
          return Padding(padding: const EdgeInsets.only(bottom: 14), child: _hadithCard(context, h, l10n));
        },
      ),
    );
  }

  Widget _hadithCard(BuildContext context, HadithItem h, AppLocalizations l10n) {
    final saved = _saved.contains(_key(h));
    final body = _content(h, l10n);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: context.borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (h.hadithNo.trim().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)),
                  child: Text('${l10n.tr('হাদিস নং', 'Hadith No.')} ${h.hadithNo}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.seaBlueDark)),
                ),
              const Spacer(),
              IconButton(tooltip: saved ? l10n.tr('সংরক্ষিত', 'Saved') : l10n.tr('সংরক্ষণ', 'Save'), onPressed: () => _toggle(h), icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, size: 21, color: saved ? AppColors.seaBlue : null)),
              IconButton(tooltip: l10n.tr('শেয়ার', 'Share'), onPressed: () => _share(h), icon: const Icon(Icons.share_outlined, size: 20)),
            ],
          ),
          if (h.arabic.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: .05), borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.tr('আরবি', 'Arabic'), textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, color: AppColors.seaBlue, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(h.arabic, textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 20, height: 2.05, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
          if (body.isNotEmpty && body != h.arabic.trim()) ...[
            const SizedBox(height: 16),
            Text(_contentLabel(l10n), style: const TextStyle(color: AppColors.seaBlue, fontSize: 11, fontWeight: FontWeight.w800)),
            const SizedBox(height: 7),
            Text(body, textAlign: l10n.isArabic ? TextAlign.right : TextAlign.left, style: const TextStyle(fontSize: 15, height: 1.75)),
          ],
          if (h.narrator.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _info(context, l10n.tr('বর্ণনাকারী', 'Narrator'), h.narrator),
          ],
          if (h.reference.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _info(context, l10n.tr('রেফারেন্স', 'Reference'), h.reference),
          ],
          if (h.grade.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _info(context, l10n.tr('মান', 'Grade'), h.grade),
          ],
        ],
      ),
    );
  }

  Widget _info(BuildContext context, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: TextStyle(color: context.secondaryTextColor, fontSize: 11, fontWeight: FontWeight.w700))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12.5, height: 1.45))),
        ],
      );
}
