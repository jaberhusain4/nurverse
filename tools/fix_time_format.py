from pathlib import Path

# Wire SettingsProvider's 12/24-hour preference into the central prayer formatter.
p = Path('lib/controllers/prayer_controller.dart')
s = p.read_text(encoding='utf-8')
if "bool _is24Hour = false;" not in s:
    s = s.replace("  Timer? _ticker;\n", "  Timer? _ticker;\n  bool _is24Hour = false;\n", 1)
if "bool get is24Hour => _is24Hour;" not in s:
    s = s.replace("  bool get loading => _loading;\n", "  bool get is24Hour => _is24Hour;\n  bool get loading => _loading;\n", 1)
if "void setTimeFormat(bool is24Hour)" not in s:
    marker = "  void setCalculationConfig(PrayerCalculationConfig config) {"
    helper = "  void setTimeFormat(bool is24Hour) {\n    if (_is24Hour == is24Hour) return;\n    _is24Hour = is24Hour;\n    _invalidateScheduleCache();\n    _safeRefresh();\n  }\n\n"
    s = s.replace(marker, helper + marker, 1)
s = s.replace("String _formatTime(DateTime value) => DateFormat('h:mm a', 'en_US').format(value);", "String _formatTime(DateTime value) => DateFormat(_is24Hour ? 'HH:mm' : 'h:mm a', 'en_US').format(value);")
p.write_text(s, encoding='utf-8')

# Main navigation syncs the preference whenever SettingsProvider changes.
p = Path('lib/main.dart')
s = p.read_text(encoding='utf-8')
needle = "    prayerController.updateCalculationSettings(\n      calculationMethod: settings.calculationMethod,\n      madhhab: settings.madhhab,\n    );\n"
if "prayerController.setTimeFormat(settings.is24Hour);" not in s:
    if needle in s:
        s = s.replace(needle, needle + "    prayerController.setTimeFormat(settings.is24Hour);\n", 1)
    else:
        fallback = "    prayerController.updatePrayerAdjustments(settings.prayerAdjustments);\n"
        if fallback in s:
            s = s.replace(fallback, "    prayerController.setTimeFormat(settings.is24Hour);\n" + fallback, 1)
p.write_text(s, encoding='utf-8')

# Prayer screen live clock follows the same setting.
p = Path('lib/screens/prayer_screen.dart')
s = p.read_text(encoding='utf-8')
old = """  void _updateClock() {
    final now = DateTime.now();
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final value = '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $period';
    if (!mounted || _currentTime == value) return;
    setState(() => _currentTime = value);
  }"""
new = """  void _updateClock() {
    final now = DateTime.now();
    final settings = context.read<SettingsProvider>();
    final value = settings.is24Hour
        ? DateFormat('HH:mm:ss', 'en_US').format(now)
        : DateFormat('hh:mm:ss a', 'en_US').format(now);
    if (!mounted || _currentTime == value) return;
    setState(() => _currentTime = value);
  }"""
if old in s:
    s = s.replace(old, new, 1)
p.write_text(s, encoding='utf-8')
print('time format wiring applied')
