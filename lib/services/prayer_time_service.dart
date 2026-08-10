import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/prayer_time_model.dart';

class PrayerTimeService {
  static const String _baseUrl = 'https://api.aladhan.com/v1/timings';

  const PrayerTimeService();

  Future<PrayerTimeModel> getPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    final now = DateTime.now();

    final uri = Uri.parse(
      '$_baseUrl/${now.day}-${now.month}-${now.year}'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&method=2',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Failed to load prayer times (${response.statusCode})');
      }

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      final data = json['data'] as Map<String, dynamic>;
      final timings = data['timings'] as Map<String, dynamic>;

      return PrayerTimeModel.fromJson(timings);
    } catch (e) {
      throw Exception('Unable to fetch prayer times: $e');
    }
  }
}
