import 'package:flutter/material.dart';

enum OnboardingImageMode { card, fullBleed, framed }

class OnboardingSlideData {
  const OnboardingSlideData({
    required this.step,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.imageAspectRatio,
    required this.imageMode,
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
  final Alignment? logoAlignment;
  final bool showHeader;
  final String primaryLabel;
  final bool showLoginPrompt;
}
