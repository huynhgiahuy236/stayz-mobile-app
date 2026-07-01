import 'package:capstone_mobile/shared/data/mock_json_loader.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';

abstract class StayzRepository {
  Future<List<StayzUser>> getUsers();
  Future<StayzUser?> getProfile();
  Future<List<City>> getCities();
  Future<List<Amenity>> getAmenities();
  Future<List<Hotel>> getHotels();
  Future<List<Room>> getRooms();
  Future<List<HotelSummary>> getHotelSummaries();
  Future<List<HotelSummary>> getFavoriteHotelSummaries({String? userId});
  Future<List<Room>> getRoomsByHotelId(String hotelId);
  Future<List<BookingSummary>> getBookingSummaries({String? userId});
  Future<List<Payment>> getPayments();
  Future<Payment?> getPaymentByBookingId(String bookingId);
  Future<List<Review>> getReviews();
  Future<List<Review>> getReviewsByHotelId(String hotelId);
  Future<List<StayzNotification>> getNotifications({String? userId});
}

class MockStayzRepository implements StayzRepository {
  MockStayzRepository({MockJsonLoader loader = const MockJsonLoader()}) : _loader = loader;

  static final MockStayzRepository instance = MockStayzRepository();
  static const String currentUserId = '64f300000000000000000001';

  final MockJsonLoader _loader;

  Future<List<T>> _load<T>(
    String collection,
    T Function(Map<String, dynamic> json) mapper,
  ) async {
    final rows = await _loader.loadCollection(collection);
    return rows.map(mapper).toList(growable: false);
  }

  @override
  Future<List<StayzUser>> getUsers() {
    return _load('users', StayzUser.fromJson);
  }

  @override
  Future<StayzUser?> getProfile() async {
    final users = await getUsers();
    return users.where((user) => user.id == currentUserId).firstOrNull;
  }

  @override
  Future<List<City>> getCities() {
    return _load('cities', City.fromJson);
  }

  @override
  Future<List<Amenity>> getAmenities() {
    return _load('amenities', Amenity.fromJson);
  }

  @override
  Future<List<Hotel>> getHotels() {
    return _load('hotels', Hotel.fromJson);
  }

  @override
  Future<List<Room>> getRooms() {
    return _load('rooms', Room.fromJson);
  }

  @override
  Future<List<HotelSummary>> getHotelSummaries() async {
    final hotels = await getHotels();
    final rooms = await getRooms();
    final cities = await getCities();
    final cityById = {for (final city in cities) city.id: city};

    return hotels.map((hotel) {
      final hotelRooms = rooms.where((room) => room.hotelId == hotel.id).toList();
      final availableRooms = hotelRooms.fold<int>(0, (sum, room) => sum + room.availableUnits);
      final prices = hotelRooms.map((room) => room.pricePerNight).toList()..sort();

      return HotelSummary(
        hotel: hotel,
        city: cityById[hotel.cityId]!,
        lowestPrice: prices.isEmpty ? 0 : prices.first,
        availableRooms: availableRooms,
        rating: (hotel.starRating + 0.7).clamp(3.8, 5.0).toDouble(),
      );
    }).toList(growable: false);
  }

  @override
  Future<List<HotelSummary>> getFavoriteHotelSummaries({String? userId}) async {
    final targetUserId = userId ?? currentUserId;
    final favorites = await _load('favorites', Favorite.fromJson);
    final favoriteHotelIds = favorites
        .where((favorite) => favorite.userId == targetUserId)
        .map((favorite) => favorite.hotelId)
        .toSet();
    final hotels = await getHotelSummaries();

    return hotels.where((summary) => favoriteHotelIds.contains(summary.hotel.id)).toList(growable: false);
  }

  @override
  Future<List<Room>> getRoomsByHotelId(String hotelId) async {
    final rooms = await getRooms();
    return rooms.where((room) => room.hotelId == hotelId).toList(growable: false);
  }

  @override
  Future<List<BookingSummary>> getBookingSummaries({String? userId}) async {
    final targetUserId = userId ?? currentUserId;
    final bookings = await _load('bookings', Booking.fromJson);
    final rooms = await getRooms();
    final hotels = await getHotels();
    final cities = await getCities();

    final roomById = {for (final room in rooms) room.id: room};
    final hotelById = {for (final hotel in hotels) hotel.id: hotel};
    final cityById = {for (final city in cities) city.id: city};

    return bookings.where((booking) => booking.userId == targetUserId).map((booking) {
      final room = roomById[booking.roomId]!;
      final hotel = hotelById[room.hotelId]!;

      return BookingSummary(
        booking: booking,
        room: room,
        hotel: hotel,
        city: cityById[hotel.cityId]!,
      );
    }).toList(growable: false);
  }

  @override
  Future<List<Payment>> getPayments() {
    return _load('payments', Payment.fromJson);
  }

  @override
  Future<Payment?> getPaymentByBookingId(String bookingId) async {
    final payments = await getPayments();
    return payments.where((payment) => payment.bookingId == bookingId).firstOrNull;
  }

  @override
  Future<List<Review>> getReviews() {
    return _load('reviews', Review.fromJson);
  }

  @override
  Future<List<Review>> getReviewsByHotelId(String hotelId) async {
    final reviews = await getReviews();
    return reviews.where((review) => review.hotelId == hotelId).toList(growable: false);
  }

  @override
  Future<List<StayzNotification>> getNotifications({String? userId}) async {
    final targetUserId = userId ?? currentUserId;
    final notifications = await _load('notifications', StayzNotification.fromJson);

    return notifications
        .where((notification) => notification.userId == targetUserId)
        .toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
