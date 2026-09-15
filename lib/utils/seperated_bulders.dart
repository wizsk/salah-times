import 'package:flutter/material.dart';

List<Widget> separatedBuilder({
  required int itemCount,
  required Widget Function(int index) itemBuilder,
  required Widget Function(int index) separatorBuilder,
}) {
  final result = <Widget>[];

  for (int i = 0; i < itemCount; i++) {
    result.add(itemBuilder(i));

    if (i != itemCount - 1) {
      result.add(separatorBuilder(i));
    }
  }

  return result;
}
