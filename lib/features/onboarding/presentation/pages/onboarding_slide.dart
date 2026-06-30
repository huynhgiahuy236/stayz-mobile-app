import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/onboarding/presentation/pages/onboarding_slide_data.dart';
import 'package:flutter/material.dart';

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
        final topSpacing = data.showHeader ? 34.0 * responsive.scale : 36.0 * responsive.scale;
        final horizontalPadding = 30.0 * responsive.widthScale;

        return Stack(
          children: [
            if (data.imageMode == OnboardingImageMode.card)
              Positioned.fill(
                child: CustomPaint(
                  painter: const _IntroBackgroundPainter(),
                ),
              ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  if (data.showHeader)
                    _OnboardingHeader(
                      responsive: responsive,
                    )
                  else
                    SizedBox(height: topSpacing),
                  if (data.logoAlignment != null)
                    _TopLogo(
                      alignment: data.logoAlignment!,
                      responsive: responsive,
                    ),
                  _HeroImage(
                    data: data,
                    responsive: responsive,
                    horizontalPadding: horizontalPadding,
                  ),
                  const Spacer(),
                  _IntroContentSheet(
                    data: data,
                    pageIndex: pageIndex,
                    pageCount: pageCount,
                    responsive: responsive,
                    onNext: onNext,
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
  });

  final _ResponsiveSpec responsive;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        28 * responsive.widthScale,
        18 * responsive.scale,
        28 * responsive.widthScale,
        (responsive.isCompact ? 18 : 34) * responsive.scale,
      ),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: textTheme.headlineMedium?.copyWith(
                color: AppTheme.accentDark,
                fontSize: 31 * responsive.scale,
                fontWeight: FontWeight.w500,
              ),
              children: const [
                TextSpan(text: 'Stay'),
                TextSpan(
                  text: 'Z',
                  style: TextStyle(color: AppTheme.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopLogo extends StatelessWidget {
  const _TopLogo({
    required this.alignment,
    required this.responsive,
  });

  final Alignment alignment;
  final _ResponsiveSpec responsive;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          30 * responsive.widthScale,
          (responsive.isCompact ? 6 : 16) * responsive.scale,
          30 * responsive.widthScale,
          8 * responsive.scale,
        ),
        child: RichText(
          text: TextSpan(
            style: textTheme.headlineMedium?.copyWith(
              color: AppTheme.accent.withValues(alpha: 0.36),
              fontSize: (responsive.isCompact ? 28 : 34) * responsive.scale,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(text: 'Stay'),
              TextSpan(text: 'Z'),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({
    required this.data,
    required this.responsive,
    required this.horizontalPadding,
  });

  final OnboardingSlideData data;
  final _ResponsiveSpec responsive;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final heightRatio = switch (data.imageMode) {
      OnboardingImageMode.card => 0.42,
      OnboardingImageMode.fullBleed => 0.30,
      OnboardingImageMode.framed => 0.29,
    };
    final absoluteMaxHeight = switch (data.imageMode) {
      OnboardingImageMode.card => 350.0,
      OnboardingImageMode.fullBleed => 396.0,
      OnboardingImageMode.framed => 360.0,
    };
    final minHeight = data.imageMode == OnboardingImageMode.card ? 210.0 : 154.0;
    final maxHeight = (responsive.height * heightRatio).clamp(
      minHeight * responsive.heightScale,
      absoluteMaxHeight * responsive.scale,
    ).toDouble();
    final padding = switch (data.imageMode) {
      OnboardingImageMode.fullBleed => EdgeInsets.zero,
      _ => EdgeInsets.symmetric(horizontal: horizontalPadding),
    };
    final radius = data.imageMode == OnboardingImageMode.card ? 16.0 : 0.0;

    return Padding(
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: AspectRatio(
          aspectRatio: data.imageAspectRatio,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: data.imageMode == OnboardingImageMode.card
                  ? [
                      BoxShadow(
                        color: AppTheme.ink.withValues(alpha: 0.2),
                        blurRadius: 32,
                        offset: const Offset(0, 22),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Image.asset(
                data.imageAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroContentSheet extends StatelessWidget {
  const _IntroContentSheet({
    required this.data,
    required this.pageIndex,
    required this.pageCount,
    required this.responsive,
    required this.onNext,
  });

  final OnboardingSlideData data;
  final int pageIndex;
  final int pageCount;
  final _ResponsiveSpec responsive;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final horizontalPadding = 30.0 * responsive.widthScale;
    final titleSize = (pageIndex == pageCount - 1 ? 36.0 : 33.0) * responsive.scale;
    final descriptionSize = 16.0 * responsive.scale;
    final buttonHeight = (responsive.isCompact ? 52.0 : 58.0) * responsive.scale;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: responsive.height * (responsive.isCompact ? 0.48 : 0.54),
      ),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        (responsive.isCompact ? 22 : 30) * responsive.scale,
        horizontalPadding,
        (responsive.isCompact ? 18 : 26) * responsive.scale,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  data.step,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFA69E92),
                    fontSize: 14 * responsive.scale,
                    letterSpacing: 4,
                  ),
                ),
                if (pageIndex == pageCount - 1) ...[
                  const Spacer(),
                  _PageIndicator(
                    pageIndex: pageIndex,
                    pageCount: pageCount,
                    scale: responsive.scale,
                  ),
                ],
              ],
            ),
            SizedBox(height: (responsive.isCompact ? 12 : 18) * responsive.scale),
            Text(
              data.title,
              style: textTheme.displayLarge?.copyWith(
                fontSize: titleSize,
                height: 1.14,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: (responsive.isCompact ? 10 : 14) * responsive.scale),
            Text(
              data.description,
              style: textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF5A3F3F),
                fontSize: descriptionSize,
                height: 1.45,
              ),
            ),
            SizedBox(
              height: (data.showLoginPrompt
                      ? (responsive.isCompact ? 18 : 30)
                      : (responsive.isCompact ? 20 : 36)) *
                  responsive.scale,
            ),
            if (pageIndex != pageCount - 1)
              _PageIndicator(
                pageIndex: pageIndex,
                pageCount: pageCount,
                scale: responsive.scale,
              ),
            SizedBox(height: (responsive.isCompact ? 18 : 26) * responsive.scale),
            SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: FilledButton(
                onPressed: onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.cream,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: data.primaryLabel == 'Tiếp theo'
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            data.primaryLabel,
                            style: textTheme.labelLarge?.copyWith(
                              color: AppTheme.cream,
                              fontSize: 18 * responsive.scale,
                            ),
                          ),
                          SizedBox(width: 12 * responsive.scale),
                          Icon(Icons.arrow_forward, size: 22 * responsive.scale),
                        ],
                      )
                    : Text(
                        data.primaryLabel,
                        style: textTheme.labelLarge?.copyWith(
                          color: AppTheme.cream,
                          fontSize: 18 * responsive.scale,
                        ),
                      ),
              ),
            ),
            if (data.showLoginPrompt) ...[
              SizedBox(height: (responsive.isCompact ? 16 : 24) * responsive.scale),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppTheme.accentDark,
                      fontSize: 14 * responsive.scale,
                      fontWeight: FontWeight.w600,
                    ),
                    children: const [
                      TextSpan(text: 'Đã có tài khoản? '),
                      TextSpan(
                        text: 'Đăng nhập',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationThickness: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
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
  });

  final int pageIndex;
  final int pageCount;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(pageCount, (index) {
        final isActive = index == pageIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: (isActive ? 42 : 10) * scale,
          height: 10 * scale,
          margin: EdgeInsets.only(
            right: index == pageCount - 1 ? 0.0 : 12 * scale,
          ),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.accent : AppTheme.neutral200,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _IntroBackgroundPainter extends CustomPainter {
  const _IntroBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE7DDCA);
    final top = size.height * 0.45;
    final stripeWidth = size.width * 0.23;

    for (var i = 0; i < 3; i++) {
      final left = size.width * 0.15 + (stripeWidth * i);
      paint.color = i == 1 ? const Color(0xFFD8CEBA) : const Color(0xFFE4DAC8);
      canvas.drawRect(Rect.fromLTWH(left, top, stripeWidth, 180), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
