import 'package:capstone_mobile/features/admin/models/admin_models.dart';
import 'package:capstone_mobile/features/admin/presentation/widgets/admin_forms.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('booking form falls back when legacy references are missing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'appLanguage': 'vi'});
    await AppLocale.instance.load();
    final now = DateTime(2026, 7, 12);
    final user = AdminUser(
      id: 'user-valid',
      fullName: 'Admin test',
      email: 'admin@test.vn',
      phone: '',
      role: 'admin',
      gender: '',
      address: '',
      avatarUrl: '',
      createdAt: now,
    );
    const hotel = AdminHotel(
      id: 'hotel-valid',
      title: 'StayZ Test',
      slug: 'stayz-test',
      city: 'da-lat',
      type: 'hotel',
      address: 'Da Lat',
      description: '',
      basePrice: 500000,
      imageUrl: '',
      isPreferred: false,
      maxStayDays: 30,
      roomCount: 1,
    );
    const room = AdminRoom(
      id: 'room-valid',
      propertyId: 'hotel-valid',
      hotelTitle: 'StayZ Test',
      name: 'Deluxe',
      description: '',
      roomType: 'deluxe_room',
      pricePerNight: 500000,
      originalPrice: 500000,
      discountPercent: 0,
      capacity: 2,
      quantity: 3,
      bedInfo: '1 queen bed',
      area: 25,
      view: '',
      imageUrl: '',
      isActive: true,
    );
    final booking = AdminBooking(
      id: 'booking-legacy',
      guestName: 'Legacy guest',
      hotelTitle: 'Deleted hotel',
      roomName: 'Deleted room',
      status: 'confirmed',
      paymentStatus: 'paid',
      totalPrice: 1000000,
      checkIn: now.add(const Duration(days: 1)),
      checkOut: now.add(const Duration(days: 3)),
      createdAt: now,
      userId: '',
      propertyId: '',
      roomId: '',
      guests: 2,
      roomsCount: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookingFormDialog(
            users: [user],
            hotels: const [hotel],
            rooms: const [room],
            booking: booking,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('liên kết dữ liệu cũ'), findsOneWidget);
    expect(find.text('Admin test - admin@test.vn'), findsOneWidget);
    expect(find.text('StayZ Test'), findsOneWidget);
    expect(find.text('Deluxe'), findsOneWidget);
  });
}
