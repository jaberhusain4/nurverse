import 'dart:async';

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
import 'quran/onudhabon_quran_screen.dart';
import 'tools/asma_ul_husna.dart';
import 'tools/tasbih_screen.dart';

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
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
      final data = await LastReadService.getLastRead();
      if (mounted) setState(() => _lastRead = data);
    } catch (_) {
      if (mounted) setState(() => _lastRead = null);
    }
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  String _l(String languageCode, String bn, String en) => languageCode == 'en' ? en : bn;

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
    return '$h:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')} ${_now.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _hijri(String languageCode) {
    try {
      final h = HijriCalendar.now();
      const bn = ['মুহররম','সফর','রবিউল আউয়াল','রবিউস সানি','জুমাদিউল আউয়াল','জুমাদিউস সানি','রজব','শাবান','রমজান','শাওয়াল','জিলকদ','জিলহজ'];
      const en = ['Muharram','Safar','Rabi al-Awwal','Rabi al-Thani','Jumada al-Awwal','Jumada al-Thani','Rajab','Sha’ban','Ramadan','Shawwal','Dhul-Qadah','Dhul-Hijjah'];
      const bnd = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
      String d(int n) => n.toString().split('').map((x) => bnd[int.parse(x)]).join();
      final m = languageCode == 'en' ? en[h.hMonth - 1] : bn[h.hMonth - 1];
      return '${languageCode == 'en' ? h.hDay : d(h.hDay)} $m ${languageCode == 'en' ? h.hYear : d(h.hYear)}';
    } catch (_) {
      return '--';
    }
  }

  _Phase get _phase {
    if (_now.hour < 5) return _Phase.night;
    if (_now.hour < 8) return _Phase.dawn;
    if (_now.hour < 17) return _Phase.day;
    if (_now.hour < 20) return _Phase.evening;
    return _Phase.night;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final languageCode = settings.languageCode;
    final primary = Theme.of(context).colorScheme.primary;
    final lastRead = _lastRead;
    final hasLastRead = lastRead != null && (lastRead['surahName']?.toString().trim().isNotEmpty ?? false);
    final prayers = controller.prayers.take(5).toList(growable: false);

    return Scaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
        children: [
          Text(_greeting(languageCode), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 21, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Row(children: [
            Icon(Icons.location_on_rounded, size: 14, color: context.secondaryTextColor),
            const SizedBox(width: 4),
            Expanded(child: Text(controller.currentLocationName.isEmpty ? _l(languageCode, 'লোকেশন নির্ধারণ হচ্ছে…', 'Locating…') : controller.currentLocationName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.secondaryTextColor, fontSize: 12.5))),
            const SizedBox(width: 8),
            Text(_hijri(languageCode), style: TextStyle(color: context.secondaryTextColor, fontSize: 12.5)),
          ]),
          const SizedBox(height: 12),
          _HeroCard(
            phase: _phase,
            nextPrayer: controller.nextPrayerName,
            nextPrayerTime: controller.nextPrayerTime,
            remaining: controller.timeRemainingForNextPrayer,
            currentPrayer: controller.currentPrayer,
            clock: _clock(),
            progress: controller.prayerProgress,
            sunrise: controller.sunriseTime,
            sunset: controller.sunsetTime,
            languageCode: languageCode,
          ),
          const SizedBox(height: 10),
          _PrayerStrip(prayers: prayers, languageCode: languageCode, currentPrayer: controller.currentPrayer),
          const SizedBox(height: 18),
          Text(_l(languageCode, 'প্রয়োজনীয়', 'Essentials'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 9),
          _Essentials(
            languageCode: languageCode,
            onQuran: () => widget.onNavigateTab?.call(2),
            onHadith: () => widget.onNavigateTab?.call(3),
            onQibla: () => _open(const QiblaScreen()),
            onDua: () => _open(const DuaScreen()),
            onTasbih: () => _open(const TasbihScreen()),
            onNames: () => _open(const AsmaUlHusnaScreen()),
          ),
          if (hasLastRead) ...[
            const SizedBox(height: 18),
            Text(_l(languageCode, 'কুরআন চালিয়ে যান', 'Continue Quran'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ContinueReadingCard(
              surahName: lastRead['surahName']?.toString() ?? '',
              paraNo: lastRead['paraNo'] is int ? lastRead['paraNo'] as int : int.tryParse('${lastRead['paraNo']}') ?? 1,
              pageNo: lastRead['pageNo'] is int ? lastRead['pageNo'] as int : int.tryParse('${lastRead['pageNo']}') ?? 1,
              progress: (lastRead['progress'] is num ? (lastRead['progress'] as num).toDouble() : 0).clamp(0.0, 1.0),
              languageCode: languageCode,
              onTap: () => _open(const OnudhabonQuranScreen(openLastRead: true)),
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: primary.withValues(alpha: .06))),
            child: Row(children: [
              Expanded(child: Text('${_l(languageCode, 'তারিখ', 'Date')}: ${DateService.englishDate()}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.secondaryTextColor, fontSize: 10.5))),
              Text('${_l(languageCode, 'সূর্যোদয়', 'Sunrise')} ${controller.sunriseTime}', style: TextStyle(color: context.secondaryTextColor, fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text('${_l(languageCode, 'সূর্যাস্ত', 'Sunset')} ${controller.sunsetTime}', style: TextStyle(color: context.secondaryTextColor, fontSize: 10, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }
}

enum _Phase { dawn, day, evening, night }

extension on _Phase {
  String label(String languageCode) {
    if (languageCode == 'en') {
      switch (this) {
        case _Phase.dawn: return 'DAWN';
        case _Phase.day: return 'DAY';
        case _Phase.evening: return 'SUNSET';
        case _Phase.night: return 'NIGHT';
      }
    }
    switch (this) {
      case _Phase.dawn: return 'ভোর';
      case _Phase.day: return 'দিন';
      case _Phase.evening: return 'সন্ধ্যা';
      case _Phase.night: return 'রাত';
    }
  }
}

class _Palette {
  const _Palette(this.top, this.bottom, this.hill, this.ground, this.celestial);
  final Color top;
  final Color bottom;
  final Color hill;
  final Color ground;
  final Color celestial;

  static _Palette of(_Phase phase) {
    switch (phase) {
      case _Phase.dawn: return const _Palette(Color(0xFF9DC8E6), Color(0xFFF3D1B0), Color(0xFF738F99), Color(0xFF344D57), Color(0xFFFFE0A5));
      case _Phase.day: return const _Palette(Color(0xFF51B8E5), Color(0xFFE6F3FA), Color(0xFF60957C), Color(0xFF2E5841), Color(0xFFFFEDAA));
      case _Phase.evening: return const _Palette(Color(0xFFEE9878), Color(0xFFF3C7A7), Color(0xFF78616A), Color(0xFF3F4350), Color(0xFFFFCF89));
      case _Phase.night: return const _Palette(Color(0xFF0C223E), Color(0xFF172F4D), Color(0xFF27384B), Color(0xFF091421), Color(0xFFE8EFF8));
    }
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.phase, required this.nextPrayer, required this.nextPrayerTime, required this.remaining, required this.currentPrayer, required this.clock, required this.progress, required this.sunrise, required this.sunset, required this.languageCode});
  final _Phase phase;
  final String nextPrayer;
  final String nextPrayerTime;
  final String remaining;
  final String currentPrayer;
  final String clock;
  final double progress;
  final String sunrise;
  final String sunset;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(phase);
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();
    String l(String bn, String en) => languageCode == 'en' ? en : bn;
    return SizedBox(
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(fit: StackFit.expand, children: [
          CustomPaint(painter: _ScenePainter(p)),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 15),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(l('পরের সালাত', 'NEXT PRAYER'), style: TextStyle(color: Colors.white.withValues(alpha: .78), fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const Spacer(),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .11), borderRadius: BorderRadius.circular(999)), child: Text(phase.label(languageCode), style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700))),
              ]),
              const Spacer(),
              Text(nextPrayer.isEmpty ? '--' : nextPrayer, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(nextPrayerTime.isEmpty ? '--:--' : nextPrayerTime, style: TextStyle(color: Colors.white.withValues(alpha: .86), fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 11),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: Text(remaining.isEmpty ? '--:--:--' : remaining, style: const TextStyle(color: Colors.white, fontSize: 37, fontWeight: FontWeight.w500, height: .95, letterSpacing: -1, fontFeatures: [FontFeature.tabularFigures()]))),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(l('এখন', 'NOW'), style: TextStyle(color: Colors.white.withValues(alpha: .54), fontSize: 8.5, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  Text(clock, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()])),
                ]),
              ]),
              const SizedBox(height: 11),
              ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(minHeight: 5, value: safeProgress, backgroundColor: Colors.white.withValues(alpha: .15), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
              const SizedBox(height: 10),
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .11), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.mosque_rounded, size: 14, color: Colors.white), const SizedBox(width: 5), Text(currentPrayer.isEmpty ? '--' : currentPrayer, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))])),
                const Spacer(),
                _Time(label: l('সূর্যোদয়', 'Sunrise'), value: sunrise),
                const SizedBox(width: 10),
                _Time(label: l('সূর্যাস্ত', 'Sunset'), value: sunset),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Time extends StatelessWidget {
  const _Time({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(label, style: TextStyle(color: Colors.white.withValues(alpha: .52), fontSize: 8.5, fontWeight: FontWeight.w700)), Text(value, style: TextStyle(color: Colors.white.withValues(alpha: .86), fontSize: 10.5, fontWeight: FontWeight.w800))]);
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter(this.p);
  final _Palette p;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [p.top, p.bottom]).createShader(rect));
    final celestial = Paint()..color = p.celestial;
    canvas.drawCircle(Offset(size.width * .76, size.height * .24), 22, celestial);
    if (p.top == const Color(0xFF0C223E)) {
      final star = Paint()..color = Colors.white.withValues(alpha: .65);
      for (final pt in const [Offset(.13,.18), Offset(.30,.28), Offset(.46,.13), Offset(.59,.20), Offset(.84,.15), Offset(.69,.30)]) canvas.drawCircle(Offset(size.width * pt.dx, size.height * pt.dy), 1.2, star);
    }
    final hill = Paint()..color = p.hill.withValues(alpha: .78);
    final h = Path()..moveTo(0, size.height*.70)..quadraticBezierTo(size.width*.22,size.height*.54,size.width*.45,size.height*.66)..quadraticBezierTo(size.width*.68,size.height*.49,size.width,size.height*.64)..lineTo(size.width,size.height)..lineTo(0,size.height)..close();
    canvas.drawPath(h, hill);
    final ground = Paint()..color = p.ground;
    final g = Path()..moveTo(0,size.height*.75)..quadraticBezierTo(size.width*.29,size.height*.65,size.width*.53,size.height*.76)..quadraticBezierTo(size.width*.80,size.height*.66,size.width,size.height*.73)..lineTo(size.width,size.height)..lineTo(0,size.height)..close();
    canvas.drawPath(g, ground);
    final mosque = Paint()..color = p.ground.withValues(alpha: .98);
    canvas.drawRect(Rect.fromLTWH(size.width*.31,size.height*.67,size.width*.38,size.height*.17), mosque);
    final dome = Path()..moveTo(size.width*.38,size.height*.68)..quadraticBezierTo(size.width*.50,size.height*.52,size.width*.62,size.height*.68)..close();
    canvas.drawPath(dome, mosque);
    canvas.drawRect(Rect.fromLTWH(size.width*.478,size.height*.49,size.width*.044,size.height*.18), mosque);
    canvas.drawCircle(Offset(size.width*.50,size.height*.48),4,mosque);
    canvas.drawRect(Rect.fromLTWH(size.width*.28,size.height*.57,size.width*.028,size.height*.29),mosque);
    canvas.drawRect(Rect.fromLTWH(size.width*.69,size.height*.57,size.width*.028,size.height*.29),mosque);
    canvas.drawCircle(Offset(size.width*.294,size.height*.565),3,mosque);
    canvas.drawCircle(Offset(size.width*.704,size.height*.565),3,mosque);
  }
  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) => oldDelegate.p != p;
}

class _PrayerStrip extends StatelessWidget {
  const _PrayerStrip({required this.prayers, required this.languageCode, required this.currentPrayer});
  final List<Map<String,dynamic>> prayers;
  final String languageCode;
  final String currentPrayer;

  bool _active(Map<String,dynamic> p) {
    final c = currentPrayer.toLowerCase().trim();
    final n = (p['name'] ?? '').toString().toLowerCase().trim();
    final bn = (p['nameBn'] ?? '').toString().toLowerCase().trim();
    return c.isNotEmpty && (c == n || c == bn || (n.isNotEmpty && c.contains(n)) || (bn.isNotEmpty && c.contains(bn)));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(children: List.generate(5, (i) {
      final p = i < prayers.length ? prayers[i] : const <String,dynamic>{};
      final active = _active(p);
      final name = languageCode == 'en' ? (p['name']?.toString() ?? p['nameBn']?.toString() ?? '--') : (p['nameBn']?.toString() ?? p['name']?.toString() ?? '--');
      final time = p['start']?.toString() ?? p['time']?.toString() ?? '--:--';
      return Expanded(child: Container(margin: EdgeInsets.only(left: i == 0 ? 0 : 4), padding: const EdgeInsets.symmetric(vertical:8,horizontal:2), decoration: BoxDecoration(color: active ? primary.withValues(alpha:.10) : context.cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: active ? primary.withValues(alpha:.20) : primary.withValues(alpha:.055))), child: Column(children: [Text(name,maxLines:1,overflow:TextOverflow.ellipsis,textAlign:TextAlign.center,style:TextStyle(color:active?primary:context.secondaryTextColor,fontSize:10.5,fontWeight:active?FontWeight.w800:FontWeight.w600)),const SizedBox(height:2),Text(time,maxLines:1,style:TextStyle(color:active?primary:context.primaryTextColor,fontSize:10.5,fontWeight:FontWeight.w700))])));
    }));
  }
}

class _Essentials extends StatelessWidget {
  const _Essentials({required this.languageCode, required this.onQuran, required this.onHadith, required this.onQibla, required this.onDua, required this.onTasbih, required this.onNames});
  final String languageCode;
  final VoidCallback onQuran,onHadith,onQibla,onDua,onTasbih,onNames;
  @override
  Widget build(BuildContext context) {
    String l(String bn,String en)=>languageCode=='en'?en:bn;
    final items=[
      _A(Icons.menu_book_rounded,l('কুরআন','Quran'),const Color(0xFF0EA5E9),onQuran),
      _A(Icons.explore_rounded,l('কিবলা','Qibla'),const Color(0xFF14B8A6),onQibla),
      _A(Icons.favorite_rounded,l('দোয়া','Dua'),const Color(0xFFEC4899),onDua),
      _A(Icons.touch_app_rounded,l('তাসবিহ','Tasbih'),const Color(0xFFF59E0B),onTasbih),
      _A(Icons.auto_awesome_rounded,l('৯৯ নাম','99 Names'),const Color(0xFF8B5CF6),onNames),
      _A(Icons.auto_stories_rounded,l('হাদিস','Hadith'),const Color(0xFF06B6D4),onHadith),
    ];
    return GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:items.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:8,mainAxisSpacing:8,childAspectRatio:1.28),itemBuilder:(_,i)=>_ActionCard(item:items[i]));
  }
}

class _A { const _A(this.icon,this.title,this.color,this.onTap); final IconData icon; final String title; final Color color; final VoidCallback onTap; }

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.item}); final _A item;
  @override
  Widget build(BuildContext context)=>Material(color:Colors.transparent,child:InkWell(onTap:item.onTap,borderRadius:BorderRadius.circular(18),child:Ink(decoration:BoxDecoration(color:item.color.withValues(alpha:.075),borderRadius:BorderRadius.circular(18),border:Border.all(color:item.color.withValues(alpha:.12))),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Container(width:34,height:34,decoration:BoxDecoration(color:item.color.withValues(alpha:.13),shape:BoxShape.circle),child:Icon(item.icon,color:item.color,size:19)),const SizedBox(height:5),Text(item.title,maxLines:1,overflow:TextOverflow.ellipsis,textAlign:TextAlign.center,style:TextStyle(color:context.primaryTextColor,fontSize:11.5,fontWeight:FontWeight.w700))]))));
}
