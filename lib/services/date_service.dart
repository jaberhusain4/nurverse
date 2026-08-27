import 'package:intl/intl.dart';

class DateService {
  static DateTime get now => DateTime.now();

  static String englishDate() {
    return DateFormat('EEEE, dd MMMM yyyy', 'en').format(now);
  }

  static String banglaCalendarDate([DateTime? date]) {
    const months = [
      'বৈশাখ',
      'জ্যৈষ্ঠ',
      'আষাঢ়',
      'শ্রাবণ',
      'ভাদ্র',
      'আশ্বিন',
      'কার্তিক',
      'অগ্রহায়ণ',
      'পৌষ',
      'মাঘ',
      'ফাল্গুন',
      'চৈত্র',
    ];
    const monthStarts = [
      [4, 14],
      [5, 15],
      [6, 15],
      [7, 16],
      [8, 16],
      [9, 16],
      [10, 16],
      [11, 15],
      [12, 15],
      [1, 15],
      [2, 14],
      [3, 15],
    ];
    const banglaDigits = '০১২৩৪৫৬৭৮৯';

    final value = date ?? now;
    final startYear = value.month > 4 || (value.month == 4 && value.day >= 14)
        ? value.year
        : value.year - 1;
    final starts = monthStarts
        .map(
          (monthDay) => DateTime(
            monthDay[0] < 4 ? startYear + 1 : startYear,
            monthDay[0],
            monthDay[1],
          ),
        )
        .toList(growable: false);
    final monthIndex = starts.lastIndexWhere(
      (start) => !value.isBefore(start),
    );
    final day = value.difference(starts[monthIndex]).inDays + 1;

    String toBanglaDigits(int number) => number
        .toString()
        .split('')
        .map((digit) => banglaDigits[int.parse(digit)])
        .join();

    return '${toBanglaDigits(day)} ${months[monthIndex]} '
        '${toBanglaDigits(startYear - 593)}';
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
