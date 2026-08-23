import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_day.dart';
import '../services/city_service.dart';
import '../services/prayer_api_service.dart';

class PrayerProvider extends ChangeNotifier {
  // ── SharedPreferences keys ────────────────────────────────────────────────
  static const _latKey        = 'latitude';
  static const _lonKey        = 'longitude';
  static const _themeModeKey  = 'theme_mode';
  static const _cityLabelKey  = 'city_label'; // persisted display label

  static const _cacheDirName  = 'prayer_cache';

  // ── State ─────────────────────────────────────────────────────────────────
  double?   _latitude;
  double?   _longitude;
  String    _cityLabel = '';   // e.g. "Dhaka" or "near Comilla"
  ThemeMode _themeMode = ThemeMode.system;
  bool      _isLoading = false;
  String?   _error;

  final Map<String, List<PrayerDay>> _monthlyCache = {};

  // ── Getters ───────────────────────────────────────────────────────────────
  double?   get latitude    => _latitude;
  double?   get longitude   => _longitude;
  String    get cityLabel   => _cityLabel;
  ThemeMode get themeMode   => _themeMode;
  bool      get isLoading   => _isLoading;
  String?   get error       => _error;
  bool      get hasLocation => _latitude != null && _longitude != null;

  final PrayerApiService _apiService = PrayerApiService();

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _latitude   = prefs.getDouble(_latKey);
    _longitude  = prefs.getDouble(_lonKey);
    _themeMode  = _parseThemeMode(prefs.getString(_themeModeKey) ?? 'system');
    _cityLabel  = prefs.getString(_cityLabelKey) ?? '';

    if (hasLocation) {
      await _loadCurrentMonth();
      _scheduleNextMonthPrefetch();
      // Refresh city label in background if not yet set
      if (_cityLabel.isEmpty) _refreshCityLabel();
    }
    notifyListeners();
  }

  // ── Theme ─────────────────────────────────────────────────────────────────

  Future<void> cycleTheme() async {
    _themeMode = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light  => ThemeMode.dark,
      ThemeMode.dark   => ThemeMode.system,
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeModeStr(_themeMode));
    notifyListeners();
  }

  // ── Location ──────────────────────────────────────────────────────────────

  /// Save coordinates + optional explicit city label (from city search).
  /// If [explicitLabel] is null the nearest city is resolved automatically.
  Future<void> saveLocation(double lat, double lon,
      {String? explicitLabel}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_lonKey, lon);
    _latitude  = lat;
    _longitude = lon;
    _monthlyCache.clear();
    await _deleteCacheDir();

    if (explicitLabel != null) {
      _cityLabel = explicitLabel;
      await prefs.setString(_cityLabelKey, _cityLabel);
    } else {
      _cityLabel = '';
      _refreshCityLabel(); // async, updates & notifies when done
    }

    await _loadCurrentMonth();
    _scheduleNextMonthPrefetch();
    notifyListeners();
  }

  /// Computes the nearest city label in background and notifies.
  Future<void> _refreshCityLabel() async {
    if (_latitude == null || _longitude == null) return;
    try {
      final result =
          await CityService.nearestCity(_latitude!, _longitude!);
      _cityLabel = result.label;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cityLabelKey, _cityLabel);
      notifyListeners();
    } catch (_) {}
  }

  // ── Prayer data ───────────────────────────────────────────────────────────

  List<PrayerDay>? getPrayerDaysForMonth(int year, int month) =>
      _monthlyCache[_cacheKey(year, month)];

  PrayerDay? getPrayerDayForDate(DateTime date) {
    final days = getPrayerDaysForMonth(date.year, date.month);
    if (days == null) return null;
    final target =
        '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
    try {
      return days.firstWhere((d) => d.gregorianDate == target);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadCurrentMonth() async {
    final now = DateTime.now();
    await fetchMonthIfNeeded(now.year, now.month);
  }

  void _scheduleNextMonthPrefetch() {
    final now = DateTime.now();
    if (now.day > 24) {
      final next = DateTime(now.year, now.month + 1);
      fetchMonthIfNeeded(next.year, next.month, silent: true);
    }
  }

  Future<void> fetchMonthIfNeeded(int year, int month,
      {bool silent = false}) async {
    final key = _cacheKey(year, month);
    if (_monthlyCache.containsKey(key)) return;

    final cached = await _readCacheFile(year, month);
    if (cached != null) {
      _monthlyCache[key] = cached;
      if (!silent) notifyListeners();
      return;
    }

    if (!hasLocation) return;

    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final days = await _apiService.fetchMonthlyPrayers(
        latitude:  _latitude!,
        longitude: _longitude!,
        year:  year,
        month: month,
      );
      _monthlyCache[key] = days;
      await _writeCacheFile(year, month, days);
    } catch (e) {
      if (!silent) _error = e.toString();
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshCurrentMonth() async {
    final now = DateTime.now();
    final key = _cacheKey(now.year, now.month);
    _monthlyCache.remove(key);
    await _deleteCacheFile(now.year, now.month);
    await fetchMonthIfNeeded(now.year, now.month);
  }

  // ── File cache ────────────────────────────────────────────────────────────

  Future<Directory> _getCacheDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_cacheDirName');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _getCacheFile(int year, int month) async {
    final dir = await _getCacheDir();
    return File('${dir.path}/${year}_${month.toString().padLeft(2, '0')}.json');
  }

  Future<List<PrayerDay>?> _readCacheFile(int year, int month) async {
    try {
      final file = await _getCacheFile(year, month);
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      return (json.decode(raw) as List)
          .map((e) => PrayerDay.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCacheFile(int year, int month, List<PrayerDay> days) async {
    try {
      final file = await _getCacheFile(year, month);
      await file.writeAsString(
          json.encode(days.map(_dayToJson).toList()), flush: true);
    } catch (_) {}
  }

  Future<void> _deleteCacheFile(int year, int month) async {
    try {
      final file = await _getCacheFile(year, month);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  Future<void> _deleteCacheDir() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDir.path}/$_cacheDirName');
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {}
  }

  // ── Serialisation ─────────────────────────────────────────────────────────

  String _cacheKey(int year, int month) => '$year-$month';

  ThemeMode _parseThemeMode(String v) => switch (v) {
        'light' => ThemeMode.light,
        'dark'  => ThemeMode.dark,
        _       => ThemeMode.system,
      };

  String _themeModeStr(ThemeMode m) => switch (m) {
        ThemeMode.light  => 'light',
        ThemeMode.dark   => 'dark',
        ThemeMode.system => 'system',
        // ignore: unreachable_switch_case
        _ => 'system',
      };

  Map<String, dynamic> _dayToJson(PrayerDay d) => {
        'timings': {
          'Fajr':     d.timings.fajr,
          'Sunrise':  d.timings.sunrise,
          'Dhuhr':    d.timings.dhuhr,
          'Asr':      d.timings.asr,
          'Maghrib':  d.timings.maghrib,
          'Isha':     d.timings.isha,
          'Imsak':    d.timings.imsak,
          'Midnight': d.timings.midnight,
        },
        'date': {
          'readable':  d.readableDate,
          'gregorian': {'date': d.gregorianDate},
          'hijri': {
            'date': d.hijri.date,
            'day':  d.hijri.day,
            'month': {'en': d.hijri.monthEn, 'ar': d.hijri.monthAr},
            'year':    d.hijri.year,
            'weekday': {'en': d.hijri.weekday},
          },
        },
      };
}
