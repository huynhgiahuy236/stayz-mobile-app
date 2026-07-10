import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/pages/home_page.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class StayZApp extends StatelessWidget {
  const StayZApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Doi ngon ngu -> AppLocale notifyListeners -> dung lai toan bo MaterialApp.
    return ListenableBuilder(
      listenable: AppLocale.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'StayZ',
          theme: AppTheme.light,
          locale: AppLocale.instance.locale,
          initialRoute: AppRoutes.authGate,
          routes: AppRoutes.routes,
          // Route khong ton tai truoc day lam app nem loi. Dua nguoi dung ve
          // trang chu thay vi de ho ket lai o mot man hinh do.
          onUnknownRoute: (settings) => MaterialPageRoute<void>(
            settings: const RouteSettings(name: AppRoutes.home),
            builder: (_) => const HomePage(),
          ),
        );
      },
    );
  }
}

// Compatibility alias for older tests/imports while the project is being reorganized.
typedef MyApp = StayZApp;
