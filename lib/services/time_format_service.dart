class TimeFormatService {
  const TimeFormatService._();

  static String formatClock(
    String value, {
    required bool is24Hour,
    bool showSeconds = false,
  }) {
    final raw = value.trim();
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([AaPp][Mm])?$',
    ).firstMatch(raw);
    if (match == null) return raw;

    var hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    final second = match.group(3);
    final period = match.group(4)?.toUpperCase();
    if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return raw;
    }

    if (period != null) {
      if (hour < 1 || hour > 12) return raw;
      hour = period == 'AM' ? (hour == 12 ? 0 : hour) : (hour == 12 ? 12 : hour + 12);
    }

    final hh24 = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    if (is24Hour) {
      final base = '$hh24:$mm';
      return showSeconds && second != null ? '$base:${second.padLeft(2, '0')}' : base;
    }

    final hh12 = (hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(2, '0');
    final base = '$hh12:$mm ${hour >= 12 ? 'PM' : 'AM'}';
    return showSeconds && second != null
        ? '$hh12:$mm:${second.padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}'
        : base;
  }
}
