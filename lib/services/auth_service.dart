import 'dart:convert';

import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/shared/repositories/booking_cache.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  const AuthService({this.api = const ApiService()});

  static const instance = AuthService();

  static const _hasSeenOnboardingKey = 'hasSeenOnboarding';
  static const _accessTokenKey = 'accessToken';
  static const _userIdKey = 'authUserId';
  static const _userEmailKey = 'authUserEmail';
  static const _userNameKey = 'authUserName';

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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    return token == null || token.isEmpty ? null : token;
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
  }) async {
    await api.post(
      '/users/create',
      body: {
        'full_name': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'phone_number': phoneNumber.trim(),
        'password': password,
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final data = await api.post(
      '/users/login',
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    if (data is! Map<String, dynamic>) {
      throw ApiException(tr('Máy chủ trả về dữ liệu đăng nhập không hợp lệ.', 'The server returned an invalid sign-in response.'));
    }

    final token = data['accessToken']?.toString() ?? '';
    final user = data['user'];
    if (token.isEmpty || user is! Map<String, dynamic>) {
      throw ApiException(tr('Đăng nhập không thành công. Vui lòng thử lại.', 'Sign-in failed. Please try again.'));
    }

    // Doi tai khoan: du lieu cua nguoi truoc phai bien mat.
    BookingCache.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    await prefs.setString(_userIdKey, user['_id']?.toString() ?? '');
    await prefs.setString(_userEmailKey, user['email']?.toString() ?? '');
    await prefs.setString(_userNameKey, user['full_name']?.toString() ?? '');
  }

  /// Buoc 1: gui ma OTP 6 chu so toi email.
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
      body: {
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
      },
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
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
  }
}
