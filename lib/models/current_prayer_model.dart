class CurrentPrayerModel {
  final String currentPrayer;

  final String nextPrayer;

  final Duration remaining;

  const CurrentPrayerModel({
    required this.currentPrayer,
    required this.nextPrayer,
    required this.remaining,
  });
}