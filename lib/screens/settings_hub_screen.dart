import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'home_mode_settings_screen.dart';

class SettingsHubScreen extends StatelessWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final en = settings.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(en ? 'Settings' : 'সেটিংস', style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _section(context, en ? 'Personalization' : 'ব্যক্তিগতকরণ', Icons.tune_rounded, [
            _tile(context, Icons.dashboard_customize_outlined, en ? 'Home Screen' : 'হোম স্ক্রিন',
              en ? 'Choose Simple or Informative Home' : 'Simple বা Informative Home বেছে নিন',
              () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeModeSettingsScreen()))),
          ]),
          const SizedBox(height: 20),
          _section(context, en ? 'Appearance' : 'অ্যাপের চেহারা', Icons.palette_outlined, [
            _tile(context, Icons.palette_outlined, en ? 'Theme' : 'থিম', _themeLabel(settings), () => _themeSheet(context, settings)),
            _divider(),
            _tile(context, Icons.language_rounded, en ? 'Language' : 'ভাষা', en ? 'English' : 'বাংলা', () => _languageSheet(context, settings)),
            _divider(),
            _tile(context, Icons.text_fields_rounded, en ? 'Reading & Font' : 'পাঠ ও ফন্ট',
              en ? 'Quran and translation text size' : 'কুরআন ও অনুবাদের লেখার আকার',
              () => _readingSheet(context, settings)),
            _divider(),
            _switchTile(context, Icons.timer_outlined, en ? 'Show seconds' : 'সেকেন্ড দেখান',
              en ? 'Show seconds where a live clock supports it' : 'যেখানে লাইভ ঘড়ি আছে সেখানে সেকেন্ড দেখাবে',
              settings.showSeconds, (v) => settings.toggleShowSeconds(v)),
            _divider(),
            _switchTile(context, Icons.vibration_rounded, en ? 'Vibration' : 'ভাইব্রেশন',
              en ? 'Allow haptic feedback for supported actions' : 'সমর্থিত action-এ haptic feedback চালু রাখুন',
              settings.vibrationEnabled, (v) => settings.toggleVibration(v)),
          ]),
          const SizedBox(height: 20),
          _section(context, en ? 'Prayer & Adhan' : 'সালাত ও আজান', Icons.mosque_outlined, [
            _tile(context, Icons.calculate_outlined, en ? 'Prayer Calculation' : 'সালাতের হিসাব পদ্ধতি', settings.calculationMethod, () => _selectionSheet(context, en ? 'Prayer Calculation' : 'সালাতের হিসাব পদ্ধতি', settings.calculationMethod, SettingsProvider.calculationMethods, settings.setCalculationMethod)),
            _divider(),
            _tile(context, Icons.mosque_outlined, en ? 'Madhhab' : 'মাযহাব', settings.madhhab, () => _selectionSheet(context, en ? 'Madhhab' : 'মাযহাব', settings.madhhab, SettingsProvider.madhabs, settings.setMadhhab)),
            _divider(),
            _switchTile(context, Icons.notifications_active_outlined, en ? 'Adhan Notifications' : 'আজান নোটিফিকেশন',
              en ? 'Enable prayer-time notification scheduling' : 'সালাতের সময়ের নোটিফিকেশন চালু রাখুন',
              settings.isAdhanNotificationEnabled, (v) => settings.toggleAdhanNotification(v)),
            _divider(),
            _tile(context, Icons.tune_rounded, en ? 'Prayer Adjustments' : 'সালাতের সময় সমন্বয়',
              _adjustmentLabel(settings, en), () => _adjustmentsDialog(context, settings)),
            _divider(),
            _tile(context, Icons.access_time_rounded, en ? 'Jamaat Times' : 'জামাতের সময়',
              en ? 'Set your local Jamaat times' : 'নিজের এলাকার জামাতের সময় সেট করুন', () => _jamaatDialog(context, settings)),
          ]),
          const SizedBox(height: 20),
          _section(context, en ? 'Quran' : 'কুরআন', Icons.menu_book_outlined, [
            _tile(context, Icons.format_size_rounded, en ? 'Quran Reading' : 'কুরআন পড়ার সেটিংস',
              '${settings.quranFontSize.round()} / ${settings.translationFontSize.round()}', () => _readingSheet(context, settings)),
            _divider(),
            _tile(context, Icons.translate_rounded, en ? 'Translation' : 'অনুবাদ', settings.quranTranslation,
              () => _selectionSheet(context, en ? 'Translation' : 'অনুবাদ', settings.quranTranslation, const ['Bangla', 'English'], settings.setQuranTranslation)),
            _divider(),
            _tile(context, Icons.font_download_outlined, en ? 'Arabic Font' : 'আরবি ফন্ট', settings.quranArabicFont,
              () => _selectionSheet(context, en ? 'Arabic Font' : 'আরবি ফন্ট', settings.quranArabicFont, const ['Default', 'Amiri', 'Scheherazade'], settings.setQuranArabicFont)),
            _divider(),
            _switchTile(context, Icons.skip_next_rounded, en ? 'Auto-play next' : 'পরেরটি স্বয়ংক্রিয় চালান',
              en ? 'Continue with the next audio item when supported' : 'সমর্থিত অডিওতে পরেরটি স্বয়ংক্রিয়ভাবে চালাবে',
              settings.autoPlayNext, (v) => settings.toggleAutoPlayNext(v)),
            _divider(),
            _switchTile(context, Icons.wifi_outlined, en ? 'Wi-Fi only downloads' : 'শুধু Wi-Fi ডাউনলোড',
              en ? 'Prefer Wi-Fi for downloadable Quran resources' : 'ডাউনলোডযোগ্য কুরআন রিসোর্সে Wi-Fi অগ্রাধিকার দিন',
              settings.downloadWifiOnly, (v) => settings.toggleDownloadWifiOnly(v)),
          ]),
          const SizedBox(height: 20),
          _section(context, en ? 'Worship & Dates' : 'ইবাদত ও তারিখ', Icons.event_available_outlined, [
            _tile(context, Icons.today_outlined, en ? 'Daily Content' : 'দৈনিক কনটেন্ট',
              en ? 'Ayah, Hadith and Dua visibility' : 'আয়াত, হাদিস ও দোয়ার দৃশ্যমানতা', () => _dailyContentSheet(context, settings)),
            _divider(),
            _tile(context, Icons.calendar_month_outlined, en ? 'Date Preferences' : 'তারিখের পছন্দ', _dateLabel(settings, en), () => _dateSheet(context, settings)),
          ]),
          const SizedBox(height: 20),
          _section(context, en ? 'Data & App' : 'ডেটা ও অ্যাপ', Icons.settings_applications_outlined, [
            _tile(context, Icons.restart_alt_rounded, en ? 'Reset Settings' : 'সেটিংস রিসেট',
              en ? 'Restore all configurable preferences' : 'সব configurable preference ডিফল্টে ফিরিয়ে দিন', () => _resetDialog(context, settings)),
            _divider(),
            _tile(context, Icons.info_outline_rounded, en ? 'About NurVerse' : 'NurVerse সম্পর্কে', 'Version 1.0.0',
              () => showAboutDialog(context: context, applicationName: 'NurVerse', applicationVersion: '1.0.0', children: [Text(en ? 'A calm companion for everyday Islamic practice.' : 'প্রতিদিনের ইসলামিক জীবনের শান্ত সঙ্গী।')])),
            _divider(),
            _tile(context, Icons.code_rounded, en ? 'Open Source Licenses' : 'ওপেন সোর্স লাইসেন্স',
              en ? 'Libraries used by NurVerse' : 'NurVerse-এ ব্যবহৃত লাইব্রেরি', () => showLicensePage(context: context, applicationName: 'NurVerse', applicationVersion: '1.0.0')),
          ]),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, IconData icon, List<Widget> children) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.only(left: 4, bottom: 9), child: Row(children: [Icon(icon, size: 16, color: AppColors.seaBlue), const SizedBox(width: 7), Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: .72)))])),
    Card(margin: EdgeInsets.zero, elevation: 0, clipBehavior: Clip.antiAlias, child: Column(children: children)),
  ]);

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: .10), borderRadius: BorderRadius.circular(13)), child: Icon(icon, size: 21, color: AppColors.seaBlue)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, height: 1.35, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: .62)))])), const SizedBox(width: 8), Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Theme.of(context).iconTheme.color?.withValues(alpha: .38))])));

  Widget _switchTile(BuildContext context, IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) => Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: .10), borderRadius: BorderRadius.circular(13)), child: Icon(icon, size: 21, color: AppColors.seaBlue)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(subtitle, style: TextStyle(fontSize: 10.5, height: 1.35, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: .62)))])), Switch.adaptive(value: value, onChanged: onChanged)]));

  Widget _divider() => const Divider(height: 1, indent: 70);

  String _themeLabel(SettingsProvider s) { if (s.isAmoledMode) return 'AMOLED Black'; switch (s.themeMode) { case ThemeMode.light: return s.isEnglish ? 'Light Mode' : 'লাইট মোড'; case ThemeMode.dark: return s.isEnglish ? 'Dark Mode' : 'ডার্ক মোড'; case ThemeMode.system: return s.isEnglish ? 'System Default' : 'সিস্টেম অনুযায়ী'; } }

  String _adjustmentLabel(SettingsProvider s, bool en) { final active = s.prayerAdjustments.entries.where((e) => e.value != 0).toList(); if (active.isEmpty) return en ? 'No adjustments' : 'কোনো সমন্বয় নেই'; final first = active.first; return '${first.key}: ${first.value > 0 ? '+' : ''}${first.value} min'; }

  String _dateLabel(SettingsProvider s, bool en) { switch (s.dateDisplayPreference) { case 'hijri': return en ? 'Hijri only' : 'শুধু হিজরি'; case 'gregorian': return en ? 'Gregorian only' : 'শুধু ইংরেজি'; default: return en ? 'Both dates' : 'উভয় তারিখ'; } }

  Future<void> _themeSheet(BuildContext context, SettingsProvider s) async { await showModalBottomSheet<void>(context: context, builder: (ctx) => _choiceList(ctx, s.isEnglish ? 'Theme' : 'থিম', ['system','light','dark','amoled'], (v) async { if (v=='system') await s.setSystemTheme(); else if (v=='light') await s.setLightTheme(); else if (v=='dark') await s.setDarkTheme(); else { await s.setAmoledTheme(); } if (ctx.mounted) Navigator.pop(ctx); })); }

  Future<void> _languageSheet(BuildContext context, SettingsProvider s) async { await showModalBottomSheet<void>(context: context, builder: (ctx) => _choiceList(ctx, s.isEnglish ? 'Language' : 'ভাষা', ['bn','en'], (v) async { await s.setLanguage(v); if (ctx.mounted) Navigator.pop(ctx); })); }

  Future<void> _selectionSheet(BuildContext context, String title, String current, List<String> options, ValueChanged<String> onSelected) async { await showModalBottomSheet<void>(context: context, builder: (ctx) => _choiceList(ctx, title, options, (v) async { onSelected(v); if (ctx.mounted) Navigator.pop(ctx); })); }

  Widget _choiceList(BuildContext context, String title, List<String> options, Future<void> Function(String) onTap) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Center(child: Container(width: 42, height: 5, decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(9)))), const SizedBox(height: 16), Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 10), ...options.map((o) => ListTile(title: Text(o), onTap: () => onTap(o)))]));

  Future<void> _readingSheet(BuildContext context, SettingsProvider s) async { await showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(18, 18, 18, 26), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(s.isEnglish ? 'Reading & Font' : 'পাঠ ও ফন্ট', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 18), _slider(ctx, s.isEnglish ? 'Quran Arabic' : 'কুরআন আরবি', s.quranFontSize, 14, 50, (v) => s.updateQuranFontSize(v)), const SizedBox(height: 14), _slider(ctx, s.isEnglish ? 'Translation' : 'অনুবাদ', s.translationFontSize, 10, 30, (v) => s.updateTranslationFontSize(v))]))); }

  Widget _slider(BuildContext c, String title, double value, double min, double max, ValueChanged<double> onChanged) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))), Text(value.round().toString(), style: const TextStyle(color: AppColors.seaBlue, fontWeight: FontWeight.w900))]), Slider(value: value.clamp(min,max), min:min, max:max, divisions:(max-min).round(), onChanged:onChanged)]);

  Future<void> _adjustmentsDialog(BuildContext context, SettingsProvider s) async { final en=s.isEnglish; await showDialog<void>(context:context,builder:(d)=>AlertDialog(title:Text(en?'Prayer Adjustments':'সালাতের সময় সমন্বয়'),content:SingleChildScrollView(child:Column(children:[for(final p in const ['Fajr','Dhuhr','Asr','Maghrib','Isha']) ListTile(title:Text(p), subtitle:Text('${s.prayerAdjustments[p] ?? 0} min'), trailing:Wrap(children:[IconButton(onPressed:()=>s.setPrayerAdjustment(p,(s.prayerAdjustments[p]??0)-1),icon:const Icon(Icons.remove_circle_outline)),IconButton(onPressed:()=>s.setPrayerAdjustment(p,(s.prayerAdjustments[p]??0)+1),icon:const Icon(Icons.add_circle_outline))]))])),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:Text(en?'Done':'সম্পন্ন'))])); }

  Future<void> _jamaatDialog(BuildContext context, SettingsProvider s) async { final en=s.isEnglish; final controllers={for(final p in const ['Fajr','Dhuhr','Asr','Maghrib','Isha']) p:TextEditingController(text:s.getJamaat(p))}; await showDialog<void>(context:context,builder:(d)=>AlertDialog(title:Text(en?'Jamaat Times':'জামাতের সময়'),content:SingleChildScrollView(child:Column(children:[for(final p in const ['Fajr','Dhuhr','Asr','Maghrib','Isha']) TextField(controller:controllers[p], decoration:InputDecoration(labelText:p), keyboardType:TextInputType.datetime)])),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:Text(en?'Cancel':'বাতিল')),FilledButton(onPressed:()async{for(final p in const ['Fajr','Dhuhr','Asr','Maghrib','Isha']){await s.setJamaatTime(p,controllers[p]!.text);}if(d.mounted)Navigator.pop(d);},child:Text(en?'Save':'সংরক্ষণ'))])); for(final c in controllers.values)c.dispose(); }

  Future<void> _dailyContentSheet(BuildContext context, SettingsProvider s) async { final en=s.isEnglish; await showModalBottomSheet<void>(context:context,builder:(ctx)=>SafeArea(child:Padding(padding:const EdgeInsets.all(18),child:Column(mainAxisSize:MainAxisSize.min,children:[Text(en?'Daily Content':'দৈনিক কনটেন্ট',style:Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w900)),const SizedBox(height:12),_switchTile(ctx,Icons.menu_book_outlined,en?'Daily Ayah':'দৈনিক আয়াত','',s.showDailyAyah,(v)=>s.setDailyContentPreferences(ayah:v)),_switchTile(ctx,Icons.auto_stories_outlined,en?'Daily Hadith':'দৈনিক হাদিস','',s.showDailyHadith,(v)=>s.setDailyContentPreferences(hadith:v)),_switchTile(ctx,Icons.volunteer_activism_outlined,en?'Daily Dua':'দৈনিক দোয়া','',s.showDailyDua,(v)=>s.setDailyContentPreferences(dua:v))]))); }

  Future<void> _dateSheet(BuildContext context, SettingsProvider s) async { final en=s.isEnglish; await showModalBottomSheet<void>(context:context,builder:(ctx)=>_choiceList(ctx,en?'Date Preferences':'তারিখের পছন্দ',['hijri','gregorian','both'],(v)async{await s.setDateDisplayPreference(v);if(ctx.mounted)Navigator.pop(ctx);})); }

  Future<void> _resetDialog(BuildContext context, SettingsProvider s) async { final en=s.isEnglish; await showDialog<void>(context:context,builder:(d)=>AlertDialog(title:Text(en?'Reset settings?':'সেটিংস রিসেট করবেন?'),content:Text(en?'All saved preferences will return to default values.':'সব সংরক্ষিত preference ডিফল্ট অবস্থায় ফিরে যাবে।'),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:Text(en?'Cancel':'বাতিল')),FilledButton(onPressed:()async{await s.resetSettings();if(d.mounted)Navigator.pop(d);},child:Text(en?'Reset':'রিসেট'))])); }
}
