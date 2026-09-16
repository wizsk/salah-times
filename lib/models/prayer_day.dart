import 'package:flutter/material.dart';
import 'package:salah_times/services/app_conf.dart';
import 'package:salah_times/utils/toast_snack.dart';

class PrayerNTI {
  final String name;
  final IconData icon;
  final String time;
  final bool notPrayer;

  const PrayerNTI(this.name, this.icon, this.time, {this.notPrayer = false});
}

abstract final class _PN {
  static const _PrayerName fajr = _PrayerName(en: 'Fajr', bn: 'ফজর');
  static const _PrayerName sunrise = _PrayerName(
    en: 'Sunrise',
    bn: 'সূর্যোদয়',
  );
  static const _PrayerName duhur = _PrayerName(en: 'Dhuhr', bn: 'যুহর');
  static const _PrayerName asr = _PrayerName(en: 'Asr', bn: 'আছর');
  static const _PrayerName magrib = _PrayerName(en: 'Maghrib', bn: 'মাগরিব');
  static const _PrayerName isa = _PrayerName(en: 'Isha', bn: 'এশা');
  static const _PrayerName imsak = _PrayerName(
    en: 'Imsak',
    bn: 'ইমছাক',
    enInfo: 'Imsak literally means to hold back. Here, it refers to the time when you should stop eating and drinking before fasting.',
    bnInfo: 'ইমছাক অর্থ বিরত থাকা। এখানে এটি রোজা শুরু করার আগে খাওয়া ও পান করা বন্ধ করার সময়কে বোঝায়।',
  );
  static const _PrayerName midnight = _PrayerName(
    en: 'Midnight',
    bn: 'মধ্যরাত',
  );

  static const IconData fjarIcon = Icons.bedtime_rounded;
  static const IconData sunriseIcon = Icons.wb_twilight_rounded;
  static const IconData duhurIcon = Icons.light_mode_rounded;
  static const IconData asrIcon = Icons.wb_cloudy_rounded;
  static const IconData magribIcon = Icons.flare_rounded;
  static const IconData isaIcon = Icons.nightlight_rounded;
  static const IconData midnightIcon = Icons.dark_mode_rounded;
  static const IconData imsakIcon = Icons.alarm_rounded;
}

class PrayerHourName {
  final int hour;
  final int min;
  final String name;

  const PrayerHourName(this.hour, this.min, this.name);
}

class _PrayerName {
  final String en;
  final String bn;
  final String? enInfo;
  final String? bnInfo;

  const _PrayerName({
    required this.en,
    required this.bn,
    this.bnInfo,
    this.enInfo,
  });
}

enum L {
  en('English'),
  bn('Bangla', 'বাংলা');

  const L(this.name, [this.nameLn]);
  final String name;
  final String? nameLn;

  static L _curr = bn;
  static L get curr => _curr;

  static set currNoSave(L lang) {
    _curr = lang;
  }

  static set curr(L lang) {
    if (_curr == lang) return;
    _curr = lang;

    AppConf.savePrayerNameLang(lang);

    ToastService.show('Prayer names language: ${lang.name}');
  }
}

enum PrayerEntry {
  fajr(_PN.fajr, _PN.fjarIcon),
  sunrise(_PN.sunrise, _PN.sunriseIcon, isNorPrayer: true),
  dhuhr(_PN.duhur, _PN.duhurIcon),
  asr(_PN.asr, _PN.asrIcon),
  maghrib(_PN.magrib, _PN.magribIcon),
  isha(_PN.isa, _PN.isaIcon),
  midnight(_PN.midnight, _PN.midnightIcon, isNorPrayer: true, extra: true),
  imsak(_PN.imsak, _PN.imsakIcon, isNorPrayer: true, extra: true);

  const PrayerEntry(
    this._names,
    this.icon, {
    this.isNorPrayer = false,
    this.extra = false,
  });

  final _PrayerName _names;
  final IconData icon;
  final bool isNorPrayer;
  final bool extra;

  String get name {
    // assert(false);
    return switch (L.curr) {
      L.en => _names.en,
      L.bn => _names.bn,
    };
  }

  String get key => _names.en;

  String? get info {
    return switch (L.curr) {
      L.en => _names.enInfo,
      L.bn => _names.bnInfo,
    };
  }

  static const prayerTimes = [
    fajr,
    sunrise,
    dhuhr,
    asr,
    maghrib,
    isha,
    midnight,
    imsak,
  ];
}

class PrayerTimingEntry {
  final PrayerEntry p;
  final DateTime time;

  PrayerTimingEntry(this.p, this.time);

  String get name => p.name;
  IconData get icon => p.icon;
  bool get isNorPrayer => p.isNorPrayer;
  bool get extra => p.extra;
  String? get info => p.info;

  int? _min;

  int get toMin {
    return _min ??= (time.hour * 60) + time.minute;
  }

  (String, String)? _hMamPm;
  (String, String)? _hm24h;

  (String, String) fmtHMAMPM(bool use24h) {
    if (use24h) {
      return _hm24h ??= (
        '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
        '',
      );
    }

    if (_hMamPm != null) return _hMamPm!;

    var h = time.hour;
    final ampm = h >= 12 ? 'PM' : 'AM';
    if (h > 12) h -= 12;
    if (h == 0) h = 12;

    final m = time.minute.toString().padLeft(2, '0');
    final r = ('$h:$m', ampm);

    _hMamPm = r;
    return r;
  }
}

class PrayerTimings {
  final List<PrayerTimingEntry> en;

  PrayerTimings(this.en);

  factory PrayerTimings.fromJson(
    Map<String, dynamic> json,
    int year,
    int month,
    int day,
  ) {
    DateTime toTime(String s) {
      final time = s.split(" ").first;
      final sp = time.split(":");
      final hour = int.parse(sp[0]);
      final minute = int.parse(sp[1]);

      return DateTime.utc(year, month, day, hour, minute).toLocal();
    }

    final en = PrayerEntry.prayerTimes.map((p) {
      return PrayerTimingEntry(p, toTime(json[p.key]));
    }).toList();

    return PrayerTimings(en);
  }
}

class HijriDate {
  final String date;
  final String day;
  final String monthEn;
  final String monthAr;
  final String year;
  final String weekday;

  HijriDate({
    required this.date,
    required this.day,
    required this.monthEn,
    required this.monthAr,
    required this.year,
    required this.weekday,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      monthEn: json['month']?['en'] ?? '',
      monthAr: json['month']?['ar'] ?? '',
      year: json['year'] ?? '',
      weekday: json['weekday']?['ar'] ?? '',
    );
  }
}

class PrayerDay {
  final PrayerTimings timings;
  final String readableDate;
  final String gregorianDate; // DD-MM-YYYY
  final HijriDate hijri;

  PrayerDay({
    required this.timings,
    required this.readableDate,
    required this.gregorianDate,
    required this.hijri,
  });

  factory PrayerDay.fromJson(
    Map<String, dynamic> json,
    int year,
    int month,
    int day,
  ) {
    return PrayerDay(
      timings: PrayerTimings.fromJson(json['timings'], year, month, day),
      readableDate: json['date']?['readable'] ?? '',
      gregorianDate: json['date']?['gregorian']?['date'] ?? '',
      hijri: HijriDate.fromJson(json['date']?['hijri'] ?? {}),
    );
  }
}
