import 'package:capstone_mobile/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  const AppRoutes._();

  static const home = '/';

  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomePage(),
      };
}
