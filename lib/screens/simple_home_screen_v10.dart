import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../providers/settings_provider.dart';
import '../services/date_service.dart';
import '../services/jamaat_service.dart';
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

class SimpleHomeScreenV10 extends StatefulWidget {
  const SimpleHomeScreenV10({super.key, this.onNavigateTab});
  final Function(int)? onNavigateTab;
  @override
  State<SimpleHomeScreenV10> createState() => _SimpleHomeScreenV10State();
}

class _SimpleHomeScreenV10State extends State<SimpleHomeScreenV10> with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat(reverse: true);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() => _now = DateTime.now()); });
    _loadLastRead();
  }

  @override
  void dispose() { _clockTimer?.cancel(); _motion.dispose(); super.dispose(); }

  Future<void> _loadLastRead() async {
    try { final value = await LastReadService.getLastRead(); if (mounted) setState(() => _lastRead = value); }
    catch (_) { if (mounted) setState(() => _lastRead = null); }
  }

  Future<void> _refreshHome() async { await context.read<PrayerController>().refreshLocation(); await _loadLastRead(); }
  Future<void> _open(Widget screen) async { await Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => screen)); if (mounted) await _refreshHome(); }
  String _tr(String bn, String en, String languageCode) => languageCode == 'en' ? en : bn;
  String _greeting(String languageCode) { if (_now.hour < 12) return _tr('শুভ সকাল', 'Good Morning', languageCode); if (_now.hour < 16) return _tr('শুভ দুপুর', 'Good Afternoon', languageCode); if (_now.hour < 19) return _tr('শুভ সন্ধ্যা', 'Good Evening', languageCode); return _tr('শুভ রাত্রি', 'Good Night', languageCode); }
  String _clock(bool is24Hour) { final minute = _now.minute.toString().padLeft(2, '0'); if (is24Hour) return '${_now.hour.toString().padLeft(2, '0')}:$minute'; final hour = _now.hour % 12 == 0 ? 12 : _now.hour % 12; return '$hour:$minute ${_now.hour >= 12 ? 'PM' : 'AM'}'; }
  String _hijri(String languageCode) {
    final h = HijriCalendar.now();
    const bn = <String>['মুহররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি', 'জুমাদিউল আউয়াল', 'জুমাদিউস সানি', 'রজব', 'শাবান', 'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ'];
    const en = <String>['Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', 'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha’ban', 'Ramadan', 'Shawwal', 'Dhul-Qadah', 'Dhul-Hijjah'];
    String bnDigits(int value) => value.toString().split('').map((d) => '০১২৩৪৫৬৭৮৯'[int.parse(d)]).join();
    final month = languageCode == 'en' ? en[h.hMonth - 1] : bn[h.hMonth - 1];
    final day = languageCode == 'en' ? '${h.hDay}' : bnDigits(h.hDay);
    final year = languageCode == 'en' ? '${h.hYear}' : bnDigits(h.hYear);
    return '$day $month $year';
  }

  List<Map<String, dynamic>> _fivePrayers(PrayerController controller) {
    const keys = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final result = <Map<String, dynamic>>[];
    for (final key in keys) {
      for (final prayer in controller.prayers) {
        final name = (prayer['name'] ?? '').toString().toLowerCase();
        final bn = (prayer['nameBn'] ?? '').toString().toLowerCase();
        final matches = name.contains(key.toLowerCase()) || (key == 'Fajr' && bn.contains('ফজর')) || (key == 'Dhuhr' && (bn.contains('যোহর') || bn.contains('জুমু'))) || (key == 'Asr' && bn.contains('আসর')) || (key == 'Maghrib' && bn.contains('মাগরিব')) || (key == 'Isha' && bn.contains('ইশা'));
        if (matches) { result.add(prayer); break; }
      }
    }
    return result;
  }

  bool _isProhibited(PrayerController controller) { final start = controller.prohibitedStart; final end = controller.prohibitedEnd; return start != null && end != null && !_now.isBefore(start) && _now.isBefore(end); }
  String _countdown(DateTime? target) { if (target == null) return '--:--:--'; final d = target.difference(_now); if (d.isNegative) return '00:00:00'; final total = d.inSeconds; return '${(total ~/ 3600).toString().padLeft(2, '0')}:${((total % 3600) ~/ 60).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')}'; }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final languageCode = settings.languageCode;
    final prayers = _fivePrayers(controller);
    final hasLastRead = _lastRead != null && (_lastRead!['surahName']?.toString() ?? '').trim().isNotEmpty;
    final prohibitedNow = _isProhibited(controller);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(bottom: false, child: RefreshIndicator(color: AppColors.seaBlueDark, onRefresh: _refreshHome, child: ListView(physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()), padding: const EdgeInsets.fromLTRB(16, 12, 16, 30), children: [
        _V10Header(greeting: _greeting(languageCode), location: controller.currentLocationName, hijri: _hijri(languageCode)),
        const SizedBox(height: 14),
        AnimatedBuilder(animation: _motion, builder: (_, __) => _V10Hero(now: _now, motion: _motion.value, clock: _clock(settings.is24Hour), nextPrayer: controller.nextPrayerName, nextPrayerTime: controller.nextPrayerTime, remaining: controller.timeRemainingForNextPrayer, currentPrayer: controller.currentPrayer, progress: controller.prayerProgress, sunrise: controller.sunriseTime, sunset: controller.sunsetTime)),
        const SizedBox(height: 22),
        _V10Heading(title: _tr('আজকের সালাত', 'Today’s Prayer', languageCode), subtitle: _tr('পাঁচ ওয়াক্ত, পরিষ্কারভাবে', 'Five prayers, clearly presented', languageCode)),
        const SizedBox(height: 10),
        _V10PrayerTimeline(prayers: prayers, languageCode: languageCode),
        const SizedBox(height: 22),
        _V10Heading(title: _tr('প্রয়োজনীয়', 'Essentials', languageCode), subtitle: _tr('প্রতিদিনের গুরুত্বপূর্ণ সুবিধা', 'Everyday essentials', languageCode)),
        const SizedBox(height: 10),
        _V10Essentials(languageCode: languageCode, onQibla: () => _open(const QiblaScreen()), onDua: () => _open(const DuaScreen()), onTasbih: () => _open(const TasbihScreen()), onNames: () => _open(const AsmaUlHusnaScreen()), onCalendar: () => _open(const CalendarScreen()), onRuqyah: () => _open(const RuqyahScreen())),
        if (hasLastRead) ...[
          const SizedBox(height: 22),
          _V10Heading(title: _tr('কুরআন চালিয়ে যান', 'Continue Quran', languageCode), subtitle: _tr('যেখান থেকে থেমেছিলেন', 'Pick up where you left off', languageCode)),
          const SizedBox(height: 10),
          ContinueReadingCard(surahName: _lastRead!['surahName']?.toString() ?? '', paraNo: _lastRead!['paraNo'] is int ? _lastRead!['paraNo'] as int : int.tryParse('${_lastRead!['paraNo']}') ?? 1, pageNo: _lastRead!['pageNo'] is int ? _lastRead!['pageNo'] as int : int.tryParse('${_lastRead!['pageNo']}') ?? 1, progress: ((_lastRead!['progress'] is num ? (_lastRead!['progress'] as num).toDouble() : 0.0).clamp(0.0, 1.0)).toDouble(), languageCode: languageCode, onTap: () => _open(const OnudhabonQuranScreen(openLastRead: true))),
        ],
        const SizedBox(height: 22),
        _V10Footer(date: DateService.englishDate(), prohibitedNow: prohibitedNow, countdown: _countdown(prohibitedNow ? controller.prohibitedEnd : controller.prohibitedStart), languageCode: languageCode),
      ])),
    ));
  }
}

class _V10Header extends StatelessWidget {
  const _V10Header({required this.greeting, required this.location, required this.hijri});
  final String greeting; final String location; final String hijri;
  @override Widget build(BuildContext context) { final theme = Theme.of(context); final primary = theme.colorScheme.primary; final secondary = context.secondaryTextColor; return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(greeting, style: theme.textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w700, color: primary)), const SizedBox(height: 5), Row(children: [Icon(Icons.place_outlined, size: 15, color: secondary), const SizedBox(width: 4), Expanded(child: Text(location.trim().isEmpty ? 'Locating…' : location.trim(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 12)))])])), const SizedBox(width: 12), Container(constraints: const BoxConstraints(maxWidth: 140), padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8), decoration: BoxDecoration(color: primary.withValues(alpha: .07), borderRadius: BorderRadius.circular(12)), child: Text(hijri, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end, style: theme.textTheme.labelMedium?.copyWith(fontSize: 10.5, fontWeight: FontWeight.w700))) ]); }
}

class _V10Hero extends StatelessWidget {
  const _V10Hero({required this.now, required this.motion, required this.clock, required this.nextPrayer, required this.nextPrayerTime, required this.remaining, required this.currentPrayer, required this.progress, required this.sunrise, required this.sunset});
  final DateTime now; final double motion; final String clock; final String nextPrayer; final String nextPrayerTime; final String remaining; final String currentPrayer; final double progress; final String sunrise; final String sunset;
  @override Widget build(BuildContext context) { final hour = now.hour + now.minute / 60.0; final night = hour < 5.5 || hour >= 19.0; final dusk = hour >= 16.5 && hour < 19.0; final dawn = hour >= 5.5 && hour < 7.5; final palette = _V10Palette.fromHour(hour); final primary = Theme.of(context).colorScheme.primary; return Container(height: 430, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .18), blurRadius: 32, offset: const Offset(0, 18))]), child: Stack(fit: StackFit.expand, children: [CustomPaint(painter: _V10DesertPainter(palette: palette, motion: motion, night: night, dawn: dawn, dusk: dusk)), Positioned(left: 18, right: 18, top: 16, child: Row(children: [Text(clock, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500, fontFeatures: const [FontFeature.tabularFigures()])), const Spacer(), Text(currentPrayer, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))])), Positioned(left: 18, right: 18, bottom: 18, child: ClipRRect(borderRadius: BorderRadius.circular(24), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), child: Container(padding: const EdgeInsets.fromLTRB(18, 14, 18, 13), decoration: BoxDecoration(color: Colors.black.withValues(alpha: night ? .36 : .27), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: .10))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(nextPrayer.isEmpty ? '—' : nextPrayer, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700))), Text(nextPrayerTime.isEmpty ? '—' : nextPrayerTime, style: TextStyle(color: Colors.white.withValues(alpha: .75), fontSize: 12, fontWeight: FontWeight.w600))]), const SizedBox(height: 4), Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: Text(remaining.isEmpty ? '--:--:--' : remaining, style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontSize: 36, height: .95, fontWeight: FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()]))), Text('NEXT', style: TextStyle(color: Colors.white.withValues(alpha: .50), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2))]), const SizedBox(height: 8), _V10DayArc(value: progress.clamp(0.0, 1.0).toDouble(), color: primary), const SizedBox(height: 7), Row(children: [_V10SunData(label: 'Sunrise', value: sunrise), const Spacer(), _V10SunData(label: 'Sunset', value: sunset, end: true)])])))))])); }
}

class _V10DayArc extends StatelessWidget { const _V10DayArc({required this.value, required this.color}); final double value; final Color color; @override Widget build(BuildContext context) => SizedBox(height: 28, child: CustomPaint(painter: _V10ArcPainter(value: value, color: color))); }
class _V10ArcPainter extends CustomPainter { const _V10ArcPainter({required this.value, required this.color}); final double value; final Color color; @override void paint(Canvas canvas, Size size) { final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height * 1.75); final base = Paint()..color = Colors.white.withValues(alpha: .17)..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round; final active = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round; canvas.drawArc(rect, math.pi * 1.02, math.pi * .96, false, base); canvas.drawArc(rect, math.pi * 1.02, math.pi * .96 * value, false, active); final angle = math.pi * 1.02 + math.pi * .96 * value; final center = rect.center; final rx = rect.width / 2; final ry = rect.height / 2; final dot = Offset(center.dx + rx * math.cos(angle), center.dy + ry * math.sin(angle)); canvas.drawCircle(dot, 5.5, Paint()..color = color.withValues(alpha: .30)); canvas.drawCircle(dot, 2.6, Paint()..color = Colors.white); } @override bool shouldRepaint(covariant _V10ArcPainter old) => old.value != value || old.color != color; }
class _V10SunData extends StatelessWidget { const _V10SunData({required this.label, required this.value, this.end = false}); final String label; final String value; final bool end; @override Widget build(BuildContext context) => Column(crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.white.withValues(alpha: .55), fontSize: 9)), const SizedBox(height: 2), Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()]))]); }
class _V10Palette { const _V10Palette({required this.top, required this.bottom, required this.haze, required this.far, required this.mid, required this.fore}); final Color top; final Color bottom; final Color haze; final Color far; final Color mid; final Color fore; static _V10Palette fromHour(double hour) { if (hour < 5.5 || hour >= 19.0) return const _V10Palette(top: Color(0xFF071723), bottom: Color(0xFF143C58), haze: Color(0xFF4C7485), far: Color(0xFF183544), mid: Color(0xFF0E2939), fore: Color(0xFF081822)); if (hour >= 16.5) return const _V10Palette(top: Color(0xFF22496B), bottom: Color(0xFFC17B59), haze: Color(0xFFE8BA92), far: Color(0xFF8C6150), mid: Color(0xFF65483F), fore: Color(0xFF392F2D)); if (hour < 7.5) return const _V10Palette(top: Color(0xFF215E80), bottom: Color(0xFFE8C8A2), haze: Color(0xFFF2D8BA), far: Color(0xFF98735B), mid: Color(0xFF76513D), fore: Color(0xFF4D392D)); return const _V10Palette(top: Color(0xFF2A779D), bottom: Color(0xFFE7BC7B), haze: Color(0xFFF1D8B1), far: Color(0xFFA87446), mid: Color(0xFF875C36), fore: Color(0xFF503B2A)); } }
class _V10DesertPainter extends CustomPainter {
  const _V10DesertPainter({required this.palette, required this.motion, required this.night, required this.dawn, required this.dusk});
  final _V10Palette palette; final double motion; final bool night; final bool dawn; final bool dusk;
  @override void paint(Canvas canvas, Size size) { final rect = Offset.zero & size; canvas.drawRect(rect, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [palette.top, palette.bottom]).createShader(rect)); _celestial(canvas, size); _clouds(canvas, size); _dunes(canvas, size); _oasis(canvas, size); _palms(canvas, size); _camel(canvas, size); }
  void _celestial(Canvas canvas, Size size) { final progress = (motion - .5) * .22; final x = size.width * (.72 + progress); final y = night ? size.height * .17 : dusk ? size.height * .23 : size.height * (.19 + (dawn ? .05 : 0)); if (night) { canvas.drawCircle(Offset(x, y), 32, Paint()..color = Colors.white.withValues(alpha: .08)); canvas.drawCircle(Offset(x, y), 20, Paint()..color = const Color(0xFFE7F4FF)); canvas.drawCircle(Offset(x + 7, y - 4), 20, Paint()..color = palette.top); for (final p in const [Offset(.12, .14), Offset(.24, .22), Offset(.42, .11), Offset(.62, .18), Offset(.83, .13), Offset(.9, .28)]) { canvas.drawCircle(Offset(size.width * p.dx, size.height * p.dy), 1.5, Paint()..color = Colors.white.withValues(alpha: .45)); } return; } final sun = dusk ? const Color(0xFFFFB46E) : const Color(0xFFFFF2B0); canvas.drawCircle(Offset(x, y), 62, Paint()..color = sun.withValues(alpha: .18)); canvas.drawCircle(Offset(x, y), 25, Paint()..color = sun); }
  void _clouds(Canvas canvas, Size size) { final drift = (motion - .5) * 38; final opacity = night ? .06 : .22; final specs = [(Offset(size.width * .12 + drift, size.height * .20), 1.05), (Offset(size.width * .62 - drift * .55, size.height * .24), .78), (Offset(size.width * .34 + drift * .35, size.height * .13), .55)]; for (final spec in specs) { _cloudCluster(canvas, spec.$1, spec.$2, opacity); } }
  void _cloudCluster(Canvas canvas, Offset center, double scale, double opacity) { final shadow = Paint()..color = Colors.black.withValues(alpha: opacity * .20); final cloud = Paint()..color = Colors.white.withValues(alpha: opacity); final puffs = [Offset(-24, 4), Offset(-8, -8), Offset(12, -10), Offset(30, 2), Offset(2, 5)]; for (final o in puffs) { canvas.drawCircle(center + o * scale + const Offset(0, 2), 15 * scale, shadow); } for (final o in puffs) { canvas.drawCircle(center + o * scale, 15 * scale, cloud); } canvas.drawOval(Rect.fromCenter(center: center + Offset(3, 8) * scale, width: 84 * scale, height: 24 * scale), cloud); }
  void _dunes(Canvas canvas, Size size) { Path dune(double y, double amplitude, double frequency, double phase) { final path = Path()..moveTo(0, size.height * y); for (int i = 0; i <= 48; i++) { final t = i / 48; final x = size.width * t; final yy = size.height * y + math.sin(t * math.pi * frequency + phase) * size.height * amplitude; path.lineTo(x, yy); } path.lineTo(size.width, size.height); path.lineTo(0, size.height); path.close(); return path; } canvas.drawPath(dune(.55, .025, 2.0, motion), Paint()..color = palette.far); canvas.drawPath(dune(.66, .045, 2.4, motion * .7), Paint()..color = palette.mid); canvas.drawPath(dune(.78, .065, 2.8, motion * .4), Paint()..color = palette.fore); }
  void _oasis(Canvas canvas, Size size) { final water = Offset(size.width * .53, size.height * .73); canvas.drawOval(Rect.fromCenter(center: water, width: size.width * .24, height: size.height * .07), Paint()..color = const Color(0xFF5C9E9A).withValues(alpha: .55)); canvas.drawOval(Rect.fromCenter(center: water + const Offset(0, -2), width: size.width * .14, height: size.height * .035), Paint()..color = const Color(0xFFB8E1D8).withValues(alpha: .48)); }
  void _palms(Canvas canvas, Size size) { _palm(canvas, Offset(size.width * .13, size.height * .77), .90); _palm(canvas, Offset(size.width * .80, size.height * .76), .70); _palm(canvas, Offset(size.width * .58, size.height * .72), .52); }
  void _palm(Canvas canvas, Offset base, double scale) { final trunk = Paint()..color = palette.fore.withValues(alpha: .96); canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(base.dx - 4 * scale, base.dy - 60 * scale, 8 * scale, 60 * scale), Radius.circular(4 * scale)), trunk); final leaf = Paint()..color = palette.fore.withValues(alpha: .97)..strokeWidth = 4.4 * scale..strokeCap = StrokeCap.round; final top = base + Offset(0, -58 * scale); for (int i = 0; i < 8; i++) { final angle = -math.pi * .94 + i * math.pi * .27; canvas.drawLine(top, top + Offset(math.cos(angle) * 30 * scale, math.sin(angle) * 18 * scale), leaf); } }
  void _camel(Canvas canvas, Size size) { final p = Paint()..color = palette.fore.withValues(alpha: .92); final x = size.width * (.32 + motion * .05); final y = size.height * .78; canvas.drawOval(Rect.fromCenter(center: Offset(x, y - 20), width: 44, height: 18), p); canvas.drawCircle(Offset(x + 19, y - 35), 8.5, p); final leg = Paint()..color = palette.fore..strokeWidth = 3.5..strokeCap = StrokeCap.round; for (final dx in const [-10.0, 8.0]) { canvas.drawLine(Offset(x + dx, y - 10), Offset(x + dx - 4, y + 7), leg); } canvas.drawLine(Offset(x + 26, y - 38), Offset(x + 35, y - 47), leg); }
  @override bool shouldRepaint(covariant _V10DesertPainter old) => old.motion != motion || old.palette.top != palette.top || old.night != night || old.dawn != dawn || old.dusk != dusk;
}

class _V10Heading extends StatelessWidget { const _V10Heading({required this.title, required this.subtitle}); final String title; final String subtitle; @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5))]); }

class _V10PrayerTimeline extends StatelessWidget {
  const _V10PrayerTimeline({required this.prayers, required this.languageCode});
  final List<Map<String, dynamic>> prayers; final String languageCode;
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context); final primary = theme.colorScheme.primary; final settings = context.watch<SettingsProvider>();
    return Container(decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(22)), child: Column(children: List.generate(5, (i) {
      final prayer = i < prayers.length ? prayers[i] : const <String, dynamic>{}; final current = prayer['isCurrent'] == true;
      final name = languageCode == 'en' ? (prayer['name']?.toString() ?? '—') : (prayer['nameBn']?.toString() ?? '—');
      final time = prayer['start']?.toString() ?? '—';
      final rawName = prayer['name']?.toString() ?? '';
      final prayerKey = rawName.toLowerCase() == 'jumuah' || rawName.contains('জুম') ? 'Dhuhr' : rawName;
      final jamaat = _formatJamaat(JamaatService.get(prayerKey), settings.is24Hour);
      return Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), decoration: BoxDecoration(color: current ? primary.withValues(alpha: .08) : Colors.transparent, borderRadius: BorderRadius.circular(16)), child: Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: current ? primary.withValues(alpha: .14) : primary.withValues(alpha: .07), borderRadius: BorderRadius.circular(11)), child: Icon(_prayerIcon(i), size: 18, color: primary)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, fontWeight: current ? FontWeight.w800 : FontWeight.w600)), if (jamaat != '--:--') Text('${languageCode == 'en' ? 'Jamaat' : 'জামাআত'}: $jamaat', style: TextStyle(color: context.secondaryTextColor, fontSize: 9.5, fontWeight: FontWeight.w600))])),
        if (current) ...[Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: primary.withValues(alpha: .14), borderRadius: BorderRadius.circular(8)), child: Text('NOW', style: TextStyle(color: primary, fontSize: 9, fontWeight: FontWeight.w800))), const SizedBox(width: 8)],
        Text(time, style: TextStyle(color: context.primaryTextColor, fontSize: 14, fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()])),
      ]));
    })));
  }

  String _formatJamaat(String value, bool is24Hour) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false).firstMatch(value.trim());
    if (match == null) return value.isEmpty ? '--:--' : value;
    final hour = int.parse(match.group(1)!); final minute = match.group(2)!; final period = match.group(3)!.toUpperCase();
    if (!is24Hour) return '$hour:$minute $period';
    var hour24 = hour % 12; if (period == 'PM') hour24 += 12;
    return '${hour24.toString().padLeft(2, '0')}:$minute';
  }
  IconData _prayerIcon(int index) => const [Icons.nightlight_round, Icons.wb_sunny_outlined, Icons.wb_twilight_rounded, Icons.wb_sunny_rounded, Icons.dark_mode_rounded][index];
}

class _V10Essentials extends StatelessWidget {
  const _V10Essentials({required this.languageCode, required this.onQibla, required this.onDua, required this.onTasbih, required this.onNames, required this.onCalendar, required this.onRuqyah});
  final String languageCode; final VoidCallback onQibla; final VoidCallback onDua; final VoidCallback onTasbih; final VoidCallback onNames; final VoidCallback onCalendar; final VoidCallback onRuqyah;
  @override Widget build(BuildContext context) { final primary = Theme.of(context).colorScheme.primary; final items = <(String, String, IconData, VoidCallback)>[('কিবলা', 'Qibla', Icons.explore_rounded, onQibla), ('দোয়া', 'Dua', Icons.auto_awesome_rounded, onDua), ('তাসবিহ', 'Tasbih', Icons.fingerprint_rounded, onTasbih), ('৯৯ নাম', '99 Names', Icons.favorite_rounded, onNames), ('ক্যালেন্ডার', 'Calendar', Icons.calendar_month_rounded, onCalendar), ('রুকইয়াহ', 'Ruqyah', Icons.menu_book_rounded, onRuqyah)]; return GridView.builder(itemCount: items.length, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: .98), itemBuilder: (context, index) { final item = items[index]; final label = languageCode == 'en' ? item.$2 : item.$1; return Material(color: Colors.transparent, child: InkWell(onTap: item.$4, borderRadius: BorderRadius.circular(18), child: Container(decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(18)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(14)), child: Icon(item.$3, color: primary, size: 21)), const SizedBox(height: 8), Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700))])))); }); }
}

class _V10Footer extends StatelessWidget {
  const _V10Footer({required this.date, required this.prohibitedNow, required this.countdown, required this.languageCode});
  final String date; final bool prohibitedNow; final String countdown; final String languageCode;
  @override Widget build(BuildContext context) { final primary = Theme.of(context).colorScheme.primary; final title = languageCode == 'en' ? 'Prohibited time' : 'নিষিদ্ধ সময়'; final state = prohibitedNow ? (languageCode == 'en' ? 'Active now' : 'এখন চলছে') : (languageCode == 'en' ? 'Next window' : 'পরবর্তী সময়'); return Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13), decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(18)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(date, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(title, style: TextStyle(color: context.secondaryTextColor, fontSize: 10.5))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(state, style: TextStyle(color: primary, fontSize: 10.5, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(countdown, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w800, fontFeatures: const [FontFeature.tabularFigures()]))]) ])); }
}
