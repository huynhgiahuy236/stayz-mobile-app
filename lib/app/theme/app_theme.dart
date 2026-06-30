import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0E7C86),
      primary: const Color(0xFF0E7C86),
      secondary: const Color(0xFFFFB703),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF7F9FA),
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }
}
