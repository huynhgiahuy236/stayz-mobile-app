import 'package:capstone_mobile/shared/models/stayz_models.dart';

/// Cache trong bo nho cho nhung booking vua tao/vua doi trang thai, de danh
/// sach cap nhat ngay ma khong phai cho backend.
///
/// Song o file rieng thay vi nam trong repository: `AuthService.logout()` phai
/// xoa duoc cache nay, ma repository lai import `AuthService` - de o day thi
/// tranh duoc vong import.
///
/// Truoc day cache la bien static trong repository va khong bao gio duoc xoa,
/// nen booking cua tai khoan truoc lot sang phien dang nhap sau.
class BookingCache {
  BookingCache._();

  static final Map<String, BookingSummary> _overrides = <String, BookingSummary>{};

  static List<BookingSummary> get all => _overrides.values.toList(growable: false);

  static void put(BookingSummary summary) => _overrides[summary.booking.id] = summary;

  static void clear() => _overrides.clear();

  /// Gop cache vao danh sach tu server, chi giu booking cua dung nguoi dung nay.
  static List<BookingSummary> mergeInto(List<BookingSummary> summaries, {String? userId}) {
    final byId = <String, BookingSummary>{
      for (final summary in summaries) summary.booking.id: summary,
    };

    for (final summary in _overrides.values) {
      final owner = summary.booking.userId;
      if (userId != null && owner.isNotEmpty && owner != userId) continue;
      byId[summary.booking.id] = summary;
    }

    return byId.values.toList(growable: false);
  }
}
