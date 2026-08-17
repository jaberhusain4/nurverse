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
    return _card(
      context,
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      radius: 19,
      child: Row(children: [
        _iconBox(primary, Icons.location_on_rounded, size: 38),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.location, maxLines: 1, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w600, height: 1.0)),
          const SizedBox(height: 4),
          SizedBox(height: 18, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, maxLines: 1, softWrap: false, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.0)))),
        ])),
      ]),
    );
  }

  Widget _currentCard(BuildContext context, PrayerController c, bool friday) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return _card(
      context,
      radius: 22,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 13),
      child: Column(children: [
        Stack(children: [
          Center(child: Column(children: [
            _iconBox(primary, Icons.mosque_rounded, size: 42),
            const SizedBox(height: 6),
            Text(l10n.currentPrayerLabel, maxLines: 1, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(l10n.prayerName(c.currentPrayer), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.05)),
          ])),
          if (friday) Positioned(top: 2, right: 0, child: _badge(primary, l10n.fridayLabel)),
        ]),
        const SizedBox(height: 13),
        Row(children: [
          Expanded(child: _mini(context, Icons.play_arrow_rounded, l10n.startLabel, c.currentPrayerStart)),
          const SizedBox(width: 8),
          Expanded(child: _mini(context, Icons.stop_rounded, l10n.endLabel, c.currentPrayerEnd)),
          const SizedBox(width: 8),
          Expanded(child: _mini(context, Icons.groups_rounded, l10n.jamaatLabel, c.currentIqamahTime)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: c.prayerProgress.clamp(0.0, 1.0), minHeight: 7, backgroundColor: primary.withValues(alpha: .10))),
        const SizedBox(height: 7),
        Row(children: [Icon(Icons.timelapse_rounded, size: 17, color: primary), const SizedBox(width: 6), Expanded(child: Text(c.prayerStatus, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)))]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(color: primary.withValues(alpha: .06), borderRadius: BorderRadius.circular(13)),
          child: Row(children: [
            Icon(Icons.schedule_rounded, size: 18, color: primary),
            const SizedBox(width: 7),
            Expanded(child: Text('${l10n.nextLabel}: ${l10n.prayerName(c.nextPrayerName)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            const SizedBox(width: 6),
            Text(c.nextPrayerTime, style: TextStyle(color: primary, fontSize: 13.5, fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            Flexible(child: Text(c.timeRemainingForNextPrayer, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w600))),
          ]),
        ),
      ]),
    );
  }

  Widget _summaryCard(BuildContext context, PrayerController c) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return _card(context, child: Column(children: [
      Row(children: [Icon(Icons.access_time_rounded, color: primary, size: 21), const SizedBox(width: 8), Text(l10n.prayerTimeLabel, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)), const Spacer(), Flexible(child: Text('${l10n.nextLabel} ${l10n.prayerName(c.nextPrayerName)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w600)))]),
      const SizedBox(height: 11),
      Row(children: [
        Expanded(child: _timeBox(context, c.previousPrayer, c.previousPrayerTime, Icons.history_rounded, l10n.previousLabel)),
        const SizedBox(width: 8),
        Expanded(child: _timeBox(context, c.currentPrayer, c.currentPrayerStart, Icons.mosque_outlined, l10n.currentLabel)),
        const SizedBox(width: 8),
        Expanded(child: _timeBox(context, c.nextPrayerName, c.nextPrayerTime, Icons.arrow_forward_rounded, l10n.nextLabel)),
      ]),
    ]));
  }

  Widget _importantTimes(BuildContext context, PrayerController c) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    return _card(context, child: Column(children: [
      Row(children: [Icon(Icons.wb_twilight_rounded, color: primary, size: 21), const SizedBox(width: 8), Text(l10n.todayImportantTimes, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _dailyTime(context, Icons.wb_sunny_outlined, l10n.sunrise, c.sunriseTime, primary)),
        _divider(context),
        Expanded(child: _dailyTime(context, Icons.light_mode_outlined, l10n.solarNoonLabel, c.solarNoonTime, primary)),
        _divider(context),
        Expanded(child: _dailyTime(context, Icons.nights_stay_outlined, l10n.sunset, c.sunsetTime, primary)),
      ]),
      const SizedBox(height: 12),
      _special(context, Icons.warning_amber_rounded, l10n.makruhLabel, c.makruhTimeText),
      const SizedBox(height: 7),
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
    final isJumuah = friday && (nameRaw == "জুমু'আ" || nameRaw == 'জুমু‘আ' || nameRaw == 'Jumuah');
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: current ? primary.withValues(alpha: .07) : context.cardColor, borderRadius: BorderRadius.circular(17), border: Border.all(color: current ? primary.withValues(alpha: .18) : primary.withValues(alpha: .06))),
      child: Row(children: [
        _iconBox(current ? primary : context.secondaryTextColor, isJumuah ? Icons.groups_rounded : Icons.access_time_rounded, size: 40),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Flexible(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: current ? FontWeight.w700 : FontWeight.w600, color: current ? primary : null))), if (current) ...[const SizedBox(width: 6), _badge(primary, l10n.currentLabel, small: true)]]),
          const SizedBox(height: 3),
          Text('$start - $end', style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ])),
        const SizedBox(width: 7),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(jamaat.isEmpty ? '—' : jamaat, style: TextStyle(color: current ? primary : null, fontSize: 12.5, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(l10n.jamaatLabel, style: TextStyle(fontSize: 10.5, color: context.secondaryTextColor, fontWeight: FontWeight.w600))]),
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
    final secondary = context.secondaryTextColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: primary.withValues(alpha: .06))),
      child: Row(children: [
        Icon(icon, color: primary, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w500))])),
        const SizedBox(width: 8),
        Flexible(child: Text(time, textAlign: TextAlign.end, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 12.5))),
      ]),
    );
  }

  Widget _trackerCard(BuildContext context, bool friday) => _PersistentPrayerTrackerCard(friday: friday);

  Widget _sectionTitle(BuildContext context, String title, String subtitle, IconData icon) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return Row(children: [_iconBox(primary, icon, size: 38), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)), const SizedBox(height: 1), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w500))]))]);
  }

  Widget _mini(BuildContext context, IconData icon, String title, String value) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9), decoration: BoxDecoration(color: primary.withValues(alpha: .055), borderRadius: BorderRadius.circular(13)), child: Column(children: [Icon(icon, color: primary, size: 20), const SizedBox(height: 4), Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: secondary, fontWeight: FontWeight.w600)), const SizedBox(height: 3), FittedBox(fit: BoxFit.scaleDown, child: Text(value.isEmpty ? '--:--' : value, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)))]));
  }

  Widget _timeBox(BuildContext context, String prayer, String time, IconData icon, String title) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9), decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(13)), child: Column(children: [Icon(icon, size: 20, color: primary), const SizedBox(height: 4), Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, color: secondary, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(AppLocalizations.of(context).prayerName(prayer), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)), const SizedBox(height: 2), FittedBox(fit: BoxFit.scaleDown, child: Text(time.isEmpty ? '--:--' : time, style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 12.5)))]));
  }

  Widget _dailyTime(BuildContext context, IconData icon, String title, String value, Color color) {
    final secondary = context.secondaryTextColor;
    return Column(children: [Icon(icon, color: color, size: 22), const SizedBox(height: 5), Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w600)), const SizedBox(height: 2), FittedBox(fit: BoxFit.scaleDown, child: Text(value.isEmpty ? '--:--' : value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5))) ]);
  }

  Widget _special(BuildContext context, IconData icon, String title, String value) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: primary.withValues(alpha: .05), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(icon, color: primary, size: 18), const SizedBox(width: 7), Text(title, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), const SizedBox(width: 7), Expanded(child: Text(value.isEmpty ? '—' : value, textAlign: TextAlign.end, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 11, fontWeight: FontWeight.w500)))]));
  }

  Widget _footer(BuildContext context) => _card(context, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline_rounded, size: 18, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Expanded(child: Text(AppLocalizations.of(context).prayerTimeNote, style: TextStyle(color: context.secondaryTextColor, height: 1.4, fontSize: 11.5)))]));

  Widget _errorState(BuildContext context, PrayerController c) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline_rounded, size: 50, color: Colors.redAccent), const SizedBox(height: 12), Text(AppLocalizations.of(context).prayerLoadFailed, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 7), Text(c.error ?? AppLocalizations.of(context).unknownProblem, textAlign: TextAlign.center, style: TextStyle(color: context.secondaryTextColor, fontSize: 12.5)), const SizedBox(height: 16), FilledButton.icon(onPressed: c.refreshPrayerTimes, icon: const Icon(Icons.refresh_rounded), label: Text(AppLocalizations.of(context).tryAgainLabel))])));

  void _showLocation(BuildContext context, String location) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Row(children: [const Icon(Icons.location_on_rounded, color: Colors.white, size: 19), const SizedBox(width: 7), Expanded(child: Text(location.isEmpty ? AppLocalizations.of(context).unknownLocation : location, maxLines: 1, overflow: TextOverflow.ellipsis))]), duration: const Duration(seconds: 3)));
  }

  Widget _card(BuildContext context, {required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(15), double radius = 20}) => Container(padding: padding, decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(radius), border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .07))), child: child);

  Widget _iconBox(Color color, IconData icon, {double size = 38}) => Container(width: size, height: size, decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(size * .30)), child: Icon(icon, color: color, size: size * .55));

  Widget _badge(Color color, String text, {bool small = false}) => Container(padding: EdgeInsets.symmetric(horizontal: small ? 6 : 8, vertical: small ? 3 : 4), decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(20)), child: Text(text, maxLines: 1, style: TextStyle(color: color, fontSize: small ? 9.5 : 10.5, fontWeight: FontWeight.w700)));

  Widget _divider(BuildContext context) => Container(width: 1, height: 38, color: Theme.of(context).dividerColor.withValues(alpha: .30));
}

class _PersistentPrayerTrackerCard extends StatefulWidget {
  final bool friday;
  const _PersistentPrayerTrackerCard({required this.friday});

  @override
  State<_PersistentPrayerTrackerCard> createState() => _PersistentPrayerTrackerCardState();
}

class _PersistentPrayerTrackerCardState extends State<_PersistentPrayerTrackerCard> {
  static const _prayers = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  Map<String, bool> _today = <String, bool>{};
  final Map<String, int> _history = <String, int>{};
  bool _loading = true;
  String _todayKey = '';

  String _key(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  String _dateText(BuildContext context, DateTime date, {bool full = false}) {
    final language = AppLocalizations.of(context).locale.languageCode;
    final locale = language == 'ar' ? 'ar' : language == 'en' ? 'en_US' : 'bn_BD';
    return DateFormat(full ? 'd MMM yyyy' : 'd MMM', locale).format(date);
  }

  Future<Map<String, bool>> _readDay(SharedPreferences prefs, String dateKey) async {
    final result = <String, bool>{};
    for (final prayer in _prayers) {
      result[prayer] = prefs.getBool('nurverse_tracker_${dateKey}_$prayer') ?? false;
    }
    return result;
  }

  Future<void> _loadTracker() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _key(now);
    final today = await _readDay(prefs, todayKey);
    final history = <String, int>{};
    for (var offset = 0; offset < 7; offset++) {
      final date = now.subtract(Duration(days: offset));
      final key = _key(date);
      final day = offset == 0 ? today : await _readDay(prefs, key);
      history[key] = day.values.where((done) => done).length;
    }
    if (!mounted) return;
    setState(() {
      _todayKey = todayKey;
      _today = today;
      _history
        ..clear()
        ..addAll(history);
      _loading = false;
    });
  }

  Future<void> _toggle(String prayer) async {
    if (_loading || _todayKey.isEmpty) return;
    final next = !(_today[prayer] ?? false);
    setState(() {
      _today = {..._today, prayer: next};
      _history[_todayKey] = _today.values.where((done) => done).length;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nurverse_tracker_${_todayKey}_$prayer', next);
  }

  String _trackerLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    if (key == 'Dhuhr' && widget.friday) return l10n.prayerName('Jumuah');
    return l10n.prayerName(key);
  }

  @override
  void initState() {
    super.initState();
    _loadTracker();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final text = Theme.of(context).textTheme.bodyLarge?.color ?? Theme.of(context).colorScheme.onSurface;
    final secondary = context.secondaryTextColor;
    final todayCount = _today.values.where((done) => done).length;
    final yesterdayKey = _key(DateTime.now().subtract(const Duration(days: 1)));
    final yesterdayCount = _history[yesterdayKey] ?? 0;
    final l10n = AppLocalizations.of(context);

    return _trackerContainer(context, child: Column(children: [
      Row(children: [Icon(Icons.check_circle_outline_rounded, size: 21, color: primary), const SizedBox(width: 8), Expanded(child: Text(l10n.trackerTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 15.5, fontWeight: FontWeight.w700))), Text('$todayCount/5', style: TextStyle(color: primary, fontSize: 13.5, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 5),
      SizedBox(
        width: double.infinity,
        height: 18,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _loading ? l10n.tr('লোড হচ্ছে...', 'Loading...') : _dateText(context, DateTime.now(), full: true),
            textAlign: TextAlign.center,
            style: TextStyle(color: secondary, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Row(children: [
        for (var i = 0; i < _prayers.length; i++) ...[
          Expanded(child: InkWell(onTap: _loading ? null : () => _toggle(_prayers[i]), borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2), child: Column(children: [
            AnimatedContainer(duration: const Duration(milliseconds: 180), width: 40, height: 40, decoration: BoxDecoration(color: (_today[_prayers[i]] ?? false) ? primary : primary.withValues(alpha: .08), shape: BoxShape.circle), child: Icon((_today[_prayers[i]] ?? false) ? Icons.check_rounded : Icons.circle_outlined, color: (_today[_prayers[i]] ?? false) ? Colors.white : primary, size: 22)),
            const SizedBox(height: 5),
            Text(_trackerLabel(context, _prayers[i]), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 11.5, fontWeight: FontWeight.w600)),
          ])))),
          if (i < _prayers.length - 1) const SizedBox(width: 2),
        ],
      ]),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: primary.withValues(alpha: .035), borderRadius: BorderRadius.circular(12)), child: Row(children: [Expanded(child: Text('${l10n.tr('আজ', 'Today')}: $todayCount/5', style: TextStyle(color: text, fontSize: 11.5, fontWeight: FontWeight.w600))), Expanded(child: Text('${l10n.tr('গতকাল', 'Yesterday')}: $yesterdayCount/5', textAlign: TextAlign.right, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w600)))])),
      const SizedBox(height: 11),
      Align(alignment: Alignment.centerLeft, child: Text(l10n.tr('গত ৭ দিনের হিসাব', 'Last 7 days'), style: TextStyle(color: text, fontSize: 12.5, fontWeight: FontWeight.w700))),
      const SizedBox(height: 5),
      for (var offset = 0; offset < 7; offset++) _historyRow(context, DateTime.now().subtract(Duration(days: offset)), primary, text, secondary),
    ]));
  }

  Widget _historyRow(BuildContext context, DateTime date, Color primary, Color text, Color secondary) {
    final l10n = AppLocalizations.of(context);
    final key = _key(date);
    final count = _history[key] ?? 0;
    final complete = count == 5;
    final label = key == _todayKey ? l10n.tr('আজ', 'Today') : _dateText(context, date);
    return Padding(padding: const EdgeInsets.only(top: 5), child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: primary.withValues(alpha: complete ? .07 : .025), borderRadius: BorderRadius.circular(11)), child: Row(children: [
      Icon(complete ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: complete ? primary : secondary.withValues(alpha: .65), size: 18),
      const SizedBox(width: 7),
      Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 11.5, fontWeight: FontWeight.w600))),
      Text('$count/5', style: TextStyle(color: complete ? primary : secondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
      const SizedBox(width: 7),
      Flexible(child: Text(complete ? l10n.tr('সব ওয়াক্ত আদায় হয়েছে', 'All 5 completed') : l10n.tr('$count ওয়াক্ত আদায় হয়েছে', '$count prayers completed'), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 10.5, fontWeight: FontWeight.w500))),
    ])));
  }

  Widget _trackerContainer(BuildContext context, {required Widget child}) => Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(12, 13, 12, 12), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .07))), child: child);
}
