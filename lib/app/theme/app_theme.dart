import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  /// Ti le khung anh dung chung cho MOI the khach san (rong : cao = 16 : 10).
  /// Dung AspectRatio thay cho chieu cao cung de anh khong bi cat cut thanh
  /// dai mong o the rong het man hinh — nguon goc cua hien tuong "bi be".
  static const double cardImageAspectRatio = 16 / 10;

  static const cream = Color(0xFFEAF7FF);
  static const surface = Color(0xFFF7FBFF);
  static const ink = Color(0xFF102A43);
  static const primary = Color(0xFF1D8BD1);
  static const primaryDark = Color(0xFF0A4E83);
  static const primarySoft = Color(0xFFDDEEFF);
  static const accent = primary;
  static const accentDark = primaryDark;
  static const teal = Color(0xFF2378C9);
  static const gold = Color(0xFFE9A92F);
  static const line = Color(0xFFC6E4F7);
  static const muted = Color(0xFF5E7F98);
  static const neutral200 = line;
  static const neutral500 = muted;
  static const neutral800 = Color(0xFF12314D);
  static const success = Color(0xFF17875A);
  static const danger = Color(0xFFD34B3F);

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: ink.withValues(alpha: 0.07),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      primary: accent,
      secondary: neutral800,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: surface,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDark,
          side: const BorderSide(color: line),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
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
