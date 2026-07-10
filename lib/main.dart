import 'package:capstone_mobile/app/app.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Nap ngon ngu da luu truoc khi dung app, tranh nhap nhay tu VI sang EN.
  await AppLocale.instance.load();
  runApp(const StayZApp());
}
