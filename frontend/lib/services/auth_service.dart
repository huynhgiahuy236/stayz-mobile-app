import 'dart:convert';

import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/shared/repositories/booking_cache.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  const AuthService({this.api = const ApiService()});

  static const instance = AuthService();

  static const _hasSeenOnboardingKey = 'hasSeenOnboarding';
  static const _accessTokenKey = 'accessToken';
  static const _secureStorage = FlutterSecureStorage();
  static const _userIdKey = 'authUserId';
  static const _userEmailKey = 'authUserEmail';
  static const _userNameKey = 'authUserName';
  static const _userRoleKey = 'authUserRole';

  final ApiService api;

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }

  /// Kiem tra ca su ton tai LAN han cua token. Truoc day chi kiem tra
  /// token co rong hay khong, nen token het han van dua thang vao trang chu
  /// roi moi API deu tra 401.
  Future<bool> isAuthenticated() async {
    final token = await accessToken();
    if (token == null) return false;
    if (_isExpired(token)) {
      await logout();
      return false;
    }
    return true;
  }

  Future<String?> accessToken() async {
    final secureToken = await _secureStorage.read(key: _accessTokenKey);
    if (secureToken != null && secureToken.isNotEmpty) return secureToken;

    // One-time migration for sessions created before secure storage was added.
    final prefs = await SharedPreferences.getInstance();
    final legacyToken = prefs.getString(_accessTokenKey);
    if (legacyToken == null || legacyToken.isEmpty) return null;
    await _secureStorage.write(key: _accessTokenKey, value: legacyToken);
    await prefs.remove(_accessTokenKey);
    return legacyToken;
  }

  Future<String?> userId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_userIdKey);
    return id == null || id.isEmpty ? null : id;
  }

  Future<String?> userName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_userNameKey);
    return name == null || name.isEmpty ? null : name;
  }

  Future<String?> userRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(_userRoleKey);
    return role == null || role.isEmpty ? null : role;
  }

  Future<bool> hasCurrentAdminAccess() async {
    final id = await userId();
    final token = await accessToken();
    if (id == null || token == null) return false;
    try {
      final data = await api.get('/users/getById/$id', bearerToken: token);
      if (data is! Map<String, dynamic>) return false;
      final role = (data['role']?.toString() ?? 'user').toLowerCase();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userRoleKey, role);
      return role == 'admin';
    } on ApiException {
      return false;
    }
  }

  /// Doc truong `exp` cua JWT ma khong can thu vien ngoai.
  /// Token khong doc duoc thi coi nhu con han: de server quyet dinh.
  bool _isExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      final exp = payload is Map<String, dynamic> ? payload['exp'] : null;
      if (exp is! num) return false;

      final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      return DateTime.now().isAfter(expiresAt);
    } catch (_) {
      return false;
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String registerCode,
  }) async {
    await api.post(
      '/users/create',
      body: {
        'full_name': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'phone_number': phoneNumber.trim(),
        'password': password,
        'register_code': registerCode.trim(),
      },
    );
  }

  Future<void> requestRegisterOtp({required String email}) async {
    await api.post(
      '/users/request-register-otp',
      body: {'email': email.trim().toLowerCase()},
    );
  }

  Future<void> verifyRegisterOtp({
    required String email,
    required String code,
  }) async {
    await api.post(
      '/users/verify-register-otp',
      body: {'email': email.trim().toLowerCase(), 'code': code.trim()},
    );
  }

  Future<void> login({required String email, required String password}) async {
    final data = await api.post(
      '/users/login',
      body: {'email': email.trim().toLowerCase(), 'password': password},
    );

    if (data is! Map<String, dynamic>) {
      throw ApiException(
        tr(
          'Máy chủ trả về dữ liệu đăng nhập không hợp lệ.',
          'The server returned an invalid sign-in response.',
        ),
      );
    }

    final token = data['accessToken']?.toString() ?? '';
    final user = data['user'];
    if (token.isEmpty || user is! Map<String, dynamic>) {
      throw ApiException(
        tr(
          'Đăng nhập không thành công. Vui lòng thử lại.',
          'Sign-in failed. Please try again.',
        ),
      );
    }

    // Doi tai khoan: du lieu cua nguoi truoc phai bien mat.
    BookingCache.clear();

    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.write(key: _accessTokenKey, value: token);
    await prefs.remove(_accessTokenKey);
    await prefs.setString(_userIdKey, user['_id']?.toString() ?? '');
    await prefs.setString(_userEmailKey, user['email']?.toString() ?? '');
    await prefs.setString(_userNameKey, user['full_name']?.toString() ?? '');
    await prefs.setString(
      _userRoleKey,
      (user['role']?.toString() ?? 'user').toLowerCase(),
    );
  }

  /// Buoc 1: gui ma OTP 6 chu so toi email.
  Uri googleLoginUri() {
    final origin = api.baseUri.replace(path: '', query: '', fragment: '');
    return origin.replace(path: '/auth/google');
  }

  Future<void> completeGoogleLogin(Uri callbackUri) async {
    if (callbackUri.scheme != 'stayz' ||
        callbackUri.host != 'auth' ||
        callbackUri.path != '/login-success') {
      throw ApiException(
        tr(
          'Liên kết đăng nhập Google không hợp lệ.',
          'Invalid Google sign-in callback.',
        ),
      );
    }
    final token = callbackUri.queryParameters['accessToken'] ?? '';
    if (token.isEmpty || _isExpired(token)) {
      throw ApiException(
        tr(
          'Phiên đăng nhập Google không hợp lệ hoặc đã hết hạn.',
          'The Google sign-in session is invalid or expired.',
        ),
      );
    }
    final payload = _jwtPayload(token);
    BookingCache.clear();
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.write(key: _accessTokenKey, value: token);
    await prefs.remove(_accessTokenKey);
    await prefs.setString(_userIdKey, payload['userId']?.toString() ?? '');
    await prefs.setString(
      _userEmailKey,
      callbackUri.queryParameters['email'] ?? '',
    );
    await prefs.setString(
      _userNameKey,
      callbackUri.queryParameters['name'] ?? '',
    );
  }

  Map<String, dynamic> _jwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return const {};
      final value = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      return value is Map<String, dynamic> ? value : const {};
    } catch (_) {
      return const {};
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    await api.post(
      '/users/request-password-reset',
      body: {'email': email.trim().toLowerCase()},
    );
  }

  /// Buoc 2: doi chieu ma truoc khi cho nguoi dung nhap mat khau moi.
  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) async {
    await api.post(
      '/users/verify-reset-code',
      body: {'email': email.trim().toLowerCase(), 'code': code.trim()},
    );
  }

  /// Buoc 3: doi mat khau. Bat buoc kem ma OTP - thieu ma la backend tu choi.
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await api.post(
      '/users/reset-password',
      body: {
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
        'newPassword': newPassword,
      },
    );
  }

  Future<void> logout() async {
    // Cache booking la bien static, song lau hon phien dang nhap.
    BookingCache.clear();

    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.delete(key: _accessTokenKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userRoleKey);
  }
}
