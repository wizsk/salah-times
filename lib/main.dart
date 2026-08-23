import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/prayer_provider.dart';
import 'screens/home_screen.dart';
import 'screens/location_setup_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => PrayerProvider()..init(),
      child: const PrayerTimesApp(),
    ),
  );
}

class PrayerTimesApp extends StatelessWidget {
  const PrayerTimesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerProvider>();
    return MaterialApp(
      title: 'Prayer Times',
      debugShowCheckedModeBanner: false,
      themeMode: provider.themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: provider.hasLocation
          ? const HomeScreen()
          : const LocationSetupScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A3A6B),
        brightness: brightness,
      ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF0F4FA),
      fontFamily: 'Roboto',
    );
  }
}
