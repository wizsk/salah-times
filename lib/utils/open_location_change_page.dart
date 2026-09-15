import 'package:flutter/material.dart';
import 'package:salah_times/pages/get_location.dart';

Future<void> showLocationProvidorScreen(
  BuildContext context, [
  bool popup = true,
]) async {
  final w = LocationPickerScreen(isPopup: popup);

  if (popup) {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => w));
  } else {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => w));
  }
}
