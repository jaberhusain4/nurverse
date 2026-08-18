import 'package:flutter/material.dart';

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
    final period = match.group(3)!.toUpperCase();
    if (period == 'AM' && hour == 12) hour = 0;
    if (period == 'PM' && hour != 12) hour += 12;
    return DateTime(base.year, base.month, base.day, hour, minute);
  }
  String _clock(DateTime time) => '${time.hour % 12 == 0 ? 12 : time.hour % 12}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';
  String _awalText() {
    final now = DateTime.now(); final start = _parseTime(currentPrayerTime, now); var next = _parseTime(nextPrayerTime, now);
    if (start == null || next == null) return _label(bn: 'আওয়াল ওয়াক্তের তথ্য প্রস্তুত হচ্ছে', en: 'Awal Waqt information is being prepared', ar: 'جارٍ تجهيز وقت الأول');
    if (!next.isAfter(start)) next = next.add(const Duration(days: 1));
    final total = next.difference(start); if (total.inMinutes <= 0) return _label(bn: 'আওয়াল ওয়াক্তের তথ্য প্রস্তুত হচ্ছে', en: 'Awal Waqt information is being prepared', ar: 'جارٍ تجهيز وقت الأول');
    final end = start.add(Duration(milliseconds: total.inMilliseconds ~/ 3)); final active = !now.isBefore(start) && now.isBefore(end);
    return '${_label(bn: active ? 'আওয়াল ওয়াক্ত চলছে' : 'আওয়াল ওয়াক্ত শেষ', en: active ? 'Awal Waqt active' : 'Awal Waqt ended', ar: active ? 'وقت الأول مستمر' : 'انتهى وقت الأول')} • ${_clock(start)} → ${_clock(end)}';
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); final primary = theme.colorScheme.primary; final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface; final secondary = theme.textTheme.bodySmall?.color?.withValues(alpha: .72) ?? theme.colorScheme.onSurface.withValues(alpha: .72);
    final safeProgress = progress.clamp(0.0, 1.0).toDouble(); final percentage = (safeProgress * 100).round();
    return Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(14, 13, 14, 12), decoration: BoxDecoration(color: theme.cardColor.withValues(alpha: theme.brightness == Brightness.dark ? .72 : .88), borderRadius: BorderRadius.circular(22), border: Border.all(color: primary.withValues(alpha: .10))), child: Column(children: [
      Row(children: [
        Expanded(child: _ContextPrayer(label: _label(bn: 'পূর্ববর্তী', en: 'Previous', ar: 'السابق'), prayer: previousPrayer.isEmpty ? '--' : previousPrayer, time: previousPrayerTime, icon: Icons.history_rounded, color: secondary, text: text)),
        Expanded(child: Column(children: [Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.mosque_rounded, size: 16, color: primary), const SizedBox(width: 4), Text(_label(bn: 'বর্তমান', en: 'Current', ar: 'الحالية'), style: TextStyle(color: primary.withValues(alpha: .82), fontSize: 11, fontWeight: FontWeight.w700))]), const SizedBox(height: 3), Text(currentPrayer.isEmpty ? _label(bn: 'ওয়াক্ত নেই', en: 'No prayer', ar: 'لا صلاة') : currentPrayer, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.w800)), const SizedBox(height: 1), Text(currentPrayerTime.isEmpty ? '--:--' : currentPrayerTime, style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w800))])),
        Expanded(child: _ContextPrayer(label: _label(bn: 'পরবর্তী', en: 'Next', ar: 'التالي'), prayer: nextPrayer.isEmpty ? '--' : nextPrayer, time: nextPrayerTime, icon: Icons.arrow_forward_rounded, color: secondary, text: text)),
      ]),
      const SizedBox(height: 9),
      Container(height: 44, width: double.infinity, alignment: Alignment.center, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: primary.withValues(alpha: .035), borderRadius: BorderRadius.circular(14), border: Border.all(color: primary.withValues(alpha: .08))), child: RichText(text: TextSpan(children: [TextSpan(text: '${_label(bn: 'সময় বাকি', en: 'Time left', ar: 'الوقت المتبقي')}  ', style: TextStyle(color: secondary, fontSize: 13, fontWeight: FontWeight.w700)), TextSpan(text: remainingTime.isEmpty ? '--:--:--' : remainingTime, style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w800))]))),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: _TimeLabel(label: _label(bn: 'শুরু', en: 'Start', ar: 'البداية'), time: currentPrayerTime, color: secondary)), Expanded(child: Align(alignment: Alignment.centerRight, child: _TimeLabel(label: _label(bn: 'শেষ', en: 'End', ar: 'النهاية'), time: nextPrayerTime, color: secondary)))]),
      const SizedBox(height: 5),
      Row(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: safeProgress, minHeight: 6, backgroundColor: primary.withValues(alpha: .09), valueColor: AlwaysStoppedAnimation<Color>(primary)))), const SizedBox(width: 7), Text('$percentage%', style: TextStyle(color: primary, fontSize: 10.5, fontWeight: FontWeight.w800))]),
      const SizedBox(height: 8),
      Row(children: [Icon(Icons.bolt_rounded, size: 16, color: primary), const SizedBox(width: 5), Expanded(child: Text(_awalText(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 11.5, fontWeight: FontWeight.w700)))]),
      if (status.isNotEmpty) ...[const SizedBox(height: 4), Row(children: [Icon(Icons.info_outline_rounded, size: 14, color: secondary), const SizedBox(width: 5), Expanded(child: Text(status, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 11, fontWeight: FontWeight.w600)))])],
      const SizedBox(height: 7),
      Material(color: Colors.transparent, child: InkWell(onTap: onJamaatTap, borderRadius: BorderRadius.circular(12), child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(Icons.groups_rounded, size: 17, color: primary), const SizedBox(width: 6), Text(_label(bn: 'জামাআত', en: 'Jamaat', ar: 'الجماعة'), style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w700)), const Spacer(), Text(iqamahTime.isEmpty ? '--:--' : iqamahTime, style: TextStyle(color: text, fontSize: 12.5, fontWeight: FontWeight.w800)), const SizedBox(width: 3), Icon(Icons.chevron_right_rounded, size: 16, color: secondary)])))),
    ]));
  }
}

class _ContextPrayer extends StatelessWidget {
  final String label, prayer, time; final IconData icon; final Color color, text;
  const _ContextPrayer({required this.label, required this.prayer, required this.time, required this.icon, required this.color, required this.text});
  @override
  Widget build(BuildContext context) => Column(children: [Icon(icon, size: 16, color: color), const SizedBox(height: 2), Text(label, maxLines: 1, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600)), const SizedBox(height: 1), Text(prayer, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w800)), Text(time.isEmpty ? '--:--' : time, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700))]);
}

class _TimeLabel extends StatelessWidget {
  final String label, time; final Color color;
  const _TimeLabel({required this.label, required this.time, required this.color});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Flexible(child: Text('$label  ', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600))), Flexible(child: Text(time.isEmpty ? '--:--' : time, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w800)))]);
}