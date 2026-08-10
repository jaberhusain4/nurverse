class TimeFormatter {
  static String format12Hour(DateTime time) {
    int hour = time.hour;

    final period = hour >= 12 ? "PM" : "AM";

    hour = hour % 12;

    if (hour == 0) hour = 12;

    final h = hour.toString().padLeft(2, "0");
    final m = time.minute.toString().padLeft(2, "0");

    return "$h:$m $period";
  }
}
