import 'dart:math';

import 'package:salah_times/services/app_conf.dart';

class City {
  final String city;
  final String cityAscii;
  final double lat;
  final double lng;
  final String country;

  const City({
    required this.city,
    required this.cityAscii,
    required this.lat,
    required this.lng,
    required this.country,
  });

  PrayerLocation toPrayerLocation() {
    return PrayerLocation(lat, lng, cityAscii);
  }

  factory City.fromJson(Map<String, dynamic> j) => City(
    city: j['city'] as String,
    cityAscii: j['city_ascii'] as String? ?? j['city'] as String,
    lat: (j['lat'] as num).toDouble(),
    lng: (j['lng'] as num).toDouble(),
    country: j['country'] as String,
  );

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
      'City(city: $city, cityAscii:$cityAscii, $country, lat: $lat, lng: $lng)';
}
