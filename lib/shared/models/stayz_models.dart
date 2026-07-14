import 'package:capstone_mobile/shared/i18n/app_locale.dart';

class StayzUser {
  const StayzUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.gender = '',
    this.homeAddress = '',
    required this.avatarUrl,
    required this.role,
    required this.status,
    required this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StayzUser.fromJson(Map<String, dynamic> json) {
    return StayzUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatarUrl'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String homeAddress;
  final String avatarUrl;
  final String role;
  final String status;
  final String dateOfBirth;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class City {
  const City({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.region,
    required this.status,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as String,
      name: json['name'] as String,
      countryCode: json['countryCode'] as String,
      region: json['region'] as String,
      status: json['status'] as String,
    );
  }

  final String id;
  final String name;
  final String countryCode;
  final String region;
  final String status;
}

class Amenity {
  const Amenity({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.status,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
    );
  }

  final String id;
  final String name;
  final String icon;
  final String category;
  final String status;
}

class Hotel {
  const Hotel({
    required this.id,
    required this.cityId,
    required this.name,
    required this.description,
    this.descriptionEn = '',
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.starRating,
    required this.checkInTime,
    required this.checkOutTime,
    required this.amenityIds,
    required this.imageUrls,
    required this.status,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] as String,
      cityId: json['cityId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      descriptionEn: json['description_en'] as String? ?? '',
      address: json['address'] as String,
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      starRating: json['starRating'] as int,
      checkInTime: json['checkInTime'] as String,
      checkOutTime: json['checkOutTime'] as String,
      amenityIds: (json['amenityIds'] as List<dynamic>).cast<String>(),
      imageUrls: (json['imageUrls'] as List<dynamic>).cast<String>(),
      status: json['status'] as String,
    );
  }

  final String id;
  final String cityId;
  final String name;
  final String description;
  final String descriptionEn;
  String get localizedDescription => AppLocale.instance.isVietnamese
      ? description
      : (descriptionEn.trim().isNotEmpty
            ? descriptionEn
            : tr(
                'Chưa có mô tả.',
                'English description is not available yet.',
              ));
  final String address;
  final double latitude;
  final double longitude;
  final int starRating;
  final String checkInTime;
  final String checkOutTime;
  final List<String> amenityIds;
  final List<String> imageUrls;
  final String status;
}

double _double(dynamic value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;

class Room {
  const Room({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.description,
    this.descriptionEn = '',
    required this.roomType,
    required this.capacityAdults,
    required this.capacityChildren,
    required this.bedType,
    required this.sizeSqm,
    required this.pricePerNight,
    required this.currency,
    required this.totalUnits,
    required this.availableUnits,
    required this.amenityIds,
    required this.imageUrls,
    required this.status,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      descriptionEn: json['description_en'] as String? ?? '',
      roomType: json['roomType'] as String,
      capacityAdults: json['capacityAdults'] as int,
      capacityChildren: json['capacityChildren'] as int,
      bedType: json['bedType'] as String,
      sizeSqm: json['sizeSqm'] as int,
      pricePerNight: json['pricePerNight'] as num,
      currency: json['currency'] as String,
      totalUnits: json['totalUnits'] as int,
      availableUnits: json['availableUnits'] as int,
      amenityIds: (json['amenityIds'] as List<dynamic>).cast<String>(),
      imageUrls: (json['imageUrls'] as List<dynamic>).cast<String>(),
      status: json['status'] as String,
    );
  }

  final String id;
  final String hotelId;
  final String name;
  final String description;
  final String descriptionEn;
  String get localizedDescription => AppLocale.instance.isVietnamese
      ? description
      : (descriptionEn.trim().isNotEmpty
            ? descriptionEn
            : tr(
                'Chưa có mô tả.',
                'English description is not available yet.',
              ));
  final String roomType;
  final int capacityAdults;
  final int capacityChildren;
  final String bedType;
  final int sizeSqm;
  final num pricePerNight;
  final String currency;
  final int totalUnits;
  final int availableUnits;
  final List<String> amenityIds;
  final List<String> imageUrls;
  final String status;
}

class BookingGuests {
  const BookingGuests({required this.adults, required this.children});

  factory BookingGuests.fromJson(Map<String, dynamic> json) {
    return BookingGuests(
      adults: json['adults'] as int,
      children: json['children'] as int,
    );
  }

  final int adults;
  final int children;
}

class Booking {
  const Booking({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.nights,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    required this.specialRequest,
    required this.createdAt,
    this.paymentPlan = '',
    this.amountPaid,
    this.remainingAtHotel,
    this.refundAmount,
    this.refundRate,
    this.paymentExpiresAt,
    String? attendanceStatus,
    String? attendanceNote,
    String? cancellationReason,
    this.checkInCode = '',
  }) : _attendanceStatus = attendanceStatus ?? 'pending',
       _attendanceNote = attendanceNote ?? '',
       _cancellationReason = cancellationReason ?? '';

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['userId'] as String,
      roomId: json['roomId'] as String,
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      checkOutDate: DateTime.parse(json['checkOutDate'] as String),
      guests: BookingGuests.fromJson(json['guests'] as Map<String, dynamic>),
      nights: json['nights'] as int,
      totalAmount: json['totalAmount'] as num,
      currency: json['currency'] as String,
      status: normalizeStatus(json['status'] as String),
      paymentStatus: json['paymentStatus'] as String,
      specialRequest: json['specialRequest'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      paymentExpiresAt: json['paymentExpiresAt'] == null
          ? null
          : DateTime.parse(json['paymentExpiresAt'] as String),
      attendanceStatus: json['attendanceStatus'] as String? ?? 'pending',
      attendanceNote: json['attendanceNote'] as String? ?? '',
      cancellationReason: json['cancellationReason'] as String? ?? '',
      checkInCode: json['checkInCode'] as String? ?? '',
    );
  }

  final String id;
  final String userId;
  final String roomId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final BookingGuests guests;
  final int nights;
  final num totalAmount;
  final String currency;
  final String status;
  final String paymentStatus;
  final String? specialRequest;
  final DateTime createdAt;

  /// Thanh toan mo phong: phuong an ('deposit_30'|'full_100'), so da tra,
  /// phan con lai tra tai khach san, va thong tin hoan tien khi da huy.
  final String paymentPlan;
  final num? amountPaid;
  final num? remainingAtHotel;
  final num? refundAmount;
  final num? refundRate;
  final DateTime? paymentExpiresAt;
  final String? _attendanceStatus;
  final String? _attendanceNote;
  final String? _cancellationReason;

  String get attendanceStatus => _attendanceStatus ?? 'pending';
  String get attendanceNote => _attendanceNote ?? '';
  String get cancellationReason => _cancellationReason ?? '';
  final String checkInCode;

  bool get hasRecordedPayment => (amountPaid ?? 0) > 0;

  bool get isDepositPayment => paymentPlan == 'deposit_30';

  num get recordedAmount => hasRecordedPayment ? amountPaid! : 0;

  num get remainingAmount {
    if (!hasRecordedPayment || !isDepositPayment) return 0;
    return remainingAtHotel ??
        (totalAmount - recordedAmount).clamp(0, totalAmount);
  }

  num get amountDueNow {
    if (hasRecordedPayment) return 0;
    if (!isDepositPayment) return totalAmount;
    final backendDeposit = totalAmount - (remainingAtHotel ?? 0);
    return backendDeposit > 0 ? backendDeposit : totalAmount * 0.3;
  }

  /// A booking with a recorded deposit is no longer awaiting payment even if
  /// an older API response still contains `pending` in one of its status fields.
  bool get isPaymentPending =>
      !hasRecordedPayment &&
      (normalizedStatus == 'pending' ||
          paymentStatus.toLowerCase() == 'pending');

  bool get isPaymentExpired =>
      isPaymentPending &&
      paymentExpiresAt != null &&
      !paymentExpiresAt!.isAfter(DateTime.now());

  static String normalizeStatus(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    switch (normalized) {
      case 'canceled':
      case 'cancel':
      case 'cancelled_booking':
      case 'canceled_booking':
        return 'cancelled';
      case 'complete':
      case 'done':
        return 'completed';
      case 'confirm':
        return 'confirmed';
      default:
        return normalized.isEmpty ? 'pending' : normalized;
    }
  }

  String get normalizedStatus => normalizeStatus(status);
  bool get isCancelled => normalizedStatus == 'cancelled';
  bool get isUpcoming =>
      !isCompleted &&
      (normalizedStatus == 'pending' || normalizedStatus == 'confirmed');
  bool get isCompleted {
    if (isCancelled) return false;
    return normalizedStatus == 'completed';
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? roomId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    BookingGuests? guests,
    int? nights,
    num? totalAmount,
    String? currency,
    String? status,
    String? paymentStatus,
    String? specialRequest,
    DateTime? createdAt,
    String? paymentPlan,
    num? amountPaid,
    num? remainingAtHotel,
    num? refundAmount,
    num? refundRate,
    DateTime? paymentExpiresAt,
    String? attendanceStatus,
    String? attendanceNote,
    String? cancellationReason,
    String? checkInCode,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      roomId: roomId ?? this.roomId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      guests: guests ?? this.guests,
      nights: nights ?? this.nights,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status == null ? this.status : normalizeStatus(status),
      paymentStatus: paymentStatus ?? this.paymentStatus,
      specialRequest: specialRequest ?? this.specialRequest,
      createdAt: createdAt ?? this.createdAt,
      paymentPlan: paymentPlan ?? this.paymentPlan,
      amountPaid: amountPaid ?? this.amountPaid,
      remainingAtHotel: remainingAtHotel ?? this.remainingAtHotel,
      refundAmount: refundAmount ?? this.refundAmount,
      refundRate: refundRate ?? this.refundRate,
      paymentExpiresAt: paymentExpiresAt ?? this.paymentExpiresAt,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      attendanceNote: attendanceNote ?? this.attendanceNote,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      checkInCode: checkInCode ?? this.checkInCode,
    );
  }
}

class Favorite {
  const Favorite({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      userId: json['userId'] as String,
      hotelId: json['hotelId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String userId;
  final String hotelId;
  final DateTime createdAt;
}

class Payment {
  const Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    required this.transactionCode,
    required this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      amount: json['amount'] as num,
      currency: json['currency'] as String,
      method: json['method'] as String,
      status: json['status'] as String,
      transactionCode: json['transactionCode'] as String,
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String bookingId;
  final num amount;
  final String currency;
  final String method;
  final String status;
  final String transactionCode;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class Review {
  const Review({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.userName = '',
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userId: json['userId'] as String,
      hotelId: json['hotelId'] as String,
      bookingId: json['bookingId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userName: json['userName'] as String? ?? '',
    );
  }

  final String id;
  final String userId;
  final String hotelId;
  final String bookingId;
  final int rating;
  final String comment;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Ten nguoi danh gia that. Truoc day man chi tiet in cung 'StayZ guest'
  /// cho moi review du backend co populate `user_id`.
  final String userName;
}

class StayzNotification {
  const StayzNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.referenceType,
    required this.referenceId,
    required this.status,
    required this.createdAt,
  });

  factory StayzNotification.fromJson(Map<String, dynamic> json) {
    return StayzNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      referenceType: json['referenceType'] as String,
      referenceId: json['referenceId'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String referenceType;
  final String referenceId;
  final String status;
  final DateTime createdAt;
}

class HotelSummary {
  const HotelSummary({
    required this.hotel,
    required this.city,
    required this.lowestPrice,
    required this.availableRooms,
    this.rating,
    this.reviewCount = 0,
    this.maxCapacity,
    this.roomTypes = const <String>[],
  });

  final Hotel hotel;
  final City city;

  /// Gia phong thap nhat con hoat dong. 0 nghia la khach san chua co phong nao.
  final num lowestPrice;
  final int availableRooms;

  /// Diem trung binh tu danh gia that. `null` khi chua co danh gia nao —
  /// khong duoc thay bang mot con so mac dinh.
  final double? rating;
  final int reviewCount;

  final int? maxCapacity;
  final List<String> roomTypes;

  bool get hasRating => rating != null && reviewCount > 0;
  bool get hasPrice => lowestPrice > 0;
  bool get isSoldOut => availableRooms <= 0;
}

class BookingSummary {
  const BookingSummary({
    required this.booking,
    required this.room,
    required this.hotel,
    required this.city,
  });

  final Booking booking;
  final Room room;
  final Hotel hotel;
  final City city;
}
