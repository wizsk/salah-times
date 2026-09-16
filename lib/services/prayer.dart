import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:salah_times/models/prayer_day.dart';
import 'package:salah_times/services/app_conf.dart';
import 'package:salah_times/services/city_service.dart';
import 'package:salah_times/utils/fnv_1a.dart';
import 'package:salah_times/utils/utils.dart';

class PDSVal {
  final List<PrayerDay>? prayers;
  final InitState _state;

  const PDSVal(this._state, [this.prayers]);

  bool get hasVal => _state.isInited;
  bool get noVal => _state.isNotInited || _state.isIniting;
  bool get _initing => _state.isIniting;
}

abstract final class PDS {
  /// month -> prayer data
  static final Map<(int, int), PDSVal> _datas = {};

  static void clear() {
    _datas.clear();
    // _u.clear();
    // _c = 0;
  }

  static PDSVal? _gd(int month, int year) => _datas[(month, year)];
  static void _pd(int month, int year, PDSVal v) => _datas[(month, year)] = v;

  static const _noVal = PDSVal(InitState.not);
  static const emtpy = _noVal;

  static PDSVal getData(
    int month,
    int year,
    VoidCallback after,
    void Function(String) onErr,
  ) {
    final val = _gd(month, year);

    if (val == null || val.noVal) {
      if (val?._initing == true) return _noVal;

      _pd(month, year, PDSVal(InitState.initing));
      _getData(month, year, after, onErr);
      return _noVal;
    }

    return val;
  }

  // static final Set<(int, int)> _u = {};
  // static int _c = 0;
  static Future<void> _getData(
    int month,
    int year,
    VoidCallback after,
    void Function(String) onErr,
  ) async {
    // _c++;
    // _u.add((month, year));
    // print('-------------- : --- unique: ${_u.length} but called: $_c');
    try {
      final data = await Prayer.fetchMonthIfNeeded(year, month);
      _pd(month, year, PDSVal(InitState.done, data));
      after();
    } catch (e) {
      onErr(e.toString());
    }
  }
}

abstract final class Prayer {
  static const String _authority = 'api.aladhan.com';
  static const String _endPoint = '/v1/calendar';
  static int get _school => AppConf.schoolVal;
  static int get _method => AppConf.methodVal;

  static const String _tz = 'UTC';

  // static Future<String> get _tz async {
  //   if (_curTz != null) return _curTz!;

  //   final tz = await NativeTimezone.getDeviceTimeZoneId();
  //   _curTz = tz;
  //   return tz;
  // }

  static Future<(List<PrayerDay>, String)> _fetchMonthlyPrayers({
    required PrayerLocation loc,
    required int year,
    required int month,
  }) async {
    // final uri = Uri.parse(
    //   '$_baseUrl/$year/$month?method=$_method&school=$_school&latitude=$latitude&longitude=$longitude',
    // );

    final uri = Uri.https(_authority, '$_endPoint/$year/$month', {
      'method': _method.toString(),
      'school': _school.toString(),
      'latitude': loc.latStr,
      'longitude': loc.lngStr,
      'timezonestring': _tz,
    });

    pd('Fetching data: ${uri.toString()}');

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = response.body;
      final decoded = json.decode(data);
      if (decoded['code'] == 200 && decoded['data'] is List) {
        final js = (decoded['data'] as List).indexed
            .map(
              (item) => PrayerDay.fromJson(item.$2, year, month, item.$1 + 1),
            )
            .toList();

        final jsonData = json.encode(decoded['data']);

        return (js, jsonData);
      } else {
        throw Exception('Unexpected API response: ${decoded['status']}');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  static Future<File> _getCacheFile(
    PrayerLocation loc,
    int year,
    int month,
  ) async {
    final dir = Platform.isLinux
        ? await getApplicationCacheDirectory()
        : await getApplicationDocumentsDirectory();

    final tz = _tz;
    final key =
        'v2|school=$_school|method=$_method|'
        'lat=${loc.latStr}|lng=${loc.latStr}|'
        'date=$year-$month|tz=$tz';

    final hash = fnv1aHash(key).toRadixString(16).padLeft(8, '0');
    final newFileName = 'salah_times_$hash.json';

    final filePath = path.join(dir.path, newFileName);

    return File(filePath);
  }

  static Future<void> fetchNextMonthIfNeeded(int year, int month) async {
    if (month == 12) {
      year++;
      month = 1;
    }

    try {
      final f = await _getCacheFile(AppConf.loc, year, month);
      if (await f.exists()) {
        pd("Alrady have fetchend next months prayer data ($month/$year)");
        return;
      }

      await fetchMonthIfNeeded(year, month);
      pd("Fetchend next months prayer data ($month/$year)");
    } catch (e) {
      pd("Could not fetch next month($month/$year): $e");
    }
  }

  static Future<List<PrayerDay>> fetchMonthIfNeeded(int year, int month) async {
    final cached = await _readCacheFile(year, month);
    if (cached != null) {
      pd('Read salah time from cache!');
      return cached;
    }

    try {
      final (days, data) = await _fetchMonthlyPrayers(
        loc: AppConf.loc,
        year: year,
        month: month,
      );
      await _writeCacheFile(year, month, data);
      return days;
    } catch (e, st) {
      pd('While getting res: $e');
      pd(st.toString());
      throw Exception('Could not Get resutls');
    }
  }

  static Future<List<PrayerDay>?> _readCacheFile(int year, int month) async {
    try {
      final file = await _getCacheFile(AppConf.loc, year, month);
      pd('trying to read from: $file');

      if (!await file.exists()) return null;
      final raw = await file.readAsString();

      return (json.decode(raw) as List).indexed
          .map(
            (e) => PrayerDay.fromJson(
              e.$2 as Map<String, dynamic>,
              year,
              month,
              e.$1 + 1,
            ),
          )
          .toList();
    } catch (e) {
      pd('while reading cache: $e');
      return null;
    }
  }

  static Future<void> _writeCacheFile(int year, int month, String data) async {
    try {
      final file = await _getCacheFile(AppConf.loc, year, month);
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(data, flush: true);
      await tmp.rename(file.path);
    } catch (_) {}
  }

  // static Future<void> deleteCacheFile(int year, int month) async {
  //   try {
  //     final file = await _getCacheFile(AppConf.loc, year, month);
  //     if (await file.exists()) await file.delete();
  //   } catch (_) {}
  // }
}
