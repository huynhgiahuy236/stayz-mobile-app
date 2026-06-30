import 'package:capstone_mobile/features/home/presentation/pages/home_page.dart';
import 'package:capstone_mobile/features/onboarding/presentation/pages/onboarding_intro_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const onboarding = '/onboarding';

  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomePage(),
        onboarding: (_) => const OnboardingIntroPage(),
      };
}
