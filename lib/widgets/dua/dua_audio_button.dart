import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/dua_data.dart';
import '../../localization/app_localizations.dart';
import '../../services/dua_audio_service.dart';

/// Final user-facing Dua audio control.
///
/// A Dua is either already cached locally, or can be downloaded from the
/// NurVerse audio store and then played offline.
class DuaAudioButton extends StatefulWidget {
  final DuaItem item;
  final Color color;

  const DuaAudioButton({
    super.key,
    required this.item,
    required this.color,
  });

  @override
  State<DuaAudioButton> createState() => _DuaAudioButtonState();
}

class _DuaAudioButtonState extends State<DuaAudioButton> {
  bool _busy = false;
  bool _playing = false;
  bool _downloaded = false;
  StreamSubscription<void>? _completionSubscription;

  @override
  void initState() {
    super.initState();
    _completionSubscription = DuaAudioService.player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      if (DuaAudioService.keyFor(widget.item) ==
          DuaAudioService.currentKey) {
        setState(() => _playing = false);
      }
    });

    DuaAudioService.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _downloaded = DuaAudioService.hasDownloadedAudio(widget.item);
        _playing = DuaAudioService.isPlaying(widget.item);
      });
    });
  }

  @override
  void dispose() {
    _completionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _play() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    try {
      await DuaAudioService.toggle(widget.item);
      if (!mounted) return;
      setState(() {
        _downloaded = DuaAudioService.hasDownloadedAudio(widget.item);
        _playing = DuaAudioService.isPlaying(widget.item);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.isBangla
                ? 'অডিও চালানো বা ডাউনলোড করা যায়নি।'
                : 'Could not play or download the audio.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _download() async {
    if (_busy || _downloaded) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    try {
      final ok = await DuaAudioService.download(widget.item);
      if (!mounted) return;
      setState(() => _downloaded = ok);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? (l10n.isBangla
                    ? 'অডিও ডাউনলোড হয়েছে। এখন অফলাইনে শুনতে পারবেন।'
                    : 'Audio downloaded. You can now listen offline.')
                : (l10n.isBangla
                    ? 'অডিও ডাউনলোড করা যায়নি।'
                    : 'Audio download failed.'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final icon = _busy
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          )
        : Icon(
            _playing
                ? Icons.pause_circle_filled_rounded
                : Icons.play_circle_fill_rounded,
            color: widget.color,
            size: 30,
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: _playing
              ? (l10n.isBangla ? 'থামান' : 'Pause')
              : (l10n.isBangla ? 'দুআর অডিও শুনুন' : 'Play Dua audio'),
          onPressed: _busy ? null : _play,
          icon: icon,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        IconButton(
          tooltip: _downloaded
              ? (l10n.isBangla ? 'অফলাইনে সংরক্ষিত' : 'Available offline')
              : (l10n.isBangla
                  ? 'অফলাইনের জন্য ডাউনলোড'
                  : 'Download for offline'),
          onPressed: _busy || _downloaded ? null : _download,
          icon: Icon(
            _downloaded
                ? Icons.download_done_rounded
                : Icons.download_rounded,
            color: _downloaded
                ? widget.color.withValues(alpha: .55)
                : widget.color,
            size: 22,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}
