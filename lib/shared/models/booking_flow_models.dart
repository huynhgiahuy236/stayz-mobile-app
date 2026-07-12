import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';

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
    this.paymentPlan,
    this.amountPaid,
    this.remainingAtHotel,
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

  /// Phuong an thanh toan da chon ('deposit_30' | 'full_100') va so tien da tra.
  /// Duoc set o man chon phuong an truoc khi tao booking.
  final String? paymentPlan;
  final num? amountPaid;
  final num? remainingAtHotel;

  int get nights {
    final value = StayzFormatters.nightsBetween(checkInDate, checkOutDate);
    return value < 1 ? 1 : value;
  }

  bool get hasValidDates => StayzFormatters.nightsBetween(checkInDate, checkOutDate) > 0;
  int get guestCount => adults + children;
  int get maxGuests => (room.capacityAdults + room.capacityChildren) * roomCount;
  num get roomSubtotal => StayzFormatters.bookingTotal(
        pricePerNight: room.pricePerNight,
        nights: nights,
        roomQuantity: roomCount,
      );
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
    String? paymentPlan,
    num? amountPaid,
    num? remainingAtHotel,
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
      paymentPlan: paymentPlan ?? this.paymentPlan,
      amountPaid: amountPaid ?? this.amountPaid,
      remainingAtHotel: remainingAtHotel ?? this.remainingAtHotel,
    );
  }
}

class BookingSummaryArgs {
  const BookingSummaryArgs({required this.summary});

  final BookingSummary summary;
}

class PayOSPaymentArgs {
  const PayOSPaymentArgs({
    required this.summary,
    required this.checkoutUrl,
    required this.amount,
    required this.qrCode,
    this.bankBin = '',
    this.accountNumber = '',
    this.accountName = '',
    this.transferDescription = '',
  });

  final BookingSummary summary;
  final String checkoutUrl;
  final num amount;
  final String qrCode;
  final String bankBin;
  final String accountNumber;
  final String accountName;
  final String transferDescription;

  factory PayOSPaymentArgs.fromPayment({
    required BookingSummary summary,
    required Map<String, dynamic> payment,
    required num fallbackAmount,
  }) => PayOSPaymentArgs(
        summary: summary,
        checkoutUrl: payment['checkout_url']?.toString() ?? '',
        amount: payment['amount'] as num? ?? fallbackAmount,
        qrCode: payment['qr_code']?.toString() ?? '',
        bankBin: payment['bank_bin']?.toString() ?? '',
        accountNumber: payment['account_number']?.toString() ?? '',
        accountName: payment['account_name']?.toString() ?? '',
        transferDescription: payment['transfer_description']?.toString() ?? '',
      );
}
