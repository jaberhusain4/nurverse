import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../localization/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/current_prayer_premium_card.dart';
import '../widgets/home/islamic_info_card.dart';
import '../widgets/home/islamic_ornamental_background.dart';
import '../widgets/home/prayer_timeline_card.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final Map<String, bool> _tracker = {
    'Fajr': false,
    'Dhuhr': false,
    'Asr': false,
    'Maghrib': false,
    'Isha': false,
  };

  String _prayerName(AppLocalizations l10n, String value) {
    switch (value.trim().toLowerCase()) {
      case 'fajr':
      case 'ফজর':
        return l10n.fajr;
      case 'dhuhr':
      case 'যোহর':
        return l10n.dhuhr;
      case 'asr':
      case 'আসর':
        return l10n.asr;
      case 'maghrib':
      case 'মাগরিব':
        return l10n.maghrib;
      case 'isha':
      case 'ইশা':
        return l10n.isha;
      case 'jumuah':
      case "জুমু'আ":
        return l10n.jumuah;
      default:
        return value;
    }
  }

  String _status(AppLocalizations l10n, String value) {
    const english = <String, String>{
      'ইশার ওয়াক্ত চলছে': 'Isha time is ongoing',
      'ফজরের সময় শুরু হতে চলেছে': 'Fajr time is about to begin',
      'ফজরের ওয়াক্ত চলছে': 'Fajr time is ongoing',
      'ফজরের ওয়াক্ত শেষ হয়েছে': 'Fajr time has ended',
      'ইশা শেষ হয়েছে': 'Isha has ended',
      'ফজর শেষ হয়েছে': 'Fajr has ended',
      "জুমু'আর ওয়াক্ত চলছে": 'Jumu’ah time is ongoing',
      'যোহরের ওয়াক্ত চলছে': 'Dhuhr time is ongoing',
      'আসরের ওয়াক্ত চলছে': 'Asr time is ongoing',
      'আসর শেষ হয়েছে': 'Asr has ended',
      'মাগরিবের ওয়াক্ত চলছে': 'Maghrib time is ongoing',
      'মাগরিব শেষ হয়েছে': 'Maghrib has ended',
      'সালাতের সময় গণনা করা হচ্ছে...': 'Calculating prayer times...',
    };
    return english.containsKey(value) ? l10n.tr(value, english[value]!) : value;
  }

  String _special(AppLocalizations l10n, String value) {
    const english = <String, String>{
      'সময় গণনা করা হচ্ছে...': 'Calculating time...',
      'আজ আর কোনো নিষিদ্ধ সময় নেই': 'No more prohibited time today',
      'সূর্যোদয়ের সময় — নামাজ আদায় থেকে বিরত থাকুন': 'Sunrise period — refrain from prayer',
      'জাওয়ালের সময় — নামাজ আদায় থেকে বিরত থাকুন': 'Zawal period — refrain from prayer',
      'সূর্যাস্তের সময় — নামাজ আদায় থেকে বিরত থাকুন': 'Sunset period — refrain from prayer',
      'পরবর্তী নিষিদ্ধ সময়: সূর্যোদয়': 'Next prohibited time: Sunrise',
      'পরবর্তী নিষিদ্ধ সময়: জাওয়াল': 'Next prohibited time: Zawal',
      'পরবর্তী নিষিদ্ধ সময়: সূর্যাস্ত': 'Next prohibited time: Sunset',
      'আজ আর কোনো বিশেষ মাকরূহ সময় নেই': 'No more special Makruh time today',
      'সূর্যোদয়ের আশেপাশের মাকরূহ সময়': 'Makruh period around sunrise',
      'জাওয়ালের আশেপাশের মাকরূহ সময়': 'Makruh period around Zawal',
      'সূর্যাস্তের আশেপাশের মাকরূহ সময়': 'Makruh period around sunset',
      'পরবর্তী মাকরূহ সময়: সূর্যোদয়': 'Next Makruh time: Sunrise',
      'পরবর্তী মাকরূহ সময়: জাওয়াল': 'Next Makruh time: Zawal',
      'পরবর্তী মাকরূহ সময়: সূর্যাস্ত': 'Next Makruh time: Sunset',
    };
    return english.containsKey(value) ? l10n.tr(value, english[value]!) : value;
  }

  String _englishDate() => DateFormat('EEEE, d MMMM yyyy', 'en').format(DateTime.now());

  String _banglaDate() {
    final now = DateTime.now();
    const months = ['বৈশাখ', 'জ্যৈষ্ঠ', 'আষাঢ়', 'শ্রাবণ', 'ভাদ্র', 'আশ্বিন', 'কার্তিক', 'অগ্রহায়ণ', 'পৌষ', 'মাঘ', 'ফাল্গুন', 'চৈত্র'];
    final starts = <DateTime>[
      DateTime(now.year, 4, 14), DateTime(now.year, 5, 15), DateTime(now.year, 6, 15), DateTime(now.year, 7, 16),
      DateTime(now.year, 8, 16), DateTime(now.year, 9, 16), DateTime(now.year, 10, 16), DateTime(now.year, 11, 15),
      DateTime(now.year, 12, 15), DateTime(now.year + 1, 1, 15), DateTime(now.year + 1, 2, 13), DateTime(now.year + 1, 3, 15),
    ];
    var index = -1;
    for (var i = 0; i < starts.length; i++) {
      if (!now.isBefore(starts[i])) index = i;
    }
    if (index < 0) index = 11;
    final year = now.month > 4 || (now.month == 4 && now.day >= 14) ? now.year - 593 : now.year - 594;
    return '${now.difference(starts[index]).inDays + 1} ${months[index]} $year';
  }

  String _hijriDate(AppLocalizations l10n) {
    try {
      final h = HijriCalendar.now();
      const bn = ['মুহররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি', 'জুমাদিউল আউয়াল', 'জুমাদিউস সানি', 'রজব', 'শাবান', 'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ'];
      const en = ['Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', 'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha’ban', 'Ramadan', 'Shawwal', 'Dhul-Qadah', 'Dhul-Hijjah'];
      final i = (h.hMonth - 1).clamp(0, 11);
      final month = l10n.isBangla ? bn[i] : en[i];
      final suffix = l10n.isBangla ? 'হিজরি' : 'AH';
      return '${h.hDay} $month ${h.hYear} $suffix';
    } catch (_) {
      return l10n.tr('হিজরি তারিখ পাওয়া যায়নি', 'Hijri date unavailable');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final controller = context.watch<PrayerController>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final languageCode = settings.languageCode;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: IslamicOrnamentalBackground()),
          SafeArea(
            child: controller.loading
                ? Center(child: CircularProgressIndicator(color: primary))
                : controller.error != null
                    ? _errorState(context, controller, l10n)
                    : RefreshIndicator(
                        color: primary,
                        onRefresh: controller.refreshPrayerTimes,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                          children: [
                            _screenHeader(context, l10n, controller),
                            const SizedBox(height: 14),
                            CurrentPrayerPremiumCard(
                              previousPrayer: _prayerName(l10n, controller.previousPrayer),
                              previousPrayerTime: controller.previousPrayerTime,
                              currentPrayer: _prayerName(l10n, controller.currentPrayer),
                              currentPrayerTime: controller.currentPrayerStart,
                              nextPrayer: _prayerName(l10n, controller.nextPrayerName),
                              nextPrayerTime: controller.nextPrayerTime,
                              remainingTime: controller.timeRemainingForNextPrayer,
                              progress: controller.prayerProgress,
                              iqamahTime: controller.currentIqamahTime,
                              status: _status(l10n, controller.prayerStatus),
                              languageCode: languageCode,
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
                              onRefresh: controller.refreshPrayerTimes,
                            ),
                            const SizedBox(height: 16),
                            _sectionHeader(context, l10n, Icons.mosque_outlined, l10n.todaysPrayer),
                            const SizedBox(height: 9),
                            _scheduleCard(context, controller, l10n),
                            const SizedBox(height: 16),
                            _sectionHeader(context, l10n, Icons.auto_awesome_outlined, l10n.naflAndOtherPrayers),
                            const SizedBox(height: 9),
                            _specialTimesCard(context, controller, l10n),
                            const SizedBox(height: 16),
                            _sectionHeader(context, l10n, Icons.warning_amber_rounded, '${l10n.prohibitedTime} & ${l10n.makruhTime}'),
                            const SizedBox(height: 9),
                            _restrictionCard(context, controller, l10n),
                            const SizedBox(height: 16),
                            _sectionHeader(context, l10n, Icons.check_circle_outline_rounded, l10n.prayerTracker),
                            const SizedBox(height: 9),
                            _trackerCard(context, controller, l10n),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _screenHeader(BuildContext context, AppLocalizations l10n, PrayerController controller) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.prayer, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(l10n.todaysPrayer, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n.location,
          onPressed: controller.loading ? null : controller.refreshLocation,
          icon: Icon(Icons.location_on_outlined, color: primary, size: 22),
        ),
        IconButton(
          tooltip: l10n.refresh,
          onPressed: controller.loading ? null : controller.refreshPrayerTimes,
          icon: Icon(Icons.refresh_rounded, color: primary, size: 22),
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, AppLocalizations l10n, IconData icon, String title) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: primary.withValues(alpha: .09), borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: primary, size: 18),
        ),
        const SizedBox(width: 9),
        Expanded(child: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontSize: 15.5, fontWeight: FontWeight.w800))),
      ],
    );
  }

  Widget _card(BuildContext context, Widget child, {EdgeInsets padding = const EdgeInsets.all(14)}) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: .055)),
      ),
      child: child,
    );
  }

  Widget _scheduleCard(BuildContext context, PrayerController controller, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondary = context.secondaryTextColor;
    if (controller.prayers.isEmpty) {
      return _card(context, Center(child: Text(l10n.loading, style: TextStyle(color: secondary, fontSize: 12))));
    }
    return _card(
      context,
      Column(
        children: [
          for (var i = 0; i < controller.prayers.length; i++) ...[
            _scheduleRow(controller.prayers[i], l10n, primary, text, secondary),
            if (i != controller.prayers.length - 1) Divider(height: 18, color: primary.withValues(alpha: .06)),
          ],
        ],
      ),
    );
  }

  Widget _scheduleRow(Map<String, dynamic> item, AppLocalizations l10n, Color primary, Color text, Color secondary) {
    final isCurrent = item['isCurrent'] == true;
    final rawName = item['name']?.toString() ?? '--';
    final name = _prayerName(l10n, rawName);
    final start = item['start']?.toString() ?? '--:--';
    final end = item['end']?.toString() ?? '--:--';
    final jamaat = item['jamaat']?.toString() ?? '--:--';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: isCurrent ? primary.withValues(alpha: .07) : Colors.transparent, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: primary.withValues(alpha: isCurrent ? .12 : .06), borderRadius: BorderRadius.circular(12)), child: Icon(isCurrent ? Icons.mosque_rounded : Icons.schedule_rounded, color: primary, size: 19)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(color: isCurrent ? primary : text, fontSize: 14, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text('$start  •  $end', style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w600))])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(l10n.jamaat, style: TextStyle(color: secondary, fontSize: 10.5, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(jamaat, style: TextStyle(color: text, fontSize: 12.5, fontWeight: FontWeight.w800))]),
        ],
      ),
    );
  }

  Widget _specialTimesCard(BuildContext context, PrayerController controller, AppLocalizations l10n) {
    final items = <String, String>{
      l10n.ishraq: controller.ishraqTime,
      l10n.duha: controller.duhaTime,
      l10n.awwabin: controller.awwabinTime,
      l10n.tahajjud: controller.tahajjudTime,
    };
    return _card(context, Column(children: [for (var i = 0; i < items.length; i++) ...[_valueRow(context, items.keys.elementAt(i), items.values.elementAt(i)), if (i != items.length - 1) const SizedBox(height: 8)]]));
  }

  Widget _restrictionCard(BuildContext context, PrayerController controller, AppLocalizations l10n) {
    return _card(
      context,
      Column(
        children: [
          _restrictionRow(context, Icons.block_rounded, l10n.prohibitedTime, _special(l10n, controller.prohibitedTimeText)),
          const SizedBox(height: 8),
          _restrictionRow(context, Icons.warning_amber_rounded, l10n.makruhTime, _special(l10n, controller.makruhTimeText)),
        ],
      ),
    );
  }

  Widget _restrictionRow(BuildContext context, IconData icon, String title, String value) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [Icon(icon, color: primary, size: 19), const SizedBox(width: 9), Expanded(child: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.5, fontWeight: FontWeight.w800))), const SizedBox(width: 8), Flexible(child: Text(value, textAlign: TextAlign.end, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5, fontWeight: FontWeight.w700)))],),
    );
  }

  Widget _valueRow(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [Container(width: 32, height: 32, decoration: BoxDecoration(color: primary.withValues(alpha: .09), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.auto_awesome_rounded, color: primary, size: 17)), const SizedBox(width: 9), Expanded(child: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w800))), Text(value.isEmpty ? '--:--' : value, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.5, fontWeight: FontWeight.w800))],),
    );
  }

  Widget _trackerCard(BuildContext context, PrayerController controller, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final names = <String, String>{
      'Fajr': l10n.fajr,
      'Dhuhr': l10n.dhuhr,
      'Asr': l10n.asr,
      'Maghrib': l10n.maghrib,
      'Isha': l10n.isha,
    };
    return _card(
      context,
      Column(children: [
        for (final entry in names.entries)
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: _tracker[entry.key],
            activeColor: primary,
            title: Text(entry.value, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700)),
            subtitle: Text(_jamaatFor(controller, entry.key), style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5)),
            onChanged: (value) => setState(() => _tracker[entry.key] = value ?? false),
          ),
      ]),
    );
  }

  String _jamaatFor(PrayerController controller, String key) {
    for (final item in controller.prayers) {
      if (item['name']?.toString() == key) return item['jamaat']?.toString() ?? '--:--';
    }
    return '--:--';
  }

  Widget _errorState(BuildContext context, PrayerController controller, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _card(
          context,
          Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.location_off_rounded, size: 42, color: primary),
            const SizedBox(height: 12),
            Text(l10n.prayerLoadError, textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 7),
            Text(controller.currentLocationName, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
            const SizedBox(height: 15),
            FilledButton.icon(onPressed: controller.refreshPrayerTimes, icon: const Icon(Icons.refresh_rounded), label: Text(l10n.retry)),
          ]),
        ),
      ),
    );
  }
}
