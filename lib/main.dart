import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'room_detail/room_detail_page.dart';
import 'room_detail/widgets/room_detail_container.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: StayZColors.background,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: StayZColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: StayZColors.background,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StayZ',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: StayZColors.background,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: StayZColors.orange,
          surface: StayZColors.white,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
      builder: (context, child) {
        return ColoredBox(
          color: StayZColors.background,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const RoomDetailPage(),
    );
  }
}
