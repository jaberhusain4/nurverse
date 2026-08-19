import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/prayer_controller.dart';

class LivePrayerRestrictionCard extends StatefulWidget {
  final String languageCode;
  const LivePrayerRestrictionCard({super.key, required this.languageCode});
  @override State<LivePrayerRestrictionCard> createState() => _LivePrayerRestrictionCardState();
}

class _LivePrayerRestrictionCardState extends State<LivePrayerRestrictionCard> {
  Timer? _timer; DateTime _now = DateTime.now();
  @override void initState(){super.initState();_timer=Timer.periodic(const Duration(seconds:1),(_){if(mounted)setState(()=>_now=DateTime.now());});}
  @override void dispose(){_timer?.cancel();super.dispose();}
  String _label(String bn,String en,String ar)=>widget.languageCode=='en'?en:widget.languageCode=='ar'?ar:bn;
  DateTime? _parse(String value){final m=RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',caseSensitive:false).firstMatch(value.trim());if(m==null)return null;var h=int.parse(m.group(1)!);final min=int.parse(m.group(2)!);final p=m.group(3)!.toUpperCase();if(p=='AM'&&h==12)h=0;if(p=='PM'&&h!=12)h+=12;return DateTime(_now.year,_now.month,_now.day,h,min);}
  String _left(Duration d){final s=d.inSeconds.clamp(0,86400);final m=s~/60,sec=s%60;return'$m:${sec.toString().padLeft(2,'0')} ${_label('মিনিট বাকি','min left','دقيقة متبقية')}';}
  @override Widget build(BuildContext context){final c=context.watch<PrayerController>();final sunrise=_parse(c.sunriseTime),noon=_parse(c.solarNoonTime),sunset=_parse(c.sunsetTime);final windows=<({DateTime start,DateTime end,String bn,String en,String ar})>[];if(sunrise!=null)windows.add((start:sunrise.subtract(const Duration(minutes:15)),end:sunrise.add(const Duration(minutes:15)),bn:'সূর্যোদয়ের সময়',en:'Sunrise restriction',ar:'وقت النهي عند الشروق'));if(noon!=null)windows.add((start:noon.subtract(const Duration(minutes:10)),end:noon.add(const Duration(minutes:5)),bn:'জাওয়ালের সময়',en:'Zawal restriction',ar:'وقت النهي عند الزوال'));if(sunset!=null)windows.add((start:sunset.subtract(const Duration(minutes:15)),end:sunset.add(const Duration(minutes:15)),bn:'সূর্যাস্তের সময়',en:'Sunset restriction',ar:'وقت النهي عند الغروب'));final active=windows.where((w)=>!_now.isBefore(w.start)&&_now.isBefore(w.end)).toList();final next=windows.where((w)=>_now.isBefore(w.start)).toList();final w=active.isNotEmpty?active.first:(next.isNotEmpty?next.first:null);if(w==null)return const SizedBox.shrink();final isActive=active.isNotEmpty;final title=_label(w.bn,w.en,w.ar);final message=isActive?'$title — ${_label('এখন নামাজের নিষিদ্ধ সময় চলছে','Restricted prayer time is active','وقت النهي قائم الآن')} • ${_left(w.end.difference(_now))}':'$title — ${_label('আর','in','في')} ${_left(w.start.difference(_now))} ${_label('পর শুরু হবে','until it starts','حتى يبدأ')}';final t=Theme.of(context),color=t.colorScheme.error,fg=t.colorScheme.onSurface;return Container(width:double.infinity,padding:const EdgeInsets.symmetric(horizontal:13,vertical:11),decoration:BoxDecoration(color:color.withValues(alpha:.08),borderRadius:BorderRadius.circular(16),border:Border.all(color:color.withValues(alpha:.25))),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.warning_amber_rounded,color:color,size:23),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(_label('সতর্কতা','Prayer Time Warning','تنبيه وقت الصلاة'),style:TextStyle(fontSize:13,fontWeight:FontWeight.w800,color:color)),const SizedBox(height:3),Text(message,style:TextStyle(fontSize:13.5,fontWeight:FontWeight.w700,color:fg))]))]);}
}
