import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/prayer_controller.dart';
import '../localization/app_localizations.dart';
import '../localization/app_localizations_x.dart';
import '../theme/app_theme.dart';

class LocalizedPrayerScreen extends StatefulWidget {
  const LocalizedPrayerScreen({super.key});

  @override
  State<LocalizedPrayerScreen> createState() => _LocalizedPrayerScreenState();
}

class _LocalizedPrayerScreenState extends State<LocalizedPrayerScreen> {
  String _normalizeLocation(String value) {
    var text = value.trim();
    if (text.isEmpty) return '';
    text = text.replaceAll(RegExp(r'\b[2-9CFGHJMPQRVWX]{4,8}\+[2-9CFGHJMPQRVWX]{2,6}\b', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'\s*,\s*,+'), ',');
    text = text.replaceAll(RegExp(r'^\s*,\s*|\s*,\s*\$'), '');
    final parts = text.split(',').map((part) => part.trim()).where((part) => part.isNotEmpty).toList();
    final unique = <String>[];
    for (final part in parts) {
      if (!unique.any((item) => item.toLowerCase() == part.toLowerCase())) unique.add(part);
    }
    return unique.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<PrayerController>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final friday = DateTime.now().weekday == DateTime.friday;
    final location = _normalizeLocation(controller.currentLocationName);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prayer, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(tooltip: l10n.locationTooltip, onPressed: () => _showLocation(context, location), icon: Icon(Icons.location_on_outlined, color: primary, size: 22)),
          IconButton(tooltip: l10n.refreshTooltip, onPressed: controller.loading ? null : controller.refreshPrayerTimes, icon: Icon(Icons.refresh_rounded, color: primary, size: 22)),
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
                      _locationCard(context, location),
                      const SizedBox(height: 12),
                      _currentCard(context, controller, friday),
                      const SizedBox(height: 12),
                      _summaryCard(context, controller),
                      const SizedBox(height: 12),
                      _importantTimes(context, controller),
                      const SizedBox(height: 18),
                      _sectionTitle(context, l10n.todaysPrayer, l10n.fullPrayerSchedule, Icons.mosque_outlined),
                      const SizedBox(height: 8),
                      ...controller.prayers.where((p) => p['category'] == 'obligatory').map((p) => _prayerTile(context, p, friday)),
                      const SizedBox(height: 10),
                      _sectionTitle(context, l10n.naflTitle, l10n.naflSubtitle, Icons.auto_awesome_outlined),
                      const SizedBox(height: 8),
                      _naflSection(context, controller),
                      const SizedBox(height: 10),
                      _sectionTitle(context, l10n.trackerTitle, l10n.trackerSubtitle, Icons.check_circle_outline_rounded),
                      const SizedBox(height: 8),
                      _trackerCard(context, friday),
                      const SizedBox(height: 18),
                      _footer(context),
                    ],
                  ),
                ),
    );
  }

  Widget _locationCard(BuildContext context, String location) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    final value = location.isEmpty ? l10n.unknownLocation : location;
    return _card(context, padding: const EdgeInsets.fromLTRB(14, 11, 14, 11), radius: 19, child: Row(children: [
      _iconBox(primary, Icons.location_on_rounded, size: 38), const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.location, maxLines: 1, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w600, height: 1.0)), const SizedBox(height: 4),
        SizedBox(height: 18, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, maxLines: 1, softWrap: false, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.0)))),
      ])),
    ]));
  }

  Widget _currentCard(BuildContext context, PrayerController c, bool friday) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return _card(context, radius: 22, padding: const EdgeInsets.fromLTRB(15, 14, 15, 13), child: Column(children: [
      Row(children: [
        _iconBox(primary, Icons.mosque_rounded, size: 42), const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.currentPrayerLabel, maxLines: 1, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w600)), const SizedBox(height: 2),
          Text(l10n.prayerName(c.currentPrayer), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.05)),
        ])),
        if (friday) _badge(primary, l10n.fridayLabel),
      ]),
      const SizedBox(height: 13),
      Row(children: [Expanded(child: _mini(context, Icons.play_arrow_rounded, l10n.startLabel, c.currentPrayerStart)), const SizedBox(width: 8), Expanded(child: _mini(context, Icons.stop_rounded, l10n.endLabel, c.currentPrayerEnd)), const SizedBox(width: 8), Expanded(child: _mini(context, Icons.groups_rounded, l10n.jamaatLabel, c.currentIqamahTime))]),
      const SizedBox(height: 12),
      ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: c.prayerProgress.clamp(0.0, 1.0), minHeight: 7, backgroundColor: primary.withValues(alpha: .10))),
      const SizedBox(height: 7),
      Row(children: [Icon(Icons.timelapse_rounded, size: 17, color: primary), const SizedBox(width: 6), Expanded(child: Text(c.prayerStatus, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)))]),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9), decoration: BoxDecoration(color: primary.withValues(alpha: .06), borderRadius: BorderRadius.circular(13)), child: Row(children: [
        Icon(Icons.schedule_rounded, size: 18, color: primary), const SizedBox(width: 7), Expanded(child: Text('${l10n.nextLabel}: ${l10n.prayerName(c.nextPrayerName)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))), const SizedBox(width: 6), Text(c.nextPrayerTime, style: TextStyle(color: primary, fontSize: 13.5, fontWeight: FontWeight.w700)), const SizedBox(width: 6), Flexible(child: Text(c.timeRemainingForNextPrayer, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w600))),
      ])),
    ]));
  }

  Widget _summaryCard(BuildContext context, PrayerController c) {
    final l10n = AppLocalizations.of(context); final primary = Theme.of(context).colorScheme.primary; final secondary = context.secondaryTextColor;
    return _card(context, child: Column(children: [Row(children: [Icon(Icons.access_time_rounded, color: primary, size: 21), const SizedBox(width: 8), Text(l10n.prayerTimeLabel, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)), const Spacer(), Flexible(child: Text('${l10n.nextLabel} ${l10n.prayerName(c.nextPrayerName)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w600)))]), const SizedBox(height: 11), Row(children: [Expanded(child: _timeBox(context, c.previousPrayer, c.previousPrayerTime, Icons.history_rounded, l10n.previousLabel)), const SizedBox(width: 8), Expanded(child: _timeBox(context, c.currentPrayer, c.currentPrayerStart, Icons.mosque_outlined, l10n.currentLabel)), const SizedBox(width: 8), Expanded(child: _timeBox(context, c.nextPrayerName, c.nextPrayerTime, Icons.arrow_forward_rounded, l10n.nextLabel))]) ]));
  }

  Widget _importantTimes(BuildContext context, PrayerController c) {
    final l10n = AppLocalizations.of(context); final primary = Theme.of(context).colorScheme.primary;
    return _card(context, child: Column(children: [Row(children: [Icon(Icons.wb_twilight_rounded, color: primary, size: 21), const SizedBox(width: 8), Text(l10n.todayImportantTimes, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700))]), const SizedBox(height: 12), Row(children: [Expanded(child: _dailyTime(context, Icons.wb_sunny_outlined, l10n.sunrise, c.sunriseTime, primary)), _divider(context), Expanded(child: _dailyTime(context, Icons.light_mode_outlined, l10n.solarNoonLabel, c.solarNoonTime, primary)), _divider(context), Expanded(child: _dailyTime(context, Icons.nights_stay_outlined, l10n.sunset, c.sunsetTime, primary))]), const SizedBox(height: 12), _special(context, Icons.warning_amber_rounded, l10n.makruhLabel, c.makruhTimeText), const SizedBox(height: 7), _special(context, Icons.block_rounded, l10n.prohibitedLabel, c.prohibitedTimeText)]));
  }

  Widget _prayerTile(BuildContext context, Map<String, dynamic> p, bool friday) {
    final l10n = AppLocalizations.of(context); final primary = Theme.of(context).colorScheme.primary; final nameRaw = p['nameBn']?.toString() ?? p['name']?.toString() ?? ''; final current = p['isCurrent'] == true; final name = l10n.prayerName(nameRaw); final start = p['start']?.toString() ?? ''; final end = p['end']?.toString() ?? ''; final jamaat = p['jamaat']?.toString() ?? ''; final isJumuah = friday && (nameRaw == "জুমু'আ" || nameRaw == 'জুমু‘আ' || nameRaw == 'Jumuah');
    return Container(margin: const EdgeInsets.only(bottom: 7), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: current ? primary.withValues(alpha: .07) : context.cardColor, borderRadius: BorderRadius.circular(17), border: Border.all(color: current ? primary.withValues(alpha: .18) : primary.withValues(alpha: .06))), child: Row(children: [_iconBox(current ? primary : context.secondaryTextColor, isJumuah ? Icons.groups_rounded : Icons.access_time_rounded, size: 40), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Flexible(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: current ? FontWeight.w700 : FontWeight.w600, color: current ? primary : null))), if (current) ...[const SizedBox(width: 6), _badge(primary, l10n.currentLabel, small: true)]]), const SizedBox(height: 3), Text('$start - $end', style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5, fontWeight: FontWeight.w600))])), const SizedBox(width: 7), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(jamaat.isEmpty ? '—' : jamaat, style: TextStyle(color: current ? primary : null, fontSize: 12.5, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(l10n.jamaatLabel, style: TextStyle(fontSize: 10.5, color: context.secondaryTextColor, fontWeight: FontWeight.w600))]) ]));
  }

  Widget _naflSection(BuildContext context, PrayerController c) { final l10n = AppLocalizations.of(context); return Column(children: [_nafl(context, l10n.ishraq, l10n.naflDescription('ishraq'), c.sunriseTime, Icons.wb_sunny_outlined), _nafl(context, l10n.duha, l10n.naflDescription('duha'), l10n.tr('সূর্যোদয়ের পর', 'After sunrise'), Icons.wb_sunny_rounded), _nafl(context, l10n.awwabin, l10n.naflDescription('awwalabin'), c.sunsetTime, Icons.nightlight_outlined), _nafl(context, l10n.tahajjud, l10n.naflDescription('tahajjud'), l10n.tr('শেষ তৃতীয়াংশ', 'Last third of the night'), Icons.nights_stay_rounded)]); }
  Widget _nafl(BuildContext context, String title, String description, String time, IconData icon) { final primary = Theme.of(context).colorScheme.primary; final secondary = context.secondaryTextColor; return Container(margin: const EdgeInsets.only(bottom: 7), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: primary.withValues(alpha: .06))), child: Row(children: [Icon(icon, color: primary, size: 22), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w500))])), const SizedBox(width: 8), Flexible(child: Text(time, textAlign: TextAlign.end, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 12.5)))])); }
  Widget _trackerCard(BuildContext context, bool friday) => _PersistentPrayerTrackerCard(friday: friday);

  Widget _card(BuildContext context, {required Widget child, EdgeInsetsGeometry? padding, double radius = 18}) => Container(padding: padding ?? const EdgeInsets.all(14), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(radius), border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .06))), child: child);
  Widget _iconBox(Color color, IconData icon, {double size = 40}) => Container(width: size, height: size, decoration: BoxDecoration(color: color.withValues(alpha: .09), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color, size: size * .5));
  Widget _badge(Color color, String text, {bool small = false}) => Container(padding: EdgeInsets.symmetric(horizontal: small ? 7 : 9, vertical: small ? 3 : 4), decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(20)), child: Text(text, style: TextStyle(color: color, fontSize: small ? 9.5 : 10.5, fontWeight: FontWeight.w700)));
  Widget _mini(BuildContext context, IconData icon, String label, String value) { final primary = Theme.of(context).colorScheme.primary; final secondary = context.secondaryTextColor; return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), decoration: BoxDecoration(color: primary.withValues(alpha: .055), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(icon, size: 16, color: primary), const SizedBox(width: 5), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 9.5, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: primary, fontSize: 11.5, fontWeight: FontWeight.w700))]))])); }
  Widget _timeBox(BuildContext context, String name, String time, IconData icon, String label) { final primary = Theme.of(context).colorScheme.primary; return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9), decoration: BoxDecoration(color: primary.withValues(alpha: .055), borderRadius: BorderRadius.circular(13)), child: Column(children: [Icon(icon, size: 18, color: primary), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 10.5, color: context.secondaryTextColor, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(time, style: TextStyle(fontSize: 11.5, color: primary, fontWeight: FontWeight.w700))])); }
  Widget _dailyTime(BuildContext context, IconData icon, String label, String time, Color primary) => Column(children: [Icon(icon, size: 20, color: primary), const SizedBox(height: 4), Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, color: context.secondaryTextColor, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(time, style: TextStyle(fontSize: 12.5, color: primary, fontWeight: FontWeight.w700))]);
  Widget _divider(BuildContext context) => Container(width: 1, height: 40, color: Theme.of(context).dividerColor);
  Widget _special(BuildContext context, IconData icon, String label, String value) { final primary = Theme.of(context).colorScheme.primary; return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(icon, size: 18, color: primary), const SizedBox(width: 7), Expanded(child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),), const SizedBox(width: 6), Flexible(child: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end, style: TextStyle(fontSize: 11.5, color: context.secondaryTextColor, fontWeight: FontWeight.w600)))])); }
  Widget _sectionTitle(BuildContext context, String title, String subtitle, IconData icon) { final primary = Theme.of(context).colorScheme.primary; return Row(children: [Icon(icon, size: 21, color: primary), const SizedBox(width: 7), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, color: context.secondaryTextColor, fontWeight: FontWeight.w500))])]); }
  Widget _footer(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 2), child: Text(AppLocalizations.of(context).tr('নামাজের সময় স্থানীয় অবস্থান ও গণনা পদ্ধতির ভিত্তিতে পরিবর্তিত হতে পারে।', 'Prayer times may vary by location and calculation method.'), textAlign: TextAlign.center, style: TextStyle(color: context.secondaryTextColor, fontSize: 10.5)));
  Widget _errorState(BuildContext context, PrayerController c) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.error_outline_rounded, size: 48, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 10), Text(c.error ?? '', textAlign: TextAlign.center), const SizedBox(height: 12), FilledButton(onPressed: c.refreshPrayerTimes, child: Text(AppLocalizations.of(context).retry))]));
  void _showLocation(BuildContext context, String location) => showDialog<void>(context: context, builder: (context) => AlertDialog(title: Text(AppLocalizations.of(context).location), content: Text(location), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context).close))]));
}

class _PersistentPrayerTrackerCard extends StatefulWidget {
  final bool friday;
  const _PersistentPrayerTrackerCard({required this.friday});
  @override
  State<_PersistentPrayerTrackerCard> createState() => _PersistentPrayerTrackerCardState();
}

class _PersistentPrayerTrackerCardState extends State<_PersistentPrayerTrackerCard> {
  static const _prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  Map<String, bool> _completed = {for (final p in _prayers) p: false};
  bool _loading = true;

  String _key(DateTime date) => 'prayer_tracker_${date.year}_${date.month}_${date.day}';
  Future<void> _load() async { final prefs = await SharedPreferences.getInstance(); final raw = prefs.getStringList(_key(DateTime.now())) ?? <String>[]; if (!mounted) return; setState(() { _completed = {for (final p in _prayers) p: raw.contains(p)}; _loading = false; }); }
  Future<void> _toggle(String prayer) async { final prefs = await SharedPreferences.getInstance(); final date = DateTime.now(); final next = !(_completed[prayer] ?? false); setState(() => _completed[prayer] = next); final raw = _prayers.where((p) => _completed[p] == true).toList(); await prefs.setStringList(_key(date), raw); }
  String _dateText(BuildContext context, DateTime date, {bool full = false}) { final locale = Localizations.localeOf(context).languageCode; if (locale == 'bn') { final months = ['জানুয়ারি','ফেব্রুয়ারি','মার্চ','এপ্রিল','মে','জুন','জুলাই','আগস্ট','সেপ্টেম্বর','অক্টোবর','নভেম্বর','ডিসেম্বর']; return full ? '${date.day} ${months[date.month - 1]} ${date.year}' : '${date.day} ${months[date.month - 1]}'; } return DateFormat(full ? 'd MMMM y' : 'd MMM', locale).format(date); }
  @override void initState() { super.initState(); _load(); }
  @override Widget build(BuildContext context) { final l10n = AppLocalizations.of(context); final primary = Theme.of(context).colorScheme.primary; final secondary = context.secondaryTextColor; final count = _completed.values.where((v) => v).length; return _trackerContainer(context, child: Column(children: [Row(children: [Icon(Icons.check_circle_outline_rounded, size: 21, color: primary), const SizedBox(width: 8), Expanded(child: Text(l10n.trackerTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.textPrimaryColor, fontSize: 15.5, fontWeight: FontWeight.w700))), Text('$count/5', style: TextStyle(color: primary, fontSize: 13.5, fontWeight: FontWeight.w700))]), const SizedBox(height: 5), SizedBox(width: double.infinity, height: 18, child: FittedBox(fit: BoxFit.scaleDown, child: Text(_loading ? l10n.tr('লোড হচ্ছে...', 'Loading...') : _dateText(context, DateTime.now(), full: true), textAlign: TextAlign.center, style: TextStyle(color: secondary, fontSize: 12, fontWeight: FontWeight.w500)))), const SizedBox(height: 10), Row(children: [for (var i = 0; i < _prayers.length; i++) ...[Expanded(child: _trackerItem(context, _prayers[i], widget.friday && _prayers[i] == 'Dhuhr')), if (i != _prayers.length - 1) const SizedBox(width: 5)]]), const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: count / 5, minHeight: 7, backgroundColor: primary.withValues(alpha: .10))), const SizedBox(height: 8), Text(count == 5 ? l10n.tr('আজ সব ওয়াক্ত আদায় হয়েছে', 'All prayers completed today') : l10n.tr('আজ $count/5 ওয়াক্ত আদায় হয়েছে', '$count/5 prayers completed today'), style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w600))])); }
  Widget _trackerContainer(BuildContext context, {required Widget child}) => Container(padding: const EdgeInsets.fromLTRB(12, 12, 12, 12), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .06))), child: child);
  Widget _trackerItem(BuildContext context, String prayer, bool jumuah) { final primary = Theme.of(context).colorScheme.primary; final done = _completed[prayer] == true; final l10n = AppLocalizations.of(context); final label = jumuah ? l10n.tr('জুমু‘আ', 'Jumuah') : l10n.prayerName(prayer); return InkWell(onTap: () => _toggle(prayer), borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), decoration: BoxDecoration(color: done ? primary.withValues(alpha: .09) : primary.withValues(alpha: .025), borderRadius: BorderRadius.circular(12), border: Border.all(color: done ? primary.withValues(alpha: .22) : primary.withValues(alpha: .06))), child: Column(children: [Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 22, color: done ? primary : context.secondaryTextColor), const SizedBox(height: 4), Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: done ? primary : null))]))); }
}
