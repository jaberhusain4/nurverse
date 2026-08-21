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
import '../widgets/home/daily_content_section.dart';
import 'home_mode_settings_screen.dart';
import 'prayer/jamaat_settings_screen.dart';
import 'qibla/qibla_screen.dart';
import 'quran/onudhabon_quran_screen.dart';
import 'tools/asma_ul_husna.dart';
import 'tools/calendar_screen.dart';
import 'tools/tasbih_screen.dart';
import 'tools/zakat_calculator_screen.dart';
import 'dua/dua_screen.dart';

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
  Timer? _clockTimer;
  String _currentTime = '';
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _updateClock();
    _loadLastRead();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateClock();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _updateClock() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final value = '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period';
    if (_currentTime == value) return;
    setState(() => _currentTime = value);
  }

  Future<void> _loadLastRead() async {
    final data = await LastReadService.getLastRead();
    if (!mounted) return;
    setState(() => _lastRead = data);
  }

  Future<void> _refreshHome() async {
    await context.read<PrayerController>().refreshLocation();
    await _loadLastRead();
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  String _label(String languageCode, String bn, String en) => languageCode == 'en' ? en : bn;

  String _greeting(String languageCode) {
    final hour = DateTime.now().hour;
    if (languageCode == 'en') {
      if (hour < 12) return 'Good Morning';
      if (hour < 18) return 'Good Afternoon';
      return 'Good Evening';
    }
    if (hour < 12) return 'শুভ সকাল';
    if (hour < 18) return 'শুভ দিন';
    return 'শুভ সন্ধ্যা';
  }

  String _hijriDate(String languageCode) {
    try {
      final h = HijriCalendar.now();
      const bnMonths = <String>[
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
      const enMonths = <String>[
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
      const digits = <String>['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
      String bnDigits(int value) => value.toString().split('').map((d) => digits[int.parse(d)]).join();
      final month = languageCode == 'en' ? enMonths[h.hMonth - 1] : bnMonths[h.hMonth - 1];
      final day = languageCode == 'en' ? h.hDay.toString() : bnDigits(h.hDay);
      final year = languageCode == 'en' ? h.hYear.toString() : bnDigits(h.hYear);
      return '$day $month $year';
    } catch (_) {
      return '--';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final languageCode = settings.languageCode;

    final lastRead = _lastRead;
    final hasLastRead = lastRead != null && (lastRead['surahName']?.toString() ?? '').isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(languageCode),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _currentTime,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: _label(languageCode, 'হোম স্ক্রিন', 'Home Screen'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const HomeModeSettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.tune_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.currentLocationName.isEmpty
                            ? _label(languageCode, 'লোকেশন পাওয়া যাচ্ছে…', 'Locating…')
                            : controller.currentLocationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _hijriDate(languageCode),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.secondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _CurrentPrayerCard(
                currentPrayer: controller.currentPrayer,
                currentPrayerTime: controller.currentPrayerTime,
                nextPrayer: controller.nextPrayerName,
                nextPrayerTime: controller.nextPrayerTime,
                remainingTime: controller.timeRemainingForNextPrayer,
                progress: controller.prayerProgress,
                status: controller.prayerStatus,
                languageCode: languageCode,
                onJamaatTap: () => _open(const JamaatSettingsScreen()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MiniInfo(
                      icon: Icons.wb_sunny_outlined,
                      title: _label(languageCode, 'সূর্যোদয়', 'Sunrise'),
                      value: controller.sunriseTime,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniInfo(
                      icon: Icons.wb_twilight_outlined,
                      title: _label(languageCode, 'সূর্যাস্ত', 'Sunset'),
                      value: controller.sunsetTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _label(languageCode, 'দ্রুত অ্যাকশন', 'Quick Actions'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 9),
              GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.02,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ActionTile(icon: Icons.menu_book_rounded, title: _label(languageCode, 'কুরআন', 'Quran'), onTap: () => widget.onNavigateTab?.call(2)),
                  _ActionTile(icon: Icons.explore_rounded, title: _label(languageCode, 'কিবলা', 'Qibla'), onTap: () => _open(const QiblaScreen())),
                  _ActionTile(icon: Icons.favorite_rounded, title: _label(languageCode, 'দোয়া', 'Dua'), onTap: () => _open(const DuaScreen())),
                  _ActionTile(icon: Icons.touch_app_rounded, title: _label(languageCode, 'তাসবিহ', 'Tasbih'), onTap: () => _open(const TasbihScreen())),
                  _ActionTile(icon: Icons.auto_awesome_rounded, title: _label(languageCode, '৯৯ নাম', '99 Names'), onTap: () => _open(const AsmaUlHusnaScreen())),
                  _ActionTile(icon: Icons.calendar_month_rounded, title: _label(languageCode, 'ক্যালেন্ডার', 'Calendar'), onTap: () => _open(const CalendarScreen())),
                  _ActionTile(icon: Icons.account_balance_wallet_rounded, title: _label(languageCode, 'জাকাত', 'Zakat'), onTap: () => _open(const ZakatCalculatorScreen())),
                  _ActionTile(icon: Icons.auto_stories_rounded, title: _label(languageCode, 'হাদিস', 'Hadith'), onTap: () => widget.onNavigateTab?.call(3)),
                ],
              ),
              const SizedBox(height: 16),
              if (hasLastRead) ...[
                Text(
                  _label(languageCode, 'কুরআন চালিয়ে যান', 'Continue Quran'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                ContinueReadingCard(
                  surahName: lastRead!['surahName']?.toString() ?? '',
                  paraNo: lastRead!['paraNo'] is int ? lastRead!['paraNo'] as int : int.tryParse('${lastRead!['paraNo']}') ?? 1,
                  pageNo: lastRead!['pageNo'] is int ? lastRead!['pageNo'] as int : int.tryParse('${lastRead!['pageNo']}') ?? 1,
                  progress: (lastRead!['progress'] is num ? (lastRead!['progress'] as num).toDouble() : 0).clamp(0.0, 1.0),
                  languageCode: languageCode,
                  onTap: () => _open(const OnudhabonQuranScreen(openLastRead: true)),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                _label(languageCode, 'আজকের কনটেন্ট', 'Today'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              DailyContentSection(languageCode: languageCode, onNavigateTab: widget.onNavigateTab),
              const SizedBox(height: 6),
              Text(
                '${_label(languageCode, 'ইংরেজি তারিখ', 'Date')}: ${DateService.englishDate()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentPrayerCard extends StatelessWidget {
  const _CurrentPrayerCard({
    required this.currentPrayer,
    required this.currentPrayerTime,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.remainingTime,
    required this.progress,
    required this.status,
    required this.languageCode,
    required this.onJamaatTap,
  });

  final String currentPrayer;
  final String currentPrayerTime;
  final String nextPrayer;
  final String nextPrayerTime;
  final String remainingTime;
  final double progress;
  final String status;
  final String languageCode;
  final VoidCallback onJamaatTap;

  String _translatePrayer(String value) {
    if (languageCode == 'en') return value;
    final normalized = value.toLowerCase();
    if (normalized.contains('fajr') || normalized.contains('ফজর')) return 'ফজর';
    if (normalized.contains('dhuhr') || normalized.contains('যোহর') || normalized.contains('জুমু')) return 'যোহর';
    if (normalized.contains('asr') || normalized.contains('আসর')) return 'আসর';
    if (normalized.contains('maghrib') || normalized.contains('মাগরিব')) return 'মাগরিব';
    if (normalized.contains('isha') || normalized.contains('ইশা')) return 'এশা';
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: .14),
            primary.withValues(alpha: .055),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withValues(alpha: .12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  languageCode == 'en' ? 'Current Prayer' : 'বর্তমান ওয়াক্ত',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.secondaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InkWell(
                onTap: onJamaatTap,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                  child: Row(
                    children: [
                      Icon(Icons.groups_outlined, size: 16, color: primary),
                      const SizedBox(width: 4),
                      Text(
                        languageCode == 'en' ? 'Jamaat' : 'জামাআত',
                        style: theme.textTheme.labelSmall?.copyWith(color: primary, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  _translatePrayer(currentPrayer),
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                currentPrayerTime.isEmpty ? '--:--' : currentPrayerTime,
                style: theme.textTheme.titleLarge?.copyWith(color: primary, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Icon(Icons.timelapse_rounded, size: 16, color: primary),
              const SizedBox(width: 6),
              Text(
                languageCode == 'en'
                    ? '$remainingTime until ${_translatePrayer(nextPrayer)}'
                    : '$remainingTime পর ${_translatePrayer(nextPrayer)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.secondaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress.clamp(0.0, 1.0),
              backgroundColor: primary.withValues(alpha: .10),
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                nextPrayerTime.isEmpty ? '--:--' : nextPrayerTime,
                style: theme.textTheme.labelSmall?.copyWith(color: primary, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: .07)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.secondaryTextColor)),
                const SizedBox(height: 1),
                Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary.withValues(alpha: .07)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primary, size: 22),
              const SizedBox(height: 5),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
