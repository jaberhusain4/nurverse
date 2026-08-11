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
  final VoidCallback? onRefresh;

  const IslamicInfoCard({
    super.key,
    required this.location,
    required this.englishDate,
    required this.banglaDate,
    required this.hijriDate,
    required this.sunrise,
    required this.sunset,
    this.onRefresh,
  });

  String _hijriBanglaDate() {
    try {
      final h = HijriCalendar.now();
      const months = <String>[
        'মুহররম',
        'সফর',
        'রবিউল আউয়াল',
        'রবিউস সানি',
        'জুমাদিউল আউয়াল',
        'জুমাদিউস সানি',
        'রজব',
        'শাবান',
        'রমজান',
        'শাওয়াল',
        'জিলকদ',
        'জিলহজ',
      ];
      const digits = <String>['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

      String bnDigits(int value) => value
          .toString()
          .split('')
          .map((d) => digits[int.parse(d)])
          .join();

      final month = (h.hMonth >= 1 && h.hMonth <= 12) ? months[h.hMonth - 1] : '';
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
    if (sector != null && lower.contains('uttara')) {
      return 'Uttara Sector ${sector.group(1)}, Dhaka, Bangladesh';
    }

    if (lower.contains('uttara')) return 'Uttara, Dhaka, Bangladesh';
    if (lower.contains('dhaka')) return raw.contains('Bangladesh') ? raw : '$raw, Bangladesh';
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final cardColor = context.cardColor;
    final titleColor = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondaryColor = context.secondaryTextColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_today_rounded, color: primary, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('আজকের তথ্য', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('NurVerse Daily Overview', style: theme.textTheme.bodySmall?.copyWith(color: secondaryColor, fontSize: 10)),
                  ],
                ),
              ),
              if (onRefresh != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onRefresh,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.refresh_rounded, size: 20, color: primary),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.location_on_rounded,
            label: 'লোকেশন',
            value: _normalizeLocation(location),
            primaryColor: primary,
            titleColor: titleColor,
            secondaryColor: secondaryColor,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.event_rounded,
            label: 'English',
            value: englishDate,
            primaryColor: primary,
            titleColor: titleColor,
            secondaryColor: secondaryColor,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.calendar_month_rounded,
            label: 'বাংলা',
            value: banglaDate,
            primaryColor: primary,
            titleColor: titleColor,
            secondaryColor: secondaryColor,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.mosque_rounded,
            label: 'হিজরি',
            value: _hijriBanglaDate(),
            primaryColor: primary,
            titleColor: titleColor,
            secondaryColor: secondaryColor,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SunTimeItem(
                  icon: Icons.wb_sunny_outlined,
                  label: 'সূর্যোদয়',
                  time: sunrise,
                  primaryColor: primary,
                  titleColor: titleColor,
                  secondaryColor: secondaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SunTimeItem(
                  icon: Icons.wb_twilight_rounded,
                  label: 'সূর্যাস্ত',
                  time: sunset,
                  primaryColor: primary,
                  titleColor: titleColor,
                  secondaryColor: secondaryColor,
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: primaryColor),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 58,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryColor, fontSize: 10)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: titleColor, fontWeight: FontWeight.w600, fontSize: 11),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryColor),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryColor, fontSize: 9)),
                const SizedBox(height: 2),
                Text(
                  time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: titleColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
