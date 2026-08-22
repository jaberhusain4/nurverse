import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../providers/settings_provider.dart';
import '../services/date_service.dart';
import '../services/last_read_service.dart';
import '../theme/app_theme.dart';
import '../widgets/home/continue_reading_card.dart';
import 'dua/dua_screen.dart';
import 'qibla/qibla_screen.dart';
import 'quran/onudhabon_quran_screen.dart';
import 'tools/asma_ul_husna.dart';
import 'tools/calendar_screen.dart';
import 'tools/ruqyah_screen.dart';
import 'tools/tasbih_screen.dart';

/// Simple Home V2.
///
/// Prayer-first opening experience inspired by the structural hierarchy of
/// Muslim's Day: location/date context, a dominant active-prayer card, then
/// the complete prayer timetable and essential shortcuts.
///
/// Informative Home remains completely separate and locked.
class SimpleHomeScreenMuslimDayV2 extends StatefulWidget {
  const SimpleHomeScreenMuslimDayV2({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreenMuslimDayV2> createState() =>
      _SimpleHomeScreenMuslimDayV2State();
}

class _SimpleHomeScreenMuslimDayV2State
    extends State<SimpleHomeScreenMuslimDayV2> {
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
    _loadLastRead();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLastRead() async {
    try {
      final data = await LastReadService.getLastRead();
      if (mounted) {
        setState(() => _lastRead = data);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _lastRead = null);
      }
    }
  }

  Future<void> _refresh() async {
    await context.read<PrayerController>().refreshLocation();
    await _loadLastRead();
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => page),
    );
    if (mounted) {
      await _refresh();
    }
  }

  String _tr(String bn, String en, String lang) => lang == 'en' ? en : bn;

  String _hijri(String lang) {
    final h = HijriCalendar.now();
    const bn = <String>[
      'মুহররম',
      'সফর',
      'রবিউল আউয়াল',
      'রবিউস সানি',
      'জুমাদিউল আউয়াল',
      'জুমাদিউস সানি',
      'রজব',
      'শাবান',
      'রমজান',
      'শাওয়াল',
      'জিলকদ',
      'জিলহজ',
    ];
    const en = <String>[
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha’ban',
      'Ramadan',
      'Shawwal',
      'Dhul-Qadah',
      'Dhul-Hijjah',
    ];

    String bnDigits(int value) => value
        .toString()
        .split('')
        .map((d) => '০১২৩৪৫৬৭৮৯'[int.parse(d)])
        .join();

    final month = lang == 'en' ? en[h.hMonth - 1] : bn[h.hMonth - 1];
    final day = lang == 'en' ? '${h.hDay}' : bnDigits(h.hDay);
    final year = lang == 'en' ? '${h.hYear}' : bnDigits(h.hYear);
    return '$day $month $year';
  }

  String _countdown(DateTime? target) {
    if (target == null) {
      return '--:--:--';
    }
    final difference = target.difference(_now);
    if (difference.isNegative) {
      return '00:00:00';
    }
    final total = difference.inSeconds;
    final hours = total ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final seconds = total % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> _fivePrayers(PrayerController controller) {
    const keys = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final result = <Map<String, dynamic>>[];

    for (final key in keys) {
      for (final prayer in controller.prayers) {
        final name = '${prayer['name'] ?? ''}'.toLowerCase();
        final bn = '${prayer['nameBn'] ?? ''}'.toLowerCase();
        final matches = name.contains(key.toLowerCase()) ||
            (key == 'Fajr' && bn.contains('ফজর')) ||
            (key == 'Dhuhr' &&
                (bn.contains('যোহর') || bn.contains('জুমু'))) ||
            (key == 'Asr' && bn.contains('আসর')) ||
            (key == 'Maghrib' && bn.contains('মাগরিব')) ||
            (key == 'Isha' && bn.contains('ইশা'));
        if (matches) {
          result.add(prayer);
          break;
        }
      }
    }
    return result;
  }

  String _prayerName(Map<String, dynamic> prayer, String lang) {
    return lang == 'en'
        ? '${prayer['name'] ?? ''}'
        : '${prayer['nameBn'] ?? prayer['name'] ?? ''}';
  }

  String _time(dynamic value) => value == null ? '--' : '$value';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final lang = settings.languageCode;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final prayers = _fivePrayers(controller);
    final current = controller.currentPrayer;
    final hasLastRead = _lastRead != null &&
        '${_lastRead!['surahName'] ?? ''}'.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: primary,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            children: [
              _TopContext(
                location: controller.currentLocationName,
                date: DateService.englishDate(),
                lang: lang,
              ),
              const SizedBox(height: 12),
              _DominantPrayerCard(
                lang: lang,
                hijri: _hijri(lang),
                gregorian: DateService.englishDate(),
                prayerName: current,
                prayerEnd: controller.currentPrayerEnd,
                nextPrayer: controller.nextPrayerName,
                nextPrayerTime: _time(controller.nextPrayerTime),
                sunrise: _time(controller.sunriseTime),
                sunset: _time(controller.sunsetTime),
                countdown: _countdown(controller.currentPrayerEnd),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      _tr('নামাজের সময়', 'Prayer times', lang),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigateTab?.call(1),
                    child: Text(_tr('আরও দেখুন', 'Learn more', lang)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _PrayerSchedule(
                prayers: prayers,
                currentPrayer: current,
                lang: lang,
              ),
              const SizedBox(height: 20),
              Text(
                _tr('প্রয়োজনীয়', 'Essentials', lang),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              _Essentials(
                lang: lang,
                onQibla: () => _open(const QiblaScreen()),
                onDua: () => _open(const DuaScreen()),
                onTasbih: () => _open(const TasbihScreen()),
                onNames: () => _open(const AsmaUlHusnaScreen()),
                onCalendar: () => _open(const CalendarScreen()),
                onRuqyah: () => _open(const RuqyahScreen()),
              ),
              if (hasLastRead) ...[
                const SizedBox(height: 20),
                Text(
                  _tr('কুরআন চালিয়ে যান', 'Continue Quran', lang),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                ContinueReadingCard(
                  surahName: '${_lastRead!['surahName'] ?? ''}',
                  paraNo: _lastRead!['paraNo'] is int
                      ? _lastRead!['paraNo'] as int
                      : int.tryParse('${_lastRead!['paraNo']}') ?? 1,
                  pageNo: _lastRead!['pageNo'] is int
                      ? _lastRead!['pageNo'] as int
                      : int.tryParse('${_lastRead!['pageNo']}') ?? 1,
                  progress: ((_lastRead!['progress'] is num
                              ? (_lastRead!['progress'] as num).toDouble()
                              : 0.0)
                          .clamp(0.0, 1.0))
                      .toDouble(),
                  languageCode: lang,
                  onTap: () => _open(
                    const OnudhabonQuranScreen(openLastRead: true),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopContext extends StatelessWidget {
  const _TopContext({
    required this.location,
    required this.date,
    required this.lang,
  });

  final String location;
  final String date;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      children: [
        Icon(Icons.location_on_outlined, color: primary, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.trim().isEmpty ? 'Locating…' : location.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.secondaryTextColor,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.notifications_none_rounded, color: primary, size: 23),
      ],
    );
  }
}

class _DominantPrayerCard extends StatelessWidget {
  const _DominantPrayerCard({
    required this.lang,
    required this.hijri,
    required this.gregorian,
    required this.prayerName,
    required this.prayerEnd,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.sunrise,
    required this.sunset,
    required this.countdown,
  });

  final String lang;
  final String hijri;
  final String gregorian;
  final String prayerName;
  final DateTime? prayerEnd;
  final String nextPrayer;
  final String nextPrayerTime;
  final String sunrise;
  final String sunset;
  final String countdown;

  String _tr(String bn, String en) => lang == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    // Solid Sea Shore color only: no gradient by design.
    final background = AppColors.seaBlueDark;
    final text = Colors.white;
    final muted = Colors.white.withValues(alpha: .84);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(21, 18, 21, 18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: background.withValues(alpha: .20),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hijri,
                      style: TextStyle(
                        color: text,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      gregorian,
                      style: TextStyle(color: muted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _tr('সূর্যোদয়', 'Sunrise'),
                    style: TextStyle(color: muted, fontSize: 10.5),
                  ),
                  Text(
                    sunrise,
                    style: TextStyle(
                      color: text,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _tr('সূর্যাস্ত', 'Sunset'),
                    style: TextStyle(color: muted, fontSize: 10.5),
                  ),
                  Text(
                    sunset,
                    style: TextStyle(
                      color: text,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 23),
          Text(
            prayerName.isEmpty
                ? _tr('পরবর্তী সালাত', 'Next prayer')
                : prayerName,
            style: TextStyle(
              color: text,
              fontSize: 31,
              height: 1.05,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            prayerEnd == null
                ? '$nextPrayer  •  $nextPrayerTime'
                : _tr('ওয়াক্ত শেষ হবে', 'Waqt ends in'),
            style: TextStyle(
              color: muted,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            countdown,
            style: TextStyle(
              color: text,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: .3,
            ),
          ),
          const SizedBox(height: 7),
          if (prayerEnd == null)
            Text(
              _tr('পরবর্তী সালাত', 'Next prayer'),
              style: TextStyle(color: muted, fontSize: 11.5),
            ),
          if (prayerEnd == null)
            Text(
              '$nextPrayer  •  $nextPrayerTime',
              style: TextStyle(
                color: text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _PrayerSchedule extends StatelessWidget {
  const _PrayerSchedule({
    required this.prayers,
    required this.currentPrayer,
    required this.lang,
  });

  final List<Map<String, dynamic>> prayers;
  final String currentPrayer;
  final String lang;

  String _name(Map<String, dynamic> prayer) =>
      lang == 'en'
          ? '${prayer['name'] ?? ''}'
          : '${prayer['nameBn'] ?? prayer['name'] ?? ''}';

  bool _active(Map<String, dynamic> prayer) {
    final name = '${prayer['name'] ?? ''}'.toLowerCase();
    final bn = '${prayer['nameBn'] ?? ''}';
    return name.contains(currentPrayer.toLowerCase()) || bn.contains(currentPrayer);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    if (prayers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          lang == 'en'
              ? 'Prayer times are loading…'
              : 'সালাতের সময় লোড হচ্ছে…',
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < prayers.length; i++) ...[
            _PrayerScheduleRow(
              name: _name(prayers[i]),
              start: '${prayers[i]['start'] ?? prayers[i]['time'] ?? '--'}',
              end: '${prayers[i]['end'] ?? ''}',
              active: _active(prayers[i]),
              primary: primary,
            ),
            if (i != prayers.length - 1)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.dividerColor.withValues(alpha: .45),
              ),
          ],
        ],
      ),
    );
  }
}

class _PrayerScheduleRow extends StatelessWidget {
  const _PrayerScheduleRow({
    required this.name,
    required this.start,
    required this.end,
    required this.active,
    required this.primary,
  });

  final String name;
  final String start;
  final String end;
  final bool active;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = end.trim().isEmpty || end == 'null'
        ? start
        : '$start – $end';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: active ? primary.withValues(alpha: .055) : null,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? primary : theme.dividerColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 15,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? primary : null,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? primary : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _Essentials extends StatelessWidget {
  const _Essentials({
    required this.lang,
    required this.onQibla,
    required this.onDua,
    required this.onTasbih,
    required this.onNames,
    required this.onCalendar,
    required this.onRuqyah,
  });

  final String lang;
  final VoidCallback onQibla;
  final VoidCallback onDua;
  final VoidCallback onTasbih;
  final VoidCallback onNames;
  final VoidCallback onCalendar;
  final VoidCallback onRuqyah;

  String _tr(String bn, String en) => lang == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 9,
      mainAxisSpacing: 9,
      childAspectRatio: 1.08,
      children: [
        _EssentialTile(
          icon: Icons.explore_outlined,
          label: _tr('কিবলা', 'Qibla'),
          onTap: onQibla,
        ),
        _EssentialTile(
          icon: Icons.auto_awesome_outlined,
          label: _tr('দু‘আ', 'Dua'),
          onTap: onDua,
        ),
        _EssentialTile(
          icon: Icons.touch_app_outlined,
          label: _tr('তাসবিহ', 'Tasbih'),
          onTap: onTasbih,
        ),
        _EssentialTile(
          icon: Icons.auto_awesome,
          label: _tr('৯৯ নাম', '99 Names'),
          onTap: onNames,
        ),
        _EssentialTile(
          icon: Icons.calendar_month_outlined,
          label: _tr('ক্যালেন্ডার', 'Calendar'),
          onTap: onCalendar,
        ),
        _EssentialTile(
          icon: Icons.shield_outlined,
          label: _tr('রুকইয়াহ', 'Ruqyah'),
          onTap: onRuqyah,
        ),
      ],
    );
  }
}

class _EssentialTile extends StatelessWidget {
  const _EssentialTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: primary),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
