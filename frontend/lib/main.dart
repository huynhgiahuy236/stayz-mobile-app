import 'package:capstone_mobile/app/app.dart';
import 'package:capstone_mobile/app/theme/app_theme_notifier.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Nap ngon ngu va theme da luu truoc khi dung app, tranh nhap nhay.
  await Future.wait([
    AppLocale.instance.load(),
    AppThemeNotifier.instance.load(),
  ]);
  runApp(const StayZApp());
}
