// import 'dart:io';

// import 'package:flutter/services.dart';
// import 'package:salah_times/utils/toast_snack.dart';
// import 'package:salah_times/utils/utils.dart';

// void _showSnakc(String s) => ToastService.show(s);

// class NativeTimezone {
//   static const _channel = MethodChannel('app.timezone/native');

//   static String? _tz;

//   /// Returns the device's IANA timezone identifier (e.g. "Asia/Dhaka").
//   ///
//   /// Supported: Android, Linux.
//   /// Throws [UnsupportedError] on any other platform.
//   static Future<String> getDeviceTimeZoneId() async {
//     if (_tz != null) return _tz!;

//     if (Platform.isAndroid) {
//       final tz = await _getAndroidTimeZoneId();

//       pd('------ got timezone: $tz');
//       _showSnakc('Using timezone: $tz');

//       _tz = tz;
//       return tz;
//     } else if (Platform.isLinux) {
//       final tz = await _getLinuxTimeZoneId();

//       pd('------ got timezone: $tz');
//       _showSnakc('Using timezone: $tz');
//       _tz = tz;
//       return tz;
//     } else {
//       throw UnsupportedError(
//         'getDeviceTimeZoneId() is not implemented for ${Platform.operatingSystem}',
//       );
//     }
//   }

//   static Future<String> _getAndroidTimeZoneId() async {
//     try {
//       final id = await _channel.invokeMethod<String>('getTimeZoneId');
//       return id ?? 'UTC';
//     } on PlatformException {
//       return 'UTC';
//     }
//   }

//   static Future<String> _getLinuxTimeZoneId() async {
//     // Method 1: /etc/timezone (Debian/Ubuntu and derivatives)
//     final tzFile = File('/etc/timezone');
//     if (await tzFile.exists()) {
//       final content = (await tzFile.readAsString()).trim();
//       if (content.isNotEmpty) return content;
//     }

//     // Method 2: /etc/localtime symlink (most distros, incl. Arch, Fedora)
//     final localtime = Link('/etc/localtime');
//     if (await localtime.exists()) {
//       final target = await localtime.target();
//       // target looks like /usr/share/zoneinfo/Asia/Dhaka
//       final marker = 'zoneinfo/';
//       final idx = target.indexOf(marker);
//       if (idx != -1) {
//         return target.substring(idx + marker.length);
//       }
//     }

//     // Method 3: TZ environment variable
//     final tzEnv = Platform.environment['TZ'];
//     if (tzEnv != null && tzEnv.isNotEmpty) return tzEnv;

//     return 'UTC';
//   }
// }
