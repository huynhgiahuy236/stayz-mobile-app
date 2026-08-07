import 'package:capstone_mobile/shared/i18n/app_locale.dart';

/// Shared validation rules for all authentication forms.
class AuthValidators {
  const AuthValidators._();

  static final _emailPattern = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(?:\.[A-Za-z0-9\-]+)+$',
  );
  static final _namePattern = RegExp(
    r"^[A-Za-zÀ-ÖØ-öø-ÿĀ-ỹĐđ]+(?:[ '\-][A-Za-zÀ-ÖØ-öø-ÿĀ-ỹĐđ]+)*$",
  );
  static final _vietnameseMobilePattern = RegExp(
    r'^(?:03[2-9]|05[25689]|07[06-9]|08[1-9]|09[0-9])\d{7}$',
  );

  static String? email(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return tr('Vui lòng nhập email.', 'Email is required.');
    if (trimmed.contains('..') || !_emailPattern.hasMatch(trimmed)) {
      return tr(
        'Email không đúng định dạng, ví dụ: ten@example.com.',
        'Enter a valid email, for example: name@example.com.',
      );
    }
    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) return tr('Vui lòng nhập mật khẩu.', 'Password is required.');
    if (value.length < 8) {
      return tr('Mật khẩu phải có ít nhất 8 ký tự.', 'Password must contain at least 8 characters.');
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return tr('Mật khẩu cần ít nhất 1 chữ thường.', 'Add at least one lowercase letter.');
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return tr('Mật khẩu cần ít nhất 1 chữ hoa.', 'Add at least one uppercase letter.');
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return tr('Mật khẩu cần ít nhất 1 chữ số.', 'Add at least one number.');
    }
    if (!RegExp(r'[^A-Za-z0-9\s]').hasMatch(value)) {
      return tr('Mật khẩu cần ít nhất 1 ký tự đặc biệt.', 'Add at least one special character.');
    }
    if (RegExp(r'\s').hasMatch(value)) {
      return tr('Mật khẩu không được chứa khoảng trắng.', 'Password cannot contain spaces.');
    }
    return null;
  }

  static String? requiredPassword(String value) => value.isEmpty
      ? tr('Vui lòng nhập mật khẩu.', 'Password is required.')
      : null;

  static String? confirmPassword(String password, String confirm) {
    if (confirm.isEmpty) return tr('Vui lòng nhập lại mật khẩu.', 'Please confirm your password.');
    if (password != confirm) return tr('Mật khẩu nhập lại không khớp.', 'Passwords do not match.');
    return null;
  }

  static String? fullName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return tr('Vui lòng nhập họ tên.', 'Full name is required.');
    if (trimmed.length < 2) return tr('Họ tên quá ngắn.', 'Full name is too short.');
    if (trimmed.length > 50) return tr('Họ tên không được quá 50 ký tự.', 'Full name cannot exceed 50 characters.');
    if (!_namePattern.hasMatch(trimmed)) {
      return tr('Họ tên chỉ được chứa chữ cái, không chứa số.', 'Full name can only contain letters, not numbers.');
    }
    return null;
  }

  static String? phone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return tr('Vui lòng nhập số điện thoại.', 'Phone number is required.');
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return tr('Số điện thoại chỉ được chứa chữ số.', 'Phone number can only contain digits.');
    }
    if (!trimmed.startsWith('0')) {
      return tr('Số điện thoại phải bắt đầu bằng 0.', 'Phone number must start with 0.');
    }
    if (trimmed.length != 10) {
      return tr('Số điện thoại phải có đúng 10 chữ số.', 'Phone number must contain exactly 10 digits.');
    }
    if (!_vietnameseMobilePattern.hasMatch(trimmed)) {
      return tr('Đầu số điện thoại Việt Nam không hợp lệ.', 'Enter a valid Vietnamese mobile prefix.');
    }
    return null;
  }

  static String? otpCode(String value) {
    final trimmed = value.trim();
    if (trimmed.length != 6 || !RegExp(r'^\d{6}$').hasMatch(trimmed)) {
      return tr('Mã xác thực gồm đúng 6 chữ số.', 'Enter the 6-digit verification code.');
    }
    return null;
  }
}
