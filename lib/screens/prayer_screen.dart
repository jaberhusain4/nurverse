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
  final Map<String, bool> _prayerTracker = {'ফজর': false, 'যোহর': false, 'আসর': false, 'মাগরিব': false, 'ইশা': false, "জুমু'আ": false};

  String _prayerLabel(AppLocalizations l10n, String value) {
    switch (value.trim().toLowerCase()) {
      case 'ফজর': case 'fajr': return l10n.fajr;
      case 'যোহর': case 'dhuhr': return l10n.dhuhr;
      case 'আসর': case 'asr': return l10n.asr;
      case 'মাগরিব': case 'maghrib': return l10n.maghrib;
      case 'ইশা': case 'isha': return l10n.isha;
      case "জুমু'আ": case 'জুমু‘আ': case 'jumuah': case 'jumu’ah': return l10n.jumuah;
      case 'তাহাজ্জুদ': case 'tahajjud': return l10n.tahajjud;
      case 'ইশরাক': case 'ishraq': return l10n.ishraq;
      case 'চাশত / দুহা': case 'দুহা': case 'duha': return l10n.duha;
      case 'আউওয়াবীন': case 'awwabin': return l10n.awwabin;
      default: return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final controller = context.watch<PrayerController>(); final primary = theme.colorScheme.primary; final isFriday = DateTime.now().weekday == DateTime.friday;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.prayer, style: const TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, elevation: 0, actions: [
        IconButton(tooltip: l10n.location, onPressed: () => _showLocation(context, controller.currentLocationName), icon: Icon(Icons.location_on_outlined, color: primary)),
        IconButton(tooltip: l10n.refresh, onPressed: controller.loading ? null : controller.refreshPrayerTimes, icon: Icon(Icons.refresh_rounded, color: primary)),
      ]),
      body: controller.loading ? Center(child: CircularProgressIndicator(color: primary)) : controller.error != null ? _buildErrorState(context, controller) : RefreshIndicator(color: primary, onRefresh: controller.refreshPrayerTimes, child: ListView(physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()), padding: const EdgeInsets.fromLTRB(16, 8, 16, 28), children: [
        _buildLocationCard(context, controller.currentLocationName), const SizedBox(height: 14), _buildCurrentPrayerCard(context, controller, isFriday), const SizedBox(height: 14), _buildPrayerTimeSummary(context, controller), const SizedBox(height: 14), _buildDailyTimeCard(context, controller), const SizedBox(height: 22), _buildSectionTitle(context, l10n.todaysPrayer, l10n.fullPrayerSchedule, Icons.mosque_outlined), const SizedBox(height: 10), _buildPrayerSchedule(context, controller), const SizedBox(height: 22), _buildSectionTitle(context, l10n.naflAndOtherPrayers, l10n.optionalWorshipTimes, Icons.auto_awesome_outlined), const SizedBox(height: 10), _buildNaflSection(context, controller), const SizedBox(height: 22), _buildSectionTitle(context, l10n.prayerTracker, l10n.markPrayers, Icons.check_circle_outline_rounded), const SizedBox(height: 10), _buildPrayerTracker(context, isFriday), const SizedBox(height: 20), _buildFooterNote(context),
      ])),
    );
  }

  Widget _buildLocationCard(BuildContext context, String location) {
    final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final primary = theme.colorScheme.primary;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: primary.withValues(alpha: .08))), child: Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.location_on_rounded, color: primary, size: 20)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.location, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: context.secondaryTextColor)), const SizedBox(height: 2), Text(location.isEmpty ? l10n.locationUnavailable : location, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 14))]))]));
  }

  Widget _buildCurrentPrayerCard(BuildContext context, PrayerController controller, bool isFriday) {
    final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final primary = theme.colorScheme.primary;
    return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: primary.withValues(alpha: .10)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 20, offset: const Offset(0, 8))]), child: Column(children: [Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.mosque_rounded, color: primary, size: 24)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.currentPrayer, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: context.secondaryTextColor)), const SizedBox(height: 2), Text(_prayerLabel(l10n, controller.currentPrayer), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))])), if (isFriday) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(20)), child: Text(l10n.friday, style: TextStyle(color: primary, fontSize: 14, fontWeight: FontWeight.bold))) ]), const SizedBox(height: 18), Row(children: [Expanded(child: _buildMiniInfo(context, icon: Icons.play_arrow_rounded, title: l10n.start, value: controller.currentPrayerStart)), const SizedBox(width: 10), Expanded(child: _buildMiniInfo(context, icon: Icons.stop_rounded, title: l10n.end, value: controller.currentPrayerEnd)), const SizedBox(width: 10), Expanded(child: _buildMiniInfo(context, icon: Icons.groups_rounded, title: l10n.jamaat, value: controller.currentIqamahTime))]), const SizedBox(height: 18), ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: controller.prayerProgress.clamp(0.0, 1.0), minHeight: 8, backgroundColor: primary.withValues(alpha: .10), valueColor: AlwaysStoppedAnimation<Color>(primary))), const SizedBox(height: 10), Row(children: [Icon(Icons.timelapse_rounded, size: 18, color: primary), const SizedBox(width: 7), Expanded(child: Text(controller.prayerStatus, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w600)))]), const SizedBox(height: 15), Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: primary.withValues(alpha: .06), borderRadius: BorderRadius.circular(15)), child: Row(children: [Icon(Icons.schedule_rounded, size: 19, color: primary), const SizedBox(width: 9), Expanded(child: Text('${l10n.next}: ${_prayerLabel(l10n, controller.nextPrayerName)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w600))), const SizedBox(width: 12), Text(controller.nextPrayerTime, maxLines: 1, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: primary, fontWeight: FontWeight.bold)), const SizedBox(width: 12), Flexible(child: Text(controller.timeRemainingForNextPrayer, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: context.secondaryTextColor, fontWeight: FontWeight.w600)))]))]));
  }

  Widget _buildPrayerTimeSummary(BuildContext context, PrayerController controller) {
    final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final primary = theme.colorScheme.primary;
    return Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: primary.withValues(alpha: .08))), child: Column(children: [Row(children: [Icon(Icons.access_time_rounded, color: primary, size: 20), const SizedBox(width: 8), Text(l10n.prayerTimes, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 16)), const Spacer(), Flexible(child: Text('${l10n.next} ${_prayerLabel(l10n, controller.nextPrayerName)}', overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: context.secondaryTextColor)))]), const SizedBox(height: 14), Row(children: [Expanded(child: _buildTimeBox(context, l10n.previousPrayer, controller.previousPrayer, controller.previousPrayerTime, Icons.history_rounded)), const SizedBox(width: 10), Expanded(child: _buildTimeBox(context, l10n.current, controller.currentPrayer, controller.currentPrayerStart, Icons.mosque_outlined)), const SizedBox(width: 10), Expanded(child: _buildTimeBox(context, l10n.next, controller.nextPrayerName, controller.nextPrayerTime, Icons.arrow_forward_rounded))]) ]));
  }

  Widget _buildDailyTimeCard(BuildContext context, PrayerController controller) {
    final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final primary = theme.colorScheme.primary;
    return Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: primary.withValues(alpha: .08))), child: Column(children: [Row(children: [Icon(Icons.wb_twilight_rounded, color: primary, size: 21), const SizedBox(width: 8), Text(l10n.importantTimes, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 16))]), const SizedBox(height: 14), Row(children: [Expanded(child: _buildDailyTimeItem(context, Icons.wb_sunny_outlined, l10n.sunrise, controller.sunriseTime, primary)), _verticalDivider(context), Expanded(child: _buildDailyTimeItem(context, Icons.light_mode_outlined, l10n.solarNoon, controller.solarNoonTime, primary)), _verticalDivider(context), Expanded(child: _buildDailyTimeItem(context, Icons.nights_stay_outlined, l10n.sunset, controller.sunsetTime, primary))]), const SizedBox(height: 14), _buildSpecialTimeRow(context, Icons.warning_amber_rounded, l10n.makruhTime, controller.makruhTimeText, Colors.orange, controller.makruhStart, controller.makruhEnd), const SizedBox(height: 8), _buildSpecialTimeRow(context, Icons.block_rounded, l10n.prohibitedTime, controller.prohibitedTimeText, Colors.redAccent, controller.prohibitedStart, controller.prohibitedEnd)]));
  }

  Widget _buildSectionTitle(BuildContext context, String title, String subtitle, IconData icon) { final theme = Theme.of(context); final primary = theme.colorScheme.primary; return Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: primary, size: 20)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 1), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: context.secondaryTextColor, fontSize: 13))])]); }

  Widget _buildPrayerSchedule(BuildContext context, PrayerController controller) {
    final prayers = controller.prayers;
    return Container(decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .08))), child: Column(children: [for (var i = 0; i < prayers.length; i++) ...[_buildPrayerRow(context, controller, prayers[i]), if (i != prayers.length - 1) Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: .5))]]));
  }

  Widget _buildPrayerRow(BuildContext context, PrayerController controller, Map<String, dynamic> prayer) {
    final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final primary = theme.colorScheme.primary; final rawName = prayer['name']?.toString() ?? ''; final name = _prayerLabel(l10n, rawName); final time = prayer['time']?.toString() ?? '--:--'; final jamaat = prayer['jamaat']?.toString() ?? '--:--'; final isCurrent = _normalize(rawName) == _normalize(controller.currentPrayer);
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: isCurrent ? primary.withValues(alpha: .12) : primary.withValues(alpha: .06), borderRadius: BorderRadius.circular(12)), child: Icon(_prayerIcon(rawName), color: primary, size: 20)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600, fontSize: 15)), const SizedBox(height: 2), Text(isCurrent ? l10n.current : l10n.start, style: theme.textTheme.bodySmall?.copyWith(color: context.secondaryTextColor, fontSize: 13))])), Text(time, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(width: 14), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(l10n.jamaat, style: theme.textTheme.bodySmall?.copyWith(color: context.secondaryTextColor, fontSize: 13)), Text(jamaat, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 14))])]));
  }

  Widget _buildNaflSection(BuildContext context, PrayerController controller) {
    final items = <_NaflItem>[
      _NaflItem(AppLocalizations.of(context).ishraq, controller.ishraqTime, controller.ishraqStart, controller.ishraqEnd, Icons.wb_sunny_outlined),
      _NaflItem(AppLocalizations.of(context).duha, controller.duhaTime, controller.duhaStart, controller.duhaEnd, Icons.wb_twilight_rounded),
      _NaflItem(AppLocalizations.of(context).awwabin, controller.awwabinTime, controller.awwabinStart, controller.awwabinEnd, Icons.nights_stay_outlined),
      _NaflItem(AppLocalizations.of(context).tahajjud, controller.tahajjudTime, controller.tahajjudStart, controller.tahajjudEnd, Icons.bedtime_outlined),
    ];
    return Column(children: [for (final item in items) ...[_buildNaflCard(context, item), const SizedBox(height: 9)]]);
  }

  Widget _buildNaflCard(BuildContext context, _NaflItem item) {
    final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final primary = theme.colorScheme.primary; final now = DateTime.now(); final active = !now.isBefore(item.start) && now.isBefore(item.end); final upcoming = now.isBefore(item.start); final status = active ? l10n.current : upcoming ? l10n.next : l10n.completed; final target = upcoming ? item.start : item.end; final timer = _formatDuration(target.difference(now).isNegative ? Duration.zero : target.difference(now));
    return Container(padding: const EdgeInsets.fromLTRB(14, 13, 14, 13), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: active ? primary.withValues(alpha: .22) : primary.withValues(alpha: .08))), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(13)), child: Icon(item.icon, color: primary, size: 21)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(item.window, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13, color: context.secondaryTextColor)), const SizedBox(height: 3), Text(status, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontSize: 13, color: active ? primary : context.secondaryTextColor, fontWeight: FontWeight.w700))])), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(_formatTime(item.start), style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(timer, maxLines: 1, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: primary, fontWeight: FontWeight.w800))])]));
  }

  Widget _buildPrayerTracker(BuildContext context, bool isFriday) {
    final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final primary = theme.colorScheme.primary; final entries = isFriday ? <String>[..._prayerTracker.keys] : _prayerTracker.keys.where((key) => key != "জুমু'আ").toList();
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: primary.withValues(alpha: .08))), child: Wrap(spacing: 8, runSpacing: 8, children: entries.map((name) => FilterChip(label: Text(_prayerLabel(l10n, name), style: const TextStyle(fontSize: 14)), selected: _prayerTracker[name] ?? false, onSelected: (value) => setState(() => _prayerTracker[name] = value), selectedColor: primary.withValues(alpha: .14))).toList()));
  }

  Widget _buildFooterNote(BuildContext context) {
    final l10n = AppLocalizations.of(context); return Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(l10n.tr('নামাজের সময় আপনার সংরক্ষিত অবস্থান অনুযায়ী অফলাইনে গণনা করা হয়.', 'Prayer times are calculated offline based on your saved location.'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13, color: context.secondaryTextColor)));
  }

  Widget _buildMiniInfo(BuildContext context, {required IconData icon, required String title, required String value}) { final theme = Theme.of(context); final primary = theme.colorScheme.primary; return Column(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: primary, size: 18)), const SizedBox(height: 6), Text(title, style: theme.textTheme.bodySmall?.copyWith(fontSize: 13, color: context.secondaryTextColor, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold))]); }

  Widget _buildTimeBox(BuildContext context, String label, String prayer, String time, IconData icon) { final theme = Theme.of(context); final primary = theme.colorScheme.primary; final l10n = AppLocalizations.of(context); return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11), decoration: BoxDecoration(color: primary.withValues(alpha: .05), borderRadius: BorderRadius.circular(15)), child: Column(children: [Icon(icon, color: primary, size: 18), const SizedBox(height: 5), Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontSize: 13, color: context.secondaryTextColor)), const SizedBox(height: 3), Text(_prayerLabel(l10n, prayer), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(time, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold))])); }

  Widget _buildDailyTimeItem(BuildContext context, IconData icon, String title, String value, Color color) { final theme = Theme.of(context); return Column(children: [Icon(icon, color: color, size: 21), const SizedBox(height: 6), Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontSize: 13, color: context.secondaryTextColor)), const SizedBox(height: 3), Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold))]); }

  Widget _buildSpecialTimeRow(BuildContext context, IconData icon, String title, String fallbackValue, Color color, DateTime? start, DateTime? end) {
    final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final now = DateTime.now();
    final hasWindow = start != null && end != null && end.isAfter(start);
    final active = hasWindow && !now.isBefore(start) && now.isBefore(end);
    final upcoming = hasWindow && now.isBefore(start);
    final status = active ? l10n.current : upcoming ? l10n.next : l10n.completed;
    final target = upcoming ? start : end;
    final remaining = target == null ? null : target.difference(now);
    final countdown = remaining == null ? '' : _formatDuration(remaining.isNegative ? Duration.zero : remaining);
    final exactWindow = hasWindow ? '${_formatTime(start!)} – ${_formatTime(end!)}' : fallbackValue;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: color.withValues(alpha: .07), borderRadius: BorderRadius.circular(14)), child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(exactWindow, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13, color: context.secondaryTextColor, fontWeight: FontWeight.w600)), if (hasWindow) ...[const SizedBox(height: 3), Text(status, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13, color: active ? color : context.secondaryTextColor, fontWeight: FontWeight.w700))]])), if (hasWindow && countdown.isNotEmpty) ...[const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(countdown, maxLines: 1, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: color, fontWeight: FontWeight.w800))])]]));
  }

  Widget _verticalDivider(BuildContext context) => Container(width: 1, height: 48, color: Theme.of(context).dividerColor.withValues(alpha: .4));

  String _formatTime(DateTime value) { final hour = value.hour == 0 ? 12 : value.hour > 12 ? value.hour - 12 : value.hour; final minute = value.minute.toString().padLeft(2, '0'); final period = value.hour >= 12 ? 'PM' : 'AM'; return '$hour:$minute $period'; }
  String _formatDuration(Duration value) { final h = value.inHours; final m = value.inMinutes.remainder(60); final s = value.inSeconds.remainder(60); return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'; }
  String _normalize(String value) => value.toLowerCase().replaceAll(RegExp(r'[\s’‘\']'), '');
  IconData _prayerIcon(String name) { switch (_normalize(name)) { case 'fajr': case 'ফজর': return Icons.wb_twilight_outlined; case 'dhuhr': case 'যোহর': return Icons.wb_sunny_outlined; case 'asr': case 'আসর': return Icons.sunny_snowing; case 'maghrib': case 'মাগরিব': return Icons.nightlight_outlined; case 'isha': case 'ইশা': return Icons.dark_mode_outlined; case 'jumuah': case "জুমু'আ": return Icons.mosque_outlined; default: return Icons.access_time_rounded; } }
  void _showLocation(BuildContext context, String location) { final l10n = AppLocalizations.of(context); showDialog<void>(context: context, builder: (_) => AlertDialog(title: Text(l10n.location), content: Text(location.isEmpty ? l10n.locationUnavailable : location), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close))])); }
  Widget _buildErrorState(BuildContext context, PrayerController controller) { final theme = Theme.of(context); final l10n = AppLocalizations.of(context); final primary = theme.colorScheme.primary; return Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.error_outline_rounded, size: 56, color: primary), const SizedBox(height: 12), Text(l10n.prayerLoadError, textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Text(controller.error!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14)), const SizedBox(height: 18), FilledButton.icon(onPressed: controller.refreshPrayerTimes, icon: const Icon(Icons.refresh_rounded), label: Text(l10n.retry))]))); }
}

class _NaflItem { final String name; final String window; final DateTime start; final DateTime end; final IconData icon; const _NaflItem(this.name, this.window, this.start, this.end, this.icon); }
