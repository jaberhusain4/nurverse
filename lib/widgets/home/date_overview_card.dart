// lib/widgets/home/date_overview_card.dart

import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../localization/app_localizations_locale_text_x.dart';
import '../../services/sun_time_service.dart';
import '../../theme/app_theme.dart';
import '../common_widgets.dart';

class DateOverviewCard extends StatelessWidget {
  final String englishDate;
  final String hijriDate;
  final SunTimeInfo sunInfo;

  const DateOverviewCard({super.key, required this.englishDate, required this.hijriDate, required this.sunInfo});

  Widget _dateItem(BuildContext context, {required String label, required String value, required IconData icon}) {
    final theme = Theme.of(context);
    return Expanded(child: Column(children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: .10), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: AppColors.seaBlue)),
      const SizedBox(height: 7),
      Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontSize: 13, color: context.secondaryTextColor, fontWeight: FontWeight.w600)),
      const SizedBox(height: 3),
      Text(value, textAlign: TextAlign.center, maxLines: 2, softWrap: true, overflow: TextOverflow.visible, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5, height: 1.15, fontWeight: FontWeight.w500, color: context.primaryTextColor)),
    ]));
  }

  Widget _divider(BuildContext context) => Container(width: 1, height: 58, color: AppColors.seaBlue.withValues(alpha: .10));

  Widget _sunItem(BuildContext context, {required IconData icon, required String title, required String value}) {
    final theme = Theme.of(context);
    return Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: .10), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: AppColors.seaBlue)),
      const SizedBox(width: 9),
      Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontSize: 13, color: context.secondaryTextColor, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13, color: context.primaryTextColor))])),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: .10), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.seaBlue)), const SizedBox(width: 10), Expanded(child: Text(l10n.tr('আজকের তারিখ', 'Today'), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 16)))]),
      const SizedBox(height: 16),
      Row(children: [
        _dateItem(context, icon: Icons.calendar_today_rounded, label: l10n.localeText(values: const {'bn': 'বাংলা', 'en': 'Bangla', 'ar': 'البنغالية'}), value: _banglaDate(englishDate)),
        _divider(context),
        _dateItem(context, icon: Icons.event_rounded, label: l10n.localeText(values: const {'bn': 'ইংরেজি', 'en': 'Gregorian', 'ar': 'الميلادي'}), value: englishDate),
        _divider(context),
        _dateItem(context, icon: Icons.brightness_2_rounded, label: l10n.localeText(values: const {'bn': 'হিজরি', 'en': 'Hijri', 'ar': 'الهجري'}), value: hijriDate),
      ]),
      const SizedBox(height: 16),
      Container(height: 1, color: AppColors.seaBlue.withValues(alpha: .08)),
      const SizedBox(height: 14),
      Row(children: [_sunItem(context, icon: Icons.wb_sunny_outlined, title: l10n.sunrise, value: sunInfo.sunriseString), Container(width: 1, height: 30, color: AppColors.seaBlue.withValues(alpha: .08)), _sunItem(context, icon: Icons.nightlight_round, title: l10n.sunset, value: sunInfo.sunsetString)]),
    ]));
  }

  String _banglaDate(String date) {
    const replacements = <String, String>{'Saturday': 'শনিবার', 'Sunday': 'রবিবার', 'Monday': 'সোমবার', 'Tuesday': 'মঙ্গলবার', 'Wednesday': 'বুধবার', 'Thursday': 'বৃহস্পতিবার', 'Friday': 'শুক্রবার', 'January': 'জানুয়ারি', 'February': 'ফেব্রুয়ারি', 'March': 'মার্চ', 'April': 'এপ্রিল', 'May': 'মে', 'June': 'জুন', 'July': 'জুলাই', 'August': 'আগস্ট', 'September': 'সেপ্টেম্বর', 'October': 'অক্টোবর', 'November': 'নভেম্বর', 'December': 'ডিসেম্বর'};
    var result = date;
    replacements.forEach((english, bangla) => result = result.replaceAll(english, bangla));
    return _toBanglaDigits(result);
  }

  String _toBanglaDigits(String value) {
    const englishDigits = '0123456789';
    const banglaDigits = '০১২৩৪৫৬৭৮৯';
    var result = value;
    for (var i = 0; i < englishDigits.length; i++) { result = result.replaceAll(englishDigits[i], banglaDigits[i]); }
    return result;
  }
}
