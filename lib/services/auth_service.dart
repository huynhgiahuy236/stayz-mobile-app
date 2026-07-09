import 'package:capstone_mobile/services/api_service.dart';
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

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_accessTokenKey) ?? '').isNotEmpty;
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
        'role': 'user',
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
      throw StateError('Invalid login response');
    }

    final token = data['accessToken']?.toString() ?? '';
    final user = data['user'];
    if (token.isEmpty || user is! Map<String, dynamic>) {
      throw StateError('Missing login token');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    await prefs.setString(_userIdKey, user['_id']?.toString() ?? '');
    await prefs.setString(_userEmailKey, user['email']?.toString() ?? '');
    await prefs.setString(_userNameKey, user['full_name']?.toString() ?? '');
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await api.post(
      '/users/reset-password',
      body: {
        'email': email.trim().toLowerCase(),
        'newPassword': newPassword,
      },
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
  }
}
