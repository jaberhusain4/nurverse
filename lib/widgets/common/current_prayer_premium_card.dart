import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/prayer_controller.dart';

class CurrentPrayerPremiumCard extends StatelessWidget {
  final String previousPrayer, previousPrayerTime, currentPrayer, currentPrayerTime, nextPrayer, nextPrayerTime, remainingTime, iqamahTime, status, languageCode;
  final double progress;
  final VoidCallback? onJamaatTap;
  const CurrentPrayerPremiumCard({super.key, required this.previousPrayer, required this.previousPrayerTime, required this.currentPrayer, required this.currentPrayerTime, required this.nextPrayer, required this.nextPrayerTime, required this.remainingTime, required this.progress, required this.iqamahTime, required this.status, this.languageCode = 'bn', this.onJamaatTap});
  String _label({required String bn, required String en, required String ar}) => languageCode == 'en' ? en : languageCode == 'ar' ? ar : bn;
  DateTime? _parseTime(String value, DateTime base) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false).firstMatch(value.trim());
    if (match == null) return null;
    var hour = int.tryParse(match.group(1)!) ?? -1; final minute = int.tryParse(match.group(2)!) ?? -1;
    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) return null;
    final period = match.group(3)!.toUpperCase(); if (period == 'AM' && hour == 12) hour = 0; if (period == 'PM' && hour != 12) hour += 12;
    return DateTime(base.year, base.month, base.day, hour, minute);
  }
  String _clock(DateTime time) => '${time.hour % 12 == 0 ? 12 : time.hour % 12}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';
  String _awalText(String actualEndTime) {
    final now = DateTime.now(); final start = _parseTime(currentPrayerTime, now); final end = _parseTime(actualEndTime, now);
    if (start == null || end == null) return _label(bn: 'আওয়াল ওয়াক্তের তথ্য প্রস্তুত হচ্ছে', en: 'Awal Waqt information is being prepared', ar: 'جارٍ تجهيز وقت الأول');
    var endTime = end; if (!endTime.isAfter(start)) endTime = endTime.add(const Duration(days: 1));
    final active = !now.isBefore(start) && now.isBefore(endTime);
    return '${_label(bn: active ? 'আওয়াল ওয়াক্ত চলছে' : 'আওয়াল ওয়াক্ত শেষ', en: active ? 'Awal Waqt active' : 'Awal Waqt ended', ar: active ? 'وقت الأول مستمر' : 'انتهى وقت الأول')} • ${_clock(start)} → ${_clock(endTime)}';
  }
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>(); final actualEndTime = controller.currentPrayerEnd;
    final theme = Theme.of(context); final primary = theme.colorScheme.primary; final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface; final secondary = theme.textTheme.bodySmall?.color?.withValues(alpha: .72) ?? theme.colorScheme.onSurface.withValues(alpha: .72);
    final safeProgress = progress.clamp(0.0, 1.0).toDouble(); final percentage = (safeProgress * 100).round();
    return Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(14, 13, 14, 12), decoration: BoxDecoration(color: theme.cardColor.withValues(alpha: theme.brightness == Brightness.dark ? .72 : .88), borderRadius: BorderRadius.circular(22), border: Border.all(color: primary.withValues(alpha: .10))), child: Column(children: [
      SizedBox(height: 92, child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: _ContextPrayer(label: _label(bn: 'পূর্ববর্তী', en: 'Previous', ar: 'السابق'), prayer: previousPrayer.isEmpty ? '--' : previousPrayer, time: previousPrayerTime, icon: Icons.history_rounded, color: secondary, text: text)),
        const SizedBox(width: 6),
        Expanded(child: _ContextPrayer(label: _label(bn: 'বর্তমান', en: 'Current', ar: 'الحالية'), prayer: currentPrayer.isEmpty ? _label(bn: 'ওয়াক্ত নেই', en: 'No prayer', ar: 'لا صلاة') : currentPrayer, time: currentPrayerTime, icon: Icons.mosque_rounded, color: primary, text: text, labelColor: primary.withValues(alpha: .82))),
        const SizedBox(width: 6),
        Expanded(child: _ContextPrayer(label: _label(bn: 'পরবর্তী', en: 'Next', ar: 'التالي'), prayer: nextPrayer.isEmpty ? '--' : nextPrayer, time: nextPrayerTime, icon: Icons.arrow_forward_rounded, color: secondary, text: text)),
      ])),
      const SizedBox(height: 10),
      Container(height: 46, width: double.infinity, alignment: Alignment.center, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: primary.withValues(alpha: .035), borderRadius: BorderRadius.circular(14), border: Border.all(color: primary.withValues(alpha: .08))), child: RichText(text: TextSpan(children: [TextSpan(text: '${_label(bn: 'সময় বাকি', en: 'Time left', ar: 'الوقت المتبقي')}  ', style: TextStyle(color: secondary, fontSize: 14, fontWeight: FontWeight.w700)), TextSpan(text: remainingTime.isEmpty ? '--:--:--' : remainingTime, style: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.w800))]))),
      const SizedBox(height: 9),
      Row(children: [Expanded(child: _TimeLabel(label: _label(bn: 'শুরু', en: 'Start', ar: 'البداية'), time: currentPrayerTime, color: secondary)), Expanded(child: Align(alignment: Alignment.centerRight, child: _TimeLabel(label: _label(bn: 'শেষ', en: 'End', ar: 'النهاية'), time: actualEndTime, color: secondary)))]),
      const SizedBox(height: 6),
      Row(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: safeProgress, minHeight: 7, backgroundColor: primary.withValues(alpha: .09), valueColor: AlwaysStoppedAnimation<Color>(primary)))), const SizedBox(width: 8), Text('$percentage%', style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w800))]),
      const SizedBox(height: 9),
      Row(children: [Icon(Icons.bolt_rounded, size: 19, color: primary), const SizedBox(width: 6), Expanded(child: Text(_awalText(actualEndTime), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w700)))]),
      if (status.isNotEmpty) ...[const SizedBox(height: 5), Row(children: [Icon(Icons.info_outline_rounded, size: 17, color: secondary), const SizedBox(width: 6), Expanded(child: Text(status, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 12.5, fontWeight: FontWeight.w600)))])],
      const SizedBox(height: 8),
      Material(color: Colors.transparent, child: InkWell(onTap: onJamaatTap, borderRadius: BorderRadius.circular(12), child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(Icons.groups_rounded, size: 19, color: primary), const SizedBox(width: 7), Text(_label(bn: 'জামাআত', en: 'Jamaat', ar: 'الجماعة'), style: TextStyle(color: secondary, fontSize: 13, fontWeight: FontWeight.w700)), const Spacer(), Text(iqamahTime.isEmpty ? '--:--' : iqamahTime, style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w800)), const SizedBox(width: 4), Icon(Icons.chevron_right_rounded, size: 18, color: secondary)])))),
    ]));
  }
}

class _ContextPrayer extends StatelessWidget {
  final String label, prayer, time;
  final IconData icon;
  final Color color, text;
  final Color? labelColor;
  const _ContextPrayer({required this.label, required this.prayer, required this.time, required this.icon, required this.color, required this.text, this.labelColor});
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: .035), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: .07))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    SizedBox(height: 21, child: Icon(icon, size: 19, color: color)), const SizedBox(height: 2),
    SizedBox(height: 16, child: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1, style: TextStyle(color: labelColor ?? color, fontSize: 12, fontWeight: FontWeight.w700, height: 1.0)))), const SizedBox(height: 1),
    SizedBox(height: 17, child: FittedBox(fit: BoxFit.scaleDown, child: Text(prayer, maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w700, height: 1.0)))), const SizedBox(height: 1),
    SizedBox(height: 14, child: FittedBox(fit: BoxFit.scaleDown, child: Text(time.isEmpty ? '--:--' : time, maxLines: 1, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700, height: 1.0)))),
  ]));
}

class _TimeLabel extends StatelessWidget {
  final String label, time; final Color color;
  const _TimeLabel({required this.label, required this.time, required this.color});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Flexible(child: Text('$label  ', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w600))), Flexible(child: Text(time.isEmpty ? '--:--' : time, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800)))]);
}
