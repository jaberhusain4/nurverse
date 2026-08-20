import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/quran_surah.dart';
import '../../services/last_read_service.dart';
import '../../services/quran_data_service.dart';
import '../../services/quran_metadata_service.dart';
import '../../services/quran_tafsir_service.dart';
import '../../services/quran_translation_service.dart';
import '../../theme/app_theme.dart';

class OnudhabonQuranReader extends StatefulWidget {
  final bool openLastRead;
  const OnudhabonQuranReader({super.key, this.openLastRead = false});

  @override
  State<OnudhabonQuranReader> createState() => _OnudhabonQuranReaderState();
}

class _OnudhabonQuranReaderState extends State<OnudhabonQuranReader> {
  final _data = QuranDataService.instance;
  final _translation = QuranTranslationService.instance;
  final _tafsir = QuranTafsirService.instance;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _ayahKeys = <int, GlobalKey>{};

  bool _loading = true;
  int? _selectedSurah;
  int? _resumeAyah;
  String _query = '';
  double _arabicSize = 20;
  double _translationSize = 15;
  String _translationId = QuranTranslationService.editions.first.id;
  String _tafsirId = QuranTafsirService.editions.first.slug;
  Map<int, String> _translations = {};
  Map<int, String> _tafsirs = {};
  String? _translationError;
  String? _tafsirError;
  bool _loadingSources = false;

  QuranTranslationEdition get _translationEdition =>
      QuranTranslationService.editions.firstWhere(
        (e) => e.id == _translationId,
        orElse: () => QuranTranslationService.editions.first,
      );

  String get _tafsirTitle => QuranTafsirService.editions.firstWhere(
        (e) => e.slug == _tafsirId,
        orElse: () => QuranTafsirService.editions.first,
      ).title;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _arabicSize = (prefs.getDouble('onudhabon_arabic_font_size') ?? 20)
        .clamp(16.0, 28.0);
    _translationSize = (prefs.getDouble('onudhabon_translation_font_size') ?? 15)
        .clamp(12.0, 21.0);
    _translationId = prefs.getString('onudhabon_translation') ?? _translationId;
    _tafsirId = prefs.getString('onudhabon_tafsir') ?? _tafsirId;

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
      await _loadSources(_data.getSurah(_selectedSurah!));
      _scrollToResume();
    }
  }

  Future<void> _loadSources(QuranSurah surah) async {
    setState(() => _loadingSources = true);
    await Future.wait([
      _loadTranslation(surah),
      _loadTafsir(surah),
    ]);
    if (mounted) setState(() => _loadingSources = false);
  }

  Future<void> _loadTranslation(QuranSurah surah) async {
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
      if (!mounted) return;
      setState(() {
        _translations = result;
        _translationError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _translationError = e.toString());
    }
  }

  Future<void> _loadTafsir(QuranSurah surah) async {
    try {
      final result = await _tafsir.getSurahTafsir(
        slug: _tafsirId,
        surahNumber: surah.number,
      );
      if (!mounted) return;
      setState(() {
        _tafsirs = result;
        _tafsirError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _tafsirError = e.toString());
    }
  }

  Future<void> _selectSurah(int number) async {
    setState(() {
      _selectedSurah = number;
      _resumeAyah = 1;
      _translations = {};
      _tafsirs = {};
      _ayahKeys.clear();
    });
    final surah = _data.getSurah(number);
    await _loadSources(surah);
    await _savePosition(number, 1);
  }

  void _backToQuranScreen() {
    Navigator.of(context).pop();
  }

  void _scrollToResume() {
    final ayah = _resumeAyah;
    if (ayah == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _ayahKeys[ayah]?.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          alignment: .08,
          duration: const Duration(milliseconds: 220),
        );
      }
    });
  }

  Future<void> _savePosition(int surahNumber, int ayahNumber) async {
    final surah = _data.getSurah(surahNumber);
    final safe = ayahNumber.clamp(1, surah.totalVerses).toInt();
    final progress = surah.totalVerses <= 1
        ? 0.0
        : ((safe - 1) / (surah.totalVerses - 1)).clamp(0.0, 1.0).toDouble();
    await LastReadService.saveLastRead(
      surahName: surah.banglaName ?? surah.transliteration,
      paraNo: 1,
      pageNo: safe,
      progress: progress,
      mode: 'onudhabon',
      surahNumber: surahNumber,
      ayahNumber: safe,
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('onudhabon_arabic_font_size', _arabicSize);
    await prefs.setDouble('onudhabon_translation_font_size', _translationSize);
  }

  Future<void> _showSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.text_fields_rounded),
                    const SizedBox(width: 8),
                    const Text('পড়ার সেটিংস', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _arabicSize = 20;
                          _translationSize = 15;
                        });
                        _saveSettings();
                        setSheetState(() {});
                      },
                      child: const Text('ডিফল্ট'),
                    ),
                  ],
                ),
                _slider('আরবি আয়াত', _arabicSize, 16, 28, (v) {
                  setState(() => _arabicSize = v);
                  _saveSettings();
                  setSheetState(() {});
                }),
                _slider('অনুবাদ', _translationSize, 12, 21, (v) {
                  setState(() => _translationSize = v);
                  _saveSettings();
                  setSheetState(() {});
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
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

  Future<void> _showTranslationPicker(QuranSurah surah) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('অনুবাদ নির্বাচন করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
            for (final edition in QuranTranslationService.editions)
              RadioListTile<String>(
                value: edition.id,
                groupValue: _translationId,
                title: Text(edition.title),
                subtitle: Text(edition.author),
                onChanged: (value) => Navigator.pop(sheetContext, value),
              ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    setState(() => _translationId = selected);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onudhabon_translation', selected);
    await _loadTranslation(surah);
  }

  Future<void> _showTafsirPicker(QuranSurah surah) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('ব্যাখ্যা / তাফসির নির্বাচন করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
            for (final edition in QuranTafsirService.editions)
              RadioListTile<String>(
                value: edition.slug,
                groupValue: _tafsirId,
                title: Text(edition.title),
                onChanged: (value) => Navigator.pop(sheetContext, value),
              ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    setState(() => _tafsirId = selected);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onudhabon_tafsir', selected);
    await _loadTafsir(surah);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final selected = _selectedSurah == null ? null : _data.getSurah(_selectedSurah!);
    return Scaffold(
      appBar: AppBar(
        title: const Text('অনুধাবন কুরআন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        centerTitle: true,
        automaticallyImplyLeading: selected != null,
        leading: selected == null ? null : IconButton(onPressed: _backToQuranScreen, icon: const Icon(Icons.arrow_back_rounded, size: 20)),
        actions: selected == null
            ? null
            : [
                IconButton(onPressed: _showSettings, tooltip: 'পড়ার সেটিংস', icon: const Icon(Icons.text_fields_rounded, size: 20)),
              ],
      ),
      body: selected == null ? _buildPicker(context) : _buildReader(context, selected),
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
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
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
        ...surahs.map((surah) => _surahTile(context, surah)),
      ],
    );
  }

  Widget _introCard(BuildContext context) {
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
          Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.auto_stories_rounded, color: primary, size: 24)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('পড়ুন, বুঝুন, অনুধাবন করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), SizedBox(height: 4), Text('আরবি আয়াত, বিভিন্ন অনুবাদ এবং নির্বাচিত ব্যাখ্যা—একটি premium reading experience.', style: TextStyle(fontSize: 12, height: 1.45))])),
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
        leading: Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: primary.withValues(alpha: .09), borderRadius: BorderRadius.circular(13)), child: Text(_bn(surah.number), style: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w800))),
        title: Text(surah.banglaName ?? surah.transliteration, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        subtitle: Text('${surah.totalVerses} আয়াত • ${meta.rukuCount} রুকু • ${meta.sajdaCount} সিজদা • ${surah.type == 'meccan' ? 'মাক্কী' : 'মাদানী'}', style: const TextStyle(fontSize: 12)),
        trailing: Text(surah.arabicName, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildReader(BuildContext context, QuranSurah surah) {
    return Column(
      children: [
        _surahHeader(context, surah),
        if (_loadingSources) const LinearProgressIndicator(minHeight: 2),
        if (_translationError != null) _error(context, _translationError!),
        if (_tafsirError != null) _error(context, 'এই ব্যাখ্যাটি এখন পাওয়া যায়নি। অন্য ব্যাখ্যা নির্বাচন করতে পারেন।'),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
            itemCount: surah.verses.length,
            itemBuilder: (context, index) {
              final verse = surah.verses[index];
              final key = _ayahKeys.putIfAbsent(verse.number, GlobalKey.new);
              return KeyedSubtree(key: key, child: _ayahCard(context, surah, verse));
            },
          ),
        ),
      ],
    );
  }

  Widget _surahHeader(BuildContext context, QuranSurah surah) {
    final primary = Theme.of(context).colorScheme.primary;
    final meta = QuranMetadataService.forSurah(surah.number);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 2),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: primary.withValues(alpha: .10))),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(onPressed: _backToQuranScreen, icon: const Icon(Icons.arrow_back_rounded, size: 20)),
              Expanded(child: Column(children: [Text(surah.arabicName, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: primary)), Text(surah.banglaName ?? surah.transliteration, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)), Text(surah.transliteration, style: TextStyle(fontSize: 11.5, color: context.secondaryTextColor))])),
              IconButton(onPressed: _showSettings, icon: const Icon(Icons.text_fields_rounded, size: 19)),
            ],
          ),
          const SizedBox(height: 9),
          Wrap(alignment: WrapAlignment.center, spacing: 7, runSpacing: 7, children: [
            _chip(context, '${surah.totalVerses}', 'আয়াত'),
            _chip(context, '${meta.rukuCount}', 'রুকু'),
            _chip(context, '${meta.sajdaCount}', 'সিজদা'),
            _chip(context, surah.type == 'meccan' ? 'মাক্কী' : 'মাদানী', 'ধরন'),
          ]),
          const SizedBox(height: 9),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => _showTranslationPicker(surah), icon: const Icon(Icons.translate_rounded, size: 17), label: Text(_translationEdition.title, maxLines: 1, overflow: TextOverflow.ellipsis))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(onPressed: () => _showTafsirPicker(surah), icon: const Icon(Icons.menu_book_rounded, size: 17), label: const Text('তাফসির', maxLines: 1))),
          ]),
        ],
      ),
    );
  }

  Widget _ayahCard(BuildContext context, QuranSurah surah, QuranVerse verse) {
    final primary = Theme.of(context).colorScheme.primary;
    final translation = _translations[verse.number];
    final tafsir = _tafsirs[verse.number];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: primary.withValues(alpha: .07))),
      child: Column(
        children: [
          Row(children: [CircleAvatar(radius: 15, backgroundColor: primary.withValues(alpha: .10), child: Text(_bn(verse.number), style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.w800))), const Spacer(), Text('${surah.number}:${verse.number}', style: TextStyle(fontSize: 10.5, color: context.secondaryTextColor))]),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: verse.arabic.trim(), style: TextStyle(fontSize: _arabicSize, height: _arabicSize >= 25 ? 1.7 : 1.58, fontWeight: FontWeight.w500)),
                  TextSpan(text: '  ۝${_ar(verse.number)}', style: TextStyle(color: primary, fontSize: _arabicSize * .72, fontWeight: FontWeight.w800)),
                ]),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          if (translation != null && translation.trim().isNotEmpty) ...[
            const SizedBox(height: 11),
            Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(15)), child: Text(translation, textAlign: TextAlign.left, style: TextStyle(fontSize: _translationSize, height: _translationSize >= 18 ? 1.55 : 1.48))),
          ],
          if (tafsir != null && tafsir.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primary.withValues(alpha: .035), borderRadius: BorderRadius.circular(14), border: Border.all(color: primary.withValues(alpha: .07))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_tafsirTitle, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: primary)), const SizedBox(height: 6), Text(tafsir, style: const TextStyle(fontSize: 13.5, height: 1.55))])),
          ],
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String value, String label) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: primary.withValues(alpha: .07), borderRadius: BorderRadius.circular(20)), child: Text('$value $label', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primary)));
  }

  Widget _error(BuildContext context, String text) {
    final color = Theme.of(context).colorScheme.error;
    return Padding(padding: const EdgeInsets.fromLTRB(14, 7, 14, 0), child: Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: .06), borderRadius: BorderRadius.circular(12)), child: Text(text, style: TextStyle(fontSize: 11.5, color: color))));
  }

  String _bn(int n) {
    const en = '0123456789';
    const bn = '০১২৩৪৫৬৭৮৯';
    return n.toString().split('').map((d) => bn[en.indexOf(d)]).join();
  }

  String _ar(int n) {
    const en = '0123456789';
    const ar = '٠١٢٣٤٥٦٧٨٩';
    return n.toString().split('').map((d) => ar[en.indexOf(d)]).join();
  }
}
