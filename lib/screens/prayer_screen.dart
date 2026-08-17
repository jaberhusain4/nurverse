import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String _label(String languageCode, String bn, String en, String ar) {
    if (languageCode == 'en') return en;
    if (languageCode == 'ar') return ar;
    return bn;
  }

  String _prayerName(AppLocalizations l10n, String value, String languageCode) {
    const names = <String, List<String>>{
      'Fajr': ['ফজর', 'Fajr', 'الفجر'],
      'Dhuhr': ['যোহর', 'Dhuhr', 'الظهر'],
      'Jumuah': ['জুমু‘আ', 'Jumu’ah', 'الجمعة'],
      'Asr': ['আসর', 'Asr', 'العصر'],
      'Maghrib': ['মাগরিব', 'Maghrib', 'المغرب'],
      'Isha': ['ইশা', 'Isha', 'العشاء'],
      'Ishraq': ['ইশরাক', 'Ishraq', 'الإشراق'],
      'Duha': ['চাশত / দুহা', 'Duha', 'الضحى'],
      'Awwabin': ['আউওয়াবীন', 'Awwabin', 'الأوابين'],
      'Tahajjud': ['তাহাজ্জুদ', 'Tahajjud', 'التهجد'],
    };
    final entry = names[value];
    if (entry != null) return _label(languageCode, entry[0], entry[1], entry[2]);
    for (final item in names.values) {
      if (item.contains(value)) return _label(languageCode, item[0], item[1], item[2]);
    }
    return l10n.tr(value, value);
  }

  String _status(AppLocalizations l10n, String value, String languageCode) {
    const translations = <String, List<String>>{
      'ফজরের সময় শুরু হতে চলেছে': ['ফজরের সময় শুরু হতে চলেছে', 'Fajr time is about to begin', 'سيبدأ وقت الفجر قريبًا'],
      'ফজরের ওয়াক্ত চলছে': ['ফজরের ওয়াক্ত চলছে', 'Fajr time is active', 'وقت الفجر جارٍ'],
      'পরবর্তী সালাত: জুমু‘আ': ['পরবর্তী সালাত: জুমু‘আ', 'Next prayer: Jumu’ah', 'الصلاة التالية: الجمعة'],
      'পরবর্তী সালাত: যোহর': ['পরবর্তী সালাত: যোহর', 'Next prayer: Dhuhr', 'الصلاة التالية: الظهر'],
      'জুমু‘আর ওয়াক্ত চলছে': ['জুমু‘আর ওয়াক্ত চলছে', 'Jumu’ah time is active', 'وقت الجمعة جارٍ'],
      'যোহরের ওয়াক্ত চলছে': ['যোহরের ওয়াক্ত চলছে', 'Dhuhr time is active', 'وقت الظهر جارٍ'],
      'আসরের ওয়াক্ত চলছে': ['আসরের ওয়াক্ত চলছে', 'Asr time is active', 'وقت العصر جارٍ'],
      'মাগরিবের ওয়াক্ত চলছে': ['মাগরিবের ওয়াক্ত চলছে', 'Maghrib time is active', 'وقت المغرب جارٍ'],
      'ইশার ওয়াক্ত চলছে': ['ইশার ওয়াক্ত চলছে', 'Isha time is active', 'وقت العشاء جارٍ'],
    };
    final entry = translations[value];
    if (entry == null) return l10n.tr(value, value);
    return _label(languageCode, entry[0], entry[1], entry[2]);
  }

  String _greeting(String languageCode) {
    final hour = DateTime.now().hour;
    if (languageCode == 'en') return hour < 12 ? 'Good Morning' : hour < 18 ? 'Good Afternoon' : 'Good Evening';
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
    if (!mounted || _currentTime == value) return;
    setState(() => _currentTime = value);
  }

  String _hijriDate(String languageCode) {
    try {
      final h = HijriCalendar.now();
      const bn = ['মুহররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি', 'জুমাদিউল আউয়াল', 'জুমাদিউস সানি', 'রজব', 'শাবান', 'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ'];
      const en = ['Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', 'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha’ban', 'Ramadan', 'Shawwal', 'Dhul-Qadah', 'Dhul-Hijjah'];
      const ar = ['محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'];
      final i = (h.hMonth - 1).clamp(0, 11);
      if (languageCode == 'en') return '${h.hDay} ${en[i]} ${h.hYear} AH';
      if (languageCode == 'ar') return '${h.hDay} ${ar[i]} ${h.hYear} هـ';
      return '${h.hDay} ${bn[i]} ${h.hYear} হিজরি';
    } catch (_) {
      return _label(languageCode, 'হিজরি তারিখ পাওয়া যায়নি', 'Hijri date unavailable', 'التاريخ الهجري غير متاح');
    }
  }

  String _banglaDate() {
    final now = DateTime.now();
    final year = now.year;
    final starts = <DateTime>[
      DateTime(year, 4, 14), DateTime(year, 5, 15), DateTime(year, 6, 15), DateTime(year, 7, 16),
      DateTime(year, 8, 16), DateTime(year, 9, 16), DateTime(year, 10, 16), DateTime(year, 11, 15),
      DateTime(year, 12, 15), DateTime(year + 1, 1, 15), DateTime(year + 1, 2, 13), DateTime(year + 1, 3, 15),
    ];
    const months = ['বৈশাখ', 'জ্যৈষ্ঠ', 'আষাঢ়', 'শ্রাবণ', 'ভাদ্র', 'আশ্বিন', 'কার্তিক', 'অগ্রহায়ণ', 'পৌষ', 'মাঘ', 'ফাল্গুন', 'চৈত্র'];
    var index = -1;
    for (var i = 0; i < starts.length; i++) {
      if (!now.isBefore(starts[i])) index = i;
    }
    if (index < 0) index = 11;
    final banglaYear = now.month > 4 || (now.month == 4 && now.day >= 14) ? year - 593 : year - 594;
    return '${now.difference(starts[index]).inDays + 1} ${months[index]} $banglaYear';
  }

  SunTimeInfo? _sunTimes(PrayerController controller) {
    final position = controller.position;
    if (position == null) return null;
    final now = DateTime.now();
    final sameDay = _sunDate?.year == now.year && _sunDate?.month == now.month && _sunDate?.day == now.day;
    final sameLocation = _sunLatitude == position.latitude && _sunLongitude == position.longitude;
    if (_sunTimeInfo == null || !sameDay || !sameLocation) {
      _sunLatitude = position.latitude;
      _sunLongitude = position.longitude;
      _sunDate = now;
      _sunTimeInfo = const SunTimeService().getSunTimes(position, date: null, method: controller.calculationMethod, madhab: controller.madhhab);
    }
    return _sunTimeInfo;
  }

  String _currentJamaatKey(String prayer) {
    switch (prayer) {
      case 'ফজর': case 'Fajr': return 'Fajr';
      case 'যোহর': case "জুমু'আ": case 'জুমু‘আ': case 'Dhuhr': case 'Jumuah': return 'Dhuhr';
      case 'আসর': case 'Asr': return 'Asr';
      case 'মাগরিব': case 'Maghrib': return 'Maghrib';
      case 'ইশা': case 'Isha': return 'Isha';
      default: return '';
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
    final currentPrayer = _prayerName(l10n, controller.currentPrayer, languageCode);
    final previousPrayer = _prayerName(l10n, controller.previousPrayer, languageCode);
    final nextPrayer = _prayerName(l10n, controller.nextPrayer.isEmpty ? controller.nextPrayerName : controller.nextPrayer, languageCode);

    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        const Positioned.fill(child: IslamicOrnamentalBackground()),
        SafeArea(child: RefreshIndicator(
          onRefresh: controller.refreshPrayerTimes,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TopHeader(greeting: _greeting(languageCode), currentTime: _currentTime, onNotificationTap: () {}, onProfileTap: () {}),
              const SizedBox(height: 14),
              CurrentPrayerPremiumCard(previousPrayer: previousPrayer, previousPrayerTime: controller.previousPrayerTime, currentPrayer: currentPrayer, currentPrayerTime: controller.currentPrayerTime, nextPrayer: nextPrayer, nextPrayerTime: controller.nextPrayerTime, remainingTime: controller.timeRemainingForNextPrayer, progress: controller.prayerProgress, iqamahTime: currentJamaat, status: _status(l10n, controller.prayerStatus, languageCode), languageCode: languageCode, onJamaatTap: _openJamaatSettings),
              const SizedBox(height: 10),
              PrayerTimelineCard(prayers: controller.prayers.where((p) => p['category'] == 'obligatory').toList(growable: false), languageCode: languageCode),
              const SizedBox(height: 10),
              IslamicInfoCard(location: controller.currentLocationName, englishDate: DateService.englishDate(), banglaDate: _banglaDate(), hijriDate: _hijriDate(languageCode), sunrise: sunTimes?.sunriseString ?? controller.sunriseTime, sunset: sunTimes?.sunsetString ?? controller.sunsetTime, languageCode: languageCode, onRefresh: controller.refreshLocation, compactLocation: true),
              const SizedBox(height: 16),
              _sectionHeader(context, primary, Icons.mosque_outlined, l10n.todaysPrayer),
              const SizedBox(height: 9),
              _prayerSchedule(context, l10n, controller, primary, languageCode),
              const SizedBox(height: 16),
              _sectionHeader(context, primary, Icons.wb_sunny_outlined, l10n.importantTimes),
              const SizedBox(height: 9),
              _importantTimes(context, l10n, controller, primary, sunTimes),
              const SizedBox(height: 16),
              _sectionHeader(context, primary, Icons.nightlight_round, l10n.naflAndOtherPrayers),
              const SizedBox(height: 9),
              _naflTimes(context, controller, primary, languageCode),
              const SizedBox(height: 16),
              _sectionHeader(context, primary, Icons.check_circle_outline_rounded, l10n.prayerTracker),
              const SizedBox(height: 9),
              _trackerCard(languageCode),
              const SizedBox(height: 12),
              Text(l10n.prayerTimeNote, maxLines: 3, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: .62), fontSize: 11.5, height: 1.35)),
            ]),
          ),
        )),
      ]),
    );
  }

  Widget _sectionHeader(BuildContext context, Color primary, IconData icon, String title) {
    final theme = Theme.of(context);
    return Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: primary.withValues(alpha: .09), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: primary, size: 19)),
      const SizedBox(width: 9),
      Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontSize: 15, fontWeight: FontWeight.w800, height: 1.2))),
    ]);
  }

  Widget _card(BuildContext context, Color primary, {required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(14)}) {
    final theme = Theme.of(context);
    return Container(width: double.infinity, padding: padding, decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: primary.withValues(alpha: .055))), child: child);
  }

  Widget _prayerSchedule(BuildContext context, AppLocalizations l10n, PrayerController controller, Color primary, String languageCode) {
    final theme = Theme.of(context);
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color?.withValues(alpha: .68) ?? theme.colorScheme.onSurface.withValues(alpha: .68);
    final items = controller.prayers.where((p) => p['category'] == 'obligatory').toList(growable: false);
    return _card(context, primary, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), child: Column(children: [
      for (var i = 0; i < items.length; i++) _prayerRow(context, l10n, items[i], primary, text, secondary, languageCode, i < items.length - 1),
    ]));
  }

  Widget _prayerRow(BuildContext context, AppLocalizations l10n, Map<String, dynamic> data, Color primary, Color text, Color secondary, String languageCode, bool divider) {
    final current = data['isCurrent'] == true;
    final name = _prayerName(l10n, data['name']?.toString() ?? '', languageCode);
    final start = data['start']?.toString() ?? '--:--';
    final end = data['end']?.toString() ?? '--:--';
    final jamaat = data['jamaat']?.toString() ?? '--:--';
    final icon = _prayerIcon(data['name']?.toString() ?? '');
    return Column(children: [
      Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: current ? primary.withValues(alpha: .11) : primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: current ? primary : secondary, size: 21)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: current ? primary : text, fontSize: 14, fontWeight: FontWeight.w800, height: 1.15)),
          const SizedBox(height: 5),
          Row(children: [Icon(Icons.play_arrow_rounded, size: 16, color: secondary), const SizedBox(width: 3), Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(start, maxLines: 1, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w700)))), const SizedBox(width: 9), Icon(Icons.stop_rounded, size: 16, color: secondary), const SizedBox(width: 3), Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(end, maxLines: 1, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w700))))]),
        ])),
        const SizedBox(width: 8),
        ConstrainedBox(constraints: const BoxConstraints(minWidth: 76, maxWidth: 98), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.groups_rounded, size: 18, color: primary), const SizedBox(width: 4), Flexible(child: Text(l10n.jamaat, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 11, fontWeight: FontWeight.w700)))]),
          const SizedBox(height: 3),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(jamaat, maxLines: 1, style: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w800))),
        ])),
      ])),
      if (divider) Divider(height: 1, color: primary.withValues(alpha: .05)),
    ]);
  }

  Widget _importantTimes(BuildContext context, AppLocalizations l10n, PrayerController controller, Color primary, SunTimeInfo? sunTimes) {
    return Row(children: [
      Expanded(child: _infoMiniCard(context, Icons.wb_sunny_outlined, l10n.sunrise, sunTimes?.sunriseString ?? controller.sunriseTime, primary)),
      const SizedBox(width: 7),
      Expanded(child: _infoMiniCard(context, Icons.brightness_5_outlined, l10n.solarNoon, controller.solarNoonTime, primary)),
      const SizedBox(width: 7),
      Expanded(child: _infoMiniCard(context, Icons.nights_stay_outlined, l10n.sunset, sunTimes?.sunsetString ?? controller.sunsetTime, primary)),
    ]);
  }

  Widget _infoMiniCard(BuildContext context, IconData icon, String title, String value, Color primary) {
    final theme = Theme.of(context);
    final text = theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurface;
    return _card(context, primary, padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12), child: Column(children: [
      Icon(icon, size: 22, color: primary),
      const SizedBox(height: 6),
      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: text.withValues(alpha: .78), fontSize: 12, fontWeight: FontWeight.w600, height: 1.1)),
      const SizedBox(height: 4),
      SizedBox(width: double.infinity, child: FittedBox(fit: BoxFit.scaleDown, child: Text(value, maxLines: 1, style: TextStyle(color: text, fontSize: 13.5, fontWeight: FontWeight.w800, height: 1.1)))),
    ]));
  }

  Widget _naflTimes(BuildContext context, PrayerController controller, Color primary, String languageCode) {
    final theme = Theme.of(context);
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color?.withValues(alpha: .68) ?? theme.colorScheme.onSurface.withValues(alpha: .68);
    final nafl = controller.prayers.where((p) => p['category'] == 'nafl').toList(growable: false);
    return _card(context, primary, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), child: Column(children: [
      for (var i = 0; i < nafl.length; i++) ...[
        Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(12)), child: Icon(_prayerIcon(nafl[i]['name']?.toString() ?? ''), size: 21, color: primary)),
          const SizedBox(width: 10),
          Expanded(child: Text(_prayerName(AppLocalizations.of(context), nafl[i]['name']?.toString() ?? '', languageCode), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w800, height: 1.15))),
          const SizedBox(width: 8),
          Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text('${nafl[i]['start'] ?? '--:--'} – ${nafl[i]['end'] ?? '--:--'}', maxLines: 1, style: TextStyle(color: primary, fontSize: 12.5, fontWeight: FontWeight.w800, height: 1.1)))),
        ])),
        if (i < nafl.length - 1) Divider(height: 1, color: secondary.withValues(alpha: .10)),
      ],
    ]));
  }

  Widget _trackerCard(String languageCode) => _DailyPrayerTrackerCard(languageCode: languageCode);

  IconData _prayerIcon(String value) {
    switch (value.toLowerCase()) {
      case 'fajr': case 'ফজর': return Icons.wb_twilight_outlined;
      case 'dhuhr': case 'jumuah': case 'যোহর': case 'জুমু‘আ': return Icons.wb_sunny_outlined;
      case 'asr': case 'আসর': return Icons.light_mode_outlined;
      case 'maghrib': case 'মাগরিব': return Icons.wb_twilight_rounded;
      case 'isha': case 'ইশা': return Icons.nights_stay_outlined;
      case 'ishraq': case 'ইশরাক': return Icons.wb_sunny_outlined;
      case 'duha': case 'দুহা': return Icons.wb_twilight_outlined;
      case 'awwabin': case 'আউওয়াবীন': return Icons.nightlight_outlined;
      case 'tahajjud': case 'তাহাজ্জুদ': return Icons.bedtime_outlined;
      default: return Icons.mosque_outlined;
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }
}

class _DailyPrayerTrackerCard extends StatefulWidget {
  final String languageCode;
  const _DailyPrayerTrackerCard({required this.languageCode});
  @override
  State<_DailyPrayerTrackerCard> createState() => _DailyPrayerTrackerCardState();
}

class _DailyPrayerTrackerCardState extends State<_DailyPrayerTrackerCard> {
  static const _prayers = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  Map<String, bool> _today = <String, bool>{};
  Map<String, bool> _yesterday = <String, bool>{};
  String _dateKey = '';
  bool _loading = true;

  String _key(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  String _label(String bn, String en, String ar) => widget.languageCode == 'en' ? en : widget.languageCode == 'ar' ? ar : bn;
  String _name(String key) {
    const bn = ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'ইশা'];
    const en = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    const ar = ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'];
    final i = _prayers.indexOf(key);
    return _label(bn[i], en[i], ar[i]);
  }
  String _dateText(DateTime date) {
    final locale = widget.languageCode == 'bn' ? 'bn_BD' : widget.languageCode == 'ar' ? 'ar' : 'en_US';
    return DateFormat('d MMM yyyy', locale).format(date);
  }
  Future<Map<String, bool>> _readDay(SharedPreferences prefs, String key) async {
    final result = <String, bool>{};
    for (final prayer in _prayers) {
      result[prayer] = prefs.getBool('nurverse_tracker_${key}_$prayer') ?? false;
    }
    return result;
  }
  Future<void> _load() async {
    final now = DateTime.now();
    final todayKey = _key(now);
    final yesterdayKey = _key(now.subtract(const Duration(days: 1)));
    final prefs = await SharedPreferences.getInstance();
    final today = await _readDay(prefs, todayKey);
    final yesterday = await _readDay(prefs, yesterdayKey);
    if (!mounted) return;
    setState(() { _dateKey = todayKey; _today = today; _yesterday = yesterday; _loading = false; });
  }
  Future<void> _toggle(String prayer) async {
    final next = !(_today[prayer] ?? false);
    setState(() => _today = {..._today, prayer: next});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nurverse_tracker_${_dateKey}_$prayer', next);
  }
  @override
  void initState() { super.initState(); _load(); }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color?.withValues(alpha: .72) ?? theme.colorScheme.onSurface.withValues(alpha: .72);
    final now = DateTime.now();
    final todayCount = _today.values.where((v) => v).length;
    final yesterdayCount = _yesterday.values.where((v) => v).length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 13, 12, 12),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: primary.withValues(alpha: .055))),
      child: Column(children: [
        Row(children: [
          Icon(Icons.check_circle_outline_rounded, size: 20, color: primary),
          const SizedBox(width: 9),
          Expanded(child: Text(_label('সালাত ট্র্যাকার', 'Prayer tracker', 'متابعة الصلاة'), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.w800))),
          Text('$todayCount/5', style: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 5),
        Align(alignment: Alignment.centerLeft, child: Text(_loading ? _label('লোড হচ্ছে...', 'Loading...', 'جار التحميل...') : '${_dateText(now)} • ${_label('আজ', 'Today', 'اليوم')}', style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w600))),
        const SizedBox(height: 10),
        Row(children: [
          for (var i = 0; i < _prayers.length; i++) ...[
            Expanded(child: InkWell(onTap: _loading ? null : () => _toggle(_prayers[i]), borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2), child: Column(children: [
              Icon((_today[_prayers[i]] ?? false) ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: (_today[_prayers[i]] ?? false) ? primary : secondary.withValues(alpha: .65), size: 23),
              const SizedBox(height: 4),
              FittedBox(fit: BoxFit.scaleDown, child: Text(_name(_prayers[i]), maxLines: 1, style: TextStyle(color: text, fontSize: 11.5, fontWeight: FontWeight.w700))),
            ])))),
            if (i < _prayers.length - 1) const SizedBox(width: 3),
          ],
        ]),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: primary.withValues(alpha: .035), borderRadius: BorderRadius.circular(13)), child: Row(children: [
          Expanded(child: Text('${_label('আজ', 'Today', 'اليوم')}: $todayCount/5', style: TextStyle(color: text, fontSize: 11.5, fontWeight: FontWeight.w700))),
          Expanded(child: Text('${_label('গতকাল', 'Yesterday', 'أمس')}: $yesterdayCount/5', textAlign: TextAlign.right, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w700))),
        ])),
        const SizedBox(height: 5),
        Align(alignment: Alignment.centerLeft, child: Text('${_dateText(now.subtract(const Duration(days: 1)))} • ${yesterdayCount == 5 ? _label('সব ৫ ওয়াক্ত আদায় হয়েছে', 'All 5 prayers completed', 'أُديت الصلوات الخمس') : _label('$yesterdayCount ওয়াক্ত আদায় হয়েছে', '$yesterdayCount prayers completed', 'تم أداء $yesterdayCount صلوات')}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 10.5, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}
