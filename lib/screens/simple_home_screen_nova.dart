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

class SimpleHomeScreenNova extends StatefulWidget {
  const SimpleHomeScreenNova({super.key, this.onNavigateTab});
  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreenNova> createState() => _SimpleHomeScreenNovaState();
}

class _SimpleHomeScreenNovaState extends State<SimpleHomeScreenNova> {
  Timer? _ticker;
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
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
      'jumuah': 'জুমুআ',
      'asr': 'আসর',
      'maghrib': 'মাগরিব',
      'isha': 'ইশা',
    };
    const en = <String, String>{
      'fajr': 'Fajr',
      'dhuhr': 'Dhuhr',
      'jumuah': 'Jumuah',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
    };
    return (lang == 'en' ? en : bn)[key] ?? value;
  }

  String _date() => DateService.englishDate();

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
                  _tr('লোকেশন', 'Location', lang),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.currentLocationName.isEmpty
                      ? _tr('লোকেশন পাওয়া যায়নি', 'Location unavailable', lang)
                      : controller.currentLocationName,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.of(sheetContext).pop();
                      await controller.refreshLocation();
                    },
                    icon: const Icon(Icons.my_location_rounded),
                    label: Text(
                      _tr(
                        'বর্তমান লোকেশন আপডেট করুন',
                        'Update current location',
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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final lang = settings.languageCode;
    final theme = Theme.of(context);
    final location = controller.currentLocationName.trim();
    final current = controller.currentPrayer.trim();
    final next = controller.nextPrayerName.trim();
    final currentLabel = _prayerLabel(current, lang);
    final nextLabel = _prayerLabel(next, lang);
    final activeLabel = currentLabel.isEmpty || current == 'ওয়াক্ত নেই'
        ? nextLabel
        : currentLabel;
    final progress = controller.prayerProgress.clamp(0.0, 1.0);
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _NovaHeader(
              location: location.isEmpty ? _tr('ঢাকা', 'Dhaka', lang) : location,
              date: _date(),
            ),
            const SizedBox(height: 14),
            _PrayerStage(
              language: lang,
              activePrayer: activeLabel,
              nextPrayer: nextLabel,
              countdown: controller.timeRemainingForNextPrayer,
              progress: progress,
              status: controller.prayerStatus,
            ),
            const SizedBox(height: 12),
            _ContextRail(
              language: lang,
              location: location.isEmpty ? _tr('ঢাকা', 'Dhaka', lang) : location,
              sunrise: controller.sunriseTime,
              sunset: controller.sunsetTime,
              onLocationTap: () => _showLocationSheet(context),
            ),
            const SizedBox(height: 18),
            _PrayerRail(
              language: lang,
              controller: controller,
              progress: progress,
            ),
            const SizedBox(height: 18),
            _UtilityDock(
              language: lang,
              onQuran: () => _open(const OnudhabonQuranScreen()),
              onQibla: () => _open(const QiblaScreen()),
              onDua: () => _open(const DuaScreen()),
              onTasbih: () => _open(const TasbihScreen()),
            ),
            if (hasLastRead) ...[
              const SizedBox(height: 20),
              _NovaSectionLabel(_tr('আপনার কুরআন', 'Your Quran', lang)),
              const SizedBox(height: 8),
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
}

class _NovaHeader extends StatelessWidget {
  const _NovaHeader({required this.location, required this.date});
  final String location;
  final String date;

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
                      location.split(',').first.trim(),
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
            shape: BoxShape.circle,
            color: primary.withValues(alpha: .10),
          ),
          child: Icon(Icons.auto_awesome_rounded, size: 18, color: primary),
        ),
      ],
    );
  }
}

class _PrayerStage extends StatelessWidget {
  const _PrayerStage({
    required this.language,
    required this.activePrayer,
    required this.nextPrayer,
    required this.countdown,
    required this.progress,
    required this.status,
  });

  final String language;
  final String activePrayer;
  final String nextPrayer;
  final String countdown;
  final double progress;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final dark = theme.brightness == Brightness.dark;
    return Container(
      height: 300,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? AppColors.seaBlueDark : AppColors.seaBlue,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: .16),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _NovaScenePainter(
                isNight: dark,
                accent: primary,
              ),
            ),
          ),
          Positioned(
            top: 18,
            left: 18,
            right: 18,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Text(
                      language == 'en' ? 'PRAYER NOW' : 'সালাত চলছে',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .65,
                      ),
                    ),
                  ),
                ),
                const _MoonMark(),
              ],
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    activePrayer.isEmpty
                        ? (language == 'en' ? 'Next Prayer' : 'পরবর্তী সালাত')
                        : activePrayer,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    language == 'en' ? 'time remaining' : 'সময় বাকি',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    countdown,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 9),
                  SizedBox(
                    height: 68,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _MoonArcPainter(
                        progress: progress,
                        accent: Colors.white,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _StageMeta(
                          title: language == 'en' ? 'Current' : 'বর্তমান',
                          value: activePrayer,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _StageMeta(
                            title: language == 'en' ? 'Next' : 'পরবর্তী',
                            value: nextPrayer,
                            alignEnd: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (status.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      status,
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
          ),
        ],
      ),
    );
  }
}

class _StageMeta extends StatelessWidget {
  const _StageMeta({required this.title, required this.value, this.alignEnd = false});
  final String title;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white60, fontSize: 9.5),
          ),
          const SizedBox(height: 1),
          Text(
            value.isEmpty ? '—' : value,
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

class _ContextRail extends StatelessWidget {
  const _ContextRail({
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
          flex: 5,
          child: _ContextPill(
            icon: Icons.location_on_outlined,
            text: location.split(',').first.trim(),
            trailing: Icons.expand_more_rounded,
            onTap: onLocationTap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 7,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SunValue(
                  icon: Icons.wb_sunny_outlined,
                  label: language == 'en' ? 'Sunrise' : 'সূর্যোদয়',
                  value: sunrise,
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: theme.dividerColor.withValues(alpha: .45),
                ),
                _SunValue(
                  icon: Icons.nights_stay_outlined,
                  label: language == 'en' ? 'Sunset' : 'সূর্যাস্ত',
                  value: sunset,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContextPill extends StatelessWidget {
  const _ContextPill({
    required this.icon,
    required this.text,
    required this.trailing,
    required this.onTap,
  });
  final IconData icon;
  final String text;
  final IconData trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Material(
      color: primary.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: Row(
            children: [
              Icon(icon, size: 16, color: primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  text,
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

class _SunValue extends StatelessWidget {
  const _SunValue({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 15, color: theme.colorScheme.primary),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 8.5,
                color: context.secondaryTextColor,
              ),
            ),
            Text(
              value,
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

class _PrayerRail extends StatelessWidget {
  const _PrayerRail({
    required this.language,
    required this.controller,
    required this.progress,
  });
  final String language;
  final PrayerController controller;
  final double progress;

  static const _items = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  String _label(String name) {
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
    var active = _items.indexWhere(
      (item) => current.contains(item.toLowerCase()),
    );
    if (active < 0) {
      active = _items.indexWhere(
        (item) => controller.nextPrayerName.toLowerCase().contains(item.toLowerCase()),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 15, 12, 11),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            width: double.infinity,
            child: CustomPaint(
              painter: _PrayerRailPainter(
                activeIndex: active,
                progress: progress,
                primary: primary,
              ),
            ),
          ),
          Row(
            children: [
              for (int i = 0; i < _items.length; i++)
                Expanded(
                  child: Text(
                    _label(_items[i]),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight:
                          i == active ? FontWeight.w800 : FontWeight.w600,
                      color: i == active
                          ? primary
                          : context.secondaryTextColor,
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

class _PrayerRailPainter extends CustomPainter {
  const _PrayerRailPainter({
    required this.activeIndex,
    required this.progress,
    required this.primary,
  });
  final int activeIndex;
  final double progress;
  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    final points = List<Offset>.generate(5, (i) {
      final x = size.width * (i / 4);
      final y = size.height * (0.62 - 0.22 * math.sin(i / 4 * math.pi));
      return Offset(x, y);
    });
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final control = Offset(
        (a.dx + b.dx) / 2,
        math.min(a.dy, b.dy) - 2,
      );
      path.quadraticBezierTo(control.dx, control.dy, b.dx, b.dy);
    }
    final track = Paint()
      ..color = primary.withValues(alpha: .12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, track);
    final metrics = path.computeMetrics().first;
    final index = activeIndex.clamp(0, 4);
    final amount = ((index + progress.clamp(0.0, 1.0)) / 4).clamp(0.0, 1.0);
    canvas.drawPath(metrics.extractPath(0, metrics.length * amount), active);
    for (int i = 0; i < points.length; i++) {
      final selected = i == activeIndex;
      canvas.drawCircle(
        points[i],
        selected ? 6 : 4,
        Paint()..color = selected ? primary : primary.withValues(alpha: .18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PrayerRailPainter oldDelegate) =>
      oldDelegate.activeIndex != activeIndex ||
      oldDelegate.progress != progress ||
      oldDelegate.primary != primary;
}

class _UtilityDock extends StatelessWidget {
  const _UtilityDock({
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
    final items = <({IconData icon, String label, VoidCallback onTap})>[
      (icon: Icons.menu_book_rounded, label: _t('কুরআন', 'Quran'), onTap: onQuran),
      (icon: Icons.explore_outlined, label: _t('কিবলা', 'Qibla'), onTap: onQibla),
      (icon: Icons.auto_awesome_outlined, label: _t('দু‘আ', 'Dua'), onTap: onDua),
      (icon: Icons.touch_app_outlined, label: _t('তাসবিহ', 'Tasbih'), onTap: onTasbih),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: InkWell(
                onTap: items[i].onTap,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    children: [
                      Icon(items[i].icon, size: 21, color: primary),
                      const SizedBox(height: 4),
                      Text(
                        items[i].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NovaSectionLabel extends StatelessWidget {
  const _NovaSectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _MoonMark extends StatelessWidget {
  const _MoonMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: _MoonPainter(color: Colors.white.withValues(alpha: .88)),
      ),
    );
  }
}

class _MoonPainter extends CustomPainter {
  const _MoonPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final outer = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * .48, size.height * .5),
          radius: size.width * .29,
        ),
      );
    final cut = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * .67, size.height * .39),
          radius: size.width * .25,
        ),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, cut),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MoonPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _MoonArcPainter extends CustomPainter {
  const _MoonArcPainter({required this.progress, required this.accent});
  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .94);
    final radius = size.width * .28;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..color = accent.withValues(alpha: .16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const start = math.pi * 1.10;
    const sweep = math.pi * .80;
    canvas.drawArc(rect, start, sweep, false, track);
    canvas.drawArc(
      rect,
      start,
      sweep * progress.clamp(0.0, 1.0),
      false,
      active,
    );
  }

  @override
  bool shouldRepaint(covariant _MoonArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accent != accent;
}

class _NovaScenePainter extends CustomPainter {
  const _NovaScenePainter({required this.isNight, required this.accent});
  final bool isNight;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()..color = isNight ? AppColors.seaBlueDark : AppColors.seaBlue,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .63, size.width, size.height * .37),
      Paint()..color = Colors.white.withValues(alpha: .055),
    );
    final distant = Paint()..color = accent.withValues(alpha: .09);
    final path = Path()
      ..moveTo(0, size.height * .78)
      ..quadraticBezierTo(
        size.width * .28,
        size.height * .67,
        size.width * .52,
        size.height * .77,
      )
      ..quadraticBezierTo(
        size.width * .78,
        size.height * .87,
        size.width,
        size.height * .70,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, distant);
    canvas.drawCircle(
      Offset(size.width * .18, size.height * .22),
      size.width * .24,
      Paint()..color = accent.withValues(alpha: isNight ? .12 : .16),
    );
    if (isNight) {
      final starPaint = Paint()..color = Colors.white.withValues(alpha: .56);
      const points = <Offset>[
        Offset(.14, .18),
        Offset(.31, .12),
        Offset(.47, .22),
        Offset(.66, .14),
        Offset(.82, .22),
      ];
      for (final p in points) {
        canvas.drawCircle(
          Offset(size.width * p.dx, size.height * p.dy),
          1.2,
          starPaint,
        );
      }
    } else {
      final cloudPaint = Paint()..color = Colors.white.withValues(alpha: .13);
      _cloud(canvas, size, Offset(size.width * .23, size.height * .20), .75, cloudPaint);
      _cloud(canvas, size, Offset(size.width * .72, size.height * .29), .52, cloudPaint);
    }
  }

  void _cloud(Canvas canvas, Size size, Offset center, double scale, Paint paint) {
    canvas.drawCircle(center + Offset(-19 * scale, 3 * scale), 16 * scale, paint);
    canvas.drawCircle(center + Offset(0, -4 * scale), 23 * scale, paint);
    canvas.drawCircle(center + Offset(21 * scale, 4 * scale), 15 * scale, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + Offset(1 * scale, 7 * scale),
          width: 62 * scale,
          height: 21 * scale,
        ),
        Radius.circular(11 * scale),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _NovaScenePainter oldDelegate) =>
      oldDelegate.isNight != isNight || oldDelegate.accent != accent;
}
