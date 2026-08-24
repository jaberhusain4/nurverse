import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../localization/app_localizations.dart';
import '../../models/quran_surah.dart';
import '../../services/audio_quran_service.dart';
import '../../services/quran_data_service.dart';
import '../../theme/app_theme.dart';

class AudioQuranScreen extends StatefulWidget {
  const AudioQuranScreen({super.key});

  @override
  State<AudioQuranScreen> createState() => _AudioQuranScreenState();
}

class _AudioQuranScreenState extends State<AudioQuranScreen> {
  final QuranDataService _data = QuranDataService.instance;
  final AudioQuranService _audio = AudioQuranService.instance;
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  String _query = '';
  int _selectedSurah = 1;
  QuranReciter _selectedReciter = kReciters.first;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _data.init();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  QuranSurah? get _currentSurah {
    if (!_data.coreLoaded) return null;
    try {
      return _data.getSurah(_selectedSurah);
    } catch (_) {
      return null;
    }
  }

  Future<void> _togglePlay() async {
    try {
      final player = _audio.player;
      if (player.playing) {
        await _audio.pause();
        return;
      }
      final sequenceState = player.sequenceState;
      final currentSource = sequenceState.currentSource;
      final currentTag = currentSource?.tag;
      final sameSurah = currentTag == '${_selectedReciter.id}:$_selectedSurah';
      if (sameSurah && player.processingState != ProcessingState.completed) {
        await player.play();
      } else {
        await _audio.play(_selectedReciter, _selectedSurah);
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.tr('অডিও চালু করা যায়নি', 'Could not play audio')}: $e')),
      );
    }
  }

  Future<void> _selectSurah(int number) async {
    setState(() => _selectedSurah = number);
    await _audio.stop();
  }

  Future<void> _downloadCurrent() async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      final ok = await _audio.download(_selectedReciter, _selectedSurah);
      if (!mounted) return;
      setState(() => _downloading = false);
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? l10n.tr('অফলাইনে অডিও সংরক্ষণ হয়েছে।', 'Audio saved offline.') : l10n.tr('ডাউনলোড ব্যর্থ হয়েছে। ইন্টারনেট সংযোগ পরীক্ষা করুন।', 'Download failed. Please check your internet connection.'))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _downloading = false);
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.tr('ডাউনলোড করা যায়নি', 'Could not download')}: $e')),
      );
    }
  }

  Future<void> _changeReciter(QuranReciter reciter) async {
    setState(() => _selectedReciter = reciter);
    await _audio.stop();
  }

  Future<void> _next() async {
    if (_selectedSurah >= 114) return;
    setState(() => _selectedSurah++);
    await _audio.play(_selectedReciter, _selectedSurah);
  }

  Future<void> _previous() async {
    if (_selectedSurah <= 1) return;
    setState(() => _selectedSurah--);
    await _audio.play(_selectedReciter, _selectedSurah);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final surahs = _data.surahList;
    final current = _currentSurah;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('অডিও কুরআন', 'Audio Quran'), style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Column(children: [_buildPlayer(context, current), Expanded(child: _buildSurahList(context, surahs))]),
    );
  }

  Widget _buildPlayer(BuildContext context, QuranSurah? current) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final title = l10n.isArabic
        ? (current?.arabicName ?? current?.transliteration ?? l10n.tr('সূরা', 'Surah'))
        : l10n.isBangla
            ? (current?.banglaName ?? current?.transliteration ?? l10n.tr('সূরা', 'Surah'))
            : (current?.transliteration ?? l10n.tr('সূরা', 'Surah'));
    final reciterName = l10n.isArabic ? _selectedReciter.nameBn : l10n.isEnglish ? _selectedReciter.nameBn : _selectedReciter.nameBn;
    return Material(
      color: context.cardColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(children: [
          Row(children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(16)), child: Icon(Icons.headphones_rounded, color: primary)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text('${current?.transliteration ?? ''} • $reciterName', style: TextStyle(fontSize: 11, color: context.secondaryTextColor)),
            ])),
            PopupMenuButton<QuranReciter>(
              tooltip: l10n.tr('ক্বারী নির্বাচন', 'Select reciter'),
              onSelected: _changeReciter,
              itemBuilder: (_) => [for (final reciter in kReciters) PopupMenuItem<QuranReciter>(value: reciter, child: Text(l10n.isArabic || l10n.isEnglish ? reciter.nameEn : reciter.nameBn)),],
              icon: const Icon(Icons.person_outline_rounded),
            ),
          ]),
          const SizedBox(height: 8),
          StreamBuilder<Duration>(
            stream: _audio.player.positionStream,
            builder: (context, positionSnapshot) {
              final position = positionSnapshot.data ?? Duration.zero;
              return StreamBuilder<Duration?>(
                stream: _audio.player.durationStream,
                builder: (context, durationSnapshot) {
                  final duration = durationSnapshot.data ?? Duration.zero;
                  final max = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
                  final value = position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble();
                  return Column(children: [
                    Slider(value: value.clamp(0, max).toDouble(), max: max, onChanged: duration.inMilliseconds <= 0 ? null : (newValue) => _audio.player.seek(Duration(milliseconds: newValue.round()))),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_formatDuration(position)), Text(_formatDuration(duration))]),
                  ]);
                },
              );
            },
          ),
          const SizedBox(height: 3),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(onPressed: _selectedSurah > 1 ? _previous : null, icon: const Icon(Icons.skip_previous_rounded), iconSize: 30),
            StreamBuilder<PlayerState>(
              stream: _audio.player.playerStateStream,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                return FilledButton(onPressed: _togglePlay, style: FilledButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(17), backgroundColor: primary), child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 30));
              },
            ),
            IconButton(onPressed: _selectedSurah < 114 ? _next : null, icon: const Icon(Icons.skip_next_rounded), iconSize: 30),
            const SizedBox(width: 4),
            IconButton(
              tooltip: l10n.tr('অফলাইনে ডাউনলোড', 'Download offline'),
              onPressed: _downloading ? null : _downloadCurrent,
              icon: _downloading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.download_for_offline_outlined),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildSurahList(BuildContext context, List<QuranSurah> surahs) {
    final l10n = AppLocalizations.of(context);
    final q = _query.trim().toLowerCase();
    final filtered = surahs.where((surah) => q.isEmpty || surah.number.toString().contains(q) || surah.transliteration.toLowerCase().contains(q) || (surah.banglaName ?? '').toLowerCase().contains(q) || surah.arabicName.contains(q)).toList();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: filtered.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(hintText: l10n.tr('সূরা খুঁজুন...', 'Search surah...'), prefixIcon: const Icon(Icons.search_rounded), suffixIcon: _searchController.text.isNotEmpty ? IconButton(onPressed: () { _searchController.clear(); setState(() => _query = ''); }, icon: const Icon(Icons.close_rounded)) : null, filled: true, fillColor: context.cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
            ),
          );
        }
        final surah = filtered[index - 1];
        final selected = surah.number == _selectedSurah;
        final primary = Theme.of(context).colorScheme.primary;
        final number = l10n.isBangla ? _bnNumber(surah.number) : surah.number.toString();
        final surahTitle = l10n.isArabic ? surah.arabicName : l10n.isBangla ? (surah.banglaName ?? surah.transliteration) : surah.transliteration;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(17), border: Border.all(color: selected ? primary.withValues(alpha: .28) : primary.withValues(alpha: .06))),
          child: ListTile(
            onTap: () => _selectSurah(surah.number),
            leading: CircleAvatar(backgroundColor: primary.withValues(alpha: .10), foregroundColor: primary, child: Text(number, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            title: Text(surahTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('${surah.transliteration} • ${surah.totalVerses} ${l10n.tr('আয়াত', 'verses')}'),
            trailing: Icon(selected ? Icons.equalizer_rounded : Icons.play_circle_outline_rounded, color: selected ? primary : context.secondaryTextColor),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  String _bnNumber(int number) {
    const en = '0123456789';
    const bn = '০১২৩৪৫৬৭৮৯';
    return number.toString().split('').map((d) { final i = en.indexOf(d); return i < 0 ? d : bn[i]; }).join();
  }
}