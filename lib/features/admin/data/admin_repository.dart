import 'package:capstone_mobile/features/admin/models/admin_models.dart';
import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';

class AdminRepository {
  const AdminRepository({this.api = const ApiService()});

  final ApiService api;

  Future<AdminSnapshot> loadDashboard() async {
    final token = await _requireToken();
    final result = await Future.wait<dynamic>([
      _list('/users/getAll'),
      _list('/properties/getAll'),
      _list('/room/getAll'),
      _list('/booking/getAll', bearerToken: token),
      _list('/review/getAll', bearerToken: token),
      _list('/payment/getAll', bearerToken: token),
    ]);

    return AdminSnapshot(
      users: (result[0] as List<Map<String, dynamic>>)
          .map(AdminUser.fromJson)
          .toList(growable: false),
      hotels: (result[1] as List<Map<String, dynamic>>)
          .map((row) => AdminHotel.fromJson(row, api))
          .toList(growable: false),
      rooms: (result[2] as List<Map<String, dynamic>>)
          .map((row) => AdminRoom.fromJson(row, api))
          .toList(growable: false),
      bookings: (result[3] as List<Map<String, dynamic>>)
          .map(AdminBooking.fromJson)
          .toList(growable: false),
      reviews: (result[4] as List<Map<String, dynamic>>)
          .map(AdminReview.fromJson)
          .toList(growable: false),
      payments: (result[5] as List<Map<String, dynamic>>)
          .map(AdminPayment.fromJson)
          .toList(growable: false),
    );
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    final token = await _requireToken();
    await api.patch(
      '/booking/$bookingId/status',
      bearerToken: token,
      body: {'status': status},
    );
  }

  Future<void> updateBookingAttendance(
    String bookingId,
    String attendanceStatus, {
    String note = '',
  }) async {
    final token = await _requireToken();
    await api.patch(
      '/booking/$bookingId/attendance',
      bearerToken: token,
      body: {'attendance_status': attendanceStatus, 'note': note},
    );
  }

  Future<AdminBooking> findBookingByCheckInCode(String value) async {
    final token = await _requireToken();
    final code = value.trim().toUpperCase().replaceFirst('STAYZ-CHECKIN:', '');
    final data = await api.get(
      '/booking/admin/check-in/${Uri.encodeComponent(code)}',
      bearerToken: token,
    );
    if (data is Map<String, dynamic>) return AdminBooking.fromJson(data);
    throw ApiException(tr('Không tìm thấy đặt phòng.', 'Booking not found.'));
  }

  Future<String> saveHotel(AdminHotelInput input, {String? id}) async {
    final token = await _requireToken();
    if (id == null) {
      final response = await api.post(
        '/properties/create',
        bearerToken: token,
        body: input.toJson(),
      );
      return _entityId(response);
    } else {
      await api.put(
        '/properties/update/$id',
        bearerToken: token,
        body: input.toJson(),
      );
      return id;
    }
  }

  Future<void> deleteHotel(String id) async {
    final token = await _requireToken();
    await api.delete('/properties/delete/$id', bearerToken: token);
  }

  Future<String> saveRoom(AdminRoomInput input, {String? id}) async {
    final token = await _requireToken();
    if (id == null) {
      final response = await api.post(
        '/room/create',
        bearerToken: token,
        body: input.toJson(),
      );
      return _entityId(response);
    } else {
      await api.put(
        '/room/update/$id',
        bearerToken: token,
        body: input.toJson(),
      );
      return id;
    }
  }

  Future<void> deleteRoom(String id) async {
    final token = await _requireToken();
    await api.delete('/room/delete/$id', bearerToken: token);
  }

  Future<String> saveUser(AdminUserInput input, {String? id}) async {
    final token = await _requireToken();
    if (id == null) {
      final response = await api.post(
        '/users/admin/create',
        bearerToken: token,
        body: input.toJson(creating: true),
      );
      return _entityId(response);
    } else {
      await api.patch(
        '/users/update/$id',
        bearerToken: token,
        body: input.toJson(creating: false),
      );
      return id;
    }
  }

  Future<void> deleteUser(String id) async {
    final token = await _requireToken();
    await api.delete('/users/delete/$id', bearerToken: token);
  }

  Future<void> saveBooking(AdminBookingInput input, {String? id}) async {
    final token = await _requireToken();
    if (id == null) {
      await api.post(
        '/booking/create',
        bearerToken: token,
        body: input.toJson(),
      );
    } else {
      await api.put(
        '/booking/update/$id',
        bearerToken: token,
        body: input.toJson(),
      );
    }
  }

  Future<void> deleteBooking(String id) async {
    final token = await _requireToken();
    await api.delete('/booking/delete/$id', bearerToken: token);
  }

  Future<void> updateReview(
    AdminReview review, {
    required num rating,
    required String comment,
  }) async {
    final token = await _requireToken();
    await api.put(
      '/review/update/${review.id}',
      bearerToken: token,
      body: {'rating': rating, 'comment': comment},
    );
  }

  Future<void> deleteReview(String id) async {
    final token = await _requireToken();
    await api.delete('/review/delete/$id', bearerToken: token);
  }

  Future<void> cancelPayment(String id) async {
    final token = await _requireToken();
    await api.post('/payment/admin/$id/cancel', bearerToken: token);
  }

  Future<void> uploadHotelImage(
    String id,
    List<int> bytes,
    String filename,
  ) async {
    final token = await _requireToken();
    await api.multipart(
      '/properties/upload/cloud/$id',
      method: 'PATCH',
      field: 'image',
      bytes: bytes,
      filename: filename,
      bearerToken: token,
    );
  }

  Future<void> uploadRoomImage(
    String id,
    List<int> bytes,
    String filename,
  ) async {
    final token = await _requireToken();
    await api.multipart(
      '/room/upload/cloud/$id',
      method: 'PATCH',
      field: 'image',
      bytes: bytes,
      filename: filename,
      bearerToken: token,
    );
  }

  Future<void> uploadUserAvatar(
    String id,
    List<int> bytes,
    String filename,
  ) async {
    final token = await _requireToken();
    await api.multipart(
      '/users/avatar/cloud/$id',
      method: 'PATCH',
      field: 'avatar',
      bytes: bytes,
      filename: filename,
      bearerToken: token,
    );
  }

  Future<void> updateUserRole(String userId, String role) async {
    final token = await _requireToken();
    await api.patch(
      '/users/update/$userId',
      bearerToken: token,
      body: {'role': role},
    );
  }

  String _entityId(dynamic response) {
    if (response is Map) {
      final value = response['_id'] ?? response['id'];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    throw ApiException(
      tr(
        'Máy chủ không trả về mã dữ liệu vừa tạo.',
        'The server did not return the newly created record ID.',
      ),
    );
  }

  Future<String> _requireToken() async {
    final token = await AuthService.instance.accessToken();
    if (token == null || token.isEmpty) {
      throw ApiException(
        tr(
          'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          'Your session has expired. Please sign in again.',
        ),
        statusCode: 401,
      );
    }
    return token;
  }

  Future<List<Map<String, dynamic>>> _list(
    String path, {
    String? bearerToken,
  }) async {
    final data = await api.get(path, bearerToken: bearerToken);
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList(growable: false);
    }
    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List).whereType<Map<String, dynamic>>().toList(
        growable: false,
      );
    }
    return const <Map<String, dynamic>>[];
  }
}
