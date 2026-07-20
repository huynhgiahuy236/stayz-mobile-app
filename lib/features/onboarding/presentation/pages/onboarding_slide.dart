import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/features/onboarding/presentation/pages/onboarding_slide_data.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:capstone_mobile/shared/widgets/stayz_brand_logo.dart';

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
        final horizontalPadding = 30.0 * responsive.widthScale;

        return _FreshBlueSlide(
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

class _FreshBlueSlide extends StatelessWidget {
  const _FreshBlueSlide({
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
    final heroHeight =
        (responsive.isCompact ? 290.0 : 340.0) * responsive.scale;
    final buttonHeight =
        (responsive.isCompact ? 52.0 : 58.0) * responsive.scale;

    return ColoredBox(
      color: data.palette.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OnboardingHeader(
              responsive: responsive,
              showSkip: pageIndex < pageCount - 1,
              palette: data.palette,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                4 * responsive.scale,
                horizontalPadding,
                0,
              ),
              child: SizedBox(
                height: heroHeight,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(34),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [data.palette.sheet, data.palette.inactive],
                          ),
                          border: Border.all(
                            color: data.palette.border,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: data.palette.primaryDark.withValues(
                                alpha: 0.14,
                              ),
                              blurRadius: 32,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      top: 18 * responsive.scale,
                      left: 18 * responsive.widthScale,
                      right: 18 * responsive.widthScale,
                      bottom: 18 * responsive.scale,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: _OnboardingImage(source: data.imageAsset),
                      ),
                    ),
                    Positioned(
                      left: 24 * responsive.widthScale,
                      bottom: 24 * responsive.scale,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16 * responsive.widthScale,
                          vertical: 9 * responsive.scale,
                        ),
                        decoration: BoxDecoration(
                          color: data.palette.sheet.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: data.palette.border),
                        ),
                        child: Text(
                          data.step,
                          style: textTheme.bodyMedium?.copyWith(
                            color: data.palette.primaryDark,
                            fontSize: 13 * responsive.scale,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20 * responsive.scale,
                  horizontalPadding,
                  24 * responsive.scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: textTheme.displayLarge?.copyWith(
                        color: data.palette.ink,
                        fontSize: 31 * responsive.scale,
                        height: 1.12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 12 * responsive.scale),
                    Text(
                      data.description,
                      style: textTheme.bodyLarge?.copyWith(
                        color: data.palette.muted,
                        fontSize: 16 * responsive.scale,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 16 * responsive.scale),
                    if (data.showLoginPrompt)
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: textTheme.bodyMedium?.copyWith(
                              color: data.palette.muted,
                              fontSize: 14 * responsive.scale,
                              fontWeight: FontWeight.w600,
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
                                  color: data.palette.primary,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 1.5,
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
                    const Spacer(),
                    Row(
                      children: [
                        _PageIndicator(
                          pageIndex: pageIndex,
                          pageCount: pageCount,
                          scale: responsive.scale,
                          palette: data.palette,
                        ),
                        const Spacer(),
                        SizedBox(
                          width:
                              (data.showLoginPrompt ? 162 : 134) *
                              responsive.widthScale,
                          height: buttonHeight,
                          child: FilledButton(
                            onPressed: onNext,
                            style: FilledButton.styleFrom(
                              backgroundColor: data.palette.primaryDark,
                              foregroundColor: data.palette.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: data.showLoginPrompt
                                ? Text(
                                    data.primaryLabel,
                                    style: textTheme.labelLarge?.copyWith(
                                      color: data.palette.onPrimary,
                                      fontSize: 17 * responsive.scale,
                                    ),
                                  )
                                : Icon(
                                    Icons.arrow_forward,
                                    size: 24 * responsive.scale,
                                    color: data.palette.onPrimary,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        28 * responsive.widthScale,
        18 * responsive.scale,
        28 * responsive.widthScale,
        (responsive.isCompact ? 12 : 24) * responsive.scale,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StayZBrandLogo(size: 50 * responsive.scale, borderRadius: 15),
          if (showSkip)
            GestureDetector(
              onTap: () => _finishOnboarding(context),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4 * responsive.scale),
                child: Text(
                  tr('Bỏ qua', 'Skip'),
                  style: TextStyle(
                    color: palette.primaryDark,
                    fontSize: 16 * responsive.scale,
                    fontWeight: FontWeight.w600,
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
          colors: [Color(0xFFE9F6FF), Color(0xFFCFEAFF)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.hotel_rounded,
          color: const Color(0xFF0A4E83).withValues(alpha: 0.38),
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
      children: List.generate(pageCount, (index) {
        final isActive = index == pageIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: (isActive ? 32 : 8) * scale,
          height: 8 * scale,
          margin: EdgeInsets.only(
            right: index == pageCount - 1 ? 0.0 : 8 * scale,
          ),
          decoration: BoxDecoration(
            color: isActive ? palette.primary : palette.inactive,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
