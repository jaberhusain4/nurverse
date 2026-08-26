from pathlib import Path


def display_helper():
    return """
  String _displayTime(String value, bool showSeconds) {
    final raw = value.trim();
    if (showSeconds) return raw;
    final match = RegExp(r'^(\\d{1,2}:\\d{2})').firstMatch(raw);
    return match?.group(1) ?? raw;
  }

  List<Map<String, dynamic>> _displayPrayerTimes(List<Map<String, dynamic>> prayers, bool showSeconds) {
    return prayers.map((prayer) {
      final copy = Map<String, dynamic>.from(prayer);
      for (final key in const ['start', 'end', 'jamaat', 'time', 'formattedTime']) {
        final value = copy[key];
        if (value != null) copy[key] = _displayTime(value.toString(), showSeconds);
      }
      return copy;
    }).toList(growable: false);
  }
"""


def patch(path, replacements):
    p = Path(path)
    s = p.read_text(encoding='utf-8')
    marker = "  String _greeting(String languageCode) {"
    if '_displayPrayerTimes(List<Map<String, dynamic>> prayers' not in s:
        if marker not in s:
            raise SystemExit(f'marker missing: {path}')
        s = s.replace(marker, display_helper() + "\n" + marker, 1)
    for old, new in replacements:
        if old not in s:
            raise SystemExit(f'pattern missing in {path}: {old[:120]}')
        s = s.replace(old, new, 1)
    p.write_text(s, encoding='utf-8')


patch('lib/screens/home_screen.dart', [
    ("currentTime: _currentTime,", "currentTime: _displayTime(_currentTime, settings.showSeconds),"),
    ("previousPrayerTime: controller.previousPrayerTime,", "previousPrayerTime: _displayTime(controller.previousPrayerTime, settings.showSeconds),"),
    ("currentPrayerTime: controller.currentPrayerTime,", "currentPrayerTime: _displayTime(controller.currentPrayerTime, settings.showSeconds),"),
    ("nextPrayerTime: controller.nextPrayerTime,", "nextPrayerTime: _displayTime(controller.nextPrayerTime, settings.showSeconds),"),
    ("remainingTime: controller.timeRemainingForNextPrayer,", "remainingTime: _displayTime(controller.timeRemainingForNextPrayer, settings.showSeconds),"),
    ("iqamahTime: currentJamaat,", "iqamahTime: _displayTime(currentJamaat, settings.showSeconds),"),
    ("PrayerTimelineCard(prayers: controller.prayers, languageCode: languageCode)", "PrayerTimelineCard(prayers: _displayPrayerTimes(controller.prayers, settings.showSeconds), languageCode: languageCode)"),
    ("sunrise: sunTimes?.sunriseString ?? controller.sunriseTime,", "sunrise: _displayTime(sunTimes?.sunriseString ?? controller.sunriseTime, settings.showSeconds),"),
    ("sunset: sunTimes?.sunsetString ?? controller.sunsetTime,", "sunset: _displayTime(sunTimes?.sunsetString ?? controller.sunsetTime, settings.showSeconds),"),
])

patch('lib/screens/prayer_screen.dart', [
    ("currentTime: _currentTime,", "currentTime: _displayTime(_currentTime, settings.showSeconds),"),
    ("previousPrayerTime: controller.previousPrayerTime,", "previousPrayerTime: _displayTime(controller.previousPrayerTime, settings.showSeconds),"),
    ("currentPrayerTime: controller.currentPrayerTime,", "currentPrayerTime: _displayTime(controller.currentPrayerTime, settings.showSeconds),"),
    ("nextPrayerTime: controller.nextPrayerTime,", "nextPrayerTime: _displayTime(controller.nextPrayerTime, settings.showSeconds),"),
    ("remainingTime: controller.timeRemainingForNextPrayer,", "remainingTime: _displayTime(controller.timeRemainingForNextPrayer, settings.showSeconds),"),
    ("iqamahTime: currentJamaat,", "iqamahTime: _displayTime(currentJamaat, settings.showSeconds),"),
    ("PrayerTimelineCard(prayers: controller.prayers.where((p) => p['category'] == 'obligatory').toList(growable: false), languageCode: languageCode)", "PrayerTimelineCard(prayers: _displayPrayerTimes(controller.prayers.where((p) => p['category'] == 'obligatory').toList(growable: false), settings.showSeconds), languageCode: languageCode)"),
    ("sunrise: sunTimes?.sunriseString ?? controller.sunriseTime,", "sunrise: _displayTime(sunTimes?.sunriseString ?? controller.sunriseTime, settings.showSeconds),"),
    ("sunset: sunTimes?.sunsetString ?? controller.sunsetTime,", "sunset: _displayTime(sunTimes?.sunsetString ?? controller.sunsetTime, settings.showSeconds),"),
    ("final start = data['start']?.toString() ?? '--:--';", "final start = _displayTime(data['start']?.toString() ?? '--:--', context.read<SettingsProvider>().showSeconds);"),
    ("final end = data['end']?.toString() ?? '--:--';", "final end = _displayTime(data['end']?.toString() ?? '--:--', context.read<SettingsProvider>().showSeconds);"),
    ("final jamaat = data['jamaat']?.toString() ?? '--:--';", "final jamaat = _displayTime(data['jamaat']?.toString() ?? '--:--', context.read<SettingsProvider>().showSeconds);"),
    ("Text('${nafl[i]['start'] ?? '--:--'} – ${nafl[i]['end'] ?? '--:--'}'", "Text('${_displayTime(nafl[i]['start']?.toString() ?? '--:--', context.read<SettingsProvider>().showSeconds)} – ${_displayTime(nafl[i]['end']?.toString() ?? '--:--', context.read<SettingsProvider>().showSeconds)}'"),
    ("sunTimes?.sunriseString ?? controller.sunriseTime, primary", "_displayTime(sunTimes?.sunriseString ?? controller.sunriseTime, context.read<SettingsProvider>().showSeconds), primary"),
    ("controller.solarNoonTime, primary", "_displayTime(controller.solarNoonTime, context.read<SettingsProvider>().showSeconds), primary"),
    ("sunTimes?.sunsetString ?? controller.sunsetTime, primary", "_displayTime(sunTimes?.sunsetString ?? controller.sunsetTime, context.read<SettingsProvider>().showSeconds), primary"),
])
