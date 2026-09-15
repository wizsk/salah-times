import 'package:flutter/material.dart';
import 'package:salah_times/main.dart';
import 'package:salah_times/models/prayer_times_modifiers.dart';
import 'package:salah_times/services/prayer.dart';
import 'package:salah_times/utils/toast_snack.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerLocation {
  static const int accuracy = 3;

  final double lat;
  final double lng;
  final String city;

  final String latStr;
  final String lngStr;

  const PrayerLocation._(
    this.lat,
    this.lng,
    this.city,
    this.latStr,
    this.lngStr,
  );

  factory PrayerLocation(double lat, double lng, String city) {
    if (lat < -90 || lat > 90) {
      throw ArgumentError.value(lat, 'lat', 'Must be between -90 and 90');
    }

    if (lng < -180 || lng > 180) {
      throw ArgumentError.value(lng, 'lng', 'Must be between -180 and 180');
    }

    final latStr = lat.toStringAsFixed(accuracy);
    final lngStr = lng.toStringAsFixed(accuracy);

    return PrayerLocation._(
      double.parse(latStr),
      double.parse(lngStr),
      city,
      latStr,
      lngStr,
    );
  }

  PrayerLocation copyWith({double? lat, double? lng, String? city}) =>
      PrayerLocation(lat ?? this.lat, lng ?? this.lng, city ?? this.city);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerLocation &&
          lat == other.lat &&
          lng == other.lng &&
          city == other.city;

  @override
  int get hashCode => Object.hash(lat, lng, city);
}

abstract final class AppConf {
  static const _latKey = 'lat';
  static const _lngKey = 'lng';
  static const _cityNameKey = 'cityName';
  static const _themeKey = 'theme';
  static const _methodKey = 'method';
  static const _schoolKey = 'school';

  static ThemeMode _theme = ThemeMode.system;
  static ThemeMode get theme => _theme;

  static PrayerSchool _school = PrayerSchool.hanafi;
  static int get schoolVal => _school.val;
  static PrayerSchool get school => _school;

  static set school(PrayerSchool s) {
    if (s == _school) return;

    _school = s;
    PDS.clear();
    _saveSchool();
  }

  static PrayerMethod _method = PrayerMethod.karachi;

  static set method(PrayerMethod m) {
    if (m == _method) return;

    _method = m;
    PDS.clear();
    _saveMethod();
  }

  static int get methodVal => _method.val;
  static PrayerMethod get method => _method;

  static set theme(ThemeMode t) {
    if (t == _theme) return;
    _theme = t;
    notifier.notify();

    _saveTheme();
  }

  static Future<void> _saveTheme() async {
    final sp = SharedPreferencesAsync();
    await sp.setString(_themeKey, _theme.name);
    ToastService.show('Theme saved: ${_theme.name}');
  }

  static Future<void> _saveMethod() async {
    final sp = SharedPreferencesAsync();
    await sp.setInt(_methodKey, _method.val);
    ToastService.show('Method saved: ${_method.name}');
  }

  static Future<void> _saveSchool() async {
    final sp = SharedPreferencesAsync();
    await sp.setInt(_schoolKey, _school.val);
    ToastService.show('School saved: ${_school.name}');
  }

  static PrayerLocation? _loc;
  static PrayerLocation? get locTry => _loc;
  static PrayerLocation get loc => _loc!;
  static bool get hasLoc => _loc != null;

  static Future<void> load() async {
    final sp = SharedPreferencesAsync();

    final cth = await sp.getString(_themeKey);
    _theme = ThemeMode.values.firstWhere(
      (v) => v.name == cth,
      orElse: () => ThemeMode.system,
    );

    if (_theme != ThemeMode.system) notifier.notify();

    final lat = await sp.getDouble(_latKey);
    final lng = await sp.getDouble(_lngKey);
    final cityName = await sp.getString(_cityNameKey);

    if (lat != null && lng != null && cityName != null) {
      _loc = PrayerLocation(lat, lng, cityName);
    }
  }

  static Future<void> saveLoc(PrayerLocation p) async {
    if (p == _loc) return;
    _loc = p;

    final sp = SharedPreferencesAsync();
    await sp.setDouble(_latKey, p.lat);
    await sp.setDouble(_lngKey, p.lng);
    await sp.setString(_cityNameKey, p.city);

    ToastService.show('New location saved: ${p.city}');
  }
}
