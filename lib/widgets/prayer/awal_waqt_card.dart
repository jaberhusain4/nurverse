import 'package:flutter/material.dart';

import '../../controllers/prayer_controller.dart';
import '../../localization/app_localizations.dart';
import '../../services/awal_waqt_service.dart';
import '../../theme/app_theme.dart';

class AwalWaqtCard extends StatelessWidget {
  final PrayerController controller;
  final bool compact;

  const AwalWaqtCard({
    super.key,
    required this.controller,
    this.compact = false,
  });

  static const _service = AwalWaqtService();

  String _prayerLabel(AppLocalizations l10n, String key) {
    return l10n.prayerName(key);
  }

  String _formatDuration(Duration value) {
    if (value.isNegative || value == Duration.zero) return '00:00:00';
    final h = value.inHours.toString().padLeft(2, '0');
    final m = (value.inMinutes % 60).toString().padLeft(2, '0');
    final s = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final windows = _service.buildWindowsFromPrayerList(
      controller.prayers,
      now: now,
    );
    final active = _service.activeWindow(windows, now);
    final primary = Theme.of(context).colorScheme.primary;

    if (compact) {
      return _buildCompact(context, active, primary, now, l10n);
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.schedule_rounded, color: primary, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tr('আওয়াল ওয়াক্ত', 'Awal Waqt'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        active == null
                            ? l10n.tr('বর্তমানে কোনো ওয়াক্তের আওয়াল সময় চলছে না', 'No Awal Waqt period is currently active')
                            : l10n.isArabic
                                ? '${_prayerLabel(l10n, active.prayerKey)} — وقت الأول مستمر'
                                : '${_prayerLabel(l10n, active.prayerKey)} — ${l10n.tr('আওয়াল ওয়াক্ত চলছে', 'Awal Waqt active')}',
                        style: TextStyle(
                          color: active == null
                              ? context.secondaryTextColor
                              : primary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (active != null)
                  Text(
                    _formatDuration(active.remainingFrom(now)),
                    style: TextStyle(
                      color: primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: windows.map((window) {
                final isActive = active?.prayerKey == window.prayerKey;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? primary.withValues(alpha: .10)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: isActive
                              ? primary.withValues(alpha: .22)
                              : primary.withValues(alpha: .06),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _prayerLabel(l10n, window.prayerKey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isActive ? primary : context.primaryTextColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${_service.formatTime(window.start)}–${_service.formatTime(window.end)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.secondaryTextColor,
                              fontSize: 8.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(
    BuildContext context,
    AwalWaqtWindow? active,
    Color primary,
    DateTime now,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: .08)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, color: primary, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              active == null
                  ? l10n.tr('আওয়াল ওয়াক্ত শেষ', 'Awal Waqt ended')
                  : l10n.isArabic
                      ? '${_prayerLabel(l10n, active.prayerKey)} — وقت الأول مستمر'
                      : '${_prayerLabel(l10n, active.prayerKey)} — ${l10n.tr('আওয়াল ওয়াক্ত চলছে', 'Awal Waqt active')}',
              style: TextStyle(
                color: active == null ? context.secondaryTextColor : primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (active != null)
            Text(
              _formatDuration(active.remainingFrom(now)),
              style: TextStyle(
                color: primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}
