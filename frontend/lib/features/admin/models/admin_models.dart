import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';

class AdminSnapshot {
  const AdminSnapshot({
    required this.users,
    required this.hotels,
    required this.rooms,
    required this.bookings,
    required this.reviews,
    required this.payments,
    this.loadErrors = const {},
  });

  final List<AdminUser> users;
  final List<AdminHotel> hotels;
  final List<AdminRoom> rooms;
  final List<AdminBooking> bookings;
  final List<AdminReview> reviews;
  final List<AdminPayment> payments;
  final Map<String, String> loadErrors;

  num get revenue => payments
      .where((payment) => payment.status.toUpperCase() == 'PAID')
      .fold<num>(0, (sum, payment) => sum + payment.amount);

  int get availableRooms =>
      rooms.fold<int>(0, (sum, room) => sum + room.quantity);
  int countBookings(String status) =>
      bookings.where((booking) => booking.status == status).length;

  List<AdminBooking> get recentBookings {
    final copy = [...bookings]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy.take(6).toList(growable: false);
  }

  List<AdminBooking> filterBookings(String query) {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return bookings;
    return bookings
        .where((item) => item.searchText.contains(value))
        .toList(growable: false);
  }

  List<AdminHotel> filterHotels(String query) {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return hotels;
    return hotels
        .where((item) => item.searchText.contains(value))
        .toList(growable: false);
  }

  List<AdminRoom> filterRooms(String query) {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return rooms;
    return rooms
        .where((item) => item.searchText.contains(value))
        .toList(growable: false);
  }

  List<AdminUser> filterUsers(String query) {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return users;
    return users
        .where((item) => item.searchText.contains(value))
        .toList(growable: false);
  }

  List<AdminReview> filterReviews(String query) {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return reviews;
    return reviews
        .where((item) => item.searchText.contains(value))
        .toList(growable: false);
  }

  List<AdminPayment> filterPayments(String query) {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return payments;
    return payments
        .where((item) => item.searchText.contains(value))
        .toList(growable: false);
  }
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.gender,
    required this.address,
    required this.avatarUrl,
    this.dateOfBirth = '',
    this.isActive = true,
    required this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: _id(json),
      fullName: _string(
        json['full_name'],
        fallback: tr('Khách StayZ', 'StayZ guest'),
      ),
      email: _string(json['email']),
      phone: _string(json['phone_number']),
      role: _string(json['role'], fallback: 'user').toLowerCase(),
      gender: _string(json['gender']),
      address: _string(json['home_address']),
      avatarUrl: _string(json['avatar'] is Map ? json['avatar']['url'] : ''),
      dateOfBirth: json['date_of_birth'] == null
          ? ''
          : _date(json['date_of_birth']).toIso8601String().split('T').first,
      isActive: json['is_active'] != false,
      createdAt: _date(json['createdAt']),
    );
  }

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String gender;
  final String address;
  final String avatarUrl;
  final String dateOfBirth;
  final bool isActive;
  final DateTime createdAt;

  String get searchText =>
      '$fullName $email $phone $role $address'.toLowerCase();
}

class AdminHotel {
  const AdminHotel({
    required this.id,
    required this.title,
    required this.slug,
    required this.city,
    required this.type,
    required this.address,
    required this.description,
    required this.descriptionEn,
    required this.basePrice,
    required this.imageUrl,
    required this.isPreferred,
    required this.maxStayDays,
    required this.roomCount,
    this.latitude = 0,
    this.longitude = 0,
    this.isActive = true,
  });

  factory AdminHotel.fromJson(Map<String, dynamic> json, ApiService api) {
    return AdminHotel(
      id: _id(json),
      title: _string(
        json['title'],
        fallback: tr('Cơ sở StayZ', 'StayZ property'),
      ),
      slug: _string(json['slug']),
      city: _string(json['city'], fallback: 'da-lat'),
      type: _string(json['type'], fallback: 'hotel'),
      address: _string(json['address']),
      description: _string(json['description']),
      descriptionEn: _string(json['description_en']),
      basePrice: _num(json['base_price'] ?? json['min_price']),
      imageUrl: api.resolveAssetUrl(_string(json['main_image_url'])),
      isPreferred: _bool(json['is_preferred']),
      maxStayDays: _int(json['max_stay_days'], fallback: 30),
      roomCount: _int(json['room_count']),
      latitude: _num(json['latitude']).toDouble(),
      longitude: _num(json['longitude']).toDouble(),
      isActive: json['is_active'] != false,
    );
  }

  final String id;
  final String title;
  final String slug;
  final String city;
  final String type;
  final String address;
  final String description;
  final String descriptionEn;
  final num basePrice;
  final String imageUrl;
  final bool isPreferred;
  final int maxStayDays;
  final int roomCount;
  final double latitude;
  final double longitude;
  final bool isActive;

  String get searchText => '$title $slug $city $type $address'.toLowerCase();
}

class AdminRoom {
  const AdminRoom({
    required this.id,
    required this.propertyId,
    required this.hotelTitle,
    required this.name,
    required this.description,
    required this.descriptionEn,
    required this.roomType,
    required this.pricePerNight,
    required this.originalPrice,
    required this.discountPercent,
    required this.capacity,
    required this.quantity,
    required this.bedInfo,
    required this.area,
    required this.view,
    required this.imageUrl,
    required this.isActive,
  });

  factory AdminRoom.fromJson(Map<String, dynamic> json, ApiService api) {
    final property = json['property_id'];
    final propertyJson = property is Map<String, dynamic>
        ? property
        : const <String, dynamic>{};
    return AdminRoom(
      id: _id(json),
      propertyId: property is Map<String, dynamic>
          ? _id(property)
          : _string(property),
      hotelTitle: _string(
        propertyJson['title'],
        fallback: tr('Chưa xác định', 'Unknown property'),
      ),
      name: _string(json['name'], fallback: tr('Phòng StayZ', 'StayZ room')),
      description: _string(json['description']),
      descriptionEn: _string(json['description_en']),
      roomType: _string(json['room_type'], fallback: 'standard_room'),
      pricePerNight: _num(json['price'] ?? json['price_per_night']),
      originalPrice: _num(json['original_price'] ?? json['price']),
      discountPercent: _num(json['discount_percent']),
      capacity: _int(json['capacity'], fallback: 1),
      quantity: _int(json['quantity'] ?? json['available_rooms'], fallback: 1),
      bedInfo: _string(json['bed_info'], fallback: '1 queen bed'),
      area: _int(json['area']),
      view: _string(json['view']),
      imageUrl: api.resolveAssetUrl(_string(json['main_image_url'])),
      isActive: json['is_active'] != false,
    );
  }

  final String id;
  final String propertyId;
  final String hotelTitle;
  final String name;
  final String description;
  final String descriptionEn;
  final String roomType;
  final num pricePerNight;
  final num originalPrice;
  final num discountPercent;
  final int capacity;
  final int quantity;
  final String bedInfo;
  final int area;
  final String view;
  final String imageUrl;
  final bool isActive;

  String get searchText => '$name $hotelTitle $roomType $bedInfo'.toLowerCase();
}

class AdminBooking {
  const AdminBooking({
    required this.id,
    required this.guestName,
    required this.hotelTitle,
    required this.roomName,
    required this.status,
    required this.paymentStatus,
    required this.totalPrice,
    required this.checkIn,
    required this.createdAt,
    required this.userId,
    required this.propertyId,
    required this.roomId,
    required this.checkOut,
    required this.guests,
    required this.roomsCount,
    this.attendanceStatus = 'pending',
    this.attendanceNote = '',
    this.cancellationReason = '',
    this.refundAmount = 0,
    this.refundRate = 0,
    this.paymentPlan = '',
    this.amountPaid = 0,
    this.checkInCode = '',
  });

  factory AdminBooking.fromJson(Map<String, dynamic> json) {
    final user = json['user_id'];
    final hotel = json['property_id'];
    final room = json['room_id'];
    final userJson = user is Map<String, dynamic>
        ? user
        : const <String, dynamic>{};
    final hotelJson = hotel is Map<String, dynamic>
        ? hotel
        : const <String, dynamic>{};
    final roomJson = room is Map<String, dynamic>
        ? room
        : const <String, dynamic>{};
    return AdminBooking(
      id: _id(json),
      guestName: _string(
        userJson['full_name'],
        fallback: tr('Khách hàng', 'Guest'),
      ),
      hotelTitle: _string(
        hotelJson['title'],
        fallback: tr('Cơ sở lưu trú', 'Property'),
      ),
      roomName: _string(roomJson['name'], fallback: tr('Phòng', 'Room')),
      status: normalizeAdminStatus(
        _string(json['status'], fallback: 'pending'),
      ),
      paymentStatus: _string(json['payment_status'], fallback: 'pending'),
      totalPrice: _num(json['total_price']),
      checkIn: _date(json['check_in']),
      createdAt: _date(json['createdAt']),
      userId: user is Map<String, dynamic> ? _id(user) : _string(user),
      propertyId: hotel is Map<String, dynamic> ? _id(hotel) : _string(hotel),
      roomId: room is Map<String, dynamic> ? _id(room) : _string(room),
      checkOut: _date(json['check_out']),
      guests: _int(json['guests'], fallback: 1),
      roomsCount: _int(json['rooms_count'], fallback: 1),
      attendanceStatus: _string(json['attendance_status'], fallback: 'pending'),
      attendanceNote: _string(json['attendance_note']),
      cancellationReason: _string(json['cancellation_reason']),
      refundAmount: _num(json['refund_amount']),
      refundRate: _num(json['refund_rate']),
      paymentPlan: _string(json['payment_plan']),
      amountPaid: _num(json['amount_paid']),
      checkInCode: _string(json['check_in_code']),
    );
  }

  final String id;
  final String guestName;
  final String hotelTitle;
  final String roomName;
  final String status;
  final String paymentStatus;
  final num totalPrice;
  final DateTime checkIn;
  final DateTime createdAt;
  final String userId;
  final String propertyId;
  final String roomId;
  final DateTime checkOut;
  final int guests;
  final int roomsCount;
  final String attendanceStatus;
  final String attendanceNote;
  final String cancellationReason;
  final num refundAmount;
  final num refundRate;
  final String paymentPlan;
  final num amountPaid;
  final String checkInCode;

  String get paymentDisplayStatus {
    if (amountPaid <= 0) return 'pending';
    if (paymentPlan == 'deposit_30') return 'deposit_30';
    return 'paid';
  }

  String get searchText =>
      '$guestName $hotelTitle $roomName $status $paymentStatus $attendanceStatus $attendanceNote'
          .toLowerCase();
}

class AdminReview {
  const AdminReview({
    required this.id,
    required this.userName,
    required this.hotelTitle,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory AdminReview.fromJson(Map<String, dynamic> json) {
    final user = json['user_id'] is Map<String, dynamic>
        ? json['user_id'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final property = json['property_id'] is Map<String, dynamic>
        ? json['property_id'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return AdminReview(
      id: _id(json),
      userName: _string(user['full_name'], fallback: tr('Người dùng', 'User')),
      hotelTitle: _string(
        property['title'],
        fallback: tr('Cơ sở lưu trú', 'Property'),
      ),
      rating: _num(json['rating']),
      comment: _string(json['comment']),
      createdAt: _date(json['createdAt']),
    );
  }

  final String id;
  final String userName;
  final String hotelTitle;
  final num rating;
  final String comment;
  final DateTime createdAt;
  String get searchText =>
      '$userName $hotelTitle $rating $comment'.toLowerCase();
}

class AdminPayment {
  const AdminPayment({
    required this.id,
    required this.bookingId,
    required this.userName,
    required this.hotelTitle,
    required this.orderCode,
    required this.amount,
    required this.status,
    required this.checkoutUrl,
    required this.createdAt,
  });

  factory AdminPayment.fromJson(Map<String, dynamic> json) {
    final user = json['user_id'] is Map<String, dynamic>
        ? json['user_id'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final booking = json['booking_id'] is Map<String, dynamic>
        ? json['booking_id'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final property = booking['property_id'] is Map<String, dynamic>
        ? booking['property_id'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return AdminPayment(
      id: _id(json),
      bookingId: booking.isEmpty ? _string(json['booking_id']) : _id(booking),
      userName: _string(
        user['full_name'],
        fallback: _string(user['email'], fallback: tr('Người dùng', 'User')),
      ),
      hotelTitle: _string(
        property['title'],
        fallback: tr('Cơ sở lưu trú', 'Property'),
      ),
      orderCode: _string(json['order_code']),
      amount: _num(json['amount']),
      status: _string(json['status'], fallback: 'pending'),
      checkoutUrl: _string(json['checkout_url']),
      createdAt: _date(json['createdAt']),
    );
  }

  final String id;
  final String bookingId;
  final String userName;
  final String hotelTitle;
  final String orderCode;
  final num amount;
  final String status;
  final String checkoutUrl;
  final DateTime createdAt;
  String get searchText =>
      '$orderCode $userName $hotelTitle $status $bookingId'.toLowerCase();
}

class AdminUserInput {
  const AdminUserInput({
    required this.fullName,
    required this.email,
    required this.password,
    required this.phone,
    required this.gender,
    required this.address,
    required this.role,
    required this.dateOfBirth,
    required this.isActive,
    this.imageBytes,
    this.imageFilename,
  });
  final String fullName;
  final String email;
  final String password;
  final String phone;
  final String gender;
  final String address;
  final String role;
  final String dateOfBirth;
  final bool isActive;
  final List<int>? imageBytes;
  final String? imageFilename;
  Map<String, dynamic> toJson({required bool creating}) => {
    'full_name': fullName,
    'email': email,
    if (password.isNotEmpty) 'password': password,
    'phone_number': phone,
    'gender': gender,
    'home_address': address,
    'role': role,
    'date_of_birth': dateOfBirth,
    'is_active': isActive,
  };
}

class AdminBookingInput {
  const AdminBookingInput({
    required this.userId,
    required this.propertyId,
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.roomsCount,
    required this.status,
  });
  final String userId;
  final String propertyId;
  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final int roomsCount;
  final String status;
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'property_id': propertyId,
    'room_id': roomId,
    'check_in': checkIn.toIso8601String(),
    'check_out': checkOut.toIso8601String(),
    'guests': guests,
    'rooms_count': roomsCount,
    'status': status,
  };
}

class AdminHotelInput {
  const AdminHotelInput({
    required this.title,
    required this.slug,
    required this.address,
    required this.city,
    required this.type,
    required this.description,
    required this.descriptionEn,
    required this.basePrice,
    required this.imageUrl,
    required this.maxStayDays,
    required this.isPreferred,
    required this.isActive,
    required this.latitude,
    required this.longitude,
    this.imageBytes,
    this.imageFilename,
  });

  final String title;
  final String slug;
  final String address;
  final String city;
  final String type;
  final String description;
  final String descriptionEn;
  final num basePrice;
  final String imageUrl;
  final int maxStayDays;
  final bool isPreferred;
  final bool isActive;
  final double latitude;
  final double longitude;
  final List<int>? imageBytes;
  final String? imageFilename;

  Map<String, dynamic> toJson() => {
    'title': title,
    'slug': slug.isEmpty ? slugify(title) : slug,
    'address': address,
    'city': city,
    'country': 'Vietnam',
    'latitude': latitude,
    'longitude': longitude,
    'type': type,
    'base_price': basePrice,
    'description': description,
    'description_en': descriptionEn,
    'main_image_url': imageUrl,
    'is_preferred': isPreferred,
    'is_active': isActive,
    'max_stay_days': maxStayDays,
  };
}

class AdminRoomInput {
  const AdminRoomInput({
    required this.propertyId,
    required this.name,
    required this.roomType,
    required this.description,
    required this.descriptionEn,
    required this.originalPrice,
    required this.discountPercent,
    required this.capacity,
    required this.quantity,
    required this.bedInfo,
    required this.area,
    required this.view,
    required this.imageUrl,
    required this.isActive,
    this.imageBytes,
    this.imageFilename,
  });

  final String propertyId;
  final String name;
  final String roomType;
  final String description;
  final String descriptionEn;
  final num originalPrice;
  final num discountPercent;
  final int capacity;
  final int quantity;
  final String bedInfo;
  final int area;
  final String view;
  final String imageUrl;
  final bool isActive;
  final List<int>? imageBytes;
  final String? imageFilename;

  Map<String, dynamic> toJson() => {
    'property_id': propertyId,
    'name': name,
    'room_type': roomType,
    'description': description,
    'description_en': descriptionEn,
    'original_price': originalPrice,
    'discount_percent': discountPercent,
    'capacity': capacity,
    'quantity': quantity,
    'bed_info': bedInfo,
    'area': area,
    'view': view,
    'main_image_url': imageUrl,
    'is_active': isActive,
  };
}

String normalizeAdminStatus(String value) {
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
    case '':
      return 'pending';
    default:
      return normalized;
  }
}

String adminStatusLabel(String value) {
  switch (normalizeAdminStatus(value)) {
    case 'pending':
      return tr('Chờ thanh toán', 'Awaiting payment');
    case 'confirmed':
      return tr('Đã xác nhận đặt phòng', 'Booking confirmed');
    case 'completed':
      return tr('Đã hoàn tất', 'Completed');
    case 'cancelled':
      return tr('Đã hủy', 'Cancelled');
    case 'paid':
      return tr('Đã thanh toán đủ 100%', 'Paid in full');
    case 'deposit_30':
      return tr('Đã đặt cọc 30%', '30% deposit paid');
    case 'failed':
      return tr('Thất bại', 'Failed');
    case 'refunded':
      return tr('Đã hoàn tiền', 'Refunded');
    case 'active':
      return tr('Đang hoạt động', 'Active');
    case 'inactive':
      return tr('Đã lưu trữ', 'Archived');
    default:
      return value;
  }
}

String adminAttendanceLabel(String value) => switch (value) {
  'checked_in' => tr('Đã nhận phòng', 'Checked in'),
  'no_show' => tr('Không đến', 'No-show'),
  _ => tr('Chờ xác nhận', 'Awaiting confirmation'),
};

String adminAttendanceDescription(String value) => switch (value) {
  'checked_in' => tr(
    'Admin đã xác nhận khách có đến nhận phòng.',
    'An admin confirmed that the guest checked in.',
  ),
  'no_show' => tr(
    'Khách không đến; booking sẽ hủy sau checkout và không hoàn tiền.',
    'The guest did not arrive; the booking will cancel after checkout with no refund.',
  ),
  _ => tr(
    'Chưa có xác nhận khách đã đến nhận phòng.',
    'The guest check-in has not been confirmed.',
  ),
};

String adminStatusDescription(String value) => switch (value) {
  'active' => tr('Bản ghi đang hoạt động.', 'The record is active.'),
  'inactive' => tr('Bản ghi đã được lưu trữ.', 'The record is archived.'),
  'paid' => tr('Đã thanh toán đủ 100%.', 'Paid in full.'),
  'deposit_30' => tr(
    'Đã cọc 30%; còn lại 70% trả tại khách sạn.',
    '30% deposit paid; 70% remains due at the property.',
  ),
  'cancelled' => tr('Booking đã bị hủy.', 'The booking was cancelled.'),
  'completed' => tr(
    'Khách đã nhận phòng và kỳ lưu trú đã kết thúc.',
    'The guest checked in and the stay has ended.',
  ),
  'confirmed' => tr(
    'Booking đã xác nhận, chưa đồng nghĩa đã nhận phòng.',
    'The booking is confirmed but check-in is not yet confirmed.',
  ),
  _ => tr('Đang chờ thanh toán hoặc xử lý lại.', 'Awaiting payment or retry.'),
};

String adminOptionLabel(String value) {
  final labels = <String, String>{
    'da-lat': tr('Đà Lạt', 'Da Lat'),
    'da-nang': tr('Đà Nẵng', 'Da Nang'),
    'ha-noi': tr('Hà Nội', 'Ha Noi'),
    'ho-chi-minh': tr('TP. Hồ Chí Minh', 'Ho Chi Minh City'),
    'vung-tau': tr('Vũng Tàu', 'Vung Tau'),
    'hotel': tr('Khách sạn', 'Hotel'),
    'resort': tr('Khu nghỉ dưỡng', 'Resort'),
    'villa': tr('Biệt thự', 'Villa'),
    'hostel': tr('Nhà nghỉ', 'Hostel'),
    'apartment': tr('Căn hộ', 'Apartment'),
    'business': tr('Khách sạn công vụ', 'Business hotel'),
    'standard_room': tr('Phòng tiêu chuẩn', 'Standard room'),
    'deluxe_room': tr('Phòng cao cấp', 'Deluxe room'),
    'suite': tr('Phòng suite', 'Suite'),
  };
  return labels[value] ?? value;
}

String slugify(String value) {
  final cleaned = value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .trim();
  return cleaned.isEmpty
      ? 'stayz-hotel-${DateTime.now().millisecondsSinceEpoch}'
      : cleaned;
}

String _id(Map<String, dynamic> json) => _string(json['_id'] ?? json['id']);
String _string(dynamic value, {String fallback = ''}) =>
    value?.toString() ?? fallback;
int _int(dynamic value, {int fallback = 0}) => value is num
    ? value.round()
    : int.tryParse(value?.toString() ?? '') ?? fallback;
num _num(dynamic value) =>
    value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;
bool _bool(dynamic value) => value == true || value?.toString() == 'true';
DateTime _date(dynamic value) =>
    DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
