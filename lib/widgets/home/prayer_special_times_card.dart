import 'package:flutter/material.dart';

class PrayerSpecialTimesCard extends StatelessWidget {
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

  String _label(String bn, String en, String ar) {
    if (languageCode == 'en') return en;
    if (languageCode == 'ar') return ar;
    return bn;
  }

  String _time(DateTime? value) {
    if (value == null) return '--:--';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _range(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '--:--';
    return '${_time(start)} – ${_time(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final text = theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color ?? text.withValues(alpha: 0.7);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 20, color: primary),
              const SizedBox(width: 8),
              Text(
                _label('মাকরূহ ও নিষিদ্ধ সময়', 'Makruh & Prohibited Times', 'أوقات الكراهة والنهي'),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: text),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _TimeItem(
                  title: _label('নিষিদ্ধ সময়', 'Prohibited', 'وقت النهي'),
                  value: _range(prohibitedStart, prohibitedEnd),
                  color: primary,
                  secondary: secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimeItem(
                  title: _label('মাকরূহ সময়', 'Makruh', 'وقت الكراهة'),
                  value: _range(makruhStart, makruhEnd),
                  color: primary,
                  secondary: secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            _label(
              'সময়গুলো আজকের হিসাব অনুযায়ী প্রতি মুহূর্তে আপডেট হচ্ছে।',
              'Times are calculated for today and update live.',
              'الأوقات محسوبة لليوم وتتحدث مباشرةً.',
            ),
            style: TextStyle(fontSize: 10.5, color: secondary),
          ),
        ],
      ),
    );
  }
}

class _TimeItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final Color secondary;

  const _TimeItem({
    required this.title,
    required this.value,
    required this.color,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10.5, color: secondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
