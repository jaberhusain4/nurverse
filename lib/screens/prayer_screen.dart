import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../localization/app_localizations.dart';
import '../theme/app_theme.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final Map<String, bool> _prayerTracker = {
    'ফজর': false,
    'যোহর': false,
    'আসর': false,
    'মাগরিব': false,
    'ইশা': false,
    "জুমু'আ": false,
  };

  String _prayerLabel(AppLocalizations l10n, String value) {
    switch (value.trim().toLowerCase()) {
      case 'ফজর':
      case 'fajr':
        return l10n.fajr;
      case 'যোহর':
      case 'dhuhr':
        return l10n.dhuhr;
      case 'আসর':
      case 'asr':
        return l10n.asr;
      case 'মাগরিব':
      case 'maghrib':
        return l10n.maghrib;
      case 'ইশা':
      case 'isha':
        return l10n.isha;
      case "জুমু'আ":
      case 'জুমু‘আ':
      case 'jumuah':
      case 'jumu’ah':
        return l10n.jumuah;
      case 'তাহাজ্জুদ':
      case 'tahajjud':
        return l10n.tahajjud;
      case 'ইশরাক':
      case 'ishraq':
        return l10n.ishraq;
      case 'চাশত / দুহা':
      case 'দুহা':
      case 'duha':
        return l10n.duha;
      case 'আউওয়াবীন':
      case 'awwabin':
        return l10n.awwabin;
      case 'ওয়াক্ত নেই':
      case 'none':
        return l10n.noPrayerWindow;
      default:
        return value;
    }
  }

  String _localizedStatus(AppLocalizations l10n, String value) {
    switch (value) {
      case 'ইশার ওয়াক্ত চলছে':
        return l10n.tr('ইশার ওয়াক্ত চলছে', 'Isha time is ongoing');
      case 'ফজরের সময় শুরু হতে চলেছে':
        return l10n.tr('ফজরের সময় শুরু হতে চলেছে', 'Fajr time is about to begin');
      case 'ফজরের ওয়াক্ত চলছে':
        return l10n.tr('ফজরের ওয়াক্ত চলছে', 'Fajr time is ongoing');
      case 'ফজরের ওয়াক্ত শেষ হয়েছে':
        return l10n.tr('ফজরের ওয়াক্ত শেষ হয়েছে', 'Fajr time has ended');
      case 'ইশা শেষ হয়েছে':
        return l10n.tr('ইশা শেষ হয়েছে', 'Isha has ended');
      case 'ফজর শেষ হয়েছে':
        return l10n.tr('ফজর শেষ হয়েছে', 'Fajr has ended');
      case "জুমু'আর ওয়াক্ত চলছে":
        return l10n.tr("জুমু'আর ওয়াক্ত চলছে", 'Jumu’ah time is ongoing');
      case 'যোহরের ওয়াক্ত চলছে':
        return l10n.tr('যোহরের ওয়াক্ত চলছে', 'Dhuhr time is ongoing');
      case 'আসরের ওয়াক্ত চলছে':
        return l10n.tr('আসরের ওয়াক্ত চলছে', 'Asr time is ongoing');
      case 'আসর শেষ হয়েছে':
        return l10n.tr('আসর শেষ হয়েছে', 'Asr has ended');
      case 'মাগরিবের ওয়াক্ত চলছে':
        return l10n.tr('মাগরিবের ওয়াক্ত চলছে', 'Maghrib time is ongoing');
      case 'মাগরিব শেষ হয়েছে':
        return l10n.tr('মাগরিব শেষ হয়েছে', 'Maghrib has ended');
      case 'লোকেশন পাওয়া গেলে সালাতের সময় দেখানো হবে':
        return l10n.tr('লোকেশন পাওয়া গেলে সালাতের সময় দেখানো হবে', 'Prayer times will be shown when a location is available');
      case 'লোকেশন পাওয়া গেলে সময় দেখানো হবে':
        return l10n.tr('লোকেশন পাওয়া গেলে সময় দেখানো হবে', 'Times will be shown when a location is available');
      case 'সালাতের সময় গণনা করা হচ্ছে...':
        return l10n.tr('সালাতের সময় গণনা করা হচ্ছে...', 'Calculating prayer times...');
      default:
        return value;
    }
  }

  String _localizedSpecialTime(AppLocalizations l10n, String value) {
    switch (value) {
      case 'আজ আর কোনো নিষিদ্ধ সময় নেই':
        return l10n.tr('আজ আর কোনো নিষিদ্ধ সময় নেই', 'No more prohibited time today');
      case 'সূর্যোদয়ের সময় — নামাজ আদায় থেকে বিরত থাকুন':
        return l10n.tr('সূর্যোদয়ের সময় — নামাজ আদায় থেকে বিরত থাকুন', 'Sunrise period — refrain from prayer');
      case 'জাওয়ালের সময় — নামাজ আদায় থেকে বিরত থাকুন':
        return l10n.tr('জাওয়ালের সময় — নামাজ আদায় থেকে বিরত থাকুন', 'Zawal period — refrain from prayer');
      case 'সূর্যাস্তের সময় — নামাজ আদায় থেকে বিরত থাকুন':
        return l10n.tr('সূর্যাস্তের সময় — নামাজ আদায় থেকে বিরত থাকুন', 'Sunset period — refrain from prayer');
      case 'পরবর্তী নিষিদ্ধ সময়: সূর্যোদয়':
        return l10n.tr('পরবর্তী নিষিদ্ধ সময়: সূর্যোদয়', 'Next prohibited time: Sunrise');
      case 'পরবর্তী নিষিদ্ধ সময়: জাওয়াল':
        return l10n.tr('পরবর্তী নিষিদ্ধ সময়: জাওয়াল', 'Next prohibited time: Zawal');
      case 'পরবর্তী নিষিদ্ধ সময়: সূর্যাস্ত':
        return l10n.tr('পরবর্তী নিষিদ্ধ সময়: সূর্যাস্ত', 'Next prohibited time: Sunset');
      case 'আজ আর কোনো বিশেষ মাকরূহ সময় নেই':
        return l10n.tr('আজ আর কোনো বিশেষ মাকরূহ সময় নেই', 'No more special Makruh time today');
      case 'সূর্যোদয়ের আশেপাশের মাকরূহ সময়':
        return l10n.tr('সূর্যোদয়ের আশেপাশের মাকরূহ সময়', 'Makruh period around sunrise');
      case 'জাওয়ালের আশেপাশের মাকরূহ সময়':
        return l10n.tr('জাওয়ালের আশেপাশের মাকরূহ সময়', 'Makruh period around Zawal');
      case 'সূর্যাস্তের আশেপাশের মাকরূহ সময়':
        return l10n.tr('সূর্যাস্তের আশেপাশের মাকরূহ সময়', 'Makruh period around sunset');
      case 'পরবর্তী মাকরূহ সময়: সূর্যোদয়':
        return l10n.tr('পরবর্তী মাকরূহ সময়: সূর্যোদয়', 'Next Makruh time: Sunrise');
      case 'পরবর্তী মাকরূহ সময়: জাওয়াল':
        return l10n.tr('পরবর্তী মাকরূহ সময়: জাওয়াল', 'Next Makruh time: Zawal');
      case 'পরবর্তী মাকরূহ সময়: সূর্যাস্ত':
        return l10n.tr('পরবর্তী মাকরূহ সময়: সূর্যাস্ত', 'Next Makruh time: Sunset');
      case 'সময় গণনা করা হচ্ছে...':
        return l10n.tr('সময় গণনা করা হচ্ছে...', 'Calculating time...');
      default:
        return value;
    }
  }

  String _localizedLocation(AppLocalizations l10n, String value) {
    switch (value) {
      case 'লোকেশন লোড হচ্ছে...':
        return l10n.tr('লোকেশন লোড হচ্ছে...', 'Loading location...');
      case 'লোকেশন পাওয়া যায়নি':
        return l10n.locationUnavailable;
      case 'লোকেশন সার্ভিস বন্ধ আছে':
        return l10n.tr('লোকেশন সার্ভিস বন্ধ আছে', 'Location service is disabled');
      case 'লোকেশন পারমিশন দেওয়া হয়নি':
        return l10n.tr('লোকেশন পারমিশন দেওয়া হয়নি', 'Location permission was not granted');
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<PrayerController>();
    final primary = theme.colorScheme.primary;
    final isFriday = DateTime.now().weekday == DateTime.friday;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prayer, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(tooltip: l10n.location, onPressed: () => _showLocation(context, controller.currentLocationName), icon: Icon(Icons.location_on_outlined, color: primary)),
          IconButton(tooltip: l10n.refresh, onPressed: controller.loading ? null : controller.refreshPrayerTimes, icon: Icon(Icons.refresh_rounded, color: primary)),
        ],
      ),
      body: controller.loading
          ? Center(child: CircularProgressIndicator(color: primary))
          : controller.error != null
              ? _buildErrorState(context, controller)
              : RefreshIndicator(
                  color: primary,
                  onRefresh: controller.refreshPrayerTimes,
                  child: ListView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      _buildLocationCard(context, controller.currentLocationName),
                      const SizedBox(height: 14),
                      _buildCurrentPrayerCard(context, controller, isFriday),
                      const SizedBox(height: 14),
                      _buildPrayerTimeSummary(context, controller),
                      const SizedBox(height: 14),
                      _buildDailyTimeCard(context, controller),
                      const SizedBox(height: 22),
                      _buildSectionTitle(context, l10n.todaysPrayer, l10n.fullPrayerSchedule, Icons.mosque_outlined),
                      const SizedBox(height: 10),
                      _buildPrayerSchedule(context, controller),
                      const SizedBox(height: 22),
                      _buildSectionTitle(context, l10n.naflAndOtherPrayers, l10n.optionalWorshipTimes, Icons.auto_awesome_outlined),
                      const SizedBox(height: 10),
                      _buildNaflSection(context, controller),
                      const SizedBox(height: 22),
                      _buildSectionTitle(context, l10n.prayerTracker, l10n.markPrayers, Icons.check_circle_outline_rounded),
                      const SizedBox(height: 10),
                      _buildPrayerTracker(context, isFriday),
                      const SizedBox(height: 20),
                      _buildFooterNote(context),
                    ],
                  ),
                ),
    );
  }

  Widget _buildLocationCard(BuildContext context, String location) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: primary.withValues(alpha: .08))),
      child: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.location_on_rounded, color: primary, size: 20)),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.location, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: context.secondaryTextColor)),
          const SizedBox(height: 2),
          Text(_localizedLocation(l10n, location), maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
        ])),
      ]),
    );
  }

  Widget _buildCurrentPrayerCard(BuildContext context, PrayerController controller, bool isFriday) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: primary.withValues(alpha: .10)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Column(children: [
        Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.mosque_rounded, color: primary, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.currentPrayer, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: context.secondaryTextColor)),
            const SizedBox(height: 2),
            Text(_prayerLabel(l10n, controller.currentPrayer), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.w700)),
          ])),
          if (isFriday) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(20)), child: Text(l10n.friday, style: TextStyle(color: primary, fontSize: 14, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _buildMiniInfo(context, icon: Icons.play_arrow_rounded, title: l10n.start, value: controller.currentPrayerStart)),
          const SizedBox(width: 10),
          Expanded(child: _buildMiniInfo(context, icon: Icons.stop_rounded, title: l10n.end, value: controller.currentPrayerEnd)),
          const SizedBox(width: 10),
          Expanded(child: _buildMiniInfo(context, icon: Icons.groups_rounded, title: l10n.jamaat, value: controller.currentIqamahTime)),
        ]),
        const SizedBox(height: 18),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: controller.prayerProgress.clamp(0.0, 1.0), minHeight: 8, backgroundColor: primary.withValues(alpha: .10), valueColor: AlwaysStoppedAnimation<Color>(primary))),
        const SizedBox(height: 10),
        Row(children: [Icon(Icons.timelapse_rounded, size: 18, color: primary), const SizedBox(width: 7), Expanded(child: Text(_localizedStatus(l10n, controller.prayerStatus), maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w600)))]),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: primary.withValues(alpha: .06), borderRadius: BorderRadius.circular(15)),
          child: Row(children: [
            Icon(Icons.schedule_rounded, size: 19, color: primary),
            const SizedBox(width: 9),
            Expanded(child: Text(l10n.nextPrayerAt(_prayerLabel(l10n, controller.nextPrayerName), controller.nextPrayerTime), maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w600))),
            const SizedBox(width: 10),
            Flexible(fit: FlexFit.loose, child: Text(controller.timeRemainingForNextPrayer, maxLines: 1, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: context.secondaryTextColor, fontWeight: FontWeight.w700))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildPrayerTimeSummary(BuildContext context, PrayerController controller) {
    final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: primary.withValues(alpha: .08))),
      child: Column(children: [
        Row(children: [
          Icon(Icons.access_time_rounded, color: primary, size: 20),
          const SizedBox(width: 8),
          Text(l10n.prayerTimes, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _buildTimeBox(context, l10n.previousPrayer, controller.previousPrayer, controller.previousPrayerTime, Icons.history_rounded)),
          const SizedBox(width: 10),
          Expanded(child: _buildTimeBox(context, l10n.current, controller.currentPrayer, controller.currentPrayerStart, Icons.mosque_outlined)),
          const SizedBox(width: 10),
          Expanded(child: _buildTimeBox(context, l10n.next, controller.nextPrayerName, controller.nextPrayerTime, Icons.arrow_forward_rounded)),
        ]),
      ]),
    );
  }

  Widget _buildDailyTimeCard(BuildContext context, PrayerController controller) {
    final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final primary = theme.colorScheme.primary;
    return Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: primary.withValues(alpha: .08))), child: Column(children: [Row(children: [Icon(Icons.wb_twilight_rounded, color: primary, size: 21), const SizedBox(width: 8), Text(l10n.importantTimes, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 16))]), const SizedBox(height: 14), Row(children: [Expanded(child: _buildDailyTimeItem(context, Icons.wb_sunny_outlined, l10n.sunrise, controller.sunriseTime, primary)), _verticalDivider(context), Expanded(child: _buildDailyTimeItem(context, Icons.light_mode_outlined, l10n.solarNoon, controller.solarNoonTime, primary)), _verticalDivider(context), Expanded(child: _buildDailyTimeItem(context, Icons.nights_stay_outlined, l10n.sunset, controller.sunsetTime, primary))]), const SizedBox(height: 14), _buildSpecialTimeRow(context, Icons.warning_amber_rounded, l10n.makruhTime, controller.makruhTimeText, Colors.orange, controller.makruhStart, controller.makruhEnd), const SizedBox(height: 8), _buildSpecialTimeRow(context, Icons.block_rounded, l10n.prohibitedTime, controller.prohibitedTimeText, Colors.redAccent, controller.prohibitedStart, controller.prohibitedEnd)]));
  }

  Widget _buildSectionTitle(BuildContext context, String title, String subtitle, IconData icon) { final theme = Theme.of(context); final primary = theme.colorScheme.primary; return Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: primary, size: 20)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 1), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: context.secondaryTextColor, fontSize: 14))])]); }

  Widget _buildPrayerSchedule(BuildContext context, PrayerController controller) {
    final prayers = controller.prayers;
    return Container(decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .08))), child: Column(children: [for (var i = 0; i < prayers.length; i++) ...[_buildPrayerRow(context, controller, prayers[i]), if (i != prayers.length - 1) Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: .5))]]));
  }

  Widget _buildPrayerRow(BuildContext context, PrayerController controller, Map<String, dynamic> prayer) {
    final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final primary = theme.colorScheme.primary;
    final rawName = prayer['name']?.toString() ?? '';
    final name = _prayerLabel(l10n, rawName);
    final time = prayer['start']?.toString() ?? prayer['time']?.toString() ?? '--:--';
    final jamaat = prayer['jamaat']?.toString() ?? '--:--';
    final isCurrent = _normalize(rawName) == _normalize(controller.currentPrayer);
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: isCurrent ? primary.withValues(alpha: .12) : primary.withValues(alpha: .06), borderRadius: BorderRadius.circular(12)), child: Icon(_prayerIcon(rawName), color: primary, size: 20)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600, fontSize: 15)), const SizedBox(height: 2), Text(isCurrent ? l10n.current : l10n.start, style: theme.textTheme.bodySmall?.copyWith(color: context.secondaryTextColor, fontSize: 14))])), Text(time, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(width: 14), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(l10n.jamaat, style: theme.textTheme.bodySmall?.copyWith(color: context.secondaryTextColor, fontSize: 14)), Text(jamaat, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 14))]) ]));
  }

  Widget _buildNaflSection(BuildContext context, PrayerController controller) {
    final l10n = AppLocalizations.of(context);
    final items = <_NaflItem>[
      _NaflItem(l10n.ishraq, controller.ishraqTime, controller.ishraqStart, controller.ishraqEnd, Icons.wb_sunny_outlined),
      _NaflItem(l10n.duha, controller.duhaTime, controller.duhaStart, controller.duhaEnd, Icons.wb_twilight_rounded),
      _NaflItem(l10n.awwabin, controller.awwabinTime, controller.awwabinStart, controller.awwabinEnd, Icons.nights_stay_outlined),
      _NaflItem(l10n.tahajjud, controller.tahajjudTime, controller.tahajjudStart, controller.tahajjudEnd, Icons.bedtime_outlined),
    ];
    return Column(children: [for (final item in items) ...[_buildNaflCard(context, item), const SizedBox(height: 9)]]);
  }

  Widget _buildNaflCard(BuildContext context, _NaflItem item) {
    final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final primary = theme.colorScheme.primary; final now = DateTime.now();
    final hasWindow = item.start != null && item.end != null && item.end!.isAfter(item.start!);
    final active = hasWindow && !now.isBefore(item.start!) && now.isBefore(item.end!);
    final upcoming = hasWindow && now.isBefore(item.start!);
    final status = !hasWindow ? l10n.completed : active ? l10n.current : upcoming ? l10n.next : l10n.completed;
    final target = upcoming ? item.start : item.end;
    final timer = target == null ? '' : _formatDuration(target.difference(now).isNegative ? Duration.zero : target.difference(now));
    final window = hasWindow ? '${_formatTime(item.start!)} – ${_formatTime(item.end!)}' : item.window;
    return Container(padding: const EdgeInsets.fromLTRB(14, 13, 14, 13), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: active ? primary.withValues(alpha: .22) : primary.withValues(alpha: .08))), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(13)), child: Icon(item.icon, color: primary, size: 21)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(window, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: context.secondaryTextColor)), const SizedBox(height: 3), Text(status, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontSize: 14, color: active ? primary : context.secondaryTextColor, fontWeight: FontWeight.w700))])), if (target != null) ...[const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(_formatTime(target), style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold)), if (timer.isNotEmpty) ...[const SizedBox(height: 4), Text(timer, maxLines: 1, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: primary, fontWeight: FontWeight.w800))]])]]));
  }

  Widget _buildPrayerTracker(BuildContext context, bool isFriday) {
    final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final primary = theme.colorScheme.primary; final entries = isFriday ? <String>[..._prayerTracker.keys] : _prayerTracker.keys.where((key) => key != "জুমু'আ").toList();
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: primary.withValues(alpha: .08))), child: Wrap(spacing: 8, runSpacing: 8, children: entries.map((name) => FilterChip(label: Text(_prayerLabel(l10n, name), style: const TextStyle(fontSize: 14)), selected: _prayerTracker[name] ?? false, onSelected: (value) => setState(() => _prayerTracker[name] = value), selectedColor: primary.withValues(alpha: .14))).toList()));
  }

  Widget _buildFooterNote(BuildContext context) {
    final l10n = AppLocalizations.of(context); return Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(l10n.tr('নামাজের সময় আপনার সংরক্ষিত অবস্থান অনুযায়ী অফলাইনে গণনা করা হয়.', 'Prayer times are calculated offline based on your saved location.'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14, color: context.secondaryTextColor)));
  }

  Widget _buildMiniInfo(BuildContext context, {required IconData icon, required String title, required String value}) { final theme = Theme.of(context); final primary = theme.colorScheme.primary; return Column(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: primary, size: 18)), const SizedBox(height: 6), Text(title, style: theme.textTheme.bodySmall?.copyWith(fontSize: 14, color: context.secondaryTextColor, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold))]); }

  Widget _buildTimeBox(BuildContext context, String label, String prayer, String time, IconData icon) { final theme = Theme.of(context); final primary = theme.colorScheme.primary; final l10n = AppLocalizations.of(context); return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11), decoration: BoxDecoration(color: primary.withValues(alpha: .05), borderRadius: BorderRadius.circular(15)), child: Column(children: [Icon(icon, color: primary, size: 18), const SizedBox(height: 5), Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontSize: 14, color: context.secondaryTextColor)), const SizedBox(height: 3), Text(_prayerLabel(l10n, prayer), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(time, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold))])); }

  Widget _buildDailyTimeItem(BuildContext context, IconData icon, String title, String value, Color color) { final theme = Theme.of(context); return Column(children: [Icon(icon, color: color, size: 21), const SizedBox(height: 6), Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontSize: 14, color: context.secondaryTextColor)), const SizedBox(height: 3), Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold))]); }

  Widget _buildSpecialTimeRow(BuildContext context, IconData icon, String title, String fallbackValue, Color color, DateTime? start, DateTime? end) {
    final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final now = DateTime.now();
    final hasWindow = start != null && end != null && end.isAfter(start);
    final active = hasWindow && !now.isBefore(start) && now.isBefore(end);
    final upcoming = hasWindow && now.isBefore(start);
    final status = active ? l10n.current : upcoming ? l10n.next : l10n.completed;
    final target = upcoming ? start : end;
    final remaining = target == null ? null : target.difference(now);
    final countdown = remaining == null ? '' : _formatDuration(remaining.isNegative ? Duration.zero : remaining);
    final exactWindow = hasWindow ? '${_formatTime(start!)} – ${_formatTime(end!)}' : _localizedSpecialTime(l10n, fallbackValue);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: color.withValues(alpha: .07), borderRadius: BorderRadius.circular(14)), child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(exactWindow, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: context.secondaryTextColor, fontWeight: FontWeight.w600)), if (hasWindow) ...[const SizedBox(height: 3), Text(status, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: active ? color : context.secondaryTextColor, fontWeight: FontWeight.w700))]])), if (hasWindow && countdown.isNotEmpty) ...[const SizedBox(width: 10), Text(countdown, maxLines: 1, textAlign: TextAlign.end, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: color, fontWeight: FontWeight.w800))]]));
  }

  Widget _verticalDivider(BuildContext context) => Container(width: 1, height: 48, color: Theme.of(context).dividerColor.withValues(alpha: .4));

  String _formatTime(DateTime value) { final hour = value.hour == 0 ? 12 : value.hour > 12 ? value.hour - 12 : value.hour; final minute = value.minute.toString().padLeft(2, '0'); final period = value.hour >= 12 ? 'PM' : 'AM'; return '$hour:$minute $period'; }
  String _formatDuration(Duration value) { final h = value.inHours; final m = value.inMinutes.remainder(60); final s = value.inSeconds.remainder(60); return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'; }
  String _normalize(String value) => value.toLowerCase().replaceAll(RegExp(r"[\s’‘']"), '');
  IconData _prayerIcon(String name) { switch (_normalize(name)) { case 'fajr': case 'ফজর': return Icons.wb_twilight_outlined; case 'dhuhr': case 'যোহর': return Icons.wb_sunny_outlined; case 'asr': case 'আসর': return Icons.sunny_snowing; case 'maghrib': case 'মাগরিব': return Icons.nightlight_outlined; case 'isha': case 'ইশা': return Icons.dark_mode_outlined; case 'jumuah': case "জুমু'আ": return Icons.mosque_outlined; default: return Icons.access_time_rounded; } }
  void _showLocation(BuildContext context, String location) { final l10n = AppLocalizations.of(context); showDialog<void>(context: context, builder: (_) => AlertDialog(title: Text(l10n.location), content: Text(_localizedLocation(l10n, location)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close))])); }
  Widget _buildErrorState(BuildContext context, PrayerController controller) { final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final primary = theme.colorScheme.primary; return Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.error_outline_rounded, size: 56, color: primary), const SizedBox(height: 12), Text(l10n.prayerLoadError, textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Text(controller.error!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14)), const SizedBox(height: 18), FilledButton.icon(onPressed: controller.refreshPrayerTimes, icon: const Icon(Icons.refresh_rounded), label: Text(l10n.retry))]))); }
}

class _NaflItem {
  final String name;
  final String window;
  final DateTime? start;
  final DateTime? end;
  final IconData icon;
  const _NaflItem(this.name, this.window, this.start, this.end, this.icon);
}
