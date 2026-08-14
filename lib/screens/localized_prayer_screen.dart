import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../localization/app_localizations.dart';
import '../localization/app_localizations_x.dart';
import '../theme/app_theme.dart';

/// App-language aware Prayer screen.
/// Keeps the existing offline prayer engine/controller as the single source
/// of truth; this widget only localizes the presentation layer.
class LocalizedPrayerScreen extends StatefulWidget {
  const LocalizedPrayerScreen({super.key});

  @override
  State<LocalizedPrayerScreen> createState() => _LocalizedPrayerScreenState();
}

class _LocalizedPrayerScreenState extends State<LocalizedPrayerScreen> {
  final Map<String, bool> _tracker = <String, bool>{
    'ফজর': false,
    'যোহর': false,
    'আসর': false,
    'মাগরিব': false,
    'ইশা': false,
    "জুমু'আ": false,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<PrayerController>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final friday = DateTime.now().weekday == DateTime.friday;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prayer, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: l10n.locationTooltip,
            onPressed: () => _showLocation(context, controller.currentLocationName),
            icon: Icon(Icons.location_on_outlined, color: primary),
          ),
          IconButton(
            tooltip: l10n.refreshTooltip,
            onPressed: controller.loading ? null : controller.refreshPrayerTimes,
            icon: Icon(Icons.refresh_rounded, color: primary),
          ),
        ],
      ),
      body: controller.loading
          ? Center(child: CircularProgressIndicator(color: primary))
          : controller.error != null
              ? _errorState(context, controller)
              : RefreshIndicator(
                  color: primary,
                  onRefresh: controller.refreshPrayerTimes,
                  child: ListView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      _locationCard(context, controller.currentLocationName),
                      const SizedBox(height: 14),
                      _currentCard(context, controller, friday),
                      const SizedBox(height: 14),
                      _summaryCard(context, controller),
                      const SizedBox(height: 14),
                      _importantTimes(context, controller),
                      const SizedBox(height: 22),
                      _sectionTitle(context, l10n.todaysPrayer, l10n.fullPrayerSchedule, Icons.mosque_outlined),
                      const SizedBox(height: 10),
                      ...controller.prayers.map((p) => _prayerTile(context, p, friday)),
                      const SizedBox(height: 12),
                      _sectionTitle(context, l10n.naflTitle, l10n.naflSubtitle, Icons.auto_awesome_outlined),
                      const SizedBox(height: 10),
                      _naflSection(context, controller),
                      const SizedBox(height: 12),
                      _sectionTitle(context, l10n.trackerTitle, l10n.trackerSubtitle, Icons.check_circle_outline_rounded),
                      const SizedBox(height: 10),
                      _trackerCard(context, friday),
                      const SizedBox(height: 20),
                      _footer(context),
                    ],
                  ),
                ),
    );
  }

  Widget _locationCard(BuildContext context, String location) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    return _card(
      context,
      child: Row(
        children: [
          _iconBox(primary, Icons.location_on_rounded),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.location, style: TextStyle(color: context.secondaryTextColor, fontSize: 12)),
              const SizedBox(height: 2),
              Text(location.isEmpty ? l10n.unknownLocation : location, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _currentCard(BuildContext context, PrayerController c, bool friday) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    return _card(
      context,
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(children: [
          _iconBox(primary, Icons.mosque_rounded, size: 46),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.currentPrayerLabel, style: TextStyle(color: context.secondaryTextColor, fontSize: 12)),
            const SizedBox(height: 2),
            Text(l10n.prayerName(c.currentPrayer), maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ])),
          if (friday) _badge(primary, l10n.fridayLabel),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _mini(context, Icons.play_arrow_rounded, l10n.startLabel, c.currentPrayerStart)),
          const SizedBox(width: 10),
          Expanded(child: _mini(context, Icons.stop_rounded, l10n.endLabel, c.currentPrayerEnd)),
          const SizedBox(width: 10),
          Expanded(child: _mini(context, Icons.groups_rounded, l10n.jamaatLabel, c.currentIqamahTime)),
        ]),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(value: c.prayerProgress.clamp(0.0, 1.0), minHeight: 8, backgroundColor: primary.withValues(alpha: .10)),
        ),
        const SizedBox(height: 9),
        Row(children: [Icon(Icons.timelapse_rounded, size: 17, color: primary), const SizedBox(width: 6), Expanded(child: Text(c.prayerStatus, style: const TextStyle(fontWeight: FontWeight.w600)))]),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(color: primary.withValues(alpha: .06), borderRadius: BorderRadius.circular(15)),
          child: Row(children: [
            Icon(Icons.schedule_rounded, size: 19, color: primary),
            const SizedBox(width: 9),
            Expanded(child: Text('${l10n.nextLabel}: ${l10n.prayerName(c.nextPrayerName)}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
            const SizedBox(width: 8),
            Text(c.nextPrayerTime, style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Flexible(child: Text(c.timeRemainingForNextPrayer, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.secondaryTextColor, fontSize: 12))),
          ]),
        ),
      ]),
    );
  }

  Widget _summaryCard(BuildContext context, PrayerController c) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    return _card(context, child: Column(children: [
      Row(children: [Icon(Icons.access_time_rounded, color: primary, size: 20), const SizedBox(width: 8), Text(l10n.prayerTimeLabel, style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Flexible(child: Text('${l10n.nextLabel} ${l10n.prayerName(c.nextPrayerName)}', overflow: TextOverflow.ellipsis, style: TextStyle(color: context.secondaryTextColor, fontSize: 12)))]),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _timeBox(context, l10n.previousLabel, c.previousPrayer, c.previousPrayerTime, Icons.history_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _timeBox(context, l10n.currentLabel, c.currentPrayer, c.currentPrayerStart, Icons.mosque_outlined)),
        const SizedBox(width: 10),
        Expanded(child: _timeBox(context, l10n.nextLabel, c.nextPrayerName, c.nextPrayerTime, Icons.arrow_forward_rounded)),
      ]),
    ]));
  }

  Widget _importantTimes(BuildContext context, PrayerController c) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    return _card(context, child: Column(children: [
      Row(children: [Icon(Icons.wb_twilight_rounded, color: primary, size: 21), const SizedBox(width: 8), Text(l10n.todayImportantTimes, style: const TextStyle(fontWeight: FontWeight.bold))]),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _dailyTime(context, Icons.wb_sunny_outlined, l10n.sunrise, c.sunriseTime, primary)),
        _divider(context),
        Expanded(child: _dailyTime(context, Icons.light_mode_outlined, l10n.solarNoonLabel, c.solarNoonTime, primary)),
        _divider(context),
        Expanded(child: _dailyTime(context, Icons.nights_stay_outlined, l10n.sunset, c.sunsetTime, primary)),
      ]),
      const SizedBox(height: 14),
      _special(context, Icons.warning_amber_rounded, l10n.makruhLabel, c.makruhTimeText),
      const SizedBox(height: 8),
      _special(context, Icons.block_rounded, l10n.prohibitedLabel, c.prohibitedTimeText),
    ]));
  }

  Widget _prayerTile(BuildContext context, Map<String, dynamic> p, bool friday) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final nameRaw = p['nameBn']?.toString() ?? p['name']?.toString() ?? '';
    final current = p['isCurrent'] == true;
    final name = l10n.prayerName(nameRaw);
    final start = p['start']?.toString() ?? '';
    final end = p['end']?.toString() ?? '';
    final jamaat = p['jamaat']?.toString() ?? '';
    final isJumuah = friday && (nameRaw == "জুমু'আ" || nameRaw == 'জুমু‘আ');
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: current ? primary.withValues(alpha: .07) : context.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: current ? primary.withValues(alpha: .18) : primary.withValues(alpha: .06))),
      child: Row(children: [
        _iconBox(current ? primary : context.secondaryTextColor, isJumuah ? Icons.groups_rounded : Icons.access_time_rounded, size: 42),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Flexible(child: Text(name, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: current ? FontWeight.bold : FontWeight.w600, color: current ? primary : null))), if (current) ...[const SizedBox(width: 7), _badge(primary, l10n.currentLabel, small: true)]]),
          const SizedBox(height: 4),
          Text('$start - $end', style: TextStyle(color: context.secondaryTextColor, fontSize: 12)),
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(jamaat.isEmpty ? '—' : jamaat, style: TextStyle(color: current ? primary : null, fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(l10n.jamaatLabel, style: TextStyle(fontSize: 9, color: context.secondaryTextColor))]),
      ]),
    );
  }

  Widget _naflSection(BuildContext context, PrayerController c) {
    final l10n = AppLocalizations.of(context);
    return Column(children: [
      _nafl(context, l10n.ishraq, l10n.naflDescription('ishraq'), c.sunriseTime, Icons.wb_sunny_outlined),
      _nafl(context, l10n.duha, l10n.naflDescription('duha'), l10n.tr('সূর্যোদয়ের পর', 'After sunrise'), Icons.wb_sunny_rounded),
      _nafl(context, l10n.awwabin, l10n.naflDescription('awwalabin'), c.sunsetTime, Icons.nightlight_outlined),
      _nafl(context, l10n.tahajjud, l10n.naflDescription('tahajjud'), l10n.tr('শেষ তৃতীয়াংশ', 'Last third of the night'), Icons.nights_stay_rounded),
    ]);
  }

  Widget _nafl(BuildContext context, String title, String description, String time, IconData icon) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(17), border: Border.all(color: primary.withValues(alpha: .06))), child: Row(children: [Icon(icon, color: primary, size: 21), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(description, style: TextStyle(color: context.secondaryTextColor, fontSize: 12))])), const SizedBox(width: 8), Flexible(child: Text(time, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 12)))]));
  }

  Widget _trackerCard(BuildContext context, bool friday) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final names = friday ? <String>['ফজর', "জুমু'আ", 'আসর', 'মাগরিব', 'ইশা'] : <String>['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'ইশা'];
    return _card(context, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: names.map((raw) {
      final done = _tracker[raw] ?? false;
      return GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _tracker[raw] = !done), child: Column(children: [AnimatedContainer(duration: const Duration(milliseconds: 220), width: 40, height: 40, decoration: BoxDecoration(color: done ? primary : primary.withValues(alpha: .08), shape: BoxShape.circle), child: Icon(done ? Icons.check_rounded : Icons.circle_outlined, color: done ? Colors.white : primary, size: 20)), const SizedBox(height: 6), Text(l10n.prayerTrackerName(raw), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]));
    }).toList()));
  }

  Widget _sectionTitle(BuildContext context, String title, String subtitle, IconData icon) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(children: [_iconBox(primary, icon, size: 36), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 1), Text(subtitle, style: TextStyle(color: context.secondaryTextColor, fontSize: 12))]))]);
  }

  Widget _mini(BuildContext context, IconData icon, String title, String value) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10), decoration: BoxDecoration(color: primary.withValues(alpha: .055), borderRadius: BorderRadius.circular(14)), child: Column(children: [Icon(icon, color: primary, size: 17), const SizedBox(height: 4), Text(title, style: TextStyle(fontSize: 9, color: context.secondaryTextColor)), const SizedBox(height: 2), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10))]));
  }

  Widget _timeBox(BuildContext context, String title, String prayer, String time, IconData icon) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(14)), child: Column(children: [Icon(icon, size: 17, color: primary), const SizedBox(height: 4), Text(title, style: TextStyle(fontSize: 9, color: context.secondaryTextColor)), const SizedBox(height: 2), Text(AppLocalizations.of(context).prayerName(prayer), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), const SizedBox(height: 2), Text(time, style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 10))]));
  }

  Widget _dailyTime(BuildContext context, IconData icon, String title, String value, Color color) => Column(children: [Icon(icon, color: color, size: 21), const SizedBox(height: 5), Text(title, style: TextStyle(color: context.secondaryTextColor, fontSize: 10)), const SizedBox(height: 2), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))]);

  Widget _special(BuildContext context, IconData icon, String title, String value) => Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .05), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(icon, color: Theme.of(context).colorScheme.primary, size: 17), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), const SizedBox(width: 8), Expanded(child: Text(value, textAlign: TextAlign.end, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.secondaryTextColor, fontSize: 10)))]));

  Widget _footer(BuildContext context) => _card(context, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline_rounded, size: 18, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 9), Expanded(child: Text(AppLocalizations.of(context).prayerTimeNote, style: TextStyle(color: context.secondaryTextColor, height: 1.4, fontSize: 11)))]));

  Widget _errorState(BuildContext context, PrayerController c) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline_rounded, size: 54, color: Colors.redAccent), const SizedBox(height: 14), Text(AppLocalizations.of(context).prayerLoadFailed, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(c.error ?? AppLocalizations.of(context).unknownProblem, textAlign: TextAlign.center, style: TextStyle(color: context.secondaryTextColor, fontSize: 12)), const SizedBox(height: 18), FilledButton.icon(onPressed: c.refreshPrayerTimes, icon: const Icon(Icons.refresh_rounded), label: Text(AppLocalizations.of(context).tryAgainLabel))])));

  void _showLocation(BuildContext context, String location) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Row(children: [const Icon(Icons.location_on_rounded, color: Colors.white), const SizedBox(width: 8), Expanded(child: Text(location.isEmpty ? AppLocalizations.of(context).unknownLocation : location, maxLines: 2, overflow: TextOverflow.ellipsis))]), duration: const Duration(seconds: 3)));
  }

  Widget _card(BuildContext context, {required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(17), double radius = 22}) => Container(padding: padding, decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(radius), border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .08))), child: child);

  Widget _iconBox(Color color, IconData icon, {double size = 38}) => Container(width: size, height: size, decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(size * .30)), child: Icon(icon, color: color, size: size * .52));

  Widget _badge(Color color, String text, {bool small = false}) => Container(padding: EdgeInsets.symmetric(horizontal: small ? 7 : 9, vertical: small ? 2 : 5), decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(20)), child: Text(text, style: TextStyle(color: color, fontSize: small ? 8 : 10, fontWeight: FontWeight.bold)));

  Widget _divider(BuildContext context) => Container(width: 1, height: 38, color: Theme.of(context).dividerColor.withValues(alpha: .30));
}
