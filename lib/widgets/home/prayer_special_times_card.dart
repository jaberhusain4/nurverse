import 'dart:async';
import 'package:flutter/material.dart';

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
  String _time(DateTime? v){if(v==null)return'--:--';final h=v.hour%12==0?12:v.hour%12;return'$h:${v.minute.toString().padLeft(2,'0')} ${v.hour>=12?'PM':'AM'}';}
  String _left(Duration d){final m=d.inMinutes,s=d.inSeconds%60;return m>0?'$m ${_label('মিনিট','min','دقيقة')} ${s.toString().padLeft(2,'0')} ${_label('সেকেন্ড','sec','ثانية')}':'$s ${_label('সেকেন্ড','sec','ثانية')}';}
  _Window? _window(DateTime? s,DateTime? e){if(s==null||e==null)return null;if(!_now.isBefore(s)&&_now.isBefore(e))return _Window(s,e,true);if(_now.isBefore(s))return _Window(s,e,false);return null;}
  String _name(DateTime s,bool prohibited){if(s.hour<10)return _label(prohibited?'সূর্যোদয়ের নিষিদ্ধ সময়':'সূর্যোদয়ের মাকরূহ সময়',prohibited?'Sunrise prohibited time':'Sunrise Makruh time',prohibited?'وقت النهي عند الشروق':'وقت الكراهة عند الشروق');if(s.hour>=16)return _label(prohibited?'সূর্যাস্তের নিষিদ্ধ সময়':'সূর্যাস্তের মাকরূহ সময়',prohibited?'Sunset prohibited time':'Sunset Makruh time',prohibited?'وقت النهي عند الغروب':'وقت الكراهة عند الغروب');return _label(prohibited?'জাওয়ালের নিষিদ্ধ সময়':'জাওয়ালের মাকরূহ সময়',prohibited?'Zawal prohibited time':'Zawal Makruh time',prohibited?'وقت النهي عند الزوال':'وقت الكراهة عند الزوال');}
  String _status(_Window? w,{required bool prohibited}){if(w==null)return _label('আজ আর কোনো সময় নেই','No more time today','لا وقت آخر اليوم');final n=_name(w.start,prohibited);return w.active?'$n — ${_label('এখন চলছে','active now','جاري الآن')} • ${_left(w.end.difference(_now))} ${_label('বাকি','left','متبقٍ')}':'$n — ${_time(w.start)} – ${_time(w.end)}';}
  @override Widget build(BuildContext context){final t=Theme.of(context),p=t.colorScheme.primary,fg=t.colorScheme.onSurface,sec=t.textTheme.bodySmall?.color??fg.withValues(alpha:.7);final pw=_window(widget.prohibitedStart,widget.prohibitedEnd),mw=_window(widget.makruhStart,widget.makruhEnd);final active=pw?.active==true||mw?.active==true;return Container(width:double.infinity,padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:t.cardColor,borderRadius:BorderRadius.circular(18),border:Border.all(color:p.withValues(alpha:.12))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Icon(active?Icons.block_rounded:Icons.warning_amber_rounded,size:21,color:p),const SizedBox(width:8),Expanded(child:Text(_label('মাকরূহ ও নিষিদ্ধ সময়','Makruh & Prohibited Times','أوقات الكراهة والنهي'),style:TextStyle(fontSize:16,fontWeight:FontWeight.w800,color:fg)))]),const SizedBox(height:10),_item(_label('নিষিদ্ধ সময়','Prohibited','وقت النهي'),_status(pw,prohibited:true),pw?.active==true,p,sec,fg),const SizedBox(height:8),_item(_label('মাকরূহ সময়','Makruh','وقت الكراهة'),_status(mw,prohibited:false),mw?.active==true,p,sec,fg),const SizedBox(height:7),Text(_label('সময়গুলো প্রতি সেকেন্ডে লাইভ আপডেট হচ্ছে।','Times update live every second.','الأوقات تتحدث مباشرة كل ثانية.'),style:TextStyle(fontSize:11.5,color:sec))]));}
  Widget _item(String title,String value,bool active,Color p,Color sec,Color fg)=>Container(width:double.infinity,padding:const EdgeInsets.symmetric(horizontal:11,vertical:10),decoration:BoxDecoration(color:p.withValues(alpha: active ? .10 : .06),borderRadius:BorderRadius.circular(13),border:active?Border.all(color:p.withValues(alpha:.22)):null),child:Row(children:[Icon(active?Icons.timer_rounded:Icons.schedule_rounded,size:20,color:p),const SizedBox(width:8),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(fontSize:12.5,color:sec,fontWeight:FontWeight.w700)),const SizedBox(height:3),Text(value,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:13.5,color:fg,fontWeight:FontWeight.w800))]))]));
}
class _Window{final DateTime start,end;final bool active;const _Window(this.start,this.end,this.active);}
