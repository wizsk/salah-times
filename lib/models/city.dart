import 'dart:math';

import 'package:salah_times/services/app_conf.dart';
import 'package:salah_times/utils/utils.dart';

class City {
  final String cityNorm;
  final String city;
  final double lat;
  final double lng;
  final String country;
  final String countryNorm;

  const City({
    required this.lat,
    required this.lng,
    required this.city,
    required this.country,
    required this.cityNorm,
    required this.countryNorm,
  });

  PrayerLocation toPrayerLocation() {
    return PrayerLocation(lat, lng, city, tzName());
  }

  factory City.fromJson(Map<String, dynamic> j) {
    final cityNameAscii = j['city_ascii'] as String? ?? j['city'] as String;
    final country = j['country'] as String;

    return City(
      city: cityNameAscii,
      cityNorm: cityNameAscii.toLowerCase(),
      country: country,
      countryNorm: country.toLowerCase(),
      lat: (j['lat'] as num).toDouble(),
      lng: (j['lng'] as num).toDouble(),
    );
  }

  /// Haversine distance in kilometres to [lat2]/[lng2].
  double distanceTo(double lat2, double lng2) {
    const r = 6371.0; // Earth radius km
    final dLat = _rad(lat2 - lat);
    final dLng = _rad(lng2 - lng);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat)) * cos(_rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _rad(double deg) => deg * pi / 180;

  @override
  String toString() =>
      'City(cityAscii:$city, $country, lat: $lat, lng: $lng)';
}
