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
    if (languageCode == 'en') return en;
    if (languageCode == 'ar') return ar;
    return bn;
  }

  DateTime? _parseTime(String value, DateTime base) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (match == null) return null;

    var hour = int.tryParse(match.group(1)!) ?? -1;
    final minute = int.tryParse(match.group(2)!) ?? -1;
    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) return null;

    final period = match.group(3)!.toUpperCase();
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

    return _AwalWaqtData(
      active: active,
      remaining: active ? end.difference(now) : Duration.zero,
      start: start,
      end: end,
    );
  }

  String _formatRemaining(Duration duration) {
    final total = duration.inSeconds.clamp(0, 86399);
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatClock(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color?.withValues(alpha: .72) ??
        theme.colorScheme.onSurface.withValues(alpha: .72);
    final safeProgress = progress.clamp(0.0, 1.0);
    final percentage = (safeProgress * 100).round();
    final awal = _awalWaqtData();
    final current = currentPrayer.isEmpty
        ? _label(bn: 'ওয়াক্ত নেই', en: 'No prayer', ar: 'لا صلاة')
        : currentPrayer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withValues(alpha: .06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _ContextPrayer(
                  label: _label(bn: 'পূর্ববর্তী', en: 'Previous', ar: 'السابق'),
                  prayer: previousPrayer.isEmpty ? '--' : previousPrayer,
                  time: previousPrayerTime,
                  icon: Icons.history_rounded,
                  color: secondary,
                  text: text,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mosque_rounded, size: 14, color: primary),
                        const SizedBox(width: 4),
                        Text(
                          _label(bn: 'বর্তমান', en: 'Current', ar: 'الحالية'),
                          style: TextStyle(
                            color: primary.withValues(alpha: .82),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      current,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: text,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      currentPrayerTime.isEmpty ? '--:--' : currentPrayerTime,
                      style: TextStyle(
                        color: primary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _ContextPrayer(
                  label: _label(bn: 'পরবর্তী', en: 'Next', ar: 'التالي'),
                  prayer: nextPrayer.isEmpty ? '--' : nextPrayer,
                  time: nextPrayerTime,
                  icon: Icons.arrow_forward_rounded,
                  color: secondary,
                  text: text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .055),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primary.withValues(alpha: .07)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _label(bn: 'সময় বাকি', en: 'Time left', ar: 'الوقت المتبقي'),
                  style: TextStyle(color: secondary, fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      remainingTime.isEmpty ? '--:--:--' : remainingTime,
                      style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: .4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _TimeLabel(
                  label: _label(bn: 'শুরু', en: 'Start', ar: 'البداية'),
                  time: currentPrayerTime,
                  color: secondary,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _TimeLabel(
                    label: _label(bn: 'শেষ', en: 'End', ar: 'النهاية'),
                    time: nextPrayerTime,
                    color: secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: safeProgress,
                    minHeight: 6,
                    backgroundColor: primary.withValues(alpha: .09),
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$percentage%', style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.bolt_rounded, size: 17, color: primary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  _awalText(awal),
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: TextStyle(color: text, fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.3),
                ),
              ),
              if (awal != null && awal.active) ...[
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 86),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_formatRemaining(awal.remaining)} ${_label(bn: 'বাকি', en: 'left', ar: 'متبقي')}',
                      maxLines: 1,
                      style: TextStyle(color: primary, fontSize: 11.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (status.isNotEmpty) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 15, color: secondary),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: secondary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onJamaatTap,
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(13)),
                child: Row(
                  children: [
                    Icon(Icons.groups_rounded, size: 16, color: primary),
                    const SizedBox(width: 7),
                    Text(_label(bn: 'জামাআত', en: 'Jamaat', ar: 'الجماعة'), style: TextStyle(color: secondary, fontSize: 12, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text(iqamahTime.isEmpty ? '--:--' : iqamahTime, style: TextStyle(color: text, fontSize: 12.5, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 17, color: secondary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _awalText(_AwalWaqtData? data) {
    if (data == null) {
      return _label(
        bn: 'আওয়াল ওয়াক্তের তথ্য প্রস্তুত হচ্ছে',
        en: 'Awal Waqt is being prepared',
        ar: 'جارٍ تجهيز وقت الأول',
      );
    }
    final label = data.active
        ? _label(bn: 'আওয়াল ওয়াক্ত চলছে', en: 'Awal Waqt active', ar: 'وقت الأول مستمر')
        : _label(bn: 'আওয়াল ওয়াক্ত শেষ', en: 'Awal Waqt ended', ar: 'انتهى وقت الأول');
    return '$label • ${_formatClock(data.start)} → ${_formatClock(data.end)}';
  }
}

class _ContextPrayer extends StatelessWidget {
  final String label;
  final String prayer;
  final String time;
  final IconData icon;
  final Color color;
  final Color text;

  const _ContextPrayer({
    required this.label,
    required this.prayer,
    required this.time,
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 1),
        Text(
          prayer,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w800),
        ),
        Text(time.isEmpty ? '--:--' : time, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _TimeLabel extends StatelessWidget {
  final String label;
  final String time;
  final Color color;

  const _TimeLabel({required this.label, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label  ', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        Flexible(
          child: Text(
            time.isEmpty ? '--:--' : time,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _AwalWaqtData {
  final bool active;
  final Duration remaining;
  final DateTime start;
  final DateTime end;

  const _AwalWaqtData({
    required this.active,
    required this.remaining,
    required this.start,
    required this.end,
  });
}
