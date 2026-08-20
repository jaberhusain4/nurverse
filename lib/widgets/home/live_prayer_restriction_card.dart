import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/prayer_controller.dart';
import '../../services/prayer_engine_service.dart';

/// Home-screen-only smart prohibited-time card.
/// Uses a single one-second tick for the live countdown; no continuous
/// animation, location polling, or prayer recalculation is performed by the
/// timer itself.
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

class _LivePrayerRestrictionCardState extends State<LivePrayerRestrictionCard>
    with WidgetsBindingObserver {
  final PrayerEngineService _engine = const PrayerEngineService();
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _now = DateTime.now();
      _startTimer();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
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

  List<List<DateTime>> _windowsForDate(
    PrayerController controller,
    DateTime date,
  ) {
    final position = controller.position;
    if (position == null) return const [];

    final times = _engine.getPrayerTimes(
      position: position,
      date: date,
      config: controller.calculationConfig,
    );

    final sunrise = times.sunrise;
    final dhuhr = times.dhuhr;
    final maghrib = times.maghrib;
    if (sunrise == null || dhuhr == null || maghrib == null) {
      return const [];
    }

    return [
      [sunrise, sunrise.add(const Duration(minutes: 15))],
      [dhuhr.subtract(const Duration(minutes: 10)), dhuhr],
      [maghrib.subtract(const Duration(minutes: 15)), maghrib],
    ];
  }

  List<DateTime>? _findWindow(PrayerController controller) {
    final controllerStart = controller.prohibitedStart;
    final controllerEnd = controller.prohibitedEnd;
    if (controllerStart != null && controllerEnd != null) {
      if (!_now.isBefore(controllerStart) && _now.isBefore(controllerEnd)) {
        return [controllerStart, controllerEnd];
      }
      if (_now.isBefore(controllerStart)) {
        return [controllerStart, controllerEnd];
      }
    }

    final today = DateTime(_now.year, _now.month, _now.day);
    for (final window in _windowsForDate(controller, today)) {
      if (!_now.isBefore(window[0]) && _now.isBefore(window[1])) {
        return window;
      }
      if (_now.isBefore(window[0])) {
        return window;
      }
    }

    final tomorrow = today.add(const Duration(days: 1));
    final tomorrowWindows = _windowsForDate(controller, tomorrow);
    if (tomorrowWindows.isNotEmpty) return tomorrowWindows.first;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final window = _findWindow(controller);

    if (window == null) return const SizedBox.shrink();

    final start = window[0];
    final end = window[1];
    final active = !_now.isBefore(start) && _now.isBefore(end);
    final target = active ? end : start;
    final duration = target.difference(_now);

    if (duration.isNegative) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final warningColor = theme.colorScheme.error;
    final primary = theme.colorScheme.primary;
    final foreground = theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color?.withValues(alpha: .72) ??
        foreground.withValues(alpha: .72);
    final accent = active ? warningColor : primary;

    final title = active
        ? _label('এখন নিষিদ্ধ সময় চলছে', 'Forbidden prayer time is active', 'وقت النهي قائم الآن')
        : _label('পরবর্তী নিষিদ্ধ সময়', 'Next prohibited time', 'وقت النهي التالي');
    final countdownLabel = active
        ? _label('শেষ হতে বাকি', 'Ends in', 'ينتهي خلال')
        : _label('শুরু হতে বাকি', 'Starts in', 'يبدأ خلال');

    final total = end.difference(start).inMilliseconds;
    final progress = active && total > 0
        ? (1 - duration.inMilliseconds / total).clamp(0.0, 1.0)
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: .18)),
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
                  color: accent.withValues(alpha: .10),
                ),
                child: Icon(
                  active ? Icons.warning_amber_rounded : Icons.schedule_rounded,
                  color: accent,
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
                    _countdown(duration),
                    style: TextStyle(
                      color: accent,
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
              value: progress,
              minHeight: 5,
              backgroundColor: accent.withValues(alpha: .10),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );
  }
}
