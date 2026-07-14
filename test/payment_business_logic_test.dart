import 'package:capstone_mobile/features/booking/presentation/pages/booking_confirmation_page.dart';
import 'package:capstone_mobile/shared/data/payment_policy.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/booking_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  tearDown(BookingCache.clear);

  test('deposit 30% and remaining 70% are calculated consistently', () {
    final quote = PaymentPolicy.quote(PaymentPlan.deposit30, 10000);
    expect(quote.payNow, 3000);
    expect(quote.remaining, 7000);
    expect(quote.discount, 0);
  });

  test('full payment applies 10% discount', () {
    final quote = PaymentPolicy.quote(PaymentPlan.full100, 10000);
    expect(quote.payNow, 9000);
    expect(quote.remaining, 0);
    expect(quote.discount, 1000);
  });

  test('authoritative paid server booking replaces pending cache', () {
    BookingCache.put(_summary(status: 'pending', amountPaid: 0));

    final merged = BookingCache.mergeInto([
      _summary(status: 'confirmed', amountPaid: 3000),
    ], userId: 'user-1');

    expect(merged, hasLength(1));
    expect(merged.single.booking.status, 'confirmed');
    expect(merged.single.booking.amountPaid, 3000);
    expect(merged.single.booking.isPaymentPending, isFalse);
  });

  testWidgets('confirmation shows payment breakdown and real check-in QR', (
    tester,
  ) async {
    final summary = _summary(status: 'confirmed', amountPaid: 3000);
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          settings: RouteSettings(
            arguments: BookingSummaryArgs(summary: summary),
          ),
          builder: (_) => const BookingConfirmationPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Tổng giá phòng'), findsOneWidget);
    expect(find.text('Đã đặt cọc (30%)'), findsOneWidget);
    expect(find.text('Còn lại tại khách sạn (70%)'), findsOneWidget);
    for (
      var i = 0;
      i < 4 && find.text('Mã nhận phòng').evaluate().isEmpty;
      i++
    ) {
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
    }
    await tester.tap(find.text('Mã nhận phòng'));
    await tester.pumpAndSettle();
    expect(find.text('A1B2C3D4'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
  });
}

BookingSummary _summary({required String status, required num amountPaid}) {
  const city = City(
    id: 'city-1',
    name: 'Ho Chi Minh City',
    countryCode: 'VN',
    region: 'South',
    status: 'active',
  );
  const hotel = Hotel(
    id: 'hotel-1',
    cityId: 'city-1',
    name: 'StayZ',
    description: '',
    address: '',
    latitude: 0,
    longitude: 0,
    starRating: 5,
    checkInTime: '14:00',
    checkOutTime: '12:00',
    amenityIds: [],
    imageUrls: [],
    status: 'active',
  );
  const room = Room(
    id: 'room-1',
    hotelId: 'hotel-1',
    name: 'Room',
    description: '',
    roomType: 'standard',
    capacityAdults: 2,
    capacityChildren: 0,
    bedType: 'queen',
    sizeSqm: 20,
    pricePerNight: 10000,
    currency: 'VND',
    totalUnits: 1,
    availableUnits: 1,
    amenityIds: [],
    imageUrls: [],
    status: 'active',
  );
  return BookingSummary(
    booking: Booking(
      id: 'booking-1',
      userId: 'user-1',
      roomId: 'room-1',
      checkInDate: DateTime(2026, 7, 20),
      checkOutDate: DateTime(2026, 7, 21),
      guests: const BookingGuests(adults: 2, children: 0),
      nights: 1,
      totalAmount: 10000,
      currency: 'VND',
      status: status,
      paymentStatus: amountPaid > 0 ? 'paid' : 'pending',
      specialRequest: null,
      createdAt: DateTime(2026, 7, 15),
      paymentPlan: 'deposit_30',
      amountPaid: amountPaid,
      remainingAtHotel: amountPaid > 0 ? 7000 : 7000,
      checkInCode: 'A1B2C3D4',
    ),
    room: room,
    hotel: hotel,
    city: city,
  );
}
