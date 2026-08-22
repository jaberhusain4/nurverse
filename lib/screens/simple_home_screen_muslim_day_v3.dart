import 'dart:async';
import 'dart:math' as math;

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../providers/settings_provider.dart';
import '../services/date_service.dart';
import '../services/last_read_service.dart';
import '../services/prayer_engine_service.dart';
import '../theme/app_theme.dart';
import '../widgets/home/continue_reading_card.dart';
import 'dua/dua_screen.dart';
import 'qibla/qibla_screen.dart';
import 'quran/onudhabon_quran_screen.dart';
import 'tools/asma_ul_husna.dart';
import 'tools/calendar_screen.dart';
import 'tools/ruqyah_screen.dart';
import 'tools/tasbih_screen.dart';

/// Simple Home V3.
///
/// The Informative Home is intentionally isolated from this screen. This
/// screen owns its presentation and manual-location UI and does not mutate the
/// Informative Home's widgets or layout.
class SimpleHomeScreenMuslimDayV3 extends StatefulWidget {
  const SimpleHomeScreenMuslimDayV3({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreenMuslimDayV3> createState() =>
      _SimpleHomeScreenMuslimDayV3State();
}

class _SimpleHomeScreenMuslimDayV3State
    extends State<SimpleHomeScreenMuslimDayV3> {
  final PrayerEngineService _engine = const PrayerEngineService();
  Timer? _ticker;
  DateTime _now = DateTime.now();
  Map<String, dynamic>? _lastRead;
  Position? _manualPosition;
  String? _manualLocationName;
  int _carouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        _carouselIndex = (_now.second ~/ 4) % 2;
      });
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
    await context.read<PrayerController>().refreshLocation();
    if (mounted) {
      setState(() {
        _manualPosition = null;
        _manualLocationName = null;
      });
    }
    await _loadLastRead();
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => page),
    );
    if (mounted) await _loadLastRead();
  }

  String _tr(String bn, String en, String lang) => lang == 'en' ? en : bn;

  String _hijri(String lang) {
    final h = HijriCalendar.now();
    const bn = <String>[
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
    const en = <String>[
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
    final month = lang == 'en' ? en[h.hMonth - 1] : bn[h.hMonth - 1];
    return lang == 'en'
        ? '${h.hDay} $month'
        : '${bnDigits(h.hDay)} $month';
  }

  String _banglaDate(DateTime date, String lang) {
    const months = <String>[
      'বৈশাখ',
      'জ্যৈষ্ঠ',
      'আষাঢ়',
      'শ্রাবণ',
      'ভাদ্র',
      'আশ্বিন',
      'কার্তিক',
      'অগ্রহায়ণ',
      'পৌষ',
      'মাঘ',
      'ফাল্গুন',
      'চৈত্র',
    ];

    DateTime banglaYearStart(int gregorianYear) =>
        DateTime(gregorianYear, 4, 14);

    final currentYearStart = banglaYearStart(date.year);
    final start = date.isBefore(currentYearStart)
        ? banglaYearStart(date.year - 1)
        : currentYearStart;
    final banglaYear = date.isBefore(currentYearStart)
        ? date.year - 594
        : date.year - 593;
    final dayOfYear = date.difference(start).inDays;
    final leapBangla = ((banglaYear + 593) % 4 == 0);
    final lengths = <int>[31, 31, 31, 31, 31, 30, 30, 30, 30, 30, leapBangla ? 30 : 29, 30];

    var remaining = dayOfYear;
    var monthIndex = 0;
    while (monthIndex < lengths.length - 1 && remaining >= lengths[monthIndex]) {
      remaining -= lengths[monthIndex];
      monthIndex++;
    }
    final day = remaining + 1;
    final month = months[monthIndex];
    final dayText = lang == 'en' ? '$day' : _bnDigits(day);
    return lang == 'en' ? '$day $month' : '$dayText $month';
  }

  String _bnDigits(int value) => value
      .toString()
      .split('')
      .map((d) => '০১২৩৪৫৬৭৮৯'[int.parse(d)])
      .join();

  String _formatPrayerName(Prayer prayer, String lang) {
    const en = <Prayer, String>{
      Prayer.fajr: 'Fajr',
      Prayer.dhuhr: 'Dhuhr',
      Prayer.asr: 'Asr',
      Prayer.maghrib: 'Maghrib',
      Prayer.isha: 'Isha',
    };
    const bn = <Prayer, String>{
      Prayer.fajr: 'ফজর',
      Prayer.dhuhr: 'যোহর',
      Prayer.asr: 'আসর',
      Prayer.maghrib: 'মাগরিব',
      Prayer.isha: 'ইশা',
    };
    return (lang == 'en' ? en : bn)[prayer] ?? '';
  }

  PrayerTimes? _timesFor(PrayerController controller) {
    final position = _manualPosition ?? controller.position;
    if (position == null) return null;
    return _engine.getPrayerTimes(
      position: position,
      date: _now,
    );
  }

  DateTime? _timeForPrayer(PrayerTimes? times, Prayer prayer) =>
      times?.timeForPrayer(prayer);

  Prayer? _currentPrayer(PrayerTimes? times) => times?.currentPrayer();

  Prayer? _nextPrayer(PrayerTimes? times) => times?.nextPrayer();

  DateTime? _prayerEnd(PrayerTimes? times) {
    final current = _currentPrayer(times);
    if (current == null) return null;
    final next = _nextPrayer(times);
    if (next == null) return _timeForPrayer(times, Prayer.fajr);
    return _timeForPrayer(times, next);
  }

  String _countdownTo(DateTime? target) {
    if (target == null) return '--:--:--';
    final difference = target.difference(_now);
    if (difference.isNegative) return '00:00:00';
    final total = difference.inSeconds;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double _currentProgress(PrayerTimes? times) {
    final current = _currentPrayer(times);
    if (current == null) return 0;
    final next = _nextPrayer(times);
    final start = _timeForPrayer(times, current);
    final end = next == null ? null : _timeForPrayer(times, next);
    if (start == null || end == null || !end.isAfter(start)) return 0.0;
    final total = end.difference(start).inMilliseconds;
    final elapsed = _now.difference(start).inMilliseconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  Future<void> _showLocationPicker() async {
    final theme = Theme.of(context);
    final controller = context.read<PrayerController>();
    final lang = context.read<SettingsProvider>().languageCode;
    final input = TextEditingController();
    var loading = false;
    String? error;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: theme.cardColor,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> applyManual() async {
              final query = input.text.trim();
              if (query.isEmpty) return;
              setSheetState(() {
                loading = true;
                error = null;
              });
              try {
                final results = await locationFromAddress(query);
                if (results.isEmpty) {
                  throw Exception(_tr('লোকেশন পাওয়া যায়নি', 'Location not found', lang));
                }
                final result = results.first;
                final position = Position(
                  latitude: result.latitude,
                  longitude: result.longitude,
                  timestamp: DateTime.now(),
                  accuracy: 0,
                  altitude: 0,
                  altitudeAccuracy: 0,
                  heading: 0,
                  headingAccuracy: 0,
                  speed: 0,
                  speedAccuracy: 0,
                  isMocked: false,
                );
                if (!mounted) return;
                setState(() {
                  _manualPosition = position;
                  _manualLocationName = query;
                });
                Navigator.of(sheetContext).pop();
              } catch (_) {
                setSheetState(() {
                  loading = false;
                  error = _tr('লোকেশন নির্বাচন করা যায়নি', 'Could not select this location', lang);
                });
              }
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  4,
                  18,
                  18 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tr('লোকেশন নির্বাচন করুন', 'Select location', lang),
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _tr('শহর বা এলাকার নাম লিখুন', 'Enter a city or area', lang),
                      style: theme.textTheme.bodySmall?.copyWith(color: context.secondaryTextColor),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: input,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => applyManual(),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: lang == 'en' ? 'Dhaka' : 'ঢাকা',
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 8),
                      Text(error!, style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: loading ? null : applyManual,
                        child: Text(loading
                            ? _tr('অনুসন্ধান করা হচ্ছে…', 'Searching…', lang)
                            : _tr('লোকেশন ব্যবহার করুন', 'Use this location', lang)),
                      ),
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.of(sheetContext).pop();
                          await controller.refreshLocation();
                          if (mounted) {
                            setState(() {
                              _manualPosition = null;
                              _manualLocationName = null;
                            });
                          }
                        },
                        icon: const Icon(Icons.my_location_rounded),
                        label: Text(_tr('বর্তমান লোকেশন ব্যবহার করুন', 'Use current location', lang)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    input.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final lang = settings.languageCode;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final times = _timesFor(controller);
    final current = _currentPrayer(times);
    final next = _nextPrayer(times);
    final currentEnd = _prayerEnd(times);
    final countdown = currentEnd != null
        ? _countdownTo(currentEnd)
        : controller.timeRemainingForNextPrayer;
    final currentName = current != null
        ? _formatPrayerName(current, lang)
        : (controller.currentPrayer.isNotEmpty ? controller.currentPrayer : _tr('ওয়াক্ত নেই', 'No prayer', lang));
    final nextName = next != null
        ? _formatPrayerName(next, lang)
        : controller.nextPrayerName;
    final sunrise = _timeForPrayer(times, Prayer.sunrise);
    final sunset = _timeForPrayer(times, Prayer.maghrib);
    final location = _manualLocationName ?? controller.currentLocationName;
    final hijri = _hijri(lang);
    final banglaDate = _banglaDate(_now, lang);
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
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
            children: [
              _PrayerHeroCard(
                lang: lang,
                hijri: hijri,
                gregorian: DateService.englishDate(),
                banglaDate: banglaDate,
                currentPrayer: currentName,
                nextPrayer: nextName,
                countdown: countdown,
                progress: _currentProgress(times),
                sunrise: sunrise,
                sunset: sunset,
                location: location,
                onLocationTap: _showLocationPicker,
              ),
              const SizedBox(height: 18),
              _SimplePrayerRows(
                times: times,
                lang: lang,
                current: current,
              ),
              const SizedBox(height: 18),
              _SectionTitle(title: _tr('প্রয়োজনীয়', 'Essentials', lang)),
              const SizedBox(height: 9),
              _Essentials(
                lang: lang,
                onQibla: () => _open(const QiblaScreen()),
                onDua: () => _open(const DuaScreen()),
                onTasbih: () => _open(const TasbihScreen()),
                onNames: () => _open(const AsmaUlHusnaScreen()),
                onCalendar: () => _open(const CalendarScreen()),
                onRuqyah: () => _open(const RuqyahScreen()),
              ),
              if (hasLastRead) ...[
                const SizedBox(height: 20),
                _SectionTitle(title: _tr('কুরআন চালিয়ে যান', 'Continue Quran', lang)),
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
      ),
    );
  }
}

class _PrayerHeroCard extends StatelessWidget {
  const _PrayerHeroCard({
    required this.lang,
    required this.hijri,
    required this.gregorian,
    required this.banglaDate,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.countdown,
    required this.progress,
    required this.sunrise,
    required this.sunset,
    required this.location,
    required this.onLocationTap,
  });

  final String lang;
  final String hijri;
  final String gregorian;
  final String banglaDate;
  final String currentPrayer;
  final String nextPrayer;
  final String countdown;
  final double progress;
  final DateTime? sunrise;
  final DateTime? sunset;
  final String location;
  final VoidCallback onLocationTap;

  String _tr(String bn, String en) => lang == 'en' ? en : bn;

  String _formatTime(DateTime? value) {
    if (value == null) return '--:--';
    final h = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$h:${value.minute.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final darkSea = AppColors.seaBlueDark;
    final lightSea = AppColors.seaBlue;
    final cardText = Colors.white;
    final muted = Colors.white.withValues(alpha: .78);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: darkSea,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: darkSea.withValues(alpha: .22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.wb_sunny_rounded, color: lightSea, size: 22),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(hijri, style: TextStyle(color: cardText, fontSize: 15.5, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 3),
                          Text('$gregorian, $banglaDate', style: TextStyle(color: muted, fontSize: 11.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              CustomPaint(size: const Size(30, 30), painter: _CrescentPainter(color: cardText)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 112,
            width: double.infinity,
            child: CustomPaint(
              painter: _PrayerArcPainter(
                progress: progress,
                trackColor: Colors.white.withValues(alpha: .14),
                progressColor: lightSea,
              ),
              child: Align(
                alignment: const Alignment(.76, -.98),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: cardText,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cardText.withValues(alpha: .55),
                        blurRadius: 7,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 1),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .35),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Text(
              _carouselIndexText(currentPrayer, nextPrayer, lang, _now),
              key: ValueKey('${currentPrayer}_${nextPrayer}_${_now.second ~/ 4}'),
              style: TextStyle(color: cardText, fontSize: 23, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _tr('ওয়াক্ত শেষ হবে', 'Waqt ends in'),
            style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            countdown,
            style: TextStyle(color: cardText, fontSize: 29, fontWeight: FontWeight.w800, letterSpacing: .2),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoPill(
                  icon: Icons.location_on_outlined,
                  text: _compactLocation(location),
                  trailing: Icons.keyboard_arrow_down_rounded,
                  onTap: onLocationTap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SunInfoPill(
                  sunrise: _formatTime(sunrise),
                  sunset: _formatTime(sunset),
                  color: cardText,
                  muted: muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _carouselIndexText(String current, String next, String lang, DateTime now) {
    final first = current.isEmpty || current == 'ওয়াক্ত নেই'
        ? _tr('ইশা', 'Isha')
        : current;
    final second = _tr('তাহাজ্জুদ', 'Tahajjud');
    return (now.second ~/ 4).isEven ? first : second;
  }

  String _compactLocation(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Dhaka';
    final first = trimmed.split(',').first.trim();
    return first.isEmpty ? trimmed : first;
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text, required this.trailing, required this.onTap});
  final IconData icon;
  final String text;
  final IconData trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Colors.white;
    return Material(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 5),
              Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700))),
              Icon(trailing, size: 17, color: color.withValues(alpha: .86)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SunInfoPill extends StatelessWidget {
  const _SunInfoPill({required this.sunrise, required this.sunset, required this.color, required this.muted});
  final String sunrise;
  final String sunset;
  final Color color;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(children: [Icon(Icons.wb_sunny_outlined, size: 15, color: color), const SizedBox(width: 4), Text(sunrise, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700))]),
          Container(width: 1, height: 14, color: muted.withValues(alpha: .35)),
          Row(children: [Icon(Icons.nights_stay_outlined, size: 15, color: color), const SizedBox(width: 4), Text(sunset, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700))]),
        ],
      ),
    );
  }
}

class _PrayerArcPainter extends CustomPainter {
  const _PrayerArcPainter({required this.progress, required this.trackColor, required this.progressColor});
  final double progress;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .96);
    final radius = math.min(size.width * .42, size.height * 1.10);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    const start = math.pi * 1.15;
    const sweep = math.pi * .70;
    canvas.drawArc(rect, start, sweep, false, track);
    canvas.drawArc(rect, start, sweep * progress.clamp(0, 1), false, fill);
  }

  @override
  bool shouldRepaint(covariant _PrayerArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.trackColor != trackColor || oldDelegate.progressColor != progressColor;
}

class _CrescentPainter extends CustomPainter {
  const _CrescentPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final outer = Path()..addOval(Rect.fromCircle(center: Offset(size.width * .5, size.height * .5), radius: size.width * .34));
    final cut = Path()..addOval(Rect.fromCircle(center: Offset(size.width * .64, size.height * .39), radius: size.width * .30));
    canvas.drawPath(Path.combine(PathOperation.difference, outer, cut), paint);
  }

  @override
  bool shouldRepaint(covariant _CrescentPainter oldDelegate) => oldDelegate.color != color;
}

class _SimplePrayerRows extends StatelessWidget {
  const _SimplePrayerRows({required this.times, required this.lang, required this.current});
  final PrayerTimes? times;
  final String lang;
  final Prayer? current;

  String _name(Prayer prayer) {
    const en = <Prayer, String>{Prayer.fajr: 'Fajr', Prayer.dhuhr: 'Dhuhr', Prayer.asr: 'Asr', Prayer.maghrib: 'Maghrib', Prayer.isha: 'Isha'};
    const bn = <Prayer, String>{Prayer.fajr: 'ফজর', Prayer.dhuhr: 'যোহর', Prayer.asr: 'আসর', Prayer.maghrib: 'মাগরিব', Prayer.isha: 'ইশা'};
    return (lang == 'en' ? en : bn)[prayer] ?? '';
  }

  String _format(DateTime? time) {
    if (time == null) return '--:--';
    final h = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$h:${time.minute.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    const prayers = <Prayer>[Prayer.fajr, Prayer.dhuhr, Prayer.asr, Prayer.maghrib, Prayer.isha];
    return Container(
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          for (var i = 0; i < prayers.length; i++) ...[
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
              leading: Container(width: 8, height: 8, decoration: BoxDecoration(color: prayers[i] == current ? primary : theme.dividerColor, shape: BoxShape.circle)),
              title: Text(_name(prayers[i]), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: prayers[i] == current ? FontWeight.w800 : FontWeight.w600, color: prayers[i] == current ? primary : null)),
              trailing: Text(_format(times?.timeForPrayer(prayers[i])), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: prayers[i] == current ? FontWeight.w800 : FontWeight.w600, color: prayers[i] == current ? primary : null)),
            ),
            if (i != prayers.length - 1) Divider(height: 1, indent: 16, endIndent: 16, color: theme.dividerColor.withValues(alpha: .45)),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w800));
}

class _Essentials extends StatelessWidget {
  const _Essentials({required this.lang, required this.onQibla, required this.onDua, required this.onTasbih, required this.onNames, required this.onCalendar, required this.onRuqyah});
  final String lang;
  final VoidCallback onQibla;
  final VoidCallback onDua;
  final VoidCallback onTasbih;
  final VoidCallback onNames;
  final VoidCallback onCalendar;
  final VoidCallback onRuqyah;

  String _tr(String bn, String en) => lang == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 9,
      crossAxisSpacing: 9,
      childAspectRatio: 1.08,
      children: [
        _Tile(icon: Icons.explore_outlined, label: _tr('কিবলা', 'Qibla'), onTap: onQibla),
        _Tile(icon: Icons.auto_awesome_outlined, label: _tr('দু‘আ', 'Dua'), onTap: onDua),
        _Tile(icon: Icons.touch_app_outlined, label: _tr('তাসবিহ', 'Tasbih'), onTap: onTasbih),
        _Tile(icon: Icons.auto_awesome_rounded, label: _tr('৯৯ নাম', '99 Names'), onTap: onNames),
        _Tile(icon: Icons.calendar_month_outlined, label: _tr('ক্যালেন্ডার', 'Calendar'), onTap: onCalendar),
        _Tile(icon: Icons.shield_outlined, label: _tr('রুকইয়াহ', 'Ruqyah'), onTap: onRuqyah),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 24, color: primary),
          const SizedBox(height: 7),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
