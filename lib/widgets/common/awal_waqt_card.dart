import 'package:flutter/material.dart';
import '../../controllers/prayer_controller.dart';
import '../../services/awal_waqt_service.dart';
import '../../theme/app_theme.dart';

/// Compact, reusable early-prayer guidance card for Home and Prayer screens.
///
/// The card reads the already-calculated prayer list from PrayerController and
/// never performs a second prayer-time calculation.
class AwalWaqtCard extends StatelessWidget {
  final PrayerController controller;
  final String languageCode;

  const AwalWaqtCard({
    super.key,
    required this.controller,
    this.languageCode = 'bn',
  });

  String _name(String key) {
    switch (key) {
      case 'Fajr':
        return languageCode == 'en' ? 'Fajr' : 'ফজর';
      case 'Dhuhr':
        return languageCode == 'en' ? 'Dhuhr' : 'যোহর';
      case 'Asr':
        return languageCode == 'en' ? 'Asr' : 'আসর';
      case 'Maghrib':
        return languageCode == 'en' ? 'Maghrib' : 'মাগরিব';
      case 'Isha':
        return languageCode == 'en' ? 'Isha' : 'ইশা';
      default:
        return key;
    }
  }

  String _label(String bn, String en) => languageCode == 'en' ? en : bn;

  String _duration(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final service = const AwalWaqtService();
    final now = DateTime.now();
    final windows = service.buildWindowsFromPrayerList(
      controller.prayers,
      now: now,
    );
    final active = service.activeWindow(windows, now);

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = context.cardColor;
    final text = context.primaryTextColor;
    final secondary = context.secondaryTextColor;

    final String title;
    final String subtitle;
    final String timer;
    final String range;
    final bool isActive = active != null;

    if (active != null) {
      title = _label('আওয়াল ওয়াক্ত চলছে', 'Early prayer time');
      subtitle = _name(active.prayerKey);
      timer = _duration(active.remainingFrom(now));
      range = '${service.formatTime(active.start)} – ${service.formatTime(active.end)}';
    } else {
      final upcoming = windows.where((w) => w.start.isAfter(now)).toList();
      upcoming.sort((a, b) => a.start.compareTo(b.start));
      final next = upcoming.isEmpty ? null : upcoming.first;

      if (next == null) {
        title = _label('প্রারম্ভিক সময় শেষ', 'Early window ended');
        subtitle = _label('পরবর্তী ওয়াক্তের জন্য অপেক্ষা করুন', 'Waiting for the next prayer');
        timer = '00:00:00';
        range = '--:--';
      } else {
        title = _label('পরবর্তী আওয়াল ওয়াক্ত', 'Next early prayer window');
        subtitle = _name(next.prayerKey);
        timer = _duration(next.start.difference(now));
        range = '${service.formatTime(next.start)} – ${service.formatTime(next.end)}';
      }
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(Icons.schedule_rounded, color: primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: text,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      IconButton(
                        tooltip: _label('আওয়াল ওয়াক্ত সম্পর্কে', 'About early prayer time'),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                        onPressed: () => _showInfo(context),
                        icon: Icon(Icons.info_outline_rounded, size: 16, color: secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    range,
                    style: TextStyle(color: secondary, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isActive
                      ? _label('সময় বাকি', 'Time left')
                      : _label('শুরু হতে', 'Starts in'),
                  style: TextStyle(color: secondary, fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  timer,
                  style: TextStyle(
                    color: primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    final isEnglish = languageCode == 'en';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEnglish ? 'About Awal Waqt' : 'আওয়াল ওয়াক্ত সম্পর্কে',
                style: TextStyle(
                  color: sheetContext.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isEnglish
                    ? 'The Sunnah encourages praying at its proper and early time. Islamic sources do not establish one universal number of minutes that defines the end of Awal Waqt for every prayer. NurVerse therefore shows an app-level early-prayer guidance window; it is not a Shar‘i deadline.'
                    : 'সুন্নাহ সালাত যথাসময়ে ও শুরুতে আদায় করতে উৎসাহিত করে। তবে সব সালাতের জন্য “আওয়াল ওয়াক্ত” শেষ হওয়ার একক নির্দিষ্ট মিনিট শরিয়তে নির্ধারিত নেই। তাই NurVerse এখানে একটি সহায়ক প্রারম্ভিক সময়ের window দেখায়; এটিকে শরঈ শেষসীমা হিসেবে গণ্য করা যাবে না।',
                style: TextStyle(
                  color: sheetContext.secondaryTextColor,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
