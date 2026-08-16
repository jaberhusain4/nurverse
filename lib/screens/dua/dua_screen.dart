import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/dua_data.dart';
import '../../localization/app_localizations.dart';
import '../../services/dua_voice_settings_service.dart';
import 'dua_voice_settings_screen.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  IconData _iconFor(String name) {
    switch (name) {
      case 'wb_twilight': return Icons.wb_twilight;
      case 'mosque_outlined': return Icons.mosque_outlined;
      case 'wb_sunny_outlined': return Icons.wb_sunny_outlined;
      case 'sentiment_dissatisfied_outlined': return Icons.sentiment_dissatisfied_outlined;
      case 'restaurant_outlined': return Icons.restaurant_outlined;
      case 'directions_bus_outlined': return Icons.directions_bus_outlined;
      default: return Icons.favorite_border_rounded;
    }
  }

  String _title(AppLocalizations l10n, DuaCategory category) => l10n.isBangla ? category.titleBn : category.titleEn;
  String _subtitle(AppLocalizations l10n, DuaCategory category) => l10n.isBangla ? category.subtitleBn : category.subtitleEn;

  List<DuaCategory> _filtered() {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return duaCategories;
    return duaCategories.where((category) {
      final categoryText = '${category.titleBn} ${category.titleEn} ${category.subtitleBn} ${category.subtitleEn}'.toLowerCase();
      final itemText = category.items.map((item) => '${item.titleBn} ${item.titleEn} ${item.translationBn} ${item.translationEn}').join(' ').toLowerCase();
      return categoryText.contains(query) || itemText.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final categories = _filtered();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr("দুআ ও জিকির", 'Dua & Dhikr'), style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: l10n.tr('দুআর অডিও সেটিংস', 'Dua audio settings'),
            icon: const Icon(Icons.record_voice_over_rounded),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DuaVoiceSettingsScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(context, l10n),
            const SizedBox(height: 18),
            Text(l10n.tr("আজকের গুরুত্বপূর্ণ দুআ", "Today's Important Dua"), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 9),
            _buildDailyDuaCard(context, l10n),
            const SizedBox(height: 20),
            Text(l10n.tr("দুআ ও জিকিরের বিভাগ", 'Dua & Dhikr Categories'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 9),
            if (categories.isEmpty)
              _buildEmptySearch(context, l10n)
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 150),
                itemBuilder: (context, index) => _buildCategoryCard(context, categories[index], l10n),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        hintText: l10n.tr("দুআ বা জিকির খুঁজুন...", 'Search Dua or Dhikr...'),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _query.isEmpty ? null : IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () { _searchController.clear(); setState(() => _query = ''); }),
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide(color: primary.withValues(alpha: .08))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide(color: primary.withValues(alpha: .08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide(color: primary.withValues(alpha: .35))),
      ),
    );
  }

  Widget _buildDailyDuaCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    const item = DuaItem(titleBn: 'জ্ঞান বৃদ্ধির দোয়া', titleEn: 'Increase in Knowledge', arabic: 'رَبِّ زِدْنِي عِلْمًا', translationBn: 'হে আমার রব! আমার জ্ঞান বৃদ্ধি করুন।', translationEn: 'My Lord, increase me in knowledge.', reference: 'Quran 20:114');
    final translation = l10n.isBangla ? item.translationBn : item.translationEn;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 15, 13, 10),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: primary.withValues(alpha: .08))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: primary.withValues(alpha: .10), shape: BoxShape.circle), child: Icon(Icons.auto_awesome_rounded, color: primary)),
          const SizedBox(width: 11),
          Expanded(child: Text(l10n.tr("আজকের দুআ", 'Dua of the Day'), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, fontSize: 14))),
          DuaAudioButton(text: item.arabic, color: primary),
        ]),
        const SizedBox(height: 11),
        Text(item.arabic, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 25, height: 1.7)),
        const SizedBox(height: 6),
        Text(translation, style: theme.textTheme.bodyMedium?.copyWith(height: 1.55, fontSize: 14)),
        const SizedBox(height: 5),
        Text(item.reference, style: theme.textTheme.bodySmall?.copyWith(color: primary, fontWeight: FontWeight.w700, fontSize: 11.5)),
      ]),
    );
  }

  Widget _buildCategoryCard(BuildContext context, DuaCategory category, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DuaCategoryScreen(category: category))),
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 12, 13, 11),
          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: primary.withValues(alpha: .08))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primary.withValues(alpha: .10), shape: BoxShape.circle), child: Icon(_iconFor(category.iconName), color: primary, size: 20)),
            const SizedBox(height: 8),
            Text(_title(l10n, category), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 13.5, height: 1.25)),
            const SizedBox(height: 3),
            Expanded(child: Text(_subtitle(l10n, category), maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: 11.5, height: 1.3))),
            Text(l10n.isBangla ? '${category.items.length}টি দুআ ও জিকির' : '${category.items.length} duas & adhkar', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: primary, fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }

  Widget _buildEmptySearch(BuildContext context, AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 35),
    child: Center(child: Text(l10n.tr("কোনো দুআ বা জিকির পাওয়া যায়নি", 'No Dua or Dhikr found'), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor))),
  );
}

class DuaCategoryScreen extends StatefulWidget {
  final DuaCategory category;
  const DuaCategoryScreen({super.key, required this.category});

  @override
  State<DuaCategoryScreen> createState() => _DuaCategoryScreenState();
}

class _DuaCategoryScreenState extends State<DuaCategoryScreen> {
  final FlutterTts _tts = FlutterTts();
  int? _playingIndex;

  @override
  void initState() {
    super.initState();
    _configureTts();
  }

  Future<void> _configureTts() async {
    await DuaVoiceSettingsService.apply(_tts);
    _tts.setCompletionHandler(() { if (mounted) setState(() => _playingIndex = null); });
    _tts.setCancelHandler(() { if (mounted) setState(() => _playingIndex = null); });
    _tts.setErrorHandler((_) { if (mounted) setState(() => _playingIndex = null); });
  }

  Future<void> _speak(int index, String text) async {
    if (_playingIndex == index) {
      await _tts.stop();
      if (mounted) setState(() => _playingIndex = null);
      return;
    }
    await _tts.stop();
    await DuaVoiceSettingsService.apply(_tts);
    if (mounted) setState(() => _playingIndex = index);
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.isBangla ? widget.category.titleBn : widget.category.titleEn, style: const TextStyle(fontWeight: FontWeight.w800)), actions: [
        IconButton(
          tooltip: l10n.tr('দুআর অডিও সেটিংস', 'Dua audio settings'),
          icon: const Icon(Icons.record_voice_over_rounded),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DuaVoiceSettingsScreen())),
        ),
      ]),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        physics: const BouncingScrollPhysics(),
        itemCount: widget.category.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = widget.category.items[index];
          final translation = l10n.isBangla ? item.translationBn : item.translationEn;
          final title = l10n.isBangla ? item.titleBn : item.titleEn;
          final playing = _playingIndex == index;

          return Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 13, 12),
            decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: primary.withValues(alpha: .08))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, fontSize: 15))),
                IconButton(visualDensity: VisualDensity.compact, tooltip: l10n.tr('দুআ শুনুন', 'Listen to dua'), onPressed: () => _speak(index, item.arabic), icon: Icon(playing ? Icons.stop_circle_outlined : Icons.volume_up_outlined, size: 22, color: primary)),
                IconButton(visualDensity: VisualDensity.compact, tooltip: l10n.tr('শেয়ার', 'Share'), onPressed: () => SharePlus.instance.share(ShareParams(text: '${item.arabic}\n\n$translation\n\n${item.reference}\n\nNurVerse')), icon: const Icon(Icons.share_outlined, size: 19)),
              ]),
              const SizedBox(height: 5),
              Text(item.arabic, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 25, height: 1.8, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(translation, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.65)),
              const SizedBox(height: 7),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(item.reference, style: theme.textTheme.bodySmall?.copyWith(color: primary, fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.35))),
                if (item.repeat != null) ...[
                  const SizedBox(width: 8),
                  Flexible(child: Text(item.repeat!, textAlign: TextAlign.end, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: 11.5, height: 1.35))),
                ],
              ]),
            ]),
          );
        },
      ),
    );
  }
}

class DuaAudioButton extends StatefulWidget {
  final String text;
  final Color color;
  const DuaAudioButton({super.key, required this.text, required this.color});

  @override
  State<DuaAudioButton> createState() => _DuaAudioButtonState();
}

class _DuaAudioButtonState extends State<DuaAudioButton> {
  final FlutterTts _tts = FlutterTts();
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _configureTts();
  }

  Future<void> _configureTts() async {
    await DuaVoiceSettingsService.apply(_tts);
    _tts.setCompletionHandler(() { if (mounted) setState(() => _playing = false); });
    _tts.setCancelHandler(() { if (mounted) setState(() => _playing = false); });
    _tts.setErrorHandler((_) { if (mounted) setState(() => _playing = false); });
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _tts.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }
    await _tts.stop();
    await DuaVoiceSettingsService.apply(_tts);
    if (mounted) setState(() => _playing = true);
    await _tts.speak(widget.text);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IconButton(
    visualDensity: VisualDensity.compact,
    tooltip: 'Listen',
    onPressed: _toggle,
    icon: Icon(_playing ? Icons.stop_circle_outlined : Icons.volume_up_outlined, color: widget.color, size: 22),
  );
}
