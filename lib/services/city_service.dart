import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart' show rootBundle;

import '../models/city.dart';

enum InitState {
  not,
  initing,
  done;

  bool get isInited => this == done;
  bool get isNotInited => this == not;
  bool get isIniting => this == initing;
}

/// Loads and searches cities from assets/cities.json.
/// The list is loaded once and cached for the app lifetime.
class CityService {
  static List<City>? _cities;

  static final Completer<void> _wait = Completer<void>();

  // /// Returns the full city list, loading from asset on first call.
  // static Future<List<City>> cities() async {
  //   _cities ??= await _load();
  //   return _cities!;
  // }

  static InitState _initState = InitState.not;
  static Future<void> load() async {
    if (_initState.isInited) return;

    if (_initState.isIniting) {
      await _wait.future;
      return;
    }

    _initState = InitState.initing;

    final raw = await rootBundle.loadString('assets/cities.json');
    // Parse in a background isolate so the main thread isn't blocked
    _cities = await Isolate.run(() {
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => City.fromJson(e as Map<String, dynamic>)).toList();
    });
    _initState = InitState.done;
    _wait.complete();
  }

  // ── Search ────────────────────────────────────────────────────────────────

  /// Returns up to [limit] cities whose ASCII name contains [query]
  /// (case-insensitive), sorted alphabetically.
  static Future<List<City>> search(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return const [];

    if (_initState.isNotInited) await load();
    if (_initState.isIniting) await _wait.future;

    final q = query.trim().toLowerCase();
    final results =
        _cities!
            .where(
              (c) =>
                  c.cityAscii.toLowerCase().contains(q) ||
                  c.city.toLowerCase().contains(q) ||
                  c.country.toLowerCase().contains(q),
            )
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
  static const double nearThresholdKm = 10.0;

  /// Finds the city nearest to [lat]/[lng] and returns a display label.
  ///
  /// Returns `(cityName, isNear)` where [isNear] is true when the closest
  /// city is further than [nearThresholdKm] km away.
  // static Future<({String label, bool isNear, City city})> nearestCity(
  static Future<({String label, bool isNear})> nearestCity(
    double lat,
    double lng,
  ) async {
    if (_initState.isNotInited) await load();

    if (_initState.isIniting) await _wait.future;

    final all = _cities!;
    City? nearest;
    double minDist = double.infinity;

    for (final c in all) {
      final d = c.distanceTo(lat, lng);
      if (d < minDist) {
        minDist = d;
        nearest = c;
      }
    }

    if (nearest == null) {
      return (label: 'Not Found', isNear: false);
      // return (label: 'Not Found', isNear: false, city: all.first);
    }

    final isNear = minDist > nearThresholdKm;
    final label = isNear ? 'near ${nearest.cityAscii}' : nearest.cityAscii;

    return (label: label, isNear: isNear);
  }
}
