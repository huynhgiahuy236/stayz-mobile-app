import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:flutter/foundation.dart';

/// Dem so thong bao chua doc, dung chung cho chuong o header va man Thong bao.
///
/// Goi `refresh()` khi: mo trang chu, quay lai tu man thong bao, hoac sau khi
/// danh dau da doc. Chuong lang nghe controller nen badge tu cap nhat.
class NotificationsController extends ChangeNotifier {
  NotificationsController._();
  static final NotificationsController instance = NotificationsController._();

  int _unread = 0;
  int get unread => _unread;

  Future<void> refresh() async {
    int next;
    try {
      final list = await ApiStayzRepository.instance.getNotifications();
      next = list.where((item) => item.status == 'unread').length;
    } catch (_) {
      next = 0;
    }
    if (next != _unread) {
      _unread = next;
      notifyListeners();
    }
  }

  void clear() {
    if (_unread == 0) return;
    _unread = 0;
    notifyListeners();
  }
}
