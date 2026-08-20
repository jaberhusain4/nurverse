import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/quran_surah.dart';
import '../../services/last_read_service.dart';
import '../../services/quran_data_service.dart';
import '../../services/quran_metadata_service.dart';
import '../../services/quran_tafsir_service.dart';
import '../../services/quran_translation_service.dart';
import '../../theme/app_theme.dart';

class PremiumOnudhabonReader extends StatefulWidget {
  final bool openLastRead;

  const PremiumOnudhabonReader({super.key, this.openLastRead = false});

  @override
  State<PremiumOnudhabonReader> createState() => _PremiumOnudhabonReaderState();
}

class _PremiumOnudhabonReaderState extends State<PremiumOnudhabonReader> {
  static const _defaultArabicFontSize = 20.0;
  static const _defaultTranslationFontSize = 15.0;
  static const _minArabicFontSize = 16.0;
  static const _maxArabicFontSize = 28.0;
  static const _minTranslationFontSize = 12.0;
  static const _maxTranslationFontSize = 21.0;

  final _data = QuranDataService.instance;
  final _tafsir = QuranTafsirService.instance;
  final _translationService = QuranTranslationService.instance;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _ayahKeys = <int, GlobalKey>{};

  Timer? _saveTimer;
  bool _loading = true;
  bool _loadingTranslation = false;
  bool _loadingTafsir = false;
  String _query = '';
  int? _selectedSurah;
  int? _resumeAyah;
  String? _tafsirError;
  String? _translationError;
  double _arabicFontSize = _defaultArabicFontSize;
  double _translationFontSize = _defaultTranslationFontSize;
  String _selectedTafsir = QuranTafsirService.editions.first.slug;
  String _selectedTranslation = QuranTranslationService.editions.first.id;
  Map<int, String> _tafsirByAyah = {};
  Map<int, String> _translationByAyah = {};

  QuranTranslationEdition get _translationEdition =>
      QuranTranslationService.editions.firstWhere((e) => e.id == _selectedTranslation);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _loadSettings();
      await _data.init();
      final prefs = await SharedPreferences.getInstance();
      _selectedTafsir = prefs.getString('onudhabon_tafsir') ?? _selectedTafsir;
      _selectedTranslation = prefs.getString('onudhabon_translation') ?? _selectedTranslation;

      if (widget.openLastRead) {
        final last = await LastReadService.getLastRead();
        final surah = last?['surahNumber'];
        final ayah = last?['ayahNumber'];
        if (surah is int && surah >= 1 && surah <= 114) {
          _selectedSurah = surah;
          _resumeAyah = ayah is int && ayah > 0 ? ayah : 1;
        }
      }
    } catch (e) {
      _translationError = e.toString();
    }

    if (!mounted) return;
    setState(() => _loading = false);
    if (_selectedSurah != null) {
      final surah = _data.getSurah(_selectedSurah!);
      await _loadTranslation(surah);
      await _loadTafsir(surah);
      _scheduleResume();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _arabicFontSize = (prefs.getDouble('onudhabon_arabic_font_size') ?? _defaultArabicFontSize)
        .clamp(_minArabicFontSize, _maxArabicFontSize);
    _translationFontSize = (prefs.getDouble('onudhabon_translation_font_size') ?? _defaultTranslationFontSize)
        .clamp(_minTranslationFontSize, _maxTranslationFontSize);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('onudhabon_arabic_font_size', _arabicFontSize);
    await prefs.setDouble('onudhabon_translation_font_size', _translationFontSize);
  }

  Future<void> _loadTranslation(QuranSurah surah) async {
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
      final result = await _translationService.getSurahTranslation(
        edition: _translationEdition,
        surahNumber: surah.number,
        localMuhiuddin: local,
      );
      if (!mounted) return;
      setState(() => _translationByAyah = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _translationError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingTranslation = false);
    }
  }

  Future<void> _loadTafsir(QuranSurah surah) async {
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
      if (!mounted) return;
      setState(() => _tafsirByAyah = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _tafsirError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingTafsir = false);
    }
  }

  void _selectSurah(int number) async {
    setState(() {
      _selectedSurah = number;
      _resumeAyah = 1;
      _tafsirByAyah = {};
      _translationByAyah = {};
      _ayahKeys.clear();
    });
    final surah = _data.getSurah(number);
    await _loadTranslation(surah);
    await _loadTafsir(surah);
    await _savePosition(number, 1);
    _scheduleResume();
  }

  void _scheduleResume() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _resumeAyah == null) return;
      final key = _ayahKeys[_resumeAyah!];
      final target = key?.currentContext;
      if (target == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleResume());
        return;
      }
      Scrollable.ensureVisible(
        target,
        alignment: .08,
        duration: const Duration(milliseconds: 250),
      );
    });
  }

  void _handleScroll() {
    if (_selectedSurah == null) return;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), _saveVisibleAyah);
  }

  void _saveVisibleAyah() {
    if (_selectedSurah == null) return;
    int? best;
    double bestTop = double.infinity;
    for (final entry in _ayahKeys.entries) {
      final target = entry.value.currentContext;
      if (target == null) continue;
      final render = target.findRenderObject();
      if (render is! RenderBox) continue;
      final top = render.localToGlobal(Offset.zero).dy;
      if (top >= 70 && top < bestTop) {
        bestTop = top;
        best = entry.key;
      }
    }
    best ??= _resumeAyah ?? 1;
    _resumeAyah = best;
    _savePosition(_selectedSurah!, best);
  }

  Future<void> _savePosition(int surahNumber, int ayahNumber) async {
    final surah = _data.getSurah(surahNumber);
    final safe = ayahNumber.clamp(1, surah.totalVerses);
    final progress = surah.totalVerses <= 1 ? 0.0 : (safe - 1) / (surah.totalVerses - 1);
    await LastReadService.saveLastRead(
      surahName: surah.banglaName ?? surah.transliteration,
      paraNo: 1,
      pageNo: safe,
      progress: progress.clamp(0.0, 1.0),
      mode: 'onudhabon',
      surahNumber: surahNumber,
      ayahNumber: safe,
    );
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final surahs = _data.surahList;
    final selected = _selectedSurah == null ? null : _data.getSurah(_selectedSurah!);
    return Scaffold(
      appBar: AppBar(
        title: Text('অনুধাবন কুরআন', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: selected == null
            ? null
            : [
                IconButton(onPressed: _showSettings, tooltip: 'পড়ার সেটিংস', icon: const Icon(Icons.text_fields_rounded, size: 20)),
              ],
      ),
      body: selected == null ? _buildPicker(context, surahs) : _buildReader(context, selected),
    );
  }

  Widget _buildPicker(BuildContext context, List<QuranSurah> surahs) {
    final q = _query.trim().toLowerCase();
    final filtered = surahs.where((s) {
      if (q.isEmpty) return true;
      return s.number.toString().contains(q) ||
          s.transliteration.toLowerCase().contains(q) ||
          s.arabicName.contains(q) ||
          (s.banglaName ?? '').contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        _buildIntro(context),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'সূরা খুঁজুন...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            filled: true,
            fillColor: context.cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 14),
        Text('সূরা নির্বাচন করুন', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...filtered.map((s) => _surahTile(context, s)),
      ],
    );
  }

  Widget _buildIntro(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary.withValues(alpha: .15), primary.withValues(alpha: .04)]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: .10)),
      ),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.auto_stories_rounded, color: primary, size: 24)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('পড়ুন, বুঝুন, অনুধাবন করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text('আরবি আয়াত, বিভিন্ন অনুবাদ ও নির্বাচিত তাফসির—এক জায়গায়।', style: TextStyle(fontSize: 12, height: 1.45)),
          ])),
        ],
      ),
    );
  }

  Widget _surahTile(BuildContext context, QuranSurah surah) {
    final primary = Theme.of(context).colorScheme.primary;
    final meta = QuranMetadataService.forSurah(surah.number);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: primary.withValues(alpha: .07))),
      child: ListTile(
        onTap: () => _selectSurah(surah.number),
        leading: Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: primary.withValues(alpha: .09), borderRadius: BorderRadius.circular(13)), child: Text(_bnNumber(surah.number), style: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w800))),
        title: Text(surah.banglaName ?? surah.transliteration, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        subtitle: Text('${surah.totalVerses} আয়াত • ${meta.rukuCount} রুকু • ${surah.type == 'meccan' ? 'মাক্কী' : 'মাদানী'}', style: const TextStyle(fontSize: 12)),
        trailing: Text(surah.arabicName, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildReader(BuildContext context, QuranSurah surah) {
    final meta = QuranMetadataService.forSurah(surah.number);
    return Column(
      children: [
        _buildSurahHeader(context, surah, meta),
        if (_loadingTranslation || _loadingTafsir)
          const LinearProgressIndicator(minHeight: 2),
        if (_translationError != null)
          _messageCard(context, _translationError!, Icons.error_outline_rounded),
        if (_tafsirError != null)
          _messageCard(context, 'ব্যাখ্যা এখন পাওয়া যায়নি। আবার চেষ্টা করুন।', Icons.menu_book_outlined),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
            itemCount: surah.verses.length,
            itemBuilder: (context, index) {
              final verse = surah.verses[index];
              final key = _ayahKeys.putIfAbsent(verse.number, GlobalKey.new);
              return KeyedSubtree(key: key, child: _verseCard(context, surah, verse));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSurahHeader(BuildContext context, QuranSurah surah, QuranSurahMetadata meta) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 2),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: primary.withValues(alpha: .10)), boxShadow: [BoxShadow(color: primary.withValues(alpha: .04), blurRadius: 18, offset: const Offset(0, 6))]),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(onPressed: () => setState(() { _selectedSurah = null; _resumeAyah = null; }), icon: const Icon(Icons.arrow_back_rounded, size: 20)),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [Text(surah.arabicName, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: primary)), const SizedBox(height: 2), Text(surah.banglaName ?? surah.transliteration, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)), Text(surah.transliteration, style: TextStyle(fontSize: 11.5, color: context.secondaryTextColor))])),
              IconButton(onPressed: _showSettings, icon: const Icon(Icons.text_fields_rounded, size: 19)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(alignment: WrapAlignment.center, spacing: 7, runSpacing: 7, children: [
            _metaChip(context, 'আয়াত', _bnNumber(surah.totalVerses)),
            _metaChip(context, 'রুকু', _bnNumber(meta.rukuCount)),
            _metaChip(context, 'সিজদা', _bnNumber(meta.sajdaCount)),
            _metaChip(context, 'ধরণ', surah.type == 'meccan' ? 'মাক্কী' : 'মাদানী'),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _sourceButton(context, Icons.translate_rounded, _translationEdition.title, () => _showTranslationPicker(surah))),
            const SizedBox(width: 8),
            Expanded(child: _sourceButton(context, Icons.menu_book_rounded, _selectedTafsirTitle, () => _showTafsirPicker(surah))),
          ]),
          const SizedBox(height: 8),
          Text('অনুবাদ ও ব্যাখ্যা অনলাইনে একবার লোড হলে ডিভাইসে ক্যাশ থাকবে।', style: TextStyle(fontSize: 10.5, color: context.secondaryTextColor)),
        ],
      ),
    );
  }

  String get _selectedTafsirTitle => QuranTafsirService.editions.firstWhere((e) => e.slug == _selectedTafsir).title;

  Widget _metaChip(BuildContext context, String label, String value) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: primary.withValues(alpha: .06), borderRadius: BorderRadius.circular(11)), child: Text('$label  $value', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: context.secondaryTextColor)));
  }

  Widget _sourceButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(color: primary.withValues(alpha: .055), borderRadius: BorderRadius.circular(12), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), child: Row(children: [Icon(icon, size: 17, color: primary), const SizedBox(width: 6), Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))), const Icon(Icons.keyboard_arrow_down_rounded, size: 16)]))));
  }

  Widget _verseCard(BuildContext context, QuranSurah surah, QuranVerse verse) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final translation = _translationByAyah[verse.number] ?? verse.bangla;
    final tafsir = _tafsirByAyah[verse.number];
    final arabicLineHeight = _arabicFontSize >= 25 ? 1.72 : 1.62;
    final translationLineHeight = _translationFontSize >= 18 ? 1.55 : 1.48;

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(21), border: Border.all(color: primary.withValues(alpha: .07))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(width: 30, height: 30, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: primary.withValues(alpha: .10)), child: Text(_bnNumber(verse.number), style: TextStyle(color: primary, fontSize: 10.5, fontWeight: FontWeight.w800))),
          const Spacer(),
          Text('${surah.number}:${verse.number}', style: TextStyle(fontSize: 10.5, color: context.secondaryTextColor, fontFeatures: const [FontFeature.tabularFigures()])),
        ]),
        const SizedBox(height: 12),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: '${verse.arabic} ', style: TextStyle(fontSize: _arabicFontSize, height: arabicLineHeight, fontWeight: FontWeight.w500)),
              TextSpan(text: '۝${_arabicNumber(verse.number)}', style: TextStyle(color: primary, fontSize: _arabicFontSize * .72, fontWeight: FontWeight.w800, height: arabicLineHeight)),
            ]),
            textAlign: TextAlign.right,
          ),
        ),
        if (translation != null && translation.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.fromLTRB(13, 11, 13, 11), decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(15)), child: Text(translation, textAlign: TextAlign.left, style: TextStyle(fontSize: _translationFontSize, height: translationLineHeight))),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.menu_book_rounded, size: 16, color: primary),
          const SizedBox(width: 5),
          Text('ব্যাখ্যা', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: primary)),
          const Spacer(),
          Text(_selectedTafsirTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, color: context.secondaryTextColor)),
        ]),
        if (_loadingTafsir && _tafsirByAyah.isEmpty) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator(minHeight: 2)),
        if (tafsir != null) ...[
          const SizedBox(height: 7),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primary.withValues(alpha: .035), borderRadius: BorderRadius.circular(14), border: Border.all(color: primary.withValues(alpha: .07))), child: Text(tafsir, style: const TextStyle(fontSize: 13.5, height: 1.55))),
        ],
      ]),
    );
  }

  void _showTranslationPicker(QuranSurah surah) {
    showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Padding(padding: EdgeInsets.fromLTRB(18, 6, 18, 12), child: Align(alignment: Alignment.centerLeft, child: Text('অনুবাদ নির্বাচন করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
      for (final edition in QuranTranslationService.editions)
        RadioListTile<String>(value: edition.id, groupValue: _selectedTranslation, title: Text(edition.title), subtitle: Text(edition.author), onChanged: (value) async { if (value == null) return; Navigator.pop(context); setState(() => _selectedTranslation = value); final prefs = await SharedPreferences.getInstance(); await prefs.setString('onudhabon_translation', value); await _loadTranslation(surah); }),
    ])));
  }

  void _showTafsirPicker(QuranSurah surah) {
    showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Padding(padding: EdgeInsets.fromLTRB(18, 6, 18, 12), child: Align(alignment: Alignment.centerLeft, child: Text('ব্যাখ্যা / তাফসির নির্বাচন করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
      for (final edition in QuranTafsirService.editions)
        RadioListTile<String>(value: edition.slug, groupValue: _selectedTafsir, title: Text(edition.title), onChanged: (value) async { if (value == null) return; Navigator.pop(context); setState(() => _selectedTafsir = value); final prefs = await SharedPreferences.getInstance(); await prefs.setString('onudhabon_tafsir', value); await _loadTafsir(surah); }),
    ])));
  }

  Widget _messageCard(BuildContext context, String message, IconData icon) => Padding(padding: const EdgeInsets.fromLTRB(14, 7, 14, 0), child: Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Theme.of(context).colorScheme.error.withValues(alpha: .06), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(icon, size: 17, color: Theme.of(context).colorScheme.error), const SizedBox(width: 7), Expanded(child: Text(message, style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.error)))])));

  Future<void> _showSettings() async {
    await showModalBottomSheet<void>(context: context, showDragHandle: true, isScrollControlled: true, builder: (context) => StatefulBuilder(builder: (context, setSheetState) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(18, 5, 18, 20), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [const Icon(Icons.text_fields_rounded), const SizedBox(width: 9), const Text('পড়ার সেটিংস', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), const Spacer(), TextButton(onPressed: () { setState(() { _arabicFontSize = _defaultArabicFontSize; _translationFontSize = _defaultTranslationFontSize; }); _saveSettings(); setSheetState(() {}); }, child: const Text('ডিফল্ট'))]),
      const SizedBox(height: 8),
      _fontControl(context, 'আরবি আয়াত', _arabicFontSize, _minArabicFontSize, _maxArabicFontSize, (v) { setState(() => _arabicFontSize = v); _saveSettings(); setSheetState(() {}); }),
      const SizedBox(height: 10),
      _fontControl(context, 'অনুবাদ', _translationFontSize, _minTranslationFontSize, _maxTranslationFontSize, (v) { setState(() => _translationFontSize = v); _saveSettings(); setSheetState(() {}); }),
    ]))));
  }

  Widget _fontControl(BuildContext context, String label, double value, double min, double max, ValueChanged<double> onChanged) => Column(children: [Row(children: [Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)), const Spacer(), Text('${value.round()}px', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700))]), Slider(value: value, min: min, max: max, divisions: (max - min).round(), onChanged: onChanged)]);

  String _bnNumber(int number) {
    const en = '0123456789';
    const bn = '০১২৩৪৫৬৭৮৯';
    return number.toString().split('').map((d) { final i = en.indexOf(d); return i < 0 ? d : bn[i]; }).join();
  }

  String _arabicNumber(int number) {
    const en = '0123456789';
    const ar = '٠١٢٣٤٥٦٧٨٩';
    return number.toString().split('').map((d) { final i = en.indexOf(d); return i < 0 ? d : ar[i]; }).join();
  }
}
