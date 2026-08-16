import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
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

  String _label(String languageCode, String bn, String en, [String? ar]) {
    if (languageCode == 'en') return en;
    if (languageCode == 'ar') return ar ?? en;
    return bn;
  }

  String _prayerName(String languageCode, String value) {
    switch (value.trim().toLowerCase()) {
      case 'fajr':
      case 'ফজর':
        return _label(languageCode, 'ফজর', 'Fajr', 'الفجر');
      case 'dhuhr':
      case 'যোহর':
        return _label(languageCode, 'যোহর', 'Dhuhr', 'الظهر');
      case 'asr':
      case 'আসর':
        return _label(languageCode, 'আসর', 'Asr', 'العصر');
      case 'maghrib':
      case 'মাগরিব':
        return _label(languageCode, 'মাগরিব', 'Maghrib', 'المغرب');
      case 'isha':
      case 'ইশা':
        return _label(languageCode, 'ইশা', 'Isha', 'العشاء');
      case 'jumuah':
      case "জুমু'আ":
        return _label(languageCode, "জুমু'আ", 'Jumu’ah', 'الجمعة');
      default:
        return value;
    }
  }

  String _status(String languageCode, String value) {
    const map = <String, List<String>>{
      'ইশার ওয়াক্ত চলছে': ['Isha time is ongoing', 'وقت العشاء جارٍ'],
      'ফজরের সময় শুরু হতে চলেছে': ['Fajr time is about to begin', 'سيبدأ وقت الفجر قريبًا'],
      'ফজরের ওয়াক্ত চলছে': ['Fajr time is ongoing', 'وقت الفجر جارٍ'],
      'ফজরের ওয়াক্ত শেষ হয়েছে': ['Fajr time has ended', 'انتهى وقت الفجر'],
      'ইশা শেষ হয়েছে': ['Isha has ended', 'انتهى وقت العشاء'],
      'ফজর শেষ হয়েছে': ['Fajr has ended', 'انتهى الفجر'],
      "জুমু'আর ওয়াক্ত চলছে": ['Jumu’ah time is ongoing', 'وقت الجمعة جارٍ'],
      'যোহরের ওয়াক্ত চলছে': ['Dhuhr time is ongoing', 'وقت الظهر جارٍ'],
      'আসরের ওয়াক্ত চলছে': ['Asr time is ongoing', 'وقت العصر جارٍ'],
      'আসর শেষ হয়েছে': ['Asr has ended', 'انتهى العصر'],
      'মাগরিবের ওয়াক্ত চলছে': ['Maghrib time is ongoing', 'وقت المغرب جارٍ'],
      'মাগরিব শেষ হয়েছে': ['Maghrib has ended', 'انتهى المغرب'],
      'সালাতের সময় গণনা করা হচ্ছে...': ['Calculating prayer times...', 'جارٍ حساب أوقات الصلاة...'],
    };
    final item = map[value];
    if (item == null) return value;
    return _label(languageCode, value, item[0], item[1]);
  }

  String _special(String languageCode, String value) {
    const map = <String, List<String>>{
      'সময় গণনা করা হচ্ছে...': ['Calculating time...', 'جارٍ حساب الوقت...'],
      'আজ আর কোনো নিষিদ্ধ সময় নেই': ['No more prohibited time today', 'لا يوجد وقت نهي آخر اليوم'],
      'সূর্যোদয়ের সময় — নামাজ আদায় থেকে বিরত থাকুন': ['Sunrise period — refrain from prayer', 'وقت الشروق — تجنب الصلاة'],
      'জাওয়ালের সময় — নামাজ আদায় থেকে বিরত থাকুন': ['Zawal period — refrain from prayer', 'وقت الزوال — تجنب الصلاة'],
      'সূর্যাস্তের সময় — নামাজ আদায় থেকে বিরত থাকুন': ['Sunset period — refrain from prayer', 'وقت الغروب — تجنب الصلاة'],
      'পরবর্তী নিষিদ্ধ সময়: সূর্যোদয়': ['Next prohibited time: Sunrise', 'وقت النهي التالي: الشروق'],
      'পরবর্তী নিষিদ্ধ সময়: জাওয়াল': ['Next prohibited time: Zawal', 'وقت النهي التالي: الزوال'],
      'পরবর্তী নিষিদ্ধ সময়: সূর্যাস্ত': ['Next prohibited time: Sunset', 'وقت النهي التالي: الغروب'],
      'আজ আর কোনো বিশেষ মাকরূহ সময় নেই': ['No more special Makruh time today', 'لا يوجد وقت مكروه آخر اليوم'],
      'সূর্যোদয়ের আশেপাশের মাকরূহ সময়': ['Makruh period around sunrise', 'وقت مكروه حول الشروق'],
      'জাওয়ালের আশেপাশের মাকরূহ সময়': ['Makruh period around Zawal', 'وقت مكروه حول الزوال'],
      'সূর্যাস্তের আশেপাশের মাকরূহ সময়': ['Makruh period around sunset', 'وقت مكروه حول الغروب'],
      'পরবর্তী মাকরূহ সময়: সূর্যোদয়': ['Next Makruh time: Sunrise', 'وقت المكروه التالي: الشروق'],
      'পরবর্তী মাকরূহ সময়: জাওয়াল': ['Next Makruh time: Zawal', 'وقت المكروه التالي: الزوال'],
      'পরবর্তী মাকরূহ সময়: সূর্যাস্ত': ['Next Makruh time: Sunset', 'وقت المكروه التالي: الغروب'],
    };
    final item = map[value];
    if (item == null) return value;
    return _label(languageCode, value, item[0], item[1]);
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

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final controller = context.watch<PrayerController>();
    final languageCode = settings.languageCode;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          _label(languageCode, 'সালাত', 'Prayer', 'الصلاة'),
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _label(languageCode, 'লোকেশন', 'Location', 'الموقع'),
            onPressed: controller.loading ? null : controller.refreshLocation,
            icon: Icon(Icons.location_on_outlined, color: primary),
          ),
          IconButton(
            tooltip: _label(languageCode, 'রিফ্রেশ', 'Refresh', 'تحديث'),
            onPressed: controller.loading ? null : controller.refreshPrayerTimes,
            icon: Icon(Icons.refresh_rounded, color: primary),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: IslamicOrnamentalBackground()),
          controller.loading
              ? Center(child: CircularProgressIndicator(color: primary))
              : controller.error != null
                  ? _errorState(context, controller, languageCode)
                  : RefreshIndicator(
                      color: primary,
                      onRefresh: controller.refreshPrayerTimes,
                      child: ListView(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
                        children: [
                          IslamicInfoCard(
                            location: controller.currentLocationName,
                            englishDate: _englishDate(),
                            banglaDate: _banglaDate(),
                            hijriDate: _hijriDate(languageCode),
                            sunrise: controller.sunriseTime,
                            sunset: controller.sunsetTime,
                            languageCode: languageCode,
                            onRefresh: controller.refreshPrayerTimes,
                          ),
                          const SizedBox(height: 10),
                          CurrentPrayerPremiumCard(
                            previousPrayer: _prayerName(languageCode, controller.previousPrayer),
                            previousPrayerTime: controller.previousPrayerTime,
                            currentPrayer: _prayerName(languageCode, controller.currentPrayer),
                            currentPrayerTime: controller.currentPrayerStart,
                            nextPrayer: _prayerName(languageCode, controller.nextPrayerName),
                            nextPrayerTime: controller.nextPrayerTime,
                            remainingTime: controller.timeRemainingForNextPrayer,
                            progress: controller.prayerProgress,
                            iqamahTime: controller.currentIqamahTime,
                            status: _status(languageCode, controller.prayerStatus),
                            languageCode: languageCode,
                          ),
                          const SizedBox(height: 10),
                          PrayerTimelineCard(prayers: controller.prayers, languageCode: languageCode),
                          const SizedBox(height: 16),
                          _sectionHeader(context, languageCode, Icons.mosque_outlined, 'আজকের সালাত', "Today's Prayers", 'صلوات اليوم'),
                          const SizedBox(height: 8),
                          _scheduleCard(context, controller, languageCode),
                          const SizedBox(height: 16),
                          _sectionHeader(context, languageCode, Icons.auto_awesome_outlined, 'নফল ও বিশেষ সময়', 'Nafl & Special Times', 'النوافل والأوقات الخاصة'),
                          const SizedBox(height: 8),
                          _specialTimesCard(context, controller, languageCode),
                          const SizedBox(height: 16),
                          _sectionHeader(context, languageCode, Icons.warning_amber_rounded, 'নিষিদ্ধ ও মাকরূহ সময়', 'Prohibited & Makruh Times', 'أوقات النهي والكراهة'),
                          const SizedBox(height: 8),
                          _restrictionCard(context, controller, languageCode),
                          const SizedBox(height: 16),
                          _sectionHeader(context, languageCode, Icons.check_circle_outline_rounded, 'সালাত ট্র্যাকার', 'Prayer Tracker', 'متابعة الصلاة'),
                          const SizedBox(height: 8),
                          _trackerCard(context, controller, languageCode),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String languageCode, IconData icon, String bn, String en, String ar) {
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
        Expanded(
          child: Text(_label(languageCode, bn, en, ar), style: theme.textTheme.titleSmall?.copyWith(fontSize: 15.5, fontWeight: FontWeight.w800)),
        ),
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

  Widget _scheduleCard(BuildContext context, PrayerController controller, String languageCode) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondary = context.secondaryTextColor;
    if (controller.prayers.isEmpty) {
      return _card(context, Center(child: Text(_label(languageCode, 'সালাতের সময় প্রস্তুত হচ্ছে...', 'Preparing prayer times...', 'جارٍ تجهيز أوقات الصلاة...'), style: TextStyle(color: secondary, fontSize: 12))));
    }
    return _card(
      context,
      Column(
        children: [
          for (var i = 0; i < controller.prayers.length; i++) ...[
            _scheduleRow(context, controller.prayers[i], languageCode, primary, text, secondary),
            if (i != controller.prayers.length - 1) Divider(height: 18, color: primary.withValues(alpha: .06)),
          ],
        ],
      ),
    );
  }

  Widget _scheduleRow(BuildContext context, Map<String, dynamic> item, String languageCode, Color primary, Color text, Color secondary) {
    final isCurrent = item['isCurrent'] == true;
    final name = languageCode == 'en' ? (item['name']?.toString() ?? '--') : languageCode == 'ar' ? (item['nameAr']?.toString() ?? '--') : (item['nameBn']?.toString() ?? '--');
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
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(_label(languageCode, 'জামাত', 'Jamaat', 'الجماعة'), style: TextStyle(color: secondary, fontSize: 10.5, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(jamaat, style: TextStyle(color: text, fontSize: 12.5, fontWeight: FontWeight.w800))]),
        ],
      ),
    );
  }

  Widget _specialTimesCard(BuildContext context, PrayerController controller, String languageCode) {
    final items = <Map<String, String>>[
      {'bn': 'ইশরাক', 'en': 'Ishraq', 'ar': 'الإشراق', 'value': controller.ishraqTime},
      {'bn': 'চাশত / দুহা', 'en': 'Chasht / Duha', 'ar': 'الضحى', 'value': controller.duhaTime},
      {'bn': 'আউওয়াবীন', 'en': 'Awwabin', 'ar': 'الأوابين', 'value': controller.awwabinTime},
      {'bn': 'তাহাজ্জুদ', 'en': 'Tahajjud', 'ar': 'التهجد', 'value': controller.tahajjudTime},
    ];
    return _card(context, Column(children: [for (var i = 0; i < items.length; i++) ...[_valueRow(context, languageCode, Icons.auto_awesome_rounded, items[i]['bn']!, items[i]['en']!, items[i]['ar']!, items[i]['value']!), if (i != items.length - 1) const SizedBox(height: 8)]]));
  }

  Widget _restrictionCard(BuildContext context, PrayerController controller, String languageCode) {
    return _card(
      context,
      Column(
        children: [
          _restrictionRow(context, languageCode, Icons.block_rounded, 'নিষিদ্ধ সময়', 'Prohibited time', 'وقت النهي', _special(languageCode, controller.prohibitedTimeText)),
          const SizedBox(height: 8),
          _restrictionRow(context, languageCode, Icons.warning_amber_rounded, 'মাকরূহ সময়', 'Makruh time', 'وقت الكراهة', _special(languageCode, controller.makruhTimeText)),
        ],
      ),
    );
  }

  Widget _restrictionRow(BuildContext context, String languageCode, IconData icon, String bn, String en, String ar, String value) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [Icon(icon, color: primary, size: 19), const SizedBox(width: 9), Expanded(child: Text(_label(languageCode, bn, en, ar), style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.5, fontWeight: FontWeight.w800))), const SizedBox(width: 8), Flexible(child: Text(value, textAlign: TextAlign.end, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5, fontWeight: FontWeight.w700)))],),
    );
  }

  Widget _valueRow(BuildContext context, String languageCode, IconData icon, String bn, String en, String ar, String value) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [Container(width: 32, height: 32, decoration: BoxDecoration(color: primary.withValues(alpha: .09), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: primary, size: 17)), const SizedBox(width: 9), Expanded(child: Text(_label(languageCode, bn, en, ar), style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w800))), Text(value.isEmpty ? '--:--' : value, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.5, fontWeight: FontWeight.w800))],),
    );
  }

  Widget _trackerCard(BuildContext context, PrayerController controller, String languageCode) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final names = <String, List<String>>{
      'Fajr': ['ফজর', 'Fajr', 'الفجر'],
      'Dhuhr': ['যোহর', 'Dhuhr', 'الظهر'],
      'Asr': ['আসর', 'Asr', 'العصر'],
      'Maghrib': ['মাগরিব', 'Maghrib', 'المغرب'],
      'Isha': ['ইশা', 'Isha', 'العشاء'],
    };
    return _card(
      context,
      Column(children: [
        for (final key in names.keys) CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          value: _tracker[key],
          activeColor: primary,
          title: Text(_label(languageCode, names[key]![0], names[key]![1], names[key]![2]), style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700)),
          subtitle: Text(_jamaatFor(controller, key), style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5)),
          onChanged: (value) => setState(() => _tracker[key] = value ?? false),
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

  Widget _errorState(BuildContext context, PrayerController controller, String languageCode) {
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
            Text(_label(languageCode, 'সালাতের সময় লোড করা যায়নি', 'Could not load prayer times', 'تعذر تحميل أوقات الصلاة'), textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 7),
            Text(controller.currentLocationName, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
            const SizedBox(height: 15),
            FilledButton.icon(onPressed: controller.refreshPrayerTimes, icon: const Icon(Icons.refresh_rounded), label: Text(_label(languageCode, 'আবার চেষ্টা করুন', 'Try again', 'حاول مرة أخرى'))),
          ]),
        ),
      ),
    );
  }
}
