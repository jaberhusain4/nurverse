import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/prayer_controller.dart';
import '../../localization/app_localizations.dart';
import '../../localization/app_localizations_locale_text_x.dart';
import '../../providers/settings_provider.dart';
import '../../services/prayer_engine_service.dart';

class LivePrayerRestrictionCard extends StatefulWidget {
  final String languageCode;
  const LivePrayerRestrictionCard({super.key, required this.languageCode});

  @override
  State<LivePrayerRestrictionCard> createState() => _LivePrayerRestrictionCardState();
}

class _LivePrayerRestrictionCardState extends State<LivePrayerRestrictionCard> {
  final PrayerEngineService _engine = const PrayerEngineService();
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _label(AppLocalizations l10n, {required String bn, required String en, required String ar}) =>
      l10n.localeText(values: {'bn': bn, 'en': en, 'ar': ar});

  String _clock(DateTime value, bool is24Hour) {
    final minute = value.minute.toString().padLeft(2, '0');
    if (is24Hour) {
      return '${value.hour.toString().padLeft(2, '0')}:$minute';
    }
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _countdown(Duration duration) {
    final totalSeconds = duration.inSeconds.clamp(0, 7 * 86400);
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  List<PrayerTimeWindow> _todayAndTomorrowWindows(PrayerController controller, DateTime date) {
    final position = controller.position;
    if (position == null) return const [];
    final windows = _engine.specialTimeWindows(position: position, date: date, config: controller.calculationConfig).values.toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return windows;
  }

  PrayerTimeWindow? _activeWindow(PrayerController controller) {
    for (final window in _todayAndTomorrowWindows(controller, DateTime(_now.year, _now.month, _now.day))) {
      if (!_now.isBefore(window.start) && _now.isBefore(window.end)) return window;
    }
    return null;
  }

  PrayerTimeWindow? _nextWindow(PrayerController controller) {
    final today = DateTime(_now.year, _now.month, _now.day);
    final candidates = <PrayerTimeWindow>[..._todayAndTomorrowWindows(controller, today), ..._todayAndTomorrowWindows(controller, today.add(const Duration(days: 1)))];
    candidates.sort((a, b) => a.start.compareTo(b.start));
    for (final window in candidates) {
      if (_now.isBefore(window.start)) return window;
    }
    return null;
  }

  String _name(AppLocalizations l10n, PrayerTimeWindow window) {
    final hour = window.start.hour;
    if (hour < 10) return _label(l10n, bn: 'সূর্যোদয়ের নিষিদ্ধ সময়', en: 'Sunrise prohibited time', ar: 'وقت النهي عند الشروق');
    if (hour >= 16) return _label(l10n, bn: 'সূর্যাস্তের নিষিদ্ধ সময়', en: 'Sunset prohibited time', ar: 'وقت النهي عند الغروب');
    return _label(l10n, bn: 'জাওয়ালের নিষিদ্ধ সময়', en: 'Zawal prohibited time', ar: 'وقت النهي عند الزوال');
  }

  Widget _timerRow({required BuildContext context, required String title, required String subtitle, required String timer, required bool active}) {
    final theme = Theme.of(context);
    final accent = active ? theme.colorScheme.error : theme.colorScheme.primary;
    final foreground = theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color ?? foreground.withValues(alpha: .7);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(color: accent.withValues(alpha: active ? .09 : .055), borderRadius: BorderRadius.circular(14), border: active ? Border.all(color: accent.withValues(alpha: .22)) : null),
      child: Row(children: [
        Icon(active ? Icons.timer_rounded : Icons.schedule_rounded, color: accent, size: 20),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: foreground, fontSize: 12.5, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 10.5, fontWeight: FontWeight.w600))])),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(timer, style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.w900, fontFeatures: const [FontFeature.tabularFigures()])),
          const SizedBox(height: 2),
          Builder(builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Text(active ? _label(l10n, bn: 'শেষ হবে', en: 'ends', ar: 'ينتهي') : _label(l10n, bn: 'শুরু হবে', en: 'starts', ar: 'يبدأ'), style: TextStyle(color: secondary, fontSize: 9.5, fontWeight: FontWeight.w700));
          }),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerController>();
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context);
    final active = _activeWindow(controller);
    final next = _nextWindow(controller);
    if (active == null && next == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurface;
    final secondary = theme.textTheme.bodySmall?.color ?? foreground.withValues(alpha: .7);
    final is24Hour = settings.is24Hour;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: theme.colorScheme.primary.withValues(alpha: .11))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.block_rounded, size: 21, color: active != null ? theme.colorScheme.error : theme.colorScheme.primary), const SizedBox(width: 8), Expanded(child: Text(_label(l10n, bn: 'নিষিদ্ধ সময়', en: 'Prohibited Prayer Times', ar: 'أوقات النهي'), style: TextStyle(color: foreground, fontSize: 16, fontWeight: FontWeight.w800)))]),
        const SizedBox(height: 10),
        if (active != null) _timerRow(context: context, title: _label(l10n, bn: 'বর্তমান নিষিদ্ধ সময়', en: 'Current prohibited time', ar: 'وقت النهي الحالي'), subtitle: '${_name(l10n, active)} • ${_clock(active.start, is24Hour)} – ${_clock(active.end, is24Hour)}', timer: _countdown(active.end.difference(_now)), active: true),
        if (active != null && next != null) const SizedBox(height: 8),
        if (next != null) _timerRow(context: context, title: _label(l10n, bn: 'পরবর্তী নিষিদ্ধ সময়', en: 'Next prohibited time', ar: 'وقت النهي التالي'), subtitle: '${_name(l10n, next)} • ${_clock(next.start, is24Hour)} – ${_clock(next.end, is24Hour)}', timer: _countdown(next.start.difference(_now)), active: false),
        const SizedBox(height: 7),
        Text(_label(l10n, bn: 'সময়গুলো প্রতি সেকেন্ডে লাইভ আপডেট হচ্ছে।', en: 'Times update live every second.', ar: 'الأوقات تتحدث مباشرة كل ثانية.'), style: TextStyle(color: secondary, fontSize: 10.5)),
      ]),
    );
  }
}
