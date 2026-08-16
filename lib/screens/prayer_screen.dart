import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../localization/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../services/date_service.dart';
import '../services/jamaat_service.dart';
import '../services/sun_time_service.dart';
import '../widgets/common/current_prayer_premium_card.dart';
import '../widgets/home/islamic_info_card.dart';
import '../widgets/home/islamic_ornamental_background.dart';
import '../widgets/home/prayer_timeline_card.dart';
import '../widgets/home/top_header.dart';
import 'prayer/jamaat_settings_screen.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  Timer? _clockTimer;
  String _currentTime = '';

  double? _sunLatitude;
  double? _sunLongitude;
  DateTime? _sunDate;
  SunTimeInfo? _sunTimeInfo;

  final Map<String, bool> _tracker = {
    'Fajr': false,
    'Dhuhr': false,
    'Asr': false,
    'Maghrib': false,
    'Isha': false,
  };

  String _prayerName(AppLocalizations l10n, String value) {
    const names = {
      'Fajr': 'ফজর',
      'Dhuhr': 'যোহর',
      'Jumuah': 'জুমু‘আ',
      'Asr': 'আসর',
      'Maghrib': 'মাগরিব',
      'Isha': 'ইশা',
      'Ishraq': 'ইশরাক',
      'Duha': 'চাশত / দুহা',
      'Awwabin': 'আউওয়াবীন',
      'Tahajjud': 'তাহাজ্জুদ',
    };
    return names.containsKey(value) ? l10n.tr(names[value]!, value) : value;
  }

  String _status(AppLocalizations l10n, String value) {
    if (value.isEmpty) return value;
    const translations = {
      'ফজরের সময় শুরু হতে চলেছে': 'Fajr time is about to begin',
      'ফজরের ওয়াক্ত চলছে': 'Fajr time is active',
      'পরবর্তী সালাত: জুমু‘আ': 'Next prayer: Jumu’ah',
      'পরবর্তী সালাত: যোহর': 'Next prayer: Dhuhr',
      'জুমু‘আর ওয়াক্ত চলছে': 'Jumu’ah time is active',
      'যোহরের ওয়াক্ত চলছে': 'Dhuhr time is active',
      'আসরের ওয়াক্ত চলছে': 'Asr time is active',
      'মাগরিবের ওয়াক্ত চলছে': 'Maghrib time is active',
      'ইশার ওয়াক্ত চলছে': 'Isha time is active',
    };
    return translations.containsKey(value) ? l10n.tr(value, translations[value]!) : value;
  }

  String _greeting(String languageCode) {
    final hour = DateTime.now().hour;
    if (languageCode == 'en') {
      if (hour < 12) return 'Good Morning';
      if (hour < 18) return 'Good Afternoon';
      return 'Good Evening';
    }
    if (languageCode == 'ar') return hour < 12 ? 'صباح الخير' : 'مساء الخير';
    if (hour < 12) return 'শুভ সকাল';
    if (hour < 15) return 'শুভ দুপুর';
    if (hour < 18) return 'শুভ বিকেল';
    return 'শুভ সন্ধ্যা';
  }

  void _updateClock() {
    final now = DateTime.now();
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final value = '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $period';
    if (_currentTime == value || !mounted) return;
    setState(() => _currentTime = value);
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
      const bnDigits = <String>['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
      String toBnDigits(int value) => value.toString().split('').map((d) => bnDigits[int.parse(d)]).join();
      final index = (h.hMonth - 1).clamp(0, 11);

      if (languageCode == 'en') return '${h.hDay} ${enMonths[index]} ${h.hYear} AH';
      if (languageCode == 'ar') return '${h.hDay} ${arMonths[index]} ${h.hYear} هـ';
      return '${toBnDigits(h.hDay)} ${bnMonths[index]} ${toBnDigits(h.hYear)} হিজরি';
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
    final sameDay = _sunDate != null && _sunDate!.year == now.year && _sunDate!.month == now.month && _sunDate!.day == now.day;
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
      case 'জুমু‘আ':
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

  Future<void> _openJamaatSettings() async {
    final controller = context.read<PrayerController>();
    JamaatService.configureDefaultsFromPrayerList(controller.prayers);
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const JamaatSettingsScreen()));
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final controller = context.watch<PrayerController>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
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
              onRefresh: controller.refreshPrayerTimes,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                children: [
                  TopHeader(
                    greeting: _greeting(languageCode),
                    currentTime: _currentTime,
                    onNotificationTap: () {},
                    onProfileTap: () {},
                  ),
                  const SizedBox(height: 12),
                  CurrentPrayerPremiumCard(
                    previousPrayer: controller.previousPrayer,
                    previousPrayerTime: controller.previousPrayerTime,
                    currentPrayer: controller.currentPrayer,
                    currentPrayerTime: controller.currentPrayerTime,
                    nextPrayer: controller.nextPrayer,
                    nextPrayerTime: controller.nextPrayerTime,
                    remainingTime: controller.timeRemainingForNextPrayer,
                    progress: controller.prayerProgress,
                    iqamahTime: currentJamaat,
                    status: _status(l10n, controller.prayerStatus),
                    languageCode: languageCode,
                    onJamaatTap: _openJamaatSettings,
                  ),
                  const SizedBox(height: 9),
                  PrayerTimelineCard(prayers: controller.prayers, languageCode: languageCode),
                  const SizedBox(height: 9),
                  IslamicInfoCard(
                    location: controller.currentLocationName,
                    englishDate: DateService.englishDate(),
                    banglaDate: _banglaDate(),
                    hijriDate: _hijriDate(languageCode),
                    sunrise: sunTimes?.sunriseString ?? controller.sunriseTime,
                    sunset: sunTimes?.sunsetString ?? controller.sunsetTime,
                    languageCode: languageCode,
                    onRefresh: controller.refreshLocation,
                  ),
                  const SizedBox(height: 13),
                  _sectionHeader(context, l10n, Icons.mosque_outlined, l10n.todaysPrayer),
                  const SizedBox(height: 7),
                  _prayerSchedule(context, l10n, controller, primary),
                  const SizedBox(height: 13),
                  _sectionHeader(context, l10n, Icons.wb_sunny_outlined, l10n.importantTimes),
                  const SizedBox(height: 7),
                  _importantTimes(context, l10n, controller, primary, sunTimes),
                  const SizedBox(height: 13),
                  _sectionHeader(context, l10n, Icons.nightlight_round, l10n.naflAndOtherPrayers),
                  const SizedBox(height: 7),
                  _naflTimes(context, l10n, controller, primary),
                  const SizedBox(height: 13),
                  _sectionHeader(context, l10n, Icons.check_circle_outline_rounded, l10n.prayerTracker),
                  const SizedBox(height: 7),
                  _trackerCard(context, l10n, primary),
                  const SizedBox(height: 10),
                  Text(
                    l10n.prayerTimeNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: .62),
                      fontSize: 10.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, AppLocalizations l10n, IconData icon, String title) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      children: [
        Icon(icon, color: primary, size: 17),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _prayerSchedule(BuildContext context, AppLocalizations l10n, PrayerController controller, Color primary) {
    final theme = Theme.of(context);
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color?.withValues(alpha: .68) ?? theme.colorScheme.onSurface.withValues(alpha: .68);
    final items = controller.prayers.where((p) => p['category'] == 'obligatory').toList();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: .055)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            _prayerRow(context, l10n, items[i], primary, text, secondary, i != items.length - 1),
        ],
      ),
    );
  }

  Widget _prayerRow(BuildContext context, AppLocalizations l10n, Map<String, dynamic> data, Color primary, Color text, Color secondary, bool divider) {
    final current = data['isCurrent'] == true;
    final name = _prayerName(l10n, data['name']?.toString() ?? '');
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: current ? primary.withValues(alpha: .12) : primary.withValues(alpha: .05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  current ? Icons.mosque_rounded : Icons.access_time_rounded,
                  color: current ? primary : secondary,
                  size: 17,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: current ? primary : text, fontSize: 12, fontWeight: FontWeight.w800, height: 1.1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data['start']?.toString() ?? '--:--',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: secondary, fontSize: 9.5, fontWeight: FontWeight.w600, height: 1.1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.jamaat, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 8.5, height: 1.1)),
                  const SizedBox(height: 1),
                  Text(data['jamaat']?.toString() ?? '--:--', maxLines: 1, style: TextStyle(color: primary, fontSize: 10.5, fontWeight: FontWeight.w800, height: 1.1)),
                ],
              ),
            ],
          ),
        ),
        if (divider) Divider(height: 1, color: primary.withValues(alpha: .05)),
      ],
    );
  }

  Widget _importantTimes(BuildContext context, AppLocalizations l10n, PrayerController controller, Color primary, SunTimeInfo? sunTimes) {
    return Row(
      children: [
        Expanded(child: _infoMiniCard(context, Icons.wb_sunny_outlined, l10n.sunrise, sunTimes?.sunriseString ?? controller.sunriseTime, primary)),
        const SizedBox(width: 7),
        Expanded(child: _infoMiniCard(context, Icons.brightness_5_outlined, l10n.solarNoon, controller.solarNoonTime, primary)),
        const SizedBox(width: 7),
        Expanded(child: _infoMiniCard(context, Icons.nights_stay_outlined, l10n.sunset, sunTimes?.sunsetString ?? controller.sunsetTime, primary)),
      ],
    );
  }

  Widget _infoMiniCard(BuildContext context, IconData icon, String title, String value, Color primary) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primary.withValues(alpha: .05)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: primary),
          const SizedBox(height: 4),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontSize: 8.5, fontWeight: FontWeight.w600, height: 1.1)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, maxLines: 1, style: theme.textTheme.bodySmall?.copyWith(fontSize: 9.5, fontWeight: FontWeight.w800, height: 1.1)),
          ),
        ],
      ),
    );
  }

  Widget _naflTimes(BuildContext context, AppLocalizations l10n, PrayerController controller, Color primary) {
    final theme = Theme.of(context);
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final nafl = controller.prayers.where((p) => p['category'] == 'nafl').toList();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: .055)),
      ),
      child: Column(
        children: [
          for (final item in nafl)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _prayerName(l10n, item['name']?.toString() ?? ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.w700, height: 1.1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${item['start'] ?? '--:--'}  –  ${item['end'] ?? '--:--'}',
                      maxLines: 1,
                      style: TextStyle(color: primary, fontSize: 9.5, fontWeight: FontWeight.w700, height: 1.1),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _trackerCard(BuildContext context, AppLocalizations l10n, Color primary) {
    final theme = Theme.of(context);
    const names = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: .055)),
      ),
      child: Column(
        children: [
          Text(
            l10n.markPrayers,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 9.5, fontWeight: FontWeight.w600, height: 1.2),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final name in names)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tracker[name] = !(_tracker[name] ?? false)),
                    child: Column(
                      children: [
                        Icon(
                          (_tracker[name] ?? false) ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: (_tracker[name] ?? false) ? primary : theme.disabledColor,
                          size: 20,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _prayerName(AppLocalizations.of(context), name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, height: 1.1),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
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
