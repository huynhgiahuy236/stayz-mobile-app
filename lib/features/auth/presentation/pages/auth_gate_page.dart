import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  @override
  void initState() {
    super.initState();
    _resolveStartRoute();
  }

  Future<void> _resolveStartRoute() async {
    final auth = AuthService.instance;
    final hasSeenOnboarding = await auth.hasSeenOnboarding();
    final isAuthenticated = await auth.isAuthenticated();
    final role = isAuthenticated ? await auth.userRole() : null;

    if (!mounted) return;

    final route = !hasSeenOnboarding
        ? AppRoutes.onboarding
        : isAuthenticated
        ? role == 'admin'
              ? AppRoutes.admin
              : AppRoutes.home
        : AppRoutes.login;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.cream,
      body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
    );
  }
}
