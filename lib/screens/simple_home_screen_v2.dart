import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../providers/settings_provider.dart';
import '../services/date_service.dart';
import '../services/last_read_service.dart';
import '../theme/app_theme.dart';
import '../widgets/home/continue_reading_card.dart';
import 'dua/dua_screen.dart';
import 'qibla/qibla_screen.dart';
import 'tools/asma_ul_husna.dart';
import 'tools/calendar_screen.dart';
import 'tools/ruqyah_screen.dart';
import 'tools/tasbih_screen.dart';
import 'quran/onudhabon_quran_screen.dart';

class SimpleHomeScreenV2 extends StatefulWidget {
  const SimpleHomeScreenV2({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreenV2> createState() => _SimpleHomeScreenV2State();
}

class _SimpleHomeScreenV2State extends State<SimpleHomeScreenV2> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _loadLastRead();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  String _label(String languageCode, String bn, String en) => languageCode == 'en' ? en : bn;

  String _greeting(String languageCode) {
    if (languageCode == 'en') {
      if (_now.hour < 12) return 'Good Morning';
      if (_now.hour < 18) return 'Good Afternoon';
      return 'Good Evening';
    }
    if (_now.hour < 12) return 'শুভ সকাল';
    if (_now.hour < 18) return 'শুভ বিকেল';
    return 'শুভ সন্ধ্যা';
  }

  String _clock() {
    final h = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');
    return '$h:$m:$s ${_now.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _hijri(String languageCode) {
    final h = HijriCalendar.now();
    const bn = ['মুহররম','সফর','রবিউল আউয়াল','রবিউস সানি','জুমাদিউল আউয়াল','জুমাদিউস সানি','রজব','শাবান','রমজান','শাওয়াল','জিলকদ','জিলহজ'];
    const en = ['Muharram','Safar','Rabi al-Awwal','Rabi al-Thani','Jumada al-Awwal','Jumada al-Thani','Rajab','Sha’ban','Ramadan','Shawwal','Dhul-Qadah','Dhul-Hijjah'];
    String digits(int value) {
      const b = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
      return value.toString().split('').map((d) => b[int.parse(d)]).join();
    }
    final month = languageCode == 'en' ? en[h.hMonth - 1] : bn[h.hMonth - 1];
    return '${languageCode == 'en' ? h.hDay : digits(h.hDay)} $month ${languageCode == 'en' ? h.hYear : digits(h.hYear)}';
  }

  List<Map<String, dynamic>> _fivePrayers(PrayerController controller) {
    const keys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
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
        if (match) {
          result.add(prayer);
          break;
        }
      }
    }
    return result;
  }

  String _countdownTo(DateTime? target) {
    if (target == null) return '--:--:--';
    final difference = target.difference(_now);
    if (difference.isNegative) return '00:00:00';
    final totalSeconds = difference.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool _isProhibited(PrayerController controller) {
    final start = controller.prohibitedStart;
    final end = controller.prohibitedEnd;
    return start != null && end != null && !_now.isBefore(start) && _now.isBefore(end);
  }

  String _prohibitedLabel(PrayerController controller, String languageCode) {
    return _isProhibited(controller)
        ? _label(languageCode, 'নিষিদ্ধ সময় চলছে', 'PROHIBITED TIME')
        : _label(languageCode, 'পরবর্তী নিষিদ্ধ সময়', 'NEXT PROHIBITED TIME');
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final languageCode = settings.languageCode;
    final primary = Theme.of(context).colorScheme.primary;
    final prayers = _fivePrayers(controller);
    final lastRead = _lastRead;
    final hasLastRead = lastRead != null && (lastRead['surahName']?.toString() ?? '').trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          color: primary,
          onRefresh: _refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
            children: [
              _Header(
                greeting: _greeting(languageCode),
                location: controller.currentLocationName,
                date: _hijri(languageCode),
                languageCode: languageCode,
              ),
              const SizedBox(height: 12),
              _Hero(
                phase: _Phase.fromHour(_now.hour),
                clock: _clock(),
                currentPrayer: controller.currentPrayer,
                nextPrayer: controller.nextPrayerName,
                nextPrayerTime: controller.nextPrayerTime,
                remaining: controller.timeRemainingForNextPrayer,
                progress: controller.prayerProgress,
                sunrise: controller.sunriseTime,
                sunset: controller.sunsetTime,
                languageCode: languageCode,
              ),
              const SizedBox(height: 12),
              _PrayerStrip(prayers: prayers, languageCode: languageCode),
              const SizedBox(height: 15),
              _SectionTitle(_label(languageCode, 'প্রয়োজনীয়', 'Essentials')),
              const SizedBox(height: 5),
              _Essentials(
                languageCode: languageCode,
                onQibla: () => _open(const QiblaScreen()),
                onDua: () => _open(const DuaScreen()),
                onTasbih: () => _open(const TasbihScreen()),
                onNames: () => _open(const AsmaUlHusnaScreen()),
                onHadith: () => widget.onNavigateTab?.call(3),
                onCalendar: () => _open(const CalendarScreen()),
                onRuqyah: () => _open(const RuqyahScreen()),
              ),
              if (hasLastRead) ...[
                const SizedBox(height: 16),
                _SectionTitle(_label(languageCode, 'কুরআন চালিয়ে যান', 'Continue Quran')),
                const SizedBox(height: 7),
                ContinueReadingCard(
                  surahName: lastRead['surahName']?.toString() ?? '',
                  paraNo: lastRead['paraNo'] is int ? lastRead['paraNo'] as int : int.tryParse('${lastRead['paraNo']}') ?? 1,
                  pageNo: lastRead['pageNo'] is int ? lastRead['pageNo'] as int : int.tryParse('${lastRead['pageNo']}') ?? 1,
                  progress: ((lastRead['progress'] is num ? (lastRead['progress'] as num).toDouble() : 0.0).clamp(0.0, 1.0)).toDouble(),
                  languageCode: languageCode,
                  onTap: () => _open(const OnudhabonQuranScreen(openLastRead: true)),
                ),
              ],
              const SizedBox(height: 14),
              _ProhibitedCard(
                label: _prohibitedLabel(controller, languageCode),
                countdown: _countdownTo(_isProhibited(controller) ? controller.prohibitedEnd : controller.prohibitedStart),
                active: _isProhibited(controller),
                languageCode: languageCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting, required this.location, required this.date, required this.languageCode});
  final String greeting, location, date, languageCode;

  @override
  Widget build(BuildContext context) {
    final secondary = context.secondaryTextColor;
    final city = location.trim().isEmpty ? (languageCode == 'en' ? 'Locating…' : 'লোকেশন নির্ধারণ হচ্ছে…') : location.trim();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(greeting, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 21, height: 1.15, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary)),
      const SizedBox(height: 5),
      Row(children: [
        Icon(Icons.location_on_rounded, size: 16, color: secondary),
        const SizedBox(width: 5),
        Expanded(child: Text(city, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 13.5, height: 1.2))),
        const SizedBox(width: 8),
        Text(date, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 13, height: 1.2)),
      ]),
    ]);
  }
}

enum _Phase { dawn, day, sunset, night;
  static _Phase fromHour(int hour) {
    if (hour < 5) return _Phase.night;
    if (hour < 8) return _Phase.dawn;
    if (hour < 16) return _Phase.day;
    if (hour < 19) return _Phase.sunset;
    return _Phase.night;
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.phase, required this.clock, required this.currentPrayer, required this.nextPrayer, required this.nextPrayerTime, required this.remaining, required this.progress, required this.sunrise, required this.sunset, required this.languageCode});
  final _Phase phase; final String clock, currentPrayer, nextPrayer, nextPrayerTime, remaining, sunrise, sunset, languageCode; final double progress;

  Color get _top => const { _Phase.dawn: Color(0xFF8FC7E8), _Phase.day: Color(0xFF43B7E8), _Phase.sunset: Color(0xFFE48C78), _Phase.night: Color(0xFF0B2039)}[phase]!;
  Color get _bottom => const { _Phase.dawn: Color(0xFFF4D3B3), _Phase.day: Color(0xFFE8F7FC), _Phase.sunset: Color(0xFFF4C8AE), _Phase.night: Color(0xFF15334F)}[phase]!;
  Color get _ground => const { _Phase.dawn: Color(0xFF294E5D), _Phase.day: Color(0xFF24546A), _Phase.sunset: Color(0xFF32435A), _Phase.night: Color(0xFF081422)}[phase]!;
  String _l(String bn, String en) => languageCode == 'en' ? en : bn;

  @override
  Widget build(BuildContext context) {
    final safe = progress.clamp(0.0, 1.0).toDouble();
    return SizedBox(
      height: 318,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(fit: StackFit.expand, children: [
          CustomPaint(painter: _HeroPainter(top: _top, bottom: _bottom, ground: _ground, night: phase == _Phase.night)),
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 16, 19, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(_l('পরের সালাত', 'NEXT PRAYER'), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const Spacer(),
                Text(phase.name.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: .88), fontSize: 10, fontWeight: FontWeight.w800)),
              ]),
              const Spacer(),
              Text(nextPrayer.isEmpty ? '--' : nextPrayer, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 31, height: 1.05, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(nextPrayerTime.isEmpty ? '--:--' : nextPrayerTime, style: const TextStyle(color: Colors.white, fontSize: 14.5, height: 1.1, fontWeight: FontWeight.w600)),
              const SizedBox(height: 13),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: Text(remaining.isEmpty ? '--:--:--' : remaining, style: const TextStyle(color: Colors.white, fontSize: 38, height: .95, fontWeight: FontWeight.w300, letterSpacing: -1.2, fontFeatures: [FontFeature.tabularFigures()]))),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(_l('এখন', 'NOW'), style: TextStyle(color: Colors.white.withValues(alpha: .68), fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                  const SizedBox(height: 2),
                  Text(clock, style: const TextStyle(color: Colors.white, fontFamily: 'sans-serif-condensed', fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 1.1, fontFeatures: [FontFeature.tabularFigures()])),
                ]),
              ]),
              const SizedBox(height: 12),
              ClipRRect(borderRadius: BorderRadius.circular(50), child: LinearProgressIndicator(minHeight: 6, value: safe, backgroundColor: Colors.white.withValues(alpha: .16), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
              const SizedBox(height: 10),
              Row(children: [
                _HeroChip(icon: Icons.mosque_rounded, text: currentPrayer.isEmpty ? '--' : currentPrayer),
                const Spacer(),
                _HeroTime(label: _l('সূর্যোদয়', 'Sunrise'), value: sunrise),
                const SizedBox(width: 10),
                _HeroTime(label: _l('সূর্যাস্ত', 'Sunset'), value: sunset),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _HeroPainter extends CustomPainter {
  const _HeroPainter({required this.top, required this.bottom, required this.ground, required this.night});
  final Color top, bottom, ground; final bool night;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom]).createShader(rect));
    canvas.drawCircle(Offset(size.width * .77, size.height * (night ? .23 : .28)), night ? 21 : 24, Paint()..color = night ? const Color(0xFFE7F0FA) : const Color(0xFFFFE2AC));
    if (night) {
      final star = Paint()..color = Colors.white.withValues(alpha: .72);
      for (final p in const [Offset(.12,.16),Offset(.28,.28),Offset(.46,.13),Offset(.61,.22),Offset(.84,.13),Offset(.70,.31)]) {
        canvas.drawCircle(Offset(size.width * p.dx, size.height * p.dy), 1.3, star);
      }
    }
    final hill = Paint()..color = Color.lerp(ground, Colors.white, .18)!.withValues(alpha: .75);
    final h = Path()..moveTo(0, size.height*.67)..quadraticBezierTo(size.width*.20,size.height*.53,size.width*.42,size.height*.65)..quadraticBezierTo(size.width*.63,size.height*.46,size.width,size.height*.64)..lineTo(size.width,size.height)..lineTo(0,size.height)..close();
    canvas.drawPath(h, hill);
    final base = Paint()..color = ground;
    final g = Path()..moveTo(0,size.height*.72)..quadraticBezierTo(size.width*.30,size.height*.64,size.width*.53,size.height*.73)..quadraticBezierTo(size.width*.77,size.height*.65,size.width,size.height*.72)..lineTo(size.width,size.height)..lineTo(0,size.height)..close();
    canvas.drawPath(g, base);
    final mosque = Paint()..color = ground.withValues(alpha:.98);
    canvas.drawRect(Rect.fromLTWH(size.width*.30,size.height*.63,size.width*.40,size.height*.22),mosque);
    final dome = Path()..moveTo(size.width*.37,size.height*.64)..quadraticBezierTo(size.width*.50,size.height*.48,size.width*.63,size.height*.64)..close();
    canvas.drawPath(dome, mosque);
    canvas.drawRect(Rect.fromLTWH(size.width*.477,size.height*.46,size.width*.045,size.height*.18),mosque);
    canvas.drawCircle(Offset(size.width*.50,size.height*.45),4,mosque);
    for (final x in [.27,.70]) {
      canvas.drawRect(Rect.fromLTWH(size.width*x,size.height*.54,size.width*.028,size.height*.32),mosque);
      canvas.drawCircle(Offset(size.width*(x+.014),size.height*.535),3,mosque);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroPainter oldDelegate) => oldDelegate.top != top || oldDelegate.bottom != bottom || oldDelegate.ground != ground || oldDelegate.night != night;
}

class _PrayerStrip extends StatelessWidget {
  const _PrayerStrip({required this.prayers, required this.languageCode});
  final List<Map<String, dynamic>> prayers; final String languageCode;
  String _name(Map<String, dynamic> p) => languageCode == 'en' ? (p['name']?.toString() ?? '--') : (p['nameBn']?.toString() ?? '--');

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = context.secondaryTextColor;
    return Row(children: List.generate(5, (i) {
      final p = i < prayers.length ? prayers[i] : const <String,dynamic>{};
      final active = p['isCurrent'] == true;
      return Expanded(child: Container(
        margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
        decoration: BoxDecoration(color: active ? primary.withValues(alpha:.10) : context.cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: active ? primary.withValues(alpha:.22) : primary.withValues(alpha:.06))),
        child: Column(children: [
          Text(_name(p), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: active ? primary : secondary, fontSize: 11.5, height: 1.1, fontWeight: active ? FontWeight.w800 : FontWeight.w600)),
          const SizedBox(height: 4),
          Text(p['start']?.toString() ?? '--:--', maxLines: 1, style: TextStyle(color: active ? primary : context.primaryTextColor, fontSize: 11.5, height: 1.1, fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()])),
        ]),
      ));
    }));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title); final String title;
  @override
  Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17, height: 1.2, fontWeight: FontWeight.w800));
}

class _Essentials extends StatelessWidget {
  const _Essentials({required this.languageCode, required this.onQibla, required this.onDua, required this.onTasbih, required this.onNames, required this.onHadith, required this.onCalendar, required this.onRuqyah});
  final String languageCode; final VoidCallback onQibla,onDua,onTasbih,onNames,onHadith,onCalendar,onRuqyah;
  String _l(String bn,String en)=>languageCode=='en'?en:bn;

  @override
  Widget build(BuildContext context) {
    final first = [
      _Item(Icons.explore_rounded, _l('কিবলা','Qibla'), onQibla),
      _Item(Icons.favorite_rounded, _l('দোয়া','Dua'), onDua),
      _Item(Icons.touch_app_rounded, _l('তাসবিহ','Tasbih'), onTasbih),
      _Item(Icons.auto_awesome_rounded, _l('৯৯ নাম','99 Names'), onNames),
      _Item(Icons.auto_stories_rounded, _l('হাদিস','Hadith'), onHadith),
    ];
    return Column(children: [
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: first.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:8,mainAxisSpacing:8,childAspectRatio:1.30),
        itemBuilder: (_, i) => _Tile(item: first[i]),
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 112, height: 82, child: _Tile(item: _Item(Icons.calendar_month_rounded, _l('ক্যালেন্ডার','Calendar'), onCalendar))),
        const SizedBox(width: 8),
        SizedBox(width: 112, height: 82, child: _Tile(item: _Item(Icons.health_and_safety_rounded, _l('রুকইয়াহ','Ruqyah'), onRuqyah))),
      ]),
    ]);
  }
}

class _Item { const _Item(this.icon,this.title,this.onTap); final IconData icon; final String title; final VoidCallback onTap; }

class _Tile extends StatelessWidget {
  const _Tile({required this.item}); final _Item item;
  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.seaBlueDark,AppColors.seaBlue,Color(0xFF0F8FB6),Color(0xFF2C7FB3),Color(0xFF4A90B8),AppColors.softAqua];
    final color = colors[item.icon.codePoint.abs() % colors.length];
    return Material(color: Colors.transparent, child: InkWell(onTap:item.onTap,borderRadius:BorderRadius.circular(18),child:Ink(
      decoration: BoxDecoration(color:color.withValues(alpha:.075),borderRadius:BorderRadius.circular(18),border:Border.all(color:color.withValues(alpha:.14))),
      child: Column(mainAxisAlignment:MainAxisAlignment.center,children:[
        Container(width:36,height:36,decoration:BoxDecoration(color:color.withValues(alpha:.13),shape:BoxShape.circle),child:Icon(item.icon,color:color,size:20)),
        const SizedBox(height:6),
        Text(item.title,maxLines:1,overflow:TextOverflow.ellipsis,textAlign:TextAlign.center,style:TextStyle(color:context.primaryTextColor,fontSize:12.5,height:1.1,fontWeight:FontWeight.w700)),
      ]),
    )));
  }
}

class _ProhibitedCard extends StatelessWidget {
  const _ProhibitedCard({required this.label,required this.countdown,required this.active,required this.languageCode});
  final String label,countdown,languageCode; final bool active;

  @override
  Widget build(BuildContext context) {
    final primary=Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.fromLTRB(14,12,14,13),
      decoration: BoxDecoration(color:context.cardColor,borderRadius:BorderRadius.circular(18),border:Border.all(color:primary.withValues(alpha:.08))),
      child: Row(children:[
        Container(width:38,height:38,decoration:BoxDecoration(color:primary.withValues(alpha:.10),borderRadius:BorderRadius.circular(12)),child:Icon(active?Icons.block_rounded:Icons.schedule_rounded,color:primary,size:20)),
        const SizedBox(width:10),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:TextStyle(color:context.primaryTextColor,fontSize:12.5,fontWeight:FontWeight.w800)),const SizedBox(height:3),Text(languageCode=='en'?'Live countdown':'লাইভ কাউন্টডাউন',style:TextStyle(color:context.secondaryTextColor,fontSize:11.5))])),
        Text(countdown,style:TextStyle(color:primary,fontFamily:'sans-serif-condensed',fontSize:19,fontWeight:FontWeight.w500,letterSpacing:1.0,fontFeatures:const [FontFeature.tabularFigures()])),
      ]),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon,required this.text}); final IconData icon; final String text;
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:Colors.white.withValues(alpha:.11),borderRadius:BorderRadius.circular(999)),child:Row(mainAxisSize:MainAxisSize.min,children:[Icon(icon,size:15,color:Colors.white),const SizedBox(width:5),Text(text,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.white,fontSize:11.5,fontWeight:FontWeight.w800))]));
}

class _HeroTime extends StatelessWidget {
  const _HeroTime({required this.label,required this.value}); final String label,value;
  @override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.end,children:[Text(label,style:TextStyle(color:Colors.white.withValues(alpha:.60),fontSize:10,fontWeight:FontWeight.w700)),const SizedBox(height:1),Text(value,style:const TextStyle(color:Colors.white,fontSize:11.5,fontWeight:FontWeight.w800))]);
}
