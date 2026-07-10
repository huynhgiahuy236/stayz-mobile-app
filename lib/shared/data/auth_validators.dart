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
    if (trimmed.isEmpty) return 'Vui lòng nhập email.';
    if (!_emailPattern.hasMatch(trimmed)) return 'Email không đúng định dạng.';
    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) return 'Vui lòng nhập mật khẩu.';
    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự.';
    return null;
  }

  static String? confirmPassword(String password, String confirm) {
    if (confirm.isEmpty) return 'Vui lòng nhập lại mật khẩu.';
    if (password != confirm) return 'Mật khẩu nhập lại không khớp.';
    return null;
  }

  static String? fullName(String value) {
    if (value.trim().isEmpty) return 'Vui lòng nhập họ tên.';
    if (value.trim().length < 2) return 'Họ tên quá ngắn.';
    return null;
  }

  /// So dien thoai Viet Nam: 10 chu so bat dau bang 0, hoac dang +84.
  static String? phone(String value) {
    final trimmed = value.trim().replaceAll(' ', '');
    if (trimmed.isEmpty) return 'Vui lòng nhập số điện thoại.';
    if (!RegExp(r'^(0\d{9}|\+84\d{9})$').hasMatch(trimmed)) {
      return 'Số điện thoại không hợp lệ.';
    }
    return null;
  }

  static String? otpCode(String value) {
    final trimmed = value.trim();
    if (trimmed.length != 6 || !RegExp(r'^\d{6}$').hasMatch(trimmed)) {
      return 'Mã xác thực gồm 6 chữ số.';
    }
    return null;
  }
}
