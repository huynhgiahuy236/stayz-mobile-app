import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
          highContrastTheme: AppTheme.highContrast,
          locale: AppLocale.instance.locale,
          supportedLocales: StayzLocalizations.supportedLocales,
          localizationsDelegates: const [
            StayzLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return AppLocale.instance.locale;
            return supportedLocales.firstWhere(
              (supported) => supported.languageCode == locale.languageCode,
              orElse: () => AppLocale.instance.locale,
            );
          },
          initialRoute: AppRoutes.authGate,
          routes: AppRoutes.routes,
          onUnknownRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => _UnknownRoutePage(routeName: settings.name),
          ),
        );
      },
    );
  }
}

// Compatibility alias for older tests/imports while the project is being reorganized.
typedef MyApp = StayZApp;

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage({this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('Không thể mở trang', 'Page unavailable'))),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.route_outlined,
                  size: 64,
                  color: AppTheme.primary,
                  semanticLabel: tr('Lỗi điều hướng', 'Navigation error'),
                ),
                const SizedBox(height: 20),
                Text(
                  tr('Đường dẫn này không còn khả dụng.', 'This page is no longer available.'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  routeName == null
                      ? tr('Hãy quay lại và thử thao tác khác.', 'Go back and try another action.')
                      : tr('Không tìm thấy trang $routeName.', 'Could not find $routeName.'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    if (navigator.canPop()) {
                      navigator.pop();
                    } else {
                      navigator.pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(tr('Quay lại', 'Go back')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
