import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/premium_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/text_scale_provider.dart';
import '../theme/app_theme.dart';
import 'home_mode_settings_screen.dart';
import 'prayer/jamaat_settings_screen.dart';

class CanonicalSettingsScreen extends StatelessWidget {
  const CanonicalSettingsScreen({super.key});

  String t(String l, String bn, String en, [String? ar]) => l == 'en' ? en : l == 'ar' ? (ar ?? en) : bn;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final scale = context.watch<TextScaleProvider>();
    final premium = context.watch<PremiumProvider>();
    final l = s.languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(t(l, 'সেটিংস', 'Settings', 'الإعدادات')), centerTitle: true),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
        _premium(context, s, premium),
        const SizedBox(height: 18),
        _section(context, t(l, 'ব্যক্তিগতকরণ', 'Personalization'), Icons.tune_rounded, [
          _tile(context, Icons.dashboard_customize_outlined, t(l, 'হোম স্ক্রিন', 'Home Screen'), t(l, 'সহজ বা বিস্তারিত হোম স্ক্রিন বেছে নিন', 'Choose your Home Screen style'), () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const HomeModeSettingsScreen()))),
        ]),
        const SizedBox(height: 20),
        _section(context, t(l, 'অ্যাপের চেহারা', 'Appearance'), Icons.palette_outlined, [
          _choice(context, Icons.palette_outlined, t(l, 'থিম', 'Theme'), themeLabel(s), ['system','light','dark','amoled'], s.themeId, (v) async { if(v=='system') await s.setSystemTheme(); else if(v=='light') await s.setLightTheme(); else if(v=='dark') await s.setDarkTheme(); else await s.setAmoledTheme(); }),
          _divider(),
          _choice(context, Icons.language_rounded, t(l, 'ভাষা', 'Language', 'اللغة'), l=='bn'?'বাংলা':l=='ar'?'العربية':'English', ['bn','en','ar'], l, s.setLanguage),
          _divider(),
          _tile(context, Icons.text_fields_rounded, t(l, 'অ্যাপের লেখা', 'App Text Size'), textSizeLabel(scale.level,l), () => textSizeSheet(context,scale,l)),
          _divider(),
          _choice(context, Icons.access_time_rounded, t(l, 'সময় ফরম্যাট', 'Time Format', 'تنسيق الوقت'), s.is24Hour?t(l,'২৪ ঘণ্টা','24-hour','24 ساعة'):t(l,'১২ ঘণ্টা','12-hour','12 ساعة'), ['12','24'], s.timeFormat, s.setTimeFormat),
          _divider(),
          _switch(context, Icons.timer_outlined, t(l,'সেকেন্ড দেখান','Show Seconds'), t(l,'যেখানে সমর্থিত সেখানে সেকেন্ড দেখাবে','Show seconds where supported'), s.showSeconds, s.toggleShowSeconds),
          _divider(),
          _switch(context, Icons.vibration_rounded, t(l,'ভাইব্রেশন','Vibration'), t(l,'সমর্থিত অ্যাকশনে হ্যাপটিক ফিডব্যাক','Allow supported haptic feedback'), s.vibrationEnabled, s.toggleVibration),
        ]),
        const SizedBox(height: 20),
        _section(context, t(l,'সালাত ও আজান','Prayer & Adhan'), Icons.mosque_outlined, [
          _choice(context, Icons.calculate_outlined, t(l,'সালাতের হিসাব পদ্ধতি','Prayer Calculation'), choice(s.calculationMethod,l), SettingsProvider.calculationMethods, s.calculationMethod, s.setCalculationMethod),
          _divider(),
          _choice(context, Icons.mosque_outlined, t(l,'মাযহাব','Madhhab'), choice(s.madhhab,l), SettingsProvider.madhabs, s.madhhab, s.setMadhhab),
          _divider(),
          _choice(context, Icons.location_on_outlined, t(l,'লোকেশন','Location'), s.autoLocation?t(l,'স্বয়ংক্রিয়','Automatic'):t(l,'ম্যানুয়াল','Manual'), ['automatic','manual'], s.locationMode, s.setLocationMode),
          _divider(),
          _switch(context, Icons.notifications_active_outlined, t(l,'আজান নোটিফিকেশন','Adhan Notifications'), t(l,'সালাতের সময় নোটিফিকেশন চালু রাখুন','Enable prayer-time notifications'), s.isAdhanNotificationEnabled, s.toggleAdhanNotification),
          _divider(),
          _choice(context, Icons.volume_up_outlined, t(l,'আজানের শব্দ','Adhan Sound'), choice(s.notificationSound,l), ['Default','Silent'], s.notificationSound, s.setNotificationSound),
          _divider(),
          _choice(context, Icons.alarm_outlined, t(l,'সালাতের আগে স্মরণ','Prayer Reminder'), reminder(s.prayerReminderMinutes,l), ['0','5','10','15','20','30'], '${s.prayerReminderMinutes}', (v)=>s.setPrayerReminderMinutes(int.parse(v))),
          _divider(),
          _choice(context, Icons.calendar_today_outlined, t(l,'হিজরি তারিখ সমন্বয়','Hijri Date Adjustment'), hijri(s.hijriAdjustment,l), ['-3','-2','-1','0','1','2','3'], '${s.hijriAdjustment}', (v)=>s.setHijriAdjustment(int.parse(v))),
          _divider(),
          _tile(context, Icons.groups_rounded, t(l,'জামাতের সময়','Jamaat Times'), t(l,'পাঁচ ওয়াক্তের জামাতের সময় সেট করুন','Set Jamaat times for all five prayers'), () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const JamaatSettingsScreen()))),
        ]),
        const SizedBox(height: 20),
        _section(context,t(l,'কুরআন','Quran'),Icons.menu_book_outlined,[
          _tile(context,Icons.format_size_rounded,t(l,'কুরআন পড়ার সেটিংস','Quran Reading'),'${s.quranFontSize.round()} / ${s.translationFontSize.round()}',()=>quranSheet(context,s,l)),
          _divider(),
          _choice(context,Icons.translate_rounded,t(l,'অনুবাদ','Translation'),choice(s.quranTranslation,l),['Bangla','English'],s.quranTranslation,s.setQuranTranslation),
          _divider(),
          _choice(context,Icons.font_download_outlined,t(l,'আরবি ফন্ট','Arabic Font'),choice(s.quranArabicFont,l),['Default','Amiri','Scheherazade'],s.quranArabicFont,s.setQuranArabicFont),
          _divider(),
          _switch(context,Icons.skip_next_rounded,t(l,'পরবর্তী আয়াত স্বয়ংক্রিয়ভাবে চালু','Auto-play next'),t(l,'সমর্থিত অডিওতে পরেরটি চালাবে','Continue with the next supported audio'),s.autoPlayNext,s.toggleAutoPlayNext),
          _divider(),
          _switch(context,Icons.wifi_outlined,t(l,'শুধু Wi-Fi দিয়ে ডাউনলোড','Wi-Fi only downloads'),t(l,'ডাউনলোডে Wi-Fi অগ্রাধিকার দিন','Prefer Wi-Fi for downloads'),s.downloadWifiOnly,s.toggleDownloadWifiOnly),
        ]),
        const SizedBox(height: 20),
        _section(context,t(l,'ইবাদত ও তারিখ','Worship & Dates'),Icons.event_available_outlined,[
          _tile(context,Icons.today_outlined,t(l,'দৈনিক কনটেন্ট','Daily Content'),t(l,'আয়াত, হাদিস ও দোয়া','Ayah, Hadith and Dua'),()=>dailySheet(context,s,l)),
          _divider(),
          _choice(context,Icons.calendar_month_outlined,t(l,'তারিখের পছন্দ','Date Preferences'),dateLabel(s.dateDisplayPreference,l),['hijri','gregorian','both'],s.dateDisplayPreference,s.setDateDisplayPreference),
        ]),
        const SizedBox(height: 20),
        _section(context,t(l,'ডেটা ও অ্যাপ','Data & App'),Icons.settings_applications_outlined,[
          _tile(context,Icons.restart_alt_rounded,t(l,'সব সেটিংস রিসেট','Reset Settings'),t(l,'সব সেটিংস ডিফল্টে ফিরিয়ে দিন','Restore all configurable settings'),()=>resetDialog(context,s,l)),
          _divider(),
          _tile(context,Icons.info_outline_rounded,t(l,'নূরভার্স সম্পর্কে','About NurVerse'),'NurVerse',()=>showAboutDialog(context:context,applicationName:'NurVerse',applicationVersion:'1.0.0')),
          _divider(),
          _tile(context,Icons.code_rounded,t(l,'ওপেন সোর্স লাইসেন্স','Open Source Licenses'),t(l,'নূরভার্সে ব্যবহৃত লাইব্রেরি','Libraries used by NurVerse'),()=>showLicensePage(context:context,applicationName:'NurVerse')),
        ]),
      ]),
    );
  }

  Widget _premium(BuildContext c, SettingsProvider s, PremiumProvider p) => Card(elevation:0,child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[CircleAvatar(radius:27,backgroundColor:AppColors.seaBlue.withValues(alpha:.12),child:Icon(p.isPremium?Icons.workspace_premium_rounded:Icons.login_rounded,color:AppColors.seaBlue,size:29)),const SizedBox(width:13),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('NurVerse Premium',style:TextStyle(fontSize:17,fontWeight:FontWeight.w900)),const SizedBox(height:3),Text(p.isPremium?t(s.languageCode,'প্রিমিয়াম সক্রিয়','Premium Active'):t(s.languageCode,'Google দিয়ে লগইন করে Premium দেখুন','Sign in with Google to explore Premium'),style:const TextStyle(fontSize:10.5),maxLines:2)])),TextButton(onPressed:p.activatePremium,child:Text(p.isPremium?t(s.languageCode,'খুলুন','Open'):t(s.languageCode,'লগইন','Login')))])));

  Widget _section(BuildContext c,String title,IconData icon,List<Widget> children)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Padding(padding:const EdgeInsets.only(left:4,bottom:9),child:Row(children:[Icon(icon,size:16,color:AppColors.seaBlue),const SizedBox(width:7),Text(title,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w800))])),Card(margin:EdgeInsets.zero,elevation:0,clipBehavior:Clip.antiAlias,child:Column(children:children))]);
  Widget _tile(BuildContext c,IconData icon,String title,String sub,VoidCallback onTap)=>ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:15,vertical:4),leading:Container(width:42,height:42,decoration:BoxDecoration(color:AppColors.seaBlue.withValues(alpha:.10),borderRadius:BorderRadius.circular(13)),child:Icon(icon,size:21,color:AppColors.seaBlue)),title:Text(title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w700)),subtitle:Text(sub,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:10.5,height:1.3)),trailing:const Icon(Icons.arrow_forward_ios_rounded,size:14),onTap:onTap);
  Widget _switch(BuildContext c,IconData icon,String title,String sub,bool value,ValueChanged<bool> onChanged)=>ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:15,vertical:4),leading:Container(width:42,height:42,decoration:BoxDecoration(color:AppColors.seaBlue.withValues(alpha:.10),borderRadius:BorderRadius.circular(13)),child:Icon(icon,size:21,color:AppColors.seaBlue)),title:Text(title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w700)),subtitle:Text(sub,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:10.5,height:1.3)),trailing:Switch.adaptive(value:value,onChanged:onChanged));
  Widget _choice(BuildContext c,IconData icon,String title,String sub,List<String> options,String selected,Future<void> Function(String) onChanged)=>_tile(c,icon,title,sub,()=>showModalBottomSheet<void>(context:c,showDragHandle:true,builder:(sc)=>SafeArea(child:ListView(shrinkWrap:true,children:options.map((v)=>ListTile(title:Text(choice(v,Localizations.localeOf(sc).languageCode)),trailing:v==selected?const Icon(Icons.check_circle_rounded,color:AppColors.seaBlue):null,onTap:()async{await onChanged(v);if(sc.mounted)Navigator.pop(sc);})).toList()))));
  Widget _divider()=>const Divider(height:1,indent:70);

  String themeLabel(SettingsProvider s)=>s.isAmoledMode?t(s.languageCode,'অ্যামোলেড কালো','AMOLED Black'):s.themeMode==ThemeMode.light?t(s.languageCode,'লাইট মোড','Light Mode'):s.themeMode==ThemeMode.dark?t(s.languageCode,'ডার্ক মোড','Dark Mode'):t(s.languageCode,'সিস্টেম অনুযায়ী','System Default');
  String textSizeLabel(int n,String l)=>[t(l,'ছোট','Small'),t(l,'স্বাভাবিক','Normal'),t(l,'বড়','Large'),t(l,'খুব বড়','Very Large')][n.clamp(0,3)];
  String choice(String v,String l){if(l=='en'){if(v=='Bangla')return'Bangla';if(v=='bn')return'Bangla';if(v=='12')return'12-hour';if(v=='24')return'24-hour';if(v=='automatic')return'Automatic';if(v=='manual')return'Manual';return v;}if(l=='ar')return v;const m={'Karachi':'করাচি','Muslim World League':'মুসলিম ওয়ার্ল্ড লীগ','Egyptian':'মিশরীয়','Umm Al Qura':'উম্মুল কুরা','Dubai':'দুবাই','Qatar':'কাতার','Kuwait':'কুয়েত','Singapore':'সিঙ্গাপুর','North America':'উত্তর আমেরিকা','Moonsighting Committee':'চাঁদ দেখা কমিটি','Hanafi':'হানাফি','Shafi':'শাফেয়ি','Maliki':'মালিকি','Hanbali':'হাম্বলি','Bangla':'বাংলা','English':'ইংরেজি','Default':'ডিফল্ট','Silent':'নীরব','Amiri':'আমিরি','Scheherazade':'শেহেরাজাদে','hijri':'হিজরি','gregorian':'গ্রেগরিয়ান','both':'উভয়'};return m[v]??v;}
  String reminder(int n,String l)=>n==0?t(l,'সময় হলে','At prayer time'):'$n ${t(l,'মিনিট আগে','min before')}';
  String hijri(int n,String l)=>n==0?t(l,'কোনো সমন্বয় নেই','No adjustment'):'${n>0?'+':''}$n ${t(l,'দিন','day')}';
  String dateLabel(String v,String l)=>v=='hijri'?t(l,'শুধু হিজরি','Hijri only'):v=='gregorian'?t(l,'শুধু গ্রেগরিয়ান','Gregorian only'):t(l,'উভয় তারিখ','Both dates');

  Future<void> textSizeSheet(BuildContext c,TextScaleProvider p,String l)=>showModalBottomSheet<void>(context:c,builder:(sc)=>Column(mainAxisSize:MainAxisSize.min,children:[for(int i=0;i<4;i++)ListTile(title:Text(textSizeLabel(i,l)),trailing:i==p.level?const Icon(Icons.check_circle_rounded,color:AppColors.seaBlue):null,onTap:()async{await p.setLevel(i);if(sc.mounted)Navigator.pop(sc);})]));
  Future<void> quranSheet(BuildContext c,SettingsProvider s,String l)=>showModalBottomSheet<void>(context:c,builder:(sc)=>Padding(padding:const EdgeInsets.all(18),child:Column(mainAxisSize:MainAxisSize.min,children:[Text(t(l,'কুরআন পড়ার সেটিংস','Quran Reading'),style:Theme.of(sc).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w900)),Text('${t(l,'আরবি','Arabic')}: ${s.quranFontSize.round()}'),Slider(value:s.quranFontSize.clamp(14,50),min:14,max:50,onChanged:s.updateQuranFontSize),Text('${t(l,'অনুবাদ','Translation')}: ${s.translationFontSize.round()}'),Slider(value:s.translationFontSize.clamp(10,30),min:10,max:30,onChanged:s.updateTranslationFontSize)])));
  Future<void> dailySheet(BuildContext c,SettingsProvider s,String l)=>showModalBottomSheet<void>(context:c,builder:(sc)=>Column(mainAxisSize:MainAxisSize.min,children:[_switch(sc,Icons.menu_book_outlined,t(l,'দৈনিক আয়াত','Daily Ayah'),' ',s.showDailyAyah,(v)=>s.setDailyContentPreferences(ayah:v)),_switch(sc,Icons.auto_stories_outlined,t(l,'দৈনিক হাদিস','Daily Hadith'),' ',s.showDailyHadith,(v)=>s.setDailyContentPreferences(hadith:v)),_switch(sc,Icons.volunteer_activism_outlined,t(l,'দৈনিক দোয়া','Daily Dua'),' ',s.showDailyDua,(v)=>s.setDailyContentPreferences(dua:v))]));
  Future<void> resetDialog(BuildContext c,SettingsProvider s,String l)async{final ok=await showDialog<bool>(context:c,builder:(d)=>AlertDialog(title:Text(t(l,'সেটিংস রিসেট করবেন?','Reset settings?')),content:Text(t(l,'সব সেটিংস ডিফল্টে ফিরে যাবে।','All settings will return to defaults.')),actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:Text(t(l,'বাতিল','Cancel'))),FilledButton(onPressed:()=>Navigator.pop(d,true),child:Text(t(l,'রিসেট','Reset')))]));if(ok==true)await s.resetSettings();}
}
