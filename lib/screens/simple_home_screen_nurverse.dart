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

class SimpleHomeScreenNurVerse extends StatefulWidget {
  const SimpleHomeScreenNurVerse({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreenNurVerse> createState() =>
      _SimpleHomeScreenNurVerseState();
}

class _SimpleHomeScreenNurVerseState extends State<SimpleHomeScreenNurVerse> {
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

  String _normalizePrayer(String value) {
    final key = value.trim().toLowerCase();
    if (key.contains('ফজর') || key == 'fajr') return 'Fajr';
    if (key.contains('জুমুআ') || key == 'jumuah') return 'Dhuhr';
    if (key.contains('যোহর') || key == 'dhuhr') return 'Dhuhr';
    if (key.contains('আসর') || key == 'asr') return 'Asr';
    if (key.contains('মাগরিব') || key == 'maghrib') return 'Maghrib';
    if (key.contains('ইশা') || key == 'isha') return 'Isha';
    return '';
  }

  String _prayerLabel(String prayer, String lang) {
    const bn = {
      'Fajr': 'ফজর',
      'Dhuhr': 'যোহর',
      'Asr': 'আসর',
      'Maghrib': 'মাগরিব',
      'Isha': 'ইশা',
    };
    const en = {
      'Fajr': 'Fajr',
      'Dhuhr': 'Dhuhr',
      'Asr': 'Asr',
      'Maghrib': 'Maghrib',
      'Isha': 'Isha',
    };
    return (lang == 'en' ? en : bn)[prayer] ?? prayer;
  }

  int _currentIndex(PrayerController controller) {
    final current = _normalizePrayer(controller.currentPrayer);
    const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final index = prayers.indexOf(current);
    if (index >= 0) return index;

    final next = _normalizePrayer(controller.nextPrayerName);
    final nextIndex = prayers.indexOf(next);
    return nextIndex <= 0 ? 0 : nextIndex - 1;
  }

  _NurVerseTimeMode _timeMode() {
    final hour = DateTime.now().hour + DateTime.now().minute / 60;
    if (hour >= 4.5 && hour < 7.0) return _NurVerseTimeMode.dawn;
    if (hour >= 7.0 && hour < 16.5) return _NurVerseTimeMode.day;
    if (hour >= 16.5 && hour < 19.0) return _NurVerseTimeMode.golden;
    return _NurVerseTimeMode.night;
  }

  String _locationText(PrayerController controller) {
    final raw = controller.currentLocationName.trim();
    if (raw.isEmpty) return '';
    return raw.split(',').first.trim();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final lang = settings.languageCode;
    final primary = theme.colorScheme.primary;
    final location = _locationText(controller);
    final currentPrayer = _normalizePrayer(controller.currentPrayer);
    final nextPrayer = _normalizePrayer(controller.nextPrayerName);
    final activePrayer = currentPrayer.isNotEmpty ? currentPrayer : nextPrayer;
    final progress = controller.prayerProgress.clamp(0.0, 1.0);
    final currentIndex = _currentIndex(controller);
    final hasLastRead = _lastRead != null &&
        '${_lastRead!['surahName'] ?? ''}'.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: primary,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _Header(
                location: location,
                date: DateService.englishDate(),
                language: lang,
              ),
              const SizedBox(height: 14),
              _PrayerHero(
                mode: _timeMode(),
                language: lang,
                activePrayer: _prayerLabel(activePrayer, lang),
                nextPrayer: _prayerLabel(nextPrayer, lang),
                countdown: controller.timeRemainingForNextPrayer,
                progress: progress,
                currentIndex: currentIndex,
              ),
              const SizedBox(height: 14),
              _DaylightRow(
                language: lang,
                location: location,
                sunrise: controller.sunriseTime,
                sunset: controller.sunsetTime,
              ),
              const SizedBox(height: 20),
              _PrayerRail(
                language: lang,
                prayers: controller.prayers,
                currentIndex: currentIndex,
                primary: primary,
              ),
              const SizedBox(height: 20),
              _QuickActions(
                language: lang,
                onQuran: () => _open(const OnudhabonQuranScreen()),
                onQibla: () => _open(const QiblaScreen()),
                onDua: () => _open(const DuaScreen()),
                onTasbih: () => _open(const TasbihScreen()),
              ),
              if (hasLastRead) ...[
                const SizedBox(height: 20),
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
              const SizedBox(height: 18),
              _QuietFooter(
                language: lang,
                prohibited: controller.prohibitedTimeText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _NurVerseTimeMode { dawn, day, golden, night }

class _Header extends StatelessWidget {
  const _Header({required this.location, required this.date, required this.language});

  final String location;
  final String date;
  final String language;

  String _dateText() => language == 'en' ? date : date;

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
                      location.isEmpty
                          ? (language == 'en' ? 'Location' : 'লোকেশন')
                          : location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                _dateText(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.secondaryTextColor,
                ),
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
          child: Icon(Icons.wb_sunny_outlined, color: primary, size: 19),
        ),
      ],
    );
  }
}

class _PrayerHero extends StatelessWidget {
  const _PrayerHero({
    required this.mode,
    required this.language,
    required this.activePrayer,
    required this.nextPrayer,
    required this.countdown,
    required this.progress,
    required this.currentIndex,
  });

  final _NurVerseTimeMode mode;
  final String language;
  final String activePrayer;
  final String nextPrayer;
  final String countdown;
  final double progress;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 318,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.seaBlueDark,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.seaBlueDark.withValues(alpha: .24),
            blurRadius: 28,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _AtmospherePainter(mode: mode),
            ),
          ),
          Positioned(
            top: 17,
            right: 17,
            child: CustomPaint(
              size: const Size(46, 46),
              painter: _CelestialPainter(mode: mode),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 19, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language == 'en' ? 'PRAYER NOW' : 'এখন সালাত',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      activePrayer.isEmpty
                          ? (language == 'en' ? 'Next Prayer' : 'পরবর্তী সালাত')
                          : activePrayer,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      language == 'en' ? 'Waqt ends in' : 'ওয়াক্ত শেষ হবে',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Center(
                    child: Text(
                      countdown,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 31,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 11),
                  SizedBox(
                    height: 74,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _PrayerOrbitPainter(
                        currentIndex: currentIndex,
                        progress: progress,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MiniHeroInfo(
                        label: language == 'en' ? 'Next' : 'পরবর্তী',
                        value: nextPrayer.isEmpty ? '—' : nextPrayer,
                      ),
                      _MiniHeroInfo(
                        label: language == 'en' ? 'Progress' : 'অগ্রগতি',
                        value: '${(progress * 100).round()}%',
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

class _MiniHeroInfo extends StatelessWidget {
  const _MiniHeroInfo({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9.5)),
        const SizedBox(height: 1),
        Text(
          value,
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

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter({required this.mode});
  final _NurVerseTimeMode mode;

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()..color = const Color(0xFF0F5870);
    canvas.drawRect(Offset.zero & size, sky);

    if (mode == _NurVerseTimeMode.day) {
      sky.color = const Color(0xFF196E85);
      canvas.drawRect(Offset.zero & size, sky);
    } else if (mode == _NurVerseTimeMode.golden) {
      sky.color = const Color(0xFF275F71);
      canvas.drawRect(Offset.zero & size, sky);
      final glow = Paint()..color = const Color(0xFFD6A45E).withValues(alpha: .28);
      canvas.drawCircle(Offset(size.width * .22, size.height * .34), 62, glow);
    } else if (mode == _NurVerseTimeMode.night) {
      sky.color = const Color(0xFF082B42);
      canvas.drawRect(Offset.zero & size, sky);
    } else {
      final glow = Paint()..color = const Color(0xFF8BB2BB).withValues(alpha: .18);
      canvas.drawCircle(Offset(size.width * .22, size.height * .34), 58, glow);
    }

    final cloud = Paint()..color = Colors.white.withValues(alpha: .10);
    _cloud(canvas, Offset(size.width * .22, size.height * .25), 0.9, cloud);
    _cloud(canvas, Offset(size.width * .72, size.height * .31), 0.55, cloud);

    final land = Paint()..color = const Color(0xFF123E49);
    final path = Path()
      ..moveTo(0, size.height * .74)
      ..quadraticBezierTo(
        size.width * .24,
        size.height * .66,
        size.width * .46,
        size.height * .74,
      )
      ..quadraticBezierTo(
        size.width * .72,
        size.height * .83,
        size.width,
        size.height * .69,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, land);

    final shore = Paint()..color = const Color(0xFF5D8F8E).withValues(alpha: .18);
    final shorePath = Path()
      ..moveTo(0, size.height * .81)
      ..quadraticBezierTo(
        size.width * .22,
        size.height * .75,
        size.width * .42,
        size.height * .83,
      )
      ..quadraticBezierTo(
        size.width * .67,
        size.height * .90,
        size.width,
        size.height * .80,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(shorePath, shore);
  }

  void _cloud(Canvas canvas, Offset center, double scale, Paint paint) {
    canvas.drawCircle(center + Offset(-20 * scale, 3 * scale), 13 * scale, paint);
    canvas.drawCircle(center + Offset(0, -4 * scale), 19 * scale, paint);
    canvas.drawCircle(center + Offset(20 * scale, 4 * scale), 12 * scale, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + Offset(0, 7 * scale),
          width: 58 * scale,
          height: 16 * scale,
        ),
        Radius.circular(8 * scale),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) =>
      oldDelegate.mode != mode;
}

class _CelestialPainter extends CustomPainter {
  const _CelestialPainter({required this.mode});
  final _NurVerseTimeMode mode;

  @override
  void paint(Canvas canvas, Size size) {
    final isNight = mode == _NurVerseTimeMode.night;
    final paint = Paint()
      ..color = isNight ? Colors.white.withValues(alpha: .90) : const Color(0xFFE8C36B);

    if (isNight) {
      final outer = Path()
        ..addOval(Rect.fromCircle(
          center: Offset(size.width * .5, size.height * .5),
          radius: size.width * .29,
        ));
      final cut = Path()
        ..addOval(Rect.fromCircle(
          center: Offset(size.width * .67, size.height * .40),
          radius: size.width * .26,
        ));
      canvas.drawPath(Path.combine(PathOperation.difference, outer, cut), paint);
    } else {
      canvas.drawCircle(
        Offset(size.width * .5, size.height * .5),
        size.width * .28,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CelestialPainter oldDelegate) => oldDelegate.mode != mode;
}

class _PrayerOrbitPainter extends CustomPainter {
  const _PrayerOrbitPainter({required this.currentIndex, required this.progress});

  final int currentIndex;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const start = math.pi * 1.10;
    const sweep = math.pi * .80;
    final center = Offset(size.width / 2, size.height * .92);
    final radius = size.width * .37;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = Colors.white.withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..color = Colors.white.withValues(alpha: .92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, start, sweep, false, track);

    final overall = ((currentIndex.clamp(0, 4) + progress) / 4).clamp(0.0, 1.0);
    canvas.drawArc(rect, start, sweep * overall, false, active);

    for (int i = 0; i < 5; i++) {
      final p = i / 4;
      final theta = start + sweep * p;
      final point = Offset(
        center.dx + radius * math.cos(theta),
        center.dy + radius * math.sin(theta),
      );
      final isCurrent = i == currentIndex;
      canvas.drawCircle(
        point,
        isCurrent ? 7 : 4.5,
        Paint()..color = isCurrent ? Colors.white : Colors.white38,
      );
      if (isCurrent) {
        canvas.drawCircle(
          point,
          12,
          Paint()..color = Colors.white.withValues(alpha: .10),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PrayerOrbitPainter oldDelegate) =>
      oldDelegate.currentIndex != currentIndex ||
      oldDelegate.progress != progress;
}

class _DaylightRow extends StatelessWidget {
  const _DaylightRow({
    required this.language,
    required this.location,
    required this.sunrise,
    required this.sunset,
  });

  final String language;
  final String location;
  final String sunrise;
  final String sunset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      children: [
        Expanded(
          child: _InfoChip(
            icon: Icons.location_on_outlined,
            title: location.isEmpty
                ? (language == 'en' ? 'Location' : 'লোকেশন')
                : location,
            subtitle: language == 'en' ? 'Tap to refresh' : 'ট্যাপ করে রিফ্রেশ',
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SunMini(
                  icon: Icons.wb_sunny_outlined,
                  title: language == 'en' ? 'Rise' : 'উদয়',
                  time: sunrise,
                ),
                _SunMini(
                  icon: Icons.nights_stay_outlined,
                  title: language == 'en' ? 'Set' : 'অস্ত',
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primary),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.secondaryTextColor,
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, size: 17, color: primary),
        ],
      ),
    );
  }
}

class _SunMini extends StatelessWidget {
  const _SunMini({required this.icon, required this.title, required this.time});
  final IconData icon;
  final String title;
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
            Text(title, style: theme.textTheme.labelSmall?.copyWith(fontSize: 8.5)),
            Text(time, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      ],
    );
  }
}

class _PrayerRail extends StatelessWidget {
  const _PrayerRail({
    required this.language,
    required this.prayers,
    required this.currentIndex,
    required this.primary,
  });

  final String language;
  final List<Map<String, dynamic>> prayers;
  final int currentIndex;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final obligatory = prayers
        .where((item) => item['category'] == 'obligatory')
        .take(5)
        .toList();

    const fallback = [
      ('ফজর', 'Fajr'),
      ('যোহর', 'Dhuhr'),
      ('আসর', 'Asr'),
      ('মাগরিব', 'Maghrib'),
      ('ইশা', 'Isha'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language == 'en' ? 'Today' : 'আজকের সালাত',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 93,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: fallback.length,
            separatorBuilder: (_, __) => const SizedBox(width: 9),
            itemBuilder: (context, index) {
              final map = index < obligatory.length ? obligatory[index] : null;
              final bn = map?['nameBn']?.toString() ?? fallback[index].$1;
              final en = map?['name']?.toString() ?? fallback[index].$2;
              final time = map?['start']?.toString() ?? '--:--';
              final active = index == currentIndex;
              return _PrayerItem(
                name: language == 'en' ? en : bn,
                time: time,
                active: active,
                primary: primary,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PrayerItem extends StatelessWidget {
  const _PrayerItem({required this.name, required this.time, required this.active, required this.primary});
  final String name;
  final String time;
  final bool active;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 88,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: active ? primary : theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? primary : theme.dividerColor.withValues(alpha: .45),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: active ? Colors.white : null,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: active ? Colors.white : null,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? Colors.white : primary.withValues(alpha: .20),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
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

  String _t(String bn, String en) => language == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final items = [
      (Icons.menu_book_rounded, _t('কুরআন', 'Quran'), onQuran),
      (Icons.explore_outlined, _t('কিবলা', 'Qibla'), onQibla),
      (Icons.auto_awesome_outlined, _t('দু‘আ', 'Dua'), onDua),
      (Icons.touch_app_outlined, _t('তাসবিহ', 'Tasbih'), onTasbih),
    ];

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: items[i].$3,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: .09),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(items[i].$1, size: 21, color: primary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        items[i].$2,
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

class _QuietFooter extends StatelessWidget {
  const _QuietFooter({required this.language, required this.prohibited});
  final String language;
  final String prohibited;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 17, color: primary),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              language == 'en' && prohibited.startsWith('পরবর্তী নিষিদ্ধ সময়')
                  ? 'Next prohibited time available in Prayer'
                  : prohibited,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
