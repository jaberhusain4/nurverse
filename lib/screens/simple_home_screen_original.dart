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
import 'tools/asma_ul_husna.dart';
import 'tools/tasbih_screen.dart';

class SimpleHomeScreenOriginal extends StatefulWidget {
  const SimpleHomeScreenOriginal({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreenOriginal> createState() => _SimpleHomeScreenOriginalState();
}

class _SimpleHomeScreenOriginalState extends State<SimpleHomeScreenOriginal> {
  Timer? _ticker;
  DateTime _now = DateTime.now();
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _loadLastRead();
  }

  @override
  void dispose() {
    _ticker?.cancel();
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

  String _prayerLabel(String value, String lang) {
    final key = value.trim().toLowerCase();
    const bn = <String, String>{
      'fajr': 'ফজর',
      'dhuhr': 'যোহর',
      'asr': 'আসর',
      'maghrib': 'মাগরিব',
      'isha': 'ইশা',
      'তাহাজ্জুদ': 'তাহাজ্জুদ',
      'তাহাজ্জুদের': 'তাহাজ্জুদ',
    };
    const en = <String, String>{
      'fajr': 'Fajr',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
    };
    if (lang == 'en') return en[key] ?? value;
    return bn[key] ?? value;
  }

  String _formatNumber(String value) {
    return value.replaceAllMapped(RegExp(r'\d'), (m) {
      const digits = '০১২৩৪৫৬৭৮৯';
      return digits[int.parse(m.group(0)!)];
    });
  }

  String _localizedDate(String lang) {
    final english = DateService.englishDate();
    return lang == 'en' ? english : english;
  }

  _SceneMode _sceneMode() {
    final hour = _now.hour + (_now.minute / 60);
    if (hour >= 4.5 && hour < 7.0) return _SceneMode.dawn;
    if (hour >= 7.0 && hour < 16.5) return _SceneMode.day;
    if (hour >= 16.5 && hour < 19.0) return _SceneMode.sunset;
    return _SceneMode.night;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final lang = settings.languageCode;
    final theme = Theme.of(context);
    final location = controller.currentLocationName.trim();
    final currentPrayer = _prayerLabel(controller.currentPrayer, lang);
    final nextPrayer = _prayerLabel(controller.nextPrayerName, lang);
    final activePrayer = currentPrayer.isNotEmpty && currentPrayer != 'ওয়াক্ত নেই'
        ? currentPrayer
        : nextPrayer;
    final countdown = controller.timeRemainingForNextPrayer;
    final progress = controller.prayerProgress.clamp(0.0, 1.0);
    final scene = _sceneMode();
    final hasLastRead = _lastRead != null &&
        '${_lastRead!['surahName'] ?? ''}'.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
          children: [
            _TopContext(
              language: lang,
              location: location.isEmpty ? 'ঢাকা' : location.split(',').first,
              date: _localizedDate(lang),
            ),
            const SizedBox(height: 10),
            _PrayerAtmosphere(
              mode: scene,
              language: lang,
              activePrayer: activePrayer,
              nextPrayer: nextPrayer,
              countdown: lang == 'en' ? countdown : _formatNumber(countdown),
              progress: progress,
              prayerStatus: controller.prayerStatus,
            ),
            const SizedBox(height: 12),
            _SunLocationStrip(
              language: lang,
              location: location.isEmpty ? 'ঢাকা' : location.split(',').first,
              sunrise: controller.sunriseTime,
              sunset: controller.sunsetTime,
              onLocationTap: () => _showLocationInfo(context),
            ),
            const SizedBox(height: 18),
            _SectionTitle(
              _tr('সালাতের যাত্রা', 'Salah Journey', lang),
            ),
            const SizedBox(height: 10),
            _PrayerJourney(
              language: lang,
              controller: controller,
              progress: progress,
            ),
            const SizedBox(height: 20),
            _SectionTitle(_tr('দ্রুত প্রবেশ', 'Quick Access', lang)),
            const SizedBox(height: 10),
            _QuickActions(
              language: lang,
              onQuran: () => _open(const OnudhabonQuranScreen()),
              onQibla: () => _open(const QiblaScreen()),
              onDua: () => _open(const DuaScreen()),
              onTasbih: () => _open(const TasbihScreen()),
            ),
            if (hasLastRead) ...[
              const SizedBox(height: 20),
              _SectionTitle(_tr('কুরআন চালিয়ে যান', 'Continue Quran', lang)),
              const SizedBox(height: 10),
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
    );
  }

  Future<void> _showLocationInfo(BuildContext context) async {
    final controller = context.read<PrayerController>();
    final lang = context.read<SettingsProvider>().languageCode;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr('বর্তমান লোকেশন', 'Current location', lang),
                  style: Theme.of(sheetContext)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.currentLocationName,
                  style: Theme.of(sheetContext).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.of(sheetContext).pop();
                      await controller.refreshLocation();
                    },
                    icon: const Icon(Icons.my_location_rounded),
                    label: Text(
                      _tr(
                        'বর্তমান লোকেশন পুনরায় নিন',
                        'Refresh current location',
                        lang,
                      ),
                    ),
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

enum _SceneMode { dawn, day, sunset, night }

class _TopContext extends StatelessWidget {
  const _TopContext({
    required this.language,
    required this.location,
    required this.date,
  });

  final String language;
  final String location;
  final String date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .10),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.nights_stay_outlined, size: 19, color: primary),
        ),
      ],
    );
  }
}

class _PrayerAtmosphere extends StatelessWidget {
  const _PrayerAtmosphere({
    required this.mode,
    required this.language,
    required this.activePrayer,
    required this.nextPrayer,
    required this.countdown,
    required this.progress,
    required this.prayerStatus,
  });

  final _SceneMode mode;
  final String language;
  final String activePrayer;
  final String nextPrayer;
  final String countdown;
  final double progress;
  final String prayerStatus;

  String _heading() {
    if (activePrayer.isNotEmpty) return activePrayer;
    return language == 'en' ? 'Next Prayer' : 'পরবর্তী সালাত';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
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
              painter: _AtmospherePainter(mode: mode, primary: primary),
            ),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: CustomPaint(
              size: const Size(54, 54),
              painter: _MoonPainter(mode: mode),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 17,
            child: Column(
              children: [
                Text(
                  _heading(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  language == 'en' ? 'Waqt ends in' : 'ওয়াক্ত শেষ হবে',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  countdown,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .2,
                  ),
                ),
                const SizedBox(height: 11),
                SizedBox(
                  height: 70,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _SalahArcPainter(
                      progress: progress,
                      accent: Colors.white,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SceneMeta(
                      label: language == 'en' ? 'Current' : 'বর্তমান',
                      value: activePrayer,
                    ),
                    _SceneMeta(
                      label: language == 'en' ? 'Next' : 'পরবর্তী',
                      value: nextPrayer,
                    ),
                  ],
                ),
                if (prayerStatus.trim().isNotEmpty &&
                    prayerStatus != 'সালাতের সময় গণনা করা হচ্ছে...') ...[
                  const SizedBox(height: 3),
                  Text(
                    prayerStatus,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneMeta extends StatelessWidget {
  const _SceneMeta({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 9.5),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SalahArcPainter extends CustomPainter {
  const _SalahArcPainter({required this.progress, required this.accent});
  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .92);
    final radius = size.width * .37;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..color = Colors.white.withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..color = accent.withValues(alpha: .95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    const start = math.pi * 1.17;
    const sweep = math.pi * .66;
    canvas.drawArc(rect, start, sweep, false, track);
    canvas.drawArc(
      rect,
      start,
      sweep * progress.clamp(0.0, 1.0),
      false,
      active,
    );

    final theta = start + sweep * progress.clamp(0.0, 1.0);
    final point = Offset(
      center.dx + radius * math.cos(theta),
      center.dy + radius * math.sin(theta),
    );
    canvas.drawCircle(point, 6.5, Paint()..color = accent);
    canvas.drawCircle(
      point,
      11,
      Paint()
        ..color = accent.withValues(alpha: .16)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _SalahArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accent != accent;
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter({required this.mode, required this.primary});
  final _SceneMode mode;
  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Canvas(PlatformDispatcher.instance.views.first)
        .viewConfiguration;
    final _ = sky;

    final Rect area = Offset.zero & size;
    final Paint background = Paint();
    switch (mode) {
      case _SceneMode.dawn:
        background.color = Color.lerp(primary, const Color(0xFF567A87), .58)!;
        canvas.drawRect(area, background);
        _drawHorizon(canvas, size, const Color(0xFFB9A079), .76);
        _drawClouds(canvas, size, Colors.white.withValues(alpha: .25));
      case _SceneMode.day:
        background.color = Color.lerp(primary, const Color(0xFF2B90A5), .28)!;
        canvas.drawRect(area, background);
        _drawHorizon(canvas, size, const Color(0xFF8EA785), .78);
        _drawClouds(canvas, size, Colors.white.withValues(alpha: .28));
      case _SceneMode.sunset:
        background.color = Color.lerp(primary, const Color(0xFFCA835F), .38)!;
        canvas.drawRect(area, background);
        _drawHorizon(canvas, size, const Color(0xFF9C745F), .78);
        _drawClouds(canvas, size, Colors.white.withValues(alpha: .18));
      case _SceneMode.night:
        background.color = Color.lerp(primary, const Color(0xFF091A31), .64)!;
        canvas.drawRect(area, background);
        _drawStars(canvas, size);
        _drawHorizon(canvas, size, const Color(0xFF1C3950), .80);
      }

    final haze = Paint()..color = Colors.white.withValues(alpha: .04);
    canvas.drawCircle(
      Offset(size.width * .18, size.height * .25),
      size.width * .22,
      haze,
    );

    final sand = Paint()..color = const Color(0xFFB48B61).withValues(alpha: .58);
    final dune = Path()
      ..moveTo(0, size.height * .82)
      ..quadraticBezierTo(
        size.width * .24,
        size.height * .69,
        size.width * .53,
        size.height * .80,
      )
      ..quadraticBezierTo(
        size.width * .80,
        size.height * .88,
        size.width,
        size.height * .76,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(dune, sand);

    _drawPalm(canvas, size, Offset(size.width * .10, size.height * .86));
    _drawPalm(canvas, size, Offset(size.width * .87, size.height * .86));
  }

  void _drawHorizon(Canvas canvas, Size size, Color color, double height) {
    final paint = Paint()..color = color.withValues(alpha: .28);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * height, size.width, size.height * .22),
      paint,
    );
  }

  void _drawClouds(Canvas canvas, Size size, Color color) {
    final paint = Paint()..color = color;
    void cloud(Offset center, double scale) {
      canvas.drawCircle(center + Offset(-22 * scale, 4 * scale), 18 * scale, paint);
      canvas.drawCircle(center + Offset(0, -4 * scale), 25 * scale, paint);
      canvas.drawCircle(center + Offset(24 * scale, 5 * scale), 17 * scale, paint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center + Offset(2 * scale, 8 * scale),
            width: 70 * scale,
            height: 24 * scale,
          ),
          Radius.circular(12 * scale),
        ),
        paint,
      );
    }
    cloud(Offset(size.width * .25, size.height * .22), .72);
    cloud(Offset(size.width * .70, size.height * .31), .52);
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .58);
    const points = <Offset>[
      Offset(.12, .16),
      Offset(.28, .10),
      Offset(.43, .20),
      Offset(.59, .12),
      Offset(.77, .22),
      Offset(.86, .13),
    ];
    for (final point in points) {
      canvas.drawCircle(
        Offset(size.width * point.dx, size.height * point.dy),
        1.2,
        paint,
      );
    }
  }

  void _drawPalm(Canvas canvas, Size size, Offset base) {
    final trunk = Paint()
      ..color = const Color(0xFF4D3D31).withValues(alpha: .60)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, base + const Offset(3, -48), trunk);
    final leaf = Paint()
      ..color = const Color(0xFF1C3E3B).withValues(alpha: .72)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final crown = base + const Offset(4, -50);
    for (int i = 0; i < 7; i++) {
      final angle = (i / 6) * math.pi * 1.6 + .15;
      final end = crown + Offset(math.cos(angle) * 25, math.sin(angle) * 18);
      canvas.drawLine(crown, end, leaf);
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) =>
      oldDelegate.mode != mode || oldDelegate.primary != primary;
}

class _MoonPainter extends CustomPainter {
  const _MoonPainter({required this.mode});
  final _SceneMode mode;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (mode == _SceneMode.day || mode == _SceneMode.dawn)
          ? Colors.white.withValues(alpha: .42)
          : Colors.white.withValues(alpha: .86);
    final outer = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * .5, size.height * .5),
          radius: size.width * .31,
        ),
      );
    final cut = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * .66, size.height * .42),
          radius: size.width * .28,
        ),
      );
    canvas.drawPath(Path.combine(PathOperation.difference, outer, cut), paint);
  }

  @override
  bool shouldRepaint(covariant _MoonPainter oldDelegate) => oldDelegate.mode != mode;
}

class _SunLocationStrip extends StatelessWidget {
  const _SunLocationStrip({
    required this.language,
    required this.location,
    required this.sunrise,
    required this.sunset,
    required this.onLocationTap,
  });

  final String language;
  final String location;
  final String sunrise;
  final String sunset;
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      children: [
        Expanded(
          child: _InfoPill(
            icon: Icons.location_on_outlined,
            label: location,
            trailing: Icons.keyboard_arrow_down_rounded,
            onTap: onLocationTap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SunTime(
                  icon: Icons.wb_sunny_outlined,
                  label: language == 'en' ? 'Rise' : 'উদয়',
                  time: sunrise,
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: theme.dividerColor.withValues(alpha: .45),
                ),
                _SunTime(
                  icon: Icons.nights_stay_outlined,
                  label: language == 'en' ? 'Set' : 'অস্ত',
                  time: sunset,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final IconData trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Material(
      color: primary.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: Row(
            children: [
              Icon(icon, size: 16, color: primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(trailing, size: 17, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SunTime extends StatelessWidget {
  const _SunTime({required this.icon, required this.label, required this.time});
  final IconData icon;
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: context.secondaryTextColor,
                fontSize: 9,
              ),
            ),
            Text(
              time,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrayerJourney extends StatelessWidget {
  const _PrayerJourney({
    required this.language,
    required this.controller,
    required this.progress,
  });

  final String language;
  final PrayerController controller;
  final double progress;

  static const prayers = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  String label(String name) {
    if (language == 'en') return name;
    const bn = <String, String>{
      'Fajr': 'ফজর',
      'Dhuhr': 'যোহর',
      'Asr': 'আসর',
      'Maghrib': 'মাগরিব',
      'Isha': 'ইশা',
    };
    return bn[name] ?? name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final current = controller.currentPrayer.toLowerCase();
    int currentIndex = prayers.indexWhere((p) => current.contains(p.toLowerCase()));
    if (currentIndex < 0) {
      final next = controller.nextPrayerName.toLowerCase();
      currentIndex = prayers.indexWhere((p) => next.contains(p.toLowerCase()));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 13),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 88,
            width: double.infinity,
            child: CustomPaint(
              painter: _JourneyPainter(
                activeIndex: currentIndex,
                progress: progress,
                primary: primary,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final prayer in prayers)
                Expanded(
                  child: Text(
                    label(prayer),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: prayers.indexOf(prayer) == currentIndex
                          ? primary
                          : context.secondaryTextColor,
                      fontWeight: prayers.indexOf(prayer) == currentIndex
                          ? FontWeight.w800
                          : FontWeight.w600,
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
  const _JourneyPainter({
    required this.activeIndex,
    required this.progress,
    required this.primary,
  });

  final int activeIndex;
  final double progress;
  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    final points = List<Offset>.generate(5, (index) {
      final x = size.width * (index / 4);
      final y = size.height * (0.62 - 0.30 * math.sin(index / 4 * math.pi));
      return Offset(x, y);
    });

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final mid = Offset((p1.dx + p2.dx) / 2, math.min(p1.dy, p2.dy) - 4);
      path.quadraticBezierTo(mid.dx, mid.dy, p2.dx, p2.dy);
    }

    final track = Paint()
      ..color = primary.withValues(alpha: .13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, track);

    final metrics = path.computeMetrics().first;
    final activeLength = metrics.length *
        (((activeIndex < 0 ? 0 : activeIndex) + progress.clamp(0.0, 1.0)) / 4)
            .clamp(0.0, 1.0);
    canvas.drawPath(metrics.extractPath(0, activeLength), active);

    for (int i = 0; i < points.length; i++) {
      final isActive = i == activeIndex;
      canvas.drawCircle(
        points[i],
        isActive ? 8 : 5,
        Paint()
          ..color = isActive ? primary : primary.withValues(alpha: .20)
          ..style = PaintingStyle.fill,
      );
      if (isActive) {
        canvas.drawCircle(
          points[i],
          13,
          Paint()
            ..color = primary.withValues(alpha: .10)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyPainter oldDelegate) =>
      oldDelegate.activeIndex != activeIndex ||
      oldDelegate.progress != progress ||
      oldDelegate.primary != primary;
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
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

  String t(String bn, String en) => language == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final items = <({IconData icon, String label, VoidCallback onTap})>[
      (icon: Icons.menu_book_rounded, label: t('কুরআন', 'Quran'), onTap: onQuran),
      (icon: Icons.explore_outlined, label: t('কিবলা', 'Qibla'), onTap: onQibla),
      (icon: Icons.auto_awesome_outlined, label: t('দু‘আ', 'Dua'), onTap: onDua),
      (icon: Icons.touch_app_outlined, label: t('তাসবিহ', 'Tasbih'), onTap: onTasbih),
    ];

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Material(
              color: primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(19),
              child: InkWell(
                onTap: items[i].onTap,
                borderRadius: BorderRadius.circular(19),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Column(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: .11),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(items[i].icon, size: 19, color: primary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        items[i].label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
