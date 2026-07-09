import 'package:capstone_mobile/shared/models/stayz_models.dart';

class RoomSelectionArgs {
  const RoomSelectionArgs({
    required this.hotel,
    this.checkInDate,
    this.checkOutDate,
    this.adults = 2,
    this.children = 0,
    this.roomCount = 1,
  });

  final HotelSummary hotel;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int adults;
  final int children;
  final int roomCount;

  bool get hasDates => checkInDate != null && checkOutDate != null && checkOutDate!.isAfter(checkInDate!);
}

class BookingDraft {
  const BookingDraft({
    required this.hotel,
    required this.room,
    required this.checkInDate,
    required this.checkOutDate,
    this.adults = 2,
    this.children = 0,
    this.roomCount = 1,
    this.specialRequest = '',
    this.paymentMethod = 'Thanh toan khi nhan phong',
    this.datesLocked = false,
  });

  final HotelSummary hotel;
  final Room room;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int adults;
  final int children;
  final int roomCount;
  final String specialRequest;
  final String paymentMethod;
  final bool datesLocked;

  int get nights {
    final value = checkOutDate.difference(checkInDate).inDays;
    return value < 1 ? 1 : value;
  }

  num get roomSubtotal => room.pricePerNight * nights * roomCount;
  num get serviceFee => 0;
  num get totalAmount => roomSubtotal;

  BookingDraft copyWith({
    HotelSummary? hotel,
    Room? room,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? adults,
    int? children,
    int? roomCount,
    String? specialRequest,
    String? paymentMethod,
    bool? datesLocked,
  }) {
    return BookingDraft(
      hotel: hotel ?? this.hotel,
      room: room ?? this.room,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      roomCount: roomCount ?? this.roomCount,
      specialRequest: specialRequest ?? this.specialRequest,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      datesLocked: datesLocked ?? this.datesLocked,
    );
  }
}

class BookingSummaryArgs {
  const BookingSummaryArgs({required this.summary});

  final BookingSummary summary;
}
