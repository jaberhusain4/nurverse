import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../localization/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../services/prayer_completion_service.dart';
import '../theme/app_theme.dart';
import '../widgets/home/prayer_special_times_card.dart';

class PrayerScreenV2 extends StatefulWidget {
  const PrayerScreenV2({super.key});

  @override
  State<PrayerScreenV2> createState() => _PrayerScreenV2State();
}

class _PrayerScreenV2State extends State<PrayerScreenV2> {
  Timer? _clock;
  DateTime _now = DateTime.now();
  Map<String, bool> _completed = <String, bool>{};
  List<PrayerDayRecord> _week = <PrayerDayRecord>[];
  bool _trackerLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTracker();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _loadTracker() async {
    final day = await PrayerCompletionService.getDay();
    final week = await PrayerCompletionService.getLastSevenDays();
    if (!mounted) return;
    setState(() {
      _completed = day;
      _week = week;
      _trackerLoading = false;
    });
  }

  Future<void> _togglePrayer(String prayer) async {
    final next = !(_completed[prayer] ?? false);
    setState(() => _completed[prayer] = next);
    await PrayerCompletionService.setCompleted(
      prayer: prayer,
      completed: next,
    );
    final week = await PrayerCompletionService.getLastSevenDays();
    if (!mounted) return;
    setState(() => _week = week);
  }

  String _label(BuildContext context, String bn, String en, [String ar = '']) {
    final code = AppLocalizations.of(context).locale.languageCode;
    if (code == 'en') return en;
    if (code == 'ar' && ar.isNotEmpty) return ar;
    return bn;
  }

  String _prayerLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    return l10n.prayerName(key);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.watch<PrayerController>();
    final primary = Theme.of(context).colorScheme.primary;
    final friday = DateTime.now().weekday == DateTime.friday;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.prayer,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
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
                  onRefresh: () async {
                    await c.refreshPrayerTimes();
                    await _loadTracker();
                  },
                  child: ListView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                    children: [
                      _locationCard(context, c),
                      const SizedBox(height: 12),
                      _currentCard(context, c, friday),
                      const SizedBox(height: 12),
                      _importantTimes(context, c),
                      const SizedBox(height: 18),
                      _todaySalah(context, c, friday),
                      const SizedBox(height: 14),
                      PrayerSpecialTimesCard(
                        languageCode: l10n.locale.languageCode,
                      ),
                      const SizedBox(height: 14),
                      _naflSection(context, c),
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
    return _card(
      context,
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      radius: 18,
      child: Row(
        children: [
          _iconBox(primary, Icons.location_on_rounded, size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label(context, 'লোকেশন', 'Location'),
                  style: TextStyle(
                    color: secondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty
                      ? _label(context, 'লোকেশন পাওয়া যায়নি', 'Location unavailable')
                      : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentCard(BuildContext context, PrayerController c, bool friday) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    final settings = context.watch<SettingsProvider>();
    return _card(
      context,
      radius: 21,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 13),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _iconBox(primary, Icons.mosque_rounded, size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label(context, 'বর্তমান ওয়াক্ত', 'Current prayer'),
                      style: TextStyle(
                        color: secondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _prayerLabel(context, c.currentPrayer),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              if (friday) ...[
                const SizedBox(width: 8),
                _badge(primary, AppLocalizations.of(context).fridayLabel),
              ],
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _label(context, 'সময় বাকি', 'Time left'),
                      style: TextStyle(
                        color: secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      settings.showSeconds
                          ? c.timeRemainingForNextPrayer
                          : _withoutSeconds(c.timeRemainingForNextPrayer),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(child: _mini(context, Icons.play_arrow_rounded, _label(context, 'শুরু', 'Start'), c.currentPrayerStart)),
              const SizedBox(width: 8),
              Expanded(child: _mini(context, Icons.stop_rounded, _label(context, 'শেষ', 'End'), c.currentPrayerEnd)),
              const SizedBox(width: 8),
              Expanded(child: _mini(context, Icons.groups_rounded, _label(context, 'জামাত', 'Jamaat'), c.currentIqamahTime)),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: c.prayerProgress.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: primary.withValues(alpha: .10),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(Icons.timelapse_rounded, size: 17, color: primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  c.prayerStatus,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _previousNextPrayerRow(context, c),
        ],
      ),
    );
  }

  Widget _previousNextPrayerRow(BuildContext context, PrayerController c) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    final previousName = c.previousPrayer.trim().isEmpty ? '—' : _prayerLabel(context, c.previousPrayer);
    final nextName = c.nextPrayerName.trim().isEmpty ? '—' : _prayerLabel(context, c.nextPrayerName);
    return Row(
      children: [
        Expanded(
          child: _adjacentPrayerCard(
            context,
            icon: Icons.history_rounded,
            title: _label(context, 'পূর্ববর্তী', 'Previous'),
            name: previousName,
            time: c.previousPrayerTime.trim().isEmpty ? '--:--' : c.previousPrayerTime,
            primary: primary,
            secondary: secondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _adjacentPrayerCard(
            context,
            icon: Icons.schedule_rounded,
            title: _label(context, 'পরবর্তী', 'Next'),
            name: nextName,
            time: c.nextPrayerTime,
            primary: primary,
            secondary: secondary,
          ),
        ),
      ],
    );
  }

  Widget _adjacentPrayerCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String name,
    required String time,
    required Color primary,
    required Color secondary,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: .10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: secondary, fontSize: 10.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            time,
            textAlign: TextAlign.end,
            style: TextStyle(color: primary, fontSize: 12.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  String _withoutSeconds(String value) {
    final match = RegExp(r'^(\d{2}):(\d{2})').firstMatch(value.trim());
    return match == null ? value : '${match.group(1)}:${match.group(2)}';
  }

  Widget _importantTimes(BuildContext context, PrayerController c) {
    final primary = Theme.of(context).colorScheme.primary;
    return _card(
      context,
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.wb_twilight_rounded, color: primary, size: 21),
              const SizedBox(width: 8),
              Text(
                _label(context, 'আজকের গুরুত্বপূর্ণ সময়', "Today's key times"),
                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _dailyTime(context, Icons.wb_sunny_outlined, _label(context, 'সূর্যোদয়', 'Sunrise'), c.sunriseTime, primary)),
              _divider(context),
              Expanded(child: _dailyTime(context, Icons.light_mode_outlined, _label(context, 'জাওয়াল / মধ্যাহ্ন', 'Zawal / Noon'), c.solarNoonTime, primary)),
              _divider(context),
              Expanded(child: _dailyTime(context, Icons.nights_stay_outlined, _label(context, 'সূর্যাস্ত', 'Sunset'), c.sunsetTime, primary)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .045),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Icon(Icons.update_rounded, color: primary, size: 18),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    _label(context, 'সময় ও কাউন্টডাউন প্রতি সেকেন্ডে আপডেট হচ্ছে', 'Times and countdowns update every second'),
                    style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(DateFormat('hh:mm:ss a').format(_now), style: TextStyle(color: primary, fontSize: 11.5, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _todaySalah(BuildContext context, PrayerController c, bool friday) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    final obligatory = c.prayers.where((p) => p['category'] == 'obligatory').toList();
    final completedCount = _completed.values.where((value) => value).length;
    final progress = completedCount / PrayerCompletionService.prayers.length;

    return _card(
      context,
      padding: const EdgeInsets.fromLTRB(13, 14, 13, 13),
      radius: 20,
      child: Column(
        children: [
          Row(
            children: [
              _iconBox(primary, Icons.check_circle_outline_rounded, size: 40),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label(context, 'আজকের সালাত', "Today's Salah"),
                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _label(context, 'প্রতি ওয়াক্ত আদায় হলে টিক দিন', 'Tick each prayer after completing it'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              _badge(primary, '$completedCount/5'),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: primary.withValues(alpha: .10),
            ),
          ),
          const SizedBox(height: 9),
          if (_trackerLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            ...PrayerCompletionService.prayers.map((prayer) {
              final source = obligatory.cast<Map<String, dynamic>?>().firstWhere(
                (p) => p?['name']?.toString() == prayer,
                orElse: () => null,
              );
              final time = source?['start']?.toString() ?? '--:--';
              final end = source?['end']?.toString() ?? '';
              final isCurrent = source?['isCurrent'] == true;
              final checked = _completed[prayer] ?? false;
              final isJumuah = friday && prayer == 'Dhuhr';
              return _completionTile(
                context,
                prayer,
                time,
                end,
                checked,
                isCurrent,
                isJumuah,
              );
            }),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showDailyReport,
                  icon: const Icon(Icons.today_rounded, size: 17),
                  label: Text(_label(context, 'দৈনিক রিপোর্ট', 'Daily report')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _showWeeklyReport,
                  icon: const Icon(Icons.bar_chart_rounded, size: 17),
                  label: Text(_label(context, 'সাপ্তাহিক রিপোর্ট', 'Weekly report')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _completionTile(
    BuildContext context,
    String prayer,
    String time,
    String end,
    bool checked,
    bool current,
    bool isJumuah,
  ) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return InkWell(
      onTap: () => _togglePrayer(prayer),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          color: checked
              ? primary.withValues(alpha: .075)
              : current
                  ? primary.withValues(alpha: .045)
                  : context.cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: checked || current
                ? primary.withValues(alpha: .16)
                : primary.withValues(alpha: .055),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: checked ? primary : primary.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                checked ? Icons.check_rounded : Icons.mosque_outlined,
                color: checked ? Colors.white : primary,
                size: 19,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          isJumuah ? _label(context, "জুমু'আ", 'Jumu\'ah') : _prayerLabel(context, prayer),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: checked || current ? FontWeight.w800 : FontWeight.w700,
                            color: current ? primary : null,
                          ),
                        ),
                      ),
                      if (current) ...[
                        const SizedBox(width: 5),
                        _badge(primary, _label(context, 'চলছে', 'Active'), small: true),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    end.isEmpty ? time : '$time  •  $end',
                    style: TextStyle(color: secondary, fontSize: 10.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            Icon(
              checked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: checked ? primary : secondary,
              size: 25,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDailyReport() async {
    final count = _completed.values.where((value) => value).length;
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final primary = Theme.of(sheetContext).colorScheme.primary;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _label(sheetContext, 'আজকের সালাত রিপোর্ট', "Today's Salah Report"),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                Text(
                  '$count / 5',
                  style: TextStyle(color: primary, fontSize: 34, fontWeight: FontWeight.w900),
                ),
                Text(
                  _label(sheetContext, 'ওয়াক্ত সম্পন্ন', 'prayers completed'),
                  style: TextStyle(color: context.secondaryTextColor, fontSize: 12),
                ),
                const SizedBox(height: 14),
                ...PrayerCompletionService.prayers.map(
                  (prayer) => ListTile(
                    dense: true,
                    leading: Icon(
                      _completed[prayer] == true
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: _completed[prayer] == true ? primary : context.secondaryTextColor,
                    ),
                    title: Text(_prayerLabel(sheetContext, prayer)),
                    trailing: Text(
                      _completed[prayer] == true
                          ? _label(sheetContext, 'আদায়', 'Completed')
                          : _label(sheetContext, 'বাকি', 'Pending'),
                      style: TextStyle(fontSize: 11, color: context.secondaryTextColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showWeeklyReport() async {
    final records = await PrayerCompletionService.getLastSevenDays();
    if (!mounted) return;
    setState(() => _week = records);
    final primary = Theme.of(context).colorScheme.primary;
    final total = records.fold<int>(0, (sum, day) => sum + day.completedCount);
    final average = total / 7;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _label(sheetContext, 'সাপ্তাহিক সালাত রিপোর্ট', 'Weekly Salah Report'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  _label(sheetContext, 'গত ৭ দিনের বাস্তব টিকের হিসাব', 'Actual completion for the last 7 days'),
                  style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _reportStat(sheetContext, '$total/35', _label(sheetContext, 'মোট', 'Total'), primary)),
                    const SizedBox(width: 8),
                    Expanded(child: _reportStat(sheetContext, average.toStringAsFixed(1), _label(sheetContext, 'দৈনিক গড়', 'Daily avg'), primary)),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: records.length,
                    itemBuilder: (_, index) {
                      final record = records[index];
                      final isToday = DateUtils.isSameDay(record.date, DateTime.now());
                      final dayName = DateFormat('EEE', AppLocalizations.of(sheetContext).locale.languageCode).format(record.date);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                        decoration: BoxDecoration(
                          color: record.completedCount == 5 ? primary.withValues(alpha: .07) : context.cardColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 48,
                              child: Text(dayName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: record.progress,
                                  minHeight: 7,
                                  backgroundColor: primary.withValues(alpha: .10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${record.completedCount}/5',
                              style: TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 12),
                            ),
                            if (isToday) ...[
                              const SizedBox(width: 5),
                              _badge(primary, _label(sheetContext, 'আজ', 'Today'), small: true),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _reportStat(BuildContext context, String value, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(color: context.secondaryTextColor, fontSize: 10.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _naflSection(BuildContext context, PrayerController c) {
    final items = <Map<String, dynamic>>[
      {
        'title': _label(context, 'ইশরাক', 'Ishraq'),
        'desc': _label(context, 'সূর্যোদয়ের পর', 'After sunrise'),
        'time': c.ishraqTime,
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'title': _label(context, 'চাশত / দুহা', 'Duha'),
        'desc': _label(context, 'দুপুরের আগে', 'Before noon'),
        'time': c.duhaTime,
        'icon': Icons.light_mode_outlined,
      },
      {
        'title': _label(context, 'আওয়াবিন', 'Awwabin'),
        'desc': _label(context, 'মাগরিবের পর', 'After Maghrib'),
        'time': c.awwabinTime,
        'icon': Icons.nights_stay_outlined,
      },
      {
        'title': _label(context, 'তাহাজ্জুদ', 'Tahajjud'),
        'desc': _label(context, 'রাতের শেষ তৃতীয়াংশ', 'Last third of the night'),
        'time': c.tahajjudTime,
        'icon': Icons.nights_stay_rounded,
      },
    ];
    final valid = items.where((item) {
      final value = item['time']?.toString() ?? '';
      return value.isNotEmpty && value != '--:--';
    }).toList();

    return Column(
      children: [
        _sectionTitle(
          context,
          _label(context, 'নফল সালাতের সময়', 'Nafl Prayer Times'),
          _label(context, 'শুধু বাস্তব গণনা পাওয়া গেলে দেখানো হবে', 'Only calculated times are shown'),
          Icons.auto_awesome_outlined,
        ),
        const SizedBox(height: 8),
        if (valid.isEmpty)
          _card(
            context,
            padding: const EdgeInsets.all(12),
            radius: 14,
            child: Text(
              _label(context, 'নফল সময়ের গণনা পাওয়া যায়নি', 'No calculated Nafl times available yet'),
              style: TextStyle(color: context.secondaryTextColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          )
        else
          ...valid.map(
            (item) => _card(
              context,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              radius: 16,
              child: Row(
                children: [
                  Icon(item['icon'] as IconData, color: Theme.of(context).colorScheme.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'] as String, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
                        Text(item['desc'] as String, style: TextStyle(color: context.secondaryTextColor, fontSize: 10.5)),
                      ],
                    ),
                  ),
                  Text(item['time'] as String, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12.5, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _footer(BuildContext context) => _card(
        context,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _label(context, 'সালাতের সময় আপনার লোকেশন, গণনা পদ্ধতি ও মাজহাবের সেটিং অনুযায়ী হিসাব করা হয়।', 'Prayer times are calculated from your location, calculation method and madhhab settings.'),
                style: TextStyle(color: context.secondaryTextColor, height: 1.4, fontSize: 11.5),
              ),
            ),
          ],
        ),
      );

  Widget _sectionTitle(BuildContext context, String title, String subtitle, IconData icon) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return Row(
      children: [
        _iconBox(primary, icon, size: 38),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 1),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mini(BuildContext context, IconData icon, String title, String value) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
      decoration: BoxDecoration(color: primary.withValues(alpha: .055), borderRadius: BorderRadius.circular(13)),
      child: Column(
        children: [
          Icon(icon, color: primary, size: 20),
          const SizedBox(height: 4),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: secondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          FittedBox(fit: BoxFit.scaleDown, child: Text(value.isEmpty ? '--:--' : value, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5))),
        ],
      ),
    );
  }

  Widget _dailyTime(BuildContext context, IconData icon, String title, String value, Color color) => Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 5),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          FittedBox(fit: BoxFit.scaleDown, child: Text(value.isEmpty ? '--:--' : value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5))),
        ],
      );

  Widget _card(BuildContext context, {required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(15), double radius = 20}) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .07)),
        ),
        child: child,
      );

  Widget _iconBox(Color color, IconData icon, {double size = 38}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(size * .30)),
        child: Icon(icon, color: color, size: size * .55),
      );

  Widget _badge(Color color, String text, {bool small = false}) => Container(
        padding: EdgeInsets.symmetric(horizontal: small ? 6 : 8, vertical: small ? 3 : 4),
        decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(20)),
        child: Text(text, maxLines: 1, style: TextStyle(color: color, fontSize: small ? 9.5 : 10.5, fontWeight: FontWeight.w700)),
      );

  Widget _divider(BuildContext context) => Container(width: 1, height: 38, color: Theme.of(context).dividerColor.withValues(alpha: .30));

  Widget _error(BuildContext context, PrayerController c) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 50, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(_label(context, 'সালাতের সময় লোড করা যায়নি', 'Could not load prayer times'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 7),
              Text(c.error ?? _label(context, 'অজানা সমস্যা', 'Unknown problem'), textAlign: TextAlign.center, style: TextStyle(color: context.secondaryTextColor, fontSize: 12.5)),
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: c.refreshPrayerTimes, icon: const Icon(Icons.refresh_rounded), label: Text(_label(context, 'আবার চেষ্টা করুন', 'Try again'))),
            ],
          ),
        ),
      );
}
