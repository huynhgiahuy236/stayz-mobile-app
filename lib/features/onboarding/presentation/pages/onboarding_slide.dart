import 'dart:ui';
import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_border.dart';
import 'package:capstone_mobile/app/theme/app_motion.dart';
import 'package:capstone_mobile/app/theme/app_radius.dart';
import 'package:capstone_mobile/app/theme/app_shadow.dart';
import 'package:capstone_mobile/app/theme/app_spacing.dart';
import 'package:capstone_mobile/features/onboarding/presentation/pages/onboarding_slide_data.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/widgets/stayz_brand_logo.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

Future<void> _finishOnboarding(BuildContext context) async {
  await AuthService.instance.markOnboardingSeen();
  if (!context.mounted) return;
  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
}

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    required this.data,
    required this.pageIndex,
    required this.pageCount,
    required this.onNext,
    super.key,
  });

  final OnboardingSlideData data;
  final int pageIndex;
  final int pageCount;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = _ResponsiveSpec.from(constraints);
        final horizontalPadding = AppSpacing.space32 * responsive.widthScale;

        return _LuxuryOnboardingSlide(
          data: data,
          pageIndex: pageIndex,
          pageCount: pageCount,
          responsive: responsive,
          horizontalPadding: horizontalPadding,
          onNext: onNext,
        );
      },
    );
  }
}

class _LuxuryOnboardingSlide extends StatelessWidget {
  const _LuxuryOnboardingSlide({
    required this.data,
    required this.pageIndex,
    required this.pageCount,
    required this.responsive,
    required this.horizontalPadding,
    required this.onNext,
  });

  final OnboardingSlideData data;
  final int pageIndex;
  final int pageCount;
  final _ResponsiveSpec responsive;
  final double horizontalPadding;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full screen hero background image
        _OnboardingImage(source: data.imageAsset),

        // Smooth cinematic gradient overlay (Top ~10-20% -> Transparent -> Bottom ~75-85% dark)
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.20, 0.58, 1.0],
              colors: [
                Colors.black.withValues(alpha: 0.20),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.60),
                Colors.black.withValues(alpha: 0.88),
              ],
            ),
          ),
        ),

        // Content layout
        SafeArea(
          child: Column(
            children: [
              // Top Header with Logo glass container & Skip capsule
              _OnboardingHeader(
                responsive: responsive,
                showSkip: pageIndex < pageCount - 1,
                palette: data.palette,
              ),

              const Spacer(),

              // Bottom Content overlay
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Main Title (Max 2 lines, strong weight, high contrast white)
                    Text(
                      data.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: (responsive.isCompact ? 25.0 : 29.0) * responsive.scale,
                        height: 1.16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),

                    SizedBox(height: AppSpacing.space12 * responsive.scale),

                    // Description (~70-75 chars per line rhythm, relaxed line height)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 320.0 * responsive.widthScale,
                      ),
                      child: Text(
                        data.description,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: (responsive.isCompact ? 13.5 : 14.5) * responsive.scale,
                          height: 1.48,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.space20 * responsive.scale),

                    // Page Indicator Dots (Smooth Animated Container)
                    _PageIndicator(
                      pageIndex: pageIndex,
                      pageCount: pageCount,
                      scale: responsive.scale,
                      palette: data.palette,
                    ),

                    SizedBox(height: AppSpacing.space24 * responsive.scale),

                    // Primary Button CTA (Height: 56, Radius: 16, Micro-interaction)
                    _OnboardingPrimaryButton(
                      label: data.primaryLabel,
                      onPressed: onNext,
                      responsive: responsive,
                    ),

                    SizedBox(height: AppSpacing.space24 * responsive.scale),

                    // Bottom Login Section ("Already have an account? Sign in")
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.70),
                            fontSize: 14.0 * responsive.scale,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: tr(
                                'Đã có tài khoản? ',
                                'Already have an account? ',
                              ),
                            ),
                            TextSpan(
                              text: tr('Đăng nhập', 'Sign in'),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5 * responsive.scale,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _finishOnboarding(context);
                                },
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: (responsive.isCompact ? AppSpacing.space12 : AppSpacing.space24) * responsive.scale),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingPrimaryButton extends StatefulWidget {
  const _OnboardingPrimaryButton({
    required this.label,
    required this.onPressed,
    required this.responsive,
  });

  final String label;
  final VoidCallback onPressed;
  final _ResponsiveSpec responsive;

  @override
  State<_OnboardingPrimaryButton> createState() => _OnboardingPrimaryButtonState();
}

class _OnboardingPrimaryButtonState extends State<_OnboardingPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: AppMotion.fast, // 150ms
        curve: AppMotion.easeOutCubic,
        child: SizedBox(
          width: double.infinity,
          height: 56.0 * widget.responsive.scale,
          child: FilledButton(
            onPressed: widget.onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1E2738).withValues(alpha: 0.92),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.25),
                width: AppBorder.regular,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button), // 16.0
              ),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0 * widget.responsive.scale,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResponsiveSpec {
  const _ResponsiveSpec({
    required this.width,
    required this.height,
    required this.widthScale,
    required this.heightScale,
    required this.scale,
    required this.isCompact,
  });

  factory _ResponsiveSpec.from(BoxConstraints constraints) {
    final width = constraints.maxWidth.clamp(360.0, 430.0).toDouble();
    final height = constraints.maxHeight;
    final widthScale = (width / 390).clamp(0.92, 1.10).toDouble();
    final heightScale = (height / 844).clamp(0.68, 1.0).toDouble();

    return _ResponsiveSpec(
      width: width,
      height: height,
      widthScale: widthScale,
      heightScale: heightScale,
      scale: (widthScale < heightScale ? widthScale : heightScale),
      isCompact: height < 760,
    );
  }

  final double width;
  final double height;
  final double widthScale;
  final double heightScale;
  final double scale;
  final bool isCompact;
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({
    required this.responsive,
    required this.showSkip,
    required this.palette,
  });

  final _ResponsiveSpec responsive;
  final bool showSkip;
  final OnboardingPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space24 * responsive.widthScale,
        AppSpacing.space16 * responsive.scale,
        AppSpacing.space24 * responsive.widthScale,
        AppSpacing.space12 * responsive.scale,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo inside subtle glass container
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.radius16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.space4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.radius16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                    width: AppBorder.thin,
                  ),
                ),
                child: StayZBrandLogo(
                  size: 44 * responsive.scale,
                  borderRadius: 12,
                ),
              ),
            ),
          ),
          if (showSkip)
            GestureDetector(
              onTap: () => _finishOnboarding(context),
              child: Container(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill), // 999
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      height: 40.0 * responsive.scale,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.space20 * responsive.widthScale,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(AppRadius.pill), // 999
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                          width: AppBorder.thin,
                        ),
                        boxShadow: AppShadow.elevation1,
                      ),
                      child: Center(
                        child: Text(
                          tr('Bỏ qua', 'Skip'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14 * responsive.scale,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingImage extends StatelessWidget {
  const _OnboardingImage({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => const _OnboardingImageFallback(),
      );
    }

    return Image.asset(
      source,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => const _OnboardingImageFallback(),
    );
  }
}

class _OnboardingImageFallback extends StatelessWidget {
  const _OnboardingImageFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF141E30), Color(0xFF2C3E5E)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.hotel_rounded,
          color: Colors.white.withValues(alpha: 0.38),
          size: 84,
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.pageIndex,
    required this.pageCount,
    required this.scale,
    required this.palette,
  });

  final int pageIndex;
  final int pageCount;
  final double scale;
  final OnboardingPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == pageIndex;
        return AnimatedContainer(
          duration: AppMotion.normal, // 200ms
          curve: AppMotion.easeOutCubic,
          width: (isActive ? 28.0 : 8.0) * scale,
          height: 6.0 * scale,
          margin: EdgeInsets.only(
            right: index == pageCount - 1 ? 0.0 : AppSpacing.space8 * scale,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.30),
            borderRadius: BorderRadius.circular(AppRadius.pill), // 999
          ),
        );
      }),
    );
  }
}
