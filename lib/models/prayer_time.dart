import 'package:salah_times/models/prayer_day.dart';

// enum NextPrayerKind { prayer, doNotPray }

class NextPrayerInfo {
  const NextPrayerInfo({
    this.next,
    this.curr,
    this.progress,
    this.remaining,
    // this.kind,
  });

  // final NextPrayerKind? kind;
  final PrayerTimingEntry? next;
  final PrayerTimingEntry? curr;
  final double? progress; // 0..1, elapsed fraction between prev and next
  final Duration? remaining;
}

// int _currTimeSec = 1;

/// the way we are getting the times we can't reliably calculate
/// next time for midngiht and ismsak
NextPrayerInfo? computeNextPrayer(PrayerDay p, DateTime now) {
  final en = p.timings.en.where((e) => !e.isNorPrayer).toList();

  // print(en.map((e) => e.name).join("\n"));
  // print('');

  final pl = en.length - 1;

  final nowMin = (now.hour * 60) + now.minute;
  // final int extraMin = _currTimeSec ~/ 60;
  // final nowMin = (50 * 60) + 42 + extraMin;
  // _currTimeSec += cooloff;

  for (var i = pl; i > -1; i--) {
    final curr = en[i];

    final min = curr.toMin;

    if (min < nowMin) {
      // found current prayer
      if (i == pl) {
        return NextPrayerInfo(curr: curr);
      }

      PrayerTimingEntry next;
      if (curr.p == PrayerEntry.fajr) {
        final sun = p.timings.en.firstWhere((e) => e.p == PrayerEntry.sunrise);
        if (sun.toMin > nowMin) {
          next = sun;
        } else {
          next = en[i + 1];
        }
      } else {
        next = en[i + 1];
      }

      final nMin = next.toMin;

      // until next prayer
      final remaining = Duration(minutes: nMin - nowMin, seconds: now.second);

      final diff = (nowMin - min).toDouble() / (nMin - min).toDouble();

      return NextPrayerInfo(
        curr: curr,
        next: next,
        remaining: remaining,
        progress: diff,
      );
    }

    if (i == 0) {
      return NextPrayerInfo(
        next: curr,
        remaining: Duration(minutes: min - nowMin),
        progress: (nowMin).toDouble() / (min).toDouble(),
      );
    }
  }

  return null;
}
