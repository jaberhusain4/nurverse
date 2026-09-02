import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/prayer_controller.dart';
import '../../providers/settings_provider.dart';

class PrayerSpecialTimesDetailCard extends StatelessWidget {
  final String languageCode;
  const PrayerSpecialTimesDetailCard({super.key, this.languageCode = 'bn'});

  String _label(String bn, String en, String ar) {
    if (languageCode == 'en') return en;
    if (languageCode == 'ar') return ar;
    return bn;
  }

  DateTime? _parse(String value) {
    final input = value.trim();
    if (input.isEmpty || input == '--:--') return null;

    // PrayerController exposes HH:mm (optionally HH:mm:ss). Keep AM/PM
    // support as a compatibility fallback for older formatted values.
    final twentyFour = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$').firstMatch(input);
    final twelveHour = RegExp(
      r'^(\d{1,2}):(\d{2})(?::(\d{2}))?\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(input);

    int hour;
    int minute;
    int second;

    if (twentyFour != null) {
      hour = int.tryParse(twentyFour.group(1)!) ?? -1;
      minute = int.tryParse(twentyFour.group(2)!) ?? -1;
      second = int.tryParse(twentyFour.group(3) ?? '0') ?? 0;
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59 || second < 0 || second > 59) {
        return null;
      }
    } else if (twelveHour != null) {
      hour = int.tryParse(twelveHour.group(1)!) ?? -1;
      minute = int.tryParse(twelveHour.group(2)!) ?? -1;
      second = int.tryParse(twelveHour.group(3) ?? '0') ?? 0;
      if (hour < 1 || hour > 12 || minute < 0 || minute > 59 || second < 0 || second > 59) {
        return null;
      }
      final period = twelveHour.group(4)!.toUpperCase();
      if (period == 'AM' && hour == 12) hour = 0;
      if (period == 'PM' && hour != 12) hour += 12;
    } else {
      return null;
    }

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute, second);
  }

  String _time(DateTime value, bool showSeconds) {
    final hour = value.hour == 0 ? 12 : value.hour > 12 ? value.hour - 12 : value.hour;
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    final base = '$hour:$minute';
    return showSeconds
        ? '$base:$second ${value.hour >= 12 ? 'PM' : 'AM'}'
        : '$base ${value.hour >= 12 ? 'PM' : 'AM'}';
  }

  bool _active(DateTime start, DateTime end, DateTime now) =>
      !now.isBefore(start) && now.isBefore(end);

  String _remaining(DateTime end, DateTime now, bool showSeconds) {
    final seconds = end.difference(now).inSeconds.clamp(0, 86400);
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (!showSeconds) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    }
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PrayerController>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final warning = theme.colorScheme.error;
    final text = theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color ?? text.withValues(alpha: .68);
    final now = DateTime.now();
    final showSeconds = context.watch<SettingsProvider>().showSeconds;
    final sunrise = _parse(c.sunriseTime);
    final noon = _parse(c.solarNoonTime);
    final sunset = _parse(c.sunsetTime);

    final prohibited = <_Restriction>[
      if (sunrise != null)
        _Restriction(_label('সূর্যোদয়', 'Sunrise', 'الشروق'), sunrise, sunrise.add(const Duration(minutes: 15))),
      if (noon != null)
        _Restriction(_label('জাওয়াল / মধ্যাহ্ন', 'Zawal / Solar Noon', 'الزوال'), noon.subtract(const Duration(minutes: 10)), noon),
      if (sunset != null)
        _Restriction(_label('সূর্যাস্ত', 'Sunset', 'الغروب'), sunset.subtract(const Duration(minutes: 15)), sunset),
    ];

    final makruh = <_Restriction>[
      if (sunrise != null)
        _Restriction(_label('সূর্যোদয়ের আশপাশ', 'Around Sunrise', 'حول الشروق'), sunrise.subtract(const Duration(minutes: 15)), sunrise.add(const Duration(minutes: 15))),
      if (noon != null)
        _Restriction(_label('জাওয়ালের আশপাশ', 'Around Zawal', 'حول الزوال'), noon.subtract(const Duration(minutes: 10)), noon.add(const Duration(minutes: 5))),
      if (sunset != null)
        _Restriction(_label('সূর্যাস্তের আশপাশ', 'Around Sunset', 'حول الغروب'), sunset.subtract(const Duration(minutes: 15)), sunset.add(const Duration(minutes: 15))),
    ];

    if (prohibited.isEmpty && makruh.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: warning, size: 21),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _label('মাকরূহ ও নিষিদ্ধ সময়', 'Makruh & Prohibited Times', 'أوقات الكراهة والنهي'),
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            _label('সূর্যোদয়, জাওয়াল ও সূর্যাস্তের বিস্তারিত সময়', 'Detailed sunrise, zawal and sunset times', 'تفاصيل أوقات الشروق والزوال والغروب'),
            style: TextStyle(fontSize: 11.5, color: secondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          _group(_label('নিষিদ্ধ সময়', 'Prohibited Times', 'أوقات النهي'), prohibited, now, warning, text, secondary, showSeconds),
          const SizedBox(height: 12),
          _group(_label('মাকরূহ সময়', 'Makruh Times', 'أوقات الكراهة'), makruh, now, primary, text, secondary, showSeconds),
        ],
      ),
    );
  }

  Widget _group(
    String title,
    List<_Restriction> items,
    DateTime now,
    Color accent,
    Color text,
    Color secondary,
    bool showSeconds,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        ...items.map((item) {
          final active = _active(item.start, item.end, now);
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: active ? accent.withValues(alpha: .08) : accent.withValues(alpha: .035),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: active ? accent.withValues(alpha: .24) : accent.withValues(alpha: .07)),
            ),
            child: Row(
              children: [
                Icon(active ? Icons.warning_rounded : Icons.schedule_rounded, color: accent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 12.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('${_time(item.start, showSeconds)} – ${_time(item.end, showSeconds)}', style: TextStyle(color: secondary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                if (active) ...[
                  const SizedBox(width: 8),
                  Text(_remaining(item.end, now, showSeconds), style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w800)),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Restriction {
  final String name;
  final DateTime start;
  final DateTime end;
  const _Restriction(this.name, this.start, this.end);
}
