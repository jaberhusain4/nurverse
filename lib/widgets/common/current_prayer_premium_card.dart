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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color?.withValues(alpha: .72) ??
        theme.colorScheme.onSurface.withValues(alpha: .72);
    final safeProgress = progress.clamp(0.0, 1.0);
    final current = currentPrayer.isEmpty
        ? _label(bn: 'ওয়াক্ত নেই', en: 'No prayer', ar: 'لا صلاة')
        : currentPrayer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(
          alpha: theme.brightness == Brightness.dark ? .62 : .72,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: .10)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mosque_rounded, size: 20, color: primary),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            _label(bn: 'বর্তমান', en: 'Current', ar: 'الحالية'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: primary.withValues(alpha: .84),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          current,
                          maxLines: 1,
                          style: TextStyle(
                            color: text,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          currentPrayerTime.isEmpty ? '--:--' : currentPrayerTime,
                          maxLines: 1,
                          style: TextStyle(
                            color: primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
          const SizedBox(height: 12),
          _RemainingTimePanel(
            label: _label(bn: 'সময় বাকি', en: 'Time left', ar: 'الوقت المتبقي'),
            value: remainingTime.isEmpty ? '--:--:--' : remainingTime,
            primary: primary,
            text: text,
            secondary: secondary,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimeLabel(
                  label: _label(bn: 'শুরু', en: 'Start', ar: 'البداية'),
                  time: currentPrayerTime,
                  color: secondary,
                  icon: Icons.play_arrow_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _TimeLabel(
                    label: _label(bn: 'শেষ', en: 'End', ar: 'النهاية'),
                    time: nextPrayerTime,
                    color: secondary,
                    icon: Icons.stop_rounded,
                    alignEnd: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: safeProgress,
                    minHeight: 5,
                    backgroundColor: primary.withValues(alpha: .09),
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(safeProgress * 100).round()}%',
                style: TextStyle(
                  color: primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (status.isNotEmpty) ...[
            const SizedBox(height: 9),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: secondary),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    status,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onJamaatTap,
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .045),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Icon(Icons.groups_rounded, size: 21, color: primary),
                    const SizedBox(width: 8),
                    Text(
                      _label(bn: 'জামাআত', en: 'Jamaat', ar: 'الجماعة'),
                      style: TextStyle(
                        color: secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          iqamahTime.isEmpty ? '--:--' : iqamahTime,
                          maxLines: 1,
                          style: TextStyle(
                            color: text,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(Icons.chevron_right_rounded, size: 19, color: secondary),
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
        Icon(icon, size: 21, color: color),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              prayer,
              maxLines: 1,
              style: TextStyle(
                color: text,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              time.isEmpty ? '--:--' : time,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RemainingTimePanel extends StatelessWidget {
  final String label;
  final String value;
  final Color primary;
  final Color text;
  final Color secondary;

  const _RemainingTimePanel({
    required this.label,
    required this.value,
    required this.primary,
    required this.text,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: .10)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 21, color: primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: secondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: TextStyle(
                  color: text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  final String label;
  final String time;
  final Color color;
  final IconData icon;
  final bool alignEnd;

  const _TimeLabel({
    required this.label,
    required this.time,
    required this.color,
    required this.icon,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              '$label: ${time.isEmpty ? '--:--' : time}',
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
