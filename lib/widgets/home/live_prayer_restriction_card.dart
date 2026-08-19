import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/prayer_controller.dart';

class LivePrayerRestrictionCard extends StatefulWidget {
  final String languageCode;
  const LivePrayerRestrictionCard({super.key, required this.languageCode});

  @override
  State<LivePrayerRestrictionCard> createState() => _LivePrayerRestrictionCardState();
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

    final bool prohibited = _active(
      controller.prohibitedStart,
      controller.prohibitedEnd,
    );
    final bool makruh = !prohibited && _active(
      controller.makruhStart,
      controller.makruhEnd,
    );

    if (!prohibited && !makruh) {
      return const SizedBox.shrink();
    }

    final DateTime end = prohibited
        ? controller.prohibitedEnd!
        : controller.makruhEnd!;

    final String title = prohibited
        ? _label(
            'এখন নিষিদ্ধ সময় চলছে',
            'Forbidden prayer time is active',
            'وقت النهي قائم الآن',
          )
        : _label(
            'এখন মাকরূহ সময় চলছে',
            'Makruh prayer time is active',
            'وقت الكراهة قائم الآن',
          );

    final String detail = prohibited
        ? _label(
            'এখন নামাজ পড়া যাবে না',
            'Prayer cannot be performed during this time',
            'لا تُصلَّى الصلاة في هذا الوقت',
          )
        : _label(
            'এখন মাকরূহ সময় চলছে',
            'Makruh time is active',
            'وقت الكراهة قائم الآن',
          );

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
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: warningColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$detail • ${_countdown(end)} ${_label('বাকি', 'remaining', 'متبقي')}',
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
