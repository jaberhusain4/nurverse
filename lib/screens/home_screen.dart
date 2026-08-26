import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../providers/settings_provider.dart';
import '../services/date_service.dart';
import '../services/jamaat_service.dart';
import '../services/last_read_service.dart';
import '../services/sun_time_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common/current_prayer_premium_card.dart';
import '../widgets/home/continue_reading_card.dart';
import '../widgets/home/daily_content_section.dart';
import '../widgets/home/islamic_info_card.dart';
import '../widgets/home/islamic_ornamental_background.dart';
import '../widgets/home/live_prayer_restriction_card.dart';
import '../widgets/home/prayer_timeline_card.dart';
import '../widgets/home/top_header.dart';
import 'prayer/jamaat_settings_screen.dart';
import 'qibla/qibla_screen.dart';
import 'quran/audio_quran_screen.dart';
import 'tools/asma_ul_husna.dart';
import 'tools/calendar_screen.dart';
import 'dua/dua_screen.dart';
import 'tools/ruqyah_screen.dart';
import 'tools/tasbih_screen.dart';
import 'tools/zakat_calculator_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _clockTimer;
  String _currentTime = '';
  Map<String, dynamic>? _lastRead;
  bool _lastReadLoading = true;

  double? _sunLatitude;
  double? _sunLongitude;
  DateTime? _sunDate;
  SunTimeInfo? _sunTimeInfo;

  @override
  void initState() {
    super.initState();
    _updateClock();
    _loadLastRead();
    JamaatService.initialize().then((_) {
      if (mounted) setState(() {});
    });

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateClock();
    });
  }

  void _updateClock() {
    final now = DateTime.now();
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final value = '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $period';

    if (_currentTime == value) return;
    setState(() => _currentTime = value);
  }

  Future<void> _loadLastRead() async {
    try {
      final data = await LastReadService.getLastRead();
      if (!mounted) return;
      setState(() {
        _lastRead = data;
        _lastReadLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _lastRead = null;
        _lastReadLoading = false;
      });
    }
  }

  Future<void> _refreshHome() async {
    final controller = context.read<PrayerController>();
    await controller.refreshLocation();
    await _loadLastRead();
    if (mounted) setState(() {});
  }

  String _displayTime(String value, bool showSeconds) {
    final raw = value.trim();
    if (showSeconds) return raw;
    final match = RegExp(r'^(\d{1,2}:\d{2})').firstMatch(raw);
    return match?.group(1) ?? raw;
  }

  List<Map<String, dynamic>> _displayPrayerTimes(
    List<Map<String, dynamic>> prayers,
    bool showSeconds,
  ) {
    return prayers.map((prayer) {
      final copy = Map<String, dynamic>.from(prayer);
      for (final key in const ['start', 'end', 'jamaat', 'time', 'formattedTime']) {
        final value = copy[key];
        if (value != null) {
          copy[key] = _displayTime(value.toString(), showSeconds);
        }
      }
      return copy;
    }).toList(growable: false);
  }

  String _greeting(String languageCode) {
    final hour = DateTime.now().hour;
    if (languageCode == 'en') {
      if (hour < 12) return 'Good Morning';
      if (hour < 18) return 'Good Afternoon';
      return 'Good Evening';
    }
    if (languageCode == 'ar') {
      return hour < 12 ? 'صباح الخير' : 'مساء الخير';
    }
    if (hour < 12) return 'শুভ সকাল';
    if (hour < 15) return 'শুভ দুপুর';
    if (hour < 18) return 'শুভ বিকেল';
    return 'শুভ সন্ধ্যা';
  }

  String _label(String languageCode, String bn, String en, String ar) {
    if (languageCode == 'en') return en;
    if (languageCode == 'ar') return ar;
    return bn;
  }

  String _hijriDate(String languageCode) {
    try {
      final h = HijriCalendar.now();
      const bnMonths = <String>[
        'মুহররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি',
        'জুমাদিউল আউয়াল', 'জুমাদিউস সানি', 'রজব', 'শাবান',
        'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ',
      ];
      const enMonths = <String>[
        'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
        'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha’ban',
        'Ramadan', 'Shawwal', 'Dhul-Qadah', 'Dhul-Hijjah',
      ];
      const arMonths = <String>[
        'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
        'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
        'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
      ];
      const digits = <String>['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

      String bnDigits(int value) => value
          .toString()
          .split('')
          .map((d) => digits[int.parse(d)])
          .join();

      final index = (h.hMonth - 1).clamp(0, 11);
      if (languageCode == 'en') return '${h.hDay} ${enMonths[index]} ${h.hYear} AH';
      if (languageCode == 'ar') return '${h.hDay} ${arMonths[index]} ${h.hYear} هـ';
      return '${bnDigits(h.hDay)} ${bnMonths[index]} ${bnDigits(h.hYear)} হিজরি';
    } catch (_) {
      return languageCode == 'en' ? 'Hijri date unavailable' : 'হিজরি তারিখ পাওয়া যায়নি';
    }
  }

  String _banglaDate() {
    final now = DateTime.now();
    final year = now.year;
    final starts = <DateTime>[
      DateTime(year, 4, 14), DateTime(year, 5, 15), DateTime(year, 6, 15),
      DateTime(year, 7, 16), DateTime(year, 8, 16), DateTime(year, 9, 16),
      DateTime(year, 10, 16), DateTime(year, 11, 15), DateTime(year, 12, 15),
      DateTime(year + 1, 1, 15), DateTime(year + 1, 2, 13), DateTime(year + 1, 3, 15),
    ];
    const months = <String>[
      'বৈশাখ', 'জ্যৈষ্ঠ', 'আষাঢ়', 'শ্রাবণ', 'ভাদ্র', 'আশ্বিন',
      'কার্তিক', 'অগ্রহায়ণ', 'পৌষ', 'মাঘ', 'ফাল্গুন', 'চৈত্র',
    ];

    var index = -1;
    for (var i = 0; i < starts.length; i++) {
      if (!now.isBefore(starts[i])) index = i;
    }

    if (index < 0) index = 11;
    final start = starts[index];
    final banglaYear = now.month > 4 || (now.month == 4 && now.day >= 14) ? year - 593 : year - 594;
    return '${now.difference(start).inDays + 1} ${months[index]} $banglaYear';
  }

  SunTimeInfo? _sunTimes(PrayerController controller) {
    final position = controller.position;
    if (position == null) return null;

    final now = DateTime.now();
    final sameDay = _sunDate != null &&
        _sunDate!.year == now.year &&
        _sunDate!.month == now.month &&
        _sunDate!.day == now.day;
    final sameLocation = _sunLatitude == position.latitude && _sunLongitude == position.longitude;

    if (_sunTimeInfo == null || !sameDay || !sameLocation) {
      _sunLatitude = position.latitude;
      _sunLongitude = position.longitude;
      _sunDate = now;
      _sunTimeInfo = const SunTimeService().getSunTimes(
        position,
        date: null,
        method: controller.calculationMethod,
        madhab: controller.madhhab,
      );
    }

    return _sunTimeInfo;
  }

  String _currentJamaatKey(String prayer) {
    switch (prayer) {
      case 'ফজর':
        return 'Fajr';
      case 'যোহর':
      case "জুমু'আ":
        return 'Dhuhr';
      case 'আসর':
        return 'Asr';
      case 'মাগরিব':
        return 'Maghrib';
      case 'ইশা':
        return 'Isha';
      default:
        return '';
    }
  }

  Widget _continueReading(BuildContext context, String languageCode) {
    if (_lastReadLoading) {
      return Container(
        height: 126,
        decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(22)),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_lastRead == null) {
      return ContinueReadingCard(
        languageCode: languageCode,
        surahName: _label(languageCode, 'অনুধাবন কুরআন শুরু করুন', 'Start Onudhabon Quran', 'ابدأ قرآن الفهم'),
        paraNo: 1,
        pageNo: 1,
        progress: 0,
        onTap: () => widget.onNavigateTab?.call(2),
      );
    }

    final surahName = _lastRead!['surahName']?.toString() ?? 'কুরআন';
    final paraNo = _lastRead!['paraNo'] is int ? _lastRead!['paraNo'] as int : int.tryParse(_lastRead!['paraNo']?.toString() ?? '') ?? 1;
    final pageNo = _lastRead!['pageNo'] is int ? _lastRead!['pageNo'] as int : int.tryParse(_lastRead!['pageNo']?.toString() ?? '') ?? 1;
    final progress = _lastRead!['progress'] is num
        ? (_lastRead!['progress'] as num).toDouble().clamp(0.0, 1.0)
        : (double.tryParse(_lastRead!['progress']?.toString() ?? '') ?? 0).clamp(0.0, 1.0);

    return ContinueReadingCard(
      languageCode: languageCode,
      surahName: surahName,
      paraNo: paraNo,
      pageNo: pageNo,
      progress: progress,
      onTap: () => widget.onNavigateTab?.call(2),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary.withValues(alpha: 0.06)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primary, size: 22),
              const SizedBox(height: 5),
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 10.5, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openJamaatSettings() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const JamaatSettingsScreen()));
    if (mounted) setState(() {});
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final languageCode = settings.languageCode;
    final sunTimes = _sunTimes(controller);

    JamaatService.configureDefaultsFromPrayerList(controller.prayers);
    final jamaatKey = _currentJamaatKey(controller.currentPrayer);
    final currentJamaat = jamaatKey.isEmpty ? '--:--' : JamaatService.get(jamaatKey);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: IslamicOrnamentalBackground()),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshHome,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopHeader(
                      greeting: _greeting(languageCode),
                      currentTime: _displayTime(_currentTime, settings.showSeconds),
                      onNotificationTap: () => widget.onNavigateTab?.call(5),
                      onProfileTap: () => widget.onNavigateTab?.call(5),
                    ),
                    const SizedBox(height: 14),
                    CurrentPrayerPremiumCard(
                      previousPrayer: controller.previousPrayer,
                      previousPrayerTime: _displayTime(controller.previousPrayerTime, settings.showSeconds),
                      currentPrayer: controller.currentPrayer,
                      currentPrayerTime: _displayTime(controller.currentPrayerTime, settings.showSeconds),
                      nextPrayer: controller.nextPrayer,
                      nextPrayerTime: _displayTime(controller.nextPrayerTime, settings.showSeconds),
                      remainingTime: _displayTime(controller.timeRemainingForNextPrayer, settings.showSeconds),
                      progress: controller.prayerProgress,
                      iqamahTime: _displayTime(currentJamaat, settings.showSeconds),
                      status: controller.prayerStatus,
                      languageCode: languageCode,
                      onJamaatTap: _openJamaatSettings,
                    ),
                    const SizedBox(height: 10),
                    PrayerTimelineCard(
                      prayers: _displayPrayerTimes(controller.prayers, settings.showSeconds),
                      languageCode: languageCode,
                    ),
                    const SizedBox(height: 10),
                    IslamicInfoCard(
                      location: controller.currentLocationName,
                      englishDate: DateService.englishDate(),
                      banglaDate: _banglaDate(),
                      hijriDate: _hijriDate(languageCode),
                      sunrise: _displayTime(sunTimes?.sunriseString ?? controller.sunriseTime, settings.showSeconds),
                      sunset: _displayTime(sunTimes?.sunsetString ?? controller.sunsetTime, settings.showSeconds),
                      languageCode: languageCode,
                      onRefresh: controller.refreshLocation,
                    ),
                    const SizedBox(height: 10),
                    LivePrayerRestrictionCard(languageCode: languageCode),
                    const SizedBox(height: 14),
                    _continueReading(context, languageCode),
                    const SizedBox(height: 16),
                    Text(
                      _label(languageCode, 'কুইক অ্যাকশনস', 'Quick Actions', 'إجراءات سريعة'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 9),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.02,
                      children: [
                        _quickAction(context, title: _label(languageCode, 'ক্যালেন্ডার', 'Calendar', 'التقويم'), icon: Icons.calendar_month_rounded, onTap: () => _openScreen(const CalendarScreen())),
                        _quickAction(context, title: _label(languageCode, 'দোয়া', 'Dua', 'الدعاء'), icon: Icons.menu_book_rounded, onTap: () => _openScreen(const DuaScreen())),
                        _quickAction(context, title: _label(languageCode, 'কিবলা', 'Qibla', 'القبلة'), icon: Icons.explore_rounded, onTap: () => _openScreen(const QiblaScreen())),
                        _quickAction(context, title: _label(languageCode, 'তাসবীহ', 'Tasbih', 'التسبيح'), icon: Icons.radio_button_checked_rounded, onTap: () => _openScreen(const TasbihScreen())),
                        _quickAction(context, title: _label(languageCode, '৯৯ নাম', '99 Names', 'أسماء الله'), icon: Icons.nightlight_round, onTap: () => _openScreen(const AsmaUlHusnaScreen())),
                        _quickAction(context, title: _label(languageCode, 'অডিও কুরআন', 'Audio Quran', 'القرآن الصوتي'), icon: Icons.headphones_rounded, onTap: () => _openScreen(const AudioQuranScreen())),
                        _quickAction(context, title: _label(languageCode, 'রুকিয়াহ', 'Ruqyah', 'الرقية'), icon: Icons.shield_outlined, onTap: () => _openScreen(const RuqyahScreen())),
                        _quickAction(context, title: _label(languageCode, 'যাকাত', 'Zakat', 'الزكاة'), icon: Icons.monetization_on_outlined, onTap: () => _openScreen(const ZakatCalculatorScreen())),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const DailyContentSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }
}
