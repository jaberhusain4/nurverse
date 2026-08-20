import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/prayer_controller.dart';

/// Home-screen-only smart prohibited-time card.
/// Shows the current prohibited window with a live countdown, or only the
/// nearest upcoming prohibited window when no prohibited period is active.
class LivePrayerRestrictionCard extends StatefulWidget {
  final String languageCode;

  const LivePrayerRestrictionCard({
    super.key,
    required this.languageCode,
  });

  @override
  State<LivePrayerRestrictionCard> createState() =>
      _LivePrayerRestrictionCardState();
}

class _LivePrayerRestrictionCardState extends State<LivePrayerRestrictionCard> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _label(String bn, String en, String ar) {
    if (widget.languageCode == 'en') return en;
    if (widget.languageCode == 'ar') return ar;
    return bn;
  }

  String _formatClock(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _countdown(Duration duration) {
    final seconds = duration.inSeconds.clamp(0, 7 * 86400);
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  bool _active(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    return !_now.isBefore(start) && _now.isBefore(end);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final start = controller.prohibitedStart;
    final end = controller.prohibitedEnd;

    if (start == null || end == null) {
      return const SizedBox.shrink();
    }

    final active = _active(start, end);
    final target = active ? end : start;
    final duration = target.difference(_now);

    // The controller exposes the nearest current/future prohibited window.
    // Never show a stale/past window if the controller has not advanced yet.
    if (duration.isNegative || (duration.inSeconds == 0 && !active)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final warningColor = theme.colorScheme.error;
    final primary = theme.colorScheme.primary;
    final foreground = theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color?.withValues(alpha: .72) ??
        foreground.withValues(alpha: .72);

    final title = active
        ? _label(
            'এখন নিষিদ্ধ সময় চলছে',
            'Forbidden prayer time is active',
            'وقت النهي قائم الآن',
          )
        : _label(
            'পরবর্তী নিষিদ্ধ সময়',
            'Next prohibited time',
            'وقت النهي التالي',
          );

    final countdownLabel = active
        ? _label('শেষ হতে বাকি', 'Ends in', 'ينتهي خلال')
        : _label('শুরু হতে বাকি', 'Starts in', 'يبدأ خلال');

    final countdown = _countdown(duration);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: (active ? warningColor : primary).withValues(alpha: .055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (active ? warningColor : primary).withValues(alpha: .18),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (active ? warningColor : primary).withValues(alpha: .10),
                ),
                child: Icon(
                  active ? Icons.warning_amber_rounded : Icons.schedule_rounded,
                  color: active ? warningColor : primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: active ? warningColor : foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_formatClock(start)} → ${_formatClock(end)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    countdownLabel,
                    style: TextStyle(
                      color: secondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    countdown,
                    style: TextStyle(
                      color: active ? warningColor : primary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: active
                  ? (end.difference(start).inMilliseconds <= 0
                      ? 1.0
                      : (1 -
                              duration.inMilliseconds /
                                  end.difference(start).inMilliseconds)
                          .clamp(0.0, 1.0))
                  : null,
              minHeight: 5,
              backgroundColor: (active ? warningColor : primary).withValues(alpha: .10),
              valueColor: AlwaysStoppedAnimation<Color>(
                active ? warningColor : primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
