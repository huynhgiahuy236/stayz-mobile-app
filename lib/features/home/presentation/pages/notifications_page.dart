import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/notifications/notifications_controller.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/stayz_state_views.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<StayzNotification> _items = const [];
  bool _loading = true;
  Object? _error;
  bool _busy = false;

  // Che do chon nhieu de xoa.
  bool _selectionMode = false;
  final Set<String> _selected = <String>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await ApiStayzRepository.instance.getNotifications();
      if (!mounted) return;
      setState(() {
        _items = items;
        _error = null;
        _loading = false;
      });
      NotificationsController.instance.refresh();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ApiStayzRepository.instance.markAllNotificationsRead();
      if (!mounted) return;
      NotificationsController.instance.clear();
      await _load();
      _showSnack(tr('Đã đánh dấu tất cả là đã đọc.', 'Marked all as read.'));
    } on ApiException catch (error) {
      _showSnack(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteOne(StayzNotification item) async {
    // Xoa lac quan: bo khoi danh sach ngay, hoan lai neu that bai.
    final index = _items.indexOf(item);
    setState(() => _items = List.of(_items)..remove(item));
    try {
      await ApiStayzRepository.instance.deleteNotification(item.id);
      NotificationsController.instance.refresh();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(
        () =>
            _items = List.of(_items)
              ..insert(index.clamp(0, _items.length), item),
      );
      _showSnack(error.message);
    }
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty || _busy) return;
    final ids = _selected.toList();
    setState(() => _busy = true);
    try {
      await ApiStayzRepository.instance.deleteNotifications(ids);
      if (!mounted) return;
      setState(() {
        _items = _items.where((n) => !_selected.contains(n.id)).toList();
        _selected.clear();
        _selectionMode = false;
      });
      NotificationsController.instance.refresh();
      _showSnack(
        tr(
          'Đã xoá ${ids.length} thông báo.',
          'Deleted ${ids.length} notifications.',
        ),
      );
    } on ApiException catch (error) {
      _showSnack(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toggleSelect(String id) {
    setState(() {
      _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
      if (_selected.isEmpty) _selectionMode = false;
    });
  }

  void _enterSelection(String id) {
    setState(() {
      _selectionMode = true;
      _selected.add(id);
    });
  }

  void _selectAll() {
    setState(() {
      if (_selected.length == _items.length) {
        _selected.clear();
        _selectionMode = false;
      } else {
        _selected
          ..clear()
          ..addAll(_items.map((n) => n.id));
      }
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openNotification(StayzNotification item) async {
    if (item.status == 'unread') {
      final index = _items.indexWhere((notification) => notification.id == item.id);
      if (index >= 0) {
        final updated = StayzNotification(
          id: item.id,
          userId: item.userId,
          type: item.type,
          event: item.event,
          title: item.title,
          message: item.message,
          referenceType: item.referenceType,
          referenceId: item.referenceId,
          status: 'read',
          createdAt: item.createdAt,
        );
        setState(() {
          final next = List<StayzNotification>.of(_items);
          next[index] = updated;
          _items = next;
        });
        NotificationsController.instance.readOne();
        try {
          await ApiStayzRepository.instance.markNotificationRead(item.id);
        } on ApiException catch (error) {
          if (!mounted) return;
          setState(() {
            final next = List<StayzNotification>.of(_items);
            final currentIndex = next.indexWhere(
              (notification) => notification.id == item.id,
            );
            if (currentIndex >= 0) next[currentIndex] = item;
            _items = next;
          });
          NotificationsController.instance.refresh();
          _showSnack(error.message);
          return;
        }
      }
    }
    if (!mounted) return;
    if (item.referenceType == 'Booking' && item.referenceId.isNotEmpty) {
      Navigator.of(
        context,
      ).pushNamed(AppRoutes.myBookings, arguments: item.referenceId);
      return;
    }
    if (item.referenceType == 'Property' && item.referenceId.isNotEmpty) {
      Navigator.of(context).pushNamed(AppRoutes.search);
      return;
    }
    _showSnack(
      tr(
        'Thông báo này không có nội dung điều hướng.',
        'This notification has no linked destination.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: _selectionMode
          ? null
          : const StayZBottomNav(activeTab: HomeTab.profile),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(responsive),
            Divider(
              color: AppTheme.neutral200.withValues(alpha: 0.7),
              height: 1,
            ),
            SizedBox(height: 12 * responsive.scale),
            Expanded(child: _buildBody(responsive)),
          ],
        ),
      ),
      // Thanh xoa khi dang chon nhieu.
      floatingActionButton: _selectionMode && _selected.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _busy ? null : _deleteSelected,
              backgroundColor: AppTheme.danger,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
              ),
              label: Text(
                tr('Xoá (${_selected.length})', 'Delete (${_selected.length})'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(HomeResponsive responsive) {
    final allSelected = _items.isNotEmpty && _selected.length == _items.length;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        responsive.horizontalPadding,
        14 * responsive.scale,
        responsive.horizontalPadding,
        14 * responsive.scale,
      ),
      child: Row(
        children: [
          _CircleIconButton(
            icon: _selectionMode
                ? Icons.close_rounded
                : Icons.arrow_back_rounded,
            onTap: () {
              if (_selectionMode) {
                setState(() {
                  _selectionMode = false;
                  _selected.clear();
                });
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
          SizedBox(width: 12 * responsive.widthScale),
          Expanded(
            child: Text(
              _selectionMode
                  ? tr(
                      'Đã chọn ${_selected.length}',
                      '${_selected.length} selected',
                    )
                  : tr('Thông báo', 'Notifications'),
              style: TextStyle(
                fontFamily: 'Noto Serif JP',
                color: AppTheme.accentDark,
                fontSize: 26 * responsive.scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (_selectionMode)
            TextButton(
              onPressed: _selectAll,
              child: Text(
                allSelected
                    ? tr('Bỏ chọn', 'Clear')
                    : tr('Chọn tất cả', 'Select all'),
              ),
            )
          else if (_items.isNotEmpty) ...[
            _CircleIconButton(
              icon: Icons.checklist_rounded,
              tooltip: tr('Chọn để xoá', 'Select to delete'),
              onTap: () => setState(() => _selectionMode = true),
            ),
            SizedBox(width: 8 * responsive.widthScale),
            _CircleIconButton(
              icon: Icons.done_all_rounded,
              tooltip: tr('Đánh dấu tất cả là đã đọc', 'Mark all as read'),
              onTap: _busy ? null : _markAllRead,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(HomeResponsive responsive) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      );
    }
    if (_error != null) {
      return StayzErrorView(error: _error, onRetry: _load);
    }
    if (_items.isEmpty) {
      return StayzEmptyView(
        icon: Icons.notifications_none_rounded,
        title: tr('Chưa có thông báo', 'No notifications'),
        message: tr(
          'Thông báo về đặt phòng và ưu đãi sẽ xuất hiện tại đây.',
          'Booking and offer updates will appear here.',
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        responsive.horizontalPadding,
        4 * responsive.scale,
        responsive.horizontalPadding,
        90 * responsive.scale,
      ),
      itemCount: _items.length,
      separatorBuilder: (_, _) => SizedBox(height: 14 * responsive.scale),
      itemBuilder: (context, index) {
        final item = _items[index];
        final visual = _notificationVisual(item);
        final selected = _selected.contains(item.id);

        final card = NotificationCard(
          icon: visual.icon,
          iconColor: visual.foreground,
          borderColor: visual.border,
          statusLabel: visual.label,
          title: item.title,
          body: item.message,
          time: _notificationTime(item.createdAt),
          unread: item.status == 'unread',
        );

        if (_selectionMode) {
          return InkWell(
            onTap: () => _toggleSelect(item.id),
            borderRadius: BorderRadius.circular(18),
            child: Row(
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (_) => _toggleSelect(item.id),
                  activeColor: AppTheme.primary,
                ),
                Expanded(child: IgnorePointer(child: card)),
              ],
            ),
          );
        }

        // Vuot sang trai de xoa 1 thong bao.
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: AppTheme.danger,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
            ),
          ),
          onDismissed: (_) => _deleteOne(item),
          child: GestureDetector(
            onLongPress: () => _enterSelection(item.id),
            onTap: () => _openNotification(item),
            child: card,
          ),
        );
      },
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppTheme.accentDark, size: 20),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size(42, 42),
        side: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.6)),
      ),
    );
  }
}

({IconData icon, Color border, Color foreground, String label})
_notificationVisual(StayzNotification item) {
  final title = item.title.toLowerCase();
  final content = '$title ${item.message.toLowerCase()}';

  final structuredVisual = switch (item.event) {
    'awaiting_payment' => (
      icon: Icons.schedule_rounded,
      border: AppTheme.notificationPendingBorder,
      foreground: AppTheme.notificationPendingText,
      label: tr('Chờ thanh toán', 'Awaiting payment'),
    ),
    'pending' => (
      icon: Icons.schedule_rounded,
      border: AppTheme.notificationPendingBorder,
      foreground: AppTheme.notificationPendingText,
      label: tr('Chờ xử lý', 'Pending'),
    ),
    'confirmed' => (
      icon: Icons.verified_outlined,
      border: AppTheme.notificationConfirmedBorder,
      foreground: AppTheme.notificationConfirmedText,
      label: tr('Đã xác nhận', 'Confirmed'),
    ),
    'deposit_paid' => (
      icon: Icons.savings_outlined,
      border: AppTheme.depositBorder,
      foreground: AppTheme.depositText,
      label: tr('Đã cọc 30%', '30% deposit'),
    ),
    'paid_in_full' => (
      icon: Icons.check_circle_outline_rounded,
      border: AppTheme.notificationSuccessBorder,
      foreground: AppTheme.notificationSuccessText,
      label: tr('Đã thanh toán đủ', 'Paid in full'),
    ),
    'checked_in' => (
      icon: Icons.login_rounded,
      border: AppTheme.notificationConfirmedBorder,
      foreground: AppTheme.notificationConfirmedText,
      label: tr('Đã nhận phòng', 'Checked in'),
    ),
    'no_show' => (
      icon: Icons.person_off_outlined,
      border: AppTheme.notificationDangerBorder,
      foreground: AppTheme.notificationDangerText,
      label: tr('Không đến nhận phòng', 'No-show'),
    ),
    'cancelled' => (
      icon: Icons.cancel_outlined,
      border: AppTheme.notificationDangerBorder,
      foreground: AppTheme.notificationDangerText,
      label: tr('Đã hủy', 'Cancelled'),
    ),
    'expired' => (
      icon: Icons.timer_off_outlined,
      border: AppTheme.notificationDangerBorder,
      foreground: AppTheme.notificationDangerText,
      label: tr('Đã hết hạn', 'Expired'),
    ),
    'completed' => (
      icon: Icons.check_circle_outline_rounded,
      border: AppTheme.notificationSuccessBorder,
      foreground: AppTheme.notificationSuccessText,
      label: tr('Hoàn tất', 'Completed'),
    ),
    _ => null,
  };
  if (structuredVisual != null) return structuredVisual;

  if (content.contains('không đến') || content.contains('no-show')) {
    return (
      icon: Icons.person_off_outlined,
      border: AppTheme.notificationDangerBorder,
      foreground: AppTheme.notificationDangerText,
      label: tr('Không đến nhận phòng', 'No-show'),
    );
  }

  if (content.contains('hủy') || content.contains('cancel')) {
    return (
      icon: Icons.cancel_outlined,
      border: AppTheme.notificationDangerBorder,
      foreground: AppTheme.notificationDangerText,
      label: tr('Đã hủy', 'Cancelled'),
    );
  }

  if (content.contains('hết hạn') || content.contains('expired')) {
    return (
      icon: Icons.timer_off_outlined,
      border: AppTheme.notificationDangerBorder,
      foreground: AppTheme.notificationDangerText,
      label: tr('Đã hết hạn', 'Expired'),
    );
  }

  // Check actionable/pending states before success. For example, the English
  // sentence "complete your payment" must never be classified as completed.
  if (title.contains('chờ') ||
      title.contains('await') ||
      title.contains('pending') ||
      title.contains('xử lý') ||
      title.contains('processing')) {
    return (
      icon: Icons.schedule_rounded,
      border: AppTheme.notificationPendingBorder,
      foreground: AppTheme.notificationPendingText,
      label: content.contains('thanh toán') || content.contains('payment')
          ? tr('Chờ thanh toán', 'Awaiting payment')
          : tr('Chờ xử lý', 'Pending'),
    );
  }

  if (title.contains('nhận phòng') || title.contains('check-in')) {
    return (
      icon: Icons.login_rounded,
      border: AppTheme.notificationConfirmedBorder,
      foreground: AppTheme.notificationConfirmedText,
      label: tr('Đã nhận phòng', 'Checked in'),
    );
  }

  if (content.contains('30%') ||
      content.contains('đặt cọc') ||
      content.contains('deposit')) {
    return (
      icon: Icons.savings_outlined,
      border: AppTheme.depositBorder,
      foreground: AppTheme.depositText,
      label: tr('Đã cọc 30%', '30% deposit'),
    );
  }

  if (content.contains('100%') ||
      content.contains('toàn bộ') ||
      content.contains('paid in full')) {
    return (
      icon: Icons.check_circle_outline_rounded,
      border: AppTheme.notificationSuccessBorder,
      foreground: AppTheme.notificationSuccessText,
      label: tr('Đã thanh toán đủ', 'Paid in full'),
    );
  }

  if (title.contains('xác nhận') || title.contains('confirmed')) {
    return (
      icon: Icons.verified_outlined,
      border: AppTheme.notificationConfirmedBorder,
      foreground: AppTheme.notificationConfirmedText,
      label: tr('Đã xác nhận', 'Confirmed'),
    );
  }

  if (content.contains('hoàn thành') ||
      title.contains('completed') ||
      content.contains('complete') ||
      content.contains('thành công') ||
      title.contains('successful')) {
    return (
      icon: Icons.check_circle_outline_rounded,
      border: AppTheme.notificationSuccessBorder,
      foreground: AppTheme.notificationSuccessText,
      label: tr('Hoàn tất', 'Completed'),
    );
  }

  if (item.type == 'promotion') {
    return (
      icon: Icons.local_offer_outlined,
      border: AppTheme.notificationOfferBorder,
      foreground: AppTheme.notificationOfferText,
      label: tr('Ưu đãi', 'Offer'),
    );
  }

  return (
    icon: Icons.info_outline_rounded,
    border: AppTheme.notificationInfoBorder,
    foreground: AppTheme.accentDark,
    label: tr('Thông tin', 'Information'),
  );
}

String _notificationTime(DateTime createdAt) {
  final age = DateTime.now().difference(createdAt);
  if (age.inDays > 0) {
    return tr('${age.inDays} ngày trước', '${age.inDays}d ago');
  }
  if (age.inHours > 0) {
    return tr('${age.inHours} giờ trước', '${age.inHours}h ago');
  }
  if (age.inMinutes > 0) {
    return tr('${age.inMinutes} phút trước', '${age.inMinutes}m ago');
  }
  return tr('Vừa xong', 'Just now');
}
