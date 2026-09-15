import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class ToastService {
  static const MethodChannel _channel = MethodChannel('app/toast');

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static Future<void> show(
    String message, {
    bool shortDuration = true,
    Duration snackDuration = const Duration(seconds: 4),
  }) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('showToast', {
          'message': message,
          'short': shortDuration,
        });
      } on PlatformException {
        _showSnackbar(message, snackDuration);
      }
    } else {
      _showSnackbar(message, snackDuration);
    }
  }

  static void _showSnackbar(String message, Duration duration) {
    final messenger = messengerKey.currentState;
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
  }
}
