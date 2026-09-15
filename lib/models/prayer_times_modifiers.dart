import 'package:salah_times/services/app_conf.dart';

abstract class PrayerMods {
  String get name;
  int get val;
}

enum PrayerSchool implements PrayerMods {
  shafi(0, 'Shafi'),
  hanafi(1, 'Hanafi');

  const PrayerSchool(this.val, this.name);

  @override
  final String name;

  @override
  final int val;

  static const def = hanafi;
  static bool get usingDef => AppConf.school == def;
}

enum PrayerMethod implements PrayerMods {
  jafari(0, 'Jafari / Shia Ithna-Ashari'),
  karachi(1, 'University of Islamic Sciences, Karachi'),
  isna(2, 'Islamic Society of North America'),
  mwl(3, 'Muslim World League'),
  makkah(4, 'Umm Al-Qura University, Makkah'),
  egypt(5, 'Egyptian General Authority of Survey'),
  tehran(7, 'Institute of Geophysics, University of Tehran'),
  gulf(8, 'Gulf Region'),
  kuwait(9, 'Kuwait'),
  qatar(10, 'Qatar'),
  singapore(11, 'Majlis Ugama Islam Singapura, Singapore'),
  france(12, 'Union Organization islamic de France'),
  turkey(13, 'Diyanet İşleri Başkanlığı, Turkey'),
  russia(14, 'Spiritual Administration of Muslims of Russia'),
  moonsighting(15, 'Moonsighting Committee Worldwide'),
  dubai(16, 'Dubai (experimental)'),
  malaysia(17, 'Jabatan Kemajuan Islam Malaysia (JAKIM)'),
  tunisia(18, 'Tunisia'),
  algeria(19, 'Algeria'),
  indonesia(20, 'KEMENAG - Kementerian Agama Republik Indonesia'),
  morocco(21, 'Morocco'),
  lisbon(22, 'Comunidade Islamica de Lisboa'),
  jordan(23, 'Ministry of Awqaf, Islamic Affairs and Holy Places, Jordan');

  const PrayerMethod(this.val, this.name);

  @override
  final int val;

  @override
  final String name;

  static const def = karachi;
  static bool get usingDef => AppConf.method == def;
}
