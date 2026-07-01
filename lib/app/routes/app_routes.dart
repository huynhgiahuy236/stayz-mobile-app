import 'package:capstone_mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/otp_page.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/reset_password_page.dart';
import 'package:capstone_mobile/features/home/presentation/pages/home_page.dart';
import 'package:capstone_mobile/features/onboarding/presentation/pages/onboarding_intro_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';
  static const resetPassword = '/reset-password';

  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomePage(),
        onboarding: (_) => const OnboardingIntroPage(),
        login: (_) => const LoginPage(),
        register: (_) => const RegisterPage(),
        forgotPassword: (_) => const ForgotPasswordPage(),
        otp: (_) => const OtpPage(),
        resetPassword: (_) => const ResetPasswordPage(),
      };
}
