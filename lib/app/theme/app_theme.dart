import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const cream = Color(0xFFF5F0E8);
  static const ink = Color(0xFF1A1612);
  static const accent = Color(0xFF8B3A3A);
  static const accentDark = Color(0xFF5C2020);
  static const neutral200 = Color(0xFFD4C9B5);
  static const neutral500 = Color(0xFF7A6E60);
  static const neutral800 = Color(0xFF2C2820);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      primary: accent,
      secondary: neutral800,
      surface: cream,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: cream,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: cream,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Noto Serif JP',
          fontSize: 48,
          height: 1.1,
          color: ink,
          fontWeight: FontWeight.w300,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Noto Serif JP',
          fontSize: 34,
          height: 1.15,
          color: ink,
          fontWeight: FontWeight.w300,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          height: 1.25,
          color: ink,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          height: 1.45,
          color: neutral500,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: neutral500,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontSize: 18,
          color: cream,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
