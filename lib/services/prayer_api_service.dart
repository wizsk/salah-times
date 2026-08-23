import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_day.dart';

class PrayerApiService {
  static const String _baseUrl = 'https://api.aladhan.com/v1/calendar';

  Future<List<PrayerDay>> fetchMonthlyPrayers({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/$year/$month?method=1&school=1&latitude=$latitude&longitude=$longitude',
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['code'] == 200 && decoded['data'] is List) {
        return (decoded['data'] as List)
            .map((item) => PrayerDay.fromJson(item))
            .toList();
      } else {
        throw Exception('Unexpected API response: ${decoded['status']}');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}
