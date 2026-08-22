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
    const bn = [
      'মুহররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি', 'জুমাদিউল আউয়াল',
      'জুমাদিউস সানি', 'রজব', 'শাবান', 'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ',
    ];
    const en = [
      'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', 'Jumada al-Awwal',
      'Jumada al-Thani', 'Rajab', 'Sha’ban', 'Ramadan', 'Shawwal', 'Dhul-Qadah',
      'Dhul-Hijjah',
    ];
    final month = lang == 'en' ? en[h.hMonth - 1] : bn[h.hMonth - 1];
    return lang == 'en' ? '${h.hDay} $month' : '${_bnDigits(h.hDay)} $month';
  }

  String _banglaDate(DateTime date, String lang) {
    const months = [
      'বৈশাখ', 'জ্যৈষ্ঠ', 'আষাঢ়', 'শ্রাবণ', 'ভাদ্র', 'আশ্বিন', 'কার্তিক',
      'অগ্রহায়ণ', 'পৌষ', 'মাঘ', 'ফাল্গুন', 'চৈত্র',
    ];
    DateTime startFor(int year) => DateTime(year, 4, 14);
    final thisYearStart = startFor(date.year);
    final start = date.isBefore(thisYearStart)
        ? startFor(date.year - 1)
        : thisYearStart;
    final banglaYear = date.isBefore(thisYearStart)
        ? date.year - 594
        : date.year - 593;
    final leap = (banglaYear + 593) % 4 == 0;
    final lengths = [31, 31, 31, 31, 31, 30, 30, 30, 30, 30, leap ? 30 : 29, 30];
    var remaining = date.difference(start).inDays;
    var monthIndex = 0;
    while (monthIndex < 11 && remaining >= lengths[monthIndex]) {
      remaining -= lengths[monthIndex];
      monthIndex++;
    }
    final day = remaining + 1;
    final dayText = lang == 'en' ? '$day' : _bnDigits(day);
    return '$dayText ${months[monthIndex]}';
  }

  String _bnDigits(int value) => value
      .toString()
      .split('')
      .map((d) => '০১২৩৪৫৬৭৮৯'[int.parse(d)])
      .join();

  PrayerTimes? _timesFor(PrayerController controller) {
    final position = _manualPosition ?? controller.position;
    if (position == null) return null;
    return _engine.getPrayerTimes(position: position, date: _now);
  }

  Prayer? _current(PrayerTimes? times) {
    if (times == null) return null;
    final detected = times.currentPrayer();
    if (detected != null) return detected;
    if (_now.isAfter(times.isha)) {
      return Prayer.isha;
    }
    return null;
  }

  Prayer? _next(PrayerTimes? times) {
    if (times == null) return null;
    return times.nextPrayer();
  }

  PrayerTimes? _tomorrowTimes(PrayerController controller) {
    final position = _manualPosition ?? controller.position;
    if (position == null) return null;
    return _engine.getPrayerTimes(
      position: position,
      date: _now.add(const Duration(days: 1)),
    );
  }

  DateTime? _endOfCurrent(PrayerTimes? times, PrayerController controller) {
    final current = _current(times);
    if (current == null) return _timeFor(times, _next(times));
    if (current == Prayer.isha) {
      return _tomorrowTimes(controller)?.fajr;
    }
    return _timeFor(times, _next(times));
  }

  DateTime? _timeFor(PrayerTimes? times, Prayer? prayer) {
    if (times == null || prayer == null) return null;
    return times.timeForPrayer(prayer);
  }

  double _progress(PrayerTimes? times, PrayerController controller) {
    final current = _current(times);
    final start = _timeFor(times, current);
    final end = _endOfCurrent(times, controller);
    if (start == null || end == null || !end.isAfter(start)) return 0;
    return (_now.difference(start).inMilliseconds / end.difference(start).inMilliseconds).clamp(0.0, 1.0);
  }

  String _countdown(DateTime? end, PrayerController controller) {
    if (end == null) return controller.timeRemainingForNextPrayer;
    final d = end.difference(_now);
    if (d.isNegative) return '00:00:00';
    final total = d.inSeconds;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _prayerName(Prayer prayer, String lang) {
    const bn = {
      Prayer.fajr: 'ফজর',
      Prayer.dhuhr: 'যোহর',
      Prayer.asr: 'আসর',
      Prayer.maghrib: 'মাগরিব',
      Prayer.isha: 'ইশা',
    };
    const en = {
      Prayer.fajr: 'Fajr',
      Prayer.dhuhr: 'Dhuhr',
      Prayer.asr: 'Asr',
      Prayer.maghrib: 'Maghrib',
      Prayer.isha: 'Isha',
    };
    return (lang == 'en' ? en : bn)[prayer] ?? '';
  }

  String _formatTime(DateTime? value) {
    if (value == null) return '--:--';
    final h = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$h:${value.minute.toString().padLeft(2, '0')} $suffix';
  }

  Future<void> _showLocationPicker() async {
    final lang = context.read<SettingsProvider>().languageCode;
    final theme = Theme.of(context);
    final controller = context.read<PrayerController>();
    final field = TextEditingController();
    var searching = false;
    String? error;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: theme.cardColor,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> search() async {
            final query = field.text.trim();
            if (query.isEmpty) return;
            setSheetState(() {
              searching = true;
              error = null;
            });
            try {
              final result = await locationFromAddress(query);
              if (result.isEmpty) throw Exception();
              final item = result.first;
              final position = Position(
                latitude: item.latitude,
                longitude: item.longitude,
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
                searching = false;
                error = _tr('লোকেশন পাওয়া যায়নি', 'Location not found', lang);
              });
            }
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 4, 18, 18 + MediaQuery.viewInsetsOf(context).bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_tr('লোকেশন নির্বাচন করুন', 'Select location', lang), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(_tr('শহর বা এলাকার নাম লিখুন', 'Enter a city or area', lang), style: theme.textTheme.bodySmall?.copyWith(color: context.secondaryTextColor)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: field,
                    onSubmitted: (_) => search(),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: lang == 'en' ? 'Dhaka' : 'ঢাকা',
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 7),
                    Text(error!, style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: searching ? null : search,
                      child: Text(searching ? _tr('অনুসন্ধান করা হচ্ছে…', 'Searching…', lang) : _tr('এই লোকেশন ব্যবহার করুন', 'Use this location', lang)),
                    ),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.of(sheetContext).pop();
                        await controller.refreshLocation();
                        if (mounted) setState(() {
                          _manualPosition = null;
                          _manualLocationName = null;
                        });
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
      ),
    );
    field.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final lang = settings.languageCode;
    final theme = Theme.of(context);
    final times = _timesFor(controller);
    final current = _current(times);
    final next = _next(times);
    final end = _endOfCurrent(times, controller);
    final nextOrCurrent = current ?? next;
    final currentName = nextOrCurrent == null ? _tr('ইশা', 'Isha', lang) : _prayerName(nextOrCurrent, lang);
    final location = (_manualLocationName ?? controller.currentLocationName).trim();
    final sunrise = _timeFor(times, Prayer.sunrise);
    final sunset = _timeFor(times, Prayer.sunset);
    final countdown = _countdown(end, controller);
    final progress = _progress(times, controller);
    final hasLastRead = _lastRead != null && '${_lastRead!['surahName'] ?? ''}'.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: theme.colorScheme.primary,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
            children: [
              _PrayerCard(
                lang: lang,
                hijri: _hijri(lang),
                gregorian: DateService.englishDate(),
                banglaDate: _banglaDate(_now, lang),
                primary: AppColors.seaBlue,
                currentName: currentName,
                countdown: countdown,
                progress: progress,
                sunrise: _formatTime(sunrise),
                sunset: _formatTime(sunset),
                location: location.isEmpty ? 'Dhaka' : location.split(',').first.trim(),
                onLocationTap: _showLocationPicker,
              ),
              const SizedBox(height: 18),
              _PrayerRows(times: times, current: current, lang: lang),
              const SizedBox(height: 18),
              _Title(text: _tr('প্রয়োজনীয়', 'Essentials', lang)),
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
                _Title(text: _tr('কুরআন চালিয়ে যান', 'Continue Quran', lang)),
                const SizedBox(height: 9),
                ContinueReadingCard(
                  surahName: '${_lastRead!['surahName'] ?? ''}',
                  paraNo: _lastRead!['paraNo'] is int ? _lastRead!['paraNo'] as int : int.tryParse('${_lastRead!['paraNo']}') ?? 1,
                  pageNo: _lastRead!['pageNo'] is int ? _lastRead!['pageNo'] as int : int.tryParse('${_lastRead!['pageNo']}') ?? 1,
                  progress: ((_lastRead!['progress'] is num ? (_lastRead!['progress'] as num).toDouble() : 0.0).clamp(0.0, 1.0)).toDouble(),
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

class _PrayerCard extends StatefulWidget {
  const _PrayerCard({required this.lang, required this.hijri, required this.gregorian, required this.banglaDate, required this.primary, required this.currentName, required this.countdown, required this.progress, required this.sunrise, required this.sunset, required this.location, required this.onLocationTap});
  final String lang, hijri, gregorian, banglaDate, currentName, countdown, sunrise, sunset, location;
  final Color primary;
  final double progress;
  final VoidCallback onLocationTap;

  @override
  State<_PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<_PrayerCard> with SingleTickerProviderStateMixin {
  late final AnimationController _slide;
  bool _showTahajjud = false;
  Timer? _textTimer;

  @override
  void initState() {
    super.initState();
    _slide = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _textTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() => _showTahajjud = !_showTahajjud);
      _slide.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _slide.dispose();
    super.dispose();
  }

  String _tr(String bn, String en) => widget.lang == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    final card = AppColors.seaBlueDark;
    const text = Colors.white;
    final muted = Colors.white70;
    final title = _showTahajjud ? _tr('তাহাজ্জুদ', 'Tahajjud') : widget.currentName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 15),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [BoxShadow(color: card.withValues(alpha: .22), blurRadius: 24, offset: const Offset(0, 10))],
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
                    Icon(Icons.wb_sunny_rounded, color: widget.primary, size: 21),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.hijri, style: const TextStyle(color: text, fontSize: 15.5, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text('${widget.gregorian}, ${widget.banglaDate}', style: const TextStyle(color: muted, fontSize: 11.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              CustomPaint(size: const Size(30, 30), painter: const _CrescentPainter(color: text)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 116,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ArcPainter(track: Colors.white12, active: widget.primary, progress: widget.progress),
                  ),
                ),
                Positioned(
                  right: 14,
                  top: 2,
                  child: CustomPaint(size: const Size(24, 24), painter: const _CrescentPainter(color: text)),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, .35), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Text(title, key: ValueKey(title), style: const TextStyle(color: text, fontSize: 23, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 5),
          Text(_tr('ওয়াক্ত শেষ হবে', 'Waqt ends in'), style: const TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(widget.countdown, style: const TextStyle(color: text, fontSize: 29, fontWeight: FontWeight.w800, letterSpacing: .15)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LocationPill(location: widget.location, onTap: widget.onLocationTap),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SunPill(sunrise: widget.sunrise, sunset: widget.sunset),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationPill extends StatelessWidget {
  const _LocationPill({required this.location, required this.onTap});
  final String location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white, size: 15),
              const SizedBox(width: 4),
              Expanded(child: Text(location, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700))),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SunPill extends StatelessWidget {
  const _SunPill({required this.sunrise, required this.sunset});
  final String sunrise, sunset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .10), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(children: [const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 15), const SizedBox(width: 4), Text(sunrise, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700))]),
          Container(width: 1, height: 14, color: Colors.white24),
          Row(children: [const Icon(Icons.nights_stay_outlined, color: Colors.white, size: 15), const SizedBox(width: 4), Text(sunset, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700))]),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.track, required this.active, required this.progress});
  final Color track, active;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .96);
    final radius = math.min(size.width * .42, size.height * .99);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()..color = track..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round;
    final activePaint = Paint()..color = active..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round;
    const start = math.pi * 1.15;
    const sweep = math.pi * .70;
    canvas.drawArc(rect, start, sweep, false, trackPaint);
    canvas.drawArc(rect, start, sweep * progress.clamp(0, 1), false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.active != active || oldDelegate.track != track;
}

class _CrescentPainter extends CustomPainter {
  const _CrescentPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final outer = Path()..addOval(Rect.fromCircle(center: Offset(size.width * .5, size.height * .5), radius: size.width * .34));
    final cut = Path()..addOval(Rect.fromCircle(center: Offset(size.width * .66, size.height * .39), radius: size.width * .30));
    canvas.drawPath(Path.combine(PathOperation.difference, outer, cut), paint);
  }

  @override
  bool shouldRepaint(covariant _CrescentPainter oldDelegate) => oldDelegate.color != color;
}

class _PrayerRows extends StatelessWidget {
  const _PrayerRows({required this.times, required this.current, required this.lang});
  final PrayerTimes? times;
  final Prayer? current;
  final String lang;

  String _name(Prayer p) {
    const bn = {Prayer.fajr: 'ফজর', Prayer.dhuhr: 'যোহর', Prayer.asr: 'আসর', Prayer.maghrib: 'মাগরিব', Prayer.isha: 'ইশা'};
    const en = {Prayer.fajr: 'Fajr', Prayer.dhuhr: 'Dhuhr', Prayer.asr: 'Asr', Prayer.maghrib: 'Maghrib', Prayer.isha: 'Isha'};
    return (lang == 'en' ? en : bn)[p] ?? '';
  }

  String _time(DateTime? value) {
    if (value == null) return '--:--';
    final h = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$h:${value.minute.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    const list = [Prayer.fajr, Prayer.dhuhr, Prayer.asr, Prayer.maghrib, Prayer.isha];
    return Container(
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          for (var i = 0; i < list.length; i++) ...[
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 1),
              leading: Container(width: 8, height: 8, decoration: BoxDecoration(color: list[i] == current ? primary : theme.dividerColor, shape: BoxShape.circle)),
              title: Text(_name(list[i]), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: list[i] == current ? FontWeight.w800 : FontWeight.w600, color: list[i] == current ? primary : null)),
              trailing: Text(_time(times?.timeForPrayer(list[i])), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: list[i] == current ? FontWeight.w800 : FontWeight.w600, color: list[i] == current ? primary : null)),
            ),
            if (i != list.length - 1) Divider(height: 1, indent: 15, endIndent: 15, color: theme.dividerColor.withValues(alpha: .45)),
          ],
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w800));
}

class _Essentials extends StatelessWidget {
  const _Essentials({required this.lang, required this.onQibla, required this.onDua, required this.onTasbih, required this.onNames, required this.onCalendar, required this.onRuqyah});
  final String lang;
  final VoidCallback onQibla, onDua, onTasbih, onNames, onCalendar, onRuqyah;
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
