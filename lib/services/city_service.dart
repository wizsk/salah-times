import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/services.dart' show rootBundle;
import '../models/city.dart';

/// Loads and searches cities from assets/cities.json.
/// The list is loaded once and cached for the app lifetime.
class CityService {
  static List<City>? _cities;

  // ── Load ──────────────────────────────────────────────────────────────────

  /// Returns the full city list, loading from asset on first call.
  static Future<List<City>> cities() async {
    _cities ??= await _load();
    return _cities!;
  }

  static Future<List<City>> _load() async {
    final raw = await rootBundle.loadString('assets/cities.json');
    // Parse in a background isolate so the main thread isn't blocked
    return await Isolate.run(() {
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => City.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  // ── Search ────────────────────────────────────────────────────────────────

  /// Returns up to [limit] cities whose ASCII name contains [query]
  /// (case-insensitive), sorted alphabetically.
  static Future<List<City>> search(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return const [];
    final all = await cities();
    final q = query.trim().toLowerCase();
    final results = all
        .where((c) =>
            c.cityAscii.toLowerCase().contains(q) ||
            c.city.toLowerCase().contains(q) ||
            c.country.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) {
        // Exact prefix matches first
        final aStarts = a.cityAscii.toLowerCase().startsWith(q) ? 0 : 1;
        final bStarts = b.cityAscii.toLowerCase().startsWith(q) ? 0 : 1;
        if (aStarts != bStarts) return aStarts - bStarts;
        return a.cityAscii.compareTo(b.cityAscii);
      });
    return results.take(limit).toList();
  }

  // ── Nearest city ──────────────────────────────────────────────────────────

  /// Threshold (km) beyond which we prepend "near" to the city name.
  static const double nearThresholdKm = 50.0;

  /// Finds the city nearest to [lat]/[lng] and returns a display label.
  ///
  /// Returns `(cityName, isNear)` where [isNear] is true when the closest
  /// city is further than [nearThresholdKm] km away.
  static Future<({String label, bool isNear, City city})> nearestCity(
      double lat, double lng) async {
    final all = await cities();
    City? nearest;
    double minDist = double.infinity;

    for (final c in all) {
      final d = c.distanceTo(lat, lng);
      if (d < minDist) {
        minDist = d;
        nearest = c;
      }
    }

    if (nearest == null) return (label: '', isNear: false, city: all.first);
    final isNear = minDist > nearThresholdKm;
    final label = isNear ? 'near ${nearest.city}' : nearest.city;
    return (label: label, isNear: isNear, city: nearest);
  }
}
