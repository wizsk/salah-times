import 'package:flutter/material.dart';

/// Material 3 theme for the Salah Times page.
///
/// Font families are referenced by name and expected to be bundled as local
/// assets (see the `fonts:` section in pubspec.yaml) rather than fetched at
/// runtime, so the page stays fully offline — matching the rest of the app.
class AppTheme {
  AppTheme._();

  static const String displayFont = 'SpaceGrotesk';
  static const String bodyFont = 'PlusJakartaSans';
  // static const String arabicFont = 'NotoSansArabic'; //'NotoNaskhArabic';

  /// Shorthand for Arabic-script text (prayer names, Hijri date, etc).
  // static TextStyle arabic({
  //   double fontSize = 15,
  //   FontWeight fontWeight = FontWeight.w400,
  //   Color? color,
  // }) {
  //   return TextStyle(
  //     fontFamily: arabicFont,
  //     fontSize: fontSize,
  //     fontWeight: fontWeight,
  //     color: color,
  //     height: 1.4,
  //   );
  // }

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF146C5B),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFA6F2DD),
    onPrimaryContainer: Color(0xFF00201A),
    secondary: Color(0xFF4C6359),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFCEE9DC),
    onSecondaryContainer: Color(0xFF092018),
    tertiary: Color(0xFF8B6D19),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFE08C),
    onTertiaryContainer: Color(0xFF2B1F00),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF5FBF6),
    onSurface: Color(0xFF171D1A),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFEFF5F0),
    surfaceContainer: Color(0xFFE9F0EA),
    surfaceContainerHigh: Color(0xFFE3EBE4),
    surfaceContainerHighest: Color(0xFFDEE4DE),
    onSurfaceVariant: Color(0xFF3F4945),
    outline: Color(0xFF6F7975),
    outlineVariant: Color(0xFFBFC9C4),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2B322E),
    onInverseSurface: Color(0xFFECF2ED),
    inversePrimary: Color(0xFF8AD5C0),
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF8AD5C0),
    onPrimary: Color(0xFF00382E),
    primaryContainer: Color(0xFF005142),
    onPrimaryContainer: Color(0xFFA6F2DD),
    secondary: Color(0xFFB3CCC1),
    onSecondary: Color(0xFF1E352D),
    secondaryContainer: Color(0xFF354B42),
    onSecondaryContainer: Color(0xFFCEE9DC),
    tertiary: Color(0xFFE4C36D),
    onTertiary: Color(0xFF3B2E00),
    tertiaryContainer: Color(0xFF6D5300),
    onTertiaryContainer: Color(0xFFFFE08C),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF101411),
    onSurface: Color(0xFFE1E3DF),
    surfaceContainerLowest: Color(0xFF0B0F0C),
    surfaceContainerLow: Color(0xFF181D19),
    surfaceContainer: Color(0xFF1C211D),
    surfaceContainerHigh: Color(0xFF262B27),
    surfaceContainerHighest: Color(0xFF313632),
    onSurfaceVariant: Color(0xFFBFC9C4),
    outline: Color(0xFF899490),
    outlineVariant: Color(0xFF3F4945),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE1E3DF),
    onInverseSurface: Color(0xFF2B322E),
    inversePrimary: Color(0xFF146C5B),
  );

  static ThemeData light() => _build(_lightScheme);
  static ThemeData dark() => _build(_darkScheme);

  static ThemeData _build(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: bodyFont,
      scaffoldBackgroundColor: scheme.surface,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.onSurface,
        contentTextStyle: TextStyle(
          fontFamily: bodyFont,
          color: scheme.surface,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.secondaryContainer,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.secondaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onSecondaryContainer),
      ),
    );
  }
}
