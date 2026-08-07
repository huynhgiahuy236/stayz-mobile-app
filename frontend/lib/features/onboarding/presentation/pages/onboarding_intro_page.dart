import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/onboarding/presentation/pages/onboarding_slide.dart';
import 'package:capstone_mobile/features/onboarding/presentation/pages/onboarding_slide_data.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class OnboardingIntroPage extends StatefulWidget {
  const OnboardingIntroPage({super.key});

  @override
  State<OnboardingIntroPage> createState() => _OnboardingIntroPageState();
}

class _OnboardingIntroPageState extends State<OnboardingIntroPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  OnboardingPalette _getPalette(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OnboardingPalette(
      background: isDark ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surface,
      sheet: isDark ? Theme.of(context).cardColor : Colors.white,
      primary: AppTheme.primary,
      primaryDark: isDark ? AppTheme.accent : AppTheme.primaryDark,
      ink: isDark ? AppTheme.inkDark : Theme.of(context).colorScheme.onSurface,
      muted: isDark ? AppTheme.mutedDark : Theme.of(context).colorScheme.secondary,
      border: isDark ? AppTheme.borderDark : AppTheme.border,
      inactive: isDark ? AppTheme.borderDark : AppTheme.line,
      onPrimary: Colors.white,
    );
  }

  List<OnboardingSlideData> _getSlides(OnboardingPalette palette) => [
    OnboardingSlideData(
      step: '01 / 03',
      title: tr(
        'Find Your Perfect Stay\nAnytime, Anywhere',
        'Find Your Perfect Stay\nAnytime, Anywhere',
      ),
      description: tr(
        'Explore hotels and resorts around the world — tailored to your comfort, budget, and mood.',
        'Explore hotels and resorts around the world — tailored to your comfort, budget, and mood.',
      ),
      imageAsset: 'assets/images/hotels/the_reverie_saigon.jpg',
      imageAspectRatio: 1,
      imageMode: OnboardingImageMode.card,
      palette: palette,
      primaryLabel: tr('Get Started', 'Get Started'),
    ),
    OnboardingSlideData(
      step: '02 / 03',
      title: tr(
        'Fast, Simple & Secure\nBooking',
        'Fast, Simple & Secure\nBooking',
      ),
      description: tr(
        'Choose your dates, compare prices, and confirm your stay in just a few taps — no hassle, no delays.',
        'Choose your dates, compare prices, and confirm your stay in just a few taps — no hassle, no delays.',
      ),
      imageAsset: 'assets/images/hotels/four_points_sheraton_danang.jpg',
      imageAspectRatio: 1,
      imageMode: OnboardingImageMode.card,
      palette: palette,
      primaryLabel: tr('Get Started', 'Get Started'),
    ),
    OnboardingSlideData(
      step: '03 / 03',
      title: tr(
        'Flexible Payment\nOptions',
        'Flexible Payment\nOptions',
      ),
      description: tr(
        'Pay easily with card, mobile banking, or wallet — your safety and convenience come first.',
        'Pay easily with card, mobile banking, or wallet — your safety and convenience come first.',
      ),
      imageAsset: 'assets/images/hotels/novotel_danang.jpg',
      imageAspectRatio: 1,
      imageMode: OnboardingImageMode.card,
      palette: palette,
      primaryLabel: tr('Get Started', 'Get Started'),
      showLoginPrompt: true,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final navigator = Navigator.of(context);
    await AuthService.instance.markOnboardingSeen();
    if (!mounted) return;
    navigator.pushReplacementNamed(AppRoutes.login);
  }

  void _goNext() {
    final palette = _getPalette(context);
    final slides = _getSlides(palette);
    if (_currentPage == slides.length - 1) {
      _finishOnboarding();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = _getPalette(context);
    final slides = _getSlides(palette);

    return Scaffold(
      backgroundColor: palette.background,
      body: PageView.builder(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        itemCount: slides.length,
        onPageChanged: (page) => setState(() => _currentPage = page),
        itemBuilder: (context, index) {
          return OnboardingSlide(
            data: slides[index],
            pageIndex: index,
            pageCount: slides.length,
            onNext: _goNext,
          );
        },
      ),
    );
  }
}

