import 'package:flutter/material.dart';
import 'live_prayer_restriction_card.dart';

/// Compatibility wrapper kept for existing screen wiring.
/// Home now renders the live restriction warning only; the old
/// "starts later" restriction message has been removed.
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
