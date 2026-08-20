import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/quran_surah.dart';
import '../../services/last_read_service.dart';
import '../../services/quran_data_service.dart';
import '../../services/quran_metadata_service.dart';
import '../../services/quran_tafsir_service.dart';
import '../../services/quran_translation_service.dart';
import '../../theme/app_theme.dart';

class PremiumOnudhabonReaderV2 extends StatefulWidget {
  final bool openLastRead;
  const PremiumOnudhabonReaderV2({super.key, this.openLastRead = false});

  @override
  State<PremiumOnudhabonReaderV2> createState() => _PremiumOnudhabonReaderV2State();
}

class _PremiumOnudhabonReaderV2State extends State<PremiumOnudhabonReaderV2> {
  static const double _defaultAr = 20;
  static const double _defaultTr = 15;
  static const double _minAr = 16;
  static const double _maxAr = 28;
  static const double _minTr = 12;
  static const double _maxTr = 21;

  final _data = QuranDataService.instance;
  final _translation = QuranTranslationService.instance;
  final _tafsir = QuranTafsirService.instance;
  final _search = TextEditingController();
  final _scroll = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};

  bool _loading = true;
  bool _loadingTranslation = false;
  bool _loadingTafsir = false;
  String _query = '';
  int? _selectedSurah;
  int? _resumeAyah;
  double _arabicFontSize = _defaultAr;
  double _translationFontSize = _defaultTr;
  String _selectedTranslation = QuranTranslationService.editions.first.id;
  String _selectedTafsir = QuranTafsirService.editions.first.slug;
  Map<int, String> _translationByAyah = {};
  Map<int, String> _tafsirByAyah = {};
  String? _translationError;
  String? _tafsirError;

  QuranTranslationEdition get _translationEdition =>
      QuranTranslationService.editions.firstWhere(
        (item) => item.id == _selectedTranslation,
        orElse: () => QuranTranslationService.editions.first,
      );

  String get _tafsirTitle => QuranTafsirService.editions.firstWhere(
        (item) => item.slug == _selectedTafsir,
        orElse: () => QuranTafsirService.editions.first,
      ).title;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_saveVisibleAyah);
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _arabicFontSize = (prefs.getDouble('onudhabon_arabic_font_size') ?? _defaultAr).clamp(_minAr, _maxAr);
    _translationFontSize = (prefs.getDouble('onudhabon_translation_font_size') ?? _defaultTr).clamp(_minTr, _maxTr);
    _selectedTranslation = prefs.getString('onudhabon_translation') ?? _selectedTranslation;
    _selectedTafsir = prefs.getString('onudhabon_tafsir') ?? _selectedTafsir;

    await _data.init();

    if (widget.openLastRead) {
      final last = await LastReadService.getLastRead();
      final surah = last?['surahNumber'];
      final ayah = last?['ayahNumber'];
      if (surah is int && surah >= 1 && surah <= 114) {
        _selectedSurah = surah;
        _resumeAyah = ayah is int && ayah > 0 ? ayah : 1;
      }
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (_selectedSurah != null) {
      final surah = _data.getSurah(_selectedSurah!);
      await _loadSources(surah);
      _scrollToResume();
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('onudhabon_arabic_font_size', _arabicFontSize);
    await prefs.setDouble('onudhabon_translation_font_size', _translationFontSize);
  }

  Future<void> _loadSources(QuranSurah surah) async {
    await Future.wait([
      _loadTranslation(surah),
      _loadTafsir(surah),
    ]);
  }

  Future<void> _loadTranslation(QuranSurah surah) async {
    if (!mounted) return;
    setState(() {
      _loadingTranslation = true;
      _translationError = null;
      _translationByAyah = {};
    });

    try {
      final local = <int, String>{
        for (final verse in surah.verses)
          if (verse.bangla != null && verse.bangla!.trim().isNotEmpty)
            verse.number: verse.bangla!,
      };
      final result = await _translation.getSurahTranslation(
        edition: _translationEdition,
        surahNumber: surah.number,
        localMuhiuddin: local,
      );
      if (mounted) setState(() => _translationByAyah = result);
    } catch (e) {
      if (mounted) setState(() => _translationError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingTranslation = false);
    }
  }

  Future<void> _loadTafsir(QuranSurah surah) async {
    if (!mounted) return;
    setState(() {
      _loadingTafsir = true;
      _tafsirError = null;
      _tafsirByAyah = {};
    });

    try {
      final result = await _tafsir.getSurahTafsir(
        slug: _selectedTafsir,
        surahNumber: surah.number,
      );
      if (mounted) setState(() => _tafsirByAyah = result);
    } catch (e) {
      if (mounted) setState(() => _tafsirError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingTafsir = false);
    }
  }

  Future<void> _selectSurah(int number) async {
    setState(() {
      _selectedSurah = number;
      _resumeAyah = 1;
      _translationByAyah = {};
      _tafsirByAyah = {};
      _ayahKeys.clear();
    });
    final surah = _data.getSurah(number);
    await _loadSources(surah);
    await _savePosition(number, 1);
  }

  void _scrollToResume() {
    if (_resumeAyah == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _ayahKeys[_resumeAyah!]?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          alignment: .08,
          duration: const Duration(milliseconds: 220),
        );
      }
    });
  }

  void _saveVisibleAyah() {
    if (_selectedSurah == null) return;
    int? candidate;
    double bestTop = double.infinity;
    for (final entry in _ayahKeys.entries) {
      final context = entry.value.currentContext;
      if (context == null) continue;
      final render = context.findRenderObject();
      if (render is! RenderBox) continue;
      final top = render.localToGlobal(Offset.zero).dy;
      if (top >= 70 && top < bestTop) {
        bestTop = top;
        candidate = entry.key;
      }
    }
    if (candidate != null) {
      _resumeAyah = candidate;
      _savePosition(_selectedSurah!, candidate);
    }
  }

  Future<void> _savePosition(int surahNumber, int ayahNumber) async {
    final surah = _data.getSurah(surahNumber);
    final safeAyah = ayahNumber.clamp(1, surah.totalVerses).toInt();
    final progress = surah.totalVerses <= 1
        ? 0.0
        : ((safeAyah - 1) / (surah.totalVerses - 1)).clamp(0.0, 1.0).toDouble();
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
    _scroll.removeListener(_saveVisibleAyah);
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final selected = _selectedSurah == null
        ? null
        : _data.getSurah(_selectedSurah!);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'অনুধাবন কুরআন',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: selected == null
            ? null
            : [
                IconButton(
                  tooltip: 'পড়ার সেটিংস',
                  onPressed: _showReadingSettings,
                  icon: const Icon(Icons.text_fields_rounded, size: 20),
                ),
              ],
      ),
      body: selected == null
          ? _buildPicker(context)
          : _buildReader(context, selected),
    );
  }

  Widget _buildPicker(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final surahs = _data.surahList.where((surah) {
      if (query.isEmpty) return true;
      return surah.number.toString().contains(query) ||
          surah.transliteration.toLowerCase().contains(query) ||
          surah.arabicName.contains(query) ||
          (surah.banglaName ?? '').contains(query);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        _introCard(context),
        const SizedBox(height: 12),
        TextField(
          controller: _search,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'সূরা খুঁজুন...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
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
        ...surahs.map((surah) => _surahTile(context, surah)),
      ],
    );
  }

  Widget _introCard(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: .15),
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
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.auto_stories_rounded, color: primary, size: 24),
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
                  'আরবি আয়াত, বিভিন্ন অনুবাদ এবং নির্বাচিত ব্যাখ্যা—একটি premium reading experience.',
                  style: TextStyle(fontSize: 12, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _surahTile(BuildContext context, QuranSurah surah) {
    final primary = Theme.of(context).colorScheme.primary;
    final meta = QuranMetadataService.forSurah(surah.number);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: .07)),
      ),
      child: ListTile(
        onTap: () => _selectSurah(surah.number),
        leading: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(
            _bnNumber(surah.number),
            style: TextStyle(
              color: primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          surah.banglaName ?? surah.transliteration,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${surah.totalVerses} আয়াত • ${meta.rukuCount} রুকু • ${meta.sajdaCount} সিজদা • ${surah.type == 'meccan' ? 'মাক্কী' : 'মাদানী'}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          surah.arabicName,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildReader(BuildContext context, QuranSurah surah) {
    final meta = QuranMetadataService.forSurah(surah.number);
    return Column(
      children: [
        _surahHeader(context, surah, meta),
        if (_loadingTranslation || _loadingTafsir)
          const LinearProgressIndicator(minHeight: 2),
        if (_translationError != null)
          _messageCard(context, _translationError!),
        if (_tafsirError != null)
          _messageCard(context, 'এই ব্যাখ্যাটি এখন পাওয়া যায়নি। অন্য ব্যাখ্যা নির্বাচন করতে পারেন।'),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
            itemCount: surah.verses.length,
            itemBuilder: (context, index) {
              final verse = surah.verses[index];
              final key = _ayahKeys.putIfAbsent(verse.number, GlobalKey.new);
              return KeyedSubtree(
                key: key,
                child: _ayahCard(context, surah, verse),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _surahHeader(
    BuildContext context,
    QuranSurah surah,
    QuranSurahMetadata meta,
  ) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 2),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: .10)),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: .035),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _selectedSurah = null;
                  _resumeAyah = null;
                }),
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      surah.arabicName,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      surah.banglaName ?? surah.transliteration,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      surah.transliteration,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showReadingSettings,
                icon: const Icon(Icons.text_fields_rounded, size: 19),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 7,
            runSpacing: 7,
            children: [
              _statChip(context, '${surah.totalVerses}', 'আয়াত'),
              _statChip(context, '${meta.rukuCount}', 'রুকু'),
              _statChip(context, '${meta.sajdaCount}', 'সিজদা'),
              _statChip(context, surah.type == 'meccan' ? 'মাক্কী' : 'মাদানী', 'ধরন'),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showTranslationPicker(surah),
                  icon: const Icon(Icons.translate_rounded, size: 17),
                  label: Text(
                    _translationEdition.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showTafsirPicker(surah),
                  icon: const Icon(Icons.menu_book_rounded, size: 17),
                  label: Text(
                    _tafsirTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(BuildContext context, String value, String label) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$value $label',
        style: TextStyle(
          color: primary,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _ayahCard(
    BuildContext context,
    QuranSurah surah,
    QuranVerse verse,
  ) {
    final primary = Theme.of(context).colorScheme.primary;
    final translation = _translationByAyah[verse.number] ?? verse.bangla;
    final tafsir = _tafsirByAyah[verse.number];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
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
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: .10),
                ),
                child: Text(
                  _bnNumber(verse.number),
                  style: TextStyle(
                    color: primary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${surah.number}:${verse.number}',
                style: TextStyle(
                  fontSize: 10.5,
                  color: context.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: verse.arabic.trim(),
                    style: TextStyle(
                      fontSize: _arabicFontSize,
                      height: _arabicFontSize >= 25 ? 1.72 : 1.62,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: ' ۝${_arabicNumber(verse.number)}',
                    style: TextStyle(
                      color: primary,
                      fontSize: _arabicFontSize * .72,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.right,
            ),
          ),
          if (translation != null && translation.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .045),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                translation,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: _translationFontSize,
                  height: _translationFontSize >= 18 ? 1.55 : 1.48,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.menu_book_rounded, size: 16, color: primary),
              const SizedBox(width: 5),
              Text(
                'ব্যাখ্যা',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  _tafsirTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: context.secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          if (_loadingTafsir && _tafsirByAyah.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (tafsir != null) ...[
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .035),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primary.withValues(alpha: .07)),
              ),
              child: Text(
                tafsir,
                style: const TextStyle(fontSize: 13.5, height: 1.55),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showTranslationPicker(QuranSurah surah) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 6, 18, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'অনুবাদ নির্বাচন করুন',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              ...QuranTranslationService.editions.map(
                (edition) => RadioListTile<String>(
                  value: edition.id,
                  groupValue: _selectedTranslation,
                  title: Text(edition.title),
                  subtitle: Text(edition.author),
                  onChanged: (value) async {
                    if (value == null) return;
                    Navigator.pop(sheetContext);
                    setState(() => _selectedTranslation = value);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('onudhabon_translation', value);
                    await _loadTranslation(surah);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTafsirPicker(QuranSurah surah) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 6, 18, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ব্যাখ্যা / তাফসির নির্বাচন করুন',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              ...QuranTafsirService.editions.map(
                (edition) => RadioListTile<String>(
                  value: edition.slug,
                  groupValue: _selectedTafsir,
                  title: Text(edition.title),
                  onChanged: (value) async {
                    if (value == null) return;
                    Navigator.pop(sheetContext);
                    setState(() => _selectedTafsir = value);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('onudhabon_tafsir', value);
                    await _loadTafsir(surah);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _messageCard(BuildContext context, String text) {
    final error = Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 7, 14, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: error.withValues(alpha: .06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 17, color: error),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 11.5, color: error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReadingSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 5, 18, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.text_fields_rounded),
                        const SizedBox(width: 9),
                        const Text(
                          'পড়ার সেটিংস',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            setState(() {
                              _arabicFontSize = _defaultAr;
                              _translationFontSize = _defaultTr;
                            });
                            await _saveSettings();
                            setSheetState(() {});
                          },
                          child: const Text('ডিফল্ট'),
                        ),
                      ],
                    ),
                    _fontControl(
                      'আরবি আয়াত',
                      _arabicFontSize,
                      _minAr,
                      _maxAr,
                      (value) {
                        setState(() => _arabicFontSize = value);
                        _saveSettings();
                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    _fontControl(
                      'অনুবাদ',
                      _translationFontSize,
                      _minTr,
                      _maxTr,
                      (value) {
                        setState(() => _translationFontSize = value);
                        _saveSettings();
                        setSheetState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _fontControl(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('${value.round()}px', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _bnNumber(int number) {
    const english = '0123456789';
    const bangla = '০১২৩৪৫৬৭৮৯';
    return number.toString().split('').map((digit) {
      final index = english.indexOf(digit);
      return index < 0 ? digit : bangla[index];
    }).join();
  }

  String _arabicNumber(int number) {
    const english = '0123456789';
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    return number.toString().split('').map((digit) {
      final index = english.indexOf(digit);
      return index < 0 ? digit : arabic[index];
    }).join();
  }
}
