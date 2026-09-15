import 'package:flutter/material.dart';
import 'package:salah_times/pages/salah_times_page.dart';
import 'package:salah_times/services/app_conf.dart';
import 'package:salah_times/theme/app_theme.dart';
import 'package:salah_times/utils/toast_snack.dart';

void main() {
  runApp(const SalahTimesApp());
}

final notifier = AppNotifier();

class AppNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

/// Standalone preview app. In your real project, drop `SalahTimesPage` into
/// your existing MaterialApp/routing and lift `_themeMode` up to wherever
/// you already manage theme state.
class SalahTimesApp extends StatefulWidget {
  const SalahTimesApp({super.key});

  @override
  State<SalahTimesApp> createState() => _SalahTimesAppState();
}

class _SalahTimesAppState extends State<SalahTimesApp> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _) => MaterialApp(
        scaffoldMessengerKey: ToastService.messengerKey,
        title: 'Salah Times',
        debugShowCheckedModeBanner: false,
        themeMode: AppConf.theme,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const SalahTimesPage(),
      ),
    );
  }
}
