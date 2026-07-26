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
        'Khám phá hàng nghìn\nkhách sạn',
        'Discover thousands\nof hotels',
      ),
      description: tr(
        'Từ boutique hotel ẩn mình trong phố cổ đến resort sang trọng ven biển.',
        'From hidden boutique hotels in old towns to luxurious beach resorts.',
      ),
      imageAsset: 'assets/images/luxury_ocean_resort.jpg',
      imageAspectRatio: 570 / 623,
      imageMode: OnboardingImageMode.card,
      palette: palette,
      primaryLabel: tr('Tiếp theo', 'Next'),
    ),
    OnboardingSlideData(
      step: '02 / 03',
      title: tr(
        'Tìm kiếm nhanh,\nđặt phòng dễ dàng',
        'Search quickly,\nbook with ease',
      ),
      description: tr(
        'Lọc theo giá, vị trí, tiện nghi. Đặt phòng trong vài giây.',
        'Filter by price, location and amenities. Book in seconds.',
      ),
      imageAsset: 'assets/images/modern_penthouse_suite.jpg',
      imageAspectRatio: 706 / 731,
      imageMode: OnboardingImageMode.card,
      palette: palette,
      primaryLabel: tr('Tiếp theo', 'Next'),
    ),
    OnboardingSlideData(
      step: '03 / 03',
      title: tr(
        'Trải nghiệm đáng\nnhớ mỗi chuyến đi',
        'Make every trip\nmemorable',
      ),
      description: tr(
        'Đánh giá thực từ khách hàng. Không bất ngờ khi check-in.',
        'Real guest reviews with no surprises at check-in.',
      ),
      imageAsset: 'assets/images/tropical_beach_villa.jpg',
      imageAspectRatio: 648 / 580,
      imageMode: OnboardingImageMode.card,
      palette: palette,
      primaryLabel: tr('Bắt đầu', 'Get started'),
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

