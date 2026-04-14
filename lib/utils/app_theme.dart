// utils/app_theme.dart
// Dark GNSS diagnostic theme — inspired by professional tools like GPSTest.

import 'package:flutter/material.dart';

class AppTheme {
  // --- Core palette ---
  static const Color background = Color(0xFF080C10);
  static const Color surface = Color(0xFF0D1520);
  static const Color surfaceElevated = Color(0xFF121D2C);
  static const Color surfaceHighlight = Color(0xFF1A2840);
  static const Color border = Color(0xFF1E3050);

  // --- Accent colors ---
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentGreen = Color(0xFF00FF9D);
  static const Color accentAmber = Color(0xFFFFB700);
  static const Color accentRed = Color(0xFFFF3D5A);
  static const Color accentPurple = Color(0xFF9B6DFF);

  // --- Text colors ---
  static const Color textPrimary = Color(0xFFE8F4FF);
  static const Color textSecondary = Color(0xFF7A9EC0);
  static const Color textMuted = Color(0xFF3D5A78);

  // --- Signal strength bar colors (poor → excellent) ---
  static const List<Color> signalColors = [
    Color(0xFF3D5A78), // No signal
    Color(0xFFFF3D5A), // Poor
    Color(0xFFFFB700), // Fair
    Color(0xFF00D4FF), // Good
    Color(0xFF00FF9D), // Excellent
  ];

  // --- Constellation badge colors ---
  static const Map<String, Color> constellationColors = {
    'GPS': Color(0xFF00D4FF),
    'GLO': Color(0xFFFF6B35),
    'GAL': Color(0xFF9B6DFF),
    'BDS': Color(0xFFFFB700),
    'QZSS': Color(0xFF00FF9D),
    'SBAS': Color(0xFF7A9EC0),
    'UNK': Color(0xFF3D5A78),
  };

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accentCyan,
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        secondary: accentGreen,
        surface: surface,
        error: accentRed,
      ),
      cardColor: surface,
      dividerColor: border,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'monospace',
          color: textPrimary,
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
        bodySmall: TextStyle(
          color: textMuted,
          fontFamily: 'monospace',
          fontSize: 11,
        ),
        labelSmall: TextStyle(
          color: textMuted,
          fontFamily: 'monospace',
          fontSize: 10,
          letterSpacing: 1.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: accentCyan),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
          fontFamily: 'monospace',
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accentCyan,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentCyan,
        foregroundColor: background,
      ),
    );
  }
}
