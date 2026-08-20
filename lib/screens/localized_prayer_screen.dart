import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/prayer_controller.dart';
import '../localization/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/home/prayer_special_times_card.dart';

class LocalizedPrayerScreen extends StatefulWidget {
  const LocalizedPrayerScreen({super.key});

  @override
  State<LocalizedPrayerScreen> createState() => _LocalizedPrayerScreenState();
}

class _LocalizedPrayerScreenState extends State<LocalizedPrayerScreen> {
  Timer? _clock;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  String _label(BuildContext context, String bn, String en, [String ar = '']) {
    final code = AppLocalizations.of(context).locale.languageCode;
    if (code == 'en') return en;
    if (code == 'ar' && ar.isNotEmpty) return ar;
    return bn;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.watch<PrayerController>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final friday = DateTime.now().weekday == DateTime.friday;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prayer, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: l10n.refreshTooltip,
            onPressed: c.loading ? null : c.refreshPrayerTimes,
            icon: Icon(Icons.refresh_rounded, color: primary, size: 22),
          ),
        ],
      ),
      body: c.loading
          ? Center(child: CircularProgressIndicator(color: primary))
          : c.error != null
              ? _error(context, c)
              : RefreshIndicator(
                  color: primary,
                  onRefresh: c.refreshPrayerTimes,
                  child: ListView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                    children: [
                      _locationCard(context, c),
                      const SizedBox(height: 12),
                      _currentCard(context, c, friday),
                      const SizedBox(height: 12),
                      PrayerSpecialTimesCard(languageCode: l10n.locale.languageCode),
                      const SizedBox(height: 12),
                      _importantTimes(context, c),
                      const SizedBox(height: 18),
                      _sectionTitle(context, _label(context, 'আজকের সালাত', 'Today\'s Salah'), _label(context, 'পাঁচ ওয়াক্তের বাস্তব সময়সূচি', 'Five daily prayer times'), Icons.mosque_outlined),
                      const SizedBox(height: 8),
                      ...c.prayers.where((p) => p['category'] == 'obligatory').map((p) => _prayerTile(context, p, friday)),
                      const SizedBox(height: 14),
                      _sectionTitle(context, _label(context, 'নফল সালাতের সময়', 'Nafl Prayer Times'), _label(context, 'শুধু বাস্তব গণনা পাওয়া গেলে দেখানো হবে', 'Only calculated times are shown'), Icons.auto_awesome_outlined),
                      const SizedBox(height: 8),
                      _naflSection(context, c),
                      const SizedBox(height: 14),
                      _sectionTitle(context, l10n.trackerTitle, l10n.trackerSubtitle, Icons.check_circle_outline_rounded),
                      const SizedBox(height: 8),
                      _PrayerTrackerCard(friday: friday),
                      const SizedBox(height: 18),
                      _footer(context),
                    ],
                  ),
                ),
    );
  }

  Widget _locationCard(BuildContext context, PrayerController c) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    final value = c.currentLocationName.trim();
    return _card(context, padding: const EdgeInsets.fromLTRB(14, 11, 14, 11), radius: 18, child: Row(children: [
      _iconBox(primary, Icons.location_on_rounded, size: 38),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_label(context, 'লোকেশন', 'Location'), style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(value.isEmpty ? _label(context, 'লোকেশন পাওয়া যায়নি', 'Location unavailable') : value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ])),
    ]));
  }

  Widget _currentCard(BuildContext context, PrayerController c, bool friday) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return _card(context, radius: 21, padding: const EdgeInsets.fromLTRB(15, 14, 15, 13), child: Column(children: [
      Row(children: [
        _iconBox(primary, Icons.mosque_rounded, size: 42),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_label(context, 'বর্তমান ওয়াক্ত', 'Current prayer'), style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(AppLocalizations.of(context).prayerName(c.currentPrayer), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ])),
        if (friday) _badge(primary, AppLocalizations.of(context).fridayLabel),
      ]),
      const SizedBox(height: 13),
      Row(children: [
        Expanded(child: _mini(context, Icons.play_arrow_rounded, _label(context, 'শুরু', 'Start'), c.currentPrayerStart)),
        const SizedBox(width: 8),
        Expanded(child: _mini(context, Icons.stop_rounded, _label(context, 'শেষ', 'End'), c.currentPrayerEnd)),
        const SizedBox(width: 8),
        Expanded(child: _mini(context, Icons.groups_rounded, _label(context, 'জামাত', 'Jamaat'), c.currentIqamahTime)),
      ]),
      const SizedBox(height: 11),
      ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: c.prayerProgress.clamp(0.0, 1.0), minHeight: 7, backgroundColor: primary.withValues(alpha: .10))),
      const SizedBox(height: 7),
      Row(children: [Icon(Icons.timelapse_rounded, size: 17, color: primary), const SizedBox(width: 6), Expanded(child: Text(c.prayerStatus, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)))]),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9), decoration: BoxDecoration(color: primary.withValues(alpha: .06), borderRadius: BorderRadius.circular(13)), child: Row(children: [
        Expanded(flex: 4, child: Row(children: [Icon(Icons.schedule_rounded, size: 18, color: primary), const SizedBox(width: 7), Expanded(child: Text('${_label(context, 'পরবর্তী', 'Next')}: ${AppLocalizations.of(context).prayerName(c.nextPrayerName)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)))])),
        Expanded(flex: 3, child: Text(c.timeRemainingForNextPrayer, textAlign: TextAlign.center, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w700))),
        Expanded(flex: 3, child: Text(c.nextPrayerTime, textAlign: TextAlign.end, style: TextStyle(color: primary, fontSize: 13.5, fontWeight: FontWeight.w800))),
      ])),
    ]));
  }

  Widget _importantTimes(BuildContext context, PrayerController c) {
    final primary = Theme.of(context).colorScheme.primary;
    return _card(context, child: Column(children: [
      Row(children: [Icon(Icons.wb_twilight_rounded, color: primary, size: 21), const SizedBox(width: 8), Text(_label(context, 'আজকের গুরুত্বপূর্ণ সময়', 'Today\'s key times'), style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800))]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _dailyTime(context, Icons.wb_sunny_outlined, _label(context, 'সূর্যোদয়', 'Sunrise'), c.sunriseTime, primary)),
        _divider(context),
        Expanded(child: _dailyTime(context, Icons.light_mode_outlined, _label(context, 'জাওয়াল / মধ্যাহ্ন', 'Zawal / Noon'), c.solarNoonTime, primary)),
        _divider(context),
        Expanded(child: _dailyTime(context, Icons.nights_stay_outlined, _label(context, 'সূর্যাস্ত', 'Sunset'), c.sunsetTime, primary)),
      ]),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(13)), child: Row(children: [Icon(Icons.update_rounded, color: primary, size: 18), const SizedBox(width: 7), Expanded(child: Text(_label(context, 'সময় ও কাউন্টডাউন প্রতি সেকেন্ডে আপডেট হচ্ছে', 'Times and countdowns update every second'), style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5, fontWeight: FontWeight.w600))), Text(DateFormat('hh:mm:ss a').format(_now), style: TextStyle(color: primary, fontSize: 11.5, fontWeight: FontWeight.w800))])),
    ]));
  }

  Widget _prayerTile(BuildContext context, Map<String, dynamic> p, bool friday) {
    final primary = Theme.of(context).colorScheme.primary;
    final current = p['isCurrent'] == true;
    final nameRaw = p['nameBn']?.toString() ?? p['name']?.toString() ?? '';
    final name = AppLocalizations.of(context).prayerName(nameRaw);
    final start = p['start']?.toString() ?? '';
    final end = p['end']?.toString() ?? '';
    final jamaat = p['jamaat']?.toString() ?? '';
    final isJumuah = friday && p['name']?.toString() == 'Jumuah';
    return Container(margin: const EdgeInsets.only(bottom: 7), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: current ? primary.withValues(alpha: .07) : context.cardColor, borderRadius: BorderRadius.circular(17), border: Border.all(color: current ? primary.withValues(alpha: .18) : primary.withValues(alpha: .06))), child: Row(children: [
      _iconBox(current ? primary : context.secondaryTextColor, isJumuah ? Icons.groups_rounded : Icons.access_time_rounded, size: 40), const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Flexible(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: current ? FontWeight.w800 : FontWeight.w600, color: current ? primary : null))), if (current) ...[const SizedBox(width: 6), _badge(primary, _label(context, 'চলছে', 'Active'), small: true)]]), const SizedBox(height: 3), Text('$start – $end', style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5, fontWeight: FontWeight.w600))])),
      if (jamaat.isNotEmpty && jamaat != '--:--') ...[const SizedBox(width: 7), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(jamaat, style: TextStyle(color: current ? primary : null, fontSize: 12.5, fontWeight: FontWeight.w800)), Text(_label(context, 'জামাত', 'Jamaat'), style: TextStyle(fontSize: 10.5, color: context.secondaryTextColor, fontWeight: FontWeight.w600))])],
    ]));
  }

  Widget _naflSection(BuildContext context, PrayerController c) {
    final items = <_NaflData>[
      _NaflData(_label(context, 'ইশরাক', 'Ishraq'), _label(context, 'সূর্যোদয়ের পর শুরু হয়', 'Begins after sunrise'), c.ishraqTime, Icons.wb_sunny_outlined),
      _NaflData(_label(context, 'দুহা / চাশত', 'Duha / Chasht'), _label(context, 'ইশরাকের পর থেকে জাওয়ালের আগে', 'After Ishraq and before Zawal'), c.duhaTime, Icons.wb_sunny_rounded),
      _NaflData(_label(context, 'আওয়াবিন', 'Awwabin'), _label(context, 'মাগরিবের পর থেকে ইশার আগে', 'After Maghrib and before Isha'), c.awwabinTime, Icons.nightlight_outlined),
      _NaflData(_label(context, 'তাহাজ্জুদ', 'Tahajjud'), _label(context, 'রাতের শেষ তৃতীয়াংশ', 'Last third of the night'), c.tahajjudTime, Icons.nights_stay_rounded),
    ];
    final valid = items.where((e) => e.time.isNotEmpty && e.time != '--:--').toList();
    if (valid.isEmpty) return _empty(context, _label(context, 'নফল সময়ের গণনা পাওয়া যায়নি', 'No calculated Nafl times available yet'));
    return Column(children: valid.map((item) => _nafl(context, item)).toList());
  }

  Widget _nafl(BuildContext context, _NaflData item) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(margin: const EdgeInsets.only(bottom: 7), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: primary.withValues(alpha: .06))), child: Row(children: [Icon(item.icon, color: primary, size: 22), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(item.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5, fontWeight: FontWeight.w500))])), const SizedBox(width: 8), Flexible(child: Text(item.time, textAlign: TextAlign.end, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: primary, fontSize: 12.5, fontWeight: FontWeight.w800)))]));
  }

  Widget _empty(BuildContext context, String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: context.secondaryTextColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _sectionTitle(BuildContext context, String title, String subtitle, IconData icon) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return Row(children: [_iconBox(primary, icon, size: 38), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)), const SizedBox(height: 1), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w500))]))]);
  }

  Widget _mini(BuildContext context, IconData icon, String title, String value) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9), decoration: BoxDecoration(color: primary.withValues(alpha: .055), borderRadius: BorderRadius.circular(13)), child: Column(children: [Icon(icon, color: primary, size: 20), const SizedBox(height: 4), Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: secondary, fontWeight: FontWeight.w600)), const SizedBox(height: 3), FittedBox(fit: BoxFit.scaleDown, child: Text(value.isEmpty ? '--:--' : value, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)))]));
  }

  Widget _dailyTime(BuildContext context, IconData icon, String title, String value, Color color) => Column(children: [Icon(icon, color: color, size: 22), const SizedBox(height: 5), Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5, fontWeight: FontWeight.w600)), const SizedBox(height: 2), FittedBox(fit: BoxFit.scaleDown, child: Text(value.isEmpty ? '--:--' : value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)))]);

  Widget _footer(BuildContext context) => _card(
    context,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _label(context, 'সালাতের সময় আপনার লোকেশন, গণনা পদ্ধতি ও মাযহাবের সেটিং অনুযায়ী হিসাব করা হয়।', 'Prayer times are calculated from your location, calculation method and madhhab settings.'),
            style: TextStyle(color: context.secondaryTextColor, height: 1.4, fontSize: 11.5),
          ),
        ),
      ],
    ),
  );

  Widget _error(BuildContext context, PrayerController c) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline_rounded, size: 50, color: Colors.redAccent), const SizedBox(height: 12), Text(_label(context, 'সালাতের সময় লোড করা যায়নি', 'Could not load prayer times'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 7), Text(c.error ?? _label(context, 'অজানা সমস্যা', 'Unknown problem'), textAlign: TextAlign.center, style: TextStyle(color: context.secondaryTextColor, fontSize: 12.5)), const SizedBox(height: 16), FilledButton.icon(onPressed: c.refreshPrayerTimes, icon: const Icon(Icons.refresh_rounded), label: Text(_label(context, 'আবার চেষ্টা করুন', 'Try again')))])));

  Widget _card(BuildContext context, {required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(15), double radius = 20}) => Container(padding: padding, decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(radius), border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .07))), child: child);
  Widget _iconBox(Color color, IconData icon, {double size = 38}) => Container(width: size, height: size, decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(size * .30)), child: Icon(icon, color: color, size: size * .55));
  Widget _badge(Color color, String text, {bool small = false}) => Container(padding: EdgeInsets.symmetric(horizontal: small ? 6 : 8, vertical: small ? 3 : 4), decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(20)), child: Text(text, maxLines: 1, style: TextStyle(color: color, fontSize: small ? 9.5 : 10.5, fontWeight: FontWeight.w700)));
  Widget _divider(BuildContext context) => Container(width: 1, height: 38, color: Theme.of(context).dividerColor.withValues(alpha: .30));
}

class _NaflData {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  const _NaflData(this.title, this.description, this.time, this.icon);
}

class _PrayerTrackerCard extends StatefulWidget {
  final bool friday;
  const _PrayerTrackerCard({required this.friday});
  @override
  State<_PrayerTrackerCard> createState() => _PrayerTrackerCardState();
}

class _PrayerTrackerCardState extends State<_PrayerTrackerCard> {
  static const _keys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  Map<String, bool> _today = {};
  bool _loading = true;
  String _dateKey = '';

  String _key(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(DateTime.now());
    final data = {for (final prayer in _keys) prayer: prefs.getBool('nurverse_tracker_${key}_$prayer') ?? false};
    if (!mounted) return;
    setState(() { _dateKey = key; _today = data; _loading = false; });
  }

  Future<void> _toggle(String prayer) async {
    if (_loading) return;
    final next = !(_today[prayer] ?? false);
    setState(() => _today = {..._today, prayer: next});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nurverse_tracker_${_dateKey}_$prayer', next);
  }

  @override
  void initState() { super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final text = Theme.of(context).colorScheme.onSurface;
    final done = _today.values.where((v) => v).length;
    return _card(context, child: Column(children: [
      Row(children: [Icon(Icons.check_circle_outline_rounded, size: 21, color: primary), const SizedBox(width: 8), Expanded(child: Text(AppLocalizations.of(context).trackerTitle, style: TextStyle(color: text, fontSize: 15.5, fontWeight: FontWeight.w800))), Text('$done/5', style: TextStyle(color: primary, fontSize: 13.5, fontWeight: FontWeight.w800))]),
      const SizedBox(height: 10),
      Row(children: [for (var i = 0; i < _keys.length; i++) ...[Expanded(child: InkWell(onTap: _loading ? null : () => _toggle(_keys[i]), borderRadius: BorderRadius.circular(12), child: Column(children: [AnimatedContainer(duration: const Duration(milliseconds: 160), width: 38, height: 38, decoration: BoxDecoration(color: (_today[_keys[i]] ?? false) ? primary : primary.withValues(alpha: .08), shape: BoxShape.circle), child: Icon((_today[_keys[i]] ?? false) ? Icons.check_rounded : Icons.circle_outlined, color: (_today[_keys[i]] ?? false) ? Colors.white : primary, size: 21)), const SizedBox(height: 4), Text(AppLocalizations.of(context).prayerName(_keys[i] == 'Dhuhr' && widget.friday ? 'Jumuah' : _keys[i]), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 10.5, fontWeight: FontWeight.w600))]))), if (i < _keys.length - 1) const SizedBox(width: 2)]]),
    ]));
  }

  Widget _card(BuildContext context, {required Widget child}) => Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .07))), child: child);
}