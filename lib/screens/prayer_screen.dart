import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/prayer_controller.dart';
import '../localization/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../services/jamaat_service.dart';
import '../theme/app_theme.dart';
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

  final Map<String, bool> _tracker = {
    'Fajr': false,
    'Dhuhr': false,
    'Asr': false,
    'Maghrib': false,
    'Isha': false,
  };

  String _prayerName(AppLocalizations l10n, String value) {
    const english = {
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
    return english.containsKey(value) ? l10n.tr(english[value]!, value) : value;
  }

  String _status(AppLocalizations l10n, String value) {
    if (value.isEmpty) return value;
    const english = {
      'ফজরের সময় শুরু হতে চলেছে': 'Fajr time is about to begin',
      'ফজরের ওয়াক্ত চলছে': 'Fajr time is active',
      'পরবর্তী সালাত: জুমু‘আ': 'Next prayer: Jumu’ah',
      'পরবর্তী সালাত: যোহর': 'Next prayer: Dhuhr',
      'জুমু‘আর ওয়াক্ত চলছে': 'Jumu’ah time is active',
      'যোহরের ওয়াক্ত চলছে': 'Dhuhr time is active',
      'আসরের ওয়াক্ত চলছে': 'Asr time is active',
      'মাগরিবের ওয়াক্ত চলছে': 'Maghrib time is active',
      'ইশার ওয়াক্ত চলছে': 'Isha time is active',
      'ইশার ওয়াক্ত চলছে': 'Isha time is active',
    };
    return english.containsKey(value) ? l10n.tr(value, english[value]!) : value;
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

  String _englishDate() => DateFormat('EEEE, d MMMM yyyy', 'en').format(DateTime.now());

  String _banglaDate() {
    try {
      final now = DateTime.now();
      const weekdays = ['সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার', 'রবিবার'];
      const months = ['জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'];
      return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
    } catch (_) {
      return '';
    }
  }

  String _hijriDate(AppLocalizations l10n) {
    try {
      final h = HijriCalendar.now();
      const bn = ['মুহররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি', 'জুমাদিউল আউয়াল', 'জুমাদিউস সানি', 'রজব', 'শাবান', 'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ'];
      const en = ['Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', 'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha’ban', 'Ramadan', 'Shawwal', 'Dhul-Qadah', 'Dhul-Hijjah'];
      const ar = ['محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'];
      final i = (h.hMonth - 1).clamp(0, 11);
      if (l10n.isBangla) return '${h.hDay} ${bn[i]} ${h.hYear} হিজরি';
      if (l10n.locale.languageCode == 'ar') return '${h.hDay} ${ar[i]} ${h.hYear} هـ';
      return '${h.hDay} ${en[i]} ${h.hYear} AH';
    } catch (_) {
      return l10n.tr('হিজরি তারিখ পাওয়া যায়নি', 'Hijri date unavailable');
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

    JamaatService.configureDefaultsFromPrayerList(controller.prayers);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const IslamicOrnamentalBackground(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: controller.refreshPrayerTimes,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                children: [
                  TopHeader(greeting: _greeting(languageCode), currentTime: _currentTime),
                  const SizedBox(height: 14),
                  CurrentPrayerPremiumCard(
                    previousPrayer: _prayerName(l10n, controller.previousPrayer),
                    previousPrayerTime: controller.previousPrayerTime,
                    currentPrayer: _prayerName(l10n, controller.currentPrayer),
                    currentPrayerTime: controller.currentPrayerTime,
                    nextPrayer: _prayerName(l10n, controller.nextPrayerName),
                    nextPrayerTime: controller.nextPrayerTime,
                    remainingTime: controller.timeRemainingForNextPrayer,
                    progress: controller.prayerProgress,
                    iqamahTime: controller.currentIqamahTime,
                    status: _status(l10n, controller.prayerStatus),
                    languageCode: languageCode,
                    onJamaatTap: _openJamaatSettings,
                  ),
                  const SizedBox(height: 10),
                  PrayerTimelineCard(prayers: controller.prayers, languageCode: languageCode),
                  const SizedBox(height: 10),
                  IslamicInfoCard(
                    location: controller.currentLocationName,
                    englishDate: _englishDate(),
                    banglaDate: _banglaDate(),
                    hijriDate: _hijriDate(l10n),
                    sunrise: controller.sunriseTime,
                    sunset: controller.sunsetTime,
                    languageCode: languageCode,
                    onRefresh: controller.refreshLocation,
                  ),
                  const SizedBox(height: 16),
                  _sectionHeader(context, l10n, Icons.mosque_outlined, l10n.todaysPrayer),
                  const SizedBox(height: 8),
                  _prayerSchedule(context, l10n, controller, primary),
                  const SizedBox(height: 16),
                  _sectionHeader(context, l10n, Icons.wb_sunny_outlined, l10n.importantTimes),
                  const SizedBox(height: 8),
                  _importantTimes(context, l10n, controller, primary),
                  const SizedBox(height: 16),
                  _sectionHeader(context, l10n, Icons.nightlight_round, l10n.naflAndOtherPrayers),
                  const SizedBox(height: 8),
                  _naflTimes(context, l10n, controller, primary),
                  const SizedBox(height: 16),
                  _sectionHeader(context, l10n, Icons.check_circle_outline_rounded, l10n.prayerTracker),
                  const SizedBox(height: 8),
                  _trackerCard(context, l10n, controller, primary),
                  const SizedBox(height: 12),
                  Text(l10n.prayerTimeNote, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: .62), height: 1.45)),
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
    return Row(children: [Icon(icon, color: primary, size: 18), const SizedBox(width: 8), Expanded(child: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontSize: 16, fontWeight: FontWeight.w700)))]);
  }

  Widget _prayerSchedule(BuildContext context, AppLocalizations l10n, PrayerController controller, Color primary) {
    final theme = Theme.of(context);
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color?.withValues(alpha: .68) ?? theme.colorScheme.onSurface.withValues(alpha: .68);
    final items = controller.prayers.where((p) => p['category'] == 'obligatory').toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: primary.withValues(alpha: .055))),
      child: Column(children: [for (var i = 0; i < items.length; i++) _prayerRow(context, l10n, items[i], primary, text, secondary, i != items.length - 1)]),
    );
  }

  Widget _prayerRow(BuildContext context, AppLocalizations l10n, Map<String, dynamic> data, Color primary, Color text, Color secondary, bool divider) {
    final current = data['isCurrent'] == true;
    final name = _prayerName(l10n, data['name']?.toString() ?? '');
    return Column(children: [
      Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: current ? primary.withValues(alpha: .12) : primary.withValues(alpha: .05), borderRadius: BorderRadius.circular(11)), child: Icon(current ? Icons.mosque_rounded : Icons.access_time_rounded, color: current ? primary : secondary, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(color: current ? primary : text, fontSize: 13, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(data['start']?.toString() ?? '--:--', style: TextStyle(color: secondary, fontSize: 10.5, fontWeight: FontWeight.w600))])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(l10n.jamaat, style: TextStyle(color: secondary, fontSize: 9)), Text(data['jamaat']?.toString() ?? '--:--', style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.w800))]),
      ])),
      if (divider) Divider(height: 1, color: primary.withValues(alpha: .05)),
    ]);
  }

  Widget _importantTimes(BuildContext context, AppLocalizations l10n, PrayerController controller, Color primary) {
    return Row(children: [
      Expanded(child: _infoMiniCard(context, Icons.wb_sunny_outlined, l10n.sunrise, controller.sunriseTime, primary)),
      const SizedBox(width: 8),
      Expanded(child: _infoMiniCard(context, Icons.brightness_5_outlined, l10n.solarNoon, controller.solarNoonTime, primary)),
      const SizedBox(width: 8),
      Expanded(child: _infoMiniCard(context, Icons.nights_stay_outlined, l10n.sunset, controller.sunsetTime, primary)),
    ]);
  }

  Widget _infoMiniCard(BuildContext context, IconData icon, String title, String value, Color primary) {
    final theme = Theme.of(context);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11), decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: primary.withValues(alpha: .05))), child: Column(children: [Icon(icon, size: 17, color: primary), const SizedBox(height: 5), Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontSize: 9, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(value, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w800))]));
  }

  Widget _naflTimes(BuildContext context, AppLocalizations l10n, PrayerController controller, Color primary) {
    final theme = Theme.of(context);
    final nafl = controller.prayers.where((p) => p['category'] == 'nafl').toList();
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: primary.withValues(alpha: .055))), child: Column(children: [for (final item in nafl) Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Expanded(child: Text(_prayerName(l10n, item['name']?.toString() ?? ''), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), Text('${item['start'] ?? '--:--'}  –  ${item['end'] ?? '--:--'}', style: TextStyle(color: primary, fontSize: 10.5, fontWeight: FontWeight.w700))]))]));
  }

  Widget _trackerCard(BuildContext context, AppLocalizations l10n, PrayerController controller, Color primary) {
    final theme = Theme.of(context);
    final names = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: primary.withValues(alpha: .055))), child: Column(children: [Text(l10n.markPrayers, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5, fontWeight: FontWeight.w600)), const SizedBox(height: 9), Row(children: [for (final name in names) Expanded(child: GestureDetector(onTap: () => setState(() => _tracker[name] = !(_tracker[name] ?? false)), child: Column(children: [Icon((_tracker[name] ?? false) ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: (_tracker[name] ?? false) ? primary : theme.disabledColor, size: 22), const SizedBox(height: 4), Text(_prayerName(l10n, name), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700))])))]),]));
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }
}
