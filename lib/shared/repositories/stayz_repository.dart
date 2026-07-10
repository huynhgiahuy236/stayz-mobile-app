import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';

class SearchFilters {
  const SearchFilters({
    this.keyword = '',
    this.city,
    this.type,
    this.maxPrice,
    this.amenities = const <String>[],
    this.isPreferred = false,
  });

  final String keyword;
  final String? city;
  final String? type;
  final num? maxPrice;
  final List<String> amenities;
  final bool isPreferred;

  SearchFilters copyWith({
    String? keyword,
    String? city,
    String? type,
    num? maxPrice,
    List<String>? amenities,
    bool? isPreferred,
    bool clearCity = false,
    bool clearType = false,
    bool clearMaxPrice = false,
  }) {
    return SearchFilters(
      keyword: keyword ?? this.keyword,
      city: clearCity ? null : city ?? this.city,
      type: clearType ? null : type ?? this.type,
      maxPrice: clearMaxPrice ? null : maxPrice ?? this.maxPrice,
      amenities: amenities ?? this.amenities,
      isPreferred: isPreferred ?? this.isPreferred,
    );
  }

  Map<String, String> toQuery() {
    return {
      if (keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
      if (city != null && city!.isNotEmpty) 'city': city!,
      if (type != null && type!.isNotEmpty) 'type': type!,
      if (maxPrice != null) 'maxPrice': maxPrice!.round().toString(),
      if (isPreferred) 'isPreferred': 'true',
      if (amenities.isNotEmpty) 'amenities': amenities.join(','),
      'limit': '50',
    };
  }
}

abstract class StayzRepository {
  Future<List<StayzUser>> getUsers();
  Future<StayzUser?> getProfile();
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
  Future<BookingSummary?> updateBookingStatus(String bookingId, String status);
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
  static final Map<String, BookingSummary> _bookingOverrides = <String, BookingSummary>{};

  static List<BookingSummary> get cachedBookingSummaries =>
      _bookingOverrides.values.toList(growable: false);

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
    if (userId == null) return null;
    final data = await api.get('/users/getById/$userId');
    return data is Map<String, dynamic> ? _userFromApi(data) : null;
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
    final hotels = await getHotels();
    final rooms = await getRooms();

    return _summariesFromHotels(hotels, rooms);
  }

  @override
  Future<List<HotelSummary>> searchHotelSummaries(SearchFilters filters) async {
    final uri = Uri(path: '/properties/search', queryParameters: filters.toQuery());
    final rows = await _list(uri.toString());
    final hotels = rows.map(_hotelFromApi).toList(growable: false);
    final rooms = await getRooms();

    return _summariesFromHotels(hotels, rooms);
  }

  List<HotelSummary> _summariesFromHotels(List<Hotel> hotels, List<Room> rooms) {
    return hotels.map((hotel) {
      final hotelRooms = rooms.where((room) => room.hotelId == hotel.id).toList();
      final prices = hotelRooms.map((room) => room.pricePerNight).toList()..sort();
      final availableRooms = hotelRooms.fold<int>(0, (sum, room) => sum + room.availableUnits);

      return HotelSummary(
        hotel: hotel,
        city: _cityFromSlug(hotel.cityId),
        lowestPrice: prices.isEmpty ? 0 : prices.first,
        availableRooms: availableRooms,
        rating: 4.7,
      );
    }).toList(growable: false);
  }

  @override
  Future<List<HotelSummary>> getFavoriteHotelSummaries({String? userId}) async {
    final token = await AuthService.instance.accessToken();
    if (token == null) return const <HotelSummary>[];

    final data = await api.get('/favorites', bearerToken: token);
    if (data is! List) return const <HotelSummary>[];

    final hotels = data
        .whereType<Map<String, dynamic>>()
        .map((row) => row['property_id'])
        .whereType<Map<String, dynamic>>()
        .map(_hotelFromApi)
        .toList(growable: false);
    final rooms = await getRooms();
    return _summariesFromHotels(hotels, rooms);
  }

  @override
  Future<Set<String>> getFavoriteHotelIds() async {
    final favorites = await getFavoriteHotelSummaries();
    return favorites.map((summary) => summary.hotel.id).toSet();
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

  @override
  Future<List<BookingSummary>> getBookingSummaries({String? userId}) async {
    final currentUserId = userId ?? await AuthService.instance.userId();
    final rows = await _list(currentUserId == null ? '/booking/getAll' : '/booking/user/$currentUserId');
    final summaries = rows.map(_bookingSummaryFromApi).whereType<BookingSummary>().toList(growable: true);
    return _mergeBookingOverrides(summaries, userId: currentUserId);
  }

  @override
  Future<BookingSummary?> createBooking(BookingDraft draft) async {
    final userId = await AuthService.instance.userId();
    if (userId == null) throw StateError('Not authenticated');
    final data = await api.post(
      '/booking/create',
      body: {
        'user_id': userId,
        'property_id': draft.hotel.hotel.id,
        'room_id': draft.room.id,
        'check_in': draft.checkInDate.toIso8601String(),
        'check_out': draft.checkOutDate.toIso8601String(),
        'guests': draft.adults + draft.children,
        'rooms_count': draft.roomCount,
        'status': 'confirmed',
      },
    );
    final summary = data is Map<String, dynamic> ? _bookingSummaryFromApi(data) : null;
    if (summary != null) _bookingOverrides[summary.booking.id] = summary;
    return summary;
  }

  @override
  Future<BookingSummary?> updateBookingStatus(String bookingId, String status) async {
    final data = await api.patch('/booking/$bookingId/status', body: {'status': status});
    final summary = data is Map<String, dynamic> ? _bookingSummaryFromApi(data) : null;
    if (summary != null) _bookingOverrides[summary.booking.id] = summary;
    return summary;
  }

  List<BookingSummary> _mergeBookingOverrides(List<BookingSummary> summaries, {String? userId}) {
    final byId = <String, BookingSummary>{
      for (final summary in summaries) summary.booking.id: summary,
    };

    for (final summary in _bookingOverrides.values) {
      if (userId != null && summary.booking.userId.isNotEmpty && summary.booking.userId != userId) {
        continue;
      }
      byId[summary.booking.id] = summary;
    }

    return byId.values.toList(growable: false);
  }

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
  Future<List<StayzNotification>> getNotifications({String? userId}) async => const <StayzNotification>[];

  StayzUser _userFromApi(Map<String, dynamic> json) {
    final avatar = json['avatar'];
    return StayzUser(
      id: _id(json),
      fullName: _string(json['full_name'], fallback: 'StayZ Guest'),
      email: _string(json['email'], fallback: 'guest@stayz.vn'),
      phone: _string(json['phone_number']),
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
    final booking = Booking(
      id: _id(json),
      userId: _string(json['user_id']),
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
