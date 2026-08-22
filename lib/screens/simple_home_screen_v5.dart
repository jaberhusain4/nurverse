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

class SimpleHomeScreenV5 extends StatefulWidget {
  const SimpleHomeScreenV5({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreenV5> createState() => _SimpleHomeScreenV5State();
}

class _SimpleHomeScreenV5State extends State<SimpleHomeScreenV5> {
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
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
    if (mounted) await _refreshHome();
  }

  String _l(String languageCode, String bn, String en) =>
      languageCode == 'en' ? en : bn;

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
    final difference = target.difference(_now);
    if (difference.isNegative) return '00:00:00';
    final total = difference.inSeconds;
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
    final activeProhibited = _isProhibited(controller);

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
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
            children: [
              _ModernHeader(
                greeting: _greeting(languageCode),
                location: controller.currentLocationName,
                date: _hijri(languageCode),
                languageCode: languageCode,
              ),
              const SizedBox(height: 14),
              _NextPrayerHero(
                now: _now,
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
              const SizedBox(height: 16),
              _SectionHeader(
                title: _l(languageCode, 'আজকের সালাত', 'Today’s Prayer'),
                subtitle: _l(languageCode, 'পাঁচ ওয়াক্ত এক নজরে', 'Five daily prayers at a glance'),
              ),
              const SizedBox(height: 9),
              _PrayerTimeline(
                prayers: prayers,
                languageCode: languageCode,
              ),
              const SizedBox(height: 18),
              _SectionHeader(
                title: _l(languageCode, 'প্রয়োজনীয়', 'Essentials'),
                subtitle: _l(languageCode, 'দৈনন্দিন গুরুত্বপূর্ণ সুবিধা', 'Everyday essentials'),
              ),
              const SizedBox(height: 9),
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
                const SizedBox(height: 18),
                _SectionHeader(
                  title: _l(languageCode, 'কুরআন চালিয়ে যান', 'Continue Quran'),
                  subtitle: _l(languageCode, 'যেখান থেকে থেমেছিলেন', 'Pick up where you left off'),
                ),
                const SizedBox(height: 9),
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
              _CompactFooter(
                date: DateService.englishDate(),
                activeProhibited: activeProhibited,
                countdown: _countdown(
                  activeProhibited
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

class _ModernHeader extends StatelessWidget {
  const _ModernHeader({
    required this.greeting,
    required this.location,
    required this.date,
    required this.languageCode,
  });

  final String greeting;
  final String location;
  final String date;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    final city = location.trim().isEmpty
        ? (languageCode == 'en' ? 'Locating your area…' : 'লোকেশন নির্ধারণ হচ্ছে…')
        : location.trim();

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
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: primary,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: secondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      city,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondary,
                        fontSize: 12.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: primary.withValues(alpha: .09)),
          ),
          child: Text(
            date,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.primaryTextColor,
              fontSize: 11,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _NextPrayerHero extends StatelessWidget {
  const _NextPrayerHero({
    required this.now,
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
  final String clock;
  final String nextPrayer;
  final String nextPrayerTime;
  final String remaining;
  final String currentPrayer;
  final double progress;
  final String sunrise;
  final String sunset;
  final String languageCode;

  String _l(String bn, String en) => languageCode == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    final isNight = now.hour < 5 || now.hour >= 19;
    final isSunset = now.hour >= 16 && now.hour < 19;
    final palette = isNight
        ? const _HeroPalette(
            top: Color(0xFF071A2D),
            bottom: Color(0xFF133A58),
            accent: Color(0xFF6FD8FF),
            silhouette: Color(0xFF07111D),
          )
        : isSunset
            ? const _HeroPalette(
                top: Color(0xFF153C61),
                bottom: Color(0xFFB96670),
                accent: Color(0xFFFFD9A8),
                silhouette: Color(0xFF132031),
              )
            : const _HeroPalette(
                top: Color(0xFF116B9B),
                bottom: Color(0xFF4CC4E9),
                accent: Color(0xFFFFF0C6),
                silhouette: Color(0xFF12384B),
              );

    final progressValue = progress.clamp(0.0, 1.0).toDouble();
    final clockStyle = GoogleFonts.googleSansTextTheme().displaySmall?.copyWith(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          letterSpacing: .4,
          fontFeatures: const [FontFeature.tabularFigures()],
        ) ??
        const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        );

    return Container(
      height: 340,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .13),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [palette.top, palette.bottom],
              ),
            ),
          ),
          CustomPaint(
            painter: _HeroScenePainter(
              palette: palette,
              night: isNight,
              accent: palette.accent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withValues(alpha: .12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mosque_rounded, size: 14, color: Colors.white.withValues(alpha: .9)),
                          const SizedBox(width: 5),
                          Text(
                            _l('পরের সালাত', 'NEXT PRAYER'),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .92),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      clock,
                      style: clockStyle,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  nextPrayer.isEmpty ? '--' : nextPrayer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.googleSans(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  nextPrayerTime.isEmpty ? '--:--' : nextPrayerTime,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .87),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 11),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        remaining.isEmpty ? '--:--:--' : remaining,
                        style: GoogleFonts.googleSans(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w500,
                          height: .96,
                          letterSpacing: -1.0,
                        ).copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _l('এখন', 'NOW'),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .60),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentPrayer.isEmpty ? '--' : currentPrayer,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _PremiumProgressRail(
                  value: progressValue,
                  accent: palette.accent,
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    _SunInfo(
                      icon: Icons.wb_twilight_rounded,
                      label: _l('সূর্যোদয়', 'Sunrise'),
                      value: sunrise,
                    ),
                    const Spacer(),
                    _SunInfo(
                      icon: Icons.wb_sunny_outlined,
                      label: _l('সূর্যাস্ত', 'Sunset'),
                      value: sunset,
                      alignEnd: true,
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

class _HeroPalette {
  const _HeroPalette({required this.top, required this.bottom, required this.accent, required this.silhouette});
  final Color top;
  final Color bottom;
  final Color accent;
  final Color silhouette;
}

class _HeroScenePainter extends CustomPainter {
  const _HeroScenePainter({required this.palette, required this.night, required this.accent});
  final _HeroPalette palette;
  final bool night;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()..color = Colors.white.withValues(alpha: .05);
    canvas.drawCircle(
      Offset(size.width * .82, size.height * .24),
      night ? 30 : 34,
      Paint()..color = accent.withValues(alpha: night ? .10 : .17),
    );
    canvas.drawCircle(
      Offset(size.width * .82, size.height * .24),
      night ? 18 : 22,
      Paint()..color = accent.withValues(alpha: night ? .14 : .24),
    );

    final wave = Path()
      ..moveTo(0, size.height * .73)
      ..quadraticBezierTo(
        size.width * .18,
        size.height * .61,
        size.width * .38,
        size.height * .72,
      )
      ..quadraticBezierTo(
        size.width * .66,
        size.height * .57,
        size.width,
        size.height * .70,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      wave,
      Paint()..color = palette.silhouette.withValues(alpha: .62),
    );

    final ground = Path()
      ..moveTo(0, size.height * .80)
      ..quadraticBezierTo(
        size.width * .28,
        size.height * .68,
        size.width * .53,
        size.height * .78,
      )
      ..quadraticBezierTo(
        size.width * .75,
        size.height * .68,
        size.width,
        size.height * .78,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(ground, Paint()..color = palette.silhouette.withValues(alpha: .95));

    final mosque = Paint()..color = palette.silhouette;
    final base = Rect.fromLTWH(
      size.width * .31,
      size.height * .70,
      size.width * .38,
      size.height * .20,
    );
    canvas.drawRect(base, mosque);
    final dome = Path()
      ..moveTo(size.width * .38, size.height * .70)
      ..quadraticBezierTo(
        size.width * .50,
        size.height * .51,
        size.width * .62,
        size.height * .70,
      )
      ..close();
    canvas.drawPath(dome, mosque);
    canvas.drawRect(
      Rect.fromLTWH(size.width * .492, size.height * .45, size.width * .016, size.height * .25),
      mosque,
    );
    canvas.drawCircle(Offset(size.width * .50, size.height * .44), 3.5, mosque);
    for (final x in <double>[.27, .70]) {
      canvas.drawRect(
        Rect.fromLTWH(size.width * x, size.height * .58, size.width * .02, size.height * .31),
        mosque,
      );
      canvas.drawCircle(
        Offset(size.width * (x + .01), size.height * .575),
        3,
        mosque,
      );
    }

    canvas.drawCircle(
      Offset(size.width * .12, size.height * .18),
      2,
      sky,
    );
  }

  @override
  bool shouldRepaint(covariant _HeroScenePainter oldDelegate) =>
      oldDelegate.palette.top != palette.top ||
      oldDelegate.palette.bottom != palette.bottom ||
      oldDelegate.night != night ||
      oldDelegate.accent != accent;
}

class _PremiumProgressRail extends StatelessWidget {
  const _PremiumProgressRail({required this.value, required this.accent});
  final double value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: CustomPaint(
        painter: _ProgressRailPainter(value: value, accent: accent),
      ),
    );
  }
}

class _ProgressRailPainter extends CustomPainter {
  const _ProgressRailPainter({required this.value, required this.accent});
  final double value;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final startX = 2.0;
    final endX = size.width - 2.0;
    final track = Paint()
      ..color = Colors.white.withValues(alpha: .17)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(startX, centerY), Offset(endX, centerY), track);

    final progressX = startX + (endX - startX) * value.clamp(0.0, 1.0);
    final active = Paint()
      ..shader = LinearGradient(
        colors: [accent.withValues(alpha: .58), accent, Colors.white],
      ).createShader(Rect.fromLTRB(startX, 0, endX, size.height))
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(startX, centerY), Offset(progressX, centerY), active);

    final glow = Paint()..color = accent.withValues(alpha: .25);
    canvas.drawCircle(Offset(progressX, centerY), 8, glow);
    canvas.drawCircle(Offset(progressX, centerY), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ProgressRailPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.accent != accent;
}

class _SunInfo extends StatelessWidget {
  const _SunInfo({required this.icon, required this.label, required this.value, this.alignEnd = false});
  final IconData icon;
  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!alignEnd) Icon(icon, size: 16, color: Colors.white.withValues(alpha: .72)),
        if (!alignEnd) const SizedBox(width: 5),
        Column(
          crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: .62), fontSize: 9.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 1),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()])),
          ],
        ),
        if (alignEnd) const SizedBox(width: 5),
        if (alignEnd) Icon(icon, size: 16, color: Colors.white.withValues(alpha: .72)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11.5, color: context.secondaryTextColor, fontWeight: FontWeight.w500)),
            ],
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .08)),
      ),
      child: Column(
        children: List.generate(5, (index) {
          final p = index < prayers.length ? prayers[index] : const <String, dynamic>{};
          final current = p['isCurrent'] == true;
          final first = index == 0;
          final last = index == 4;
          final primary = Theme.of(context).colorScheme.primary;
          final name = languageCode == 'en' ? (p['name']?.toString() ?? '--') : (p['nameBn']?.toString() ?? '--');
          final time = p['start']?.toString() ?? '--:--';

          return Container(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
            decoration: BoxDecoration(
              color: current ? primary.withValues(alpha: .065) : Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(first ? 22 : 0),
                topRight: Radius.circular(first ? 22 : 0),
                bottomLeft: Radius.circular(last ? 22 : 0),
                bottomRight: Radius.circular(last ? 22 : 0),
              ),
              border: index == 0
                  ? null
                  : Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: .55), width: .6)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: current ? primary.withValues(alpha: .13) : primary.withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    current ? Icons.notifications_active_rounded : Icons.mosque_outlined,
                    size: 18,
                    color: current ? primary : context.secondaryTextColor,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name, style: TextStyle(fontSize: 14, fontWeight: current ? FontWeight.w800 : FontWeight.w700)),
                          if (current) ...[
                            const SizedBox(width: 7),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(color: primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(999)),
                              child: Text(languageCode == 'en' ? 'NOW' : 'এখন', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: primary)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        current ? (languageCode == 'en' ? 'Prayer time is running' : 'সালাতের সময় চলছে') : (languageCode == 'en' ? 'Scheduled prayer' : 'নির্ধারিত সালাত'),
                        style: TextStyle(fontSize: 10.5, color: context.secondaryTextColor, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  time,
                  style: GoogleFonts.googleSans(
                    fontSize: 15,
                    fontWeight: current ? FontWeight.w700 : FontWeight.w600,
                    color: current ? primary : context.primaryTextColor,
                  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _EssentialsGrid extends StatelessWidget {
  const _EssentialsGrid({required this.languageCode, required this.onQibla, required this.onDua, required this.onTasbih, required this.onNames, required this.onCalendar, required this.onRuqyah});
  final String languageCode;
  final VoidCallback onQibla;
  final VoidCallback onDua;
  final VoidCallback onTasbih;
  final VoidCallback onNames;
  final VoidCallback onCalendar;
  final VoidCallback onRuqyah;

  String _l(String bn, String en) => languageCode == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    final items = <_EssentialItem>[
      _EssentialItem(Icons.explore_rounded, _l('কিবলা', 'Qibla'), onQibla),
      _EssentialItem(Icons.favorite_rounded, _l('দোয়া', 'Dua'), onDua),
      _EssentialItem(Icons.touch_app_rounded, _l('তাসবিহ', 'Tasbih'), onTasbih),
      _EssentialItem(Icons.auto_awesome_rounded, _l('৯৯ নাম', '99 Names'), onNames),
      _EssentialItem(Icons.calendar_month_rounded, _l('ক্যালেন্ডার', 'Calendar'), onCalendar),
      _EssentialItem(Icons.health_and_safety_rounded, _l('রুকইয়াহ', 'Ruqyah'), onRuqyah),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (_, index) => _EssentialTile(item: items[index]),
    );
  }
}

class _EssentialItem {
  const _EssentialItem(this.icon, this.title, this.onTap);
  final IconData icon;
  final String title;
  final VoidCallback onTap;
}

class _EssentialTile extends StatelessWidget {
  const _EssentialTile({required this.item});
  final _EssentialItem item;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .055),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primary.withValues(alpha: .09)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary.withValues(alpha: .18), primary.withValues(alpha: .08)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 20, color: primary),
              ),
              const SizedBox(height: 7),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: context.primaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactFooter extends StatelessWidget {
  const _CompactFooter({required this.date, required this.activeProhibited, required this.countdown, required this.languageCode});
  final String date;
  final bool activeProhibited;
  final String countdown;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    final english = languageCode == 'en';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: .07)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(Icons.calendar_month_rounded, size: 18, color: primary),
                ),
                const SizedBox(width: 9),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(english ? 'Date' : 'তারিখ', style: TextStyle(fontSize: 10, color: secondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(date, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: context.primaryTextColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 34, color: Theme.of(context).dividerColor.withValues(alpha: .55)),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(activeProhibited ? Icons.block_rounded : Icons.access_time_rounded, size: 18, color: primary),
              const SizedBox(width: 7),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    activeProhibited
                        ? (english ? 'Prohibited now' : 'নিষিদ্ধ সময় চলছে')
                        : (english ? 'Next prohibited' : 'পরবর্তী নিষিদ্ধ সময়'),
                    style: TextStyle(fontSize: 10, color: secondary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    countdown,
                    style: GoogleFonts.googleSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: primary,
                      letterSpacing: .4,
                    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
