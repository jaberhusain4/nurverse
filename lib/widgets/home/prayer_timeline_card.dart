import 'package:flutter/material.dart';

class PrayerTimelineCard extends StatelessWidget {
  final List<Map<String, dynamic>> prayers;
  final String languageCode;

  const PrayerTimelineCard({super.key, required this.prayers, this.languageCode = 'bn'});

  String _label({required String bn, required String en, required String ar}) {
    switch (languageCode) {
      case 'en': return en;
      case 'ar': return ar;
      default: return bn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color?.withValues(alpha: .68) ?? theme.colorScheme.onSurface.withValues(alpha: .68);
    final items = prayers.where((p) => p['category'] == 'obligatory').take(5).toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: primary.withValues(alpha: .055))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.schedule_rounded, color: primary, size: 19),
          const SizedBox(width: 8),
          Expanded(child: Text(_label(bn: 'আজকের সালাত', en: "Today's Prayers", ar: 'صلوات اليوم'), style: theme.textTheme.titleSmall?.copyWith(fontSize: 15, fontWeight: FontWeight.w800, height: 1.15))),
          Text(_label(bn: '৫ ওয়াক্ত', en: '5 prayers', ar: 'خمس صلوات'), style: TextStyle(color: secondary, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 10),
        if (items.length == 5)
          Row(children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(child: _PrayerItem(data: items[i], languageCode: languageCode, primary: primary, text: text, secondary: secondary)),
              if (i != items.length - 1) const SizedBox(width: 4),
            ],
          ])
        else
          Center(child: Text(_label(bn: 'সালাতের সময় প্রস্তুত হচ্ছে...', en: 'Preparing prayer times...', ar: 'جارٍ تجهيز أوقات الصلاة...'), style: TextStyle(color: secondary, fontSize: 11.5))),
      ]),
    );
  }
}

class _PrayerItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final String languageCode;
  final Color primary;
  final Color text;
  final Color secondary;

  const _PrayerItem({required this.data, required this.languageCode, required this.primary, required this.text, required this.secondary});

  @override
  Widget build(BuildContext context) {
    final isCurrent = data['isCurrent'] == true;
    final name = languageCode == 'en' ? (data['name']?.toString() ?? '--') : languageCode == 'ar' ? (data['nameAr']?.toString() ?? '--') : (data['nameBn']?.toString() ?? '--');
    final start = data['start']?.toString() ?? '--:--';
    final background = isCurrent ? primary.withValues(alpha: .10) : primary.withValues(alpha: .035);

    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14), border: Border.all(color: isCurrent ? primary.withValues(alpha: .16) : primary.withValues(alpha: .035))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (isCurrent)
          Container(width: 7, height: 7, decoration: BoxDecoration(color: primary, shape: BoxShape.circle))
        else
          Icon(Icons.check_circle_outline_rounded, size: 14, color: secondary.withValues(alpha: .62)),
        const SizedBox(height: 4),
        SizedBox(width: double.infinity, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child: Text(name, maxLines: 1, style: TextStyle(color: isCurrent ? primary : text, fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.1)))),
        const SizedBox(height: 3),
        SizedBox(width: double.infinity, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child: Text(start, maxLines: 1, style: TextStyle(color: isCurrent ? primary : secondary, fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.1)))),
      ]),
    );
  }
}
