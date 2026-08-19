import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/prayer_controller.dart';

class PrayerSpecialTimesCard extends StatefulWidget {
  final String languageCode;
  final DateTime? prohibitedStart, prohibitedEnd, makruhStart, makruhEnd;
  const PrayerSpecialTimesCard({super.key, required this.languageCode, required this.prohibitedStart, required this.prohibitedEnd, required this.makruhStart, required this.makruhEnd});
  @override State<PrayerSpecialTimesCard> createState() => _PrayerSpecialTimesCardState();
}

class _PrayerSpecialTimesCardState extends State<PrayerSpecialTimesCard> {
  Timer? _timer; DateTime _now = DateTime.now();
  @override void initState(){super.initState();_timer=Timer.periodic(const Duration(seconds:1),(_){if(mounted)setState(()=>_now=DateTime.now());});}
  @override void dispose(){_timer?.cancel();super.dispose();}
  String _label(String bn,String en,String ar)=>widget.languageCode=='en'?en:widget.languageCode=='ar'?ar:bn;
  String _time(DateTime v){final h=v.hour%12==0?12:v.hour%12;return'$h:${v.minute.toString().padLeft(2,'0')} ${v.hour>=12?'PM':'AM'}';}
  String _left(Duration d){final seconds=d.inSeconds.clamp(0,86400),m=seconds~/60,s=seconds%60;return m>0?'$m ${_label('মিনিট','min','دقيقة')} ${s.toString().padLeft(2,'0')} ${_label('সেকেন্ড','sec','ثانية')} ${_label('বাকি','left','متبقٍ')}':'$s ${_label('সেকেন্ড বাকি','sec left','ثانية متبقية')}';}

  List<_Window> _windows(PrayerController c,{required bool prohibited}){
    final sunrise=c.sunriseTime.isEmpty?null:_parse(c.sunriseTime);
    final noon=c.solarNoonTime.isEmpty?null:_parse(c.solarNoonTime);
    final sunset=c.sunsetTime.isEmpty?null:_parse(c.sunsetTime);
    if(sunrise==null||noon==null||sunset==null)return const [];
    final ranges=prohibited?<List<DateTime>>[[sunrise,sunrise.add(const Duration(minutes:15))],[noon.subtract(const Duration(minutes:10)),noon],[sunset.subtract(const Duration(minutes:15)),sunset]]:<List<DateTime>>[[sunrise.subtract(const Duration(minutes:15)),sunrise.add(const Duration(minutes:15))],[noon.subtract(const Duration(minutes:10)),noon.add(const Duration(minutes:5))],[sunset.subtract(const Duration(minutes:15)),sunset.add(const Duration(minutes:15))]];
    return ranges.map((r){final active=!_now.isBefore(r[0])&&_now.isBefore(r[1]);final past=!_now.isBefore(r[1]);return _Window(r[0],r[1],active,past);}).toList();
  }

  DateTime? _parse(String value){final m=RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',caseSensitive:false).firstMatch(value.trim());if(m==null)return null;var h=int.tryParse(m.group(1)!)??-1;final min=int.tryParse(m.group(2)!)??-1;if(h<1||h>12||min<0||min>59)return null;final p=m.group(3)!.toUpperCase();if(p=='AM'&&h==12)h=0;if(p=='PM'&&h!=12)h+=12;return DateTime(_now.year,_now.month,_now.day,h,min);}

  String _name(int index,{required bool prohibited}){
    if(index==0)return _label(prohibited?'সূর্যোদয়ের নিষিদ্ধ সময়':'সূর্যোদয়ের মাকরূহ সময়',prohibited?'Sunrise prohibited time':'Sunrise Makruh time',prohibited?'وقت النهي عند الشروق':'وقت الكراهة عند الشروق');
    if(index==1)return _label(prohibited?'জাওয়ালের নিষিদ্ধ সময়':'জাওয়ালের মাকরূহ সময়',prohibited?'Zawal prohibited time':'Zawal Makruh time',prohibited?'وقت النهي عند الزوال':'وقت الكراهة عند الزوال');
    return _label(prohibited?'সূর্যাস্তের নিষিদ্ধ সময়':'সূর্যাস্তের মাকরূহ সময়',prohibited?'Sunset prohibited time':'Sunset Makruh time',prohibited?'وقت النهي عند الغروب':'وقت الكراهة عند الغروب');
  }

  String _status(_Window w,int index,{required bool prohibited}){
    final name=_name(index,prohibited:prohibited);
    if(w.active)return '$name — ${_label('এখন চলছে','active now','جاري الآن')} • ${_left(w.end.difference(_now))}';
    if(w.past)return '$name — ${_label('আজকের সময় শেষ','ended today','انتهى اليوم')} • ${_time(w.start)} – ${_time(w.end)}';
    return '$name — ${_label('পরবর্তী','next','التالي')} • ${_time(w.start)} – ${_time(w.end)}';
  }

  @override Widget build(BuildContext context){final c=context.watch<PrayerController>(),t=Theme.of(context),p=t.colorScheme.primary,fg=t.colorScheme.onSurface,sec=t.textTheme.bodySmall?.color??fg.withValues(alpha:.7);final prohibited=_windows(c,prohibited:true),makruh=_windows(c,prohibited:false);final active=prohibited.any((w)=>w.active)||makruh.any((w)=>w.active);return Container(width:double.infinity,padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:t.cardColor,borderRadius:BorderRadius.circular(18),border:Border.all(color:p.withValues(alpha:.12))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Icon(active?Icons.block_rounded:Icons.warning_amber_rounded,size:21,color:p),const SizedBox(width:8),Expanded(child:Text(_label('মাকরূহ ও নিষিদ্ধ সময়','Makruh & Prohibited Times','أوقات الكراهة والنهي'),style:TextStyle(fontSize:16,fontWeight:FontWeight.w800,color:fg)))]),const SizedBox(height:10),...List.generate(prohibited.length,(i)=>Padding(padding:const EdgeInsets.only(bottom:8),child:_item(_label('নিষিদ্ধ সময়','Prohibited','وقت النهي'),_status(prohibited[i],i,prohibited:true),prohibited[i].active,p,sec,fg))),...List.generate(makruh.length,(i)=>Padding(padding:const EdgeInsets.only(bottom:8),child:_item(_label('মাকরূহ সময়','Makruh','وقت الكراهة'),_status(makruh[i],i,prohibited:false),makruh[i].active,p,sec,fg))),Text(_label('সময়গুলো প্রতি সেকেন্ডে লাইভ আপডেট হচ্ছে।','Times update live every second.','الأوقات تتحدث مباشرة كل ثانية.'),style:TextStyle(fontSize:11.5,color:sec))]));}

  Widget _item(String title,String value,bool active,Color p,Color sec,Color fg)=>Container(width:double.infinity,padding:const EdgeInsets.symmetric(horizontal:11,vertical:10),decoration:BoxDecoration(color:p.withValues(alpha: active ? .10 : .06),borderRadius:BorderRadius.circular(13),border:active?Border.all(color:p.withValues(alpha:.22)):null),child:Row(children:[Icon(active?Icons.timer_rounded:Icons.schedule_rounded,size:20,color:p),const SizedBox(width:8),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(fontSize:12.5,color:sec,fontWeight:FontWeight.w700)),const SizedBox(height:3),Text(value,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:13.5,color:fg,fontWeight:FontWeight.w800))]))]));
}

class _Window{final DateTime start,end;final bool active,past;const _Window(this.start,this.end,this.active,this.past);}