import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

String tzName([DateTime? d]) => (d ?? DateTime.now()).timeZoneName;

void pd(dynamic p) {
  if (kDebugMode) debugPrint(p);
}

const scrollPadding = EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 140);

@pragma("vm:prefer-inline")
EdgeInsets scrollPaddingBottmSheet(
  BuildContext context, {
  double sides = 14.00,
  double bottomExtra = 00.00,
}) => scrollPadding.copyWith(
  right: sides,
  left: sides,
  bottom: MediaQuery.of(context).padding.bottom + 12 + bottomExtra,
);

@pragma("vm:prefer-inline")
void postFrame(VoidCallback f) {
  WidgetsBinding.instance.addPostFrameCallback((_) => f());
}

extension DateTimeExt on DateTime {
  DateTime incrementDay([int days = 1]) {
    return DateTime(
      year,
      month,
      day + days,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  String formatTime(bool use24h) {
    final local = toLocal();
    // final second = local.second.toString().padLeft(2, '0');

    // final day = ' ${_weekday(local.day)} • ${_weekdayAr(local.day)}';

    if (use24h) {
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');

      // return '$hour:$minute:$second';
      return '$hour:$minute';
    } else {
      int hour = local.hour;
      final minute = local.minute.toString().padLeft(2, '0');

      final isPm = hour >= 12;
      final period = isPm ? 'PM' : 'AM';

      hour = hour % 12;
      if (hour == 0) hour = 12;

      final hourStr = hour.toString().padLeft(2, '0');

      // return '$hourStr:$minute:$second $period';
      return '$hourStr:$minute $period';
    }
  }

  // int get totalMinutes {
  //   return ((hour * 60) + minute);
  // }
}

extension TimeOfDayExt on TimeOfDay {
  static const _dayMin = 24 * 60;

  int get totalMinutesAfterIsha {
    return _dayMin - ((hour * 60) + minute);
  }

  int get inMinutes {
    return ((hour * 60) + minute);
  }
}
