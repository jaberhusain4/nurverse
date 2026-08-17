import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../data/dua_data.dart';
import '../../localization/app_localizations.dart';
import '../../services/dua_audio_service.dart';

/// Temporary recording control used while collecting the user's own Dua audio.
///
/// States are explicit:
/// - microphone + Record when no recording exists;
/// - red REC indicator + elapsed time while recording;
/// - play/pause + delete controls after a recording is saved.
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
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  bool _busy = false;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    DuaAudioService.initialize();
    DuaAudioService.player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      // Avoid depending on the PlayerState enum name so this widget remains
      // compatible with the installed audioplayers API version.
      final isPlayingState = state.toString().endsWith('.playing');
      setState(() {
        _playing = isPlayingState && DuaAudioService.isPlaying(widget.item);
      });
    });
    DuaAudioService.player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _recordingTimer?.cancel();
    _recordingDuration = Duration.zero;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _recordingDuration += const Duration(seconds: 1));
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  String _durationText(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _toggleRecording() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);

    try {
      if (DuaAudioService.isRecording(widget.item)) {
        await DuaAudioService.stopRecording(widget.item);
        _stopTimer();
        if (mounted) setState(() {});
      } else {
        await DuaAudioService.startRecording(widget.item);
        _startTimer();
        if (mounted) setState(() {});
      }
    } catch (e) {
      _stopTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.isBangla ? 'রেকর্ডিং ব্যর্থ' : 'Recording failed'}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _togglePlayback() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (_playing) {
        await DuaAudioService.pauseRecording(widget.item);
      } else {
        await DuaAudioService.playRecording(widget.item);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio playback failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteRecording() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.isBangla ? 'রেকর্ডিং মুছে ফেলবেন?' : 'Delete recording?'),
        content: Text(
          l10n.isBangla
              ? 'এই Dua-এর নিজের রেকর্ড করা অডিওটি মুছে যাবে।'
              : 'Your recorded audio for this Dua will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.isBangla ? 'না' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.isBangla ? 'মুছে দিন' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await DuaAudioService.deleteRecording(widget.item);
      if (mounted) setState(() => _playing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recording = DuaAudioService.isRecording(widget.item);
    final hasRecording = DuaAudioService.hasRecording(widget.item);

    if (recording) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: .30)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(
                  'REC ${_durationText(_recordingDuration)}',
                  style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: l10n.isBangla ? 'রেকর্ডিং বন্ধ করুন' : 'Stop recording',
            onPressed: _busy ? null : _toggleRecording,
            icon: const Icon(Icons.stop_circle_rounded, color: Colors.red, size: 30),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
        ],
      );
    }

    if (hasRecording) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: _playing
                ? (l10n.isBangla ? 'থামান' : 'Pause')
                : (l10n.isBangla ? 'রেকর্ডিং শুনুন' : 'Play recording'),
            onPressed: _busy ? null : _togglePlayback,
            icon: Icon(
              _playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
              color: widget.color,
              size: 30,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
          IconButton(
            tooltip: l10n.isBangla ? 'রেকর্ডিং মুছুন' : 'Delete recording',
            onPressed: _busy ? null : _deleteRecording,
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            tooltip: l10n.isBangla ? 'আবার রেকর্ড করুন' : 'Record again',
            onPressed: _busy ? null : _toggleRecording,
            icon: Icon(Icons.mic_rounded, color: widget.color, size: 23),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      );
    }

    return IconButton(
      tooltip: l10n.isBangla ? 'রেকর্ড করুন' : 'Record',
      onPressed: _busy ? null : _toggleRecording,
      icon: Icon(Icons.mic_rounded, color: widget.color, size: 26),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}
