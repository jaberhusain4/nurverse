import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/app_localizations.dart';
import '../../models/quran_surah.dart';
import '../../services/last_read_service.dart';
import '../../services/quran_data_service.dart';
import '../../services/quran_metadata_service.dart';
import '../../services/quran_tafsir_service.dart';
import '../../services/quran_translation_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/quran/bismillah_header.dart';

class OnudhabonQuranReader extends StatefulWidget {
  final bool openLastRead;
  final int? initialSurahNumber;

  const OnudhabonQuranReader({
    super.key,
    this.openLastRead = false,
    this.initialSurahNumber,
  });

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
  bool _showAyah = true;
  bool _showTranslation = true;
  bool _showTafsir = false;

  String _surahDisplayName(QuranSurah surah, AppLocalizations l10n) {
    const banglaNames = <int, String>{
      1: 'আল-ফাতিহা', 2: 'আল-বাকারা', 3: 'আলে-ইমরান', 4: 'আন-নিসা', 5: 'আল-মায়িদাহ',
      6: 'আল-আনআম', 7: 'আল-আরাফ', 8: 'আল-আনফাল', 9: 'আত-তাওবাহ', 10: 'ইউনুস',
      11: 'হূদ', 12: 'ইউসুফ', 13: 'আর-রাদ', 14: 'ইবরাহিম', 15: 'আল-হিজর', 16: 'আন-নাহল',
      17: 'আল-ইসরা', 18: 'আল-কাহফ', 19: 'মারইয়াম', 20: 'ত্বা-হা', 21: 'আল-আম্বিয়া', 22: 'আল-হাজ্জ',
      23: 'আল-মুমিনূন', 24: 'আন-নূর', 25: 'আল-ফুরকান', 26: 'আশ-শুআরা', 27: 'আন-নামল', 28: 'আল-কাসাস',
      29: 'আল-আনকাবুত', 30: 'আর-রূম', 31: 'লুকমান', 32: 'আস-সাজদাহ', 33: 'আল-আহযাব', 34: 'সাবা',
      35: 'ফাতির', 36: 'ইয়াসীন', 37: 'আস-সাফফাত', 38: 'সাদ', 39: 'আয-যুমার', 40: 'গাফির', 41: 'ফুসসিলাত',
      42: 'আশ-শূরা', 43: 'আয-যুখরুফ', 44: 'আদ-দুখান', 45: 'আল-জাসিয়াহ', 46: 'আল-আহকাফ', 47: 'মুহাম্মাদ',
      48: 'আল-ফাতহ', 49: 'আল-হুজুরাত', 50: 'কাফ', 51: 'আয-যারিয়াত', 52: 'আত-তূর', 53: 'আন-নাজম',
      54: 'আল-কামার', 55: 'আর-রহমান', 56: 'আল-ওয়াকিয়াহ', 57: 'আল-হাদীদ', 58: 'আল-মুজাদালাহ',
      59: 'আল-হাশর', 60: 'আল-মুমতাহিনাহ', 61: 'আস-সাফ', 62: 'আল-জুমুআহ', 63: 'আল-মুনাফিকূন',
      64: 'আত-তাগাবুন', 65: 'আত-তালাক', 66: 'আত-তাহরীম', 67: 'আল-মুলক', 68: 'আল-কলম', 69: 'আল-হাক্কাহ',
      70: 'আল-মাআরিজ', 71: 'নূহ', 72: 'আল-জিন', 73: 'আল-মুযযাম্মিল', 74: 'আল-মুদ্দাসসির', 75: 'আল-কিয়ামাহ',
      76: 'আল-ইনসান', 77: 'আল-মুরসালাত', 78: 'আন-নাবা', 79: 'আন-নাযিয়াত', 80: 'আবাসা', 81: 'আত-তাকভীর',
      82: 'আল-ইনফিতার', 83: 'আল-মুতাফফিফীন', 84: 'আল-ইনশিকাক', 85: 'আল-বুরুজ', 86: 'আত-তারিক',
      87: 'আল-আ’লা', 88: 'আল-গাশিয়াহ', 89: 'আল-ফজর', 90: 'আল-বালাদ', 91: 'আশ-শামস', 92: 'আল-লাইল',
      93: 'আদ-দুহা', 94: 'আশ-শরহ', 95: 'আত-তীন', 96: 'আল-আলাক', 97: 'আল-কদর', 98: 'আল-বাইয়্যিনাহ',
      99: 'আয-যিলযাল', 100: 'আল-আদিয়াত', 101: 'আল-কারিয়াহ', 102: 'আত-তাকাসুর', 103: 'আল-আসর', 104: 'আল-হুমাযাহ',
      105: 'আল-ফীল', 106: 'কুরাইশ', 107: 'আল-মাউন', 108: 'আল-কাওসার', 109: 'আল-কাফিরুন', 110: 'আন-নসর',
      111: 'আল-মাসাদ', 112: 'আল-ইখলাস', 113: 'আল-ফালাক', 114: 'আন-নাস',
    };
    if (l10n.isArabic) return surah.arabicName;
    if (l10n.isEnglish) return surah.transliteration;
    return banglaNames[surah.number] ?? surah.transliteration;
  }

  String _localizedText(AppLocalizations l10n, String bn, String en, String ar) {
    return l10n.isArabic ? ar : l10n.tr(bn, en);
  }

  QuranTranslationEdition get _translationEdition => QuranTranslationService.editions.firstWhere(
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

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _arabicSize = (prefs.getDouble('onudhabon_arabic_font_size') ?? 20).clamp(16.0, 28.0);
    _translationSize = (prefs.getDouble('onudhabon_translation_font_size') ?? 15).clamp(12.0, 21.0);
    _translationId = prefs.getString('onudhabon_translation') ?? _translationId;
    _tafsirId = prefs.getString('onudhabon_tafsir') ?? _tafsirId;
    _showAyah = prefs.getBool('onudhabon_show_ayah') ?? true;
    _showTranslation = prefs.getBool('onudhabon_show_translation') ?? true;
    _showTafsir = prefs.getBool('onudhabon_show_tafsir') ?? false;

    if (!QuranTranslationService.editions.any((e) => e.id == _translationId)) {
      _translationId = QuranTranslationService.editions.first.id;
    }

    await _data.init();

    if (widget.initialSurahNumber != null && widget.initialSurahNumber! >= 1 && widget.initialSurahNumber! <= 114) {
      _selectedSurah = widget.initialSurahNumber;
      _resumeAyah = null;
    } else if (widget.openLastRead) {
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
    await Future.wait([_loadTranslation(surah), _loadTafsir(surah)]);
    if (mounted) setState(() => _loadingSources = false);
  }

  Future<void> _loadTranslation(QuranSurah surah) async {
    try {
      var currentSurah = surah;
      if (_translationEdition.localMuhiuddin && !_data.translationAvailable) {
        final loaded = await _data.downloadTranslation();
        if (!loaded && !_data.translationAvailable) {
          throw StateError('মুহিউদ্দীন খান-এর বাংলা অনুবাদ লোড করা যায়নি।');
        }
        currentSurah = _data.getSurah(surah.number);
      }

      final local = <int, String>{
        for (final verse in currentSurah.verses)
          if (verse.bangla != null && verse.bangla!.trim().isNotEmpty) verse.number: verse.bangla!,
      };
      final result = await _translation.getSurahTranslation(
        edition: _translationEdition,
        surahNumber: currentSurah.number,
        localMuhiuddin: local,
      );
      if (result.isEmpty) {
        throw StateError('মুহিউদ্দীন খান-এর অনুবাদ এই সূরার জন্য পাওয়া যায়নি।');
      }
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
      final result = await _tafsir.getSurahTafsir(slug: _tafsirId, surahNumber: surah.number);
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
    await _savePosition(number, 1);
    if (!mounted) return;
    setState(() {
      _selectedSurah = number;
      _resumeAyah = null;
      _translations = {};
      _tafsirs = {};
      _ayahKeys.clear();
    });
    await _loadSources(_data.getSurah(number));
  }

  void _backToQuranScreen() => Navigator.of(context).pop();

  void _scrollToResume() {
    final ayah = _resumeAyah;
    if (ayah == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _ayahKeys[ayah]?.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(target, alignment: .08, duration: const Duration(milliseconds: 220));
      }
    });
  }

  Future<void> _savePosition(int surahNumber, int ayahNumber) async {
    final surah = _data.getSurah(surahNumber);
    final safe = ayahNumber.clamp(1, surah.totalVerses).toInt();
    final progress = surah.totalVerses <= 1 ? 0.0 : ((safe - 1) / (surah.totalVerses - 1)).clamp(0.0, 1.0).toDouble();
    await LastReadService.saveLastRead(surahName: surah.banglaName ?? surah.transliteration, paraNo: 1, pageNo: safe, progress: progress, mode: 'onudhabon', surahNumber: surahNumber, ayahNumber: safe);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('onudhabon_arabic_font_size', _arabicSize);
    await prefs.setDouble('onudhabon_translation_font_size', _translationSize);
    await prefs.setBool('onudhabon_show_ayah', _showAyah);
    await prefs.setBool('onudhabon_show_translation', _showTranslation);
    await prefs.setBool('onudhabon_show_tafsir', _showTafsir);
  }

  void _toggleReadingPart(String part) {
    setState(() {
      switch (part) {
        case 'ayah': if (_showAyah && !_showTranslation && !_showTafsir) return; _showAyah = !_showAyah; break;
        case 'translation': if (_showTranslation && !_showAyah && !_showTafsir) return; _showTranslation = !_showTranslation; break;
        case 'tafsir': if (_showTafsir && !_showAyah && !_showTranslation) return; _showTafsir = !_showTafsir; break;
      }
    });
    _saveSettings();
  }

  Future<void> _showReadingSettings() async {
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                const Icon(Icons.text_fields_rounded), const SizedBox(width: 8),
                Text(_localizedText(l10n, 'পড়ার সেটিংস', 'Reading settings', 'إعدادات القراءة'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() { _arabicSize = 20; _translationSize = 15; });
                    _saveSettings();
                    setSheetState(() {});
                  },
                  child: Text(_localizedText(l10n, 'ডিফল্ট', 'Default', 'افتراضي')),
                ),
              ]),
              Align(alignment: Alignment.centerLeft, child: Text(_localizedText(l10n, 'কি কি দেখাবেন', 'What to show', 'ماذا تريد أن تعرض'), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700))),
              const SizedBox(height: 6),
              Wrap(spacing: 7, runSpacing: 7, children: [
                FilterChip(label: Text(_localizedText(l10n, 'আয়াত', 'Ayah', 'الآية')), selected: _showAyah, onSelected: (_) { _toggleReadingPart('ayah'); setSheetState(() {}); }),
                FilterChip(label: Text(_localizedText(l10n, 'অনুবাদ', 'Translation', 'الترجمة')), selected: _showTranslation, onSelected: (_) { _toggleReadingPart('translation'); setSheetState(() {}); }),
                FilterChip(label: Text(_localizedText(l10n, 'তাফসির', 'Tafsir', 'التفسير')), selected: _showTafsir, onSelected: (_) { _toggleReadingPart('tafsir'); setSheetState(() {}); }),
              ]),
              const SizedBox(height: 8),
              _slider(_localizedText(l10n, 'আরবি আয়াত', 'Arabic Ayah', 'الآية العربية'), _arabicSize, 16, 28, (value) { setState(() => _arabicSize = value); _saveSettings(); setSheetState(() {}); }),
              _slider(_localizedText(l10n, 'অনুবাদ', 'Translation', 'الترجمة'), _translationSize, 12, 21, (value) { setState(() => _translationSize = value); _saveSettings(); setSheetState(() {}); }),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(children: [
      Row(children: [Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)), const Spacer(), Text('${value.round()}px', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))]),
      Slider(value: value, min: min, max: max, divisions: (max - min).round(), onChanged: onChanged),
    ]);
  }

  Future<void> _showTranslationPicker(QuranSurah surah) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.all(16), child: Align(alignment: Alignment.centerLeft, child: Text(_localizedText(l10n, 'অনুবাদ নির্বাচন করুন', 'Select translation', 'اختر الترجمة'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
          for (final edition in QuranTranslationService.editions)
            RadioListTile<String>(value: edition.id, groupValue: _translationId, title: Text(edition.title), subtitle: Text(edition.author), onChanged: (value) => Navigator.pop(sheetContext, value)),
        ]),
      ),
    );
    if (selected == null) return;
    setState(() => _translationId = selected);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onudhabon_translation', selected);
    if (mounted) await _loadTranslation(surah);
  }

  Future<void> _showTafsirPicker(QuranSurah surah) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.all(16), child: Align(alignment: Alignment.centerLeft, child: Text(_localizedText(l10n, 'ব্যাখ্যা / তাফসির নির্বাচন করুন', 'Select Tafsir / Explanation', 'اختر التفسير / الشرح'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
          for (final edition in QuranTafsirService.editions)
            RadioListTile<String>(value: edition.slug, groupValue: _tafsirId, title: Text(edition.title), onChanged: (value) => Navigator.pop(sheetContext, value)),
        ]),
      ),
    );
    if (selected == null) return;
    setState(() => _tafsirId = selected);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onudhabon_tafsir', selected);
    if (mounted) await _loadTafsir(surah);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final selected = _selectedSurah == null ? null : _data.getSurah(_selectedSurah!);
    return Scaffold(
      appBar: AppBar(
        title: Text(_localizedText(l10n, 'অনুধাবন কুরআন', 'Onudhabon Quran', 'قرآن الفهم'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        centerTitle: true,
        leading: selected == null ? null : IconButton(onPressed: _backToQuranScreen, icon: const Icon(Icons.arrow_back_rounded, size: 20)),
        actions: selected == null ? null : [IconButton(onPressed: _showReadingSettings, icon: const Icon(Icons.text_fields_rounded, size: 20))],
      ),
      body: selected == null ? _buildPicker(context) : _buildReader(context, selected),
    );
  }

  Widget _buildPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = _query.trim().toLowerCase();
    final surahs = _data.surahList.where((surah) {
      if (query.isEmpty) return true;
      return surah.number.toString().contains(query) || surah.transliteration.toLowerCase().contains(query) || surah.arabicName.contains(query) || (surah.banglaName ?? '').contains(query);
    }).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        _introCard(context), const SizedBox(height: 12),
        TextField(controller: _searchController, onChanged: (value) => setState(() => _query = value), decoration: InputDecoration(hintText: _localizedText(l10n, 'সূরা খুঁজুন...', 'Search surah...', 'ابحث عن السورة...'), prefixIcon: const Icon(Icons.search_rounded, size: 20), filled: true, fillColor: context.cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
        const SizedBox(height: 14),
        Text(_localizedText(l10n, 'সূরা নির্বাচন করুন', 'Select a surah', 'اختر سورة'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...surahs.map((surah) => _surahTile(context, surah)),
      ],
    );
  }

  Widget _introCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [primary.withValues(alpha: .15), primary.withValues(alpha: .04)]), borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.auto_stories_rounded, color: primary, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_localizedText(l10n, 'পড়ুন, বুঝুন, অনুধাবন করুন', 'Read, Understand, Reflect', 'اقرأ وافهم وتدبر'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(_localizedText(l10n, 'আরবি আয়াত, ওয়াকফ চিহ্ন, বিভিন্ন অনুবাদ এবং নির্বাচিত ব্যাখ্যা—একটি উন্নত রিডিং অভিজ্ঞতা।', 'Arabic verses, pause signs, translations and selected explanations in one reading experience.', 'آيات عربية وعلامات الوقف وترجمات وشروحات مختارة في تجربة قراءة متكاملة.'), style: const TextStyle(fontSize: 12, height: 1.45)),
          ]),
        ],
      ),
    );
  }

  Widget _surahTile(BuildContext context, QuranSurah surah) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final meta = QuranMetadataService.forSurah(surah.number);
    final typeLabel = surah.type == 'meccan' ? _localizedText(l10n, 'মাক্কী', 'Meccan', 'مكية') : _localizedText(l10n, 'মাদানী', 'Medinan', 'مدنية');
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: primary.withValues(alpha: .07))),
      child: ListTile(
        onTap: () => _selectSurah(surah.number),
        leading: Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: primary.withValues(alpha: .09), borderRadius: BorderRadius.circular(13)), child: Text(l10n.isBangla ? _bn(surah.number) : l10n.isArabic ? _ar(surah.number) : '${surah.number}', style: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w800))),
        title: Text(_surahDisplayName(surah, l10n), textDirection: l10n.isArabic ? TextDirection.rtl : TextDirection.ltr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        subtitle: Text('${l10n.isBangla && (surah.banglaName?.trim().isNotEmpty ?? false) ? '${surah.banglaName!.trim()} • ' : ''}${l10n.isBangla ? _bn(surah.totalVerses) : l10n.isArabic ? _ar(surah.totalVerses) : surah.totalVerses} ${_localizedText(l10n, 'আয়াত', 'verses', 'آيات')} • ${l10n.isBangla ? _bn(meta.rukuCount) : l10n.isArabic ? _ar(meta.rukuCount) : meta.rukuCount} ${_localizedText(l10n, 'রুকু', 'ruku', 'ركوع')} • ${l10n.isBangla ? _bn(meta.sajdaCount) : l10n.isArabic ? _ar(meta.sajdaCount) : meta.sajdaCount} ${_localizedText(l10n, 'সিজদা', 'sajdah', 'سجود')} • $typeLabel', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
        trailing: Text(surah.arabicName, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildReader(BuildContext context, QuranSurah surah) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        if (_loadingSources) const LinearProgressIndicator(minHeight: 2),
        if (_translationError != null) _error(context, _translationError!),
        if (_tafsirError != null) _error(context, _localizedText(l10n, 'তাফসির লোড করা যায়নি। আবার চেষ্টা করুন।', 'Could not load Tafsir. Please try again.', 'تعذر تحميل التفسير. حاول مرة أخرى.')),
        Expanded(
          child: Builder(
            builder: (context) {
              final primary = Theme.of(context).colorScheme.primary;
              return ScrollbarTheme(
                data: ScrollbarThemeData(thumbColor: WidgetStatePropertyAll(primary.withValues(alpha: .72)), trackColor: WidgetStatePropertyAll(primary.withValues(alpha: .07)), trackBorderColor: WidgetStatePropertyAll(primary.withValues(alpha: .12)), thickness: const WidgetStatePropertyAll(7), radius: const Radius.circular(10), minThumbLength: 52),
                child: Scrollbar(controller: _scrollController, thumbVisibility: true, interactive: true, child: ListView.builder(controller: _scrollController, padding: const EdgeInsets.fromLTRB(14, 8, 18, 28), itemCount: surah.verses.length + 1, itemBuilder: (context, index) {
                  if (index == 0) return Column(children: [_surahHeader(context, surah), if (surah.number != 1 && surah.number != 9) const BismillahHeader(), const SizedBox(height: 4)]);
                  final verse = surah.verses[index - 1];
                  final key = _ayahKeys.putIfAbsent(verse.number, GlobalKey.new);
                  return KeyedSubtree(key: key, child: _ayahCard(context, surah, verse));
                })),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _surahHeader(BuildContext context, QuranSurah surah) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final meta = QuranMetadataService.forSurah(surah.number);
    final typeLabel = surah.type == 'meccan' ? _localizedText(l10n, 'মাক্কী', 'Meccan', 'مكية') : _localizedText(l10n, 'মাদানী', 'Medinan', 'مدنية');
    const buttonTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w700);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 2),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: primary.withValues(alpha: .10))),
      child: Column(children: [
        Row(children: [IconButton(onPressed: _backToQuranScreen, icon: const Icon(Icons.arrow_back_rounded, size: 20)), Expanded(child: Column(children: [Text(surah.arabicName, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: primary)), Text(surah.banglaName ?? surah.transliteration, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)), Text(surah.transliteration, style: TextStyle(fontSize: 11.5, color: context.secondaryTextColor))]))]),
        const SizedBox(height: 9),
        Wrap(alignment: WrapAlignment.center, spacing: 7, runSpacing: 7, children: [
          _chip(context, l10n.isBangla ? _bn(surah.totalVerses) : l10n.isArabic ? _ar(surah.totalVerses) : surah.totalVerses.toString(), _localizedText(l10n, 'আয়াত', 'verses', 'آيات')),
          _chip(context, l10n.isBangla ? _bn(meta.rukuCount) : l10n.isArabic ? _ar(meta.rukuCount) : meta.rukuCount.toString(), _localizedText(l10n, 'রুকু', 'ruku', 'ركوع')),
          _chip(context, l10n.isBangla ? _bn(meta.sajdaCount) : l10n.isArabic ? _ar(meta.sajdaCount) : meta.sajdaCount.toString(), _localizedText(l10n, 'সিজদা', 'sajdah', 'سجود')),
          _chip(context, typeLabel, ''),
        ]),
        const SizedBox(height: 9),
        Row(children: [
          Expanded(child: TextButton.icon(onPressed: () => _showTranslationPicker(surah), icon: const Icon(Icons.translate_rounded, size: 17), label: Text(_translationEdition.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: buttonTextStyle), style: TextButton.styleFrom(foregroundColor: primary, backgroundColor: primary.withValues(alpha: .055), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(width: 8),
          Expanded(child: TextButton.icon(onPressed: () => _showTafsirPicker(surah), icon: const Icon(Icons.menu_book_rounded, size: 17), label: Text(_localizedText(l10n, 'তাফসির / ব্যাখ্যা', 'Tafsir / Explanation', 'التفسير / الشرح'), maxLines: 1, style: buttonTextStyle), style: TextButton.styleFrom(foregroundColor: primary, backgroundColor: primary.withValues(alpha: .055), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
        ]),
        Align(alignment: Alignment.centerRight, child: OutlinedButton.icon(onPressed: () { setState(() => _showTafsir = !_showTafsir); _saveSettings(); }, icon: Icon(_showTafsir ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 15), label: Text(_showTafsir ? _localizedText(l10n, 'তাফসির লুকান', 'Hide Tafsir', 'إخفاء التفسير') : _localizedText(l10n, 'তাফসির দেখান', 'Show Tafsir', 'عرض التفسير'), style: buttonTextStyle), style: OutlinedButton.styleFrom(minimumSize: const Size(0, 32), padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5), tapTargetSize: MaterialTapTargetSize.shrinkWrap, side: BorderSide(color: primary.withValues(alpha: .32), width: 1.1), backgroundColor: primary.withValues(alpha: .055), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      ]),
    );
  }

  Widget _ayahCard(BuildContext context, QuranSurah surah, QuranVerse verse) {
    final primary = Theme.of(context).colorScheme.primary;
    final translation = _translations[verse.number];
    final tafsir = _tafsirs[verse.number];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Row(children: [CircleAvatar(radius: 15, backgroundColor: primary.withValues(alpha: .10), child: Text(_bn(verse.number), style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.w800))), const Spacer(), Text('${_bn(surah.number)}:${_bn(verse.number)}', style: TextStyle(fontSize: 10.5, color: context.secondaryTextColor))]),
        const SizedBox(height: 10),
        if (_showAyah) Container(width: double.infinity, alignment: Alignment.centerRight, child: Directionality(textDirection: TextDirection.rtl, child: Text.rich(TextSpan(children: [TextSpan(text: verse.arabic, style: TextStyle(fontSize: _arabicSize, height: _arabicSize >= 25 ? 1.72 : 1.60, fontWeight: FontWeight.w500)), TextSpan(text: '  ۝${_ar(verse.number)}', style: TextStyle(color: primary, fontSize: _arabicSize * .72, fontWeight: FontWeight.w800))]), textAlign: TextAlign.right))),
        if (_showTranslation && translation != null && translation.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(15)), child: Text(translation, textAlign: TextAlign.left, style: TextStyle(fontSize: _translationSize, height: _translationSize >= 18 ? 1.55 : 1.48))),
        ],
        if (_showTafsir && tafsir != null && tafsir.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primary.withValues(alpha: .035), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_tafsirTitle, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: primary)), const SizedBox(height: 6), Text(tafsir, style: const TextStyle(fontSize: 13.5, height: 1.55))]),
        ],
      ]),
    );
  }

  Widget _chip(BuildContext context, String value, String label) {
    final primary = Theme.of(context).colorScheme.primary;
    final text = label.isEmpty ? value : '$value $label';
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: primary.withValues(alpha: .07), borderRadius: BorderRadius.circular(20)), child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primary)));
  }

  Widget _error(BuildContext context, String text) {
    final color = Theme.of(context).colorScheme.error;
    return Padding(padding: const EdgeInsets.fromLTRB(14, 7, 14, 0), child: Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: .06), borderRadius: BorderRadius.circular(12)), child: Text(text, style: TextStyle(fontSize: 11.5, color: color)));
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
