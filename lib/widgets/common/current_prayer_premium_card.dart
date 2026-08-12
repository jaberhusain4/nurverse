import 'package:flutter/material.dart';

class CurrentPrayerPremiumCard extends StatelessWidget {
  final String previousPrayer;
  final String previousPrayerTime;
  final String currentPrayer;
  final String currentPrayerTime;
  final String nextPrayer;
  final String nextPrayerTime;
  final String remainingTime;
  final double progress;
  final String iqamahTime;
  final String status;
  final String languageCode;
  final VoidCallback? onJamaatTap;

  const CurrentPrayerPremiumCard({
    super.key,
    required this.previousPrayer,
    required this.previousPrayerTime,
    required this.currentPrayer,
    required this.currentPrayerTime,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.remainingTime,
    required this.progress,
    required this.iqamahTime,
    required this.status,
    this.languageCode = 'bn',
    this.onJamaatTap,
  });

  String _label({required String bn, required String en, required String ar}) {
    switch (languageCode) {
      case 'en': return en;
      case 'ar': return ar;
      default: return bn;
    }
  }

  DateTime? _parseTime(String value, DateTime base) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false).firstMatch(value.trim());
    if (match == null) return null;
    var hour = int.tryParse(match.group(1)!) ?? -1;
    final minute = int.tryParse(match.group(2)!) ?? -1;
    final period = match.group(3)!.toUpperCase();
    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) return null;
    if (period == 'AM') {
      if (hour == 12) hour = 0;
    } else if (hour != 12) {
      hour += 12;
    }
    return DateTime(base.year, base.month, base.day, hour, minute);
  }

  _AwalWaqtData? _awalWaqtData() {
    final now = DateTime.now();
    final start = _parseTime(currentPrayerTime, now);
    var next = _parseTime(nextPrayerTime, now);
    if (start == null || next == null) return null;
    if (!next.isAfter(start)) next = next.add(const Duration(days: 1));
    final interval = next.difference(start);
    if (interval.inSeconds <= 0) return null;
    final end = start.add(Duration(milliseconds: interval.inMilliseconds ~/ 3));
    final active = !now.isBefore(start) && now.isBefore(end);
    return _AwalWaqtData(active: active, remaining: active ? end.difference(now) : Duration.zero, start: start, end: end);
  }

  String _formatRemaining(Duration duration) {
    final totalSeconds = duration.inSeconds.clamp(0, 86399);
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatClock(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    return '$hour:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyLarge?.color ?? scheme.onSurface;
    final secondary = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.66) ?? scheme.onSurface.withValues(alpha: 0.66);
    final primary = scheme.primary;
    final safeProgress = progress.clamp(0.0, 1.0);
    final percentage = (safeProgress * 100).round();
    final awal = _awalWaqtData();
    final previous = previousPrayer.isEmpty ? '--' : previousPrayer;
    final current = currentPrayer.isEmpty ? _label(bn: 'ওয়াক্ত নেই', en: 'No prayer', ar: 'لا صلاة') : currentPrayer;
    final next = nextPrayer.isEmpty ? '--' : nextPrayer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withValues(alpha: 0.06)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.035), blurRadius: 16, offset: const Offset(0, 7))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: _PrayerMini(label: _label(bn: 'পূর্ববর্তী', en: 'Previous', ar: 'السابق'), prayer: previous, time: previousPrayerTime, icon: Icons.history_rounded, color: secondary, textColor: textColor)),
              const SizedBox(width: 7),
              Expanded(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(color: primary.withValues(alpha: 0.055), borderRadius: BorderRadius.circular(18)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_label(bn: 'সময় বাকি', en: 'Time left', ar: 'الوقت المتبقي'), textAlign: TextAlign.center, style: TextStyle(color: secondary, fontSize: 10.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  FittedBox(fit: BoxFit.scaleDown, child: Text(remainingTime.isEmpty ? '--:--:--' : remainingTime, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.3))),
                ]),
              )),
              const SizedBox(width: 7),
              Expanded(child: _PrayerMini(label: _label(bn: 'পরবর্তী', en: 'Next', ar: 'التالي'), prayer: next, time: nextPrayerTime, icon: Icons.arrow_forward_rounded, color: secondary, textColor: textColor)),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 330;
            if (wide) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _InfoPanel(color: primary, background: primary.withValues(alpha: 0.075), icon: Icons.mosque_rounded, title: _label(bn: 'বর্তমান সালাত', en: 'Current prayer', ar: 'الصلاة الحالية'), value: current, subtitle: currentPrayerTime.isEmpty ? '--:--' : currentPrayerTime, valueSize: 15, subtitleSize: 12)),
                const SizedBox(width: 8),
                Expanded(child: _AwalPanel(primary: primary, textColor: textColor, secondary: secondary, data: awal, label: _label(bn: 'আওয়াল ওয়াক্ত', en: 'Awal Waqt', ar: 'وقت الأول'), formatClock: _formatClock, formatRemaining: _formatRemaining, activeLabel: _label(bn: 'চলছে', en: 'Active', ar: 'مستمر'), endedLabel: _label(bn: 'শেষ', en: 'Ended', ar: 'انتهى'), startLabel: _label(bn: 'শুরু', en: 'Start', ar: 'البداية'), endLabel: _label(bn: 'শেষ', en: 'End', ar: 'النهاية'), leftLabel: _label(bn: 'বাকি', en: 'Left', ar: 'المتبقي'))),
              ]);
            }
            return Column(mainAxisSize: MainAxisSize.min, children: [
              _InfoPanel(color: primary, background: primary.withValues(alpha: 0.075), icon: Icons.mosque_rounded, title: _label(bn: 'বর্তমান সালাত', en: 'Current prayer', ar: 'الصلاة الحالية'), value: current, subtitle: currentPrayerTime.isEmpty ? '--:--' : currentPrayerTime, valueSize: 15, subtitleSize: 12),
              const SizedBox(height: 8),
              _AwalPanel(primary: primary, textColor: textColor, secondary: secondary, data: awal, label: _label(bn: 'আওয়াল ওয়াক্ত', en: 'Awal Waqt', ar: 'وقت الأول'), formatClock: _formatClock, formatRemaining: _formatRemaining, activeLabel: _label(bn: 'চলছে', en: 'Active', ar: 'مستمر'), endedLabel: _label(bn: 'শেষ', en: 'Ended', ar: 'انتهى'), startLabel: _label(bn: 'শুরু', en: 'Start', ar: 'البداية'), endLabel: _label(bn: 'শেষ', en: 'End', ar: 'النهاية'), leftLabel: _label(bn: 'বাকি', en: 'Left', ar: 'المتبقي')),
            ]);
          }),
          const SizedBox(height: 9),
          Row(children: [
            Expanded(child: _TimeLabel(label: _label(bn: 'শুরু', en: 'Start', ar: 'البداية'), time: currentPrayerTime, color: secondary)),
            const SizedBox(width: 8),
            Expanded(child: Align(alignment: Alignment.centerRight, child: _TimeLabel(label: _label(bn: 'শেষ', en: 'End', ar: 'النهاية'), time: nextPrayerTime, color: secondary))),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: safeProgress, minHeight: 6, backgroundColor: primary.withValues(alpha: 0.09), valueColor: AlwaysStoppedAnimation<Color>(primary)))),
            const SizedBox(width: 8),
            Text('$percentage%', style: TextStyle(color: primary, fontSize: 10.5, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.info_outline_rounded, size: 14, color: secondary),
            const SizedBox(width: 6),
            Expanded(child: Text(status.isEmpty ? _label(bn: 'সালাতের সময় গণনা করা হচ্ছে...', en: 'Calculating prayer time...', ar: 'جارٍ حساب وقت الصلاة...') : status, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 10.5, fontWeight: FontWeight.w500))),
          ]),
          const SizedBox(height: 8),
          Material(color: Colors.transparent, child: InkWell(
            onTap: onJamaatTap,
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: primary.withValues(alpha: 0.045), borderRadius: BorderRadius.circular(13)),
              child: Row(children: [
                Icon(Icons.groups_rounded, size: 16, color: primary),
                const SizedBox(width: 7),
                Text(_label(bn: 'জামাআত', en: 'Jamaat', ar: 'الجماعة'), style: TextStyle(color: secondary, fontSize: 10.5, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(iqamahTime.isEmpty ? '--:--' : iqamahTime, style: TextStyle(color: textColor, fontSize: 11.5, fontWeight: FontWeight.w800)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 17, color: secondary),
              ]),
            ),
          )),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final Color color; final Color background; final IconData icon; final String title; final String value; final String subtitle; final double valueSize; final double subtitleSize;
  const _InfoPanel({required this.color, required this.background, required this.icon, required this.title, required this.value, required this.subtitle, required this.valueSize, required this.subtitleSize});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
    child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: color, size: 18), const SizedBox(height: 3),
      Text(title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color.withValues(alpha: 0.72), fontSize: 10.5, fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      Text(value, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: valueSize, fontWeight: FontWeight.w900)),
      const SizedBox(height: 2), Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: subtitleSize, fontWeight: FontWeight.w800)),
    ]),
  );
}

class _AwalPanel extends StatelessWidget {
  final Color primary, textColor, secondary; final _AwalWaqtData? data; final String label, activeLabel, endedLabel, startLabel, endLabel, leftLabel; final String Function(DateTime) formatClock; final String Function(Duration) formatRemaining;
  const _AwalPanel({required this.primary, required this.textColor, required this.secondary, required this.data, required this.label, required this.formatClock, required this.formatRemaining, required this.activeLabel, required this.endedLabel, required this.startLabel, required this.endLabel, required this.leftLabel});
  @override
  Widget build(BuildContext context) {
    final active = data?.active ?? false;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(color: primary.withValues(alpha: active ? 0.075 : 0.045), borderRadius: BorderRadius.circular(16), border: Border.all(color: primary.withValues(alpha: active ? 0.11 : 0.045))),
      child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.bolt_rounded, color: primary, size: 18), const SizedBox(height: 3),
        Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: primary.withValues(alpha: 0.72), fontSize: 10.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(active ? activeLabel : endedLabel, textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w900)),
        if (data != null) ...[
          const SizedBox(height: 5),
          Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 3, children: [
            _AwalValue(label: startLabel, value: formatClock(data!.start), color: secondary),
            _AwalValue(label: endLabel, value: formatClock(data!.end), color: secondary),
            if (active) _AwalValue(label: leftLabel, value: formatRemaining(data!.remaining), color: primary),
          ]),
        ],
      ]),
    );
  }
}

class _AwalValue extends StatelessWidget {
  final String label, value; final Color color;
  const _AwalValue({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w600)), const SizedBox(height: 1), Text(value, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800))]);
}

class _AwalWaqtData { final bool active; final Duration remaining; final DateTime start; final DateTime end; const _AwalWaqtData({required this.active, required this.remaining, required this.start, required this.end}); }

class _PrayerMini extends StatelessWidget { final String label, prayer, time; final IconData icon; final Color color, textColor; const _PrayerMini({required this.label, required this.prayer, required this.time, required this.icon, required this.color, required this.textColor}); @override Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: color), const SizedBox(height: 2), Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w600)), const SizedBox(height: 1), Text(prayer, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor, fontSize: 10.5, fontWeight: FontWeight.w800)), const SizedBox(height: 1), Text(time.isEmpty ? '--:--' : time, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor, fontSize: 10.5, fontWeight: FontWeight.w700))]); }

class _TimeLabel extends StatelessWidget {
  final String label, time; final Color color;
  const _TimeLabel({required this.label, required this.time, required this.color});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Text('$label  ', style: TextStyle(color: color, fontSize: 10)), Text(time.isEmpty ? '--:--' : time, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800))]);
}
