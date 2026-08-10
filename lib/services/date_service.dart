import 'package:intl/intl.dart';

class DateService {
  static DateTime get now => DateTime.now();

  static String englishDate() {
    return DateFormat('EEEE, dd MMMM yyyy', 'en').format(now);
  }

  static String englishTime() {
    return DateFormat('hh:mm a', 'en').format(now);
  }

  static String weekDayEnglish() {
    return DateFormat('EEEE', 'en').format(now);
  }

  static String monthEnglish() {
    return DateFormat('MMMM', 'en').format(now);
  }

  static String dayEnglish() {
    return DateFormat('dd', 'en').format(now);
  }

  static String yearEnglish() {
    return DateFormat('yyyy', 'en').format(now);
  }
}
