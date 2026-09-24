extension BanglaNumber on int {
  static final _r = RegExp(r'\d');
  static const _d = '০১২৩৪৫৬৭৮৯';

  String get bn {
    return toString().replaceAllMapped(_r, (m) => _d[int.parse(m.group(0)!)]);
  }
}
