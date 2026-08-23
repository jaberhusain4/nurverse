import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
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
import 'tools/tasbih_screen.dart';

class SimpleHomeScreenOriginalV2 extends StatefulWidget {
  const SimpleHomeScreenOriginalV2({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreenOriginalV2> createState() => _SimpleHomeScreenOriginalV2State();
}

class _SimpleHomeScreenOriginalV2State extends State<SimpleHomeScreenOriginalV2> {
  Timer? _timer;
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
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
      final value = await LastReadService.getLastRead();
      if (mounted) setState(() => _lastRead = value);
    } catch (_) {
      if (mounted) setState(() => _lastRead = null);
    }
  }

  Future<void> _refresh() async {
    await context.read<PrayerController>().refreshPrayerTimes();
    await _loadLastRead();
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => page),
    );
    if (mounted) await _loadLastRead();
  }

  String _tr(String bn, String en, String lang) => lang == 'en' ? en : bn;

  String _prayerName(String value, String lang) {
    final key = value.trim().toLowerCase();
    const bn = <String, String>{
      'fajr': 'ফজর',
      'dhuhr': 'যোহর',
      'asr': 'আসর',
      'maghrib': 'মাগরিব',
      'isha': 'ইশা',
    };
    const en = <String, String>{
      'fajr': 'Fajr',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
    };
    return lang == 'en' ? (en[key] ?? value) : (bn[key] ?? value);
  }

  String _bnDigits(String value) => value.replaceAllMapped(RegExp(r'\d'), (match) {
        const digits = '০১২৩৪৫৬৭৮৯';
        return digits[int.parse(match.group(0)!)];
      });

  _Atmosphere _atmosphere() {
    final hour = DateTime.now().hour + DateTime.now().minute / 60;
    if (hour >= 4.5 && hour < 7) return _Atmosphere.dawn;
    if (hour >= 7 && hour < 16.5) return _Atmosphere.day;
    if (hour >= 16.5 && hour < 19) return _Atmosphere.sunset;
    return _Atmosphere.night;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final lang = settings.languageCode;
    final theme = Theme.of(context);
    final location = controller.currentLocationName.trim();
    final current = _prayerName(controller.currentPrayer, lang);
    final next = _prayerName(controller.nextPrayerName, lang);
    final focus = current.isNotEmpty && current != 'ওয়াক্ত নেই' ? current : next;
    final countdown = lang == 'en'
        ? controller.timeRemainingForNextPrayer
        : _bnDigits(controller.timeRemainingForNextPrayer);
    final progress = controller.prayerProgress.clamp(0.0, 1.0);
    final hasLastRead = _lastRead != null && '${_lastRead!['surahName'] ?? ''}'.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
          children: [
            _Header(
              location: location.isEmpty ? 'ঢাকা' : location.split(',').first.trim(),
              date: DateService.englishDate(),
              language: lang,
            ),
            const SizedBox(height: 12),
            _HeroScene(
              atmosphere: _atmosphere(),
              primary: theme.colorScheme.primary,
              language: lang,
              prayer: focus,
              nextPrayer: next,
              countdown: countdown,
              progress: progress,
            ),
            const SizedBox(height: 12),
            _SolarStrip(
              location: location.isEmpty ? 'ঢাকা' : location.split(',').first.trim(),
              sunrise: controller.sunriseTime,
              sunset: controller.sunsetTime,
              language: lang,
              onTap: () => _showLocationSheet(context),
            ),
            const SizedBox(height: 20),
            _SectionTitle(_tr('সালাতের যাত্রা', 'Salah Journey', lang)),
            const SizedBox(height: 9),
            _PrayerJourney(
              language: lang,
              currentPrayer: controller.currentPrayer,
              nextPrayer: controller.nextPrayerName,
              progress: progress,
            ),
            const SizedBox(height: 20),
            _SectionTitle(_tr('দ্রুত প্রবেশ', 'Quick Access', lang)),
            const SizedBox(height: 9),
            _QuickAccess(
              language: lang,
              onQuran: () => _open(const OnudhabonQuranScreen()),
              onQibla: () => _open(const QiblaScreen()),
              onDua: () => _open(const DuaScreen()),
              onTasbih: () => _open(const TasbihScreen()),
            ),
            if (hasLastRead) ...[
              const SizedBox(height: 20),
              _SectionTitle(_tr('কুরআন চালিয়ে যান', 'Continue Quran', lang)),
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
                onTap: () => _open(const OnudhabonQuranScreen(openLastRead: true)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showLocationSheet(BuildContext context) async {
    final controller = context.read<PrayerController>();
    final lang = context.read<SettingsProvider>().languageCode;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr('বর্তমান লোকেশন', 'Current location', lang),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 7),
                Text(controller.currentLocationName, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.of(sheetContext).pop();
                      await controller.refreshLocation();
                    },
                    icon: const Icon(Icons.my_location_rounded),
                    label: Text(_tr('লোকেশন রিফ্রেশ করুন', 'Refresh location', lang)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _Atmosphere { dawn, day, sunset, night }

class _Header extends StatelessWidget {
  const _Header({required this.location, required this.date, required this.language});
  final String location;
  final String date;
  final String language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 17, color: primary),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: primary),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: theme.textTheme.bodySmall?.copyWith(color: context.secondaryTextColor),
              ),
            ],
          ),
        ),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.nights_stay_outlined,
            color: primary,
            size: 19,
          ),
        ),
      ],
    );
  }
}

class _HeroScene extends StatelessWidget {
  const _HeroScene({
    required this.atmosphere,
    required this.primary,
    required this.language,
    required this.prayer,
    required this.nextPrayer,
    required this.countdown,
    required this.progress,
  });

  final _Atmosphere atmosphere;
  final Color primary;
  final String language;
  final String prayer;
  final String nextPrayer;
  final String countdown;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: .18),
            blurRadius: 28,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _LandscapePainter(atmosphere: atmosphere, primary: primary),
            ),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: CustomPaint(
              size: const Size(48, 48),
              painter: _CrescentPainter(night: atmosphere == _Atmosphere.night),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 16,
            child: Column(
              children: [
                Text(
                  prayer.isEmpty ? (language == 'en' ? 'Next Prayer' : 'পরবর্তী সালাত') : prayer,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  language == 'en' ? 'Waqt ends in' : 'ওয়াক্ত শেষ হবে',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 1),
                Text(
                  countdown,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                SizedBox(
                  height: 58,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _ArcProgressPainter(progress: progress),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MiniText(
                      title: language == 'en' ? 'Current' : 'বর্তমান',
                      value: prayer,
                    ),
                    _MiniText(
                      title: language == 'en' ? 'Next' : 'পরবর্তী',
                      value: nextPrayer,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniText extends StatelessWidget {
  const _MiniText({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white60, fontSize: 9.5)),
        const SizedBox(height: 1),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _ArcProgressPainter extends CustomPainter {
  const _ArcProgressPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .95);
    final radius = size.width * .37;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..color = Colors.white.withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    const start = math.pi * 1.17;
    const sweep = math.pi * .66;
    final p = progress.clamp(0.0, 1.0);
    canvas.drawArc(rect, start, sweep, false, track);
    canvas.drawArc(rect, start, sweep * p, false, active);
    final theta = start + sweep * p;
    final point = Offset(
      center.dx + radius * math.cos(theta),
      center.dy + radius * math.sin(theta),
    );
    canvas.drawCircle(point, 5.5, Paint()..color = Colors.white);
    canvas.drawCircle(
      point,
      10,
      Paint()..color = Colors.white.withValues(alpha: .16),
    );
  }

  @override
  bool shouldRepaint(covariant _ArcProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _LandscapePainter extends CustomPainter {
  const _LandscapePainter({required this.atmosphere, required this.primary});
  final _Atmosphere atmosphere;
  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final background = Paint();
    switch (atmosphere) {
      case _Atmosphere.dawn:
        background.color = Color.lerp(primary, const Color(0xFF6A8791), .55)!;
      case _Atmosphere.day:
        background.color = Color.lerp(primary, const Color(0xFF2B91A3), .25)!;
      case _Atmosphere.sunset:
        background.color = Color.lerp(primary, const Color(0xFFB96F60), .42)!;
      case _Atmosphere.night:
        background.color = Color.lerp(primary, const Color(0xFF09172B), .70)!;
    }
    canvas.drawRect(rect, background);

    if (atmosphere == _Atmosphere.night) {
      _stars(canvas, size);
    } else {
      _clouds(canvas, size);
    }

    final horizon = Paint()..color = const Color(0xFF6B7B70).withValues(alpha: .25);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .67, size.width, size.height * .33),
      horizon,
    );

    final dune = Paint()..color = const Color(0xFFB38D68).withValues(alpha: .64);
    final path = Path()
      ..moveTo(0, size.height * .79)
      ..quadraticBezierTo(size.width * .25, size.height * .68, size.width * .52, size.height * .80)
      ..quadraticBezierTo(size.width * .78, size.height * .90, size.width, size.height * .74)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, dune);

    _palm(canvas, Offset(size.width * .10, size.height * .91));
    _palm(canvas, Offset(size.width * .88, size.height * .90));
  }

  void _clouds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .23);
    void cloud(double x, double y, double s) {
      final center = Offset(size.width * x, size.height * y);
      canvas.drawCircle(center + Offset(-20 * s, 5 * s), 16 * s, paint);
      canvas.drawCircle(center + Offset(0, -5 * s), 22 * s, paint);
      canvas.drawCircle(center + Offset(21 * s, 5 * s), 15 * s, paint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center + Offset(0, 8 * s), width: 65 * s, height: 20 * s),
          Radius.circular(10 * s),
        ),
        paint,
      );
    }
    cloud(.22, .22, .75);
    cloud(.72, .30, .52);
  }

  void _stars(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .62);
    const points = <Offset>[
      Offset(.12, .14), Offset(.26, .10), Offset(.40, .20),
      Offset(.58, .12), Offset(.73, .23), Offset(.87, .12),
    ];
    for (final point in points) {
      canvas.drawCircle(Offset(size.width * point.dx, size.height * point.dy), 1.2, paint);
    }
  }

  void _palm(Canvas canvas, Offset base) {
    final trunk = Paint()
      ..color = const Color(0xFF4B3A2F).withValues(alpha: .68)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, base + const Offset(2, -48), trunk);
    final leaf = Paint()
      ..color = const Color(0xFF17413D).withValues(alpha: .76)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final crown = base + const Offset(2, -49);
    for (int i = 0; i < 7; i++) {
      final angle = i / 6 * math.pi * 1.6 + .15;
      canvas.drawLine(
        crown,
        crown + Offset(math.cos(angle) * 24, math.sin(angle) * 18),
        leaf,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LandscapePainter oldDelegate) =>
      oldDelegate.atmosphere != atmosphere || oldDelegate.primary != primary;
}

class _CrescentPainter extends CustomPainter {
  const _CrescentPainter({required this.night});
  final bool night;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: night ? .88 : .44);
    final outer = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * .5, size.height * .5),
          radius: size.width * .30,
        ),
      );
    final cut = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * .67, size.height * .42),
          radius: size.width * .27,
        ),
      );
    canvas.drawPath(Path.combine(PathOperation.difference, outer, cut), paint);
  }

  @override
  bool shouldRepaint(covariant _CrescentPainter oldDelegate) => oldDelegate.night != night;
}

class _SolarStrip extends StatelessWidget {
  const _SolarStrip({
    required this.location,
    required this.sunrise,
    required this.sunset,
    required this.language,
    required this.onTap,
  });

  final String location;
  final String sunrise;
  final String sunset;
  final String language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      children: [
        Expanded(
          child: Material(
            color: primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(17),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(17),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: primary),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 17, color: primary),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SolarValue(icon: Icons.wb_sunny_outlined, label: language == 'en' ? 'Rise' : 'উদয়', value: sunrise),
                Container(width: 1, height: 26, color: theme.dividerColor.withValues(alpha: .45)),
                _SolarValue(icon: Icons.nights_stay_outlined, label: language == 'en' ? 'Set' : 'অস্ত', value: sunset),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SolarValue extends StatelessWidget {
  const _SolarValue({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 15, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: context.secondaryTextColor, fontSize: 8.5)),
            Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      ],
    );
  }
}

class _PrayerJourney extends StatelessWidget {
  const _PrayerJourney({
    required this.language,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.progress,
  });

  final String language;
  final String currentPrayer;
  final String nextPrayer;
  final double progress;

  static const names = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  String label(String name) {
    if (language == 'en') return name;
    const bn = <String, String>{
      'Fajr': 'ফজর', 'Dhuhr': 'যোহর', 'Asr': 'আসর', 'Maghrib': 'মাগরিব', 'Isha': 'ইশা',
    };
    return bn[name] ?? name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final currentKey = currentPrayer.toLowerCase();
    final nextKey = nextPrayer.toLowerCase();
    var activeIndex = names.indexWhere((name) => currentKey.contains(name.toLowerCase()));
    if (activeIndex < 0) {
      activeIndex = names.indexWhere((name) => nextKey.contains(name.toLowerCase()));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 76,
            width: double.infinity,
            child: CustomPaint(
              painter: _JourneyPainter(activeIndex: activeIndex, progress: progress, primary: primary),
            ),
          ),
          Row(
            children: [
              for (final name in names)
                Expanded(
                  child: Text(
                    label(name),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: names.indexOf(name) == activeIndex ? primary : context.secondaryTextColor,
                      fontWeight: names.indexOf(name) == activeIndex ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JourneyPainter extends CustomPainter {
  const _JourneyPainter({required this.activeIndex, required this.progress, required this.primary});
  final int activeIndex;
  final double progress;
  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    final points = List<Offset>.generate(5, (i) {
      final x = size.width * i / 4;
      final y = size.height * (.64 - .25 * math.sin(i / 4 * math.pi));
      return Offset(x, y);
    });
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      path.quadraticBezierTo((a.dx + b.dx) / 2, math.min(a.dy, b.dy) - 4, b.dx, b.dy);
    }
    final track = Paint()
      ..color = primary.withValues(alpha: .12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, track);
    final metric = path.computeMetrics().first;
    final base = activeIndex < 0 ? 0 : activeIndex.toDouble();
    final length = metric.length * ((base + progress.clamp(0.0, 1.0)) / 4).clamp(0.0, 1.0);
    canvas.drawPath(metric.extractPath(0, length), active);
    for (int i = 0; i < points.length; i++) {
      final selected = i == activeIndex;
      canvas.drawCircle(points[i], selected ? 7 : 4.5, Paint()..color = selected ? primary : primary.withValues(alpha: .18));
      if (selected) {
        canvas.drawCircle(points[i], 12, Paint()..color = primary.withValues(alpha: .08));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyPainter oldDelegate) => oldDelegate.activeIndex != activeIndex || oldDelegate.progress != progress || oldDelegate.primary != primary;
}

class _QuickAccess extends StatelessWidget {
  const _QuickAccess({
    required this.language,
    required this.onQuran,
    required this.onQibla,
    required this.onDua,
    required this.onTasbih,
  });

  final String language;
  final VoidCallback onQuran;
  final VoidCallback onQibla;
  final VoidCallback onDua;
  final VoidCallback onTasbih;

  String label(String bn, String en) => language == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      children: [
        _Action(icon: Icons.menu_book_rounded, label: label('কুরআন', 'Quran'), onTap: onQuran, primary: primary),
        const SizedBox(width: 8),
        _Action(icon: Icons.explore_outlined, label: label('কিবলা', 'Qibla'), onTap: onQibla, primary: primary),
        const SizedBox(width: 8),
        _Action(icon: Icons.auto_awesome_outlined, label: label('দু‘আ', 'Dua'), onTap: onDua, primary: primary),
        const SizedBox(width: 8),
        _Action(icon: Icons.touch_app_outlined, label: label('তাসবিহ', 'Tasbih'), onTap: onTasbih, primary: primary),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap, required this.primary});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Material(
        color: primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: primary.withValues(alpha: .11), shape: BoxShape.circle),
                  child: Icon(icon, color: primary, size: 19),
                ),
                const SizedBox(height: 5),
                Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w800),
      );
}
