import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

class SimpleHomeScreenV7 extends StatefulWidget {
  const SimpleHomeScreenV7({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreenV7> createState() => _SimpleHomeScreenV7State();
}

class _SimpleHomeScreenV7State extends State<SimpleHomeScreenV7>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sceneController;
  Timer? _timer;
  DateTime _now = DateTime.now();
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _sceneController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _loadLastRead();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sceneController.dispose();
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
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
    if (mounted) await _refreshHome();
  }

  String _tr(String bn, String en, String languageCode) =>
      languageCode == 'en' ? en : bn;

  String _greeting(String languageCode) {
    if (languageCode == 'en') {
      if (_now.hour < 12) return 'Good Morning';
      if (_now.hour < 16) return 'Good Afternoon';
      if (_now.hour < 19) return 'Good Evening';
      return 'Good Night';
    }
    if (_now.hour < 12) return 'শুভ সকাল';
    if (_now.hour < 16) return 'শুভ দুপুর';
    if (_now.hour < 19) return 'শুভ সন্ধ্যা';
    return 'শুভ রাত্রি';
  }

  String _clock() {
    final hour = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    return '${hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')} ${_now.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _hijri(String languageCode) {
    final h = HijriCalendar.now();
    const bn = [
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
    const en = [
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
    final month = languageCode == 'en' ? en[h.hMonth - 1] : bn[h.hMonth - 1];
    final day = languageCode == 'en' ? '${h.hDay}' : bnDigits(h.hDay);
    final year = languageCode == 'en' ? '${h.hYear}' : bnDigits(h.hYear);
    return '$day $month $year';
  }

  List<Map<String, dynamic>> _fivePrayers(PrayerController controller) {
    const keys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final result = <Map<String, dynamic>>[];
    for (final key in keys) {
      for (final prayer in controller.prayers) {
        final name = (prayer['name'] ?? '').toString().toLowerCase();
        final bn = (prayer['nameBn'] ?? '').toString().toLowerCase();
        final match = name.contains(key.toLowerCase()) ||
            (key == 'Fajr' && bn.contains('ফজর')) ||
            (key == 'Dhuhr' &&
                (bn.contains('যোহর') || bn.contains('জুমু'))) ||
            (key == 'Asr' && bn.contains('আসর')) ||
            (key == 'Maghrib' && bn.contains('মাগরিব')) ||
            (key == 'Isha' && bn.contains('ইশা'));
        if (match) {
          result.add(prayer);
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
    final total = d.inSeconds;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final languageCode = settings.languageCode;
    final prayers = _fivePrayers(controller);
    final hasLastRead = _lastRead != null &&
        (_lastRead!['surahName']?.toString() ?? '').trim().isNotEmpty;
    final prohibitedNow = _isProhibited(controller);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.seaBlue,
          onRefresh: _refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
            children: [
              _TopHeader(
                greeting: _greeting(languageCode),
                location: controller.currentLocationName,
                hijri: _hijri(languageCode),
                languageCode: languageCode,
              ),
              const SizedBox(height: 14),
              AnimatedBuilder(
                animation: _sceneController,
                builder: (context, _) => _PrayerHero(
                  now: _now,
                  motion: _sceneController.value,
                  clock: _clock(),
                  nextPrayer: controller.nextPrayerName,
                  nextPrayerTime: controller.nextPrayerTime,
                  remaining: controller.timeRemainingForNextPrayer,
                  currentPrayer: controller.currentPrayer,
                  progress: controller.prayerProgress,
                  sunrise: controller.sunriseTime,
                  sunset: controller.sunsetTime,
                  languageCode: languageCode,
                ),
              ),
              const SizedBox(height: 22),
              _SectionHeading(
                title: _tr('আজকের সালাত', 'Today’s Prayer', languageCode),
                subtitle: _tr('প্রতিটি ওয়াক্ত এক নজরে', 'Every prayer at a glance', languageCode),
              ),
              const SizedBox(height: 10),
              _PrayerTimeline(
                prayers: prayers,
                languageCode: languageCode,
              ),
              const SizedBox(height: 22),
              _SectionHeading(
                title: _tr('প্রয়োজনীয়', 'Essentials', languageCode),
                subtitle: _tr('দৈনন্দিন প্রয়োজনীয় সুবিধা', 'Everyday tools', languageCode),
              ),
              const SizedBox(height: 10),
              _EssentialsGrid(
                languageCode: languageCode,
                onQibla: () => _open(const QiblaScreen()),
                onDua: () => _open(const DuaScreen()),
                onTasbih: () => _open(const TasbihScreen()),
                onNames: () => _open(const AsmaUlHusnaScreen()),
                onCalendar: () => _open(const CalendarScreen()),
                onRuqyah: () => _open(const RuqyahScreen()),
              ),
              if (hasLastRead) ...[
                const SizedBox(height: 22),
                _SectionHeading(
                  title: _tr('কুরআন চালিয়ে যান', 'Continue Quran', languageCode),
                  subtitle: _tr('যেখান থেকে থেমেছিলেন', 'Pick up where you left off', languageCode),
                ),
                const SizedBox(height: 10),
                ContinueReadingCard(
                  surahName: _lastRead!['surahName']?.toString() ?? '',
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
                  languageCode: languageCode,
                  onTap: () => _open(
                    const OnudhabonQuranScreen(openLastRead: true),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              _FooterSummary(
                date: DateService.englishDate(),
                prohibitedNow: prohibitedNow,
                countdown: _countdown(
                  prohibitedNow ? controller.prohibitedEnd : controller.prohibitedStart,
                ),
                languageCode: languageCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.greeting,
    required this.location,
    required this.hijri,
    required this.languageCode,
  });

  final String greeting;
  final String location;
  final String hijri;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: GoogleFonts.googleSans(
                  fontSize: 21,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.place_outlined, size: 15, color: secondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location.trim().isEmpty
                          ? (languageCode == 'en' ? 'Locating your area…' : 'লোকেশন নির্ধারণ হচ্ছে…')
                          : location.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _MiniDateChip(value: hijri),
      ],
    );
  }
}

class _MiniDateChip extends StatelessWidget {
  const _MiniDateChip({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      constraints: const BoxConstraints(maxWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
        style: TextStyle(
          color: context.primaryTextColor,
          fontSize: 10.5,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PrayerHero extends StatelessWidget {
  const _PrayerHero({
    required this.now,
    required this.motion,
    required this.clock,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.remaining,
    required this.currentPrayer,
    required this.progress,
    required this.sunrise,
    required this.sunset,
    required this.languageCode,
  });

  final DateTime now;
  final double motion;
  final String clock;
  final String nextPrayer;
  final String nextPrayerTime;
  final String remaining;
  final String currentPrayer;
  final double progress;
  final String sunrise;
  final String sunset;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final hour = now.hour + now.minute / 60;
    final palette = _HeroPalette.fromTime(hour);
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();

    return Container(
      height: 386,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: palette.deep.withValues(alpha: .22),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _AtmosphericScenePainter(
              palette: palette,
              motion: motion,
              now: now,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  palette.deep.withValues(alpha: .18),
                  palette.deep.withValues(alpha: .62),
                  palette.deep.withValues(alpha: .92),
                ],
                stops: const [0, .35, .68, 1],
              ),
            ),
          ),
          Positioned(
            top: 18,
            left: 18,
            child: _HeroGlass(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_rounded, size: 14, color: Colors.white.withValues(alpha: .88)),
                  const SizedBox(width: 6),
                  Text(
                    clock,
                    style: GoogleFonts.googleSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .2,
                    ).copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: _HeroGlass(
              radius: 22,
              padding: const EdgeInsets.fromLTRB(17, 15, 17, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              languageCode == 'en' ? 'NEXT PRAYER' : 'পরবর্তী সালাত',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .68),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              nextPrayer.isEmpty ? '--' : nextPrayer,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.googleSans(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            nextPrayerTime.isEmpty ? '--:--' : nextPrayerTime,
                            style: GoogleFonts.googleSans(
                              color: palette.aqua,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            languageCode == 'en' ? 'remaining' : 'বাকি',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .56),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          remaining.isEmpty ? '--:--:--' : remaining,
                          style: GoogleFonts.googleSans(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            height: .98,
                            letterSpacing: -.7,
                          ).copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      _CurrentBadge(
                        value: currentPrayer.isEmpty ? '--' : currentPrayer,
                        languageCode: languageCode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  _ProgressTrack(
                    value: safeProgress,
                    color: palette.aqua,
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      _SunStat(
                        icon: Icons.wb_twilight_rounded,
                        label: _tr('সূর্যোদয়', 'Sunrise', languageCode),
                        value: sunrise,
                      ),
                      const Spacer(),
                      _SunStat(
                        icon: Icons.wb_sunny_outlined,
                        label: _tr('সূর্যাস্ত', 'Sunset', languageCode),
                        value: sunset,
                        end: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroGlass extends StatelessWidget {
  const _HeroGlass({
    required this.child,
    this.radius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
  });

  final Widget child;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .105),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: .08)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge({required this.value, required this.languageCode});
  final String value;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            languageCode == 'en' ? 'NOW' : 'এখন',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .54),
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: CustomPaint(
        painter: _ProgressPainter(value: value, color: color),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  const _ProgressPainter({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final start = 1.0;
    final end = size.width - 1.0;
    final progress = start + (end - start) * value.clamp(0.0, 1.0);
    final bg = Paint()
      ..color = Colors.white.withValues(alpha: .13)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(start, y), Offset(end, y), bg);
    final active = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: .52), color, Colors.white],
      ).createShader(Rect.fromLTRB(start, 0, end, size.height))
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(start, y), Offset(progress, y), active);
    canvas.drawCircle(Offset(progress, y), 5.5, Paint()..color = color.withValues(alpha: .22));
    canvas.drawCircle(Offset(progress, y), 2.6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}

class _SunStat extends StatelessWidget {
  const _SunStat({
    required this.icon,
    required this.label,
    required this.value,
    this.end = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool end;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!end) Icon(icon, size: 15, color: Colors.white.withValues(alpha: .7)),
        if (!end) const SizedBox(width: 5),
        Column(
          crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: .56), fontSize: 9.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 1),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
          ],
        ),
        if (end) const SizedBox(width: 5),
        if (end) Icon(icon, size: 15, color: Colors.white.withValues(alpha: .7)),
      ],
    );
    return row;
  }
}

class _AtmosphericScenePainter extends CustomPainter {
  const _AtmosphericScenePainter({
    required this.palette,
    required this.motion,
    required this.now,
  });

  final _HeroPalette palette;
  final double motion;
  final DateTime now;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [palette.skyTop, palette.skyMid, palette.skyBottom],
      stops: const [.0, .55, 1],
    ).createShader(rect));

    final horizon = size.height * .56;
    final lightCenter = Offset(size.width * .72, size.height * .22);
    for (int i = 4; i >= 1; i--) {
      final radius = 22.0 + i * 17;
      canvas.drawCircle(
        lightCenter,
        radius,
        Paint()..color = palette.glow.withValues(alpha: .026 * i),
      );
    }

    final cloudShift = (motion - .5) * 24;
    _drawCloud(canvas, Offset(size.width * .21 + cloudShift, size.height * .21), 74, palette.cloud.withValues(alpha: .12));
    _drawCloud(canvas, Offset(size.width * .68 - cloudShift * .6, size.height * .17), 58, palette.cloud.withValues(alpha: .10));

    _drawTerrain(canvas, size, horizon + 30, palette.farTerrain, 0.2, motion);
    _drawTerrain(canvas, size, horizon + 55, palette.midTerrain, 0.45, motion);
    _drawTerrain(canvas, size, horizon + 78, palette.frontTerrain, 0.72, motion);

    _drawMosque(canvas, size, motion);

    final foreground = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, palette.deep.withValues(alpha: .22)],
      ).createShader(Rect.fromLTWH(0, horizon + 62, size.width, size.height - horizon - 62));
    canvas.drawRect(Rect.fromLTWH(0, horizon, size.width, size.height - horizon), foreground);
  }

  void _drawCloud(Canvas canvas, Offset center, double width, Color color) {
    final p = Paint()..color = color;
    canvas.drawOval(Rect.fromCenter(center: center.translate(-width * .26, 2), width: width * .56, height: width * .2), p);
    canvas.drawOval(Rect.fromCenter(center: center.translate(0, -5), width: width * .50, height: width * .28), p);
    canvas.drawOval(Rect.fromCenter(center: center.translate(width * .25, 3), width: width * .58, height: width * .22), p);
  }

  void _drawTerrain(Canvas canvas, Size size, double y, Color color, double parallax, double t) {
    final shift = (t - .5) * 18 * parallax;
    final path = Path()..moveTo(-20, size.height);
    for (int i = 0; i <= 6; i++) {
      final x = -20 + i * size.width / 6;
      final wave = math.sin(i * 1.4 + 1.2) * 16;
      path.lineTo(x + shift, y + wave);
    }
    path
      ..lineTo(size.width + 20, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawMosque(Canvas canvas, Size size, double t) {
    final x = size.width * .52 + (t - .5) * 5;
    final baseY = size.height * .74;
    final paint = Paint()..color = palette.mosque;
    final shadow = Paint()..color = Colors.black.withValues(alpha: .18);

    final shadowRect = Rect.fromCenter(center: Offset(x, baseY + 12), width: size.width * .54, height: 18);
    canvas.drawOval(shadowRect, shadow);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - size.width * .20, baseY - 72, size.width * .40, 76),
        const Radius.circular(5),
      ),
      paint,
    );

    final dome = Path()
      ..moveTo(x - size.width * .12, baseY - 71)
      ..quadraticBezierTo(x, baseY - 132, x + size.width * .12, baseY - 71)
      ..close();
    canvas.drawPath(dome, paint);
    canvas.drawRect(Rect.fromLTWH(x - 2, baseY - 151, 4, 28), paint);
    canvas.drawCircle(Offset(x, baseY - 154), 3.5, paint);

    for (final side in <double>[-1, 1]) {
      final towerX = x + side * size.width * .19;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(towerX - 8, baseY - 105, 16, 110),
          const Radius.circular(5),
        ),
        paint,
      );
      canvas.drawCircle(Offset(towerX, baseY - 110), 9, paint);
      canvas.drawRect(Rect.fromLTWH(towerX - 2, baseY - 142, 4, 28), paint);
      canvas.drawCircle(Offset(towerX, baseY - 145), 3, paint);
    }

    final doorPaint = Paint()..color = palette.door;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 17, baseY - 42, 34, 42),
        const Radius.circular(17),
      ),
      doorPaint,
    );

    final arch = Paint()..color = palette.window;
    for (int i = -1; i <= 1; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + i * 53 - 9, baseY - 53, 18, 23),
          const Radius.circular(9),
        ),
        arch,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AtmosphericScenePainter oldDelegate) =>
      oldDelegate.motion != motion || oldDelegate.palette != palette || oldDelegate.now.hour != now.hour;
}

class _HeroPalette {
  const _HeroPalette({
    required this.skyTop,
    required this.skyMid,
    required this.skyBottom,
    required this.farTerrain,
    required this.midTerrain,
    required this.frontTerrain,
    required this.mosque,
    required this.door,
    required this.window,
    required this.glow,
    required this.aqua,
    required this.deep,
    required this.cloud,
  });

  final Color skyTop;
  final Color skyMid;
  final Color skyBottom;
  final Color farTerrain;
  final Color midTerrain;
  final Color frontTerrain;
  final Color mosque;
  final Color door;
  final Color window;
  final Color glow;
  final Color aqua;
  final Color deep;
  final Color cloud;

  static _HeroPalette fromTime(double hour) {
    if (hour < 5.5) {
      return const _HeroPalette(
        skyTop: Color(0xFF04111D),
        skyMid: Color(0xFF0B2A43),
        skyBottom: Color(0xFF145578),
        farTerrain: Color(0xFF18384C),
        midTerrain: Color(0xFF0E2739),
        frontTerrain: Color(0xFF061620),
        mosque: Color(0xFF031018),
        door: Color(0xFF16405B),
        window: Color(0xFF2C7898),
        glow: Color(0xFF7DD3FC),
        aqua: Color(0xFF8AE5FF),
        deep: Color(0xFF031018),
        cloud: Color(0xFFE6F7FF),
      );
    }
    if (hour < 10) {
      return const _HeroPalette(
        skyTop: Color(0xFF0A4360),
        skyMid: Color(0xFF1683AA),
        skyBottom: Color(0xFF6EC5D9),
        farTerrain: Color(0xFF3A8EA3),
        midTerrain: Color(0xFF21657D),
        frontTerrain: Color(0xFF0D3B4F),
        mosque: Color(0xFF082B39),
        door: Color(0xFF0B536B),
        window: Color(0xFF69D7E9),
        glow: Color(0xFFFFF3C2),
        aqua: Color(0xFF9EF3FF),
        deep: Color(0xFF062A36),
        cloud: Color(0xFFEFFBFF),
      );
    }
    if (hour < 16) {
      return const _HeroPalette(
        skyTop: Color(0xFF075A79),
        skyMid: Color(0xFF1599B5),
        skyBottom: Color(0xFF8AD4DE),
        farTerrain: Color(0xFF4B9DA7),
        midTerrain: Color(0xFF257487),
        frontTerrain: Color(0xFF124A59),
        mosque: Color(0xFF082E3A),
        door: Color(0xFF0E5364),
        window: Color(0xFF83E5EB),
        glow: Color(0xFFFFF0BC),
        aqua: Color(0xFF9BF4FA),
        deep: Color(0xFF062C36),
        cloud: Color(0xFFF4FEFF),
      );
    }
    if (hour < 19) {
      return const _HeroPalette(
        skyTop: Color(0xFF164762),
        skyMid: Color(0xFF287F99),
        skyBottom: Color(0xFFD68D67),
        farTerrain: Color(0xFF637B87),
        midTerrain: Color(0xFF304E5D),
        frontTerrain: Color(0xFF112A34),
        mosque: Color(0xFF091A22),
        door: Color(0xFF274554),
        window: Color(0xFFF4BF7A),
        glow: Color(0xFFFFCB83),
        aqua: Color(0xFFB4EEF4),
        deep: Color(0xFF091820),
        cloud: Color(0xFFFFE8D9),
      );
    }
    return const _HeroPalette(
      skyTop: Color(0xFF061321),
      skyMid: Color(0xFF0E3550),
      skyBottom: Color(0xFF1C5F77),
      farTerrain: Color(0xFF24485B),
      midTerrain: Color(0xFF183746),
      frontTerrain: Color(0xFF0B1B25),
      mosque: Color(0xFF041017),
      door: Color(0xFF0D3448),
      window: Color(0xFF63C9DD),
      glow: Color(0xFFB7F1FF),
      aqua: Color(0xFF91E5FA),
      deep: Color(0xFF031018),
      cloud: Color(0xFFD7F0F8),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.googleSans(
            color: primary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            color: context.secondaryTextColor,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PrayerTimeline extends StatelessWidget {
  const _PrayerTimeline({required this.prayers, required this.languageCode});
  final List<Map<String, dynamic>> prayers;
  final String languageCode;

  static const _icons = <IconData>[
    Icons.nightlight_round,
    Icons.wb_sunny_outlined,
    Icons.wb_twilight,
    Icons.wb_twilight_rounded,
    Icons.nights_stay_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: .07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: List.generate(5, (index) {
          final prayer = index < prayers.length ? prayers[index] : const <String, dynamic>{};
          final current = prayer['isCurrent'] == true;
          final name = languageCode == 'en'
              ? (prayer['name']?.toString() ?? '--')
              : (prayer['nameBn']?.toString() ?? '--');
          final time = prayer['start']?.toString() ?? '--:--';
          final last = index == 4;
          return _PrayerRow(
            name: name,
            time: time,
            current: current,
            icon: _icons[index],
            last: last,
          );
        }),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.name,
    required this.time,
    required this.icon,
    required this.current,
    required this.last,
  });

  final String name;
  final String time;
  final IconData icon;
  final bool current;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: current ? primary.withValues(alpha: .075) : Colors.transparent,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(last ? 0 : 0),
          bottom: Radius.circular(last ? 22 : 0),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: current ? primary.withValues(alpha: .13) : primary.withValues(alpha: .065),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 17, color: current ? primary : secondary),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.primaryTextColor,
                          fontSize: 15,
                          fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (current) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Text(
                          'NOW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                time,
                style: GoogleFonts.googleSans(
                  color: current ? primary : context.primaryTextColor,
                  fontSize: 14,
                  fontWeight: current ? FontWeight.w800 : FontWeight.w700,
                ).copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          if (!last)
            Padding(
              padding: const EdgeInsets.only(left: 46, top: 10),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: .06),
              ),
            ),
        ],
      ),
    );
  }
}

class _EssentialsGrid extends StatelessWidget {
  const _EssentialsGrid({
    required this.onQibla,
    required this.onDua,
    required this.onTasbih,
    required this.onNames,
    required this.onCalendar,
    required this.onRuqyah,
    required this.languageCode,
  });

  final VoidCallback onQibla;
  final VoidCallback onDua;
  final VoidCallback onTasbih;
  final VoidCallback onNames;
  final VoidCallback onCalendar;
  final VoidCallback onRuqyah;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final items = <_ToolItem>[
      _ToolItem(Icons.explore_rounded, _tr('কিবলা', 'Qibla', languageCode), onQibla),
      _ToolItem(Icons.auto_awesome_rounded, _tr('দোয়া', 'Dua', languageCode), onDua),
      _ToolItem(Icons.touch_app_rounded, _tr('তাসবিহ', 'Tasbih', languageCode), onTasbih),
      _ToolItem(Icons.workspace_premium_rounded, _tr('৯৯ নাম', '99 Names', languageCode), onNames),
      _ToolItem(Icons.calendar_month_rounded, _tr('ক্যালেন্ডার', 'Calendar', languageCode), onCalendar),
      _ToolItem(Icons.shield_moon_rounded, _tr('রুকইয়াহ', 'Ruqyah', languageCode), onRuqyah),
    ];
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        childAspectRatio: 1.06,
      ),
      itemBuilder: (context, index) => _ToolCard(item: items[index]),
    );
  }
}

class _ToolItem {
  const _ToolItem(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.item});
  final _ToolItem item;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: .045),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 41,
                  height: 41,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: .09),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: primary, size: 21),
                ),
                const SizedBox(height: 7),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterSummary extends StatelessWidget {
  const _FooterSummary({
    required this.date,
    required this.prohibitedNow,
    required this.countdown,
    required this.languageCode,
  });

  final String date;
  final bool prohibitedNow;
  final String countdown;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageCode == 'en' ? 'DATE' : 'তারিখ',
                  style: TextStyle(
                    color: context.secondaryTextColor,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 30, color: primary.withValues(alpha: .08)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                prohibitedNow
                    ? (languageCode == 'en' ? 'PROHIBITED NOW' : 'নিষিদ্ধ সময় চলছে')
                    : (languageCode == 'en' ? 'NEXT PROHIBITED TIME' : 'পরবর্তী নিষিদ্ধ সময়'),
                style: TextStyle(
                  color: prohibitedNow ? AppColors.error : context.secondaryTextColor,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                countdown,
                style: GoogleFonts.googleSans(
                  color: prohibitedNow ? AppColors.error : primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ).copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _tr(String bn, String en, String languageCode) =>
    languageCode == 'en' ? en : bn;
