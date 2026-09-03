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
if needle in s and "prayerController.setTimeFormat(settings.is24Hour);" not in s:
    s = s.replace(needle, needle + "    prayerController.setTimeFormat(settings.is24Hour);\n", 1)
p.write_text(s, encoding='utf-8')

# Prayer screen live clock follows the same setting.
p = Path('lib/screens/prayer_screen.dart')
s = p.read_text(encoding='utf-8')
old = """  void _updateClock() {\n    final now = DateTime.now();\n    final period = now.hour >= 12 ? 'PM' : 'AM';\n    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;\n    final value = '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $period';\n    if (!mounted || _currentTime == value) return;\n    setState(() => _currentTime = value);\n  }"""
new = """  void _updateClock() {\n    final now = DateTime.now();\n    final settings = context.read<SettingsProvider>();\n    final value = settings.is24Hour\n        ? DateFormat('HH:mm:ss', 'en_US').format(now)\n        : DateFormat('hh:mm:ss a', 'en_US').format(now);\n    if (!mounted || _currentTime == value) return;\n    setState(() => _currentTime = value);\n  }"""
if old in s:
    s = s.replace(old, new, 1)
p.write_text(s, encoding='utf-8')
print('time format wiring applied')
