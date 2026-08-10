import '../data/ayahs.dart';
import '../data/hadiths.dart';
import '../data/duas.dart';
import '../models/daily_content_model.dart';

class DailyContentService {
  const DailyContentService._();

  static DailyContentModel getTodayAyah() {
    final index = _dayIndex(dailyAyahs.length);
    return dailyAyahs[index];
  }

  static DailyContentModel getTodayHadith() {
    final index = _dayIndex(dailyHadiths.length);
    return dailyHadiths[index];
  }

  static DailyContentModel getTodayDua() {
    final index = _dayIndex(dailyDuas.length);
    return dailyDuas[index];
  }

  static int _dayIndex(int totalItems) {
    if (totalItems == 0) return 0;

    final now = DateTime.now();

    final firstDay = DateTime(2026, 1, 1);

    final difference = now.difference(firstDay).inDays.abs();

    return difference % totalItems;
  }
}
