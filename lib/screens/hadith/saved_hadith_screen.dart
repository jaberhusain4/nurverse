// lib/screens/hadith/saved_hadith_screen.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/saved_hadith.dart';
import '../../services/hadith_bookmark_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../localization/app_localizations.dart';

class SavedHadithScreen extends StatefulWidget {
  const SavedHadithScreen({super.key});

  @override
  State<SavedHadithScreen> createState() => _SavedHadithScreenState();
}

class _SavedHadithScreenState extends State<SavedHadithScreen> {
  List<SavedHadith> _items = const [];
  String _query = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _body(SavedHadith item, AppLocalizations l10n) {
    if (l10n.isArabic) return item.arabic.trim();
    if (l10n.locale.languageCode == 'en') {
      return item.english.trim().isNotEmpty ? item.english.trim() : item.bangla.trim();
    }
    return item.bangla.trim();
  }

  String _bookTitle(SavedHadith item, AppLocalizations l10n) {
    return l10n.isBangla ? item.bookNameBn : item.bookKey == 'bukhari' && l10n.isArabic ? 'صحيح البخاري' : item.bookNameBn;
  }

  Future<void> _load() async {
    if (mounted) setState(() => _isLoading = true);
    final items = await HadithBookmarkService.instance.getAll();
    if (!mounted) return;
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  List<SavedHadith> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((item) {
      return item.bangla.toLowerCase().contains(q) ||
          item.english.toLowerCase().contains(q) ||
          item.arabic.toLowerCase().contains(q) ||
          item.bookNameBn.toLowerCase().contains(q) ||
          item.chapterNameBn.toLowerCase().contains(q) ||
          item.reference.toLowerCase().contains(q) ||
          item.narrator.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _remove(SavedHadith item) async {
    await HadithBookmarkService.instance.remove(item.key);
    if (!mounted) return;
    setState(() => _items = _items.where((e) => e.key != item.key).toList());
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.tr('হাদিসটি সংরক্ষিত তালিকা থেকে সরানো হয়েছে', 'Hadith removed from saved list')),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _share(SavedHadith item) async {
    final l10n = AppLocalizations.of(context);
    final buffer = StringBuffer();
    if (item.arabic.trim().isNotEmpty) {
      buffer..writeln(item.arabic.trim())..writeln();
    }
    final body = _body(item, l10n);
    if (body.isNotEmpty && body != item.arabic.trim()) {
      buffer..writeln(body)..writeln();
    }
    if (item.narrator.trim().isNotEmpty) {
      buffer.writeln('${l10n.tr('বর্ণনাকারী', 'Narrator')}: ${item.narrator.trim()}');
    }
    if (item.reference.trim().isNotEmpty) {
      buffer.writeln('${l10n.tr('রেফারেন্স', 'Reference')}: ${item.reference.trim()}');
    }
    if (item.grade.trim().isNotEmpty) {
      buffer.writeln('${l10n.tr('মান', 'Grade')}: ${item.grade.trim()}');
    }
    final book = l10n.isBangla ? item.bookNameBn : item.bookKey == 'bukhari' && l10n.isArabic ? 'صحيح البخاري' : item.bookNameBn;
    buffer.writeln('$book • ${l10n.tr('হাদিস নং', 'Hadith No.')} ${item.hadithNo}');
    buffer.writeln('\nNurVerse');
    await SharePlus.instance.share(ShareParams(text: buffer.toString().trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('সংরক্ষিত হাদিস', 'Saved Hadith'), style: const TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 12, AppSpacing.md, 8),
                    child: TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: l10n.tr('সংরক্ষিত হাদিস খুঁজুন...', 'Search saved hadith...'),
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isEmpty ? null : IconButton(onPressed: () => setState(() => _query = ''), icon: const Icon(Icons.clear_rounded)),
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? _EmptySavedState(hasQuery: _query.isNotEmpty, l10n: l10n)
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 6, AppSpacing.md, 24),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _SavedHadithCard(item: item, l10n: l10n, onRemove: () => _remove(item), onShare: () => _share(item)),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SavedHadithCard extends StatelessWidget {
  final SavedHadith item;
  final AppLocalizations l10n;
  final VoidCallback onRemove;
  final VoidCallback onShare;

  const _SavedHadithCard({required this.item, required this.l10n, required this.onRemove, required this.onShare});

  @override
  Widget build(BuildContext context) {
    final body = l10n.isArabic
        ? item.arabic.trim()
        : l10n.locale.languageCode == 'en'
            ? (item.english.trim().isNotEmpty ? item.english.trim() : item.bangla.trim())
            : item.bangla.trim();
    final bookTitle = l10n.isBangla
        ? item.bookNameBn
        : l10n.isArabic && item.bookKey == 'bukhari'
            ? 'صحيح البخاري'
            : item.bookNameBn;
    return NvCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(bookTitle, style: const TextStyle(color: AppColors.seaBlue, fontSize: 12, fontWeight: FontWeight.w800))),
          Text(item.hadithNo.isEmpty ? '' : '${l10n.tr('হাদিস', 'Hadith')} ${item.hadithNo}', style: TextStyle(fontSize: 11, color: context.secondaryTextColor, fontWeight: FontWeight.w600)),
        ]),
        if (item.chapterNameBn.trim().isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(item.chapterNameBn, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, height: 1.45, color: context.secondaryTextColor)),
        ],
        if (item.arabic.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)), child: Text(item.arabic, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: const TextStyle(fontSize: 19, height: 2.0))),
        ],
        if (body.isNotEmpty && body != item.arabic.trim()) ...[
          const SizedBox(height: 14),
          Text(l10n.isArabic ? 'العربية' : l10n.isBangla ? 'বাংলা অনুবাদ' : 'Translation', style: const TextStyle(color: AppColors.seaBlue, fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          Text(body, textAlign: l10n.isArabic ? TextAlign.right : TextAlign.left, style: const TextStyle(fontSize: 15, height: 1.75)),
        ],
        const SizedBox(height: 12),
        if (item.reference.trim().isNotEmpty) Text('${l10n.tr('রেফারেন্স', 'Reference')}: ${item.reference}', style: TextStyle(fontSize: 11.5, color: context.secondaryTextColor, height: 1.5)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          IconButton(tooltip: l10n.tr('শেয়ার', 'Share'), onPressed: onShare, icon: const Icon(Icons.share_outlined, size: 20)),
          IconButton(tooltip: l10n.tr('সংরক্ষণ থেকে সরান', 'Remove from saved'), onPressed: onRemove, icon: const Icon(Icons.bookmark_rounded, size: 21, color: AppColors.seaBlue)),
        ]),
      ]),
    );
  }
}

class _EmptySavedState extends StatelessWidget {
  final bool hasQuery;
  final AppLocalizations l10n;

  const _EmptySavedState({required this.hasQuery, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 72, height: 72, decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: 0.09), shape: BoxShape.circle), child: const Icon(Icons.bookmark_border_rounded, size: 34, color: AppColors.seaBlue)),
      const SizedBox(height: 18),
      Text(hasQuery ? l10n.tr('কোনো হাদিস পাওয়া যায়নি', 'No hadith found') : l10n.tr('এখনো কোনো হাদিস সংরক্ষণ করা হয়নি', 'No hadith has been saved yet'), textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.primaryTextColor)),
      const SizedBox(height: 8),
      Text(hasQuery ? l10n.tr('অন্য কোনো শব্দ দিয়ে আবার খুঁজে দেখুন।', 'Try searching with another word.') : l10n.tr('গুরুত্বপূর্ণ হাদিসের পাশে সংরক্ষণ আইকনে চাপলে এখানে পাওয়া যাবে।', 'Saved hadiths will appear here when you tap the save icon.'), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.55, color: context.secondaryTextColor)),
    ]));
  }
}
