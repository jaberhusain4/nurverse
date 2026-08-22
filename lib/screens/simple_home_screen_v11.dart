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

class SimpleHomeScreenV11 extends StatefulWidget {
  const SimpleHomeScreenV11({super.key, this.onNavigateTab});
  final Function(int)? onNavigateTab;
  @override
  State<SimpleHomeScreenV11> createState() => _SimpleHomeScreenV11State();
}

class _SimpleHomeScreenV11State extends State<SimpleHomeScreenV11>
    with SingleTickerProviderStateMixin {
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  Map<String, dynamic>? _lastRead;
  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
    _loadLastRead();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _motion.dispose();
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
    if (_now.hour < 12) return _l(languageCode, 'শুভ সকাল', 'Good Morning');
    if (_now.hour < 18) return _l(languageCode, 'শুভ বিকেল', 'Good Afternoon');
    return _l(languageCode, 'শুভ সন্ধ্যা', 'Good Evening');
  }

  String _clock() {
    final h = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    return '${h.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')} ${_now.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _hijri(String languageCode) {
    final h = HijriCalendar.now();
    const bn = ['মুহররম','সফর','রবিউল আউয়াল','রবিউস সানি','জুমাদিউল আউয়াল','জুমাদিউস সানি','রজব','শাবান','রমজান','শাওয়াল','জিলকদ','জিলহজ'];
    const en = ['Muharram','Safar','Rabi al-Awwal','Rabi al-Thani','Jumada al-Awwal','Jumada al-Thani','Rajab','Sha’ban','Ramadan','Shawwal','Dhul-Qadah','Dhul-Hijjah'];
    String digits(int v) => v.toString().split('').map((d) => '০১২৩৪৫৬৭৮৯'[int.parse(d)]).join();
    final month = languageCode == 'en' ? en[h.hMonth - 1] : bn[h.hMonth - 1];
    return '${languageCode == 'en' ? h.hDay : digits(h.hDay)} $month ${languageCode == 'en' ? h.hYear : digits(h.hYear)}';
  }

  List<Map<String, dynamic>> _fivePrayers(PrayerController c) {
    const keys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final result = <Map<String, dynamic>>[];
    for (final key in keys) {
      for (final p in c.prayers) {
        final n = (p['name'] ?? '').toString().toLowerCase();
        final b = (p['nameBn'] ?? '').toString().toLowerCase();
        final match = n.contains(key.toLowerCase()) ||
            (key == 'Fajr' && b.contains('ফজর')) ||
            (key == 'Dhuhr' && (b.contains('যোহর') || b.contains('জুমু'))) ||
            (key == 'Asr' && b.contains('আসর')) ||
            (key == 'Maghrib' && b.contains('মাগরিব')) ||
            (key == 'Isha' && b.contains('ইশা'));
        if (match) {
          result.add(p);
          break;
        }
      }
    }
    return result;
  }

  bool _isProhibited(PrayerController c) {
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
    final c = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final lang = settings.languageCode;
    final prayers = _fivePrayers(c);
    final hasLastRead = _lastRead != null && (_lastRead!['surahName']?.toString() ?? '').trim().isNotEmpty;
    final prohibited = _isProhibited(c);
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: primary,
          onRefresh: _refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
            children: [
              _Header(greeting: _greeting(lang), location: c.currentLocationName, hijri: _hijri(lang), lang: lang),
              const SizedBox(height: 14),
              _Hero(now: _now, clock: _clock(), nextPrayer: c.nextPrayerName, nextTime: c.nextPrayerTime, remaining: c.timeRemainingForNextPrayer, currentPrayer: c.currentPrayer, progress: c.prayerProgress, sunrise: c.sunriseTime, sunset: c.sunsetTime, motion: _motion, lang: lang),
              const SizedBox(height: 18),
              _Section(title: _l(lang, 'আজকের সালাত', 'Today’s Prayer'), subtitle: _l(lang, 'পাঁচ ওয়াক্ত এক নজরে', 'Five daily prayers at a glance')),
              const SizedBox(height: 9),
              _PrayerTimeline(prayers: prayers, lang: lang),
              const SizedBox(height: 18),
              _Section(title: _l(lang, 'প্রয়োজনীয়', 'Essentials'), subtitle: _l(lang, 'দৈনন্দিন গুরুত্বপূর্ণ সুবিধা', 'Everyday essentials')),
              const SizedBox(height: 9),
              _Essentials(lang: lang, onQibla: () => _open(const QiblaScreen()), onDua: () => _open(const DuaScreen()), onTasbih: () => _open(const TasbihScreen()), onNames: () => _open(const AsmaUlHusnaScreen()), onCalendar: () => _open(const CalendarScreen()), onRuqyah: () => _open(const RuqyahScreen())),
              if (hasLastRead) ...[
                const SizedBox(height: 18),
                _Section(title: _l(lang, 'কুরআন চালিয়ে যান', 'Continue Quran'), subtitle: _l(lang, 'যেখান থেকে থেমেছিলেন', 'Pick up where you left off')),
                const SizedBox(height: 9),
                ContinueReadingCard(surahName: _lastRead!['surahName']?.toString() ?? '', paraNo: int.tryParse('${_lastRead!['paraNo']}') ?? 1, pageNo: int.tryParse('${_lastRead!['pageNo']}') ?? 1, progress: ((_lastRead!['progress'] is num ? (_lastRead!['progress'] as num).toDouble() : 0.0).clamp(0.0, 1.0)).toDouble(), languageCode: lang, onTap: () => _open(const OnudhabonQuranScreen(openLastRead: true))),
              ],
              const SizedBox(height: 18),
              _Footer(date: DateService.englishDate(), prohibited: prohibited, countdown: _countdown(prohibited ? c.prohibitedEnd : c.prohibitedStart), lang: lang),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting, required this.location, required this.hijri, required this.lang});
  final String greeting, location, hijri, lang;
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final city = location.trim().isEmpty ? (lang == 'en' ? 'Locating your area…' : 'লোকেশন নির্ধারণ হচ্ছে…') : location.trim();
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(greeting, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 21, fontWeight: FontWeight.w800, color: primary, height: 1.05)), const SizedBox(height: 7), Row(children: [Icon(Icons.location_on_outlined, size: 15, color: context.secondaryTextColor), const SizedBox(width: 4), Expanded(child: Text(city, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: context.secondaryTextColor)))])])), const SizedBox(width: 10), Container(constraints: const BoxConstraints(maxWidth: 145), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: primary.withValues(alpha: .07), borderRadius: BorderRadius.circular(14)), child: Text(hijri, textAlign: TextAlign.end, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.primaryTextColor))) ]);
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.now, required this.clock, required this.nextPrayer, required this.nextTime, required this.remaining, required this.currentPrayer, required this.progress, required this.sunrise, required this.sunset, required this.motion, required this.lang});
  final DateTime now; final String clock, nextPrayer, nextTime, remaining, currentPrayer, sunrise, sunset, lang; final double progress; final Animation<double> motion;
  @override
  Widget build(BuildContext context) {
    final hour = now.hour + now.minute / 60;
    final night = hour < 5 || hour >= 19.5;
    final dawn = hour >= 5 && hour < 7;
    final dusk = hour >= 16.5 && hour < 19.5;
    final sea = Theme.of(context).colorScheme.primary;
    final palette = _ScenePalette.forTime(hour);
    return AnimatedBuilder(animation: motion, builder: (context, _) => Container(height: 370, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .16), blurRadius: 28, offset: const Offset(0, 14))]), child: Stack(children: [Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [palette.top, palette.mid, palette.bottom])))), Positioned.fill(child: CustomPaint(painter: _DesertPainter(palette: palette, t: motion.value, night: night, dawn: dawn, dusk: dusk))), Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: .04), Colors.black.withValues(alpha: .40)])))), Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 17), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(clock, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: .3, fontFeatures: const [FontFeature.tabularFigures()])), const Spacer(), _SceneBadge(text: night ? (lang == 'en' ? 'NIGHT' : 'রাত') : dusk ? (lang == 'en' ? 'GOLDEN HOUR' : 'সন্ধ্যা') : (lang == 'en' ? 'DAYLIGHT' : 'দিন'))]), const Spacer(), Text(nextPrayer.isEmpty ? '--' : nextPrayer, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1.0)), const SizedBox(height: 4), Text(nextTime.isEmpty ? '--:--' : nextTime, style: TextStyle(color: Colors.white.withValues(alpha: .84), fontSize: 13.5, fontWeight: FontWeight.w600)), const SizedBox(height: 9), Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: Text(remaining.isEmpty ? '--:--:--' : remaining, style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontSize: 35, fontWeight: FontWeight.w500, height: .95, letterSpacing: -.8, fontFeatures: const [FontFeature.tabularFigures()]))), if (currentPrayer.isNotEmpty) Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(lang == 'en' ? 'NOW' : 'এখন', style: TextStyle(color: Colors.white.withValues(alpha: .55), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)), const SizedBox(height: 2), Text(currentPrayer, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))])]), const SizedBox(height: 11), _DayArc(value: progress.clamp(0.0, 1.0).toDouble(), accent: sea), const SizedBox(height: 6), Row(children: [_SunMeta(icon: Icons.wb_sunny_outlined, label: lang == 'en' ? 'Sunrise' : 'সূর্যোদয়', value: sunrise), const Spacer(), _SunMeta(icon: Icons.nightlight_round, label: lang == 'en' ? 'Sunset' : 'সূর্যাস্ত', value: sunset, end: true)])]))])));
  }
}

class _SceneBadge extends StatelessWidget { const _SceneBadge({required this.text}); final String text; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: Colors.black.withValues(alpha: .12), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withValues(alpha: .12))), child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800, letterSpacing: .9))); }

class _SunMeta extends StatelessWidget { const _SunMeta({required this.icon, required this.label, required this.value, this.end = false}); final IconData icon; final String label, value; final bool end; @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [if (!end) Icon(icon, size: 15, color: Colors.white.withValues(alpha: .72)), if (!end) const SizedBox(width: 5), Column(crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.white.withValues(alpha: .58), fontSize: 9, fontWeight: FontWeight.w600)), const SizedBox(height: 1), Text(value, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()]))]), if (end) const SizedBox(width: 5), if (end) Icon(icon, size: 15, color: Colors.white.withValues(alpha: .72))]); }

class _ScenePalette { const _ScenePalette(this.top, this.mid, this.bottom, this.sun, this.sandFar, this.sandNear); final Color top, mid, bottom, sun, sandFar, sandNear; static _ScenePalette forTime(double h) { if (h < 5 || h >= 19.5) return const _ScenePalette(Color(0xFF061B2C), Color(0xFF0D3A57), Color(0xFF103F59), Color(0xFFBDEBFF), Color(0xFF173B4A), Color(0xFF071F2C)); if (h < 7) return const _ScenePalette(Color(0xFF155B78), Color(0xFF3C9CB0), Color(0xFFE3B07B), Color(0xFFFFE0A4), Color(0xFFB47757), Color(0xFF513A35)); if (h >= 16.5) return const _ScenePalette(Color(0xFF176B91), Color(0xFF5BA6B7), Color(0xFFD8896D), Color(0xFFFFD08A), Color(0xFF9B6657), Color(0xFF493B39)); return const _ScenePalette(Color(0xFF14729B), Color(0xFF51B8D1), Color(0xFFB7D5C8), Color(0xFFFFF1BD), Color(0xFFC59A68), Color(0xFF66503F)); } }

class _DesertPainter extends CustomPainter {
  const _DesertPainter({required this.palette, required this.t, required this.night, required this.dawn, required this.dusk});
  final _ScenePalette palette; final double t; final bool night, dawn, dusk;
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final sunPos = Offset(w * .77, h * (night ? .22 : dusk ? .38 : .20));
    canvas.drawCircle(sunPos, night ? 27 : 31, Paint()..color = palette.sun.withValues(alpha: night ? .18 : .10));
    canvas.drawCircle(sunPos, night ? 17 : 20, Paint()..color = palette.sun.withValues(alpha: night ? .88 : .96));
    if (night) {
      final star = Paint()..color = Colors.white.withValues(alpha: .45);
      for (var i = 0; i < 24; i++) { final x = ((i * 83) % 100) / 100 * w; final y = ((i * 47) % 48) / 100 * h; canvas.drawCircle(Offset(x, y), i % 4 == 0 ? 1.5 : .8, star); }
    }
    _cloud(canvas, Offset(w * (.17 + .05 * t), h * .20), 1.0, night ? .08 : .30);
    _cloud(canvas, Offset(w * (.55 - .07 * t), h * .29), .72, night ? .05 : .20);
    _cloud(canvas, Offset(w * (.80 + .03 * t), h * .14), .52, night ? .035 : .14);
    _dune(canvas, w, h, h * .68, palette.sandFar, .10);
    _dune(canvas, w, h, h * .76, palette.sandFar.withValues(alpha: .82), .13);
    _dune(canvas, w, h, h * .84, palette.sandNear, .16);
    final oasis = Offset(w * .66, h * .79);
    canvas.drawOval(Rect.fromCenter(center: oasis, width: w * .27, height: h * .055), Paint()..color = const Color(0xFF4FA5A1).withValues(alpha: .78));
    canvas.drawOval(Rect.fromCenter(center: oasis.translate(0, 2), width: w * .20, height: h * .025), Paint()..color = const Color(0xFFB9E6D7).withValues(alpha: .35));
    _palm(canvas, Offset(w * .18, h * .68), .88, const Color(0xFF0D4E56));
    _palm(canvas, Offset(w * .83, h * .69), .68, const Color(0xFF14525A));
    _palm(canvas, Offset(w * .59, h * .72), .54, const Color(0xFF236A67));
    final camelX = w * (.38 + .025 * (t < .5 ? t * 2 : 2 - t * 2));
    _camel(canvas, Offset(camelX, h * .77), .85, const Color(0xFF4A3B31));
  }

  void _cloud(Canvas canvas, Offset c, double s, double opacity) {
    final p = Paint()..color = Colors.white.withValues(alpha: opacity);
    canvas.drawCircle(c.translate(-25 * s, 4), 18 * s, p);
    canvas.drawCircle(c.translate(0, -8), 25 * s, p);
    canvas.drawCircle(c.translate(24 * s, 4), 17 * s, p);
    canvas.drawOval(Rect.fromCenter(center: c.translate(0, 9), width: 72 * s, height: 26 * s), p);
    final shade = Paint()..color = Colors.white.withValues(alpha: opacity * .25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(Rect.fromCenter(center: c.translate(0, 11), width: 78 * s, height: 20 * s), shade);
  }

  void _dune(Canvas canvas, double w, double h, double y, Color color, double curve) { final p = Path()..moveTo(0, y)..quadraticBezierTo(w * .22, y - h * curve, w * .46, y + h * curve * .35)..quadraticBezierTo(w * .72, y + h * curve, w, y - h * curve * .18)..lineTo(w, h)..lineTo(0, h)..close(); canvas.drawPath(p, Paint()..color = color); }

  void _palm(Canvas canvas, Offset base, double s, Color color) {
    final trunk = Paint()..color = color.withValues(alpha: .92)..strokeWidth = 4.5 * s..strokeCap = StrokeCap.round;
    canvas.drawLine(base, base.translate(4 * s, -55 * s), trunk);
    final top = base.translate(4 * s, -55 * s);
    final leaf = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5 * s..strokeCap = StrokeCap.round;
    for (final end in [Offset(-24, -15), Offset(-15, -23), Offset(-5, -27), Offset(8, -25), Offset(20, -17), Offset(26, -7)]) {
      final e = top + end.scale(s, s);
      final path = Path()..moveTo(top.dx, top.dy)..quadraticBezierTo((top.dx + e.dx) / 2, top.dy - 7 * s, e.dx, e.dy);
      canvas.drawPath(path, leaf);
    }
  }

  void _camel(Canvas canvas, Offset base, double s, Color color) {
    final p = Paint()..color = color;
    canvas.drawOval(Rect.fromLTWH(base.dx - 30 * s, base.dy - 18 * s, 55 * s, 19 * s), p);
    canvas.drawCircle(base.translate(12 * s, -19 * s), 11 * s, p);
    final neck = Path()..moveTo(base.dx + 7 * s, base.dy - 12 * s)..quadraticBezierTo(base.dx + 18 * s, base.dy - 31 * s, base.dx + 15 * s, base.dy - 41 * s)..lineTo(base.dx + 23 * s, base.dy - 43 * s)..quadraticBezierTo(base.dx + 28 * s, base.dy - 22 * s, base.dx + 21 * s, base.dy - 9 * s)..close();
    canvas.drawPath(neck, p);
    for (final dx in [-18.0, -2.0, 17.0]) canvas.drawRect(Rect.fromLTWH(base.dx + dx * s, base.dy - 2 * s, 4 * s, 25 * s), p);
    canvas.drawCircle(base.translate(-5 * s, -19 * s), 7 * s, p);
  }

  @override
  bool shouldRepaint(covariant _DesertPainter old) => old.t != t || old.palette != palette;
}

class _DayArc extends StatelessWidget { const _DayArc({required this.value, required this.accent}); final double value; final Color accent; @override Widget build(BuildContext context) => SizedBox(height: 42, width: double.infinity, child: CustomPaint(painter: _ArcPainter(value, accent))); }

class _ArcPainter extends CustomPainter {
  const _ArcPainter(this.value, this.accent); final double value; final Color accent;
  @override void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(8, 4, size.width - 16, size.height * 1.9);
    final bg = Paint()..color = Colors.white.withValues(alpha: .18)..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 3.14159, 3.14159, false, bg);
    final fg = Paint()..color = accent.withValues(alpha: .95)..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 3.14159, 3.14159 * value.clamp(0, 1), false, fg);
    final x = 8 + (size.width - 16) * value.clamp(0, 1);
    final y = 9 + 19 * (1 - value.clamp(0, 1));
    canvas.drawCircle(Offset(x, y), 9, Paint()..color = accent.withValues(alpha: .22));
    canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white);
  }
  @override bool shouldRepaint(covariant _ArcPainter old) => old.value != value || old.accent != accent;
}

class _Section extends StatelessWidget { const _Section({required this.title, required this.subtitle}); final String title, subtitle; @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(fontSize: 11.5, color: context.secondaryTextColor, fontWeight: FontWeight.w500))]); }

class _PrayerTimeline extends StatelessWidget {
  const _PrayerTimeline({required this.prayers, required this.lang}); final List<Map<String, dynamic>> prayers; final String lang;
  @override Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(22)), child: Column(children: List.generate(5, (i) {
      final p = i < prayers.length ? prayers[i] : const <String, dynamic>{}; final current = p['isCurrent'] == true;
      final name = lang == 'en' ? (p['name']?.toString() ?? '--') : (p['nameBn']?.toString() ?? '--'); final time = p['start']?.toString() ?? '--:--';
      return Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: current ? primary.withValues(alpha: .065) : Colors.transparent, border: i == 0 ? null : Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: .5), width: .6))), child: Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: primary.withValues(alpha: current ? .13 : .07), borderRadius: BorderRadius.circular(11)), child: Icon(current ? Icons.bolt_rounded : Icons.access_time_rounded, size: 18, color: current ? primary : context.secondaryTextColor)), const SizedBox(width: 11), Expanded(child: Row(children: [Text(name, style: TextStyle(fontSize: 14, fontWeight: current ? FontWeight.w800 : FontWeight.w700)), if (current) ...[const SizedBox(width: 7), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(999)), child: Text(lang == 'en' ? 'NOW' : 'এখন', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: primary)))] ])), Text(time, style: TextStyle(fontSize: 15, fontWeight: current ? FontWeight.w800 : FontWeight.w600, color: current ? primary : context.primaryTextColor, fontFeatures: const [FontFeature.tabularFigures()]))]));
    })));
  }
}

class _Essentials extends StatelessWidget {
  const _Essentials({required this.lang, required this.onQibla, required this.onDua, required this.onTasbih, required this.onNames, required this.onCalendar, required this.onRuqyah});
  final String lang; final VoidCallback onQibla, onDua, onTasbih, onNames, onCalendar, onRuqyah;
  @override Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final items = <_Item>[_Item(Icons.explore_rounded, lang == 'en' ? 'Qibla' : 'কিবলা', onQibla), _Item(Icons.favorite_rounded, lang == 'en' ? 'Dua' : 'দোয়া', onDua), _Item(Icons.touch_app_rounded, lang == 'en' ? 'Tasbih' : 'তাসবিহ', onTasbih), _Item(Icons.auto_awesome_rounded, lang == 'en' ? '99 Names' : '৯৯ নাম', onNames), _Item(Icons.calendar_month_rounded, lang == 'en' ? 'Calendar' : 'ক্যালেন্ডার', onCalendar), _Item(Icons.health_and_safety_rounded, lang == 'en' ? 'Ruqyah' : 'রুকইয়াহ', onRuqyah)];
    return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.15), itemBuilder: (_, i) => Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(20), onTap: items[i].onTap, child: Ink(decoration: BoxDecoration(color: primary.withValues(alpha: .055), borderRadius: BorderRadius.circular(20)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: primary.withValues(alpha: .10), shape: BoxShape.circle), child: Icon(items[i].icon, color: primary, size: 20)), const SizedBox(height: 7), Text(items[i].title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: context.primaryTextColor))])))));
  }
}
class _Item { const _Item(this.icon, this.title, this.onTap); final IconData icon; final String title; final VoidCallback onTap; }

class _Footer extends StatelessWidget {
  const _Footer({required this.date, required this.prohibited, required this.countdown, required this.lang}); final String date, countdown, lang; final bool prohibited;
  @override Widget build(BuildContext context) { final primary = Theme.of(context).colorScheme.primary; return Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(20)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(lang == 'en' ? 'Date' : 'তারিখ', style: TextStyle(fontSize: 10, color: context.secondaryTextColor)), const SizedBox(height: 2), Text(date, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: context.primaryTextColor))]), const SizedBox(width: 14), Container(width: 1, height: 30, color: Theme.of(context).dividerColor), const SizedBox(width: 14), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(prohibited ? (lang == 'en' ? 'Prohibited now' : 'নিষিদ্ধ সময় চলছে') : (lang == 'en' ? 'Next prohibited' : 'পরবর্তী নিষিদ্ধ সময়'), style: TextStyle(fontSize: 10, color: context.secondaryTextColor)), const SizedBox(height: 2), Text(countdown, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: primary, fontFeatures: const [FontFeature.tabularFigures()]))])])); }
}
