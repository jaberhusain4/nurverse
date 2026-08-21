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
import '../widgets/home/islamic_ornamental_background.dart';
import 'home_mode_settings_screen.dart';
import 'prayer/jamaat_settings_screen.dart';
import 'qibla/qibla_screen.dart';
import 'quran/onudhabon_quran_screen.dart';
import 'dua/dua_screen.dart';
import 'tools/asma_ul_husna.dart';
import 'tools/calendar_screen.dart';
import 'tools/tasbih_screen.dart';
import 'tools/zakat_calculator_screen.dart';

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
    final value =
        '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period';
    if (_currentTime == value) return;
    setState(() => _currentTime = value);
  }

  Future<void> _loadLastRead() async {
    try {
      final data = await LastReadService.getLastRead();
      if (!mounted) return;
      setState(() => _lastRead = data);
    } catch (_) {
      if (!mounted) return;
      setState(() => _lastRead = null);
    }
  }

  Future<void> _refreshHome() async {
    await context.read<PrayerController>().refreshLocation();
    await _loadLastRead();
  }

  void _open(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  void _openHomeModeSettings() {
    _open(const HomeModeSettingsScreen());
  }

  String _label(String languageCode, String bn, String en) {
    return languageCode == 'en' ? en : bn;
  }

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
      const digits = <String>[
        '০',
        '১',
        '২',
        '৩',
        '৪',
        '৫',
        '৬',
        '৭',
        '৮',
        '৯',
      ];
      String bnDigits(int value) {
        return value
            .toString()
            .split('')
            .map((d) => digits[int.parse(d)])
            .join();
      }

      final month = languageCode == 'en'
          ? enMonths[h.hMonth - 1]
          : bnMonths[h.hMonth - 1];
      final day = languageCode == 'en' ? h.hDay.toString() : bnDigits(h.hDay);
      final year =
          languageCode == 'en' ? h.hYear.toString() : bnDigits(h.hYear);
      return '$day $month $year';
    } catch (_) {
      return '--';
    }
  }

  String _englishDate() => DateService.englishDate();

  String _currentJamaatKey(String prayer) {
    final normalized = prayer.trim().toLowerCase();
    if (normalized.contains('ফজর') || normalized.contains('fajr')) {
      return 'Fajr';
    }
    if (normalized.contains('যোহর') ||
        normalized.contains('dhuhr') ||
        normalized.contains('জুমু')) {
      return 'Dhuhr';
    }
    if (normalized.contains('আসর') || normalized.contains('asr')) {
      return 'Asr';
    }
    if (normalized.contains('মাগরিব') || normalized.contains('maghrib')) {
      return 'Maghrib';
    }
    if (normalized.contains('ইশা') || normalized.contains('isha')) {
      return 'Isha';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final languageCode = settings.languageCode;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final currentJamaatKey = _currentJamaatKey(controller.currentPrayer);
    final currentJamaat = currentJamaatKey.isEmpty
        ? '--:--'
        : JamaatService.get(currentJamaatKey);

    final lastRead = _lastRead;
    final hasLastRead = lastRead != null &&
        (lastRead['surahName']?.toString() ?? '').trim().isNotEmpty;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: IgnorePointer(child: IslamicOrnamentalBackground()),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: primary,
              onRefresh: _refreshHome,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
                children: [
                  _buildHeader(
                    context,
                    languageCode: languageCode,
                    primary: primary,
                  ),
                  const SizedBox(height: 12),
                  _buildWelcomeHero(
                    context,
                    languageCode: languageCode,
                    primary: primary,
                    location: controller.currentLocationName,
                  ),
                  const SizedBox(height: 12),
                  CurrentPrayerPremiumCard(
                    previousPrayer: controller.previousPrayer,
                    previousPrayerTime: controller.previousPrayerTime,
                    currentPrayer: controller.currentPrayer,
                    currentPrayerTime: controller.currentPrayerTime,
                    nextPrayer: controller.nextPrayerName,
                    nextPrayerTime: controller.nextPrayerTime,
                    remainingTime: controller.timeRemainingForNextPrayer,
                    progress: controller.prayerProgress,
                    iqamahTime: currentJamaat,
                    status: controller.prayerStatus,
                    languageCode: languageCode,
                    onJamaatTap: () => _open(const JamaatSettingsScreen()),
                  ),
                  const SizedBox(height: 10),
                  _buildSolarRow(
                    context,
                    languageCode: languageCode,
                    sunrise: controller.sunriseTime,
                    sunset: controller.sunsetTime,
                    primary: primary,
                  ),
                  const SizedBox(height: 18),
                  _buildSectionHeader(
                    context,
                    title: _label(languageCode, 'প্রয়োজনীয় ফিচার', 'Essentials'),
                    subtitle: _label(
                      languageCode,
                      'প্রতিদিনের প্রয়োজনীয় কাজ এক জায়গায়',
                      'Your everyday essentials, one tap away',
                    ),
                  ),
                  const SizedBox(height: 9),
                  _buildQuickActions(
                    context,
                    languageCode: languageCode,
                    primary: primary,
                  ),
                  if (hasLastRead) ...[
                    const SizedBox(height: 18),
                    _buildSectionHeader(
                      context,
                      title: _label(
                        languageCode,
                        'কুরআন চালিয়ে যান',
                        'Continue Quran',
                      ),
                      subtitle: _label(
                        languageCode,
                        'যেখান থেকে থেমেছিলেন সেখান থেকেই শুরু করুন',
                        'Pick up exactly where you left off',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ContinueReadingCard(
                      surahName: lastRead!['surahName']?.toString() ?? '',
                      paraNo: lastRead!['paraNo'] is int
                          ? lastRead!['paraNo'] as int
                          : int.tryParse('${lastRead!['paraNo']}') ?? 1,
                      pageNo: lastRead!['pageNo'] is int
                          ? lastRead!['pageNo'] as int
                          : int.tryParse('${lastRead!['pageNo']}') ?? 1,
                      progress: (lastRead!['progress'] is num
                              ? (lastRead!['progress'] as num).toDouble()
                              : 0.0)
                          .clamp(0.0, 1.0),
                      languageCode: languageCode,
                      onTap: () => _open(
                        const OnudhabonQuranScreen(openLastRead: true),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  _buildSectionHeader(
                    context,
                    title: _label(languageCode, 'আজকের জন্য', 'For Today'),
                    subtitle: _label(
                      languageCode,
                      'আয়াত, হাদিস ও দোয়া—সংক্ষেপে',
                      'Ayah, Hadith and Dua—kept simple',
                    ),
                  ),
                  const SizedBox(height: 8),
                  DailyContentSection(
                    languageCode: languageCode,
                    onNavigateTab: widget.onNavigateTab,
                  ),
                  const SizedBox(height: 14),
                  _buildFooterCard(
                    context,
                    languageCode: languageCode,
                    primary: primary,
                    englishDate: _englishDate(),
                    hijriDate: _hijriDate(languageCode),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required String languageCode,
    required Color primary,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(languageCode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _currentTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.secondaryTextColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .2,
                ),
              ),
            ],
          ),
        ),
        _HeaderAction(
          icon: Icons.refresh_rounded,
          tooltip: _label(languageCode, 'রিফ্রেশ', 'Refresh'),
          onTap: _refreshHome,
          primary: primary,
        ),
        const SizedBox(width: 6),
        _HeaderAction(
          icon: Icons.tune_rounded,
          tooltip: _label(languageCode, 'হোম স্ক্রিন', 'Home Screen'),
          onTap: _openHomeModeSettings,
          primary: primary,
        ),
      ],
    );
  }

  Widget _buildWelcomeHero(
    BuildContext context, {
    required String languageCode,
    required Color primary,
    required String location,
  }) {
    final theme = Theme.of(context);
    final secondary = context.secondaryTextColor;
    final displayLocation = location.trim().isEmpty
        ? _label(languageCode, 'লোকেশন নির্ধারণ হচ্ছে…', 'Locating your area…')
        : location.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: .12),
            primary.withValues(alpha: .035),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: .11)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label(languageCode, 'আপনার অবস্থান', 'Your location'),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayLocation,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right_rounded, size: 21),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: primary.withValues(alpha: .08),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _DatePill(
                  icon: Icons.calendar_today_rounded,
                  label: _label(languageCode, 'গ্রেগরিয়ান', 'Gregorian'),
                  value: _englishDate(),
                  primary: primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DatePill(
                  icon: Icons.nightlight_round,
                  label: _label(languageCode, 'হিজরি', 'Hijri'),
                  value: _hijriDate(languageCode),
                  primary: primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSolarRow(
    BuildContext context, {
    required String languageCode,
    required String sunrise,
    required String sunset,
    required Color primary,
  }) {
    return Row(
      children: [
        Expanded(
          child: _SolarCard(
            icon: Icons.wb_sunny_outlined,
            title: _label(languageCode, 'সূর্যোদয়', 'Sunrise'),
            value: sunrise.isEmpty ? '--:--' : sunrise,
            caption: _label(languageCode, 'আজকের শুরু', 'Today'),
            primary: primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SolarCard(
            icon: Icons.wb_twilight_outlined,
            title: _label(languageCode, 'সূর্যাস্ত', 'Sunset'),
            value: sunset.isEmpty ? '--:--' : sunset,
            caption: _label(languageCode, 'আজকের শেষ', 'Today'),
            primary: primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -.1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: context.secondaryTextColor,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    BuildContext context, {
    required String languageCode,
    required Color primary,
  }) {
    final actions = <_QuickActionData>[
      _QuickActionData(
        icon: Icons.menu_book_rounded,
        title: _label(languageCode, 'কুরআন', 'Quran'),
        accent: primary,
        onTap: () => widget.onNavigateTab?.call(2),
      ),
      _QuickActionData(
        icon: Icons.explore_rounded,
        title: _label(languageCode, 'কিবলা', 'Qibla'),
        accent: primary,
        onTap: () => _open(const QiblaScreen()),
      ),
      _QuickActionData(
        icon: Icons.favorite_rounded,
        title: _label(languageCode, 'দোয়া', 'Dua'),
        accent: primary,
        onTap: () => _open(const DuaScreen()),
      ),
      _QuickActionData(
        icon: Icons.touch_app_rounded,
        title: _label(languageCode, 'তাসবিহ', 'Tasbih'),
        accent: primary,
        onTap: () => _open(const TasbihScreen()),
      ),
      _QuickActionData(
        icon: Icons.auto_awesome_rounded,
        title: _label(languageCode, '৯৯ নাম', '99 Names'),
        accent: primary,
        onTap: () => _open(const AsmaUlHusnaScreen()),
      ),
      _QuickActionData(
        icon: Icons.auto_stories_rounded,
        title: _label(languageCode, 'হাদিস', 'Hadith'),
        accent: primary,
        onTap: () => widget.onNavigateTab?.call(3),
      ),
      _QuickActionData(
        icon: Icons.calendar_month_rounded,
        title: _label(languageCode, 'ক্যালেন্ডার', 'Calendar'),
        accent: primary,
        onTap: () => _open(const CalendarScreen()),
      ),
      _QuickActionData(
        icon: Icons.account_balance_wallet_rounded,
        title: _label(languageCode, 'জাকাত', 'Zakat'),
        accent: primary,
        onTap: () => _open(const ZakatCalculatorScreen()),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: .98,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return _QuickActionTile(data: action);
      },
    );
  }

  Widget _buildFooterCard(
    BuildContext context, {
    required String languageCode,
    required Color primary,
    required String englishDate,
    required String hijriDate,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: .07)),
      ),
      child: Row(
        children: [
          Icon(Icons.today_rounded, size: 19, color: primary),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label(languageCode, 'আজ', 'Today'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: context.secondaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  englishDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: primary.withValues(alpha: .10),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hijriDate,
              maxLines: 2,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: primary,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.primary,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: primary.withValues(alpha: .08)),
            ),
            child: Icon(icon, size: 20, color: primary),
          ),
        ),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({
    required this.icon,
    required this.label,
    required this.value,
    required this.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: primary),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.secondaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SolarCard extends StatelessWidget {
  const _SolarCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
    required this.primary,
  });

  final IconData icon;
  final String title;
  final String value;
  final String caption;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: primary.withValues(alpha: .07)),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: primary, size: 18),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.secondaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: .15,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  caption,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.title,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color accent;
  final VoidCallback onTap;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.data});

  final _QuickActionData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: data.accent.withValues(alpha: .07)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: data.accent.withValues(alpha: .085),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(data.icon, color: data.accent, size: 19),
                ),
                const SizedBox(height: 7),
                SizedBox(
                  height: 19,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      data.title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
