import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTheme {
  const AppTextTheme._();

  static TextTheme buildTextTheme(Color mainColor, Color secondaryColor) {
    return GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          height: 1.1,
          color: mainColor,
          fontWeight: FontWeight.w300,
        ),
        headlineMedium: TextStyle(
          fontSize: 34,
          height: 1.15,
          color: mainColor,
          fontWeight: FontWeight.w300,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          height: 1.25,
          color: mainColor,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          height: 1.45,
          color: secondaryColor,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: secondaryColor,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontSize: 18,
          color: mainColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
