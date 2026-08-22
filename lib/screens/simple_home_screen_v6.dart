import 'dart:async';
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

class SimpleHomeScreenV6 extends StatefulWidget {
  const SimpleHomeScreenV6({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreenV6> createState() => _SimpleHomeScreenV6State();
}

class _SimpleHomeScreenV6State extends State<SimpleHomeScreenV6>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sceneController;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _sceneController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _loadLastRead();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
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
          color: Theme.of(context).colorScheme.primary,
          onRefresh: _refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
            children: [
              _V6Header(
                greeting: _greeting(languageCode),
                location: controller.currentLocationName,
                hijri: _hijri(languageCode),
                languageCode: languageCode,
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _sceneController,
                builder: (context, _) {
                  return _V6Hero(
                    now: _now,
                    animation: _sceneController.value,
                    clock: _clock(),
                    nextPrayer: controller.nextPrayerName,
                    nextPrayerTime: controller.nextPrayerTime,
                    remaining: controller.timeRemainingForNextPrayer,
                    currentPrayer: controller.currentPrayer,
                    progress: controller.prayerProgress,
                    sunrise: controller.sunriseTime,
                    sunset: controller.sunsetTime,
                    languageCode: languageCode,
                  );
                },
              ),
              const SizedBox(height: 18),
              _V6SectionTitle(
                title: _tr('আজকের সালাত', 'Today’s Prayer', languageCode),
                subtitle: _tr('পাঁচ ওয়াক্ত এক নজরে', 'Five daily prayers at a glance', languageCode),
              ),
              const SizedBox(height: 10),
              _V6PrayerTimeline(prayers: prayers, languageCode: languageCode),
              const SizedBox(height: 18),
              _V6SectionTitle(
                title: _tr('প্রয়োজনীয়', 'Essentials', languageCode),
                subtitle: _tr('দৈনন্দিন গুরুত্বপূর্ণ সুবিধা', 'Everyday essentials', languageCode),
              ),
              const SizedBox(height: 10),
              _V6Essentials(
                onQibla: () => _open(const QiblaScreen()),
                onDua: () => _open(const DuaScreen()),
                onTasbih: () => _open(const TasbihScreen()),
                onNames: () => _open(const AsmaUlHusnaScreen()),
                onCalendar: () => _open(const CalendarScreen()),
                onRuqyah: () => _open(const RuqyahScreen()),
                languageCode: languageCode,
              ),
              if (hasLastRead) ...[
                const SizedBox(height: 18),
                _V6SectionTitle(
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
              const SizedBox(height: 18),
              _V6Footer(
                date: DateService.englishDate(),
                prohibitedNow: prohibitedNow,
                countdown: _countdown(
                  prohibitedNow
                      ? controller.prohibitedEnd
                      : controller.prohibitedStart,
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

class _V6Header extends StatelessWidget {
  const _V6Header({
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
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: GoogleFonts.googleSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 15, color: secondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location.trim().isEmpty
                          ? (languageCode == 'en' ? 'Locating…' : 'লোকেশন নির্ধারণ হচ্ছে…')
                          : location.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: secondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(
            hijri,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: context.primaryTextColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _V6Hero extends StatelessWidget {
  const _V6Hero({
    required this.now,
    required this.animation,
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
  final double animation;
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
    final night = hour < 5.5 || hour >= 19.0;
    final golden = hour >= 16.0 && hour < 19.0;
    final palette = _V6Palette.fromTime(hour);
    final normalizedProgress = progress.clamp(0.0, 1.0).toDouble();

    return Container(
      height: 455,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: palette.deep.withValues(alpha: .28),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [palette.skyTop, palette.skyBottom, palette.earth],
                  stops: const [0, .58, 1],
                ),
              ),
            ),
            CustomPaint(
              painter: _V6AtmospherePainter(
                palette: palette,
                parallax: animation,
                night: night,
                golden: golden,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: .02),
                        Colors.black.withValues(alpha: .08),
                        Colors.black.withValues(alpha: .36),
                      ],
                      stops: const [0, .48, 1],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 14,
              child: _GlassChip(
                child: Row(
                  children: [
                    Icon(
                      night ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                      size: 15,
                      color: Colors.white.withValues(alpha: .86),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      clock,
                      style: GoogleFonts.googleSans(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .6,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      currentPrayer.isEmpty ? '--' : currentPrayer,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 20,
              child: _GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageCode == 'en' ? 'NEXT PRAYER' : 'পরবর্তী সালাত',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .66),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            nextPrayer.isEmpty ? '--' : nextPrayer,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.googleSans(
                              color: Colors.white,
                              fontSize: 30,
                              height: .98,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          nextPrayerTime.isEmpty ? '--:--' : nextPrayerTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      remaining.isEmpty ? '--:--:--' : remaining,
                      style: GoogleFonts.googleSans(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -1.2,
                      ).copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 11),
                    _V6Progress(value: normalizedProgress, accent: palette.accent),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        _V6SunInfo(Icons.wb_twilight_rounded, languageCode == 'en' ? 'Sunrise' : 'সূর্যোদয়', sunrise),
                        const Spacer(),
                        _V6SunInfo(Icons.wb_sunny_outlined, languageCode == 'en' ? 'Sunset' : 'সূর্যাস্ত', sunset, end: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _V6Palette {
  const _V6Palette({
    required this.skyTop,
    required this.skyBottom,
    required this.horizon,
    required this.earth,
    required this.deep,
    required this.accent,
  });

  final Color skyTop;
  final Color skyBottom;
  final Color horizon;
  final Color earth;
  final Color deep;
  final Color accent;

  static _V6Palette fromTime(double h) {
    if (h < 5.5) {
      return const _V6Palette(
        skyTop: Color(0xFF061427),
        skyBottom: Color(0xFF123A59),
        horizon: Color(0xFF285C73),
        earth: Color(0xFF07111B),
        deep: Color(0xFF06111B),
        accent: Color(0xFF78D7FF),
      );
    }
    if (h < 7) {
      return const _V6Palette(
        skyTop: Color(0xFF437EAB),
        skyBottom: Color(0xFFB8D5E3),
        horizon: Color(0xFFEACBA8),
        earth: Color(0xFF26414B),
        deep: Color(0xFF193642),
        accent: Color(0xFFFFD58A),
      );
    }
    if (h < 16) {
      return const _V6Palette(
        skyTop: Color(0xFF4AA8D9),
        skyBottom: Color(0xFFBFE7F5),
        horizon: Color(0xFFD7E6D5),
        earth: Color(0xFF335C58),
        deep: Color(0xFF1B3F45),
        accent: Color(0xFFFFF1A6),
      );
    }
    if (h < 19) {
      return const _V6Palette(
        skyTop: Color(0xFF2B537C),
        skyBottom: Color(0xFFF0A56A),
        horizon: Color(0xFFFFC86F),
        earth: Color(0xFF473C43),
        deep: Color(0xFF241D2A),
        accent: Color(0xFFFFD38B),
      );
    }
    return const _V6Palette(
      skyTop: Color(0xFF071326),
      skyBottom: Color(0xFF17375B),
      horizon: Color(0xFF274D69),
      earth: Color(0xFF08121F),
      deep: Color(0xFF040A12),
      accent: Color(0xFF8EDCFF),
    );
  }
}

class _V6AtmospherePainter extends CustomPainter {
  const _V6AtmospherePainter({
    required this.palette,
    required this.parallax,
    required this.night,
    required this.golden,
  });

  final _V6Palette palette;
  final double parallax;
  final bool night;
  final bool golden;

  @override
  void paint(Canvas canvas, Size size) {
    final breath = (parallax - .5) * 2;
    final w = size.width;
    final h = size.height;

    final celestial = Offset(
      w * (.78 + breath * .035),
      h * (night ? .20 : .25),
    );
    canvas.drawCircle(
      celestial,
      night ? 34 : 42,
      Paint()..color = palette.accent.withValues(alpha: night ? .08 : .12),
    );
    canvas.drawCircle(
      celestial,
      night ? 20 : 27,
      Paint()..color = palette.accent.withValues(alpha: night ? .18 : .22),
    );
    canvas.drawCircle(
      celestial,
      night ? 9 : 14,
      Paint()..color = palette.accent.withValues(alpha: .92),
    );

    if (night) {
      final star = Paint()..color = Colors.white.withValues(alpha: .58);
      for (final p in [
        Offset(w * .18, h * .17),
        Offset(w * .32, h * .11),
        Offset(w * .57, h * .19),
        Offset(w * .69, h * .09),
        Offset(w * .85, h * .30),
        Offset(w * .44, h * .27),
      ]) {
        canvas.drawCircle(p.translate(breath * 5, 0), 1.4, star);
      }
    }

    _drawCloudLayer(canvas, size, offsetY: h * .27, speed: .5, alpha: night ? .03 : .18, scale: 1.0);
    _drawCloudLayer(canvas, size, offsetY: h * .37, speed: .9, alpha: night ? .02 : .11, scale: .82);

    final distant = Paint()..color = palette.horizon.withValues(alpha: .82);
    final distantPath = Path()
      ..moveTo(0, h * .63)
      ..quadraticBezierTo(w * .16, h * .55, w * .31, h * .63)
      ..quadraticBezierTo(w * .52, h * .49, w * .70, h * .61)
      ..quadraticBezierTo(w * .86, h * .54, w, h * .62)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(distantPath.shift(Offset(breath * -8, 0)), distant);

    final middle = Paint()..color = palette.deep.withValues(alpha: .58);
    final middlePath = Path()
      ..moveTo(0, h * .74)
      ..quadraticBezierTo(w * .18, h * .64, w * .38, h * .74)
      ..quadraticBezierTo(w * .62, h * .60, w, h * .72)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(middlePath.shift(Offset(breath * -14, 0)), middle);

    _drawMosque(canvas, size, breath);
    _drawForeground(canvas, size, breath);
    if (golden) {
      canvas.drawRect(
        Rect.fromLTWH(0, h * .45, w, h * .55),
        Paint()..color = const Color(0xFFFFB56B).withValues(alpha: .05),
      );
    }
  }

  void _drawCloudLayer(
    Canvas canvas,
    Size size, {
    required double offsetY,
    required double speed,
    required double alpha,
    required double scale,
  }) {
    final w = size.width;
    final dx = (parallax - .5) * speed * 20;
    final paint = Paint()..color = Colors.white.withValues(alpha: alpha);
    for (final x in [-.18, .16, .46, .76]) {
      final base = Offset(w * (x + dx / w), offsetY);
      canvas.drawOval(
        Rect.fromCenter(
          center: base,
          width: w * .26 * scale,
          height: size.height * .065 * scale,
        ),
        paint,
      );
      canvas.drawCircle(
        base.translate(w * .04, -size.height * .017),
        size.height * .034 * scale,
        paint,
      );
      canvas.drawCircle(
        base.translate(-w * .04, -size.height * .009),
        size.height * .028 * scale,
        paint,
      );
    }
  }

  void _drawMosque(Canvas canvas, Size size, double breath) {
    final w = size.width;
    final h = size.height;
    final shadow = Paint()..color = palette.deep.withValues(alpha: .92);
    final building = Rect.fromLTWH(w * .31, h * .64, w * .38, h * .23);
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(7)),
      shadow,
    );

    final dome = Path()
      ..moveTo(w * .35, h * .65)
      ..quadraticBezierTo(w * .50, h * .44, w * .65, h * .65)
      ..close();
    canvas.drawPath(dome, shadow);

    final minaretPaint = Paint()..color = palette.deep.withValues(alpha: .96);
    for (final x in [w * .26, w * .69]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + breath * 3, h * .53, w * .026, h * .33),
          const Radius.circular(3),
        ),
        minaretPaint,
      );
      canvas.drawCircle(
        Offset(x + w * .013 + breath * 3, h * .52),
        4,
        minaretPaint,
      );
    }

    final door = Paint()..color = palette.earth.withValues(alpha: .78);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .47, h * .71, w * .06, h * .16),
        const Radius.circular(18),
      ),
      door,
    );

    final window = Paint()..color = palette.accent.withValues(alpha: .10);
    for (final x in [w * .38, w * .62]) {
      canvas.drawCircle(Offset(x, h * .71), 7, window);
    }
  }

  void _drawForeground(Canvas canvas, Size size, double breath) {
    final w = size.width;
    final h = size.height;
    final ground = Paint()..color = palette.deep;
    final path = Path()
      ..moveTo(0, h * .79)
      ..quadraticBezierTo(w * .22, h * .71, w * .45, h * .82)
      ..quadraticBezierTo(w * .68, h * .70, w, h * .80)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path.shift(Offset(breath * -18, 0)), ground);

    final rim = Paint()..color = Colors.white.withValues(alpha: .035);
    canvas.drawPath(
      Path()
        ..moveTo(0, h * .79)
        ..quadraticBezierTo(w * .22, h * .71, w * .45, h * .82)
        ..quadraticBezierTo(w * .68, h * .70, w, h * .80)
        ..lineTo(w, h * .82)
        ..quadraticBezierTo(w * .68, h * .72, w * .45, h * .84)
        ..quadraticBezierTo(w * .22, h * .73, 0, h * .81)
        ..close(),
      rim,
    );
  }

  @override
  bool shouldRepaint(covariant _V6AtmospherePainter oldDelegate) =>
      oldDelegate.parallax != parallax ||
      oldDelegate.palette != palette;
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .10),
            border: Border.all(color: Colors.white.withValues(alpha: .12)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .20),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: .12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _V6Progress extends StatelessWidget {
  const _V6Progress({required this.value, required this.accent});
  final double value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: CustomPaint(
        painter: _V6ProgressPainter(value: value, accent: accent),
      ),
    );
  }
}

class _V6ProgressPainter extends CustomPainter {
  const _V6ProgressPainter({required this.value, required this.accent});
  final double value;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final left = 1.5;
    final right = size.width - 1.5;
    final p = left + (right - left) * value.clamp(0.0, 1.0);
    canvas.drawLine(
      Offset(left, y),
      Offset(right, y),
      Paint()
        ..color = Colors.white.withValues(alpha: .17)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(left, y),
      Offset(p, y),
      Paint()
        ..shader = LinearGradient(
          colors: [accent.withValues(alpha: .45), accent, Colors.white],
        ).createShader(Rect.fromLTRB(left, 0, right, size.height))
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(p, y), 9, Paint()..color = accent.withValues(alpha: .22));
    canvas.drawCircle(Offset(p, y), 4.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _V6ProgressPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.accent != accent;
}

class _V6SunInfo extends StatelessWidget {
  const _V6SunInfo(this.icon, this.label, this.value, {this.end = false});
  final IconData icon;
  final String label;
  final String value;
  final bool end;

  @override
  Widget build(BuildContext context) {
    final children = [
      Column(
        crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: .58), fontSize: 9.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 1),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()])),
        ],
      ),
      const SizedBox(width: 5),
      Icon(icon, size: 16, color: Colors.white.withValues(alpha: .74)),
    ];
    return Row(mainAxisSize: MainAxisSize.min, children: end ? children.reversed.toList() : children);
  }
}

class _V6SectionTitle extends StatelessWidget {
  const _V6SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _V6PrayerTimeline extends StatelessWidget {
  const _V6PrayerTimeline({required this.prayers, required this.languageCode});
  final List<Map<String, dynamic>> prayers;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 18, offset: const Offset(0, 9)),
        ],
      ),
      child: Column(
        children: List.generate(5, (index) {
          final p = index < prayers.length ? prayers[index] : const <String, dynamic>{};
          final current = p['isCurrent'] == true;
          final name = languageCode == 'en' ? (p['name']?.toString() ?? '--') : (p['nameBn']?.toString() ?? '--');
          final time = p['start']?.toString() ?? '--:--';
          final isLast = index == 4;
          return Container(
            margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: current ? primary.withValues(alpha: .08) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: current ? primary : context.secondaryTextColor.withValues(alpha: .26),
                    shape: BoxShape.circle,
                    boxShadow: current
                        ? [BoxShadow(color: primary.withValues(alpha: .28), blurRadius: 10)]
                        : const [],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: current ? primary : context.primaryTextColor,
                      fontSize: 14,
                      fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: current ? primary : context.primaryTextColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ).withBottomMargin(isLast ? 8 : 0);
        }),
      ),
    );
  }
}

class _V6Essentials extends StatelessWidget {
  const _V6Essentials({
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
    final items = [
      ('কিবলা', 'Qibla', Icons.explore_rounded, onQibla),
      ('দোয়া', 'Dua', Icons.auto_awesome_rounded, onDua),
      ('তাসবিহ', 'Tasbih', Icons.circle_outlined, onTasbih),
      ('৯৯ নাম', '99 Names', Icons.favorite_rounded, onNames),
      ('ক্যালেন্ডার', 'Calendar', Icons.calendar_month_rounded, onCalendar),
      ('রুকইয়াহ', 'Ruqyah', Icons.shield_moon_rounded, onRuqyah),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: .96,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final primary = Theme.of(context).colorScheme.primary;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: item.$4,
            child: Container(
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 14, offset: const Offset(0, 7)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item.$3, color: primary, size: 21),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    languageCode == 'en' ? item.$2 : item.$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.primaryTextColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _V6Footer extends StatelessWidget {
  const _V6Footer({
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
            child: Text(
              date,
              style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: prohibitedNow ? Colors.red.withValues(alpha: .10) : primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: prohibitedNow ? Colors.redAccent : primary),
                const SizedBox(width: 5),
                Text(
                  '${languageCode == 'en' ? 'Prohibited' : 'নিষিদ্ধ সময়'}  $countdown',
                  style: TextStyle(
                    color: prohibitedNow ? Colors.redAccent : primary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension _EdgeMargin on Widget {
  Widget withBottomMargin(double margin) => Padding(
        padding: EdgeInsets.only(bottom: margin),
        child: this,
      );
}
