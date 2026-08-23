import 'package:flutter/material.dart';

import 'live_prayer_restriction_card.dart';
import '../prayer/prayer_special_times_detail_card.dart';

/// Informative Home / Prayer compatibility entry point.
///
/// Informative Home supplies all four calculated window arguments and receives
/// the compact live Home card. Prayer screens omit those arguments and receive
/// the detailed special-times card.
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
    final hasCompleteHomeWindowInput =
        prohibitedStart != null &&
        prohibitedEnd != null &&
        makruhStart != null &&
        makruhEnd != null;

    if (hasCompleteHomeWindowInput) {
      return LivePrayerRestrictionCard(languageCode: languageCode);
    }

    return PrayerSpecialTimesDetailCard(languageCode: languageCode);
  }
}
