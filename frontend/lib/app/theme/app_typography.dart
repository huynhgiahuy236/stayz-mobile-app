import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  const AppTypography._();

  static const double fontDisplay = 40.0;
  static const double fontHeadline1 = 32.0;
  static const double fontHeadline2 = 28.0;
  static const double fontHeadline3 = 24.0;
  static const double fontTitle = 20.0;
  static const double fontSubtitle = 18.0;
  static const double fontBody = 16.0;
  static const double fontBodySmall = 14.0;
  static const double fontCaption = 12.0;
  static const double fontOverline = 10.0;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static TextTheme buildTextTheme(Color mainColor, Color secondaryColor) {
    return GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: fontDisplay,
          height: 1.10,
          color: mainColor,
          fontWeight: bold,
        ),
        headlineLarge: TextStyle(
          fontSize: fontHeadline1,
          height: 1.15,
          color: mainColor,
          fontWeight: bold,
        ),
        headlineMedium: TextStyle(
          fontSize: fontHeadline2,
          height: 1.20,
          color: mainColor,
          fontWeight: bold,
        ),
        headlineSmall: TextStyle(
          fontSize: fontHeadline3,
          height: 1.25,
          color: mainColor,
          fontWeight: semiBold,
        ),
        titleLarge: TextStyle(
          fontSize: fontTitle,
          height: 1.30,
          color: mainColor,
          fontWeight: semiBold,
        ),
        titleMedium: TextStyle(
          fontSize: fontSubtitle,
          height: 1.35,
          color: mainColor,
          fontWeight: semiBold,
        ),
        bodyLarge: TextStyle(
          fontSize: fontBody,
          height: 1.45,
          color: secondaryColor,
          fontWeight: regular,
        ),
        bodyMedium: TextStyle(
          fontSize: fontBodySmall,
          height: 1.50,
          color: secondaryColor,
          fontWeight: regular,
        ),
        labelLarge: TextStyle(
          fontSize: fontBody,
          height: 1.25,
          color: mainColor,
          fontWeight: bold,
        ),
        bodySmall: TextStyle(
          fontSize: fontCaption,
          height: 1.40,
          color: secondaryColor,
          fontWeight: regular,
        ),
        labelSmall: TextStyle(
          fontSize: fontOverline,
          height: 1.40,
          color: secondaryColor,
          fontWeight: medium,
        ),
      ),
    );
  }
}
