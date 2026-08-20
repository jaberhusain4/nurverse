import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../providers/settings_provider.dart';
import '../services/date_service.dart';
import '../services/jamaat_service.dart';
import '../services/last_read_service.dart';
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
import 'quran/onudhabon_quran_screen.dart';
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
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Timer? _clockTimer;
  String _currentTime = '';
  Map<String, dynamic>? _lastRead;
  bool _lastReadLoading = true;

  @override
  void initState() {
    super.initState();
    _updateClock();
    _loadLastRead();
    JamaatService.initialize().then((_) { if (mounted) setState(() {}); });
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) _updateClock(); });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _updateClock() {
    final now = DateTime.now();
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final value = '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $period';
    if (_currentTime == value) return;
    setState(() => _currentTime = value);
  }

  Future<void> refreshForBack() => _refreshHome();

  Future<void> _loadLastRead() async {
    try {
      final data = await LastReadService.getLastRead();
      if (!mounted) return;
      setState(() { _lastRead = data; _lastReadLoading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _lastRead = null; _lastReadLoading = false; });
    }
  }

  Future<void> _refreshHome() async {
    final controller = context.read<PrayerController>();
    await controller.refreshLocation();
    await _loadLastRead();
    if (mounted) setState(() {});
  }

  String _greeting(String languageCode) {
    final hour = DateTime.now().hour;
    if (languageCode == 'en') { if (hour < 12) return 'Good Morning'; if (hour < 18) return 'Good Afternoon'; return 'Good Evening'; }
    if (languageCode == 'ar') return hour < 12 ? 'صباح الخير' : 'مساء الخير';
    if (hour < 12) return 'শুভ সকাল'; if (hour < 15) return 'শুভ দুপুর'; if (hour < 18) return 'শুভ বিকেল'; return 'শুভ সন্ধ্যা';
  }

  String _label(String languageCode, String bn, String en, String ar) {
    if (languageCode == 'en') return en; if (languageCode == 'ar') return ar; return bn;
  }

  String _hijriDate(String languageCode) {
    try {
      final h = HijriCalendar.now();
      const bnMonths = <String>['মুহররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি', 'জুমাদিউল আউয়াল', 'জুমাদিউস সানি', 'রজব', 'শাবান', 'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ'];
      const enMonths = <String>['Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', 'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha’ban', 'Ramadan', 'Shawwal', 'Dhul-Qadah', 'Dhul-Hijjah'];
      const arMonths = <String>['محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'];
      const digits = <String>['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
      String bnDigits(int value) => value.toString().split('').map((d) => digits[int.parse(d)]).join();
      final month = languageCode == 'en' ? enMonths[h.hMonth - 1] : languageCode == 'ar' ? arMonths[h.hMonth - 1] : bnMonths[h.hMonth - 1];
      final day = languageCode == 'bn' ? bnDigits(h.hDay) : h.hDay.toString();
      final year = languageCode == 'bn' ? bnDigits(h.hYear) : h.hYear.toString();
      return '$day $month $year';
    } catch (_) { return '--'; }
  }

  String _banglaDate() {
    final now = DateTime.now();
    const months = <String>['জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'];
    const digits = <String>['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String bnDigits(int value) => value.toString().split('').map((d) => digits[int.parse(d)]).join();
    return '${bnDigits(now.day)} ${months[now.month - 1]} ${bnDigits(now.year)}';
  }

  String _currentJamaatKey(String prayer) {
    final normalized = prayer.trim().toLowerCase();
    if (normalized.contains('ফজর') || normalized.contains('fajr')) return 'Fajr';
    if (normalized.contains('যোহর') || normalized.contains('dhuhr') || normalized.contains('জুমু')) return 'Dhuhr';
    if (normalized.contains('আসর') || normalized.contains('asr')) return 'Asr';
    if (normalized.contains('মাগরিব') || normalized.contains('maghrib')) return 'Maghrib';
    if (normalized.contains('ইশা') || normalized.contains('isha')) return 'Isha';
    return '';
  }

  Widget _quickAction(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context); final primary = theme.colorScheme.primary; final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    return Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: primary.withValues(alpha: 0.06))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: primary, size: 22), const SizedBox(height: 5), Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 10.5, fontWeight: FontWeight.w700))]))));
  }

  Future<void> _openJamaatSettings() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const JamaatSettingsScreen()));
    if (mounted) setState(() {});
  }

  void _openScreen(Widget screen) { Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen)); }

  Widget _continueReading(BuildContext context, String languageCode) {
    if (_lastReadLoading || _lastRead == null) return const SizedBox.shrink();
    final surahName = _lastRead!['surahName']?.toString() ?? '';
    if (surahName.isEmpty) return const SizedBox.shrink();
    final paraNo = _lastRead!['paraNo'] is int ? _lastRead!['paraNo'] as int : int.tryParse('${_lastRead!['paraNo']}') ?? 1;
    final pageNo = _lastRead!['pageNo'] is int ? _lastRead!['pageNo'] as int : int.tryParse('${_lastRead!['pageNo']}') ?? 1;
    final progressValue = _lastRead!['progress'];
    final progress = progressValue is num ? progressValue.toDouble().clamp(0.0, 1.0) : 0.0;
    return ContinueReadingCard(surahName: surahName, paraNo: paraNo, pageNo: pageNo, progress: progress, languageCode: languageCode, onTap: () => _openScreen(const OnudhabonQuranScreen(openLastRead: true)));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final languageCode = settings.languageCode;
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
                    TopHeader(greeting: _greeting(languageCode), currentTime: _currentTime, onNotificationTap: () => widget.onNavigateTab?.call(5), onProfileTap: () => widget.onNavigateTab?.call(5)),
                    const SizedBox(height: 14),
                    CurrentPrayerPremiumCard(previousPrayer: controller.previousPrayer, previousPrayerTime: controller.previousPrayerTime, currentPrayer: controller.currentPrayer, currentPrayerTime: controller.currentPrayerTime, nextPrayer: controller.nextPrayer, nextPrayerTime: controller.nextPrayerTime, remainingTime: controller.timeRemainingForNextPrayer, progress: controller.prayerProgress, iqamahTime: currentJamaat, status: controller.prayerStatus, languageCode: languageCode, onJamaatTap: _openJamaatSettings),
                    const SizedBox(height: 10),
                    PrayerTimelineCard(prayers: controller.prayers, languageCode: languageCode),
                    const SizedBox(height: 10),
                    IslamicInfoCard(location: controller.currentLocationName, englishDate: DateService.englishDate(), banglaDate: _banglaDate(), hijriDate: _hijriDate(languageCode), sunrise: controller.sunriseTime, sunset: controller.sunsetTime, languageCode: languageCode, onRefresh: controller.refreshLocation),
                    const SizedBox(height: 10),
                    LivePrayerRestrictionCard(languageCode: languageCode),
                    const SizedBox(height: 14),
                    Text(_label(languageCode, 'কুইক অ্যাকশন', 'Quick Actions', 'إجراءات سريعة'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    GridView.count(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.0, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: [
                      _quickAction(context, title: _label(languageCode, 'কিবলা', 'Qibla', 'القبلة'), icon: Icons.explore_rounded, onTap: () => _openScreen(const QiblaScreen())),
                      _quickAction(context, title: _label(languageCode, 'তাসবিহ', 'Tasbih', 'التسبيح'), icon: Icons.touch_app_rounded, onTap: () => _openScreen(const TasbihScreen())),
                      _quickAction(context, title: _label(languageCode, '৯৯ নাম', '99 Names', 'أسماء الله'), icon: Icons.auto_awesome_rounded, onTap: () => _openScreen(const AsmaUlHusnaScreen())),
                      _quickAction(context, title: _label(languageCode, 'রুকইয়াহ', 'Ruqyah', 'الرقية'), icon: Icons.menu_book_rounded, onTap: () => _openScreen(const RuqyahScreen())),
                      _quickAction(context, title: _label(languageCode, 'দোয়া', 'Dua', 'الدعاء'), icon: Icons.favorite_rounded, onTap: () => _openScreen(const DuaScreen())),
                      _quickAction(context, title: _label(languageCode, 'ক্যালেন্ডার', 'Calendar', 'التقويم'), icon: Icons.calendar_month_rounded, onTap: () => _openScreen(const CalendarScreen())),
                      _quickAction(context, title: _label(languageCode, 'জাকাত', 'Zakat', 'الزকاة'), icon: Icons.account_balance_wallet_rounded, onTap: () => _openScreen(const ZakatCalculatorScreen())),
                      _quickAction(context, title: _label(languageCode, 'কুরআন', 'Quran', 'القرآن'), icon: Icons.menu_book_rounded, onTap: () => widget.onNavigateTab?.call(2)),
                    ]),
                    const SizedBox(height: 16),
                    _continueReading(context, languageCode),
                    const SizedBox(height: 16),
                    Text(_label(languageCode, 'দৈনিক আমল ও জ্ঞান', 'Daily Deeds & Knowledge', 'الأعمال والمعرفة اليومية'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    DailyContentSection(languageCode: languageCode, onNavigateTab: widget.onNavigateTab),
                    const SizedBox(height: 16),
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
