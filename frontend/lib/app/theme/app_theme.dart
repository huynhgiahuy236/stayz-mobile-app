import 'package:capstone_mobile/app/theme/light_theme.dart';
import 'package:capstone_mobile/app/theme/dark_theme.dart';
import 'package:capstone_mobile/app/theme/app_radius.dart';
import 'package:capstone_mobile/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  // ─────────────────────────────────────────────────────────────────
  // LAYOUT TOKENS
  // ─────────────────────────────────────────────────────────────────

  /// Standard card image aspect ratio.
  static const double cardImageAspectRatio = 16 / 10;

  /// Standardized button corner radius across the design system.
  static const double buttonRadius = AppRadius.button;

  /// Standardized text input corner radius.
  static const double inputRadius = AppRadius.input;

  /// Standardized card corner radius.
  static const double cardRadius = AppRadius.card;

  /// Control (chip, badge, pill) corner radius.
  static const double controlRadius = AppRadius.button;

  /// Dialog and bottom sheet corner radius.
  static const double dialogRadius = AppRadius.dialog;
  static const double sheetRadius = AppRadius.sheet;

  /// Standard vertical section spacing.
  static const double sectionSpacing = AppSpacing.space32;

  /// Normalized button height tokens: Primary (56), Medium (48), Small (40).
  static const double pageActionHeight = 56.0;
  static const double cardActionHeight = 48.0;
  static const double smallActionHeight = 40.0;

  // ─────────────────────────────────────────────────────────────────
  // LIGHT PALETTE
  // ─────────────────────────────────────────────────────────────────

  static const cream = Color(0xFFF0F0FF);
  static const surface = Color(0xFFFAF9FF);
  static const ink = Color(0xFF101010);
  static const brand = Color(0xFF4C4DDC);
  static const primary = Color(0xFF4C4DDC);
  static const primaryDark = Color(0xFF3334B8);
  static const primarySoft = Color(0xFFE4E4FA);
  static const accent = brand;
  static const accentDark = primaryDark;
  static const teal = Color(0xFF00BFA5);
  static const gold = Color(0xFFE5C158);
  static const line = Color(0xFFE8E8F0);
  static const border = Color(0xFFC8C8F4);
  static const muted = Color(0xFF6E6FA6);
  static const neutral200 = line;
  static const neutral500 = muted;
  static const neutral800 = Color(0xFF1A1A24);
  static const success = Color(0xFF2E7D32);
  static const successSoft = Color(0xFFE8F5E9);
  static const warning = Color(0xFFEF6C00);
  static const warningSoft = Color(0xFFFFF3E0);
  static const danger = Color(0xFFC62828);
  static const dangerSoft = Color(0xFFFFEBEE);
  static const refund = Color(0xFF6A1B9A);
  static const refundSoft = Color(0xFFF3E5F5);

  // Notification semantic colors
  static const notificationPendingBorder = Color(0xFFFFB74D);
  static const notificationPendingText = Color(0xFFE65100);
  static const notificationSuccessBorder = Color(0xFF81C784);
  static const notificationSuccessText = Color(0xFF1B5E20);
  static const notificationDangerBorder = Color(0xFFE57373);
  static const notificationDangerText = Color(0xFFB71C1C);
  static const notificationInfoBorder = Colors.white;
  static const notificationConfirmedBorder = Color(0xFF64B5F6);
  static const notificationConfirmedText = Color(0xFF0D47A1);
  static const notificationOfferBorder = Color(0xFFBA68C8);
  static const notificationOfferText = Color(0xFF4A148C);
  static const depositBorder = Color(0xFFFFB74D);
  static const depositText = warning;

  // ─────────────────────────────────────────────────────────────────
  // LUMINOUS ROYAL NAVY DARK PALETTE
  // ─────────────────────────────────────────────────────────────────

  /// Nền scaffold trong dark mode (Midnight Slate Navy).
  static const surfaceDark = Color(0xFF0F172A);

  /// Nền card/sheet trong dark mode (Luminous Navy Card).
  static const cardDark = Color(0xFF243048);

  /// Nền elevated surface (dialog, bottom sheet) dark.
  static const elevatedDark = Color(0xFF1E293B);

  /// Text chính trong dark mode (Pure Crisp White).
  static const inkDark = Color(0xFFFFFFFF);

  /// Text phụ trong dark mode (Bright Slate-Silver).
  static const mutedDark = Color(0xFFCBD5E1);

  /// Border trong dark mode.
  static const borderDark = Color(0xFF334155);

  /// Line / divider trong dark mode.
  static const lineDark = Color(0xFF334155);

  /// Primary soft trong dark mode.
  static const primarySoftDark = Color(0xFF312E81);

  // ─────────────────────────────────────────────────────────────────
  // SHIMMER COLORS
  // ─────────────────────────────────────────────────────────────────

  static const shimmerBase = Color(0xFFEAEAF5);
  static const shimmerHighlight = Color(0xFFF4F4FA);
  static const shimmerBaseDark = Color(0xFF1E293B);
  static const shimmerHighlightDark = Color(0xFF334155);

  // ─────────────────────────────────────────────────────────────────
  // GRADIENT TOKENS
  // ─────────────────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF6A6BEB)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkHeroGradient = LinearGradient(
    colors: [Color(0x000F172A), Color(0xE60F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─────────────────────────────────────────────────────────────────
  // SHADOWS
  // ─────────────────────────────────────────────────────────────────

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: ink.withValues(alpha: 0.03),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: ink.withValues(alpha: 0.05),
      blurRadius: 32,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> get darkSoftShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.45),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  // ─────────────────────────────────────────────────────────────────
  // THEME EXPORTS
  // ─────────────────────────────────────────────────────────────────

  static ThemeData get light => lightTheme;

  static ThemeData get dark => darkTheme;

  static ThemeData get highContrast => lightTheme.copyWith(
        colorScheme: lightTheme.colorScheme.copyWith(
          error: const Color(0xFFB3261E),
        ),
      );
}
