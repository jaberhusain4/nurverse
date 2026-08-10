// lib/screens/hadith/saved_hadith_screen.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/saved_hadith.dart';
import '../../services/hadith_bookmark_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('হাদিসটি সংরক্ষিত তালিকা থেকে সরানো হয়েছে'),
          duration: Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _share(SavedHadith item) async {
    final buffer = StringBuffer();
    if (item.arabic.trim().isNotEmpty) {
      buffer
        ..writeln(item.arabic.trim())
        ..writeln();
    }
    if (item.bangla.trim().isNotEmpty) {
      buffer
        ..writeln(item.bangla.trim())
        ..writeln();
    }
    if (item.narrator.trim().isNotEmpty) {
      buffer.writeln('বর্ণনাকারী: ${item.narrator.trim()}');
    }
    if (item.reference.trim().isNotEmpty) {
      buffer.writeln('রেফারেন্স: ${item.reference.trim()}');
    }
    if (item.grade.trim().isNotEmpty) {
      buffer.writeln('মান: ${item.grade.trim()}');
    }
    buffer.writeln(
      '${item.bookNameBn} • হাদিস নং ${item.hadithNo}',
    );
    buffer.writeln('\nNurVerse');
    await SharePlus.instance.share(ShareParams(text: buffer.toString().trim()));
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'সংরক্ষিত হাদিস',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      12,
                      AppSpacing.md,
                      8,
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'সংরক্ষিত হাদিস খুঁজুন...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () => setState(() => _query = ''),
                                icon: const Icon(Icons.clear_rounded),
                              ),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? _EmptySavedState(hasQuery: _query.isNotEmpty)
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.md,
                                6,
                                AppSpacing.md,
                                24,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _SavedHadithCard(
                                    item: item,
                                    onRemove: () => _remove(item),
                                    onShare: () => _share(item),
                                  ),
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
  final VoidCallback onRemove;
  final VoidCallback onShare;

  const _SavedHadithCard({
    required this.item,
    required this.onRemove,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return NvCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.bookNameBn,
                  style: const TextStyle(
                    color: AppColors.seaBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                item.hadithNo.isEmpty ? '' : 'হাদিস ${item.hadithNo}',
                style: TextStyle(
                  fontSize: 11,
                  color: context.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (item.chapterNameBn.trim().isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              item.chapterNameBn,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: context.secondaryTextColor,
              ),
            ),
          ],
          if (item.arabic.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.seaBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                item.arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 19, height: 2.0),
              ),
            ),
          ],
          if (item.bangla.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              item.bangla,
              style: const TextStyle(fontSize: 15, height: 1.75),
            ),
          ],
          const SizedBox(height: 12),
          if (item.reference.trim().isNotEmpty)
            Text(
              'রেফারেন্স: ${item.reference}',
              style: TextStyle(
                fontSize: 11.5,
                color: context.secondaryTextColor,
                height: 1.5,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'শেয়ার',
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined, size: 20),
              ),
              IconButton(
                tooltip: 'সংরক্ষণ থেকে সরান',
                onPressed: onRemove,
                icon: const Icon(
                  Icons.bookmark_rounded,
                  size: 21,
                  color: AppColors.seaBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptySavedState extends StatelessWidget {
  final bool hasQuery;

  const _EmptySavedState({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.seaBlue.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 34,
                color: AppColors.seaBlue,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasQuery ? 'কোনো হাদিস পাওয়া যায়নি' : 'এখনো কোনো হাদিস সংরক্ষণ করা হয়নি',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasQuery
                  ? 'অন্য কোনো শব্দ দিয়ে আবার খুঁজে দেখুন।'
                  : 'গুরুত্বপূর্ণ হাদিসের পাশে সংরক্ষণ আইকনে চাপলে এখানে পাওয়া যাবে।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: context.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
