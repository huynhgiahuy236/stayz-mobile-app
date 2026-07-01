import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/features/onboarding/presentation/pages/onboarding_slide.dart';
import 'package:capstone_mobile/features/onboarding/presentation/pages/onboarding_slide_data.dart';
import 'package:flutter/material.dart';

class OnboardingIntroPage extends StatefulWidget {
  const OnboardingIntroPage({super.key});

  @override
  State<OnboardingIntroPage> createState() => _OnboardingIntroPageState();
}

class _OnboardingIntroPageState extends State<OnboardingIntroPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _slides = [
    OnboardingSlideData(
      step: '01 / 03',
      title: 'Khám phá hàng nghìn\nkhách sạn',
      description:
          'Từ boutique hotel ẩn mình trong phố cổ đến resort sang trọng ven biển.',
      imageAsset: 'assets/images/onboarding_intro_hero.png',
      imageAspectRatio: 570 / 623,
      imageMode: OnboardingImageMode.card,
    ),
    OnboardingSlideData(
      step: '02 / 03',
      title: 'Tìm kiếm nhanh,\nđặt phòng dễ dàng',
      description: 'Lọc theo giá, vị trí, tiện nghi. Đặt phòng trong vài giây.',
      imageAsset: 'assets/images/onboarding_search_hero.png',
      imageAspectRatio: 706 / 731,
      imageMode: OnboardingImageMode.card,
    ),
    OnboardingSlideData(
      step: '03 / 03',
      title: 'Trải nghiệm đáng\nnhớ mỗi chuyến đi',
      description:
          'Đánh giá thực từ khách hàng. Không bất ngờ khi check-in.',
      imageAsset: 'assets/images/onboarding_stay_hero.png',
      imageAspectRatio: 648 / 580,
      imageMode: OnboardingImageMode.card,
      primaryLabel: 'Bắt đầu',
      showLoginPrompt: true,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage == _slides.length - 1) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: PageView.builder(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
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
