import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../localization/app_localizations_x.dart';
import '../common/app_progress_bar.dart';

class CurrentPrayerCard extends StatelessWidget {
  final String currentPrayer;
  final String currentPrayerTime;
  final String nextPrayer;
  final String nextPrayerTime;
  final String remainingTime;
  final double progress;
  final String status;

  final String? sunrise;
  final String? sunset;

  const CurrentPrayerCard({
    super.key,
    required this.currentPrayer,
    required this.currentPrayerTime,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.remainingTime,
    required this.progress,
    required this.status,
    this.sunrise,
    this.sunset,
  });

  String _prayerLabel(AppLocalizations l10n, String value) {
    final raw = value.trim();
    switch (raw.toLowerCase()) {
      case 'fajr':
      case 'ফজর':
        return l10n.fajr;
      case 'dhuhr':
      case 'যোহর':
        return l10n.dhuhr;
      case 'asr':
      case 'আসর':
        return l10n.asr;
      case 'maghrib':
      case 'magrib':
      case 'মাগরিব':
        return l10n.maghrib;
      case 'isha':
      case 'ইশা':
        return l10n.isha;
      case 'ishraq':
      case 'ইশরাক':
        return l10n.ishraq;
      case 'duha':
      case 'chasht':
      case 'চাশত':
      case 'দুহা':
        return l10n.duha;
      case 'awwabin':
      case 'আউওয়াবীন':
        return l10n.awwabin;
      case 'tahajjud':
      case 'তাহাজ্জুদ':
        return l10n.tahajjud;
      case 'jumuah':
      case 'jumu’ah':
      case "jumu'ah":
      case 'জুমু‘আ':
      case 'জুমু\'আ':
      case 'জুমুআ':
        return l10n.jumuah;
      default:
        return l10n.prayerName(raw);
    }
  }

  String _statusLabel(AppLocalizations l10n, String value) {
    final raw = value.trim();
    const english = <String, String>{
      'ইশার ওয়াক্ত চলছে': 'Isha time is active',
      'ইশরাকের ওয়াক্ত চলছে': 'Ishraq time is active',
      'ইশরাক ওয়াক্ত চলছে': 'Ishraq time is active',
      'তাহাজ্জুদের ওয়াক্ত চলছে': 'Tahajjud time is active',
      'তাহাজ্জুদ ওয়াক্ত চলছে': 'Tahajjud time is active',
      'মাগরিবের ওয়াক্ত চলছে': 'Maghrib time is active',
      'Ishar Waqto Cholche': 'Isha time is active',
      'Ishar Waqt Cholche': 'Isha time is active',
      'Magrib time is active': 'Maghrib time is active',
    };
    if (l10n.isArabic) {
      const arabic = <String, String>{
        'ইশার ওয়াক্ত চলছে': 'وقت العشاء جارٍ',
        'ইশরাকের ওয়াক্ত চলছে': 'وقت الإشراق جارٍ',
        'ইশরাক ওয়াক্ত চলছে': 'وقت الإشراق جارٍ',
        'তাহাজ্জুদের ওয়াক্ত চলছে': 'وقت التهجد جارٍ',
        'তাহাজ্জুদ ওয়াক্ত চলছে': 'وقت التهجد جارٍ',
        'মাগরিবের ওয়াক্ত চলছে': 'وقت المغرب جارٍ',
        'Ishar Waqto Cholche': 'وقت العشاء جارٍ',
        'Ishar Waqt Cholche': 'وقت العشاء جارٍ',
        'Magrib time is active': 'وقت المغرب جارٍ',
        'Isha time is active': 'وقت العشاء جارٍ',
        'Maghrib time is active': 'وقت المغرب جارٍ',
        'Tahajjud time is active': 'وقت التهجد جارٍ',
        'Ishraq time is active': 'وقت الإشراق جارٍ',
      };
      return arabic[raw] ?? l10n.prayerStatus(raw);
    }
    if (l10n.isEnglish) return english[raw] ?? l10n.prayerStatus(raw);
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = const Color(0x220288D1);
    final shadowColor =
        isDark ? Colors.black.withValues(alpha: .35) : const Color(0x140288D1);
    final infoBg = theme.cardColor;

    final localizedStatus = _statusLabel(l10n, status);
    final statusForColor = status.toLowerCase();
    final chipBg = statusForColor.contains('মাকরুহ') ||
            statusForColor.contains('makruh')
        ? Colors.red.withValues(alpha: .10)
        : statusForColor.contains('জামাত') ||
                statusForColor.contains('jama')
            ? Colors.orange.withValues(alpha: .12)
            : Colors.green.withValues(alpha: .10);
    final chipText = statusForColor.contains('মাকরুহ') ||
            statusForColor.contains('makruh')
        ? Colors.red
        : statusForColor.contains('জামাত') ||
                statusForColor.contains('jama')
            ? Colors.orange
            : Colors.green;
    final currentPrayerLabel = _prayerLabel(l10n, currentPrayer);
    final nextPrayerLabel = _prayerLabel(l10n, nextPrayer);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xff0288D1).withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: Color(0xff0288D1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.currentPrayer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentPrayerLabel,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    localizedStatus,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: chipText,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            currentPrayerTime,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${l10n.next} • $nextPrayerLabel  •  $nextPrayerTime',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 20),
          AppProgressBar(value: progress),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  title: l10n.tr('বাকি', 'Remaining'),
                  value: remainingTime,
                  backgroundColor: infoBg,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoItem(
                  title: l10n.next,
                  value: nextPrayerLabel,
                  backgroundColor: infoBg,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoItem(
                  title: l10n.prayerTime,
                  value: nextPrayerTime,
                  backgroundColor: infoBg,
                ),
              ),
            ],
          ),
          if (sunrise != null || sunset != null) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                if (sunrise != null)
                  Expanded(
                    child: _InfoItem(
                      title: l10n.sunrise,
                      value: sunrise!,
                      backgroundColor: infoBg,
                    ),
                  ),
                if (sunrise != null && sunset != null)
                  const SizedBox(width: 10),
                if (sunset != null)
                  Expanded(
                    child: _InfoItem(
                      title: l10n.sunset,
                      value: sunset!,
                      backgroundColor: infoBg,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;

  const _InfoItem({
    required this.title,
    required this.value,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x150288D1)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
