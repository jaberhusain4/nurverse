import 'package:flutter/material.dart';
import 'live_prayer_restriction_card.dart';

/// Home compatibility wrapper.
/// Home shows only the live warning when a restriction is active.
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
    return LivePrayerRestrictionCard(languageCode: languageCode);
  }
}
