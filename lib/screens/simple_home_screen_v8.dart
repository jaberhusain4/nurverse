import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../services/date_service.dart';
import '../services/last_read_service.dart';
import '../theme/app_theme.dart';
import '../widgets/home/continue_reading_card.dart';
import 'dua/dua_screen.dart';
import 'qibla/qibla_screen.dart';
import 'quran/onudhabon_quran_screen.dart';
import 'tools/asma_ul_husna.dart';
import 'tools/calendar_screen.dart';
import 'tools/ruqyah_screen.dart';
import 'tools/tasbih_screen.dart';

class SimpleHomeScreenV8 extends StatefulWidget {
  const SimpleHomeScreenV8({super.key, this.onNavigateTab});
  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreenV8> createState() => _SimpleHomeScreenV8State();
}

class _SimpleHomeScreenV8State extends State<SimpleHomeScreenV8>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sceneController;
  Timer? _timer;
  DateTime _now = DateTime.now();
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _sceneController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _loadLastRead();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sceneController.dispose();
    super.dispose();
  }

  Future<void> _loadLastRead() async {
    try {
      final value = await LastReadService.getLastRead();
      if (mounted) setState(() => _lastRead = value);
    } catch (_) {
      if (mounted) setState(() => _lastRead = null);
    }
  }

  Future<void> _refreshHome() async {
    await context.read<PrayerController>().refreshLocation();
    await _loadLastRead();
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
    if (mounted) await _refreshHome();
  }

  String _tr(String bn, String en, String languageCode) => languageCode == 'en' ? en : bn;

  String _greeting(String languageCode) {
    if (_now.hour < 12) return languageCode == 'en' ? 'Good Morning' : 'শুভ সকাল';
    if (_now.hour < 16) return languageCode == 'en' ? 'Good Afternoon' : 'শুভ দুপুর';
    if (_now.hour < 19) return languageCode == 'en' ? 'Good Evening' : 'শুভ সন্ধ্যা';
    return languageCode == 'en' ? 'Good Night' : 'শুভ রাত্রি';
  }

  String _clock() {
    final hour = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    return '${hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}';
  }

  String _hijri(String languageCode) {
    final h = HijriCalendar.now();
    const bn = ['মুহররম','সফর','রবিউল আউয়াল','রবিউস সানি','জুমাদিউল আউয়াল','জুমাদিউস সানি','রজব','শাবান','রমজান','শাওয়াল','জিলকদ','জিলহজ'];
    const en = ['Muharram','Safar','Rabi al-Awwal','Rabi al-Thani','Jumada al-Awwal','Jumada al-Thani','Rajab','Sha’ban','Ramadan','Shawwal','Dhul-Qadah','Dhul-Hijjah'];
    String bnDigits(int value) => value.toString().split('').map((d) => '০১২৩৪৫৬৭৮৯'[int.parse(d)]).join();
    final month = languageCode == 'en' ? en[h.hMonth - 1] : bn[h.hMonth - 1];
    final day = languageCode == 'en' ? '${h.hDay}' : bnDigits(h.hDay);
    final year = languageCode == 'en' ? '${h.hYear}' : bnDigits(h.hYear);
    return '$day $month $year';
  }

  List<Map<String, dynamic>> _fivePrayers(PrayerController controller) {
    const keys = ['Fajr','Dhuhr','Asr','Maghrib','Isha'];
    final result = <Map<String, dynamic>>[];
    for (final key in keys) {
      for (final prayer in controller.prayers) {
        final name = (prayer['name'] ?? '').toString().toLowerCase();
        final bn = (prayer['nameBn'] ?? '').toString().toLowerCase();
        final match = name.contains(key.toLowerCase()) ||
            (key == 'Fajr' && bn.contains('ফজর')) ||
            (key == 'Dhuhr' && (bn.contains('যোহর') || bn.contains('জুমু'))) ||
            (key == 'Asr' && bn.contains('আসর')) ||
            (key == 'Maghrib' && bn.contains('মাগরিব')) ||
            (key == 'Isha' && bn.contains('ইশা'));
        if (match) { result.add(prayer); break; }
      }
    }
    return result;
  }

  bool _isProhibited(PrayerController c) {
    final start = c.prohibitedStart;
    final end = c.prohibitedEnd;
    return start != null && end != null && !_now.isBefore(start) && _now.isBefore(end);
  }

  String _countdown(DateTime? target) {
    if (target == null) return '--:--:--';
    final d = target.difference(_now);
    if (d.isNegative) return '00:00:00';
    final total = d.inSeconds;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final languageCode = settings.languageCode;
    final prayers = _fivePrayers(controller);
    final hasLastRead = _lastRead != null && (_lastRead!['surahName']?.toString() ?? '').trim().isNotEmpty;
    final prohibitedNow = _isProhibited(controller);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.seaBlueDark,
          onRefresh: _refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            children: [
              _Header(greeting: _greeting(languageCode), location: controller.currentLocationName, hijri: _hijri(languageCode)),
              const SizedBox(height: 14),
              AnimatedBuilder(
                animation: _sceneController,
                builder: (context, _) => _DesertHero(
                  now: _now,
                  motion: _sceneController.value,
                  clock: _clock(),
                  nextPrayer: controller.nextPrayerName,
                  nextPrayerTime: controller.nextPrayerTime,
                  remaining: controller.timeRemainingForNextPrayer,
                  currentPrayer: controller.currentPrayer,
                  progress: controller.prayerProgress,
                  sunrise: controller.sunriseTime,
                  sunset: controller.sunsetTime,
                ),
              ),
              const SizedBox(height: 22),
              _SectionHeading(title: _tr('আজকের সালাত','Today’s Prayer',languageCode), subtitle: _tr('পাঁচ ওয়াক্ত, পরিষ্কারভাবে','Five prayers, clearly presented',languageCode)),
              const SizedBox(height: 10),
              _PrayerTimeline(prayers: prayers, languageCode: languageCode),
              const SizedBox(height: 22),
              _SectionHeading(title: _tr('প্রয়োজনীয়','Essentials',languageCode), subtitle: _tr('প্রতিদিনের গুরুত্বপূর্ণ সুবিধা','Everyday essentials',languageCode)),
              const SizedBox(height: 10),
              _Essentials(languageCode: languageCode, onQibla: () => _open(const QiblaScreen()), onDua: () => _open(const DuaScreen()), onTasbih: () => _open(const TasbihScreen()), onNames: () => _open(const AsmaUlHusnaScreen()), onCalendar: () => _open(const CalendarScreen()), onRuqyah: () => _open(const RuqyahScreen())),
              if (hasLastRead) ...[
                const SizedBox(height: 22),
                _SectionHeading(title: _tr('কুরআন চালিয়ে যান','Continue Quran',languageCode), subtitle: _tr('যেখান থেকে থেমেছিলেন','Pick up where you left off',languageCode)),
                const SizedBox(height: 10),
                ContinueReadingCard(
                  surahName: _lastRead!['surahName']?.toString() ?? '',
                  paraNo: _lastRead!['paraNo'] is int ? _lastRead!['paraNo'] as int : int.tryParse('${_lastRead!['paraNo']}') ?? 1,
                  pageNo: _lastRead!['pageNo'] is int ? _lastRead!['pageNo'] as int : int.tryParse('${_lastRead!['pageNo']}') ?? 1,
                  progress: ((_lastRead!['progress'] is num ? (_lastRead!['progress'] as num).toDouble() : 0.0).clamp(0.0,1.0)).toDouble(),
                  languageCode: languageCode,
                  onTap: () => _open(const OnudhabonQuranScreen(openLastRead: true)),
                ),
              ],
              const SizedBox(height: 22),
              _Footer(date: DateService.englishDate(), prohibitedNow: prohibitedNow, countdown: _countdown(prohibitedNow ? controller.prohibitedEnd : controller.prohibitedStart), languageCode: languageCode),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting, required this.location, required this.hijri});
  final String greeting; final String location; final String hijri;
  @override
  Widget build(BuildContext context) {
    final theme=Theme.of(context); final primary=theme.colorScheme.primary; final secondary=context.secondaryTextColor;
    return Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(greeting,style:theme.textTheme.titleLarge?.copyWith(fontSize:20,fontWeight:FontWeight.w700,color:primary)),const SizedBox(height:5),Row(children:[Icon(Icons.place_outlined,size:15,color:secondary),const SizedBox(width:4),Expanded(child:Text(location.trim().isEmpty?'Locating…':location.trim(),maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(color:secondary,fontSize:12)))])])),const SizedBox(width:12),Container(constraints:const BoxConstraints(maxWidth:140),padding:const EdgeInsets.symmetric(horizontal:11,vertical:8),decoration:BoxDecoration(color:primary.withValues(alpha:.07),borderRadius:BorderRadius.circular(12)),child:Text(hijri,maxLines:2,overflow:TextOverflow.ellipsis,textAlign:TextAlign.end,style:theme.textTheme.labelMedium?.copyWith(fontSize:10.5,fontWeight:FontWeight.w700))) ]);
  }
}

class _DesertHero extends StatelessWidget {
  const _DesertHero({required this.now,required this.motion,required this.clock,required this.nextPrayer,required this.nextPrayerTime,required this.remaining,required this.currentPrayer,required this.progress,required this.sunrise,required this.sunset});
  final DateTime now; final double motion; final String clock; final String nextPrayer; final String nextPrayerTime; final String remaining; final String currentPrayer; final double progress; final String sunrise; final String sunset;
  @override
  Widget build(BuildContext context){
    final hour=now.hour+now.minute/60; final night=hour<5.5||hour>=19; final dawn=hour>=5.5&&hour<7.5; final dusk=hour>=16.5&&hour<19; final phase=dawn?0.0:dusk?1.0:night?2.0:.5; final palette=_ScenePalette.fromPhase(phase); final theme=Theme.of(context); final primary=theme.colorScheme.primary;
    return Container(clipBehavior:Clip.antiAlias,decoration:BoxDecoration(borderRadius:BorderRadius.circular(28),boxShadow:[BoxShadow(color:Colors.black.withValues(alpha:.16),blurRadius:30,offset:const Offset(0,16))]),child:SizedBox(height:430,child:Stack(fit:StackFit.expand,children:[CustomPaint(painter:_DesertScenePainter(palette:palette,motion:motion,night:night,dusk:dusk)),Align(alignment:Alignment.topCenter,child:Padding(padding:const EdgeInsets.fromLTRB(18,18,18,0),child:Row(children:[Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),decoration:BoxDecoration(color:Colors.white.withValues(alpha:.13),borderRadius:BorderRadius.circular(14)),child:Text(clock,style:theme.textTheme.titleLarge?.copyWith(color:Colors.white,fontSize:22,fontWeight:FontWeight.w500,fontFeatures:const[FontFeature.tabularFigures()]))),const Spacer(),Icon(night?Icons.nightlight_round:dusk?Icons.wb_twilight_rounded:Icons.wb_sunny_rounded,color:Colors.white.withValues(alpha:.85),size:20)]))),Positioned(left:16,right:16,bottom:16,child:ClipRRect(borderRadius:BorderRadius.circular(24),child:BackdropFilter(filter:ImageFilter.blur(sigmaX:18,sigmaY:18),child:Container(padding:const EdgeInsets.fromLTRB(18,15,18,14),decoration:BoxDecoration(color:Color.alphaBlend(Colors.black.withValues(alpha:night?.34:.24),palette.glass),borderRadius:BorderRadius.circular(24),border:Border.all(color:Colors.white.withValues(alpha:.12)),),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(nextPrayer.isEmpty?'—':nextPrayer,style:theme.textTheme.headlineSmall?.copyWith(color:Colors.white,fontSize:24,fontWeight:FontWeight.w700))),if(currentPrayer.isNotEmpty)Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(color:primary.withValues(alpha:.25),borderRadius:BorderRadius.circular(8)),child:Text(currentPrayer,style:theme.textTheme.labelSmall?.copyWith(color:Colors.white,fontSize:10,fontWeight:FontWeight.w700)))]),const SizedBox(height:2),Text(nextPrayerTime.isEmpty?'—':nextPrayerTime,style:TextStyle(color:Colors.white.withValues(alpha:.72),fontSize:12,fontWeight:FontWeight.w600)),const SizedBox(height:8),Row(crossAxisAlignment:CrossAxisAlignment.end,children:[Expanded(child:Text(remaining.isEmpty?'--:--:--':remaining,style:theme.textTheme.displaySmall?.copyWith(color:Colors.white,fontSize:36,height:.95,fontWeight:FontWeight.w600,fontFeatures:const[FontFeature.tabularFigures()]))),Text('NEXT',style:TextStyle(color:Colors.white.withValues(alpha:.55),fontSize:9,letterSpacing:1.2,fontWeight:FontWeight.w700))]),const SizedBox(height:12),_HeroProgress(value:progress.clamp(0.0,1.0).toDouble(),accent:primary),const SizedBox(height:12),Row(children:[_SunData(icon:Icons.wb_twilight_rounded,label:'Sunrise',value:sunrise),const Spacer(),_SunData(icon:Icons.wb_sunny_outlined,label:'Sunset',value:sunset,end:true)])]))))))])));
  }
}

class _ScenePalette { const _ScenePalette({required this.skyTop,required this.skyBottom,required this.haze,required this.farDune,required this.midDune,required this.foreDune,required this.glass}); final Color skyTop,skyBottom,haze,farDune,midDune,foreDune,glass;
  static _ScenePalette fromPhase(double phase){ if(phase==2.0)return const _ScenePalette(skyTop:Color(0xFF061827),skyBottom:Color(0xFF17425F),haze:Color(0xFF2E6C87),farDune:Color(0xFF183647),midDune:Color(0xFF0D2738),foreDune:Color(0xFF071720),glass:Color(0x66243B4C)); if(phase==1.0)return const _ScenePalette(skyTop:Color(0xFF234B71),skyBottom:Color(0xFFC07B56),haze:Color(0xFFE2B18E),farDune:Color(0xFF855B4A),midDune:Color(0xFF6A493E),foreDune:Color(0xFF382F2D),glass:Color(0x66363B45)); if(phase==0.0)return const _ScenePalette(skyTop:Color(0xFF1B587A),skyBottom:Color(0xFFE9C7A0),haze:Color(0xFFF1DAB9),farDune:Color(0xFF9D7657),midDune:Color(0xFF78543D),foreDune:Color(0xFF4A372B),glass:Color(0x66412F25)); return const _ScenePalette(skyTop:Color(0xFF2B7AA0),skyBottom:Color(0xFFE6B978),haze:Color(0xFFF0D3A2),farDune:Color(0xFFAF7B42),midDune:Color(0xFF956134),foreDune:Color(0xFF58402B),glass:Color(0x663F352B)); }
}

class _DesertScenePainter extends CustomPainter { const _DesertScenePainter({required this.palette,required this.motion,required this.night,required this.dusk}); final _ScenePalette palette; final double motion; final bool night; final bool dusk;
  @override void paint(Canvas canvas,Size size){ final rect=Offset.zero&size; canvas.drawRect(rect,Paint()..shader=LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[palette.skyTop,palette.skyBottom]).createShader(rect)); _atmosphere(canvas,size); _celestial(canvas,size); _clouds(canvas,size); _dunes(canvas,size); _oasis(canvas,size); _palms(canvas,size); _camel(canvas,size); }
  void _atmosphere(Canvas canvas,Size size){canvas.drawRect(Rect.fromLTWH(0,size.height*.42,size.width,size.height*.20),Paint()..color=palette.haze.withValues(alpha:.18));}
  void _celestial(Canvas canvas,Size size){final x=size.width*(.74+math.sin(motion*math.pi)*.035);final y=night?size.height*.18:dusk?size.height*.24:size.height*.18;if(night){canvas.drawCircle(Offset(x,y),28,Paint()..color=Colors.white.withValues(alpha:.09));canvas.drawCircle(Offset(x,y),17,Paint()..color=const Color(0xFFE7F4FF));canvas.drawCircle(Offset(x+6,y-4),17,Paint()..color=palette.skyTop);for(final s in const[Offset(.12,.16),Offset(.22,.24),Offset(.61,.13),Offset(.84,.27),Offset(.45,.12),Offset(.91,.17)])canvas.drawCircle(Offset(size.width*s.dx,size.height*s.dy),1.4,Paint()..color=Colors.white.withValues(alpha:.45));return;}final c=dusk?const Color(0xFFFFB36A):const Color(0xFFFFF2B2);canvas.drawCircle(Offset(x,y),58,Paint()..color=c.withValues(alpha:.22));canvas.drawCircle(Offset(x,y),24,Paint()..color=c);}
  void _clouds(Canvas canvas,Size size){final p=Paint()..color=Colors.white.withValues(alpha:night?.045:.19);final drift=(motion-.5)*34;for(int i=0;i<4;i++){final x=size.width*(.06+i*.26)+drift*(i.isEven?1:-.6);final y=size.height*(.18+(i%2)*.08);_cloud(canvas,Offset(x,y),1+i*.08,p);}}
  void _cloud(Canvas canvas,Offset o,double s,Paint p){canvas.drawCircle(o,13*s,p);canvas.drawCircle(o+Offset(16*s,-4*s),18*s,p);canvas.drawCircle(o+Offset(34*s,1*s),12*s,p);canvas.drawOval(Rect.fromCenter(center:o+Offset(18*s,6*s),width:58*s,height:22*s),p);}
  void _dunes(Canvas canvas,Size size){Path dune(double y,double amp,double f){final p=Path()..moveTo(0,size.height*y);for(int i=0;i<=40;i++){final x=size.width*i/40;final yy=size.height*y+math.sin(i/40*math.pi*f+motion*.6)*size.height*amp;p.lineTo(x,yy);}p.lineTo(size.width,size.height);p.lineTo(0,size.height);p.close();return p;}canvas.drawPath(dune(.56,.035,2.2),Paint()..color=palette.farDune);canvas.drawPath(dune(.67,.052,2.7),Paint()..color=palette.midDune);canvas.drawPath(dune(.79,.075,3),Paint()..color=palette.foreDune);}
  void _oasis(Canvas canvas,Size size){final c=Offset(size.width*.48,size.height*.72);canvas.drawOval(Rect.fromCenter(center:c,width:size.width*.23,height:size.height*.075),Paint()..color=const Color(0xFF5F9E98).withValues(alpha:.55));canvas.drawOval(Rect.fromCenter(center:c+const Offset(0,-2),width:size.width*.14,height:size.height*.04),Paint()..color=const Color(0xFFB3E0D4).withValues(alpha:.62));}
  void _palms(Canvas canvas,Size size){_palm(canvas,Offset(size.width*.16,size.height*.58),.78);_palm(canvas,Offset(size.width*.79,size.height*.61),.62);_palm(canvas,Offset(size.width*.56,size.height*.63),.48);}
  void _palm(Canvas canvas,Offset base,double scale){final trunk=Paint()..color=palette.foreDune.withValues(alpha:.92);canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(base.dx-3*scale,base.dy-55*scale,6*scale,55*scale),Radius.circular(3*scale)),trunk);final leaf=Paint()..color=palette.foreDune.withValues(alpha:.96)..strokeWidth=4*scale..strokeCap=StrokeCap.round;final top=base+Offset(0,-55*scale);for(int i=0;i<7;i++){final a=-math.pi*.92+i*math.pi*.30;canvas.drawLine(top,top+Offset(math.cos(a)*26*scale,math.sin(a)*18*scale),leaf);}}
  void _camel(Canvas canvas,Size size){final p=Paint()..color=palette.foreDune.withValues(alpha:.9);final y=size.height*.76;final x=size.width*(.31+motion*.045);canvas.drawOval(Rect.fromCenter(center:Offset(x,y-20),width:42,height:18),p);canvas.drawCircle(Offset(x+18,y-34),8,p);final leg=Paint()..color=palette.foreDune.withValues(alpha:.9)..strokeWidth=3.5..strokeCap=StrokeCap.round;for(final dx in const[-10.0,8.0])canvas.drawLine(Offset(x+dx,y-10),Offset(x+dx-4,y+6),leg);canvas.drawLine(Offset(x+26,y-38),Offset(x+34,y-47),leg);}
  @override bool shouldRepaint(covariant _DesertScenePainter old)=>old.motion!=motion||old.night!=night||old.dusk!=dusk||old.palette.skyTop!=palette.skyTop;
}

class _HeroProgress extends StatelessWidget { const _HeroProgress({required this.value,required this.accent}); final double value; final Color accent; @override Widget build(BuildContext context)=>SizedBox(height:14,child:CustomPaint(painter:_HeroProgressPainter(value:value,accent:accent))); }
class _HeroProgressPainter extends CustomPainter { const _HeroProgressPainter({required this.value,required this.accent}); final double value; final Color accent; @override void paint(Canvas c,Size s){final y=s.height/2;final end=s.width-2;final x=2+(end-2)*value.clamp(0.0,1.0);c.drawLine(Offset(2,y),Offset(end,y),Paint()..color=Colors.white.withValues(alpha:.16)..strokeWidth=4..strokeCap=StrokeCap.round);c.drawLine(Offset(2,y),Offset(x,y),Paint()..color=accent..strokeWidth=4..strokeCap=StrokeCap.round);c.drawCircle(Offset(x,y),7,Paint()..color=accent.withValues(alpha:.26));c.drawCircle(Offset(x,y),3.5,Paint()..color=Colors.white);} @override bool shouldRepaint(covariant _HeroProgressPainter old)=>old.value!=value||old.accent!=accent; }
class _SunData extends StatelessWidget { const _SunData({required this.icon,required this.label,required this.value,this.end=false}); final IconData icon; final String label,value; final bool end; @override Widget build(BuildContext context)=>Row(mainAxisSize:MainAxisSize.min,children:[if(!end)Icon(icon,size:15,color:Colors.white.withValues(alpha:.70)),if(!end)const SizedBox(width:5),Column(crossAxisAlignment:end?CrossAxisAlignment.end:CrossAxisAlignment.start,children:[Text(label,style:TextStyle(color:Colors.white.withValues(alpha:.58),fontSize:9)),const SizedBox(height:2),Text(value,style:const TextStyle(color:Colors.white,fontSize:11,fontWeight:FontWeight.w700,fontFeatures:[FontFeature.tabularFigures()]))]),if(end)const SizedBox(width:5),if(end)Icon(icon,size:15,color:Colors.white.withValues(alpha:.70))]); }
class _SectionHeading extends StatelessWidget { const _SectionHeading({required this.title,required this.subtitle}); final String title,subtitle; @override Widget build(BuildContext context){final t=Theme.of(context);return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:t.textTheme.titleMedium?.copyWith(fontSize:17,fontWeight:FontWeight.w700)),const SizedBox(height:2),Text(subtitle,style:TextStyle(color:context.secondaryTextColor,fontSize:11.5))]);} }
class _PrayerTimeline extends StatelessWidget { const _PrayerTimeline({required this.prayers,required this.languageCode}); final List<Map<String,dynamic>> prayers; final String languageCode; @override Widget build(BuildContext context){final theme=Theme.of(context);final primary=theme.colorScheme.primary;return Container(decoration:BoxDecoration(color:context.cardColor,borderRadius:BorderRadius.circular(22)),child:Column(children:List.generate(5,(i){final p=i<prayers.length?prayers[i]:const <String,dynamic>{};final current=p['isCurrent']==true;final name=languageCode=='en'?(p['name']?.toString()??'—'):(p['nameBn']?.toString()??'—');final time=p['start']?.toString()??'—';return Container(padding:const EdgeInsets.symmetric(horizontal:15,vertical:12),decoration:BoxDecoration(color:current?primary.withValues(alpha:.08):Colors.transparent,borderRadius:BorderRadius.circular(16)),child:Row(children:[Container(width:34,height:34,decoration:BoxDecoration(color:current?primary.withValues(alpha:.14):primary.withValues(alpha:.07),borderRadius:BorderRadius.circular(11)),child:Icon(_iconForPrayer(i),size:18,color:primary)),const SizedBox(width:10),Expanded(child:Text(name,style:theme.textTheme.bodyLarge?.copyWith(fontSize:15,fontWeight:current?FontWeight.w800:FontWeight.w600))),if(current)Container(padding:const EdgeInsets.symmetric(horizontal:7,vertical:4),decoration:BoxDecoration(color:primary.withValues(alpha:.14),borderRadius:BorderRadius.circular(8)),child:Text('NOW',style:TextStyle(color:primary,fontSize:9,fontWeight:FontWeight.w800))),const SizedBox(width:8),Text(time,style:TextStyle(color:context.primaryTextColor,fontSize:14,fontWeight:FontWeight.w700,fontFeatures:const[FontFeature.tabularFigures()]))]));})));}
 IconData _iconForPrayer(int i){const icons=[Icons.nightlight_round,Icons.wb_sunny_outlined,Icons.wb_twilight_rounded,Icons.wb_sunny_rounded,Icons.dark_mode_rounded];return icons[i];} }
class _Essentials extends StatelessWidget { const _Essentials({required this.onQibla,required this.onDua,required this.onTasbih,required this.onNames,required this.onCalendar,required this.onRuqyah,required this.languageCode}); final VoidCallback onQibla,onDua,onTasbih,onNames,onCalendar,onRuqyah; final String languageCode; @override Widget build(BuildContext context){final primary=Theme.of(context).colorScheme.primary;final items=[('কিবলা','Qibla',Icons.explore_rounded,onQibla),('দোয়া','Dua',Icons.auto_awesome_rounded,onDua),('তাসবিহ','Tasbih',Icons.fingerprint_rounded,onTasbih),('৯৯ নাম','99 Names',Icons.favorite_rounded,onNames),('ক্যালেন্ডার','Calendar',Icons.calendar_month_rounded,onCalendar),('রুকইয়াহ','Ruqyah',Icons.menu_book_rounded,onRuqyah)];return GridView.builder(itemCount:6,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,mainAxisSpacing:10,crossAxisSpacing:10,childAspectRatio:.98),itemBuilder:(context,i){final it=items[i];final label=languageCode=='en'?it.$2:it.$1;return Material(color:Colors.transparent,child:InkWell(onTap:it.$4,borderRadius:BorderRadius.circular(18),child:Container(decoration:BoxDecoration(color:context.cardColor,borderRadius:BorderRadius.circular(18)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Container(width:42,height:42,decoration:BoxDecoration(color:primary.withValues(alpha:.10),borderRadius:BorderRadius.circular(14)),child:Icon(it.$3,color:primary,size:21)),const SizedBox(height:8),Text(label,style:Theme.of(context).textTheme.labelLarge?.copyWith(fontSize:12.5,fontWeight:FontWeight.w700))]))));});}}
class _Footer extends StatelessWidget { const _Footer({required this.date,required this.prohibitedNow,required this.countdown,required this.languageCode}); final String date; final bool prohibitedNow; final String countdown; final String languageCode; @override Widget build(BuildContext context){final primary=Theme.of(context).colorScheme.primary;final title=languageCode=='en'?'Prohibited time':'নিষিদ্ধ সময়';final state=prohibitedNow?(languageCode=='en'?'Active now':'এখন চলছে'):(languageCode=='en'?'Next window':'পরবর্তী সময়');return Container(padding:const EdgeInsets.symmetric(horizontal:15,vertical:13),decoration:BoxDecoration(color:context.cardColor,borderRadius:BorderRadius.circular(18)),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(date,style:Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize:12.5,fontWeight:FontWeight.w700)),const SizedBox(height:4),Text(title,style:TextStyle(color:context.secondaryTextColor,fontSize:10.5))])),Column(crossAxisAlignment:CrossAxisAlignment.end,children:[Text(state,style:TextStyle(color:primary,fontSize:10.5,fontWeight:FontWeight.w700)),const SizedBox(height:3),Text(countdown,style:Theme.of(context).textTheme.titleSmall?.copyWith(fontSize:14,fontWeight:FontWeight.w800,fontFeatures:const[FontFeature.tabularFigures()]))])]));}}
