import 'package:capstone_mobile/features/admin/models/admin_models.dart';
import 'package:capstone_mobile/features/admin/presentation/widgets/admin_forms.dart';
import 'package:capstone_mobile/features/admin/presentation/widgets/admin_tables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('admin overview has no overflow at 320px', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const snapshot = AdminSnapshot(
      users: [],
      hotels: [],
      rooms: [],
      bookings: [],
      reviews: [],
      payments: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: AdminOverview(snapshot: snapshot, onStatus: _ignoreStatus),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(MetricTile), findsNWidgets(4));
  });

  testWidgets('admin user form has no overflow at 390px', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final user = AdminUser(
      id: 'user-1',
      fullName: 'StayZ Guest',
      email: 'guest@stayz.vn',
      phone: '0901234567',
      role: 'user',
      gender: 'other',
      address: 'Ho Chi Minh City, Viet Nam',
      avatarUrl: '',
      createdAt: DateTime(2026, 7, 12),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: UserFormDialog(user: user)),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(UserFormDialog), findsOneWidget);
    expect(find.text('Ho Chi Minh City, Viet Nam'), findsOneWidget);
    expect(find.byIcon(Icons.folder_open_outlined), findsOneWidget);
    expect(find.byIcon(Icons.cloud_upload_outlined), findsNothing);
  });
}

void _ignoreStatus(AdminBooking booking, String status) {}
