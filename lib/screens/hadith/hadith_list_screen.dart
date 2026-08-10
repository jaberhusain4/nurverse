// lib/screens/hadith/hadith_list_screen.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/saved_hadith.dart';
import '../../services/hadith_bookmark_service.dart';
import '../../services/hadith_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'saved_hadith_screen.dart';

class HadithListScreen extends StatefulWidget {
  final HadithBook book;
  final HadithChapter chapter;

  const HadithListScreen({
    super.key,
    required this.book,
    required this.chapter,
  });

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  List<HadithItem>? _hadiths;
  String? _error;
  bool _isLoading = true;
  bool _didLoad = false;
  final Set<String> _savedKeys = <String>{};

  String get _loadingText => 'হাদিস লোড হচ্ছে...';
  String get _errorText => 'হাদিস লোড করা যায়নি। আবার চেষ্টা করুন।';
  String get _retryText => 'আবার চেষ্টা করুন';
  String get _emptyText => 'এই অধ্যায়ে কোনো হাদিস পাওয়া যায়নি।';
  String get _hadithNumberLabel => 'হাদিস নং';
  String get _arabicLabel => 'আরবি';
  String get _banglaLabel => 'বাংলা অনুবাদ';
  String get _narratorLabel => 'বর্ণনাকারী';
  String get _referenceLabel => 'রেফারেন্স';
  String get _gradeLabel => 'মান';
  String get _bookmarkLabel => 'সংরক্ষণ';
  String get _savedLabel => 'সংরক্ষিত';
  String get _shareLabel => 'শেয়ার';

  String get _chapterTitle {
    if (widget.chapter.nameBn.trim().isNotEmpty) {
      return widget.chapter.nameBn.trim();
    }
    if (widget.chapter.nameAr.trim().isNotEmpty) {
      return widget.chapter.nameAr.trim();
    }
    return widget.book.nameBn;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _didLoad = true;
      _load();
    }
  }

  String _bookmarkKey(HadithItem hadith) {
    return HadithBookmarkService.instance.buildKey(
      bookKey: widget.book.key,
      hadithNo: hadith.hadithNo,
      arabic: hadith.arabic,
    );
  }

  SavedHadith _toSavedHadith(HadithItem hadith) {
    return SavedHadith(
      key: _bookmarkKey(hadith),
      bookKey: widget.book.key,
      bookNameBn: widget.book.nameBn,
      chapterNameBn: _chapterTitle,
      hadithNo: hadith.hadithNo,
      arabic: hadith.arabic,
      bangla: hadith.bangla,
      narrator: hadith.narrator,
      reference: hadith.reference,
      grade: hadith.grade,
      savedAt: DateTime.now(),
    );
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final list = await HadithService.instance.getHadiths(
        widget.book.key,
        widget.chapter.id,
        bookNumber: widget.chapter.bookNumber,
        languageCode: 'bn',
      );

      final saved = <String>{};
      for (final hadith in list) {
        if (await HadithBookmarkService.instance.isSaved(_bookmarkKey(hadith))) {
          saved.add(_bookmarkKey(hadith));
        }
      }

      if (!mounted) return;

      setState(() {
        _hadiths = list;
        _savedKeys
          ..clear()
          ..addAll(saved);
        _isLoading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hadiths = null;
        _error = _errorText;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBookmark(HadithItem hadith) async {
    final key = _bookmarkKey(hadith);
    final saved = await HadithBookmarkService.instance.toggle(
      _toSavedHadith(hadith),
    );
    if (!mounted) return;

    setState(() {
      if (saved) {
        _savedKeys.add(key);
      } else {
        _savedKeys.remove(key);
      }
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            saved
                ? 'হাদিসটি সংরক্ষণ করা হয়েছে'
                : 'হাদিসটি সংরক্ষণ থেকে সরানো হয়েছে',
          ),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _shareHadith(HadithItem hadith) async {
    final buffer = StringBuffer();

    if (hadith.arabic.trim().isNotEmpty) {
      buffer
        ..writeln(hadith.arabic.trim())
        ..writeln();
    }

    if (hadith.bangla.trim().isNotEmpty) {
      buffer
        ..writeln(hadith.bangla.trim())
        ..writeln();
    }

    if (hadith.narrator.trim().isNotEmpty) {
      buffer.writeln('$_narratorLabel: ${hadith.narrator.trim()}');
    }

    if (hadith.reference.trim().isNotEmpty) {
      buffer.writeln('$_referenceLabel: ${hadith.reference.trim()}');
    }

    if (hadith.grade.trim().isNotEmpty) {
      buffer.writeln('$_gradeLabel: ${hadith.grade.trim()}');
    }

    final number = hadith.hadithNo.trim();
    buffer.writeln(
      number.isNotEmpty
          ? '${widget.book.nameBn} • $_hadithNumberLabel $number'
          : widget.book.nameBn,
    );
    buffer.writeln('\nNurVerse');

    final text = buffer.toString().trim();
    if (text.isEmpty) return;

    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _openSavedHadiths() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SavedHadithScreen()),
    );
    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _chapterTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'সংরক্ষিত হাদিস',
            onPressed: _openSavedHadiths,
            icon: const Icon(Icons.bookmarks_rounded),
          ),
        ],
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
              style: TextStyle(fontSize: 13, color: context.secondaryTextColor),
            ),
          ],
        ),
      );
    }

    if (_error != null) return _buildErrorState();

    final hadiths = _hadiths ?? const <HadithItem>[];
    if (hadiths.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: hadiths.length,
        itemBuilder: (context, index) {
          final hadith = hadiths[index];
          final key = _bookmarkKey(hadith);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _HadithCard(
              hadith: hadith,
              isSaved: _savedKeys.contains(key),
              hadithNumberLabel: _hadithNumberLabel,
              arabicLabel: _arabicLabel,
              banglaLabel: _banglaLabel,
              narratorLabel: _narratorLabel,
              referenceLabel: _referenceLabel,
              gradeLabel: _gradeLabel,
              bookmarkLabel: _bookmarkLabel,
              savedLabel: _savedLabel,
              shareLabel: _shareLabel,
              onBookmark: () => _toggleBookmark(hadith),
              onShare: () => _shareHadith(hadith),
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
            Icon(Icons.error_outline_rounded, size: 46, color: context.secondaryTextColor),
            const SizedBox(height: 14),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.55, color: context.primaryTextColor),
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
                  style: TextStyle(fontSize: 14, height: 1.55, color: context.secondaryTextColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  final HadithItem hadith;
  final bool isSaved;
  final String hadithNumberLabel;
  final String arabicLabel;
  final String banglaLabel;
  final String narratorLabel;
  final String referenceLabel;
  final String gradeLabel;
  final String bookmarkLabel;
  final String savedLabel;
  final String shareLabel;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  const _HadithCard({
    required this.hadith,
    required this.isSaved,
    required this.hadithNumberLabel,
    required this.arabicLabel,
    required this.banglaLabel,
    required this.narratorLabel,
    required this.referenceLabel,
    required this.gradeLabel,
    required this.bookmarkLabel,
    required this.savedLabel,
    required this.shareLabel,
    required this.onBookmark,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return NvCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          if (hadith.arabic.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildArabic(),
          ],
          if (hadith.bangla.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildTranslation(label: banglaLabel, text: hadith.bangla),
          ],
          if (hadith.narrator.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildInfoRow(label: narratorLabel, value: hadith.narrator),
          ],
          if (hadith.reference.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(label: referenceLabel, value: hadith.reference),
          ],
          if (hadith.grade.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(label: gradeLabel, value: hadith.grade),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final number = hadith.hadithNo.trim();

    return Row(
      children: [
        if (number.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.seaBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$hadithNumberLabel $number',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.seaBlueDark,
              ),
            ),
          )
        else
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.seaBlue,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        const Spacer(),
        IconButton(
          tooltip: isSaved ? savedLabel : bookmarkLabel,
          onPressed: onBookmark,
          icon: Icon(
            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            size: 21,
            color: isSaved ? AppColors.seaBlue : null,
          ),
        ),
        IconButton(
          tooltip: shareLabel,
          onPressed: onShare,
          icon: const Icon(Icons.share_outlined, size: 20),
        ),
      ],
    );
  }

  Widget _buildArabic() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.seaBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            arabicLabel,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11, color: AppColors.seaBlue, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            hadith.arabic,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 20, height: 2.05, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslation({required String label, required String text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            label,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 12, color: AppColors.seaBlue, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          text,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 15, height: 1.75),
        ),
      ],
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.seaBlue.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        text: TextSpan(
          style: const TextStyle(fontSize: 12, height: 1.5),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.seaBlue),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
