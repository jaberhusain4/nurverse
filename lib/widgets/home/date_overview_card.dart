// lib/widgets/home/date_overview_card.dart

import 'package:flutter/material.dart';

import '../../services/sun_time_service.dart';
import '../../theme/app_theme.dart';
import '../common_widgets.dart';

class DateOverviewCard extends StatelessWidget {
  final String englishDate;
  final String hijriDate;
  final SunTimeInfo sunInfo;

  const DateOverviewCard({
    super.key,
    required this.englishDate,
    required this.hijriDate,
    required this.sunInfo,
  });

  Widget _dateItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.seaBlue.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.seaBlue),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: context.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: context.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Container(
      width: 1,
      height: 58,
      color: AppColors.seaBlue.withValues(alpha: .10),
    );
  }

  Widget _sunItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.seaBlue.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.seaBlue),
          ),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: context.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: context.primaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================================
          // HEADER
          // ==========================================================
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.seaBlue.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: AppColors.seaBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'আজকের তারিখ',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ==========================================================
          // THREE DATE SYSTEMS
          // বাংলা | ENGLISH | HIJRI
          // ==========================================================
          Row(
            children: [
              _dateItem(
                context,
                icon: Icons.calendar_today_rounded,
                label: 'বাংলা',
                value: _banglaDate(englishDate),
              ),

              _divider(context),

              _dateItem(
                context,
                icon: Icons.event_rounded,
                label: 'English',
                value: englishDate,
              ),

              _divider(context),

              _dateItem(
                context,
                icon: Icons.brightness_2_rounded,
                label: 'হিজরি',
                value: hijriDate,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ==========================================================
          // SUN TIMES
          // ==========================================================
          Container(height: 1, color: AppColors.seaBlue.withValues(alpha: .08)),

          const SizedBox(height: 14),

          Row(
            children: [
              _sunItem(
                context,
                icon: Icons.wb_sunny_outlined,
                title: 'সূর্যোদয়',
                value: sunInfo.sunriseString,
              ),

              Container(
                width: 1,
                height: 30,
                color: AppColors.seaBlue.withValues(alpha: .08),
              ),

              _sunItem(
                context,
                icon: Icons.nightlight_round,
                title: 'সূর্যাস্ত',
                value: sunInfo.sunsetString,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // BANGLA DATE
  // ================================================================
  //
  // Current englishDate সাধারণত যেমন:
  // "Thursday, August 6, 2026"
  //
  // আপাতত day/month অংশকে Bangla label-এ compact করা হচ্ছে।
  // HomeScreen-এর actual Bengali calendar data থাকলে পরে সেটার
  // সাথে সরাসরি connect করা যাবে।
  // ================================================================

  String _banglaDate(String date) {
    final replacements = <String, String>{
      'Saturday': 'শনিবার',
      'Sunday': 'রবিবার',
      'Monday': 'সোমবার',
      'Tuesday': 'মঙ্গলবার',
      'Wednesday': 'বুধবার',
      'Thursday': 'বৃহস্পতিবার',
      'Friday': 'শুক্রবার',
      'January': 'জানুয়ারি',
      'February': 'ফেব্রুয়ারি',
      'March': 'মার্চ',
      'April': 'এপ্রিল',
      'May': 'মে',
      'June': 'জুন',
      'July': 'জুলাই',
      'August': 'আগস্ট',
      'September': 'সেপ্টেম্বর',
      'October': 'অক্টোবর',
      'November': 'নভেম্বর',
      'December': 'ডিসেম্বর',
    };

    String result = date;

    replacements.forEach((english, bangla) {
      result = result.replaceAll(english, bangla);
    });

    return _toBanglaDigits(result);
  }

  String _toBanglaDigits(String value) {
    const englishDigits = '0123456789';
    const banglaDigits = '০১২৩৪৫৬৭৮৯';

    String result = value;

    for (int i = 0; i < englishDigits.length; i++) {
      result = result.replaceAll(englishDigits[i], banglaDigits[i]);
    }

    return result;
  }
}
