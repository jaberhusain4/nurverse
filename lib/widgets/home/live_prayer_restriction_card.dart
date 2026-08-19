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

  DateTime? _parse(String value) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (match == null) return null;

    var hour = int.tryParse(match.group(1)!) ?? -1;
    final minute = int.tryParse(match.group(2)!) ?? -1;
    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) return null;

    final period = match.group(3)!.toUpperCase();
    if (period == 'AM' && hour == 12) hour = 0;
    if (period == 'PM' && hour != 12) hour += 12;

    return DateTime(_now.year, _now.month, _now.day, hour, minute);
  }

  String _left(Duration duration) {
    final seconds = duration.inSeconds.clamp(0, 86400);
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '$minutes:${remaining.toString().padLeft(2, '0')} '
        '${_label('মিনিট বাকি', 'min left', 'دقيقة متبقية')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final sunrise = _parse(controller.sunriseTime);
    final noon = _parse(controller.solarNoonTime);
    final sunset = _parse(controller.sunsetTime);

    final windows = <Map<String, dynamic>>[];

    if (sunrise != null) {
      windows.add({
        'start': sunrise.subtract(const Duration(minutes: 15)),
        'end': sunrise.add(const Duration(minutes: 15)),
        'bn': 'সূর্যোদয়ের সময়',
        'en': 'Sunrise restriction',
        'ar': 'وقت النهي عند الشروق',
      });
    }

    if (noon != null) {
      windows.add({
        'start': noon.subtract(const Duration(minutes: 10)),
        'end': noon.add(const Duration(minutes: 5)),
        'bn': 'জাওয়ালের সময়',
        'en': 'Zawal restriction',
        'ar': 'وقت النهي عند الزوال',
      });
    }

    if (sunset != null) {
      windows.add({
        'start': sunset.subtract(const Duration(minutes: 15)),
        'end': sunset.add(const Duration(minutes: 15)),
        'bn': 'সূর্যাস্তের সময়',
        'en': 'Sunset restriction',
        'ar': 'وقت النهي عند الغروب',
      });
    }

    final active = windows.where((window) {
      final start = window['start'] as DateTime;
      final end = window['end'] as DateTime;
      return !_now.isBefore(start) && _now.isBefore(end);
    }).toList();

    final upcoming = windows.where((window) {
      return _now.isBefore(window['start'] as DateTime);
    }).toList();

    final Map<String, dynamic>? window = active.isNotEmpty
        ? active.first
        : (upcoming.isNotEmpty ? upcoming.first : null);

    if (window == null) return const SizedBox.shrink();

    final isActive = active.isNotEmpty;
    final title = _label(
      window['bn'] as String,
      window['en'] as String,
      window['ar'] as String,
    );

    final message = isActive
        ? '$title — ${_label('এখন নামাজের নিষিদ্ধ/মাকরূহ সময় চলছে', 'Restricted prayer time is active', 'وقت النهي قائم الآن')} • ${_left((window['end'] as DateTime).difference(_now))}'
        : '$title — ${_left((window['start'] as DateTime).difference(_now))} ${_label('পর শুরু হবে', 'until it starts', 'حتى يبدأ')}';

    final theme = Theme.of(context);
    final warningColor = theme.colorScheme.error;
    final foreground = theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warningColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: warningColor, size: 23),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label('সতর্কতা', 'Prayer Time Warning', 'تنبيه وقت الصلاة'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: warningColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
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
