import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../services/dua_voice_settings_service.dart';

class DuaVoiceSettingsScreen extends StatefulWidget {
  const DuaVoiceSettingsScreen({super.key});

  @override
  State<DuaVoiceSettingsScreen> createState() => _DuaVoiceSettingsScreenState();
}

class _DuaVoiceSettingsScreenState extends State<DuaVoiceSettingsScreen> {
  final FlutterTts _tts = FlutterTts();
  String _selected = DuaVoiceSettingsService.male;
  bool _loading = true;
  bool _playing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _playing = false);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _playing = false);
    });
    _tts.setErrorHandler((_) {
      if (mounted) setState(() {
        _playing = false;
        _error = _bangla ? 'এই কণ্ঠটি চালু করা যায়নি।' : 'This voice could not be started.';
      });
    });
  }

  bool get _bangla => Localizations.localeOf(context).languageCode == 'bn';

  Future<void> _load() async {
    final value = await DuaVoiceSettingsService.getVoiceGender();
    if (!mounted) return;
    setState(() {
      _selected = value;
      _loading = false;
    });
  }

  Future<void> _select(String value) async {
    await _tts.stop();
    await DuaVoiceSettingsService.setVoiceGender(value);
    final available = await DuaVoiceSettingsService.apply(_tts);
    if (!mounted) return;
    setState(() {
      _selected = value;
      _error = available
          ? null
          : (_bangla
                ? 'এই ডিভাইসে নির্বাচিত ${value == DuaVoiceSettingsService.male ? 'পুরুষ' : 'নারী'} Arabic voice পাওয়া যায়নি।'
                : 'The selected ${value == DuaVoiceSettingsService.male ? 'male' : 'female'} Arabic voice is not available on this device.');
    });
  }

  Future<void> _preview() async {
    if (_playing) {
      await _tts.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }

    final available = await DuaVoiceSettingsService.apply(_tts);
    if (!available) {
      if (mounted) {
        setState(() {
          _error = _bangla
              ? 'এই ডিভাইসে নির্বাচিত Arabic voice ইনস্টল নেই। ফোনের Text-to-speech settings থেকে Arabic voice data ইনস্টল করুন।'
              : 'The selected Arabic voice is not installed. Install Arabic voice data from the phone Text-to-speech settings.';
        });
      }
      return;
    }

    if (mounted) setState(() {
      _playing = true;
      _error = null;
    });
    await _tts.speak('رَبِّ زِدْنِي عِلْمًا');
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isBangla = Localizations.localeOf(context).languageCode == 'bn';

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(isBangla ? 'দুআর অডিও' : 'Dua Audio')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(isBangla ? 'দুআর অডিও' : 'Dua Audio')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        children: [
          Text(
            isBangla ? 'দুআ শোনার কণ্ঠ' : 'Dua Audio Voice',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          const SizedBox(height: 6),
          Text(
            isBangla
                ? 'পুরুষ বা নারী—আপনার পছন্দের প্রকৃত Arabic TTS কণ্ঠ নির্বাচন করুন।'
                : 'Choose the actual Arabic TTS voice you want to use: male or female.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.55, fontSize: 14),
          ),
          const SizedBox(height: 18),
          _VoiceOptionCard(
            selected: _selected == DuaVoiceSettingsService.male,
            icon: Icons.record_voice_over_rounded,
            title: isBangla ? 'পুরুষ কণ্ঠ' : 'Male voice',
            subtitle: isBangla ? 'প্রকৃত পুরুষ Arabic TTS voice' : 'Actual male Arabic TTS voice',
            primary: primary,
            onTap: () => _select(DuaVoiceSettingsService.male),
          ),
          const SizedBox(height: 12),
          _VoiceOptionCard(
            selected: _selected == DuaVoiceSettingsService.female,
            icon: Icons.record_voice_over_outlined,
            title: isBangla ? 'নারী কণ্ঠ' : 'Female voice',
            subtitle: isBangla ? 'প্রকৃত নারী Arabic TTS voice' : 'Actual female Arabic TTS voice',
            primary: primary,
            onTap: () => _select(DuaVoiceSettingsService.female),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(_error!, style: theme.textTheme.bodySmall?.copyWith(height: 1.45)),
            ),
          ],
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: _preview,
            icon: Icon(_playing ? Icons.stop_rounded : Icons.volume_up_rounded),
            label: Text(isBangla ? 'নির্বাচিত কণ্ঠ শুনুন' : 'Preview selected voice'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              isBangla
                  ? 'NurVerse কোনো voice-কে pitch পরিবর্তন করে অন্য gender হিসেবে দেখাবে না। ডিভাইসে প্রকৃত voice না থাকলে সেটি unavailable দেখাবে।'
                  : 'NurVerse never changes pitch to imitate another gender. If the real voice is unavailable on the device, it will be reported as unavailable.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceOptionCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color primary;
  final VoidCallback onTap;

  const _VoiceOptionCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: 0.08) : theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? primary.withValues(alpha: 0.45) : primary.withValues(alpha: 0.08),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: primary.withValues(alpha: 0.10), shape: BoxShape.circle),
                child: Icon(icon, color: primary, size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.5, height: 1.35)),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? primary : theme.hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
