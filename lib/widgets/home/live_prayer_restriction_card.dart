import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/prayer_controller.dart';

/// Compact live-only warning for the Home screen.
/// The complete Makruh + Forbidden schedule belongs on the Prayer screen.
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
      if (mounted) setState(() => _now = DateTime.now());
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

  String _countdown(DateTime end) {
    final seconds = end.difference(_now).inSeconds.clamp(0, 86400);
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }

  bool _active(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    return !_now.isBefore(start) && _now.isBefore(end);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();

    // Home intentionally shows ONLY an active forbidden period.
    // Makruh and the complete schedule are handled by the Prayer screen.
    final prohibited = _active(
      controller.prohibitedStart,
      controller.prohibitedEnd,
    );

    if (!prohibited) return const SizedBox.shrink();

    final end = controller.prohibitedEnd!;
    final theme = Theme.of(context);
    final warningColor = theme.colorScheme.error;
    final foreground = theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warningColor.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: warningColor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label(
                    'এখন নিষিদ্ধ সময় চলছে',
                    'Forbidden prayer time is active',
                    'وقت النهي قائم الآن',
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: warningColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_countdown(end)} ${_label('বাকি', 'remaining', 'متبقي')}',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
