import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StayZApp extends StatelessWidget {
  const StayZApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StayZ',
      theme: AppTheme.light,
      initialRoute: AppRoutes.onboarding,
      routes: AppRoutes.routes,
    );
  }
}

// Compatibility alias for older tests/imports while the project is being reorganized.
typedef MyApp = StayZApp;
