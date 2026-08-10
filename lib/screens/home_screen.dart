import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../providers/settings_provider.dart';
import '../services/date_service.dart';
import '../services/last_read_service.dart';
import '../widgets/common/current_prayer_premium_card.dart';
import '../widgets/home/continue_reading_card.dart';
import '../widgets/home/daily_content_section.dart';
import '../widgets/home/islamic_info_card.dart';
import '../widgets/home/prayer_timeline.dart';
import '../widgets/home/top_header.dart';
import 'tools/ruqyah_screen.dart';
import 'tools/zakat_calculator_screen.dart';

// Existing screens
import 'tools/asma_ul_husna.dart';
import 'qibla/qibla_screen.dart';
import 'quran/audio_quran_screen.dart';
import 'tools/tasbih_screen.dart';
import 'tools/calendar_screen.dart';
import 'dua/dua_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  String _currentTime = '';

  Map<String, dynamic>? _lastRead;
  bool _lastReadLoading = true;

  @override
  void initState() {
    super.initState();

    _updateTime();
    _loadLastRead();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      _updateTime();

      final controller = Provider.of<PrayerController>(context, listen: false);

      controller.updatePrayerTimes();
    });
  }

  // ============================================================
  // LIVE CLOCK
  // ============================================================

  void _updateTime() {
    final now = DateTime.now();

    int hour = now.hour;

    final String period = hour >= 12 ? 'PM' : 'AM';

    hour %= 12;

    if (hour == 0) {
      hour = 12;
    }

    final String hourStr = hour.toString().padLeft(2, '0');
    final String minuteStr = now.minute.toString().padLeft(2, '0');
    final String secondStr = now.second.toString().padLeft(2, '0');

    if (!mounted) return;

    setState(() {
      _currentTime = '$hourStr:$minuteStr:$secondStr $period';
    });
  }

  // ============================================================
  // LAST READ
  // ============================================================

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

  // ============================================================
  // REFRESH HOME DATA
  // ============================================================

  Future<void> _refreshHome() async {
    final controller = Provider.of<PrayerController>(context, listen: false);

    await controller.refreshLocation();

    await _loadLastRead();

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // GREETING
  // ============================================================

  String _getGreeting(String languageCode) {
    final hour = DateTime.now().hour;

    switch (languageCode) {
      case 'en':
        if (hour < 12) {
          return 'Good Morning';
        }

        if (hour < 15) {
          return 'Good Afternoon';
        }

        if (hour < 18) {
          return 'Good Evening';
        }

        return 'Good Evening';

      case 'ar':
        if (hour < 12) {
          return 'صباح الخير';
        }

        return 'مساء الخير';

      case 'bn':
      default:
        if (hour < 12) {
          return 'শুভ সকাল';
        }

        if (hour < 15) {
          return 'শুভ দুপুর';
        }

        if (hour < 18) {
          return 'শুভ বিকেল';
        }

        return 'শুভ সন্ধ্যা';
    }
  }

  // ============================================================
  // FEATURE DIALOG
  // ============================================================

  void _showFeatureDialog(
    BuildContext context,
    String featureName,
    String languageCode,
  ) {
    String message;
    String okayText;

    switch (languageCode) {
      case 'en':
        message = '$featureName will be available soon, In Sha Allah.';
        okayText = 'OK';
        break;

      case 'ar':
        message = 'ستتوفر ميزة $featureName قريبًا إن شاء الله.';
        okayText = 'حسنًا';
        break;

      case 'bn':
      default:
        message = '$featureName ফিচারটি খুব শীঘ্রই যুক্ত হচ্ছে ইনশাআল্লাহ।';
        okayText = 'ঠিক আছে';
        break;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(featureName),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(okayText),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // OPEN SCREEN HELPER
  // ============================================================

  void _openScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  // ============================================================
  // QUICK ACTION ITEM
  // ============================================================

  Widget _buildQuickActionItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    final primary = theme.colorScheme.primary;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary.withValues(alpha: 0.07)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primary, size: 24),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BANGLA DATE
  // Bangladesh National Calendar
  // ============================================================

  String _getBanglaDate() {
    final now = DateTime.now();
    final int year = now.year;

    final List<DateTime> monthStarts = [
      DateTime(year, 4, 14),
      DateTime(year, 5, 15),
      DateTime(year, 6, 15),
      DateTime(year, 7, 16),
      DateTime(year, 8, 16),
      DateTime(year, 9, 16),
      DateTime(year, 10, 16),
      DateTime(year, 11, 15),
      DateTime(year, 12, 15),
      DateTime(year + 1, 1, 15),
      DateTime(year + 1, 2, 13),
      DateTime(year + 1, 3, 15),
    ];

    final List<String> monthNames = [
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

    final DateTime effectiveDate = now;

    int banglaYear;

    if (now.month > 4 || (now.month == 4 && now.day >= 14)) {
      banglaYear = year - 593;
    } else {
      banglaYear = year - 594;
    }

    int monthIndex = -1;

    for (int i = 0; i < monthStarts.length; i++) {
      if (!now.isBefore(monthStarts[i])) {
        monthIndex = i;
      }
    }

    if (monthIndex == -1) {
      final previousYearStarts = <DateTime>[
        DateTime(year - 1, 4, 14),
        DateTime(year - 1, 5, 15),
        DateTime(year - 1, 6, 15),
        DateTime(year - 1, 7, 16),
        DateTime(year - 1, 8, 16),
        DateTime(year - 1, 9, 16),
        DateTime(year - 1, 10, 16),
        DateTime(year - 1, 11, 15),
        DateTime(year - 1, 12, 15),
        DateTime(year, 1, 15),
        DateTime(year, 2, 13),
        DateTime(year, 3, 15),
      ];

      for (int i = 0; i < previousYearStarts.length; i++) {
        if (!now.isBefore(previousYearStarts[i])) {
          monthIndex = i;
        }
      }

      banglaYear = year - 594;
    }

    if (monthIndex < 0) {
      monthIndex = 0;
    }

    if (monthIndex >= monthNames.length) {
      monthIndex = monthNames.length - 1;
    }

    DateTime startDate;

    if (monthIndex < monthStarts.length &&
        !now.isBefore(monthStarts[monthIndex])) {
      startDate = monthStarts[monthIndex];
    } else {
      final previousYear = year - 1;

      final List<DateTime> previousStarts = [
        DateTime(previousYear, 4, 14),
        DateTime(previousYear, 5, 15),
        DateTime(previousYear, 6, 15),
        DateTime(previousYear, 7, 16),
        DateTime(previousYear, 8, 16),
        DateTime(previousYear, 9, 16),
        DateTime(previousYear, 10, 16),
        DateTime(previousYear, 11, 15),
        DateTime(previousYear, 12, 15),
        DateTime(year, 1, 15),
        DateTime(year, 2, 13),
        DateTime(year, 3, 15),
      ];

      startDate = previousStarts[monthIndex];
    }

    final int day = effectiveDate.difference(startDate).inDays + 1;

    return '$day ${monthNames[monthIndex]} $banglaYear';
  }

  // ============================================================
  // HIJRI DATE
  // ============================================================

  String _getHijriDate() {
    try {
      final hijri = HijriCalendar.now();

      final String formatted = hijri.toFormat('DD MMMM YYYY');

      return '$formatted হিজরি';
    } catch (_) {
      return 'হিজরি তারিখ পাওয়া যায়নি';
    }
  }

  // ============================================================
  // LAST READ WIDGET
  // ============================================================

  Widget _buildContinueReading(BuildContext context) {
    if (_lastReadLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const SizedBox(
          height: 90,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_lastRead == null) {
      return ContinueReadingCard(
        surahName: 'কুরআন তিলাওয়াত শুরু করুন',
        paraNo: 1,
        pageNo: 1,
        progress: 0.0,
        onTap: () {
          widget.onNavigateTab?.call(2);
        },
      );
    }

    final String surahName = _lastRead!['surahName']?.toString() ?? 'কুরআন';

    final int paraNo =
        _lastRead!['paraNo'] is int
            ? _lastRead!['paraNo'] as int
            : int.tryParse(_lastRead!['paraNo']?.toString() ?? '') ?? 1;

    final int pageNo =
        _lastRead!['pageNo'] is int
            ? _lastRead!['pageNo'] as int
            : int.tryParse(_lastRead!['pageNo']?.toString() ?? '') ?? 1;

    final double progress =
        _lastRead!['progress'] is num
            ? (_lastRead!['progress'] as num).toDouble()
            : double.tryParse(_lastRead!['progress']?.toString() ?? '') ?? 0.0;

    return ContinueReadingCard(
      surahName: surahName,
      paraNo: paraNo,
      pageNo: pageNo,
      progress: progress.clamp(0.0, 1.0),
      onTap: () {
        widget.onNavigateTab?.call(2);
      },
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  String _title(
    String languageCode, {
    required String bn,
    required String en,
    required String ar,
  }) {
    switch (languageCode) {
      case 'en':
        return en;

      case 'ar':
        return ar;

      case 'bn':
      default:
        return bn;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PrayerController>(context);

    final settings = Provider.of<SettingsProvider>(context);

    final languageCode = settings.languageCode;

    final greeting = _getGreeting(languageCode);

    final englishDate = DateService.englishDate();

    final banglaDate = _getBanglaDate();

    final hijriDate = _getHijriDate();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshHome,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // HEADER
                // ==================================================
                TopHeader(
                  greeting: greeting,
                  currentTime: _currentTime,
                  onNotificationTap: () {
                    _showFeatureDialog(
                      context,
                      _title(
                        languageCode,
                        bn: 'নোটিফিকেশন',
                        en: 'Notifications',
                        ar: 'الإشعارات',
                      ),
                      languageCode,
                    );
                  },
                  onProfileTap: () {
                    widget.onNavigateTab?.call(5);
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // CURRENT PRAYER
                // ==================================================
                CurrentPrayerPremiumCard(
                  previousPrayer: controller.previousPrayer,
                  previousPrayerTime: controller.previousPrayerTime,
                  currentPrayer: controller.currentPrayer,
                  currentPrayerTime: controller.currentPrayerTime,
                  nextPrayer: controller.nextPrayer,
                  nextPrayerTime: controller.nextPrayerTime,
                  remainingTime: controller.timeRemainingForNextPrayer,
                  progress: controller.prayerProgress,
                  sunrise: controller.sunriseTime,
                  sunset: controller.sunsetTime,
                  iqamahTime: controller.iqamahTime,
                  status: controller.prayerStatus,
                  showExtraInfo: true,
                ),

                const SizedBox(height: 20),

                // ==================================================
                // ISLAMIC INFORMATION
                // ==================================================
                IslamicInfoCard(
                  location: controller.currentLocationName,
                  englishDate: englishDate,
                  banglaDate: banglaDate,
                  hijriDate: hijriDate,
                  sunrise: controller.sunriseTime,
                  sunset: controller.sunsetTime,
                  onRefresh: () async {
                    await controller.refreshLocation();
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // PRAYER TIMELINE
                // ==================================================
                PrayerTimeline(prayers: controller.prayers),

                const SizedBox(height: 20),

                // ==================================================
                // CONTINUE READING
                // ==================================================
                _buildContinueReading(context),

                const SizedBox(height: 20),

                // ==================================================
                // QUICK ACTIONS TITLE
                // ==================================================
                Text(
                  _title(
                    languageCode,
                    bn: 'কুইক অ্যাকশনস',
                    en: 'Quick Actions',
                    ar: 'إجراءات سريعة',
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // QUICK ACTIONS
                // ==================================================
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.92,
                  children: [
                    // ==============================================
                    // CALENDAR
                    // ==============================================
                    _buildQuickActionItem(
                      context,
                      title: _title(
                        languageCode,
                        bn: 'ক্যালেন্ডার',
                        en: 'Calendar',
                        ar: 'التقويم',
                      ),
                      icon: Icons.calendar_month_rounded,
                      onTap: () {
                        _openScreen(const CalendarScreen());
                      },
                    ),

                    // ==============================================
                    // DUA
                    // ==============================================
                    _buildQuickActionItem(
                      context,
                      title: _title(
                        languageCode,
                        bn: 'দোয়া',
                        en: 'Dua',
                        ar: 'الدعاء',
                      ),
                      icon: Icons.menu_book_rounded,
                      onTap: () {
                        _openScreen(const DuaScreen());
                      },
                    ),

                    // ==============================================
                    // QIBLA
                    // ==============================================
                    _buildQuickActionItem(
                      context,
                      title: _title(
                        languageCode,
                        bn: 'কিবলা',
                        en: 'Qibla',
                        ar: 'القبلة',
                      ),
                      icon: Icons.explore_rounded,
                      onTap: () {
                        _openScreen(const QiblaScreen());
                      },
                    ),

                    // ==============================================
                    // TASBIH
                    // ==============================================
                    _buildQuickActionItem(
                      context,
                      title: _title(
                        languageCode,
                        bn: 'তাসবীহ',
                        en: 'Tasbih',
                        ar: 'التسبيح',
                      ),
                      icon: Icons.radio_button_checked_rounded,
                      onTap: () {
                        _openScreen(const TasbihScreen());
                      },
                    ),

                    // ==============================================
                    // 99 NAMES
                    // ==============================================
                    _buildQuickActionItem(
                      context,
                      title: _title(
                        languageCode,
                        bn: '৯৯ নাম',
                        en: '99 Names',
                        ar: 'أسماء الله',
                      ),
                      icon: Icons.nightlight_round,
                      onTap: () {
                        _openScreen(const AsmaUlHusnaScreen());
                      },
                    ),

                    // ==============================================
                    // AUDIO QURAN
                    // ==============================================
                    _buildQuickActionItem(
                      context,
                      title: _title(
                        languageCode,
                        bn: 'অডিও কুরআন',
                        en: 'Audio Quran',
                        ar: 'القرآن الصوتي',
                      ),
                      icon: Icons.headphones_rounded,
                      onTap: () {
                        _openScreen(const AudioQuranScreen());
                      },
                    ),

                    // ==============================================
                    // RUQYAH
                    // ==============================================
                    _buildQuickActionItem(
                      context,
                      title: _title(
                        languageCode,
                        bn: 'রুকিয়াহ',
                        en: 'Ruqyah',
                        ar: 'الرقية',
                      ),
                      icon: Icons.shield_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RuqyahScreen(),
                          ),
                        );
                      },
                    ),

                    // ==============================================
                    // ZAKAT
                    // ==============================================
                    _buildQuickActionItem(
                      context,
                      title: _title(
                        languageCode,
                        bn: 'যাকাত',
                        en: 'Zakat',
                        ar: 'الزكاة',
                      ),
                      icon: Icons.monetization_on_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ZakatCalculatorScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ==================================================
                // DAILY CONTENT
                // ==================================================
                const DailyContentSection(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
