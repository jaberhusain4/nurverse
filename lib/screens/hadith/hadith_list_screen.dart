// lib/screens/hadith/hadith_list_screen.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/hadith_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

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
      return 'جارٍ تحميل الأحاديث...';
    }

    if (_isEnglish) {
      return 'Loading hadiths...';
    }

    return 'হাদিস লোড হচ্ছে...';
  }

  String get _errorText {
    if (_isArabic) {
      return 'تعذر تحميل الأحاديث. تحقق من اتصال الإنترنت أو حاول مرة أخرى.';
    }

    if (_isEnglish) {
      return 'Unable to load hadiths. Check your internet connection or try again.';
    }

    return 'হাদিস লোড করা যায়নি। ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';
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
      return 'لا توجد أحاديث في هذا الفصل.';
    }

    if (_isEnglish) {
      return 'No hadiths were found in this chapter.';
    }

    return 'এই অধ্যায়ে কোনো হাদিস পাওয়া যায়নি।';
  }

  String get _hadithNumberLabel {
    if (_isArabic) {
      return 'رقم الحديث';
    }

    if (_isEnglish) {
      return 'Hadith';
    }

    return 'হাদিস নং';
  }

  String get _arabicLabel {
    if (_isArabic) {
      return 'النص العربي';
    }

    if (_isEnglish) {
      return 'Arabic';
    }

    return 'আরবি';
  }

  String get _banglaLabel {
    return 'বাংলা অনুবাদ';
  }

  String get _englishLabel {
    return 'English Translation';
  }

  String get _narratorLabel {
    if (_isArabic) {
      return 'الراوي';
    }

    if (_isEnglish) {
      return 'Narrator';
    }

    return 'বর্ণনাকারী';
  }

  String get _referenceLabel {
    if (_isArabic) {
      return 'المرجع';
    }

    if (_isEnglish) {
      return 'Reference';
    }

    return 'রেফারেন্স';
  }

  String get _gradeLabel {
    if (_isArabic) {
      return 'الدرجة';
    }

    if (_isEnglish) {
      return 'Grade';
    }

    return 'মান';
  }

  String get _bookmarkLabel {
    if (_isArabic) {
      return 'حفظ';
    }

    if (_isEnglish) {
      return 'Bookmark';
    }

    return 'বুকমার্ক';
  }

  String get _shareLabel {
    if (_isArabic) {
      return 'مشاركة';
    }

    if (_isEnglish) {
      return 'Share';
    }

    return 'শেয়ার';
  }

  String get _chapterTitle {
    if (_isArabic) {
      if (widget.chapter.nameAr.trim().isNotEmpty) {
        return widget.chapter.nameAr.trim();
      }

      if (widget.chapter.nameEn.trim().isNotEmpty) {
        return widget.chapter.nameEn.trim();
      }

      return widget.book.nameEn;
    }

    if (_isEnglish) {
      if (widget.chapter.nameEn.trim().isNotEmpty) {
        return widget.chapter.nameEn.trim();
      }

      if (widget.chapter.nameBn.trim().isNotEmpty) {
        return widget.chapter.nameBn.trim();
      }

      return widget.book.nameEn;
    }

    if (widget.chapter.nameBn.trim().isNotEmpty) {
      return widget.chapter.nameBn.trim();
    }

    if (widget.chapter.nameEn.trim().isNotEmpty) {
      return widget.chapter.nameEn.trim();
    }

    return widget.book.nameBn;
  }

  // ---------------------------------------------------------------------------
  // LOAD
  // ---------------------------------------------------------------------------

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
      final list = await HadithService.instance.getHadiths(
        widget.book.key,
        widget.chapter.id,
        bookNumber: widget.chapter.bookNumber,
        languageCode: _languageCode,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _hadiths = list;
        _isLoading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _hadiths = null;
        _error = _errorText;
        _isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // SHARE
  // ---------------------------------------------------------------------------

  Future<void> _shareHadith(HadithItem hadith) async {
    final buffer = StringBuffer();

    if (hadith.arabic.trim().isNotEmpty) {
      buffer
        ..writeln(hadith.arabic.trim())
        ..writeln();
    }

    if (_isArabic) {
      if (hadith.arabic.trim().isNotEmpty) {
        buffer.writeln(hadith.arabic.trim());
      }
    } else if (_isEnglish) {
      if (hadith.english.trim().isNotEmpty) {
        buffer.writeln(hadith.english.trim());
      }
    } else {
      if (hadith.bangla.trim().isNotEmpty) {
        buffer.writeln(hadith.bangla.trim());
      }
    }

    if (hadith.narrator.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('$_narratorLabel: ${hadith.narrator.trim()}');
    }

    if (hadith.reference.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('$_referenceLabel: ${hadith.reference.trim()}');
    }

    final number = hadith.hadithNo.trim();

    if (number.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('${widget.book.nameEn} • $_hadithNumberLabel $number');
    } else {
      buffer
        ..writeln()
        ..writeln(widget.book.nameEn);
    }

    buffer
      ..writeln()
      ..writeln('NurVerse');

    final text = buffer.toString().trim();

    if (text.isEmpty) {
      return;
    }

    await SharePlus.instance.share(ShareParams(text: text));
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _chapterTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: _isArabic ? TextAlign.right : TextAlign.left,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
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

    final hadiths = _hadiths ?? const <HadithItem>[];

    if (hadiths.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: hadiths.length,
        itemBuilder: (context, index) {
          final hadith = hadiths[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _HadithCard(
              hadith: hadith,
              languageCode: _languageCode,
              hadithNumberLabel: _hadithNumberLabel,
              arabicLabel: _arabicLabel,
              banglaLabel: _banglaLabel,
              englishLabel: _englishLabel,
              narratorLabel: _narratorLabel,
              referenceLabel: _referenceLabel,
              gradeLabel: _gradeLabel,
              bookmarkLabel: _bookmarkLabel,
              shareLabel: _shareLabel,
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
}

// =============================================================================
// HADITH CARD
// =============================================================================

class _HadithCard extends StatelessWidget {
  final HadithItem hadith;
  final String languageCode;

  final String hadithNumberLabel;
  final String arabicLabel;
  final String banglaLabel;
  final String englishLabel;
  final String narratorLabel;
  final String referenceLabel;
  final String gradeLabel;
  final String bookmarkLabel;
  final String shareLabel;

  final VoidCallback onShare;

  const _HadithCard({
    required this.hadith,
    required this.languageCode,
    required this.hadithNumberLabel,
    required this.arabicLabel,
    required this.banglaLabel,
    required this.englishLabel,
    required this.narratorLabel,
    required this.referenceLabel,
    required this.gradeLabel,
    required this.bookmarkLabel,
    required this.shareLabel,
    required this.onShare,
  });

  bool get isArabic => languageCode == 'ar';

  bool get isEnglish => languageCode == 'en';

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

          if (!isArabic && !isEnglish && hadith.bangla.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildTranslation(
              label: banglaLabel,
              text: hadith.bangla,
              textDirection: TextDirection.ltr,
            ),
          ],

          if (isEnglish && hadith.english.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildTranslation(
              label: englishLabel,
              text: hadith.english,
              textDirection: TextDirection.ltr,
            ),
          ],

          if (isArabic && hadith.arabic.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildTranslation(
              label: arabicLabel,
              text: hadith.arabic,
              textDirection: TextDirection.rtl,
            ),
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
          tooltip: bookmarkLabel,
          onPressed: () {},
          icon: const Icon(Icons.bookmark_border_rounded, size: 21),
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
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.seaBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hadith.arabic,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 20,
              height: 2.05,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslation({
    required String label,
    required String text,
    required TextDirection textDirection,
  }) {
    final isRtl = textDirection == TextDirection.rtl;

    return Column(
      crossAxisAlignment:
          isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            label,
            textDirection: textDirection,
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.seaBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          text,
          textDirection: textDirection,
          textAlign: isRtl ? TextAlign.right : TextAlign.left,
          style: const TextStyle(fontSize: 15, height: 1.75),
        ),
      ],
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    final direction = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.seaBlue.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        textDirection: direction,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        text: TextSpan(
          style: const TextStyle(fontSize: 12, height: 1.5),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.seaBlue,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
