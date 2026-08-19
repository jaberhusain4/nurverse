import 'package:flutter/material.dart';
import 'live_prayer_restriction_card.dart';
import '../prayer/prayer_special_times_detail_card.dart';

/// Compatibility wrapper.
/// Home passes the calculated window values and therefore gets the live-only warning.
/// Prayer screen calls this without window arguments and gets the full detailed schedule.
class PrayerSpecialTimesCard extends StatelessWidget {
  final String languageCode;
  final DateTime? prohibitedStart;
  final DateTime? prohibitedEnd;
  final DateTime? makruhStart;
  final DateTime? makruhEnd;

  const PrayerSpecialTimesCard({
    super.key,
    this.languageCode = 'bn',
    this.prohibitedStart,
    this.prohibitedEnd,
    this.makruhStart,
    this.makruhEnd,
  });

  @override
  Widget build(BuildContext context) {
    final hasWindowArguments = prohibitedStart != null ||
        prohibitedEnd != null ||
        makruhStart != null ||
        makruhEnd != null;
    return hasWindowArguments
        ? LivePrayerRestrictionCard(languageCode: languageCode)
        : PrayerSpecialTimesDetailCard(languageCode: languageCode);
  }
}
