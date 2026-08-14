// lib/screens/prayer_screen.dart

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
      case 'aw w a bin':
      case 'aw wabin':
      case 'awwabin':
        return l10n.awwabin;
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
          IconButton(
            tooltip: l10n.location,
            onPressed: () => _showLocation(context, controller.currentLocationName),
            icon: Icon(Icons.location_on_outlined, color: primary),
          ),
          IconButton(
            tooltip: l10n.refresh,
            onPressed: controller.loading ? null : controller.refreshPrayerTimes,
            icon: Icon(Icons.refresh_rounded, color: primary),
          ),
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
                      _buildPrayerSchedule(context, controller, isFriday),
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
          Text(l10n.location, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor)),
          const SizedBox(height: 2),
          Text(location.isEmpty ? l10n.locationUnavailable : location, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
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
            Text(l10n.currentPrayer, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor)),
            const SizedBox(height: 2),
            Text(_prayerLabel(l10n, controller.currentPrayer), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ])),
          if (isFriday) Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(20)),
            child: Text(l10n.friday, style: TextStyle(color: primary, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
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
        Row(children: [
          Icon(Icons.timelapse_rounded, size: 18, color: primary),
          const SizedBox(width: 7),
          Expanded(child: Text(controller.prayerStatus, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: primary.withValues(alpha: .06), borderRadius: BorderRadius.circular(15)),
          child: Row(children: [
            Icon(Icons.schedule_rounded, size: 19, color: primary),
            const SizedBox(width: 9),
            Expanded(child: Text('${l10n.next}: ${_prayerLabel(l10n, controller.nextPrayerName)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
            const SizedBox(width: 12),
            Text(controller.nextPrayerTime, maxLines: 1, style: theme.textTheme.bodyMedium?.copyWith(color: primary, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Flexible(child: Text(controller.timeRemainingForNextPrayer, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor, fontWeight: FontWeight.w600))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildPrayerTimeSummary(BuildContext context, PrayerController controller) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: primary.withValues(alpha: .08))),
      child: Column(children: [
        Row(children: [Icon(Icons.access_time_rounded, color: primary, size: 20), const SizedBox(width: 8), Text(l10n.prayerTimes, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)), const Spacer(), Flexible(child: Text('${l10n.next} ${_prayerLabel(l10n, controller.nextPrayerName)}', overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor)))]),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: primary.withValues(alpha: .08))),
      child: Column(children: [
        Row(children: [Icon(Icons.wb_twilight_rounded, color: primary, size: 21), const SizedBox(width: 8), Text(l10n.importantTimes, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _buildDailyTimeItem(context, Icons.wb_sunny_outlined, l10n.sunrise, controller.sunriseTime, primary)),
          _verticalDivider(context),
          Expanded(child: _buildDailyTimeItem(context, Icons.light_mode_outlined, l10n.solarNoon, controller.solarNoonTime, primary)),
          _verticalDivider(context),
          Expanded(child: _buildDailyTimeItem(context, Icons.nights_stay_outlined, l10n.sunset, controller.sunsetTime, primary)),
        ]),
        const SizedBox(height: 14),
        _buildSpecialTimeRow(context, Icons.warning_amber_rounded, l10n.makruhTime, controller.makruhTimeText, Colors.orange),
        const SizedBox(height: 8),
        _buildSpecialTimeRow(context, Icons.block_rounded, l10n.prohibitedTime, controller.prohibitedTimeText, Colors.redAccent),
      ]),
    );
  }

  Widget _buildPrayerSchedule(BuildContext context, PrayerController controller, bool isFriday) {
    final l10n = AppLocalizations.of(context);
    return Column(children: controller.prayers.map((prayer) {
      final isCurrent = prayer['isCurrent'] == true;
      final name = prayer['nameBn']?.toString() ?? prayer['name']?.toString() ?? '';
      return _buildPrayerTile(context, name: name, start: prayer['start']?.toString() ?? '', end: prayer['end']?.toString() ?? '', jamaat: prayer['jamaat']?.toString() ?? '', isCurrent: isCurrent, isFriday: isFriday && (name == "জুমু'আ" || name == 'জুমু‘আ'));
    }).toList());
  }

  Widget _buildPrayerTile(BuildContext context, {required String name, required String start, required String end, required String jamaat, required bool isCurrent, required bool isFriday}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: isCurrent ? primary.withValues(alpha: .07) : context.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: isCurrent ? primary.withValues(alpha: .18) : primary.withValues(alpha: .06))),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: isCurrent ? primary.withValues(alpha: .12) : theme.dividerColor.withValues(alpha: .30), borderRadius: BorderRadius.circular(13)), child: Icon(isFriday ? Icons.groups_rounded : Icons.access_time_rounded, size: 20, color: isCurrent ? primary : context.secondaryTextColor)),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(_prayerLabel(l10n, name), overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600, color: isCurrent ? primary : null))),
            if (isCurrent) ...[
              const SizedBox(width: 7),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(20)), child: Text(l10n.current, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 4),
          Text('$start - $end', style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor)),
        ])),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(jamaat.isEmpty ? '—' : jamaat, style: theme.textTheme.titleSmall?.copyWith(color: isCurrent ? primary : null, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(l10n.jamaat, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor)),
        ]),
      ]),
    );
  }

  Widget _buildNaflSection(BuildContext context, PrayerController controller) {
    final l10n = AppLocalizations.of(context);
    return Column(children: [
      _buildNaflTile(context, l10n.ishraq, l10n.isBangla ? 'সূর্যোদয়ের কিছুক্ষণ পর' : 'Shortly after sunrise', controller.sunriseTime, Icons.wb_sunny_outlined),
      _buildNaflTile(context, l10n.duha, l10n.isBangla ? 'সকাল থেকে দুপুরের পূর্ব পর্যন্ত' : 'Morning until before noon', 'সূর্যোদয়ের পর', Icons.wb_sunny_rounded),
      _buildNaflTile(context, l10n.awwabin, l10n.isBangla ? 'মাগরিবের পর' : 'After Maghrib', controller.sunsetTime, Icons.nightlight_outlined),
      _buildNaflTile(context, l10n.tahajjud, l10n.isBangla ? 'রাতের শেষাংশ' : 'Last part of the night', l10n.isBangla ? 'শেষ তৃতীয়াংশ' : 'Last third', Icons.nights_stay_rounded),
    ]);
  }

  Widget _buildNaflTile(BuildContext context, String title, String description, String time, IconData icon) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(17), border: Border.all(color: primary.withValues(alpha: .06))),
      child: Row(children: [
        Icon(icon, color: primary, size: 21),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor))])),
        const SizedBox(width: 8),
        Flexible(child: Text(time, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(color: primary, fontWeight: FontWeight.bold))),
      ]),
    );
  }

  Widget _buildPrayerTracker(BuildContext context, bool isFriday) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context);
    final prayers = isFriday ? ['ফজর', "জুমু'আ", 'আসর', 'মাগরিব', 'ইশা'] : ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'ইশা'];
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: primary.withValues(alpha: .08))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: prayers.map((prayer) {
        final isDone = _prayerTracker[prayer] ?? false;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _prayerTracker[prayer] = !isDone),
          child: Column(children: [
            AnimatedContainer(duration: const Duration(milliseconds: 220), width: 40, height: 40, decoration: BoxDecoration(color: isDone ? primary : primary.withValues(alpha: .08), shape: BoxShape.circle), child: Icon(isDone ? Icons.check_rounded : Icons.circle_outlined, color: isDone ? Colors.white : primary, size: 20)),
            const SizedBox(height: 6),
            Text(_prayerLabel(l10n, prayer), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ]),
        );
      }).toList()),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: primary.withValues(alpha: .09), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: primary, size: 19)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor))])),
    ]);
  }

  Widget _buildMiniInfo(BuildContext context, {required IconData icon, required String title, required String value}) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
      decoration: BoxDecoration(color: primary.withValues(alpha: .055), borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Icon(icon, color: primary, size: 17),
        const SizedBox(height: 5),
        Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor)),
        const SizedBox(height: 2),
        Text(value, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildTimeBox(BuildContext context, String title, String prayer, String time, IconData icon) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Icon(icon, size: 17, color: primary),
        const SizedBox(height: 5),
        Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor)),
        const SizedBox(height: 2),
        Text(_prayerLabel(l10n, prayer), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(time, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(color: primary, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildDailyTimeItem(BuildContext context, IconData icon, String title, String value, Color color) {
    final theme = Theme.of(context);
    return Column(children: [
      Icon(icon, color: color, size: 21),
      const SizedBox(height: 5),
      Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor)),
      const SizedBox(height: 2),
      Text(value, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildSpecialTimeRow(BuildContext context, IconData icon, String title, String value, Color color) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(color: color.withValues(alpha: .06), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, textAlign: TextAlign.end, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor))),
      ]),
    );
  }

  Widget _verticalDivider(BuildContext context) => Container(width: 1, height: 38, color: Theme.of(context).dividerColor.withValues(alpha: .30));

  Widget _buildErrorState(BuildContext context, PrayerController controller) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final primary = theme.colorScheme.primary;
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline_rounded, size: 54, color: Colors.redAccent),
      const SizedBox(height: 14),
      Text(l10n.prayerLoadError, textAlign: TextAlign.center, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(controller.error ?? l10n.somethingWentWrong, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor)),
      const SizedBox(height: 18),
      ElevatedButton.icon(onPressed: controller.refreshPrayerTimes, icon: const Icon(Icons.refresh_rounded), label: Text(l10n.retry), style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white)),
    ])));
  }

  void _showLocation(BuildContext context, String location) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Row(children: [const Icon(Icons.location_on_rounded, color: Colors.white), const SizedBox(width: 8), Expanded(child: Text(location.isEmpty ? l10n.locationUnavailable : location, maxLines: 2, overflow: TextOverflow.ellipsis))]), duration: const Duration(seconds: 3)));
  }

  Widget _buildFooterNote(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline_rounded, size: 18, color: primary),
        const SizedBox(width: 9),
        Expanded(child: Text(l10n.prayerTimeNote, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor, height: 1.4))),
      ]),
    );
  }
}
