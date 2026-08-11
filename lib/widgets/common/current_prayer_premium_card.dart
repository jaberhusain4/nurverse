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
      case 'en':
        return en;
      case 'ar':
        return ar;
      default:
        return bn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyLarge?.color ?? scheme.onSurface;
    final secondary =
        theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.66) ??
        scheme.onSurface.withValues(alpha: 0.66);
    final primary = scheme.primary;
    final safeProgress = progress.clamp(0.0, 1.0);
    final percentage = (safeProgress * 100).round();

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
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
                child: _PrayerMini(
                  label: _label(bn: 'পূর্ববর্তী', en: 'Previous', ar: 'السابق'),
                  prayer: previous,
                  time: previousPrayerTime,
                  icon: Icons.history_rounded,
                  color: secondary,
                  textColor: textColor,
                  alignEnd: false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.055),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _label(bn: 'সময় বাকি', en: 'Time left', ar: 'الوقت المتبقي'),
                        style: TextStyle(
                          color: secondary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          remainingTime.isEmpty ? '--:--:--' : remainingTime,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PrayerMini(
                  label: _label(bn: 'পরবর্তী', en: 'Next', ar: 'التالي'),
                  prayer: next,
                  time: nextPrayerTime,
                  icon: Icons.arrow_forward_rounded,
                  color: secondary,
                  textColor: textColor,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.075),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.11),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mosque_rounded, color: primary, size: 16),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _label(bn: 'বর্তমান সালাত', en: 'Current prayer', ar: 'الصلاة الحالية'),
                        style: TextStyle(color: secondary, fontSize: 9.5, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        current,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                Text(
                  currentPrayerTime.isEmpty ? '--:--' : currentPrayerTime,
                  style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _TimeLabel(
                label: _label(bn: 'শুরু', en: 'Start', ar: 'البداية'),
                time: currentPrayerTime,
                color: secondary,
              ),
              const Spacer(),
              _TimeLabel(
                label: _label(bn: 'শেষ', en: 'End', ar: 'النهاية'),
                time: nextPrayerTime,
                color: secondary,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: safeProgress,
                    minHeight: 6,
                    backgroundColor: primary.withValues(alpha: 0.09),
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$percentage%',
                style: TextStyle(color: primary, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: secondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  status.isEmpty ? _label(bn: 'সালাতের সময় গণনা করা হচ্ছে...', en: 'Calculating prayer time...', ar: 'جارٍ حساب وقت الصلاة...') : status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: secondary, fontSize: 9.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onJamaatTap,
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.045),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Icon(Icons.groups_rounded, size: 16, color: primary),
                    const SizedBox(width: 7),
                    Text(
                      _label(bn: 'জামাআত', en: 'Jamaat', ar: 'الجماعة'),
                      style: TextStyle(color: secondary, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      iqamahTime.isEmpty ? '--:--' : iqamahTime,
                      style: TextStyle(color: textColor, fontSize: 11.5, fontWeight: FontWeight.w800),
                    ),
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
}

class _PrayerMini extends StatelessWidget {
  final String label;
  final String prayer;
  final String time;
  final IconData icon;
  final Color color;
  final Color textColor;
  final bool alignEnd;

  const _PrayerMini({
    required this.label,
    required this.prayer,
    required this.time,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.alignEnd,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.end : TextAlign.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 1),
        Text(
          prayer,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 1),
        Text(time.isEmpty ? '--:--' : time, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
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
      children: [
        Text('$label  ', style: TextStyle(color: color, fontSize: 8.5)),
        Text(
          time.isEmpty ? '--:--' : time,
          style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
