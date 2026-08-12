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
      const months = <String>[
        'মুহররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি',
        'জুমাদিউল আউয়াল', 'জুমাদিউস সানি', 'রজব', 'শাবান',
        'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ',
      ];
      const digits = <String>['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

      String bnDigits(int value) => value
          .toString()
          .split('')
          .map((d) => digits[int.parse(d)])
          .join();

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

    final sector = RegExp(
      r'(?:sector|সেক্টর)\s*[- ]?(\d+)',
      caseSensitive: false,
    ).firstMatch(raw);

    if (sector != null && lower.contains('uttara')) {
      return 'Uttara Sector ${sector.group(1)}, Dhaka, Bangladesh';
    }

    if (lower.contains('uttara')) return 'Uttara, Dhaka, Bangladesh';
    if (lower.contains('dhaka')) {
      return raw.contains('Bangladesh') ? raw : '$raw, Bangladesh';
    }

    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final cardColor = context.cardColor;
    final titleColor = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondary = context.secondaryTextColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_today_rounded, color: primary, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label(bn: 'আজকের তথ্য', en: 'Today', ar: 'اليوم'),
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _label(bn: 'NurVerse দৈনিক সারসংক্ষেপ', en: 'NurVerse Daily Overview', ar: 'ملخص نورفيرس اليومي'),
                      style: theme.textTheme.bodySmall?.copyWith(color: secondary, fontSize: 10),
                    ),
                  ],
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  tooltip: _label(bn: 'রিফ্রেশ', en: 'Refresh', ar: 'تحديث'),
                  onPressed: onRefresh,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.refresh_rounded, size: 19, color: primary),
                ),
            ],
          ),
          const SizedBox(height: 13),
          _InfoRow(
            icon: Icons.location_on_rounded,
            label: _label(bn: 'লোকেশন', en: 'Location', ar: 'الموقع'),
            value: _normalizeLocation(location),
            primaryColor: primary,
            titleColor: titleColor,
            secondaryColor: secondary,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.event_rounded,
            label: _label(bn: 'তারিখ', en: 'Date', ar: 'التاريخ'),
            value: englishDate,
            primaryColor: primary,
            titleColor: titleColor,
            secondaryColor: secondary,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.calendar_month_rounded,
            label: _label(bn: 'বাংলা', en: 'Bangla', ar: 'بنغالية'),
            value: banglaDate,
            primaryColor: primary,
            titleColor: titleColor,
            secondaryColor: secondary,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.mosque_rounded,
            label: _label(bn: 'হিজরি', en: 'Hijri', ar: 'هجري'),
            value: languageCode == 'bn' ? _hijriBanglaDate() : hijriDate,
            primaryColor: primary,
            titleColor: titleColor,
            secondaryColor: secondary,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SunTimeItem(
                  icon: Icons.wb_sunny_outlined,
                  label: _label(bn: 'সূর্যোদয়', en: 'Sunrise', ar: 'الشروق'),
                  time: sunrise,
                  primaryColor: primary,
                  titleColor: titleColor,
                  secondaryColor: secondary,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _SunTimeItem(
                  icon: Icons.wb_twilight_rounded,
                  label: _label(bn: 'সূর্যাস্ত', en: 'Sunset', ar: 'الغروب'),
                  time: sunset,
                  primaryColor: primary,
                  titleColor: titleColor,
                  secondaryColor: secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color primaryColor;
  final Color titleColor;
  final Color secondaryColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.primaryColor,
    required this.titleColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: primaryColor),
        ),
        const SizedBox(width: 9),
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: secondaryColor,
              fontSize: 10.5,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _SunTimeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final Color primaryColor;
  final Color titleColor;
  final Color secondaryColor;

  const _SunTimeItem({
    required this.icon,
    required this.label,
    required this.time,
    required this.primaryColor,
    required this.titleColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: secondaryColor, fontSize: 9.5)),
                const SizedBox(height: 2),
                Text(
                  time.isEmpty ? '--:--' : time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: titleColor, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
