import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/features/onboarding/presentation/pages/onboarding_slide.dart';
import 'package:capstone_mobile/features/onboarding/presentation/pages/onboarding_slide_data.dart';
import 'package:capstone_mobile/services/auth_service.dart';
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

  static const _slides = [
    OnboardingSlideData(
      step: '01 / 03',
      title: 'Khám phá hàng nghìn\nkhách sạn',
      description:
          'Từ boutique hotel ẩn mình trong phố cổ đến resort sang trọng ven biển.',
      imageAsset: 'https://images.unsplash.com/photo-1566073771259-6a8506099945',
      imageAspectRatio: 570 / 623,
      imageMode: OnboardingImageMode.card,
      palette: _gardenPalette,
    ),
    OnboardingSlideData(
      step: '02 / 03',
      title: 'Tìm kiếm nhanh,\nđặt phòng dễ dàng',
      description: 'Lọc theo giá, vị trí, tiện nghi. Đặt phòng trong vài giây.',
      imageAsset: 'https://images.unsplash.com/photo-1564501049412-61c2a3083791',
      imageAspectRatio: 706 / 731,
      imageMode: OnboardingImageMode.card,
      palette: _mistPalette,
    ),
    OnboardingSlideData(
      step: '03 / 03',
      title: 'Trải nghiệm đáng\nnhớ mỗi chuyến đi',
      description:
          'Đánh giá thực từ khách hàng. Không bất ngờ khi check-in.',
      imageAsset: 'https://images.unsplash.com/photo-1582719508461-905c673771fd',
      imageAspectRatio: 648 / 580,
      imageMode: OnboardingImageMode.card,
      palette: _clayPalette,
      primaryLabel: 'Bắt đầu',
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
