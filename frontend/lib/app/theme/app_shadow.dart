import 'package:flutter/material.dart';

class AppShadow {
  const AppShadow._();

  static const List<BoxShadow> elevation0 = <BoxShadow>[];

  static List<BoxShadow> get elevation1 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevation2 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get elevation3 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get elevation4 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 32,
          offset: const Offset(0, 16),
        ),
      ];

  static List<BoxShadow> get elevation5 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.18),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
      ];

  // Dark Mode Shadow variants
  static List<BoxShadow> get darkElevation2 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.30),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get darkElevation3 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];
}
