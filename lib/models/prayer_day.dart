class PrayerTimings {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String imsak;
  final String midnight;

  PrayerTimings({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.midnight,
  });

  factory PrayerTimings.fromJson(Map<String, dynamic> json) {
    String clean(String raw) => raw.split(' ').first; // strip timezone offset
    return PrayerTimings(
      fajr: clean(json['Fajr'] ?? ''),
      sunrise: clean(json['Sunrise'] ?? ''),
      dhuhr: clean(json['Dhuhr'] ?? ''),
      asr: clean(json['Asr'] ?? ''),
      maghrib: clean(json['Maghrib'] ?? ''),
      isha: clean(json['Isha'] ?? ''),
      imsak: clean(json['Imsak'] ?? ''),
      midnight: clean(json['Midnight'] ?? ''),
    );
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
      weekday: json['weekday']?['en'] ?? '',
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

  factory PrayerDay.fromJson(Map<String, dynamic> json) {
    return PrayerDay(
      timings: PrayerTimings.fromJson(json['timings']),
      readableDate: json['date']?['readable'] ?? '',
      gregorianDate: json['date']?['gregorian']?['date'] ?? '',
      hijri: HijriDate.fromJson(json['date']?['hijri'] ?? {}),
    );
  }
}
