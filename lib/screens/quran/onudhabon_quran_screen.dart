import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/quran_surah.dart';
import '../../services/last_read_service.dart';
import '../../services/quran_data_service.dart';
import '../../services/quran_tafsir_service.dart';
import '../../theme/app_theme.dart';

class OnudhabonQuranScreen extends StatefulWidget {
  const OnudhabonQuranScreen({super.key});

  @override
  State<OnudhabonQuranScreen> createState() => _OnudhabonQuranScreenState();
}

class _OnudhabonQuranScreenState extends State<OnudhabonQuranScreen> {
  final QuranDataService _data = QuranDataService.instance;
  final QuranTafsirService _tafsir = QuranTafsirService.instance;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _readingScrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = <int, GlobalKey>{};

  Timer? _savePositionTimer;
  bool _loading = true;
  bool _translationDownloading = false;
  bool _resumeScheduled = false;
  String _query = '';
  int? _selectedSurah;
  int? _resumeAyah;
  String _selectedTafsir = QuranTafsirService.editions.first.slug;
  Map<int, String> _tafsirByAyah = {};
  bool _tafsirLoading = false;
  String? _tafsirError;

  @override
  void initState() {
    super.initState();
    _readingScrollController.addListener(_handleReadingScroll);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _data.init();
      final lastRead = await LastReadService.getLastRead();

      if (lastRead != null && lastRead['mode'] == 'onudhabon') {
        final surahNumber = lastRead['surahNumber'];
        final ayahNumber = lastRead['ayahNumber'];
        if (surahNumber is int && surahNumber >= 1 && surahNumber <= 114) {
          _selectedSurah = surahNumber;
          _resumeAyah = ayahNumber is int && ayahNumber > 0 ? ayahNumber : 1;
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _tafsirError = e.toString());
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (_selectedSurah != null && _resumeAyah != null) {
      _scheduleResume();
    }

    if (!_data.translationAvailable) {
      await _downloadTranslation();
    }
  }

  Future<void> _downloadTranslation() async {
    if (_translationDownloading) return;
    setState(() => _translationDownloading = true);
    final ok = await _data.downloadTranslation();
    if (!mounted) return;
    setState(() => _translationDownloading = false);

    if (!ok && _data.downloadError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('বাংলা অনুবাদ পাওয়া যায়নি। ${_data.downloadError}')),
      );
    }
  }

  Future<void> _loadTafsir(QuranSurah surah) async {
    setState(() {
      _tafsirLoading = true;
      _tafsirError = null;
      _tafsirByAyah = {};
    });

    try {
      final result = await _tafsir.getSurahTafsir(
        slug: _selectedTafsir,
        surahNumber: surah.number,
      );
      if (!mounted) return;
      setState(() => _tafsirByAyah = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _tafsirError = e.toString());
    } finally {
      if (mounted) setState(() => _tafsirLoading = false);
    }
  }

  void _selectSurah(int number) {
    setState(() {
      _selectedSurah = number;
      _resumeAyah = 1;
      _tafsirByAyah = {};
      _tafsirError = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _savePosition(number, 1);
    });
  }

  GlobalKey _keyForAyah(int ayahNumber) {
    return _ayahKeys.putIfAbsent(ayahNumber, GlobalKey.new);
  }

  void _scheduleResume() {
    if (_resumeScheduled) return;
    _resumeScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resumeScheduled = false;
      if (!mounted || _resumeAyah == null) return;
      _scrollToAyah(_resumeAyah!);
    });
  }

  void _scrollToAyah(int ayahNumber) {
    final key = _ayahKeys[ayahNumber];
    final targetContext = key?.currentContext;
    if (targetContext == null) {
      _scheduleResumeRetry(ayahNumber);
      return;
    }

    final renderObject = targetContext.findRenderObject();
    if (renderObject is! RenderBox) {
      _scheduleResumeRetry(ayahNumber);
      return;
    }

    final top = renderObject.localToGlobal(Offset.zero).dy;
    const desiredTop = 96.0;
    final delta = top - desiredTop;
    final target = (_readingScrollController.offset + delta).clamp(
      0.0,
      _readingScrollController.position.maxScrollExtent,
    );

    _readingScrollController.jumpTo(target.toDouble());
  }

  void _scheduleResumeRetry(int ayahNumber) {
    if (_resumeScheduled) return;
    _resumeScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resumeScheduled = false;
      if (!mounted) return;
      _scrollToAyah(ayahNumber);
    });
  }

  void _handleReadingScroll() {
    if (_selectedSurah == null) return;
    _savePositionTimer?.cancel();
    _savePositionTimer = Timer(const Duration(milliseconds: 450), () {
      if (mounted) _saveVisibleAyah();
    });
  }

  void _saveVisibleAyah() {
    final surahNumber = _selectedSurah;
    if (surahNumber == null) return;

    int? bestAyah;
    double bestTop = double.infinity;

    for (final entry in _ayahKeys.entries) {
      final context = entry.value.currentContext;
      if (context == null) continue;
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) continue;

      final top = renderObject.localToGlobal(Offset.zero).dy;
      if (top >= 72 && top < bestTop) {
        bestTop = top;
        bestAyah = entry.key;
      }
    }

    bestAyah ??= _resumeAyah ?? 1;
    _resumeAyah = bestAyah;
    _savePosition(surahNumber, bestAyah);
  }

  Future<void> _savePosition(int surahNumber, int ayahNumber) async {
    if (surahNumber < 1 || surahNumber > 114 || ayahNumber < 1) return;

    final surah = _data.getSurah(surahNumber);
    final safeAyah = ayahNumber.clamp(1, surah.totalVerses);
    final progress = surah.totalVerses <= 1
        ? 0.0
        : ((safeAyah - 1) / (surah.totalVerses - 1)).clamp(0.0, 1.0);

    await LastReadService.saveLastRead(
      surahName: surah.banglaName ?? surah.transliteration,
      paraNo: 1,
      pageNo: safeAyah,
      progress: progress,
      mode: 'onudhabon',
      surahNumber: surahNumber,
      ayahNumber: safeAyah,
    );
  }

  @override
  void dispose() {
    _savePositionTimer?.cancel();
    _readingScrollController.removeListener(_handleReadingScroll);
    _readingScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final surahs = _data.surahList;
    final selected = _selectedSurah == null
        ? null
        : _data.getSurah(_selectedSurah!);

    if (selected != null && _resumeAyah != null) {
      _scheduleResume();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'অনুধাবন কুরআন',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: selected == null
          ? _buildSurahPicker(context, surahs)
          : _buildReading(context, selected),
    );
  }

  Widget _buildSurahPicker(BuildContext context, List<QuranSurah> surahs) {
    final filtered = surahs.where((surah) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return surah.number.toString().contains(q) ||
          surah.arabicName.contains(q) ||
          surah.transliteration.toLowerCase().contains(q) ||
          (surah.banglaName ?? '').toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        _buildIntroCard(context),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'সূরা খুঁজুন...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
            filled: true,
            fillColor: context.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'সূরা নির্বাচন করুন',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        ...filtered.map((surah) => _buildSurahTile(context, surah)),
      ],
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: .14),
            primary.withValues(alpha: .04),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: .10)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.auto_stories_rounded, color: primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'পড়ুন, বুঝুন, অনুধাবন করুন',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text(
                  'আরবি আয়াতের সঙ্গে বাংলা অনুবাদ এবং নির্বাচিত বাংলা তাফসির।',
                  style: TextStyle(fontSize: 12, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahTile(BuildContext context, QuranSurah surah) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: .06)),
      ),
      child: ListTile(
        onTap: () => _selectSurah(surah.number),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(
            child: Text(
              _bnNumber(surah.number),
              style: TextStyle(color: primary, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        title: Text(
          surah.banglaName ?? surah.transliteration,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${surah.transliteration} • ${surah.totalVerses} আয়াত • ${surah.type == 'meccan' ? 'মাক্কী' : 'মাদানী'}',
        ),
        trailing: Text(
          surah.arabicName,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildReading(BuildContext context, QuranSurah surah) {
    return Column(
      children: [
        Material(
          color: context.cardColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    _selectedSurah = null;
                    _resumeAyah = null;
                  }),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.banglaName ?? surah.transliteration,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text('${surah.transliteration} • ${surah.totalVerses} আয়াত'),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'তাফসির নির্বাচন',
                  initialValue: _selectedTafsir,
                  onSelected: (value) {
                    setState(() {
                      _selectedTafsir = value;
                      _tafsirByAyah = {};
                    });
                  },
                  itemBuilder: (_) => [
                    for (final edition in QuranTafsirService.editions)
                      PopupMenuItem(
                        value: edition.slug,
                        child: Text(edition.title),
                      ),
                  ],
                  icon: const Icon(Icons.tune_rounded),
                ),
              ],
            ),
          ),
        ),
        if (!_data.translationAvailable)
          Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              onPressed: _translationDownloading ? null : _downloadTranslation,
              icon: _translationDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded),
              label: const Text('বাংলা অনুবাদ ডাউনলোড করুন'),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _readingScrollController,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
            itemCount: surah.verses.length,
            itemBuilder: (context, index) {
              final verse = surah.verses[index];
              return KeyedSubtree(
                key: _keyForAyah(verse.number),
                child: _buildAyahCard(context, surah, verse),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAyahCard(
    BuildContext context,
    QuranSurah surah,
    QuranVerse verse,
  ) {
    final primary = Theme.of(context).colorScheme.primary;
    final tafsir = _tafsirByAyah[verse.number];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: .06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: primary.withValues(alpha: .10),
                child: Text(
                  _bnNumber(verse.number),
                  style: TextStyle(
                    color: primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${surah.number}:${verse.number}',
                style: TextStyle(
                  fontSize: 11,
                  color: context.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            verse.arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 24,
              height: 1.9,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (verse.bangla != null) ...[
            const SizedBox(height: 13),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .045),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                verse.bangla!,
                style: const TextStyle(fontSize: 15, height: 1.65),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: _tafsirLoading
                    ? null
                    : () => _loadTafsir(surah),
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: const Text('তাফসির / ব্যাখ্যা'),
              ),
            ],
          ),
          if (_tafsirLoading && _tafsirByAyah.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: LinearProgressIndicator(),
            ),
          if (_tafsirError != null && _tafsirByAyah.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'তাফসির লোড করা যায়নি। ইন্টারনেট সংযোগ পরীক্ষা করে আবার চাপুন।',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (tafsir != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .055),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: primary.withValues(alpha: .08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    QuranTafsirService.editions
                        .firstWhere(
                          (edition) => edition.slug == _selectedTafsir,
                        )
                        .title,
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    tafsir,
                    style: const TextStyle(fontSize: 14, height: 1.65),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _bnNumber(int number) {
    const en = '0123456789';
    const bn = '০১২৩৪৫৬৭৮৯';
    return number.toString().split('').map((d) {
      final i = en.indexOf(d);
      return i < 0 ? d : bn[i];
    }).join();
  }
}
