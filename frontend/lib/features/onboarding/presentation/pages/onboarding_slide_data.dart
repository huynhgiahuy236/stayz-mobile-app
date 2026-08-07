import 'package:flutter/material.dart';

enum OnboardingImageMode { card, fullBleed, framed }

class OnboardingPalette {
  const OnboardingPalette({
    required this.background,
    required this.sheet,
    required this.primary,
    required this.primaryDark,
    required this.ink,
    required this.muted,
    required this.border,
    required this.inactive,
    required this.onPrimary,
  });

  final Color background;
  final Color sheet;
  final Color primary;
  final Color primaryDark;
  final Color ink;
  final Color muted;
  final Color border;
  final Color inactive;
  final Color onPrimary;
}

class OnboardingSlideData {
  const OnboardingSlideData({
    required this.step,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.imageAspectRatio,
    required this.imageMode,
    required this.palette,
    this.logoAlignment,
    this.showHeader = false,
    this.primaryLabel = 'Tiếp theo',
    this.showLoginPrompt = false,
  });

  final String step;
  final String title;
  final String description;
  final String imageAsset;
  final double imageAspectRatio;
  final OnboardingImageMode imageMode;
  final OnboardingPalette palette;
  final Alignment? logoAlignment;
  final bool showHeader;
  final String primaryLabel;
  final bool showLoginPrompt;
}
