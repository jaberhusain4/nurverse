import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hijri/hijri_calendar.dart';

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

class SimpleHomeScreenV9 extends StatefulWidget {
  const SimpleHomeScreenV9({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreenV9> createState() => _SimpleHomeScreenV9State();
}

class _SimpleHomeScreenV9State extends State<SimpleHomeScreenV9>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  Timer? _timer;
  DateTime _now = DateTime.now();
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _loadLastRead();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
    if (mounted) await _refreshHome();
  }

  String _tr(String bn, String en, String languageCode) {
    return languageCode == 'en' ? en : bn;
  }

  String _greeting(String languageCode) {
    if (_now.hour < 12) {
      return _tr('শুভ সকাল', 'Good Morning', languageCode);
    }
    if (_now.hour < 16) {
      return _tr('শুভ দুপুর', 'Good Afternoon', languageCode);
    }
    if (_now.hour < 19) {
      return _tr('শুভ সন্ধ্যা', 'Good Evening', languageCode);
    }
    return _tr('শুভ রাত্রি', 'Good Night', languageCode);
  }

  String _clock() {
    final hour = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final minute = _now.minute.toString().padLeft(2, '0');
    final second = _now.second.toString().padLeft(2, '0');
    return '${hour.toString().padLeft(2, '0')}:$minute:$second';
  }

  String _hijri(String languageCode) {
    final h = HijriCalendar.now();
    const bnMonths = <String>[
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
    const enMonths = <String>[
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

    String bnDigits(int value) {
      return value
          .toString()
          .split('')
          .map((d) => '০১২৩৪৫৬৭৮৯'[int.parse(d)])
          .join();
    }

    final month = languageCode == 'en'
        ? enMonths[h.hMonth - 1]
        : bnMonths[h.hMonth - 1];
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

  bool _isProhibited(PrayerController controller) {
    final start = controller.prohibitedStart;
    final end = controller.prohibitedEnd;
    return start != null &&
        end != null &&
        !_now.isBefore(start) &&
        _now.isBefore(end);
  }

  String _countdown(DateTime? target) {
    if (target == null) return '--:--:--';
    final difference = target.difference(_now);
    if (difference.isNegative) return '00:00:00';

    final totalSeconds = difference.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
          color: AppColors.seaBlueDark,
          onRefresh: _refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            children: [
              _V9Header(
                greeting: _greeting(languageCode),
                location: controller.currentLocationName,
                hijri: _hijri(languageCode),
              ),
              const SizedBox(height: 14),
              AnimatedBuilder(
                animation: _motion,
                builder: (_, __) {
                  return _V9PrayerHero(
                    now: _now,
                    motion: _motion.value,
                    clock: _clock(),
                    nextPrayer: controller.nextPrayerName,
                    nextPrayerTime: controller.nextPrayerTime,
                    remaining: controller.timeRemainingForNextPrayer,
                    currentPrayer: controller.currentPrayer,
                    progress: controller.prayerProgress,
                    sunrise: controller.sunriseTime,
                    sunset: controller.sunsetTime,
                  );
                },
              ),
              const SizedBox(height: 22),
              _V9SectionHeading(
                title: _tr('আজকের সালাত', 'Today’s Prayer', languageCode),
                subtitle: _tr(
                  'পাঁচ ওয়াক্ত, পরিষ্কারভাবে',
                  'Five prayers, clearly presented',
                  languageCode,
                ),
              ),
              const SizedBox(height: 10),
              _V9PrayerTimeline(
                prayers: prayers,
                languageCode: languageCode,
              ),
              const SizedBox(height: 22),
              _V9SectionHeading(
                title: _tr('প্রয়োজনীয়', 'Essentials', languageCode),
                subtitle: _tr(
                  'প্রতিদিনের গুরুত্বপূর্ণ সুবিধা',
                  'Everyday essentials',
                  languageCode,
                ),
              ),
              const SizedBox(height: 10),
              _V9Essentials(
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
                _V9SectionHeading(
                  title: _tr('কুরআন চালিয়ে যান', 'Continue Quran', languageCode),
                  subtitle: _tr(
                    'যেখান থেকে থেমেছিলেন',
                    'Pick up where you left off',
                    languageCode,
                  ),
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
              _V9Footer(
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

class _V9Header extends StatelessWidget {
  const _V9Header({
    required this.greeting,
    required this.location,
    required this.hijri,
  });

  final String greeting;
  final String location;
  final String hijri;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
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
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.place_outlined, size: 15, color: secondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location.trim().isEmpty
                          ? 'Locating…'
                          : location.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          constraints: const BoxConstraints(maxWidth: 140),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            hijri,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _V9PrayerHero extends StatelessWidget {
  const _V9PrayerHero({
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

  @override
  Widget build(BuildContext context) {
    final hour = now.hour + now.minute / 60.0;
    final night = hour < 5.5 || hour >= 19.0;
    final dusk = hour >= 16.5 && hour < 19.0;
    final dawn = hour >= 5.5 && hour < 7.5;
    final palette = _V9ScenePalette.fromPhase(
      dawn: dawn,
      dusk: dusk,
      night: night,
    );
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      height: 430,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .16),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _V9DesertPainter(
              palette: palette,
              motion: motion,
              night: night,
              dusk: dusk,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      clock,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    night
                        ? Icons.nightlight_round
                        : dusk
                            ? Icons.wb_twilight_rounded
                            : Icons.wb_sunny_rounded,
                    color: Colors.white.withValues(alpha: .86),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 15, 18, 14),
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      Colors.black.withValues(alpha: night ? .34 : .24),
                      palette.glass,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              nextPrayer.isEmpty ? '—' : nextPrayer,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (currentPrayer.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: .25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                currentPrayer,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        nextPrayerTime.isEmpty ? '—' : nextPrayerTime,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .72),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              remaining.isEmpty ? '--:--:--' : remaining,
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontSize: 36,
                                height: .95,
                                fontWeight: FontWeight.w600,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            'NEXT',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .55),
                              fontSize: 9,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _V9Progress(
                        value: progress.clamp(0.0, 1.0).toDouble(),
                        accent: primary,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _V9SunData(
                            icon: Icons.wb_twilight_rounded,
                            label: 'Sunrise',
                            value: sunrise,
                          ),
                          const Spacer(),
                          _V9SunData(
                            icon: Icons.wb_sunny_outlined,
                            label: 'Sunset',
                            value: sunset,
                            end: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _V9ScenePalette {
  const _V9ScenePalette({
    required this.skyTop,
    required this.skyBottom,
    required this.haze,
    required this.farDune,
    required this.midDune,
    required this.foreDune,
    required this.glass,
  });

  final Color skyTop;
  final Color skyBottom;
  final Color haze;
  final Color farDune;
  final Color midDune;
  final Color foreDune;
  final Color glass;

  static _V9ScenePalette fromPhase({
    required bool dawn,
    required bool dusk,
    required bool night,
  }) {
    if (night) {
      return const _V9ScenePalette(
        skyTop: Color(0xFF061827),
        skyBottom: Color(0xFF17425F),
        haze: Color(0xFF2E6C87),
        farDune: Color(0xFF183647),
        midDune: Color(0xFF0D2738),
        foreDune: Color(0xFF071720),
        glass: Color(0x66243B4C),
      );
    }
    if (dusk) {
      return const _V9ScenePalette(
        skyTop: Color(0xFF234B71),
        skyBottom: Color(0xFFC07B56),
        haze: Color(0xFFE2B18E),
        farDune: Color(0xFF855B4A),
        midDune: Color(0xFF6A493E),
        foreDune: Color(0xFF382F2D),
        glass: Color(0x66363B45),
      );
    }
    if (dawn) {
      return const _V9ScenePalette(
        skyTop: Color(0xFF1B587A),
        skyBottom: Color(0xFFE9C7A0),
        haze: Color(0xFFF1DAB9),
        farDune: Color(0xFF9D7657),
        midDune: Color(0xFF78543D),
        foreDune: Color(0xFF4A372B),
        glass: Color(0x66412F25),
      );
    }
    return const _V9ScenePalette(
      skyTop: Color(0xFF2B7AA0),
      skyBottom: Color(0xFFE6B978),
      haze: Color(0xFFF0D3A2),
      farDune: Color(0xFFAF7B42),
      midDune: Color(0xFF956134),
      foreDune: Color(0xFF58402B),
      glass: Color(0x663F352B),
    );
  }
}

class _V9DesertPainter extends CustomPainter {
  const _V9DesertPainter({
    required this.palette,
    required this.motion,
    required this.night,
    required this.dusk,
  });

  final _V9ScenePalette palette;
  final double motion;
  final bool night;
  final bool dusk;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.skyTop, palette.skyBottom],
        ).createShader(rect),
    );
    _drawAtmosphere(canvas, size);
    _drawCelestial(canvas, size);
    _drawClouds(canvas, size);
    _drawDunes(canvas, size);
    _drawOasis(canvas, size);
    _drawPalms(canvas, size);
    _drawCamel(canvas, size);
  }

  void _drawAtmosphere(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .42, size.width, size.height * .20),
      Paint()..color = palette.haze.withValues(alpha: .18),
    );
  }

  void _drawCelestial(Canvas canvas, Size size) {
    final x = size.width * (.74 + math.sin(motion * math.pi) * .035);
    final y = night
        ? size.height * .18
        : dusk
            ? size.height * .24
            : size.height * .18;

    if (night) {
      canvas.drawCircle(
        Offset(x, y),
        28,
        Paint()..color = Colors.white.withValues(alpha: .09),
      );
      canvas.drawCircle(
        Offset(x, y),
        17,
        Paint()..color = const Color(0xFFE7F4FF),
      );
      canvas.drawCircle(
        Offset(x + 6, y - 4),
        17,
        Paint()..color = palette.skyTop,
      );
      const stars = <Offset>[
        Offset(.12, .16),
        Offset(.22, .24),
        Offset(.61, .13),
        Offset(.84, .27),
        Offset(.45, .12),
        Offset(.91, .17),
      ];
      for (final star in stars) {
        canvas.drawCircle(
          Offset(size.width * star.dx, size.height * star.dy),
          1.4,
          Paint()..color = Colors.white.withValues(alpha: .45),
        );
      }
      return;
    }

    final color = dusk ? const Color(0xFFFFB36A) : const Color(0xFFFFF2B2);
    canvas.drawCircle(
      Offset(x, y),
      58,
      Paint()..color = color.withValues(alpha: .22),
    );
    canvas.drawCircle(Offset(x, y), 24, Paint()..color = color);
  }

  void _drawClouds(Canvas canvas, Size size) {
    final opacity = night ? .045 : .19;
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    final drift = (motion - .5) * 34;

    for (var i = 0; i < 4; i++) {
      final x = size.width * (.06 + i * .26) +
          drift * (i.isEven ? 1 : -.6);
      final y = size.height * (.18 + (i % 2) * .08);
      _drawCloud(canvas, Offset(x, y), 1 + i * .08, paint);
    }
  }

  void _drawCloud(
    Canvas canvas,
    Offset origin,
    double scale,
    Paint paint,
  ) {
    canvas.drawCircle(origin, 13 * scale, paint);
    canvas.drawCircle(
      origin + Offset(16 * scale, -4 * scale),
      18 * scale,
      paint,
    );
    canvas.drawCircle(
      origin + Offset(34 * scale, 1 * scale),
      12 * scale,
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: origin + Offset(18 * scale, 6 * scale),
        width: 58 * scale,
        height: 22 * scale,
      ),
      paint,
    );
  }

  void _drawDunes(Canvas canvas, Size size) {
    Path dune(double y, double amplitude, double frequency) {
      final path = Path()..moveTo(0, size.height * y);
      for (var i = 0; i <= 40; i++) {
        final x = size.width * i / 40;
        final yy = size.height * y +
            math.sin(i / 40 * math.pi * frequency + motion * .6) *
                size.height * amplitude;
        path.lineTo(x, yy);
      }
      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      return path;
    }

    canvas.drawPath(
      dune(.56, .035, 2.2),
      Paint()..color = palette.farDune,
    );
    canvas.drawPath(
      dune(.67, .052, 2.7),
      Paint()..color = palette.midDune,
    );
    canvas.drawPath(
      dune(.79, .075, 3),
      Paint()..color = palette.foreDune,
    );
  }

  void _drawOasis(Canvas canvas, Size size) {
    final center = Offset(size.width * .48, size.height * .72);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .23,
        height: size.height * .075,
      ),
      Paint()..color = const Color(0xFF5F9E98).withValues(alpha: .55),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(0, -2),
        width: size.width * .14,
        height: size.height * .04,
      ),
      Paint()..color = const Color(0xFFB3E0D4).withValues(alpha: .62),
    );
  }

  void _drawPalms(Canvas canvas, Size size) {
    _drawPalm(canvas, Offset(size.width * .16, size.height * .58), .78);
    _drawPalm(canvas, Offset(size.width * .79, size.height * .61), .62);
    _drawPalm(canvas, Offset(size.width * .56, size.height * .63), .48);
  }

  void _drawPalm(Canvas canvas, Offset base, double scale) {
    final trunk = Paint()
      ..color = palette.foreDune.withValues(alpha: .92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          base.dx - 3 * scale,
          base.dy - 55 * scale,
          6 * scale,
          55 * scale,
        ),
        Radius.circular(3 * scale),
      ),
      trunk,
    );

    final leaves = Paint()
      ..color = palette.foreDune.withValues(alpha: .96)
      ..strokeWidth = 4 * scale
      ..strokeCap = StrokeCap.round;
    final top = base + Offset(0, -55 * scale);
    for (var i = 0; i < 7; i++) {
      final angle = -math.pi * .92 + i * math.pi * .30;
      canvas.drawLine(
        top,
        top + Offset(
          math.cos(angle) * 26 * scale,
          math.sin(angle) * 18 * scale,
        ),
        leaves,
      );
    }
  }

  void _drawCamel(Canvas canvas, Size size) {
    final paint = Paint()..color = palette.foreDune.withValues(alpha: .9);
    final y = size.height * .76;
    final x = size.width * (.31 + motion * .045);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y - 20),
        width: 42,
        height: 18,
      ),
      paint,
    );
    canvas.drawCircle(Offset(x + 18, y - 34), 8, paint);

    final leg = Paint()
      ..color = palette.foreDune.withValues(alpha: .9)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    for (final dx in const [-10.0, 8.0]) {
      canvas.drawLine(
        Offset(x + dx, y - 10),
        Offset(x + dx - 4, y + 6),
        leg,
      );
    }
    canvas.drawLine(
      Offset(x + 26, y - 38),
      Offset(x + 34, y - 47),
      leg,
    );
  }

  @override
  bool shouldRepaint(covariant _V9DesertPainter oldDelegate) {
    return oldDelegate.motion != motion ||
        oldDelegate.night != night ||
        oldDelegate.dusk != dusk ||
        oldDelegate.palette.skyTop != palette.skyTop;
  }
}

class _V9Progress extends StatelessWidget {
  const _V9Progress({required this.value, required this.accent});

  final double value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: CustomPaint(
        painter: _V9ProgressPainter(value: value, accent: accent),
      ),
    );
  }
}

class _V9ProgressPainter extends CustomPainter {
  const _V9ProgressPainter({required this.value, required this.accent});

  final double value;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final end = size.width - 2;
    final x = 2 + (end - 2) * value.clamp(0.0, 1.0);

    canvas.drawLine(
      Offset(2, y),
      Offset(end, y),
      Paint()
        ..color = Colors.white.withValues(alpha: .16)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(2, y),
      Offset(x, y),
      Paint()
        ..color = accent
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(x, y),
      7,
      Paint()..color = accent.withValues(alpha: .26),
    );
    canvas.drawCircle(
      Offset(x, y),
      3.5,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _V9ProgressPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.accent != accent;
  }
}

class _V9SunData extends StatelessWidget {
  const _V9SunData({
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
    final labelStyle = TextStyle(
      color: Colors.white.withValues(alpha: .58),
      fontSize: 9,
    );
    final valueStyle = TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!end)
          Icon(icon, size: 15, color: Colors.white.withValues(alpha: .70)),
        if (!end) const SizedBox(width: 5),
        Column(
          crossAxisAlignment:
              end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(label, style: labelStyle),
            const SizedBox(height: 2),
            Text(value, style: valueStyle),
          ],
        ),
        if (end) const SizedBox(width: 5),
        if (end)
          Icon(icon, size: 15, color: Colors.white.withValues(alpha: .70)),
      ],
    );
  }
}

class _V9SectionHeading extends StatelessWidget {
  const _V9SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: context.secondaryTextColor,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }
}

class _V9PrayerTimeline extends StatelessWidget {
  const _V9PrayerTimeline({
    required this.prayers,
    required this.languageCode,
  });

  final List<Map<String, dynamic>> prayers;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: List.generate(5, (index) {
          final prayer = index < prayers.length
              ? prayers[index]
              : const <String, dynamic>{};
          final isCurrent = prayer['isCurrent'] == true;
          final name = languageCode == 'en'
              ? (prayer['name']?.toString() ?? '—')
              : (prayer['nameBn']?.toString() ?? '—');
          final time = prayer['start']?.toString() ?? '—';

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isCurrent
                  ? primary.withValues(alpha: .08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? primary.withValues(alpha: .14)
                        : primary.withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    _iconForPrayer(index),
                    size: 18,
                    color: primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: isCurrent
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'NOW',
                      style: TextStyle(
                        color: primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  IconData _iconForPrayer(int index) {
    const icons = <IconData>[
      Icons.nightlight_round,
      Icons.wb_sunny_outlined,
      Icons.wb_twilight_rounded,
      Icons.wb_sunny_rounded,
      Icons.dark_mode_rounded,
    ];
    return icons[index];
  }
}

class _V9Essentials extends StatelessWidget {
  const _V9Essentials({
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
    final primary = Theme.of(context).colorScheme.primary;
    final items = <(String, String, IconData, VoidCallback)>[
      ('কিবলা', 'Qibla', Icons.explore_rounded, onQibla),
      ('দোয়া', 'Dua', Icons.auto_awesome_rounded, onDua),
      ('তাসবিহ', 'Tasbih', Icons.fingerprint_rounded, onTasbih),
      ('৯৯ নাম', '99 Names', Icons.favorite_rounded, onNames),
      ('ক্যালেন্ডার', 'Calendar', Icons.calendar_month_rounded, onCalendar),
      ('রুকইয়াহ', 'Ruqyah', Icons.menu_book_rounded, onRuqyah),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: .98,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final label = languageCode == 'en' ? item.$2 : item.$1;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.$4,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(18),
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
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 12.5,
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

class _V9Footer extends StatelessWidget {
  const _V9Footer({
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
    final title = _tr('নিষিদ্ধ সময়', 'Prohibited time', languageCode);
    final state = prohibitedNow
        ? _tr('এখন চলছে', 'Active now', languageCode)
        : _tr('পরবর্তী সময়', 'Next window', languageCode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
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
                  date,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: context.secondaryTextColor,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                state,
                style: TextStyle(
                  color: primary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                countdown,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _tr(String bn, String en, String languageCode) {
    return languageCode == 'en' ? en : bn;
  }
}
