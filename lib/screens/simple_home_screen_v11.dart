import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../providers/settings_provider.dart';
import '../services/date_service.dart';
import '../theme/app_theme.dart';

class SimpleHomeScreenV11 extends StatefulWidget {
  const SimpleHomeScreenV11({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreenV11> createState() => _SimpleHomeScreenV11State();
}

class _SimpleHomeScreenV11State extends State<SimpleHomeScreenV11>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat(reverse: true);
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

  String _tr(String bn, String en, String code) => code == 'en' ? en : bn;

  String _greeting(String code) {
    if (_now.hour < 12) return _tr('শুভ সকাল', 'Good Morning', code);
    if (_now.hour < 16) return _tr('শুভ দুপুর', 'Good Afternoon', code);
    if (_now.hour < 19) return _tr('শুভ সন্ধ্যা', 'Good Evening', code);
    return _tr('শুভ রাত্রি', 'Good Night', code);
  }

  String _clock() {
    final h = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    return '${h.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}';
  }

  String _hijri(String code) {
    final h = HijriCalendar.now();
    const bn = <String>[
      'মুহররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি', 'জুমাদিউল আউয়াল',
      'জুমাদিউস সানি', 'রজব', 'শাবান', 'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ',
    ];
    const en = <String>[
      'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', 'Jumada al-Awwal',
      'Jumada al-Thani', 'Rajab', 'Sha’ban', 'Ramadan', 'Shawwal', 'Dhul-Qadah', 'Dhul-Hijjah',
    ];
    final month = code == 'en' ? en[h.hMonth - 1] : bn[h.hMonth - 1];
    return code == 'en' ? '${h.hDay} $month ${h.hYear}' : '${_bnDigits(h.hDay)} $month ${_bnDigits(h.hYear)}';
  }

  String _bnDigits(int value) => value.toString().split('').map((d) => '০১২৩৪৫৬৭৮৯'[int.parse(d)]).join();

  String _remaining(PrayerController c) {
    final value = c.timeRemainingForNextPrayer;
    if (value == null) return '--:--:--';
    return value.toString();
  }

  List<Map<String, dynamic>> _prayers(PrayerController c) {
    const keys = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final out = <Map<String, dynamic>>[];
    for (final key in keys) {
      for (final p in c.prayers) {
        final name = '${p['name'] ?? ''}'.toLowerCase();
        final bn = '${p['nameBn'] ?? ''}';
        final match = name.contains(key.toLowerCase()) ||
            (key == 'Fajr' && bn.contains('ফজর')) ||
            (key == 'Dhuhr' && (bn.contains('যোহর') || bn.contains('জুমু'))) ||
            (key == 'Asr' && bn.contains('আসর')) ||
            (key == 'Maghrib' && bn.contains('মাগরিব')) ||
            (key == 'Isha' && bn.contains('ইশা'));
        if (match) {
          out.add(p);
          break;
        }
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final code = settings.languageCode;
    final primary = Theme.of(context).colorScheme.primary;
    final prayers = _prayers(controller);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: primary,
          onRefresh: () => controller.refreshLocation(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            children: [
              _Header(
                greeting: _greeting(code),
                location: controller.currentLocationName,
                hijri: _hijri(code),
              ),
              const SizedBox(height: 14),
              AnimatedBuilder(
                animation: _motion,
                builder: (_, __) => _UnifiedPrayerHero(
                  now: _now,
                  motion: _motion.value,
                  clock: _clock(),
                  nextPrayer: '${controller.nextPrayerName}',
                  nextPrayerTime: '${controller.nextPrayerTime}',
                  remaining: _remaining(controller),
                  currentPrayer: '${controller.currentPrayer}',
                  progress: controller.prayerProgress.clamp(0.0, 1.0),
                  sunrise: '${controller.sunriseTime}',
                  sunset: '${controller.sunsetTime}',
                ),
              ),
              const SizedBox(height: 22),
              _SectionTitle(
                title: _tr('আজকের সালাত', 'Today’s Prayer', code),
                subtitle: _tr('পাঁচ ওয়াক্ত, এক নজরে', 'Five prayers at a glance', code),
              ),
              const SizedBox(height: 10),
              _PrayerTimeline(prayers: prayers, code: code),
              const SizedBox(height: 22),
              _SectionTitle(
                title: _tr('প্রয়োজনীয়', 'Essentials', code),
                subtitle: _tr('প্রতিদিনের গুরুত্বপূর্ণ সুবিধা', 'Everyday essentials', code),
              ),
              const SizedBox(height: 10),
              _Essentials(code: code, onNavigateTab: widget.onNavigateTab),
              const SizedBox(height: 22),
              _Footer(
                date: DateService.englishDate(),
                code: code,
                prohibited: controller.prohibitedTimeText.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting, required this.location, required this.hijri});
  final String greeting;
  final String location;
  final String hijri;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = context.secondaryTextColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: theme.textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 15, color: secondary),
                  const SizedBox(width: 4),
                  Expanded(child: Text(location.trim().isEmpty ? 'Locating…' : location.trim(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: secondary))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(hijri, textAlign: TextAlign.end, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelMedium?.copyWith(fontSize: 10.5, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _UnifiedPrayerHero extends StatelessWidget {
  const _UnifiedPrayerHero({
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
    final palette = _Atmosphere.fromHour(hour);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      height: 430,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .18), blurRadius: 30, offset: const Offset(0, 16))],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _AtmosphericPainter(palette: palette, motion: motion)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: .02), Colors.black.withValues(alpha: .05), Colors.black.withValues(alpha: .36)],
                  stops: const [0, .46, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            top: 18,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(clock, style: const TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w700, letterSpacing: 1.2, height: 1)),
                ),
                _GlassPill(label: nextPrayer, value: nextPrayerTime),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEXT PRAYER', style: TextStyle(color: Colors.white.withValues(alpha: .70), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.7)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(nextPrayer, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)),
                    ),
                    Text(remaining, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(currentPrayer.isEmpty ? nextPrayer : currentPrayer, style: TextStyle(color: Colors.white.withValues(alpha: .78), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 13),
                SizedBox(
                  height: 48,
                  child: CustomPaint(
                    painter: _DayArcPainter(progress: progress, accent: primary),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _TinyTime(label: 'SUNRISE', value: sunrise),
                        _TinyTime(label: 'SUNSET', value: sunset),
                      ],
                    ),
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

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: .18), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withValues(alpha: .12))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: Colors.white.withValues(alpha: .72), fontSize: 10, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _TinyTime extends StatelessWidget {
  const _TinyTime({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: .55), fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      ]);
}

class _Atmosphere {
  const _Atmosphere({required this.top, required this.bottom, required this.horizon, required this.night});
  final Color top;
  final Color bottom;
  final Color horizon;
  final bool night;

  static _Atmosphere fromHour(double h) {
    if (h < 5.5 || h >= 19) return const _Atmosphere(top: Color(0xFF082A48), bottom: Color(0xFF155A78), horizon: Color(0xFF7AA8A9), night: true);
    if (h < 7.5) return const _Atmosphere(top: Color(0xFF126B8D), bottom: Color(0xFFE5A36B), horizon: Color(0xFFF4C184), night: false);
    if (h < 16.5) return const _Atmosphere(top: Color(0xFF4FA8C1), bottom: Color(0xFFBFE1E4), horizon: Color(0xFFE4C38D), night: false);
    return const _Atmosphere(top: Color(0xFF236B82), bottom: Color(0xFFE19A68), horizon: Color(0xFFF0B16E), night: false);
  }
}

class _AtmosphericPainter extends CustomPainter {
  const _AtmosphericPainter({required this.palette, required this.motion});
  final _Atmosphere palette;
  final double motion;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = LinearGradient(colors: [palette.top, palette.bottom, palette.horizon], stops: const [0, .58, 1], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(rect));

    final sunX = size.width * (.73 + math.sin(motion * math.pi * 2) * .025);
    final sunY = palette.night ? size.height * .20 : size.height * (.20 + math.sin(motion * math.pi) * .025);
    final glow = Paint()..color = (palette.night ? const Color(0xFFBFD9E0) : const Color(0xFFFFE5A8)).withValues(alpha: .18);
    canvas.drawCircle(Offset(sunX, sunY), 62, glow);
    canvas.drawCircle(Offset(sunX, sunY), palette.night ? 19 : 24, Paint()..color = palette.night ? const Color(0xFFE6F0E8) : const Color(0xFFFFD27D));

    _cloud(canvas, size, Offset(size.width * (.18 + motion * .035), size.height * .18), 74, .48);
    _cloud(canvas, size, Offset(size.width * (.62 - motion * .04), size.height * .27), 92, .40);
    _cloud(canvas, size, Offset(size.width * (.40 + motion * .025), size.height * .11), 52, .24);

    final far = Paint()..color = const Color(0xFF5F7772).withValues(alpha: .34);
    final farPath = Path()..moveTo(0, size.height * .62);
    for (double x = 0; x <= size.width; x += 4) {
      final y = size.height * .60 + math.sin(x / 65 + motion * 1.2) * 9 + math.sin(x / 31) * 4;
      farPath.lineTo(x, y);
    }
    farPath.lineTo(size.width, size.height);
    farPath.lineTo(0, size.height);
    farPath.close();
    canvas.drawPath(farPath, far);

    final sand = Paint()..color = const Color(0xFFC99A62).withValues(alpha: .92);
    final dune = Path()..moveTo(0, size.height * .70);
    for (double x = 0; x <= size.width; x += 4) {
      final y = size.height * .67 + math.sin(x / 105 + motion * .8) * 18 + math.sin(x / 45) * 5;
      dune.lineTo(x, y);
    }
    dune.lineTo(size.width, size.height);
    dune.lineTo(0, size.height);
    dune.close();
    canvas.drawPath(dune, sand);

    _oasis(canvas, size, Offset(size.width * .70, size.height * .79));
    _palm(canvas, size, Offset(size.width * .14, size.height * .71), 1.05);
    _palm(canvas, size, Offset(size.width * .88, size.height * .72), .82);
    _camel(canvas, size, Offset(size.width * (.43 + motion * .018), size.height * .76));

    if (palette.night) {
      final star = Paint()..color = Colors.white.withValues(alpha: .45);
      for (int i = 0; i < 22; i++) {
        final x = (i * 83.0) % size.width;
        final y = 24 + ((i * 37.0) % (size.height * .40));
        canvas.drawCircle(Offset(x, y), i % 3 == 0 ? 1.4 : .8, star);
      }
    }
  }

  void _cloud(Canvas canvas, Size size, Offset center, double width, double opacity) {
    final shadow = Paint()..color = Colors.white.withValues(alpha: opacity * .22);
    final cloud = Paint()..color = Colors.white.withValues(alpha: opacity);
    final y = center.dy;
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, y + 8), width: width, height: width * .25), shadow);
    canvas.drawCircle(Offset(center.dx - width * .26, y), width * .19, cloud);
    canvas.drawCircle(Offset(center.dx - width * .05, y - width * .08), width * .27, cloud);
    canvas.drawCircle(Offset(center.dx + width * .19, y - width * .02), width * .22, cloud);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, y + width * .04), width: width * .72, height: width * .24), cloud);
  }

  void _palm(Canvas canvas, Size size, Offset base, double scale) {
    final trunk = Paint()..color = const Color(0xFF6D5137);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(base.dx - 3 * scale, base.dy - 88 * scale, 6 * scale, 90 * scale), Radius.circular(3 * scale)), trunk);
    final leaf = Paint()..color = const Color(0xFF315E4C).withValues(alpha: .95);
    for (int i = 0; i < 7; i++) {
      final a = -math.pi + i * math.pi / 6;
      final end = Offset(base.dx + math.cos(a) * 38 * scale, base.dy - 90 * scale + math.sin(a) * 22 * scale);
      canvas.drawLine(Offset(base.dx, base.dy - 90 * scale), end, leaf..strokeWidth = 5 * scale..strokeCap = StrokeCap.round);
    }
  }

  void _oasis(Canvas canvas, Size size, Offset center) {
    canvas.drawOval(Rect.fromCenter(center: center, width: 112, height: 30), Paint()..color = const Color(0xFF245F68).withValues(alpha: .85));
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy - 4), width: 84, height: 16), Paint()..color = const Color(0xFF5AB7B0).withValues(alpha: .55));
  }

  void _camel(Canvas canvas, Size size, Offset base) {
    final p = Paint()..color = const Color(0xFF6B5038);
    canvas.drawOval(Rect.fromCenter(center: Offset(base.dx, base.dy - 22), width: 58, height: 23), p);
    canvas.drawCircle(Offset(base.dx + 27, base.dy - 39), 8, p);
    canvas.drawLine(Offset(base.dx + 27, base.dy - 39), Offset(base.dx + 34, base.dy - 52), p..strokeWidth = 5..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(base.dx - 17, base.dy - 12), Offset(base.dx - 20, base.dy + 6), p..strokeWidth = 4);
    canvas.drawLine(Offset(base.dx + 10, base.dy - 12), Offset(base.dx + 13, base.dy + 6), p..strokeWidth = 4);
  }

  @override
  bool shouldRepaint(covariant _AtmosphericPainter oldDelegate) => oldDelegate.motion != motion || oldDelegate.palette != palette;
}

class _DayArcPainter extends CustomPainter {
  const _DayArcPainter({required this.progress, required this.accent});
  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(8, -12, size.width - 16, 64);
    final base = Paint()..color = Colors.white.withValues(alpha: .22)..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round;
    final active = Paint()..color = accent.withValues(alpha: .95)..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, base);
    canvas.drawArc(rect, math.pi, math.pi * progress.clamp(0.0, 1.0), false, active);
    final angle = math.pi + math.pi * progress.clamp(0.0, 1.0);
    final center = Offset(size.width / 2, 52);
    final rx = (size.width - 16) / 2;
    final ry = 32.0;
    final dot = Offset(center.dx + math.cos(angle) * rx, center.dy + math.sin(angle) * ry);
    canvas.drawCircle(dot, 5.5, Paint()..color = Colors.white);
    canvas.drawCircle(dot, 3.2, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant _DayArcPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.accent != accent;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(fontSize: 11, color: context.secondaryTextColor))])),
      ]);
}

class _PrayerTimeline extends StatelessWidget {
  const _PrayerTimeline({required this.prayers, required this.code});
  final List<Map<String, dynamic>> prayers;
  final String code;
  @override
  Widget build(BuildContext context) {
    const namesBn = ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'ইশা'];
    const namesEn = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final p = i < prayers.length ? prayers[i] : <String, dynamic>{};
          final time = '${p['time'] ?? p['formattedTime'] ?? '--:--'}';
          return Container(
            width: 92,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: primary.withValues(alpha: .07), borderRadius: BorderRadius.circular(18)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(code == 'en' ? namesEn[i] : namesBn[i], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(time, style: TextStyle(fontSize: 12, color: context.secondaryTextColor, fontWeight: FontWeight.w600))]),
          );
        },
      ),
    );
  }
}

class _Essentials extends StatelessWidget {
  const _Essentials({required this.code, required this.onNavigateTab});
  final String code;
  final Function(int)? onNavigateTab;
  @override
  Widget build(BuildContext context) {
    const bn = ['কিবলা', 'দোয়া', 'তাসবিহ', '৯৯ নাম', 'ক্যালেন্ডার', 'রুকইয়াহ'];
    const en = ['Qibla', 'Dua', 'Tasbih', '99 Names', 'Calendar', 'Ruqyah'];
    const icons = [Icons.explore_outlined, Icons.auto_awesome_outlined, Icons.fingerprint, Icons.favorite_outline, Icons.calendar_month_outlined, Icons.shield_outlined];
    final primary = Theme.of(context).colorScheme.primary;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: 1.05),
      itemBuilder: (_, i) => Material(
        color: primary.withValues(alpha: .075),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (i == 0) onNavigateTab?.call(4);
          },
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icons[i], size: 24, color: primary), const SizedBox(height: 7), Text(code == 'en' ? en[i] : bn[i], textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))]),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.date, required this.code, required this.prohibited});
  final String date;
  final String code;
  final String prohibited;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .055), borderRadius: BorderRadius.circular(18)),
        child: Row(children: [Expanded(child: Text(date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))), const SizedBox(width: 10), Flexible(child: Text('${code == 'en' ? 'Prohibited time' : 'নিষিদ্ধ সময়'}: $prohibited', textAlign: TextAlign.end, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, color: context.secondaryTextColor, fontWeight: FontWeight.w600)))])
      );
}
