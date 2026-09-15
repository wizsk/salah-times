/// Lightweight, offline Gregorian → Hijri conversion.
///
/// Uses the tabular ("Kuwaiti algorithm") civil calendar, which is a pure
/// arithmetic approximation — no network, no package dependency. It can
/// differ by a day from local moon-sighting announcements or the precise
/// Umm al-Qura calendar. For a religious-accuracy-critical use case, swap
/// this for a verified source (e.g. a bundled Umm al-Qura lookup table).
class HijriDateService {
  const HijriDateService(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  static const List<String> _monthsEn = [
    'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani",
    'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', "Sha'ban",
    'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah',
  ];

  static const List<String> _monthsAr = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  String get monthNameEn => _monthsEn[month - 1];
  String get monthNameAr => _monthsAr[month - 1];

  /// e.g. "١٠ ربيع الأول ١٤٤٨ هـ" — pass [useArabicDigits] to render the
  /// day/year with Arabic-indic numerals instead of Western digits.
  String toArabicString({bool useArabicDigits = false}) {
    final d = useArabicDigits ? _toArabicDigits(day) : '$day';
    final y = useArabicDigits ? _toArabicDigits(year) : '$year';
    return '$d $monthNameAr $y هـ';
  }

  String toEnglishString() => '$day $monthNameEn $year AH';

  static String _toArabicDigits(int n) {
    const western = '0123456789';
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    return '$n'.split('').map((c) {
      final i = western.indexOf(c);
      return i == -1 ? c : arabic[i];
    }).join();
  }

  factory HijriDateService.fromGregorian(DateTime date) {
    final jd = _gregorianToJulianDay(date);
    return _julianToHijri(jd);
  }

  static int _gregorianToJulianDay(DateTime date) {
    final y = date.year, m = date.month, d = date.day;
    final a = (14 - m) ~/ 12;
    final y2 = y + 4800 - a;
    final m2 = m + 12 * a - 3;
    return d +
        ((153 * m2 + 2) ~/ 5) +
        365 * y2 +
        (y2 ~/ 4) -
        (y2 ~/ 100) +
        (y2 ~/ 400) -
        32045;
  }

  static HijriDateService _julianToHijri(int jd) {
    var l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
        (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    final month = (24 * l) ~/ 709;
    final day = l - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;
    return HijriDateService(year, month, day);
  }
}
