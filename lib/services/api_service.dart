import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Loi API da duoc dich sang ngon ngu nguoi dung doc duoc.
///
/// Truoc day moi loi mang deu noi thang ra snackbar duoi dang
/// "POST http://10.0.2.2:3000/api/booking/create failed: 500 {...}".
/// [message] danh cho nguoi dung, [detail] danh cho log.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.detail});

  final String message;
  final int? statusCode;
  final String? detail;

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;
  bool get isOffline => statusCode == null;

  @override
  String toString() => message;
}

class ApiService {
  const ApiService({
    this.baseUrl = const String.fromEnvironment(
      'STAYZ_API_BASE_URL',
      defaultValue: 'http://10.0.2.2:3000/api',
    ),
  });

  final String baseUrl;

  /// Khong co gioi han nao thi backend treo se lam app quay vo tan.
  static const Duration _connectTimeout = Duration(seconds: 8);
  static const Duration _requestTimeout = Duration(seconds: 20);

  Uri get baseUri => Uri.parse(baseUrl);

  String resolveAssetUrl(String value) {
    if (value.isEmpty) return value;

    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) return value;

    final origin = baseUri.replace(path: '', query: '', fragment: '');
    final path = value.startsWith('/') ? value : '/$value';
    return origin.replace(path: path).toString();
  }

  Future<dynamic> get(String path, {String? bearerToken}) =>
      _send('GET', path, bearerToken: bearerToken);

  Future<dynamic> post(String path, {Map<String, dynamic>? body, String? bearerToken}) =>
      _send('POST', path, body: body, bearerToken: bearerToken);

  Future<dynamic> patch(String path, {Map<String, dynamic>? body, String? bearerToken}) =>
      _send('PATCH', path, body: body, bearerToken: bearerToken);

  Future<dynamic> delete(String path, {String? bearerToken}) =>
      _send('DELETE', path, bearerToken: bearerToken);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? bearerToken,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final client = HttpClient()..connectionTimeout = _connectTimeout;

    try {
      final request = await client.openUrl(method, uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (bearerToken != null && bearerToken.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearerToken');
      }
      if (body != null || method == 'POST' || method == 'PATCH') {
        // Ma hoa body bang UTF-8. Truoc day dung request.write(...) -> ma hoa
        // latin1, khong chua duoc chu tieng Viet co dau (vd "vũng tàu") nen
        // nem "Invalid argument: Contains invalid character". Loi nay lam
        // hong ca chat AI lan gui danh gia co tieng Viet.
        request.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
        request.add(utf8.encode(jsonEncode(body ?? const <String, dynamic>{})));
      }

      final response = await request.close().timeout(_requestTimeout);
      final responseBody = await response.transform(utf8.decoder).join().timeout(_requestTimeout);
      final decoded = responseBody.isEmpty ? null : _tryDecode(responseBody);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _messageFor(response.statusCode, decoded),
          statusCode: response.statusCode,
          detail: '$method $uri -> ${response.statusCode} $responseBody',
        );
      }

      if (decoded is Map<String, dynamic>) {
        return decoded.containsKey('metaData') ? decoded['metaData'] : decoded;
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on SocketException catch (error) {
      throw ApiException(
        'Không kết nối được máy chủ. Kiểm tra kết nối mạng rồi thử lại.',
        detail: '$method $uri -> $error',
      );
    } on TimeoutException catch (error) {
      throw ApiException(
        'Máy chủ phản hồi quá lâu. Vui lòng thử lại.',
        detail: '$method $uri -> $error',
      );
    } on HttpException catch (error) {
      throw ApiException(
        'Không kết nối được máy chủ. Vui lòng thử lại.',
        detail: '$method $uri -> $error',
      );
    } on FormatException catch (error) {
      throw ApiException(
        'Máy chủ trả về dữ liệu không hợp lệ.',
        detail: '$method $uri -> $error',
      );
    } finally {
      client.close(force: true);
    }
  }

  dynamic _tryDecode(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  /// Uu tien thong diep tieng Viet do backend gui ve; neu khong co thi
  /// dich ma trang thai sang cau noi nguoi dung hieu duoc.
  String _messageFor(int statusCode, dynamic decoded) {
    final serverMessage = decoded is Map<String, dynamic> ? decoded['message']?.toString() : null;
    if (serverMessage != null && serverMessage.trim().isNotEmpty) {
      return serverMessage;
    }

    switch (statusCode) {
      case 400:
        return 'Yêu cầu không hợp lệ. Vui lòng kiểm tra lại thông tin.';
      case 401:
        return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
      case 403:
        return 'Bạn không có quyền thực hiện thao tác này.';
      case 404:
        return 'Không tìm thấy dữ liệu.';
      case 429:
        return 'Bạn thao tác quá nhanh. Vui lòng thử lại sau ít phút.';
      default:
        return statusCode >= 500
            ? 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.'
            : 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    }
  }
}
