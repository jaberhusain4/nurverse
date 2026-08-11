import 'package:flutter/material.dart';
import '../../controllers/prayer_controller.dart';
import '../../services/awal_waqt_service.dart';
import '../../theme/app_theme.dart';

/// Compact, reusable Awal Waqt status card for Home and Prayer screens.
///
/// The card reads the already-calculated prayer list from PrayerController and
/// never performs a second prayer-time calculation. This keeps the UI offline,
/// fast, and synchronized with the app's single prayer-time source of truth.
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

    if (active != null) {
      title = _label('আওয়াল ওয়াক্ত চলছে', 'Awal Waqt is active');
      subtitle = _name(active.prayerKey);
      timer = _duration(active.remainingFrom(now));
      range = '${service.formatTime(active.start)} – ${service.formatTime(active.end)}';
    } else {
      final upcoming = windows.where((w) => w.start.isAfter(now)).toList();
      upcoming.sort((a, b) => a.start.compareTo(b.start));
      final next = upcoming.isEmpty ? null : upcoming.first;

      if (next == null) {
        title = _label('আওয়াল ওয়াক্ত শেষ', 'Awal Waqt ended');
        subtitle = _label('পরবর্তী ওয়াক্তের জন্য অপেক্ষা করুন', 'Waiting for the next prayer');
        timer = '00:00:00';
        range = '--:--';
      } else {
        title = _label('পরবর্তী আওয়াল ওয়াক্ত', 'Next Awal Waqt');
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
                  Text(
                    title,
                    style: TextStyle(
                      color: text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
                  _label('সময় বাকি', 'Time left'),
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
}
