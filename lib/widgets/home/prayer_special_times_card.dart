import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/prayer_controller.dart';

class PrayerSpecialTimesCard extends StatefulWidget {
  final String languageCode;
  final DateTime? prohibitedStart, prohibitedEnd, makruhStart, makruhEnd;

  const PrayerSpecialTimesCard({
    super.key,
    required this.languageCode,
    required this.prohibitedStart,
    required this.prohibitedEnd,
    required this.makruhStart,
    required this.makruhEnd,
  });

  @override
  State<PrayerSpecialTimesCard> createState() => _PrayerSpecialTimesCardState();
}

class _PrayerSpecialTimesCardState extends State<PrayerSpecialTimesCard> {
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

  DateTime? _parseClock(String value) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
        .firstMatch(value.trim());
    if (match == null) return null;
    var hour = int.tryParse(match.group(1)!) ?? -1;
    final minute = int.tryParse(match.group(2)!) ?? -1;
    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) return null;
    final period = match.group(3)!.toUpperCase();
    if (period == 'AM' && hour == 12) hour = 0;
    if (period == 'PM' && hour != 12) hour += 12;
    return DateTime(_now.year, _now.month, _now.day, hour, minute);
  }

  String _time(DateTime value) {
    final h = value.hour % 12 == 0 ? 12 : value.hour % 12;
    return '$h:${value.minute.toString().padLeft(2, '0')} ${value.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _left(Duration duration) {
    final seconds = duration.inSeconds.clamp(0, 86400);
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '$minutes ${_label('মিনিট', 'min', 'دقيقة')} '
          '${secs.toString().padLeft(2, '0')} ${_label('সেকেন্ড', 'sec', 'ثانية')} '
          '${_label('বাকি', 'left', 'متبقٍ')}';
    }
    return '$secs ${_label('সেকেন্ড বাকি', 'sec left', 'ثانية متبقية')}';
  }

  _Window? _window(DateTime start, DateTime end) {
    if (!_now.isBefore(start) && _now.isBefore(end)) {
      return _Window(start, end, true);
    }
    if (_now.isBefore(start)) {
      return _Window(start, end, false);
    }
    return null;
  }

  List<_Window> _windows(PrayerController controller, {required bool prohibited}) {
    final sunrise = _parseClock(controller.sunriseTime);
    final dhuhr = _parseClock(controller.solarNoonTime);
    final sunset = _parseClock(controller.sunsetTime);
    if (sunrise == null || dhuhr == null || sunset == null) return const [];

    final ranges = prohibited
        ? <List<DateTime>>[
            [sunrise, sunrise.add(const Duration(minutes: 15))],
            [dhuhr.subtract(const Duration(minutes: 10)), dhuhr],
            [sunset.subtract(const Duration(minutes: 15)), sunset],
          ]
        : <List<DateTime>>[
            [sunrise.subtract(const Duration(minutes: 15)), sunrise.add(const Duration(minutes: 15))],
            [dhuhr.subtract(const Duration(minutes: 10)), dhuhr.add(const Duration(minutes: 5))],
            [sunset.subtract(const Duration(minutes: 15)), sunset.add(const Duration(minutes: 15))],
          ];

    return ranges
        .map((range) => _window(range[0], range[1]))
        .whereType<_Window>()
        .toList();
  }

  String _name(DateTime start, {required bool prohibited}) {
    final sunrise = _parseClock(context.read<PrayerController>().sunriseTime);
    final sunset = _parseClock(context.read<PrayerController>().sunsetTime);
    final isSunrise = sunrise != null && start.difference(sunrise).inMinutes.abs() <= 15;
    final isSunset = sunset != null && start.difference(sunset).inMinutes.abs() <= 15;

    if (isSunrise) {
      return _label(
        prohibited ? 'সূর্যোদয়ের নিষিদ্ধ সময়' : 'সূর্যোদয়ের মাকরূহ সময়',
        prohibited ? 'Sunrise prohibited time' : 'Sunrise Makruh time',
        prohibited ? 'وقت النهي عند الشروق' : 'وقت الكراهة عند الشروق',
      );
    }
    if (isSunset) {
      return _label(
        prohibited ? 'সূর্যাস্তের নিষিদ্ধ সময়' : 'সূর্যাস্তের মাকরূহ সময়',
        prohibited ? 'Sunset prohibited time' : 'Sunset Makruh time',
        prohibited ? 'وقت النهي عند الغروب' : 'وقت الكراهة عند الغروب',
      );
    }
    return _label(
      prohibited ? 'জাওয়ালের নিষিদ্ধ সময়' : 'জাওয়ালের মাকরূহ সময়',
      prohibited ? 'Zawal prohibited time' : 'Zawal Makruh time',
      prohibited ? 'وقت النهي عند الزوال' : 'وقت الكراهة عند الزوال',
    );
  }

  String _status(_Window window, {required bool prohibited}) {
    final name = _name(window.start, prohibited: prohibited);
    if (window.active) {
      return '$name — ${_label('এখন চলছে', 'active now', 'جاري الآن')} • '
          '${_left(window.end.difference(_now))}';
    }
    return '$name — ${_time(window.start)} – ${_time(window.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final foreground = theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color ?? foreground.withValues(alpha: .7);
    final prohibited = _windows(controller, prohibited: true);
    final makruh = _windows(controller, prohibited: false);
    final active = prohibited.any((w) => w.active) || makruh.any((w) => w.active);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: .12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(active ? Icons.block_rounded : Icons.warning_amber_rounded, size: 21, color: primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _label('মাকরূহ ও নিষিদ্ধ সময়', 'Makruh & Prohibited Times', 'أوقات الكراهة والنهي'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: foreground),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...prohibited.map((window) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _item(
                  _label('নিষিদ্ধ সময়', 'Prohibited', 'وقت النهي'),
                  _status(window, prohibited: true),
                  window.active,
                  primary,
                  secondary,
                  foreground,
                ),
              )),
          ...makruh.map((window) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _item(
                  _label('মাকরূহ সময়', 'Makruh', 'وقت الكراهة'),
                  _status(window, prohibited: false),
                  window.active,
                  primary,
                  secondary,
                  foreground,
                ),
              )),
          Text(
            _label('সময়গুলো প্রতি সেকেন্ডে লাইভ আপডেট হচ্ছে।', 'Times update live every second.', 'الأوقات تتحدث مباشرة كل ثانية.'),
            style: TextStyle(fontSize: 11.5, color: secondary),
          ),
        ],
      ),
    );
  }

  Widget _item(String title, String value, bool active, Color primary, Color secondary, Color foreground) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: active ? .10 : .06),
        borderRadius: BorderRadius.circular(13),
        border: active ? Border.all(color: primary.withValues(alpha: .22)) : null,
      ),
      child: Row(
        children: [
          Icon(active ? Icons.timer_rounded : Icons.schedule_rounded, size: 20, color: primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12.5, color: secondary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, color: foreground, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Window {
  final DateTime start;
  final DateTime end;
  final bool active;
  const _Window(this.start, this.end, this.active);
}
