import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../theme/app_theme.dart';

class IslamicInfoCard extends StatelessWidget {
  final String location;
  final String englishDate;
  final String banglaDate;
  final String hijriDate;
  final String sunrise;
  final String sunset;
  final String languageCode;
  final VoidCallback? onRefresh;

  const IslamicInfoCard({
    super.key,
    required this.location,
    required this.englishDate,
    required this.banglaDate,
    required this.hijriDate,
    required this.sunrise,
    required this.sunset,
    this.languageCode = 'bn',
    this.onRefresh,
  });

  String _label({required String bn, required String en, required String ar}) {
    switch (languageCode) {
      case 'en':
        return en;
      case 'ar':
        return ar;
      default:
        return bn;
    }
  }

  String _hijriBanglaDate() {
    try {
      final h = HijriCalendar.now();
      const months = <String>['মুহররম','সফর','রবিউল আউয়াল','রবিউস সানি','জুমাদিউল আউয়াল','জুমাদিউস সানি','রজব','শাবান','রমজান','শাওয়াল','জিলকদ','জিলহজ'];
      const digits = <String>['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
      String bnDigits(int value) => value.toString().split('').map((d) => digits[int.parse(d)]).join();
      final month = h.hMonth >= 1 && h.hMonth <= 12 ? months[h.hMonth - 1] : '';
      return '${bnDigits(h.hDay)} $month ${bnDigits(h.hYear)} হিজরি';
    } catch (_) {
      return hijriDate;
    }
  }

  String _normalizeLocation(String value) {
    final raw = value.trim();
    if (raw.isEmpty || raw == 'লোকেশন লোড হচ্ছে...') return raw;
    final lower = raw.toLowerCase();
    if (lower.contains('mirpur')) return 'Mirpur, Dhaka, Bangladesh';
    final sector = RegExp(r'(?:sector|সেক্টর)\s*[- ]?(\d+)', caseSensitive: false).firstMatch(raw);
    if (sector != null && lower.contains('uttara')) return 'Uttara Sector ${sector.group(1)}, Dhaka, Bangladesh';
    if (lower.contains('uttara')) return 'Uttara, Dhaka, Bangladesh';
    if (lower.contains('dhaka') && !lower.contains('bangladesh')) return '$raw, Bangladesh';
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondary = context.secondaryTextColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: .055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: primary.withValues(alpha: .09), borderRadius: BorderRadius.circular(11)), child: Icon(Icons.location_on_rounded, color: primary, size: 18)),
              const SizedBox(width: 9),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_normalizeLocation(location), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(_label(bn: 'আজকের তথ্য', en: 'Today', ar: 'اليوم'), style: TextStyle(color: secondary, fontSize: 11, fontWeight: FontWeight.w600)),
                ]),
              ),
              if (onRefresh != null) IconButton(tooltip: _label(bn: 'রিফ্রেশ', en: 'Refresh', ar: 'تحديث'), onPressed: onRefresh, visualDensity: VisualDensity.compact, icon: Icon(Icons.refresh_rounded, size: 18, color: primary)),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(child: _DateBlock(label: _label(bn: 'ইংরেজি', en: 'Gregorian', ar: 'ميلادي'), value: englishDate, primary: primary, text: text, secondary: secondary)),
              const SizedBox(width: 7),
              Expanded(child: _DateBlock(label: _label(bn: 'বাংলা', en: 'Bangla', ar: 'بنغالية'), value: banglaDate, primary: primary, text: text, secondary: secondary)),
              const SizedBox(width: 7),
              Expanded(child: _DateBlock(label: _label(bn: 'হিজরি', en: 'Hijri', ar: 'هجري'), value: languageCode == 'bn' ? _hijriBanglaDate() : hijriDate, primary: primary, text: text, secondary: secondary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _SunBlock(icon: Icons.wb_sunny_outlined, label: _label(bn: 'সূর্যোদয়', en: 'Sunrise', ar: 'الشروق'), value: sunrise, primary: primary, text: text, secondary: secondary)),
              const SizedBox(width: 8),
              Expanded(child: _SunBlock(icon: Icons.wb_twilight_rounded, label: _label(bn: 'সূর্যাস্ত', en: 'Sunset', ar: 'الغروب'), value: sunset, primary: primary, text: text, secondary: secondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  final String label, value;
  final Color primary, text, secondary;

  const _DateBlock({required this.label, required this.value, required this.primary, required this.text, required this.secondary});

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
        decoration: BoxDecoration(color: primary.withValues(alpha: .035), borderRadius: BorderRadius.circular(13)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: secondary, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: text, fontSize: 12.5, fontWeight: FontWeight.w800)),
        ]),
      );
}

class _SunBlock extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color primary, text, secondary;

  const _SunBlock({required this.icon, required this.label, required this.value, required this.primary, required this.text, required this.secondary});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
        decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 1),
              child: Icon(icon, size: 18, color: primary),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: secondary, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(value.isEmpty ? '--:--' : value, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 22),
          ],
        ),
      );
}
