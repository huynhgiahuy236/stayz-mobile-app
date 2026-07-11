import 'package:capstone_mobile/shared/i18n/app_locale.dart';

/// Kiem tra dau vao cua cac man xac thuc.
///
/// Truoc day moi man chi kiem tra chuoi rong, nen email sai dinh dang van
/// duoc gui thang len server va nguoi dung nhan ve mot loi kho hieu.
class AuthValidators {
  const AuthValidators._();

  // Du dung cho email thuc te: co phan truoc @, ten mien, va TLD >= 2 ky tu.
  static final _emailPattern = RegExp(r'^[\w.!#$%&*+/=?^`{|}~-]+@[\w-]+(\.[\w-]+)+$');

  /// Tra ve `null` khi hop le, nguoc lai la thong diep loi hien cho nguoi dung.
  static String? email(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return tr('Vui lòng nhập email.', 'Email is required.');
    if (!_emailPattern.hasMatch(trimmed)) return tr('Email không đúng định dạng.', 'Enter a valid email address.');
    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) return tr('Vui lòng nhập mật khẩu.', 'Password is required.');
    if (value.length < 6) return tr('Mật khẩu phải có ít nhất 6 ký tự.', 'Password must contain at least 6 characters.');
    return null;
  }

  static String? confirmPassword(String password, String confirm) {
    if (confirm.isEmpty) return tr('Vui lòng nhập lại mật khẩu.', 'Please confirm your password.');
    if (password != confirm) return tr('Mật khẩu nhập lại không khớp.', 'Passwords do not match.');
    return null;
  }

  static String? fullName(String value) {
    if (value.trim().isEmpty) return tr('Vui lòng nhập họ tên.', 'Full name is required.');
    if (value.trim().length < 2) return tr('Họ tên quá ngắn.', 'Full name is too short.');
    return null;
  }

  /// So dien thoai Viet Nam: 10 chu so bat dau bang 0, hoac dang +84.
  static String? phone(String value) {
    final trimmed = value.trim().replaceAll(' ', '');
    if (trimmed.isEmpty) return tr('Vui lòng nhập số điện thoại.', 'Phone number is required.');
    if (!RegExp(r'^(0\d{9}|\+84\d{9})$').hasMatch(trimmed)) {
      return tr('Số điện thoại không hợp lệ.', 'Enter a valid phone number.');
    }
    return null;
  }

  static String? otpCode(String value) {
    final trimmed = value.trim();
    if (trimmed.length != 6 || !RegExp(r'^\d{6}$').hasMatch(trimmed)) {
      return tr('Mã xác thực gồm 6 chữ số.', 'Enter the 6-digit verification code.');
    }
    return null;
  }
}
