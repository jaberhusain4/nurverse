import 'dart:async';
import 'dart:ui';

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

class SimpleHomeScreenV3 extends StatefulWidget {
  const SimpleHomeScreenV3({super.key, this.onNavigateTab});
  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreenV3> createState() => _SimpleHomeScreenV3State();
}

class _SimpleHomeScreenV3State extends State<SimpleHomeScreenV3> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _loadLastRead();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadLastRead() async {
    try {
      final value = await LastReadService.getLastRead();
      if (mounted) setState(() => _lastRead = value);
    } catch (_) {
      if (mounted) setState(() => _lastRead = null);
    }
  }

  Future<void> _refreshHome() async {
    await context.read<PrayerController>().refreshLocation();
    await _loadLastRead();
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
    if (mounted) await _refreshHome();
  }

  String _l(String languageCode, String bn, String en) => languageCode == 'en' ? en : bn;

  String _greeting(String languageCode) {
    if (languageCode == 'en') {
      if (_now.hour < 12) return 'Good Morning';
      if (_now.hour < 18) return 'Good Afternoon';
      return 'Good Evening';
    }
    if (_now.hour < 12) return 'শুভ সকাল';
    if (_now.hour < 18) return 'শুভ বিকেল';
    return 'শুভ সন্ধ্যা';
  }

  String _clock() {
    final h = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    return '${h.toString()}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')} ${_now.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _hijri(String languageCode) {
    final h = HijriCalendar.now();
    const bn = ['মুহররম','সফর','রবিউল আউয়াল','রবিউস সানি','জুমাদিউল আউয়াল','জুমাদিউস সানি','রজব','শাবান','রমজান','শাওয়াল','জিলকদ','জিলহজ'];
    const en = ['Muharram','Safar','Rabi al-Awwal','Rabi al-Thani','Jumada al-Awwal','Jumada al-Thani','Rajab','Sha’ban','Ramadan','Shawwal','Dhul-Qadah','Dhul-Hijjah'];
    String bnDigits(int n) => n.toString().split('').map((d) => '০১২৩৪৫৬৭৮৯'[int.parse(d)]).join();
    final month = languageCode == 'en' ? en[h.hMonth - 1] : bn[h.hMonth - 1];
    return '${languageCode == 'en' ? h.hDay : bnDigits(h.hDay)} $month ${languageCode == 'en' ? h.hYear : bnDigits(h.hYear)}';
  }

  List<Map<String, dynamic>> _prayers(PrayerController controller) {
    const keys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final result = <Map<String, dynamic>>[];
    for (final key in keys) {
      for (final p in controller.prayers) {
        final name = (p['name'] ?? '').toString().toLowerCase();
        final bn = (p['nameBn'] ?? '').toString();
        final match = name.contains(key.toLowerCase()) ||
            (key == 'Fajr' && bn.contains('ফজর')) ||
            (key == 'Dhuhr' && (bn.contains('যোহর') || bn.contains('জুমু'))) ||
            (key == 'Asr' && bn.contains('আসর')) ||
            (key == 'Maghrib' && bn.contains('মাগরিব')) ||
            (key == 'Isha' && bn.contains('ইশা'));
        if (match) {
          result.add(p);
          break;
        }
      }
    }
    return result;
  }

  bool _prohibited(PrayerController c) {
    final start = c.prohibitedStart;
    final end = c.prohibitedEnd;
    return start != null && end != null && !_now.isBefore(start) && _now.isBefore(end);
  }

  String _countdown(DateTime? target) {
    if (target == null) return '--:--:--';
    final d = target.difference(_now);
    if (d.isNegative) return '00:00:00';
    final s = d.inSeconds;
    return '${(s ~/ 3600).toString().padLeft(2, '0')}:${((s % 3600) ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final languageCode = settings.languageCode;
    final prayers = _prayers(controller);
    final hasLastRead = _lastRead != null && (_lastRead!['surahName']?.toString() ?? '').trim().isNotEmpty;
    final activeProhibited = _prohibited(controller);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: _refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
            children: [
              _Header(greeting: _greeting(languageCode), location: controller.currentLocationName, date: _hijri(languageCode), languageCode: languageCode),
              const SizedBox(height: 12),
              _Hero(
                clock: _clock(),
                nextPrayer: controller.nextPrayerName,
                nextPrayerTime: controller.nextPrayerTime,
                remaining: controller.timeRemainingForNextPrayer,
                progress: controller.prayerProgress,
                currentPrayer: controller.currentPrayer,
                sunrise: controller.sunriseTime,
                sunset: controller.sunsetTime,
                languageCode: languageCode,
                hour: _now.hour,
              ),
              const SizedBox(height: 12),
              _PrayerStrip(prayers: prayers, languageCode: languageCode),
              const SizedBox(height: 15),
              _SectionTitle(_l(languageCode, 'প্রয়োজনীয়', 'Essentials')),
              const SizedBox(height: 7),
              _Essentials(
                languageCode: languageCode,
                onQibla: () => _open(const QiblaScreen()),
                onDua: () => _open(const DuaScreen()),
                onTasbih: () => _open(const TasbihScreen()),
                onNames: () => _open(const AsmaUlHusnaScreen()),
                onCalendar: () => _open(const CalendarScreen()),
                onRuqyah: () => _open(const RuqyahScreen()),
              ),
              if (hasLastRead) ...[
                const SizedBox(height: 16),
                _SectionTitle(_l(languageCode, 'কুরআন চালিয়ে যান', 'Continue Quran')),
                const SizedBox(height: 7),
                ContinueReadingCard(
                  surahName: _lastRead!['surahName']?.toString() ?? '',
                  paraNo: _lastRead!['paraNo'] is int ? _lastRead!['paraNo'] as int : int.tryParse('${_lastRead!['paraNo']}') ?? 1,
                  pageNo: _lastRead!['pageNo'] is int ? _lastRead!['pageNo'] as int : int.tryParse('${_lastRead!['pageNo']}') ?? 1,
                  progress: ((_lastRead!['progress'] is num ? (_lastRead!['progress'] as num).toDouble() : 0).clamp(0.0, 1.0)).toDouble(),
                  languageCode: languageCode,
                  onTap: () => _open(const OnudhabonQuranScreen(openLastRead: true)),
                ),
              ],
              const SizedBox(height: 14),
              _RestrictionCard(
                active: activeProhibited,
                countdown: _countdown(activeProhibited ? controller.prohibitedEnd : controller.prohibitedStart),
                languageCode: languageCode,
              ),
              const SizedBox(height: 12),
              _Footer(date: DateService.englishDate(), sunrise: controller.sunriseTime, sunset: controller.sunsetTime, languageCode: languageCode),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting, required this.location, required this.date, required this.languageCode});
  final String greeting, location, date, languageCode;

  @override
  Widget build(BuildContext context) {
    final secondary = context.secondaryTextColor;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(greeting, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 21, height: 1.15, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary)),
      const SizedBox(height: 5),
      Row(children: [
        Icon(Icons.location_on_rounded, size: 16, color: secondary),
        const SizedBox(width: 5),
        Expanded(child: Text(location.trim().isEmpty ? (languageCode == 'en' ? 'Locating…' : 'লোকেশন নির্ধারণ হচ্ছে…') : location.trim(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 13.5))),
        const SizedBox(width: 8),
        Text(date, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 13)),
      ]),
    ]);
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.clock, required this.nextPrayer, required this.nextPrayerTime, required this.remaining, required this.progress, required this.currentPrayer, required this.sunrise, required this.sunset, required this.languageCode, required this.hour});
  final String clock, nextPrayer, nextPrayerTime, remaining, currentPrayer, sunrise, sunset, languageCode;
  final double progress;
  final int hour;

  String _l(String bn, String en) => languageCode == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    final isNight = hour < 5 || hour >= 19;
    final top = isNight ? const Color(0xFF0B2039) : const Color(0xFF43B7E8);
    final bottom = isNight ? const Color(0xFF15334F) : const Color(0xFFE8F7FC);
    final safe = progress.clamp(0.0, 1.0).toDouble();

    return Container(
      height: 318,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom]),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .10), blurRadius: 22, offset: const Offset(0, 9))],
      ),
      child: Stack(children: [
        Positioned(right: 34, top: 35, child: Icon(isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded, size: 46, color: Colors.white.withValues(alpha: .20))),
        Positioned(left: 0, right: 0, bottom: -25, child: CustomPaint(size: const Size(double.infinity, 160), painter: _LandscapePainter(dark: isNight))),
        Padding(
          padding: const EdgeInsets.fromLTRB(19, 16, 19, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_l('পরের সালাত', 'NEXT PRAYER'), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            const Spacer(),
            Text(nextPrayer.isEmpty ? '--' : nextPrayer, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(nextPrayerTime.isEmpty ? '--:--' : nextPrayerTime, style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 13),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: Text(remaining.isEmpty ? '--:--:--' : remaining, style: const TextStyle(color: Colors.white, fontSize: 38, height: .95, fontWeight: FontWeight.w300, fontFeatures: [FontFeature.tabularFigures()]))),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_l('এখন', 'NOW'), style: TextStyle(color: Colors.white.withValues(alpha: .70), fontSize: 10.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(clock, style: const TextStyle(color: Colors.white, fontFamily: 'sans-serif-condensed', fontSize: 15, letterSpacing: 1.0, fontFeatures: [FontFeature.tabularFigures()])),
              ]),
            ]),
            const SizedBox(height: 12),
            ClipRRect(borderRadius: BorderRadius.circular(50), child: LinearProgressIndicator(minHeight: 6, value: safe, backgroundColor: Colors.white.withValues(alpha: .16), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
            const SizedBox(height: 10),
            Row(children: [
              _Pill(Icons.mosque_rounded, currentPrayer.isEmpty ? '--' : currentPrayer),
              const Spacer(),
              _SmallTime(_l('সূর্যোদয়', 'Sunrise'), sunrise),
              const SizedBox(width: 10),
              _SmallTime(_l('সূর্যাস্ত', 'Sunset'), sunset),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  const _LandscapePainter({required this.dark});
  final bool dark;
  @override
  void paint(Canvas canvas, Size size) {
    final ground = dark ? const Color(0xFF081422) : const Color(0xFF24546A);
    final p = Paint()..color = ground.withValues(alpha: .95);
    final path = Path()..moveTo(0, size.height * .35)..quadraticBezierTo(size.width * .25, size.height * .08, size.width * .48, size.height * .35)..quadraticBezierTo(size.width * .72, size.height * .06, size.width, size.height * .32)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(path, p);
  }
  @override
  bool shouldRepaint(covariant _LandscapePainter oldDelegate) => oldDelegate.dark != dark;
}

class _PrayerStrip extends StatelessWidget {
  const _PrayerStrip({required this.prayers, required this.languageCode});
  final List<Map<String, dynamic>> prayers;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return Row(children: List.generate(5, (i) {
      final p = i < prayers.length ? prayers[i] : const <String, dynamic>{};
      final current = p['isCurrent'] == true;
      final name = languageCode == 'en' ? (p['name']?.toString() ?? '--') : (p['nameBn']?.toString() ?? '--');
      return Expanded(child: Container(
        margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
        decoration: BoxDecoration(color: current ? primary.withValues(alpha: .10) : context.cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: current ? primary.withValues(alpha: .22) : primary.withValues(alpha: .06))),
        child: Column(children: [
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: current ? primary : secondary, fontSize: 11.5, fontWeight: current ? FontWeight.w800 : FontWeight.w600)),
          const SizedBox(height: 4),
          Text(p['start']?.toString() ?? '--:--', style: TextStyle(color: current ? primary : context.primaryTextColor, fontSize: 11.5, fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()])),
        ]),
      ));
    }));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w800));
}

class _Essentials extends StatelessWidget {
  const _Essentials({required this.languageCode, required this.onQibla, required this.onDua, required this.onTasbih, required this.onNames, required this.onCalendar, required this.onRuqyah});
  final String languageCode;
  final VoidCallback onQibla, onDua, onTasbih, onNames, onCalendar, onRuqyah;
  String _l(String bn, String en) => languageCode == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    final items = [
      _Item(Icons.explore_rounded, _l('কিবলা', 'Qibla'), onQibla),
      _Item(Icons.favorite_rounded, _l('দোয়া', 'Dua'), onDua),
      _Item(Icons.touch_app_rounded, _l('তাসবিহ', 'Tasbih'), onTasbih),
      _Item(Icons.auto_awesome_rounded, _l('৯৯ নাম', '99 Names'), onNames),
      _Item(Icons.calendar_month_rounded, _l('ক্যালেন্ডার', 'Calendar'), onCalendar),
      _Item(Icons.health_and_safety_rounded, _l('রুকইয়াহ', 'Ruqyah'), onRuqyah),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.18),
      itemBuilder: (_, i) => _Tile(item: items[i]),
    );
  }
}

class _Item {
  const _Item(this.icon, this.title, this.onTap);
  final IconData icon;
  final String title;
  final VoidCallback onTap;
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item});
  final _Item item;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(color: primary.withValues(alpha: .055), borderRadius: BorderRadius.circular(18), border: Border.all(color: primary.withValues(alpha: .10))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(color: primary.withValues(alpha: .10), shape: BoxShape.circle), child: Icon(item.icon, color: primary, size: 19)),
            const SizedBox(height: 5),
            Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: context.primaryTextColor, fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

class _RestrictionCard extends StatelessWidget {
  const _RestrictionCard({required this.active, required this.countdown, required this.languageCode});
  final bool active;
  final String countdown, languageCode;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: primary.withValues(alpha: .08))),
      child: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)), child: Icon(active ? Icons.block_rounded : Icons.schedule_rounded, color: primary, size: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(active ? (languageCode == 'en' ? 'Prohibited time now' : 'নিষিদ্ধ সময় চলছে') : (languageCode == 'en' ? 'Next prohibited time' : 'পরবর্তী নিষিদ্ধ সময়'), style: TextStyle(color: context.primaryTextColor, fontSize: 12.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(languageCode == 'en' ? 'Live countdown' : 'লাইভ কাউন্টডাউন', style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5)),
        ])),
        Text(countdown, style: TextStyle(color: primary, fontFamily: 'sans-serif-condensed', fontSize: 19, letterSpacing: 1.0, fontFeatures: const [FontFeature.tabularFigures()])),
      ]),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.date, required this.sunrise, required this.sunset, required this.languageCode});
  final String date, sunrise, sunset, languageCode;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    final english = languageCode == 'en';
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: primary.withValues(alpha: .07))),
      child: Row(children: [
        Expanded(child: Row(children: [
          Icon(Icons.wb_twilight_rounded, size: 18, color: primary),
          const SizedBox(width: 8),
          _FooterTime(english ? 'Sunrise' : 'সূর্যোদয়', sunrise, secondary),
          const SizedBox(width: 14),
          _FooterTime(english ? 'Sunset' : 'সূর্যাস্ত', sunset, secondary),
        ])),
        Container(width: 1, height: 32, color: Theme.of(context).dividerColor.withValues(alpha: .55)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(english ? 'Date' : 'তারিখ', style: TextStyle(fontSize: 10.5, color: secondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(date, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
        ]),
      ]),
    );
  }
}

class _FooterTime extends StatelessWidget {
  const _FooterTime(this.label, this.value, this.secondary);
  final String label, value;
  final Color secondary;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 10.5, color: secondary, fontWeight: FontWeight.w600)),
    const SizedBox(height: 1),
    Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()])),
  ]);
}

class _Pill extends StatelessWidget {
  const _Pill(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .11), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: Colors.white), const SizedBox(width: 5), Text(text, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800))]));
}

class _SmallTime extends StatelessWidget {
  const _SmallTime(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(label, style: TextStyle(color: Colors.white.withValues(alpha: .60), fontSize: 10, fontWeight: FontWeight.w700)), const SizedBox(height: 1), Text(value, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800))]);
}
