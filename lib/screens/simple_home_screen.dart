import 'dart:async';

import 'package:flutter/material.dart';
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
import 'tools/tasbih_screen.dart';

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _loadLastRead();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLastRead() async {
    try {
      final value = await LastReadService.getLastRead();
      if (!mounted) return;
      setState(() => _lastRead = value);
    } catch (_) {
      if (!mounted) return;
      setState(() => _lastRead = null);
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

  String _label(String languageCode, String bn, String en) =>
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

  String _clock(bool showSeconds) {
    final hour = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final minute = _now.minute.toString().padLeft(2, '0');
    final second = _now.second.toString().padLeft(2, '0');
    final base = '$hour:$minute';
    return showSeconds
        ? '$base:$second ${_now.hour >= 12 ? 'PM' : 'AM'}'
        : '$base ${_now.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _staticTime(String value) {
    final match = RegExp(r'^(\d{1,2}:\d{2})').firstMatch(value.trim());
    return match?.group(1) ?? value;
  }

  String _countdownTime(String value, bool showSeconds) =>
      showSeconds ? value : _staticTime(value);

  String _dateText(String languageCode) {
    final h = HijriCalendar.now();
    const bnMonths = [
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
    const enMonths = [
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

    String digits(int value) {
      const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
      return value.toString().split('').map((d) => bn[int.parse(d)]).join();
    }

    final month =
        languageCode == 'en' ? enMonths[h.hMonth - 1] : bnMonths[h.hMonth - 1];
    final day = languageCode == 'en' ? '${h.hDay}' : digits(h.hDay);
    final year = languageCode == 'en' ? '${h.hYear}' : digits(h.hYear);
    return '$day $month $year';
  }

  List<Map<String, dynamic>> _fivePrayers(PrayerController controller) {
    const keys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final result = <Map<String, dynamic>>[];
    for (final key in keys) {
      for (final prayer in controller.prayers) {
        final name = (prayer['name'] ?? '').toString().toLowerCase();
        final nameBn = (prayer['nameBn'] ?? '').toString().toLowerCase();
        final match = name.contains(key.toLowerCase()) ||
            (key == 'Fajr' && nameBn.contains('ফজর')) ||
            (key == 'Dhuhr' &&
                (nameBn.contains('যোহর') || nameBn.contains('জুমু'))) ||
            (key == 'Asr' && nameBn.contains('আসর')) ||
            (key == 'Maghrib' && nameBn.contains('মাগরিব')) ||
            (key == 'Isha' && nameBn.contains('ইশা'));
        if (match) {
          result.add(prayer);
          break;
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final languageCode = settings.languageCode;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final prayers = _fivePrayers(controller);
    final lastRead = _lastRead;
    final hasLastRead = lastRead != null &&
        (lastRead['surahName']?.toString() ?? '').trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          color: primary,
          onRefresh: _refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
            children: [
              _CalmHeader(
                greeting: _greeting(languageCode),
                date: _dateText(languageCode),
                location: controller.currentLocationName,
                languageCode: languageCode,
              ),
              const SizedBox(height: 12),
              _ScenicPrayerHero(
                now: _now,
                clock: _clock(settings.showSeconds),
                currentPrayer: controller.currentPrayer,
                nextPrayer: controller.nextPrayerName,
                nextPrayerTime: _staticTime(controller.nextPrayerTime),
                remaining: _countdownTime(
                  controller.timeRemainingForNextPrayer,
                  settings.showSeconds,
                ),
                progress: controller.prayerProgress,
                sunrise: _staticTime(controller.sunriseTime),
                sunset: _staticTime(controller.sunsetTime),
                languageCode: languageCode,
              ),
              const SizedBox(height: 12),
              _PrayerStrip(prayers: prayers, languageCode: languageCode),
              const SizedBox(height: 18),
              _SectionTitle(
                  title: _label(languageCode, 'প্রয়োজনীয়', 'Essentials')),
              const SizedBox(height: 9),
              _EssentialGrid(
                languageCode: languageCode,
                onQuran: () => widget.onNavigateTab?.call(2),
                onHadith: () => widget.onNavigateTab?.call(3),
                onQibla: () => _open(const QiblaScreen()),
                onDua: () => _open(const DuaScreen()),
                onTasbih: () => _open(const TasbihScreen()),
                onNames: () => _open(const AsmaUlHusnaScreen()),
              ),
              if (hasLastRead) ...[
                const SizedBox(height: 18),
                _SectionTitle(
                  title: _label(
                      languageCode, 'কুরআন চালিয়ে যান', 'Continue Quran'),
                ),
                const SizedBox(height: 9),
                ContinueReadingCard(
                  surahName: lastRead['surahName']?.toString() ?? '',
                  paraNo: lastRead['paraNo'] is int
                      ? lastRead['paraNo'] as int
                      : int.tryParse('${lastRead['paraNo']}') ?? 1,
                  pageNo: lastRead['pageNo'] is int
                      ? lastRead['pageNo'] as int
                      : int.tryParse('${lastRead['pageNo']}') ?? 1,
                  progress: ((lastRead['progress'] is num
                              ? (lastRead['progress'] as num).toDouble()
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
              _DateFooter(
                englishDate: DateService.englishDate(),
                banglaDate: DateService.banglaCalendarDate(),
                sunrise: _staticTime(controller.sunriseTime),
                sunset: _staticTime(controller.sunsetTime),
                languageCode: languageCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalmHeader extends StatelessWidget {
  const _CalmHeader({
    required this.greeting,
    required this.date,
    required this.location,
    required this.languageCode,
  });

  final String greeting;
  final String date;
  final String location;
  final String languageCode;

  String _label(String bn, String en) => languageCode == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = context.secondaryTextColor;
    final city = location.trim().isEmpty
        ? _label('লোকেশন নির্ধারণ হচ্ছে…', 'Locating your area…')
        : location.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 21,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(Icons.location_on_rounded, size: 16, color: secondary),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                city,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13.5,
                  height: 1.2,
                  color: secondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              date,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 13,
                height: 1.2,
                color: secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScenicPrayerHero extends StatelessWidget {
  const _ScenicPrayerHero({
    required this.now,
    required this.clock,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.remaining,
    required this.progress,
    required this.sunrise,
    required this.sunset,
    required this.languageCode,
  });

  final DateTime now;
  final String clock;
  final String currentPrayer;
  final String nextPrayer;
  final String nextPrayerTime;
  final String remaining;
  final double progress;
  final String sunrise;
  final String sunset;
  final String languageCode;

  String _label(String bn, String en) => languageCode == 'en' ? en : bn;

  _DayPhase get phase {
    if (now.hour < 5) return _DayPhase.night;
    if (now.hour < 8) return _DayPhase.dawn;
    if (now.hour < 16) return _DayPhase.day;
    if (now.hour < 19) return _DayPhase.sunset;
    return _DayPhase.night;
  }

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();
    final palette = _ScenePalette.forPhase(phase);

    return Container(
      height: 318,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _SkylinePainter(phase: phase, palette: palette),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 16, 19, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _label('পরের সালাত', 'NEXT PRAYER'),
                      style: TextStyle(
                        color: palette.lightText.withValues(alpha: .88),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    _PhasePill(
                      text: phase.label(languageCode),
                      color: palette.lightText,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  nextPrayer.isEmpty ? '--' : nextPrayer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.lightText,
                    fontSize: 31,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  nextPrayerTime.isEmpty ? '--:--' : nextPrayerTime,
                  style: TextStyle(
                    color: palette.lightText.withValues(alpha: .94),
                    fontSize: 14.5,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        remaining.isEmpty ? '--:--:--' : remaining,
                        style: TextStyle(
                          color: palette.lightText,
                          fontSize: 38,
                          height: .95,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -1.2,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _label('এখন', 'NOW'),
                          style: TextStyle(
                            color: palette.lightText.withValues(alpha: .68),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          clock,
                          style: TextStyle(
                            color: palette.lightText,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: safeProgress,
                    backgroundColor: palette.lightText.withValues(alpha: .16),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: .90),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _HeroChip(
                      icon: Icons.mosque_rounded,
                      text: currentPrayer.isEmpty ? '--' : currentPrayer,
                      color: palette.lightText,
                    ),
                    const Spacer(),
                    _HeroTimeChip(
                      label: _label('সূর্যোদয়', 'Sunrise'),
                      value: sunrise,
                      color: palette.lightText,
                    ),
                    const SizedBox(width: 10),
                    _HeroTimeChip(
                      label: _label('সূর্যাস্ত', 'Sunset'),
                      value: sunset,
                      color: palette.lightText,
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

class _PrayerStrip extends StatelessWidget {
  const _PrayerStrip({required this.prayers, required this.languageCode});

  final List<Map<String, dynamic>> prayers;
  final String languageCode;

  String _name(Map<String, dynamic> prayer) {
    if (languageCode != 'en') return prayer['nameBn']?.toString() ?? '--';
    return prayer['name']?.toString() ?? prayer['nameBn']?.toString() ?? '--';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;

    return Row(
      children: List.generate(5, (index) {
        final prayer =
            index < prayers.length ? prayers[index] : const <String, dynamic>{};
        final active = prayer['isCurrent'] == true;
        final name = _name(prayer);
        final rawTime = prayer['start']?.toString() ?? '--:--';
        final time =
            RegExp(r'^(\d{1,2}:\d{2})').firstMatch(rawTime.trim())?.group(1) ??
                rawTime;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: index == 0 ? 0 : 4),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
            decoration: BoxDecoration(
              color:
                  active ? primary.withValues(alpha: .10) : context.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active
                    ? primary.withValues(alpha: .22)
                    : primary.withValues(alpha: .06),
              ),
            ),
            child: Column(
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? primary : secondary,
                    fontSize: 11.5,
                    height: 1.1,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  maxLines: 1,
                  style: TextStyle(
                    color: active ? primary : context.primaryTextColor,
                    fontSize: 11.5,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 17,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _EssentialGrid extends StatelessWidget {
  const _EssentialGrid({
    required this.languageCode,
    required this.onQuran,
    required this.onHadith,
    required this.onQibla,
    required this.onDua,
    required this.onTasbih,
    required this.onNames,
  });

  final String languageCode;
  final VoidCallback onQuran;
  final VoidCallback onHadith;
  final VoidCallback onQibla;
  final VoidCallback onDua;
  final VoidCallback onTasbih;
  final VoidCallback onNames;

  String _label(String bn, String en) => languageCode == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    final items = [
      _EssentialItem(
          Icons.menu_book_rounded, _label('কুরআন', 'Quran'), onQuran),
      _EssentialItem(Icons.explore_rounded, _label('কিবলা', 'Qibla'), onQibla),
      _EssentialItem(Icons.favorite_rounded, _label('দোয়া', 'Dua'), onDua),
      _EssentialItem(
          Icons.touch_app_rounded, _label('তাসবিহ', 'Tasbih'), onTasbih),
      _EssentialItem(
          Icons.auto_awesome_rounded, _label('৯৯ নাম', '99 Names'), onNames),
      _EssentialItem(
          Icons.auto_stories_rounded, _label('হাদিস', 'Hadith'), onHadith),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.30,
      ),
      itemBuilder: (context, index) => _EssentialTile(item: items[index]),
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

  Color _itemColor(BuildContext context) {
    const colors = [
      AppColors.seaBlueDark,
      AppColors.seaBlue,
      Color(0xFF0F8FB6),
      Color(0xFF2C7FB3),
      Color(0xFF4A90B8),
      AppColors.softAqua,
    ];
    return colors[item.icon.codePoint.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _itemColor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: color.withValues(alpha: .075),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: .14)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .13),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.primaryTextColor,
                  fontSize: 12.5,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateFooter extends StatelessWidget {
  const _DateFooter({
    required this.englishDate,
    required this.banglaDate,
    required this.sunrise,
    required this.sunset,
    required this.languageCode,
  });

  final String englishDate;
  final String banglaDate;
  final String sunrise;
  final String sunset;
  final String languageCode;

  String _label(String bn, String en) => languageCode == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    final secondary = context.secondaryTextColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .06),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_label('তারিখ', 'Date')}: ${languageCode == 'bn' ? banglaDate : englishDate}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: secondary, fontSize: 11.5),
            ),
          ),
          Text(
            '${_label('সূর্যোদয়', 'Sunrise')} $sunrise',
            style: TextStyle(
              color: secondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_label('সূর্যাস্ত', 'Sunset')} $sunset',
            style: TextStyle(
              color: secondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhasePill extends StatelessWidget {
  const _PhasePill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: color, fontSize: 10.5, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip(
      {required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: color, fontSize: 11.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _HeroTimeChip extends StatelessWidget {
  const _HeroTimeChip(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
              color: color.withValues(alpha: .60),
              fontSize: 10,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
              color: color.withValues(alpha: .92),
              fontSize: 11.5,
              fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

enum _DayPhase { dawn, day, sunset, night }

extension on _DayPhase {
  String label(String languageCode) {
    if (languageCode == 'en') {
      switch (this) {
        case _DayPhase.dawn:
          return 'DAWN';
        case _DayPhase.day:
          return 'DAY';
        case _DayPhase.sunset:
          return 'SUNSET';
        case _DayPhase.night:
          return 'NIGHT';
      }
    }
    switch (this) {
      case _DayPhase.dawn:
        return 'ভোর';
      case _DayPhase.day:
        return 'দিন';
      case _DayPhase.sunset:
        return 'সন্ধ্যা';
      case _DayPhase.night:
        return 'রাত';
    }
  }
}

class _ScenePalette {
  const _ScenePalette({
    required this.sky,
    required this.horizon,
    required this.ground,
    required this.lightText,
    required this.sun,
  });

  final List<Color> sky;
  final Color horizon;
  final Color ground;
  final Color lightText;
  final Color sun;

  static _ScenePalette forPhase(_DayPhase phase) {
    switch (phase) {
      case _DayPhase.dawn:
        return const _ScenePalette(
          sky: [Color(0xFF8FC7E8), Color(0xFFF4D3B3)],
          horizon: Color(0xFF648B9B),
          ground: Color(0xFF294E5D),
          lightText: Colors.white,
          sun: Color(0xFFFFE2AC),
        );
      case _DayPhase.day:
        return const _ScenePalette(
          sky: [Color(0xFF43B7E8), Color(0xFFE8F7FC)],
          horizon: Color(0xFF4E91A8),
          ground: Color(0xFF24546A),
          lightText: Colors.white,
          sun: Color(0xFFFFEEB1),
        );
      case _DayPhase.sunset:
        return const _ScenePalette(
          sky: [Color(0xFFE48C78), Color(0xFFF4C8AE)],
          horizon: Color(0xFF626D85),
          ground: Color(0xFF32435A),
          lightText: Colors.white,
          sun: Color(0xFFFFD394),
        );
      case _DayPhase.night:
        return const _ScenePalette(
          sky: [Color(0xFF0B2039), Color(0xFF15334F)],
          horizon: Color(0xFF263C50),
          ground: Color(0xFF081422),
          lightText: Colors.white,
          sun: Color(0xFFE7F0FA),
        );
    }
  }
}

class _SkylinePainter extends CustomPainter {
  const _SkylinePainter({required this.phase, required this.palette});

  final _DayPhase phase;
  final _ScenePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: palette.sky,
      ).createShader(rect);
    canvas.drawRect(rect, gradient);

    final celestial = Paint()..color = palette.sun;
    final cx = size.width * (phase == _DayPhase.night ? .77 : .73);
    final cy = size.height *
        (phase == _DayPhase.dawn
            ? .29
            : phase == _DayPhase.sunset
                ? .38
                : .22);
    canvas.drawCircle(
      Offset(cx, cy),
      phase == _DayPhase.night ? 21 : 24,
      celestial,
    );

    if (phase == _DayPhase.night) {
      final star = Paint()..color = Colors.white.withValues(alpha: .70);
      const points = [
        Offset(.12, .16),
        Offset(.28, .28),
        Offset(.46, .13),
        Offset(.61, .22),
        Offset(.84, .13),
        Offset(.70, .31),
      ];
      for (final p in points) {
        canvas.drawCircle(
          Offset(size.width * p.dx, size.height * p.dy),
          1.3,
          star,
        );
      }
    }

    final hill = Paint()..color = palette.horizon.withValues(alpha: .78);
    final hillPath = Path()
      ..moveTo(0, size.height * .67)
      ..quadraticBezierTo(
        size.width * .20,
        size.height * .53,
        size.width * .42,
        size.height * .65,
      )
      ..quadraticBezierTo(
        size.width * .63,
        size.height * .46,
        size.width,
        size.height * .64,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath, hill);

    final ground = Paint()..color = palette.ground;
    final groundPath = Path()
      ..moveTo(0, size.height * .72)
      ..quadraticBezierTo(
        size.width * .30,
        size.height * .64,
        size.width * .53,
        size.height * .73,
      )
      ..quadraticBezierTo(
        size.width * .77,
        size.height * .65,
        size.width,
        size.height * .72,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(groundPath, ground);

    final mosque = Paint()..color = palette.ground.withValues(alpha: .98);
    final base = Rect.fromLTWH(
      size.width * .30,
      size.height * .63,
      size.width * .40,
      size.height * .22,
    );
    canvas.drawRect(base, mosque);

    final dome = Path()
      ..moveTo(size.width * .37, size.height * .64)
      ..quadraticBezierTo(
        size.width * .50,
        size.height * .48,
        size.width * .63,
        size.height * .64,
      )
      ..close();
    canvas.drawPath(dome, mosque);

    final centerTower = Rect.fromLTWH(
      size.width * .477,
      size.height * .46,
      size.width * .045,
      size.height * .18,
    );
    canvas.drawRect(centerTower, mosque);
    canvas.drawCircle(
      Offset(size.width * .50, size.height * .45),
      4,
      mosque,
    );

    final minaret1 = Rect.fromLTWH(
      size.width * .27,
      size.height * .54,
      size.width * .028,
      size.height * .32,
    );
    final minaret2 = Rect.fromLTWH(
      size.width * .70,
      size.height * .54,
      size.width * .028,
      size.height * .32,
    );
    canvas.drawRect(minaret1, mosque);
    canvas.drawRect(minaret2, mosque);
    canvas.drawCircle(
      Offset(size.width * .284, size.height * .535),
      3,
      mosque,
    );
    canvas.drawCircle(
      Offset(size.width * .714, size.height * .535),
      3,
      mosque,
    );

    final doorway = Paint()..color = palette.sky.last.withValues(alpha: .35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .478,
          size.height * .74,
          size.width * .044,
          size.height * .11,
        ),
        const Radius.circular(20),
      ),
      doorway,
    );
  }

  @override
  bool shouldRepaint(covariant _SkylinePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.palette != palette;
}
