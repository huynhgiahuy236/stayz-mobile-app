import 'dart:async';

import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Wake a sleeping Render service while the user is still entering auth
    // details, so OTP submission does not pay the full cold-start delay.
    unawaited(const ApiService().get('/health').catchError((_) => null));
    _resolveStartRoute();
  }

  Future<void> _resolveStartRoute() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final auth = AuthService.instance;
      final hasSeenOnboarding = await auth.hasSeenOnboarding().timeout(
        const Duration(seconds: 12),
      );
      // New users do not need secure-storage or session work before onboarding.
      final isAuthenticated = hasSeenOnboarding
          ? await auth.isAuthenticated().timeout(const Duration(seconds: 12))
          : false;
      if (!mounted) return;

      final route = !hasSeenOnboarding
          ? AppRoutes.onboarding
          : isAuthenticated
          ? AppRoutes.home
          : AppRoutes.login;
      Navigator.of(context).pushReplacementNamed(route);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: _loading && _error == null
              ? const CircularProgressIndicator(color: AppTheme.accent)
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sync_problem_rounded,
                        size: 56,
                        color: AppTheme.primary,
                        semanticLabel: tr('Lỗi khởi động', 'Startup error'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tr(
                          'Không thể khởi động StayZ lúc này.',
                          'StayZ could not start right now.',
                        ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _resolveStartRoute,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(tr('Thử lại', 'Try again')),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushReplacementNamed(AppRoutes.login),
                        child: Text(tr('Về trang đăng nhập', 'Go to sign in')),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
