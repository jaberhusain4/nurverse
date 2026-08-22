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

/// New Simple Home: prayer-first, inspired by the information hierarchy of
/// modern prayer apps while retaining NurVerse's own Sea Shore visual system.
class SimpleHomeScreenPrayerV1 extends StatefulWidget {
  const SimpleHomeScreenPrayerV1({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreenPrayerV1> createState() => _SimpleHomeScreenPrayerV1State();
}

class _SimpleHomeScreenPrayerV1State extends State<SimpleHomeScreenPrayerV1> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _loadLastRead();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadLastRead() async {
    try {
      final data = await LastReadService.getLastRead();
      if (mounted) setState(() => _lastRead = data);
    } catch (_) {
      if (mounted) setState(() => _lastRead = null);
    }
  }

  Future<void> _refresh() async {
    await context.read<PrayerController>().refreshLocation();
    await _loadLastRead();
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => page));
    if (mounted) await _refresh();
  }

  String _tr(String bn, String en, String lang) => lang == 'en' ? en : bn;

  String _hijri(String lang) {
    final h = HijriCalendar.now();
    const bn = <String>[
      'মুহররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি', 'জুমাদিউল আউয়াল', 'জুমাদিউস সানি',
      'রজব', 'শাবান', 'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ',
    ];
    const en = <String>[
      'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', 'Jumada al-Awwal', 'Jumada al-Thani',
      'Rajab', 'Sha’ban', 'Ramadan', 'Shawwal', 'Dhul-Qadah', 'Dhul-Hijjah',
    ];
    String bnDigits(int value) => value
        .toString()
        .split('')
        .map((d) => '০১২৩৪৫৬৭৮৯'[int.parse(d)])
        .join();
    final month = lang == 'en' ? en[h.hMonth - 1] : bn[h.hMonth - 1];
    return lang == 'en'
        ? '${h.hDay} $month ${h.hYear}'
        : '${bnDigits(h.hDay)} $month ${bnDigits(h.hYear)}';
  }

  String _countdown(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '--:--:--';
    return raw;
  }

  List<Map<String, dynamic>> _prayers(PrayerController controller) {
    const target = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final out = <Map<String, dynamic>>[];
    for (final key in target) {
      for (final prayer in controller.prayers) {
        final name = '${prayer['name'] ?? ''}'.toLowerCase();
        final bn = '${prayer['nameBn'] ?? ''}'.toLowerCase();
        final match = name.contains(key.toLowerCase()) ||
            (key == 'Fajr' && bn.contains('ফজর')) ||
            (key == 'Dhuhr' && (bn.contains('যোহর') || bn.contains('জুমু'))) ||
            (key == 'Asr' && bn.contains('আসর')) ||
            (key == 'Maghrib' && bn.contains('মাগরিব')) ||
            (key == 'Isha' && bn.contains('ইশা'));
        if (match) {
          out.add(prayer);
          break;
        }
      }
    }
    return out;
  }

  String _prayerLabel(Map<String, dynamic> prayer, String lang) {
    if (lang != 'en') return '${prayer['nameBn'] ?? prayer['name'] ?? ''}';
    return '${prayer['name'] ?? ''}';
  }

  String _timeValue(dynamic value) => value == null ? '--' : value.toString();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final lang = settings.languageCode;
    final prayers = _prayers(controller);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final current = controller.currentPrayer;
    final hasLastRead = _lastRead != null && '${_lastRead!['surahName'] ?? ''}'.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: primary,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
            children: [
              _LocationHeader(
                location: controller.currentLocationName,
                date: DateService.englishDate(),
                lang: lang,
              ),
              const SizedBox(height: 12),
              _PrayerHeroCard(
                lang: lang,
                hijri: _hijri(lang),
                gregorian: DateService.englishDate(),
                currentPrayer: current,
                nextPrayer: controller.nextPrayerName,
                nextPrayerTime: _timeValue(controller.nextPrayerTime),
                remaining: _countdown(controller.timeRemainingForNextPrayer),
                sunrise: _timeValue(controller.sunriseTime),
                sunset: _timeValue(controller.sunsetTime),
                primary: primary,
              ),
              const SizedBox(height: 22),
              _SectionTitle(title: _tr('নামাজের সময়', 'Prayer times', lang)),
              const SizedBox(height: 8),
              _PrayerList(prayers: prayers, currentPrayer: current, lang: lang),
              const SizedBox(height: 22),
              _SectionTitle(title: _tr('প্রয়োজনীয়', 'Essentials', lang)),
              const SizedBox(height: 8),
              _EssentialGrid(
                lang: lang,
                onQibla: () => _open(const QiblaScreen()),
                onDua: () => _open(const DuaScreen()),
                onTasbih: () => _open(const TasbihScreen()),
                onNames: () => _open(const AsmaUlHusnaScreen()),
                onCalendar: () => _open(const CalendarScreen()),
                onRuqyah: () => _open(const RuqyahScreen()),
              ),
              if (hasLastRead) ...[
                const SizedBox(height: 22),
                _SectionTitle(title: _tr('কুরআন চালিয়ে যান', 'Continue Quran', lang)),
                const SizedBox(height: 8),
                ContinueReadingCard(
                  surahName: '${_lastRead!['surahName'] ?? ''}',
                  paraNo: _lastRead!['paraNo'] is int ? _lastRead!['paraNo'] as int : int.tryParse('${_lastRead!['paraNo']}') ?? 1,
                  pageNo: _lastRead!['pageNo'] is int ? _lastRead!['pageNo'] as int : int.tryParse('${_lastRead!['pageNo']}') ?? 1,
                  progress: ((_lastRead!['progress'] is num ? (_lastRead!['progress'] as num).toDouble() : 0.0).clamp(0.0, 1.0)).toDouble(),
                  languageCode: lang,
                  onTap: () => _open(const OnudhabonQuranScreen(openLastRead: true)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({required this.location, required this.date, required this.lang});
  final String location;
  final String date;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.location_on_outlined, color: primary, size: 21),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(location.trim().isEmpty ? 'Locating…' : location.trim(), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(date, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: context.secondaryTextColor, fontSize: 11.5)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.notifications_none_rounded, color: primary, size: 22),
      ],
    );
  }
}

class _PrayerHeroCard extends StatelessWidget {
  const _PrayerHeroCard({
    required this.lang,
    required this.hijri,
    required this.gregorian,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.remaining,
    required this.sunrise,
    required this.sunset,
    required this.primary,
  });

  final String lang;
  final String hijri;
  final String gregorian;
  final String currentPrayer;
  final String nextPrayer;
  final String nextPrayerTime;
  final String remaining;
  final String sunrise;
  final String sunset;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onHero = theme.brightness == Brightness.dark ? Colors.white : Colors.white;
    final seaLight = AppColors.seaBlue;
    final seaDark = AppColors.seaBlueDark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 19, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [seaLight, seaDark],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: seaDark.withValues(alpha: .22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hijri, style: TextStyle(color: onHero.withValues(alpha: .96), fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(gregorian, style: TextStyle(color: onHero.withValues(alpha: .83), fontSize: 12.5)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_tr('সূর্যোদয়', 'Sunrise', lang), style: TextStyle(color: onHero.withValues(alpha: .78), fontSize: 10.5)),
                  Text(sunrise, style: TextStyle(color: onHero, fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(_tr('সূর্যাস্ত', 'Sunset', lang), style: TextStyle(color: onHero.withValues(alpha: .78), fontSize: 10.5)),
                  Text(sunset, style: TextStyle(color: onHero, fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 21),
          Text(
            currentPrayer.trim().isEmpty ? _tr('পরবর্তী সালাত', 'Next prayer', lang) : currentPrayer,
            style: TextStyle(color: onHero.withValues(alpha: .86), fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(nextPrayer.isEmpty ? '—' : nextPrayer, style: TextStyle(color: onHero, fontSize: 33, fontWeight: FontWeight.w800, height: 1.05)),
          const SizedBox(height: 6),
          Text(nextPrayerTime, style: TextStyle(color: onHero.withValues(alpha: .94), fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded, size: 17, color: onHero.withValues(alpha: .9)),
                const SizedBox(width: 7),
                Text(_tr('সময় বাকি', 'Time remaining', lang), style: TextStyle(color: onHero.withValues(alpha: .86), fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(width: 9),
                Text(remaining, style: TextStyle(color: onHero, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: .2)),
              ],
            ),
          ),
          const SizedBox(height: 19),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: .18),
          ),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeroMeta(icon: Icons.wb_sunny_outlined, label: _tr('সূর্যোদয়', 'Sunrise', lang), value: sunrise, color: onHero),
              _HeroMeta(icon: Icons.nights_stay_outlined, label: _tr('সূর্যাস্ত', 'Sunset', lang), value: sunset, color: onHero),
            ],
          ),
        ],
      ),
    );
  }

  String _tr(String bn, String en, String lang) => lang == 'en' ? en : bn;
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color.withValues(alpha: .88)),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 9.5, color: color.withValues(alpha: .7))),
            Text(value, style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w800));
  }
}

class _PrayerList extends StatelessWidget {
  const _PrayerList({required this.prayers, required this.currentPrayer, required this.lang});
  final List<Map<String, dynamic>> prayers;
  final String currentPrayer;
  final String lang;

  String _name(Map<String, dynamic> p) => lang == 'en' ? '${p['name'] ?? ''}' : '${p['nameBn'] ?? p['name'] ?? ''}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    if (prayers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(18)),
        child: Text(lang == 'en' ? 'Prayer times are loading…' : 'সালাতের সময় লোড হচ্ছে…', style: theme.textTheme.bodyMedium),
      );
    }

    return Container(
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          for (int i = 0; i < prayers.length; i++) ...[
            _PrayerRow(
              name: _name(prayers[i]),
              start: '${prayers[i]['start'] ?? prayers[i]['time'] ?? '--'}',
              end: '${prayers[i]['end'] ?? '--'}',
              active: '${prayers[i]['name'] ?? ''}'.toLowerCase().contains(currentPrayer.toLowerCase()) || '${prayers[i]['nameBn'] ?? ''}'.contains(currentPrayer),
              primary: primary,
              lang: lang,
            ),
            if (i != prayers.length - 1) Divider(height: 1, indent: 16, endIndent: 16, color: theme.dividerColor.withValues(alpha: .55)),
          ],
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({required this.name, required this.start, required this.end, required this.active, required this.primary, required this.lang});
  final String name;
  final String start;
  final String end;
  final bool active;
  final Color primary;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      color: active ? primary.withValues(alpha: .06) : Colors.transparent,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: active ? primary : theme.dividerColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(name, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, fontWeight: active ? FontWeight.w800 : FontWeight.w600)),
          ),
          Text(
            end == '--' || end.isEmpty ? start : '$start – $end',
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: active ? FontWeight.w800 : FontWeight.w600, color: active ? primary : null),
          ),
        ],
      ),
    );
  }
}

class _EssentialGrid extends StatelessWidget {
  const _EssentialGrid({required this.lang, required this.onQibla, required this.onDua, required this.onTasbih, required this.onNames, required this.onCalendar, required this.onRuqyah});
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
      mainAxisSpacing: 9,
      crossAxisSpacing: 9,
      childAspectRatio: 1.08,
      children: [
        _Essential(icon: Icons.explore_outlined, label: _tr('কিবলা', 'Qibla'), onTap: onQibla),
        _Essential(icon: Icons.auto_awesome_outlined, label: _tr('দু‘আ', 'Dua'), onTap: onDua),
        _Essential(icon: Icons.touch_app_outlined, label: _tr('তাসবিহ', 'Tasbih'), onTap: onTasbih),
        _Essential(icon: Icons.auto_awesome, label: _tr('৯৯ নাম', '99 Names'), onTap: onNames),
        _Essential(icon: Icons.calendar_month_outlined, label: _tr('ক্যালেন্ডার', 'Calendar'), onTap: onCalendar),
        _Essential(icon: Icons.shield_outlined, label: _tr('রুকইয়াহ', 'Ruqyah'), onTap: onRuqyah),
      ],
    );
  }
}

class _Essential extends StatelessWidget {
  const _Essential({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: primary),
            const SizedBox(height: 7),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
