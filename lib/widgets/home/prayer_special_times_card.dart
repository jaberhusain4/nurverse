import 'dart:async';

import 'package:flutter/material.dart';

class PrayerSpecialTimesCard extends StatefulWidget {
  final String languageCode;
  final DateTime? prohibitedStart;
  final DateTime? prohibitedEnd;
  final DateTime? makruhStart;
  final DateTime? makruhEnd;

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
      if (!mounted) return;
      setState(() => _now = DateTime.now());
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

  String _time(DateTime? value) {
    if (value == null) return '--:--';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _left(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes ${_label('মিনিট', 'min', 'دقيقة')} '
          '${seconds.toString().padLeft(2, '0')} '
          '${_label('সেকেন্ড', 'sec', 'ثانية')}';
    }
    return '$seconds ${_label('সেকেন্ড', 'sec', 'ثانية')}';
  }

  _Window? _window(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    if (!_now.isBefore(start) && _now.isBefore(end)) {
      return _Window(start, end, true);
    }
    if (_now.isBefore(start)) {
      return _Window(start, end, false);
    }
    return null;
  }

  String _name(DateTime start, bool prohibited) {
    if (start.hour < 10) {
      return _label(
        prohibited ? 'সূর্যোদয়ের নিষিদ্ধ সময়' : 'সূর্যোদয়ের মাকরূহ সময়',
        prohibited ? 'Sunrise prohibited time' : 'Sunrise Makruh time',
        prohibited ? 'وقت النهي عند الشروق' : 'وقت الكراهة عند الشروق',
      );
    }
    if (start.hour >= 16) {
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

  String _status(_Window? window, {required bool prohibited}) {
    if (window == null) {
      return _label(
        'আজ আর কোনো সময় নেই',
        'No more time today',
        'لا وقت آخر اليوم',
      );
    }
    final name = _name(window.start, prohibited);
    if (window.active) {
      return '$name — ${_label('এখন চলছে', 'active now', 'جاري الآن')} • '
          '${_left(window.end.difference(_now))} '
          '${_label('বাকি', 'left', 'متبقٍ')}';
    }
    return '$name — ${_time(window.start)} – ${_time(window.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final foreground = theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color ??
        foreground.withValues(alpha: .70);

    final prohibited = _window(
      widget.prohibitedStart,
      widget.prohibitedEnd,
    );
    final makruh = _window(widget.makruhStart, widget.makruhEnd);
    final active = prohibited?.active == true || makruh?.active == true;

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
              Icon(
                active ? Icons.block_rounded : Icons.warning_amber_rounded,
                size: 21,
                color: primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _label(
                    'মাকরূহ ও নিষিদ্ধ সময়',
                    'Makruh & Prohibited Times',
                    'أوقات الكراهة والنهي',
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _item(
            _label('নিষিদ্ধ সময়', 'Prohibited', 'وقت النهي'),
            _status(prohibited, prohibited: true),
            prohibited?.active == true,
            primary,
            secondary,
            foreground,
          ),
          const SizedBox(height: 8),
          _item(
            _label('মাকরূহ সময়', 'Makruh', 'وقت الكراهة'),
            _status(makruh, prohibited: false),
            makruh?.active == true,
            primary,
            secondary,
            foreground,
          ),
          const SizedBox(height: 7),
          Text(
            _label(
              'সময়গুলো প্রতি সেকেন্ডে লাইভ আপডেট হচ্ছে।',
              'Times update live every second.',
              'الأوقات تتحدث مباشرة كل ثانية.',
            ),
            style: TextStyle(fontSize: 11.5, color: secondary),
          ),
        ],
      ),
    );
  }

  Widget _item(
    String title,
    String value,
    bool active,
    Color primary,
    Color secondary,
    Color foreground,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: active ? .10 : .06),
        borderRadius: BorderRadius.circular(13),
        border: active
            ? Border.all(color: primary.withValues(alpha: .22))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            active ? Icons.timer_rounded : Icons.schedule_rounded,
            size: 20,
            color: primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: foreground,
                    fontWeight: FontWeight.w800,
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

class _Window {
  final DateTime start;
  final DateTime end;
  final bool active;

  const _Window(this.start, this.end, this.active);
}
