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
  String _selected = DuaVoiceSettingsService.female;
  bool _loading = true;
  bool _playing = false;

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
      if (mounted) setState(() => _playing = false);
    });
  }

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
    await DuaVoiceSettingsService.apply(_tts);
    if (!mounted) return;
    setState(() => _selected = value);
  }

  Future<void> _preview() async {
    if (_playing) {
      await _tts.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }

    await DuaVoiceSettingsService.apply(_tts);
    if (mounted) setState(() => _playing = true);
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
      appBar: AppBar(
        title: Text(isBangla ? 'দুআর অডিও' : 'Dua Audio'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        children: [
          Text(
            isBangla ? 'দুআ শোনার কণ্ঠ' : 'Dua Audio Voice',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isBangla
                ? 'আপনার পছন্দের পুরুষ বা নারী কণ্ঠ নির্বাচন করুন। নির্বাচিত কণ্ঠ সব দুআর অডিওতে ব্যবহার হবে।'
                : 'Choose a male or female voice. Your choice will be used for dua audio throughout NurVerse.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.55,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          _VoiceOptionCard(
            selected: _selected == DuaVoiceSettingsService.male,
            icon: Icons.record_voice_over_rounded,
            title: isBangla ? 'পুরুষ কণ্ঠ' : 'Male voice',
            subtitle: isBangla
                ? 'পুরুষ কণ্ঠে দুআ শুনুন'
                : 'Listen to duas with a male voice',
            primary: primary,
            onTap: () => _select(DuaVoiceSettingsService.male),
          ),
          const SizedBox(height: 12),
          _VoiceOptionCard(
            selected: _selected == DuaVoiceSettingsService.female,
            icon: Icons.record_voice_over_outlined,
            title: isBangla ? 'নারী কণ্ঠ' : 'Female voice',
            subtitle: isBangla
                ? 'নারী কণ্ঠে দুআ শুনুন'
                : 'Listen to duas with a female voice',
            primary: primary,
            onTap: () => _select(DuaVoiceSettingsService.female),
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: _preview,
            icon: Icon(_playing ? Icons.stop_rounded : Icons.volume_up_rounded),
            label: Text(isBangla ? 'নির্বাচিত কণ্ঠ শুনুন' : 'Preview selected voice'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
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
                  ? 'নোট: ফোনের TTS engine যদি আলাদা পুরুষ/নারী Arabic voice দেয়, NurVerse সেটি ব্যবহার করবে। অন্যথায় device-compatible pitch profile ব্যবহার করে পছন্দের কণ্ঠের অনুভূতি বজায় রাখা হবে।'
                  : 'Note: If your phone TTS engine provides separate Arabic male/female voices, NurVerse will use them. Otherwise a device-compatible pitch profile is used as a fallback.',
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.5,
                fontSize: 12.5,
              ),
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
            color: selected
                ? primary.withValues(alpha: 0.08)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? primary.withValues(alpha: 0.45)
                  : primary.withValues(alpha: 0.08),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primary, size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? primary : theme.hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
