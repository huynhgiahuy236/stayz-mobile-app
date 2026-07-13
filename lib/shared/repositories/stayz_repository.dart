import 'package:capstone_mobile/services/api_service.dart' show ApiService, ApiException;
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/repositories/booking_cache.dart';

export 'package:capstone_mobile/services/api_service.dart' show ApiException;

class SearchFilters {
  const SearchFilters({
    this.keyword = '',
    this.city,
    this.type,
    this.roomType,
    this.minPrice,
    this.maxPrice,
    this.guests,
    this.amenities = const <String>[],
    this.isPreferred = false,
    this.nearBeach = false,
  });

  final String keyword;
  final String? city;
  final String? type;
  final String? roomType;

  /// So sanh voi gia phong thap nhat - dung con so hien thi tren the khach san.
  final num? minPrice;
  final num? maxPrice;

  final int? guests;
  final List<String> amenities;
  final bool isPreferred;

  /// Chi lay khach san o thanh pho co bien (Da Nang, Vung Tau).
  final bool nearBeach;

  bool get isEmpty =>
      keyword.trim().isEmpty &&
      city == null &&
      type == null &&
      roomType == null &&
      minPrice == null &&
      maxPrice == null &&
      guests == null &&
      amenities.isEmpty &&
      !isPreferred &&
      !nearBeach;

  /// So tieu chi dang bat, dung de hien badge tren nut loc.
  int get activeCount =>
      (city != null ? 1 : 0) +
      (type != null ? 1 : 0) +
      (roomType != null ? 1 : 0) +
      (minPrice != null || maxPrice != null ? 1 : 0) +
      (guests != null ? 1 : 0) +
      amenities.length +
      (isPreferred ? 1 : 0) +
      (nearBeach ? 1 : 0);

  SearchFilters copyWith({
    String? keyword,
    String? city,
    String? type,
    String? roomType,
    num? minPrice,
    num? maxPrice,
    int? guests,
    List<String>? amenities,
    bool? isPreferred,
    bool? nearBeach,
    bool clearCity = false,
    bool clearType = false,
    bool clearRoomType = false,
    bool clearPrice = false,
    bool clearGuests = false,
  }) {
    return SearchFilters(
      keyword: keyword ?? this.keyword,
      city: clearCity ? null : city ?? this.city,
      type: clearType ? null : type ?? this.type,
      roomType: clearRoomType ? null : roomType ?? this.roomType,
      minPrice: clearPrice ? null : minPrice ?? this.minPrice,
      maxPrice: clearPrice ? null : maxPrice ?? this.maxPrice,
      guests: clearGuests ? null : guests ?? this.guests,
      amenities: amenities ?? this.amenities,
      isPreferred: isPreferred ?? this.isPreferred,
      nearBeach: nearBeach ?? this.nearBeach,
    );
  }

  Map<String, String> toQuery() {
    return {
      if (keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
      if (city != null && city!.isNotEmpty) 'city': city!,
      if (type != null && type!.isNotEmpty) 'type': type!,
      if (roomType != null && roomType!.isNotEmpty) 'roomType': roomType!,
      // Chi gui khi nguoi dung that su dat gioi han. Truoc day man Filter
      // luon gui maxPrice=5.000.000 ke ca khi khong ai cham vao thanh truot.
      if (minPrice != null) 'minPrice': minPrice!.round().toString(),
      if (maxPrice != null) 'maxPrice': maxPrice!.round().toString(),
      if (guests != null) 'guests': guests!.toString(),
      if (isPreferred) 'isPreferred': 'true',
      if (nearBeach) 'nearBeach': 'true',
      if (amenities.isNotEmpty) 'amenities': amenities.join(','),
      'limit': '50',
    };
  }
}

abstract class StayzRepository {
  Future<List<StayzUser>> getUsers();
  Future<StayzUser?> getProfile();
  Future<StayzUser> updateProfile({
    required String fullName,
    required String phone,
    required String gender,
    required String homeAddress,
  });
  Future<List<City>> getCities();
  Future<List<Amenity>> getAmenities();
  Future<List<Hotel>> getHotels();
  Future<List<Room>> getRooms();
  Future<List<HotelSummary>> getHotelSummaries();
  Future<List<HotelSummary>> searchHotelSummaries(SearchFilters filters);
  Future<List<HotelSummary>> getFavoriteHotelSummaries({String? userId});
  Future<Set<String>> getFavoriteHotelIds();
  Future<void> addFavorite(String hotelId);
  Future<void> removeFavorite(String hotelId);
  Future<List<Room>> getRoomsByHotelId(String hotelId, {DateTime? checkInDate, DateTime? checkOutDate});
  Future<List<BookingSummary>> getBookingSummaries({String? userId});
  Future<BookingSummary?> createBooking(BookingDraft draft);
  Future<Map<String, dynamic>> createPayOSPayment(String bookingId);
  Future<Map<String, dynamic>?> getPayOSPayment(String bookingId);
  Future<BookingSummary?> updateBookingStatus(String bookingId, String status, {num? refundAmount, num? refundRate});
  Future<List<Payment>> getPayments();
  Future<Payment?> getPaymentByBookingId(String bookingId);
  Future<List<Review>> getReviews();
  Future<List<Review>> getReviewsByHotelId(String hotelId);
  Future<void> submitReview({
    required String propertyId,
    required String bookingId,
    required int rating,
    required String comment,
  });
  Future<List<StayzNotification>> getNotifications({String? userId});
}

class ApiStayzRepository implements StayzRepository {
  const ApiStayzRepository({this.api = const ApiService()});

  static const ApiStayzRepository instance = ApiStayzRepository();

  static List<BookingSummary> get cachedBookingSummaries => BookingCache.all;

  /// Xoa cache dung chung. `AuthService.logout()` goi truc tiep `BookingCache.clear()`.
  static void clearCache() => BookingCache.clear();

  final ApiService api;

  Future<List<Map<String, dynamic>>> _list(String path) async {
    final data = await api.get(path);
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList(growable: false);
    }
    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List).whereType<Map<String, dynamic>>().toList(growable: false);
    }
    return const <Map<String, dynamic>>[];
  }

  @override
  Future<List<StayzUser>> getUsers() async {
    final rows = await _list('/users/getAll');
    return rows.map(_userFromApi).toList(growable: false);
  }

  @override
  Future<StayzUser?> getProfile() async {
    final userId = await AuthService.instance.userId();
    if (userId == null) {
      throw ApiException(
        tr(
          'Vui lòng đăng nhập lại để xem hồ sơ.',
          'Please sign in again to view your profile.',
        ),
        statusCode: 401,
      );
    }
    final data = await api.get('/users/getById/$userId');
    if (data is! Map<String, dynamic>) {
      throw ApiException(
        tr(
          'Dữ liệu hồ sơ trả về không hợp lệ.',
          'The profile response is invalid.',
        ),
      );
    }
    final user = _userFromApi(data);
    if (user.id.isEmpty || user.email.isEmpty) {
      throw ApiException(
        tr(
          'Hồ sơ tài khoản đang thiếu dữ liệu bắt buộc.',
          'The account profile is missing required data.',
        ),
      );
    }
    return user;
  }

  @override
  Future<StayzUser> updateProfile({
    required String fullName,
    required String phone,
    required String gender,
    required String homeAddress,
  }) async {
    final userId = await AuthService.instance.userId();
    final token = await AuthService.instance.accessToken();
    if (userId == null || token == null) {
      throw ApiException(tr('Vui lòng đăng nhập lại để cập nhật hồ sơ.', 'Please sign in again to update your profile.'), statusCode: 401);
    }
    final data = await api.patch(
      '/users/update/$userId',
      bearerToken: token,
      body: {
        'full_name': fullName.trim(),
        'phone_number': phone.trim(),
        'gender': gender,
        'home_address': homeAddress.trim(),
      },
    );
    if (data is! Map<String, dynamic>) {
      throw ApiException(tr('Dữ liệu hồ sơ trả về không hợp lệ.', 'The profile response is invalid.'));
    }
    return _userFromApi(data);
  }

  @override
  Future<List<City>> getCities() async {
    final hotels = await getHotels();
    final cities = <String, City>{};
    for (final hotel in hotels) {
      cities[hotel.cityId] = _cityFromSlug(hotel.cityId);
    }
    return cities.values.toList(growable: false);
  }

  @override
  Future<List<Amenity>> getAmenities() async => const <Amenity>[];

  @override
  Future<List<Hotel>> getHotels() async {
    final rows = await _list('/properties/getAll');
    return rows.map(_hotelFromApi).toList(growable: false);
  }

  @override
  Future<List<Room>> getRooms() async {
    final rows = await _list('/room/getAll');
    return rows.map(_roomFromApi).toList(growable: false);
  }

  @override
  Future<List<HotelSummary>> getHotelSummaries() async {
    final rows = await _list('/properties/getAll');
    return _summariesFromApi(rows);
  }

  @override
  Future<List<HotelSummary>> searchHotelSummaries(SearchFilters filters) async {
    final uri = Uri(path: '/properties/search', queryParameters: filters.toQuery());
    final rows = await _list(uri.toString());
    final results = _summariesFromApi(rows);
    final keyword = _searchText(filters.keyword);
    if (keyword.isEmpty) {
      return results;
    }

    // Khong tin rang server/cache da ap dung keyword chi vi response khong rong.
    // Hau kiem tren client de tranh truong hop go "vung tau" nhung van hien
    // ca 18 khach san. Cac filter khac van do server quyet dinh vi tap dau vao
    // o day chinh la response da loc cua server.
    final keywordMatches = results.where((summary) => _matchesKeyword(summary, keyword)).toList(growable: false);
    if (keywordMatches.isNotEmpty || filters.activeCount > 0) {
      return keywordMatches;
    }

    // Fallback cho input tu khoa: backend cu/co cache co the tra rong trong khi
    // danh sach properties van co du lieu. Khong ap dung khi dang bat bo loc de
    // tranh bo qua dieu kien gia, phong, tien ich.
    final all = await getHotelSummaries();
    return all.where((summary) => _matchesKeyword(summary, keyword)).toList(growable: false);
  }

  bool _matchesKeyword(HotelSummary summary, String keyword) {
    final haystack = _searchText([
      summary.hotel.name,
      summary.hotel.address,
      summary.city.name,
      summary.city.region,
    ].join(' '));
    return haystack.contains(keyword);
  }

  String _searchText(String value) {
    const accented = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const plain = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    var result = value.toLowerCase();
    for (var i = 0; i < accented.length; i++) {
      result = result.replaceAll(accented[i], plain[i]);
    }
    return result.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Backend da tinh san rating that, gia phong thap nhat va so phong trong
  /// cho tung khach san. Truoc day client phai tai toan bo `/room/getAll`
  /// roi tu join, va rating la hang so 4.7.
  List<HotelSummary> _summariesFromApi(List<Map<String, dynamic>> rows) {
    return rows.map((json) {
      final hotel = _hotelFromApi(json);
      final ratingValue = json['rating'];
      final roomTypes = json['room_types'];

      return HotelSummary(
        hotel: hotel,
        city: _cityFromSlug(hotel.cityId),
        lowestPrice: _num(json['min_price']),
        availableRooms: _int(json['available_rooms']),
        rating: ratingValue is num ? ratingValue.toDouble() : null,
        reviewCount: _int(json['review_count']),
        maxCapacity: json['max_capacity'] == null ? null : _int(json['max_capacity']),
        roomTypes: roomTypes is List ? roomTypes.map((e) => e.toString()).toList(growable: false) : const <String>[],
      );
    }).toList(growable: false);
  }

  @override
  Future<List<HotelSummary>> getFavoriteHotelSummaries({String? userId}) async {
    final favoriteIds = await getFavoriteHotelIds();
    if (favoriteIds.isEmpty) return const <HotelSummary>[];

    // Lay tu danh sach da enrich thay vi dung property long trong favorites,
    // de the yeu thich cung co rating va gia that nhu moi noi khac.
    final summaries = await getHotelSummaries();
    return summaries.where((summary) => favoriteIds.contains(summary.hotel.id)).toList(growable: false);
  }

  @override
  Future<Set<String>> getFavoriteHotelIds() async {
    final token = await AuthService.instance.accessToken();
    if (token == null) return <String>{};

    final data = await api.get('/favorites', bearerToken: token);
    if (data is! List) return <String>{};

    return data
        .whereType<Map<String, dynamic>>()
        .map((row) => row['property_id'])
        .map((property) => property is Map<String, dynamic> ? _id(property) : _string(property))
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  @override
  Future<void> addFavorite(String hotelId) async {
    final token = await AuthService.instance.accessToken();
    if (token == null) throw StateError('Not authenticated');
    await api.post('/favorites/$hotelId', bearerToken: token);
  }

  @override
  Future<void> removeFavorite(String hotelId) async {
    final token = await AuthService.instance.accessToken();
    if (token == null) throw StateError('Not authenticated');
    await api.delete('/favorites/$hotelId', bearerToken: token);
  }

  @override
  Future<List<Room>> getRoomsByHotelId(String hotelId, {DateTime? checkInDate, DateTime? checkOutDate}) async {
    final uri = Uri(
      path: '/room/$hotelId',
      queryParameters: {
        if (checkInDate != null) 'checkIn': checkInDate.toIso8601String(),
        if (checkOutDate != null) 'checkOut': checkOutDate.toIso8601String(),
      },
    );
    final rows = await _list(uri.toString());
    return rows.map(_roomFromApi).toList(growable: false);
  }

  /// Nhom route `/booking` da duoc bao ve bang JWT, moi loi goi deu phai kem token.
  Future<String> _requireToken() async {
    final token = await AuthService.instance.accessToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Vui lòng đăng nhập để tiếp tục.', statusCode: 401);
    }
    return token;
  }

  @override
  Future<List<BookingSummary>> getBookingSummaries({String? userId}) async {
    final token = await _requireToken();
    final currentUserId = userId ?? await AuthService.instance.userId();
    if (currentUserId == null) {
      throw const ApiException('Vui lòng đăng nhập để xem đặt phòng.', statusCode: 401);
    }

    final data = await api.get('/booking/user/$currentUserId', bearerToken: token);
    final rows = data is List
        ? data.whereType<Map<String, dynamic>>().toList(growable: false)
        : const <Map<String, dynamic>>[];
    final summaries = rows.map(_bookingSummaryFromApi).whereType<BookingSummary>().toList(growable: true);
    return _mergeBookingOverrides(summaries, userId: currentUserId);
  }

  @override
  Future<BookingSummary?> createBooking(BookingDraft draft) async {
    final token = await _requireToken();

    // `user_id` khong con duoc gui len: backend lay tu token.
    final data = await api.post(
      '/booking/create',
      bearerToken: token,
      body: {
        'property_id': draft.hotel.hotel.id,
        'room_id': draft.room.id,
        'check_in': draft.checkInDate.toIso8601String(),
        'check_out': draft.checkOutDate.toIso8601String(),
        'guests': draft.adults + draft.children,
        'rooms_count': draft.roomCount,
        'status': 'pending',
        if (draft.paymentPlan != null) 'payment_plan': draft.paymentPlan,
      },
    );
    final summary = data is Map<String, dynamic> ? _bookingSummaryFromApi(data) : null;
    if (summary != null) BookingCache.put(summary);
    return summary;
  }

  @override
  Future<Map<String, dynamic>> createPayOSPayment(String bookingId) async {
    final token = await _requireToken();
    final data = await api.post('/payment/create/$bookingId', bearerToken: token);
    if (data is! Map<String, dynamic>) throw const ApiException('Invalid PayOS response.');
    return data;
  }

  @override
  Future<Map<String, dynamic>?> getPayOSPayment(String bookingId) async {
    final token = await _requireToken();
    final data = await api.get('/payment/booking/$bookingId', bearerToken: token);
    return data is Map<String, dynamic> ? data : null;
  }

  @override
  Future<BookingSummary?> updateBookingStatus(
    String bookingId,
    String status, {
    num? refundAmount,
    num? refundRate,
  }) async {
    final token = await _requireToken();
    final data = await api.patch(
      '/booking/$bookingId/status',
      bearerToken: token,
      body: {
        'status': status,
      },
    );
    final summary = data is Map<String, dynamic> ? _bookingSummaryFromApi(data) : null;
    if (summary != null) BookingCache.put(summary);
    return summary;
  }

  List<BookingSummary> _mergeBookingOverrides(List<BookingSummary> summaries, {String? userId}) =>
      BookingCache.mergeInto(summaries, userId: userId);

  @override
  Future<List<Payment>> getPayments() async => const <Payment>[];

  @override
  Future<Payment?> getPaymentByBookingId(String bookingId) async => null;

  @override
  Future<List<Review>> getReviews() async {
    final rows = await _list('/review/getAll');
    return rows.map(_reviewFromApi).toList(growable: false);
  }

  @override
  Future<List<Review>> getReviewsByHotelId(String hotelId) async {
    final rows = await _list('/review/getAll?propertyId=$hotelId');
    return rows.map(_reviewFromApi).toList(growable: false);
  }

  @override
  Future<void> submitReview({
    required String propertyId,
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    final token = await AuthService.instance.accessToken();
    if (token == null) throw StateError('Not authenticated');
    await api.post(
      '/review/create',
      bearerToken: token,
      body: {
        'property_id': propertyId,
        'booking_id': bookingId,
        'rating': rating,
        'comment': comment,
      },
    );
  }

  @override
  Future<List<StayzNotification>> getNotifications({String? userId}) async {
    // Backend van sinh thong bao that moi lan booking doi trang thai,
    // nhung ham nay tung tra ve `const []` nen man Thong bao luon trang.
    final token = await AuthService.instance.accessToken();
    if (token == null) return const <StayzNotification>[];

    final data = await api.get('/notifications', bearerToken: token);
    // Endpoint tra ve metaData = { notifications: [...] }, khong phai list tran.
    final list = data is List
        ? data
        : data is Map<String, dynamic> && data['notifications'] is List
            ? data['notifications'] as List
            : const <dynamic>[];
    final rows = list.whereType<Map<String, dynamic>>().toList(growable: false);

    return rows.map(_notificationFromApi).toList(growable: false);
  }

  Future<void> markAllNotificationsRead() async {
    final token = await _requireToken();
    await api.patch('/notifications/read-all', bearerToken: token);
  }

  Future<void> deleteNotification(String id) async {
    final token = await _requireToken();
    await api.delete('/notifications/$id', bearerToken: token);
  }

  /// Xoa nhieu thong bao. Backend chi co DELETE tung id nen goi song song.
  Future<void> deleteNotifications(Iterable<String> ids) async {
    final token = await _requireToken();
    await Future.wait(ids.map((id) => api.delete('/notifications/$id', bearerToken: token)));
  }

  StayzNotification _notificationFromApi(Map<String, dynamic> json) {
    final user = json['user_id'];
    return StayzNotification(
      id: _id(json),
      userId: user is Map<String, dynamic> ? _id(user) : _string(user),
      type: _string(json['type'], fallback: 'system'),
      title: _string(json['title']),
      message: _string(json['body']),
      referenceType: _string(json['ref_type']),
      referenceId: _string(json['ref_id']),
      status: _bool(json['is_read']) ? 'read' : 'unread',
      createdAt: _date(json['createdAt']),
    );
  }

  StayzUser _userFromApi(Map<String, dynamic> json) {
    final avatar = json['avatar'];
    return StayzUser(
      id: _id(json),
      fullName: _string(json['full_name']),
      email: _string(json['email']),
      phone: _string(json['phone_number']),
      gender: _string(json['gender']),
      homeAddress: _string(json['home_address']),
      avatarUrl: avatar is Map ? _string(avatar['url']) : '',
      role: _string(json['role'], fallback: 'user'),
      status: 'active',
      dateOfBirth: '',
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  Hotel _hotelFromApi(Map<String, dynamic> json) {
    final gallery = json['gallery_images'];
    final images = <String>[
      if (_imageUrl(json['main_image_url']).isNotEmpty) _imageUrl(json['main_image_url']),
      if (gallery is List)
        ...gallery.whereType<Map>().map((item) => _imageUrl(item['url'])).where((url) => url.isNotEmpty),
    ];

    return Hotel(
      id: _id(json),
      cityId: _string(json['city'], fallback: 'da-lat'),
      name: _string(json['title'], fallback: 'StayZ Hotel'),
      description: _string(json['description'], fallback: 'Khach san StayZ'),
      descriptionEn: _string(json['description_en']),
      address: _string(json['address']),
      latitude: _num(json['latitude']).toDouble(),
      longitude: _num(json['longitude']).toDouble(),
      starRating: _bool(json['is_preferred']) ? 5 : 4,
      checkInTime: '14:00',
      checkOutTime: '12:00',
      amenityIds: _enabledKeys(json['amenities']),
      imageUrls: images,
      status: _bool(json['is_preferred']) ? 'featured' : 'active',
    );
  }

  Room _roomFromApi(Map<String, dynamic> json) {
    final property = json['property_id'];
    final hotelId = property is Map<String, dynamic> ? _id(property) : _string(property);
    final capacity = _int(json['capacity'], fallback: 2);
    final gallery = json['gallery_images'];
    final propertyGallery = property is Map<String, dynamic> ? property['gallery_images'] : null;
    final images = <String>[
      if (_imageUrl(json['main_image_url']).isNotEmpty) _imageUrl(json['main_image_url']),
      if (gallery is List)
        ...gallery.whereType<Map>().map((item) => _imageUrl(item['url'])).where((url) => url.isNotEmpty),
      if (property is Map<String, dynamic> && _imageUrl(property['main_image_url']).isNotEmpty)
        _imageUrl(property['main_image_url']),
      if (propertyGallery is List)
        ...propertyGallery.whereType<Map>().map((item) => _imageUrl(item['url'])).where((url) => url.isNotEmpty),
    ];

    return Room(
      id: _id(json),
      hotelId: hotelId,
      name: _string(json['name'], fallback: 'StayZ Room'),
      description: _string(json['description']),
      descriptionEn: _string(json['description_en']),
      roomType: _string(json['room_type'], fallback: 'standard_room'),
      capacityAdults: capacity,
      capacityChildren: capacity > 2 ? capacity - 2 : 0,
      bedType: _string(json['bed_info'], fallback: '1 queen bed'),
      sizeSqm: _int(json['area'], fallback: 25),
      pricePerNight: _num(json['price_per_night'] ?? json['price']),
      currency: 'VND',
      totalUnits: _int(json['available_rooms'] ?? json['quantity'], fallback: 1),
      availableUnits: _int(json['available_rooms'] ?? json['quantity'], fallback: 1),
      amenityIds: _enabledKeys(json['amenities']),
      imageUrls: images.toSet().toList(growable: false),
      status: _bool(json['is_active']) ? 'available' : 'inactive',
    );
  }

  BookingSummary? _bookingSummaryFromApi(Map<String, dynamic> json) {
    final roomJson = json['room_id'];
    final hotelJson = json['property_id'];
    if (roomJson is! Map<String, dynamic> || hotelJson is! Map<String, dynamic>) {
      return null;
    }

    final hotel = _hotelFromApi(hotelJson);
    final room = _roomFromApi({...roomJson, 'property_id': hotel.id});
    final guests = _int(json['guests'], fallback: 2);

    // Backend populate `user_id` thanh object. `_string(Map)` se cho ra chuoi
    // "{_id: ..., full_name: ...}" - khong bao gio bang id that, lam hong
    // bo loc theo nguoi dung o `_mergeBookingOverrides`.
    final userJson = json['user_id'];
    final bookingUserId = userJson is Map<String, dynamic> ? _id(userJson) : _string(userJson);

    final booking = Booking(
      id: _id(json),
      userId: bookingUserId,
      roomId: room.id,
      checkInDate: _date(json['check_in']),
      checkOutDate: _date(json['check_out']),
      guests: BookingGuests(adults: guests, children: 0),
      nights: _int(json['nights'], fallback: 1),
      totalAmount: _num(json['total_price']),
      currency: 'VND',
      status: Booking.normalizeStatus(_string(json['status'], fallback: 'pending')),
      paymentStatus: _string(json['payment_status'], fallback: Booking.normalizeStatus(_string(json['status'], fallback: 'pending')) == 'confirmed' ? 'paid' : 'pending'),
      specialRequest: null,
      createdAt: _date(json['createdAt']),
      paymentPlan: _string(json['payment_plan']),
      amountPaid: json['amount_paid'] == null ? null : _num(json['amount_paid']),
      remainingAtHotel: json['remaining_at_hotel'] == null ? null : _num(json['remaining_at_hotel']),
      refundAmount: json['refund_amount'] == null ? null : _num(json['refund_amount']),
      refundRate: json['refund_rate'] == null ? null : _num(json['refund_rate']),
      paymentExpiresAt: json['payment_expires_at'] == null
          ? null
          : _date(json['payment_expires_at']),
    );

    return BookingSummary(
      booking: booking,
      room: room,
      hotel: hotel,
      city: _cityFromSlug(hotel.cityId),
    );
  }

  Review _reviewFromApi(Map<String, dynamic> json) {
    final user = json['user_id'];
    final property = json['property_id'];
    return Review(
      id: _id(json),
      userId: user is Map<String, dynamic> ? _id(user) : _string(user),
      userName: user is Map<String, dynamic> ? _string(user['full_name']) : '',
      hotelId: property is Map<String, dynamic> ? _id(property) : _string(property),
      bookingId: _string(json['booking_id']),
      rating: _int(json['rating']),
      comment: _string(json['comment']),
      status: 'active',
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  City _cityFromSlug(String slug) {
    final names = {
      'da-lat': ('Da Lat', 'Lam Dong'),
      'da-nang': ('Da Nang', 'Central Vietnam'),
      'ha-noi': ('Ha Noi', 'Northern Vietnam'),
      'ho-chi-minh': ('Ho Chi Minh City', 'Southern Vietnam'),
      'vung-tau': ('Vung Tau', 'Ba Ria - Vung Tau'),
    };
    final value = names[slug] ?? (slug, 'Viet Nam');
    return City(id: slug, name: value.$1, countryCode: 'VN', region: value.$2, status: 'active');
  }

  List<String> _enabledKeys(dynamic value) {
    if (value is! Map) return const <String>[];
    return value.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key.toString())
        .toList(growable: false);
  }

  String _id(Map<String, dynamic> json) => _string(json['_id'] ?? json['id']);
  String _string(dynamic value, {String fallback = ''}) => value?.toString() ?? fallback;
  String _imageUrl(dynamic value) => api.resolveAssetUrl(_string(value));
  int _int(dynamic value, {int fallback = 0}) => value is num ? value.round() : int.tryParse(value?.toString() ?? '') ?? fallback;
  num _num(dynamic value) => value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;
  bool _bool(dynamic value) => value == true || value?.toString() == 'true';
  DateTime _date(dynamic value) => DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}
