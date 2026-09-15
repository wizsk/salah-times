import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void pd(dynamic p) {
  if (kDebugMode) debugPrint(p);
}

const scrollPadding = EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 140);

@pragma("vm:prefer-inline")
EdgeInsets scrollPaddingBottmSheet(
  BuildContext context, {
  double sides = 14.00,
}) => scrollPadding.copyWith(
  right: sides,
  left: sides,
  bottom: MediaQuery.of(context).padding.bottom + 12,
);
