import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/dua_data.dart';
import '../../localization/app_localizations.dart';
import '../../services/dua_audio_service.dart';

/// Temporary recording control used while collecting the user's own Dua audio.
///
/// States are intentionally explicit:
/// - microphone + "Record" when no recording exists;
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
      setState(() {
        _playing = state == PlayerState.playing &&
            DuaAudioService.isPlaying(widget.item);
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
      setState(() {
        _recordingDuration += const Duration(seconds: 1);
      });
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
        final path = await DuaAudioService.stopRecording(widget.item);
        _stopTimer();
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                path == null
                    ? l10n.tr('রেকর্ডিং সংরক্ষণ করা যায়নি।', 'Recording could not be saved.')
                    : l10n.tr('রেকর্ডিং সংরক্ষণ হয়েছে। এখন শুনে যাচাই করুন।', 'Recording saved. Play it back to check it.'),
              ),
            ),
          );
        }
        return;
      }

      final started = await DuaAudioService.startRecording(widget.item);
      if (started) {
        _startTimer();
      }
      if (mounted) {
        setState(() {});
        if (!started) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.tr('মাইক্রোফোনের অনুমতি দিন।', 'Please allow microphone access.'),
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _togglePlayback() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await DuaAudioService.toggle(widget.item);
      if (mounted) {
        setState(() => _playing = DuaAudioService.isPlaying(widget.item));
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
        title: Text(l10n.tr('রেকর্ডিং মুছে ফেলবেন?', 'Delete recording?')),
        content: Text(
          l10n.tr(
            'এই দুআর আপনার রেকর্ড করা অডিওটি মুছে যাবে।',
            'Your recorded audio for this Dua will be deleted.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.tr('বাতিল', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.tr('মুছে ফেলুন', 'Delete')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      await DuaAudioService.deleteRecording(widget.item);
      if (mounted) setState(() => _playing = false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recording = DuaAudioService.isRecording(widget.item);
    final available = DuaAudioService.hasAudio(widget.item);

    if (recording) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _busy ? null : _toggleRecording,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withValues(alpha: .35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'REC ${_durationText(_recordingDuration)}',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(Icons.stop_rounded, color: Colors.redAccent, size: 18),
              ],
            ),
          ),
        ),
      );
    }

    if (!available) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _busy ? null : _toggleRecording,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic_none_rounded, color: widget.color, size: 18),
                const SizedBox(width: 5),
                Text(
                  AppLocalizations.of(context).tr('রেকর্ড', 'Record'),
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(left: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: _playing
                ? AppLocalizations.of(context).tr('বিরতি', 'Pause')
                : AppLocalizations.of(context).tr('শুনুন', 'Listen'),
            onPressed: _busy ? null : _togglePlayback,
            icon: Icon(
              _playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
              color: widget.color,
              size: 24,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: AppLocalizations.of(context).tr('রেকর্ডিং মুছুন', 'Delete recording'),
            onPressed: _busy ? null : _deleteRecording,
            icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 21),
          ),
        ],
      ),
    );
  }
}
