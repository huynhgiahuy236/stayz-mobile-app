import 'package:capstone_mobile/features/admin/presentation/widgets/admin_shell.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('admin language segmented control switches VN and EN', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'appLanguage': 'en'});
    await AppLocale.instance.load();
    final search = TextEditingController();

    await tester.pumpWidget(
      ListenableBuilder(
        listenable: AppLocale.instance,
        builder: (_, _) => MaterialApp(
          home: Scaffold(
            body: AdminHeader(
              section: AdminSection.overview,
              searchController: search,
              onRefresh: () {},
              onLogout: () {},
              onHome: () {},
            ),
          ),
        ),
      ),
    );

    expect(AppLocale.instance.language, AppLanguage.en);
    await tester.tap(find.text('VI'));
    await tester.pumpAndSettle();
    expect(AppLocale.instance.language, AppLanguage.vi);
    expect(find.text('Tổng quan vận hành'), findsOneWidget);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(AppLocale.instance.language, AppLanguage.en);
    expect(find.text('Operations overview'), findsOneWidget);
    search.dispose();
  });
}
