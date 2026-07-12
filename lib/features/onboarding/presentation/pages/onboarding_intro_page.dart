import 'package:capstone_mobile/app/routes/app_routes.dart';
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

  static const _gardenPalette = OnboardingPalette(
    background: Color(0xFFEAF7FF),
    sheet: Color(0xFFF8FCFF),
    primary: Color(0xFF1D8BD1),
    primaryDark: Color(0xFF0A4E83),
    ink: Color(0xFF102A43),
    muted: Color(0xFF5E7F98),
    border: Color(0xFFC6E4F7),
    inactive: Color(0xFFD8EDF9),
    onPrimary: Color(0xFFF7FCFF),
  );

  static const _mistPalette = OnboardingPalette(
    background: Color(0xFFEAF4FF),
    sheet: Color(0xFFF7FBFF),
    primary: Color(0xFF2378C9),
    primaryDark: Color(0xFF0B477A),
    ink: Color(0xFF102B4A),
    muted: Color(0xFF607E9B),
    border: Color(0xFFC9E1F8),
    inactive: Color(0xFFDDEEFF),
    onPrimary: Color(0xFFF7FFFC),
  );

  static const _clayPalette = OnboardingPalette(
    background: Color(0xFFEFF8FF),
    sheet: Color(0xFFFBFDFF),
    primary: Color(0xFF3A95D8),
    primaryDark: Color(0xFF135D95),
    ink: Color(0xFF12314D),
    muted: Color(0xFF66849C),
    border: Color(0xFFD2E8FA),
    inactive: Color(0xFFE0F0FB),
    onPrimary: Color(0xFFFBFDFF),
  );

  List<OnboardingSlideData> get _slides => [
    OnboardingSlideData(
      step: '01 / 03',
      title: tr('Khám phá hàng nghìn\nkhách sạn', 'Discover thousands\nof hotels'),
      description: tr('Từ boutique hotel ẩn mình trong phố cổ đến resort sang trọng ven biển.', 'From hidden boutique hotels in old towns to luxurious beach resorts.'),
      imageAsset: 'assets/images/onboarding_pullman_vung_tau.jpg',
      imageAspectRatio: 570 / 623,
      imageMode: OnboardingImageMode.card,
      palette: _gardenPalette,
      primaryLabel: tr('Tiếp theo', 'Next'),
    ),
    OnboardingSlideData(
      step: '02 / 03',
      title: tr('Tìm kiếm nhanh,\nđặt phòng dễ dàng', 'Search quickly,\nbook with ease'),
      description: tr('Lọc theo giá, vị trí, tiện nghi. Đặt phòng trong vài giây.', 'Filter by price, location and amenities. Book in seconds.'),
      imageAsset: 'assets/images/onboarding_hotel_colline_dalat.jpg',
      imageAspectRatio: 706 / 731,
      imageMode: OnboardingImageMode.card,
      palette: _mistPalette,
      primaryLabel: tr('Tiếp theo', 'Next'),
    ),
    OnboardingSlideData(
      step: '03 / 03',
      title: tr('Trải nghiệm đáng\nnhớ mỗi chuyến đi', 'Make every trip\nmemorable'),
      description: tr('Đánh giá thực từ khách hàng. Không bất ngờ khi check-in.', 'Real guest reviews with no surprises at check-in.'),
      imageAsset: 'assets/images/onboarding_ana_mandara_dalat.jpg',
      imageAspectRatio: 648 / 580,
      imageMode: OnboardingImageMode.card,
      palette: _clayPalette,
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
    if (_currentPage == _slides.length - 1) {
      _finishOnboarding();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView.builder(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _slides.length,
        onPageChanged: (page) => setState(() => _currentPage = page),
        itemBuilder: (context, index) {
          return OnboardingSlide(
            data: _slides[index],
            pageIndex: index,
            pageCount: _slides.length,
            onNext: _goNext,
          );
        },
      ),
    );
  }
}
