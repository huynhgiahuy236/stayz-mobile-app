import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/admin/models/admin_models.dart';
import 'package:capstone_mobile/features/admin/presentation/widgets/admin_shell.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class AdminOverview extends StatelessWidget {
  const AdminOverview({
    required this.snapshot,
    required this.onStatus,
    this.onAttendance = _ignoreAttendance,
    super.key,
  });
  final AdminSnapshot snapshot;
  final void Function(AdminBooking booking, String status) onStatus;
  final void Function(AdminBooking booking, String status) onAttendance;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LayoutBuilder(
        builder: (_, constraints) {
          final columns = constraints.maxWidth >= 980
              ? 4
              : constraints.maxWidth >= 560
              ? 2
              : 1;
          return GridView.count(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: columns == 1
                ? 124
                : columns == 2
                ? 118
                : 112,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MetricTile(
                icon: Icons.payments_outlined,
                label: tr('Doanh thu đã thu', 'Collected revenue'),
                value: StayzFormatters.fullVnd(snapshot.revenue),
                color: AppTheme.success,
                note: tr(
                  'Từ giao dịch PayOS thành công',
                  'From successful PayOS payments',
                ),
              ),
              MetricTile(
                icon: Icons.calendar_month_outlined,
                label: tr('Tổng booking', 'Total bookings'),
                value: '${snapshot.bookings.length}',
                color: AppTheme.primary,
                note: tr(
                  '${snapshot.countBookings('pending')} đơn chờ xử lý',
                  '${snapshot.countBookings('pending')} pending',
                ),
              ),
              MetricTile(
                icon: Icons.domain_outlined,
                label: tr('Cơ sở lưu trú', 'Properties'),
                value: '${snapshot.hotels.length}',
                color: AppTheme.gold,
                note: tr(
                  '${snapshot.rooms.length} loại phòng',
                  '${snapshot.rooms.length} room types',
                ),
              ),
              MetricTile(
                icon: Icons.group_outlined,
                label: tr('Tài khoản', 'Users'),
                value: '${snapshot.users.length}',
                color: AppTheme.primaryDark,
                note: tr(
                  '${snapshot.reviews.length} đánh giá',
                  '${snapshot.reviews.length} reviews',
                ),
              ),
            ],
          );
        },
      ),
      const SizedBox(height: 24),
      LayoutBuilder(
        builder: (_, constraints) {
          final title = Text(
            tr('Booking gần đây', 'Recent bookings'),
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          );
          final caption = Text(
            tr('Cập nhật theo dữ liệu mới nhất', 'Updated from live data'),
            style: const TextStyle(color: AppTheme.muted, fontSize: 11),
          );
          if (constraints.maxWidth < 420) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 3), caption],
            );
          }
          return Row(
            children: [
              Expanded(child: title),
              caption,
            ],
          );
        },
      ),
      const SizedBox(height: 9),
      AdminBookingsTable(
        bookings: snapshot.recentBookings,
        onStatus: onStatus,
        onAttendance: onAttendance,
      ),
    ],
  );
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.note,
    super.key,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String note;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppTheme.line),
      boxShadow: AppTheme.softShadow,
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                note,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class AdminBookingsTable extends StatelessWidget {
  const AdminBookingsTable({
    required this.bookings,
    required this.onStatus,
    this.onAttendance = _ignoreAttendance,
    this.busyKey,
    this.onAdd,
    this.onEdit,
    this.onDelete,
    super.key,
  });
  final List<AdminBooking> bookings;
  final String? busyKey;
  final void Function(AdminBooking booking, String status) onStatus;
  final void Function(AdminBooking booking, String status) onAttendance;
  final VoidCallback? onAdd;
  final ValueChanged<AdminBooking>? onEdit;
  final ValueChanged<AdminBooking>? onDelete;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return AdminEmptyState(
        icon: Icons.event_busy_outlined,
        title: tr('Không tìm thấy booking', 'No bookings found'),
        actionLabel: onAdd == null ? null : tr('Thêm booking', 'Add booking'),
        onAction: onAdd,
      );
    }
    return TableShell(
      child: AdminDataTable(
        columns: [
          tr('Khách hàng', 'Guest'),
          tr('Cơ sở lưu trú', 'Property'),
          tr('Nhận phòng', 'Check-in'),
          tr('Tổng tiền', 'Total'),
          tr('Thanh toán', 'Payment'),
          tr('Trạng thái', 'Status'),
          tr('Nhận phòng', 'Check-in status'),
          tr('Thao tác', 'Actions'),
        ],
        rows: [
          for (final booking in bookings)
            DataRow(
              cells: [
                DataCell(
                  _PrimaryCell(
                    title: booking.guestName,
                    subtitle: booking.roomName,
                  ),
                ),
                DataCell(CellText(booking.hotelTitle)),
                DataCell(Text(StayzFormatters.shortDate(booking.checkIn))),
                DataCell(
                  Text(
                    StayzFormatters.fullVnd(booking.totalPrice),
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataCell(
                  BookingStatusMenu(
                    status: booking.status,
                    loading: busyKey == 'booking:${booking.id}',
                    enabled:
                        busyKey == null || busyKey == 'booking:${booking.id}',
                    onSelected: (status) => onStatus(booking, status),
                  ),
                ),
                DataCell(StatusPill(status: booking.paymentDisplayStatus)),
                DataCell(
                  AttendanceStatusMenu(
                    status: booking.attendanceStatus,
                    enabled: booking.status == 'confirmed' && busyKey == null,
                    loading: busyKey == 'attendance:${booking.id}',
                    onSelected: (status) => onAttendance(booking, status),
                  ),
                ),
                DataCell(
                  _RowActions(
                    onEdit: onEdit == null ? null : () => onEdit!(booking),
                    onDelete: onDelete == null
                        ? null
                        : () => onDelete!(booking),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

void _ignoreAttendance(AdminBooking _, String _) {}

class AdminHotelsTable extends StatelessWidget {
  const AdminHotelsTable({
    required this.hotels,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });
  final List<AdminHotel> hotels;
  final VoidCallback onAdd;
  final ValueChanged<AdminHotel> onEdit;
  final ValueChanged<AdminHotel> onDelete;

  @override
  Widget build(BuildContext context) {
    if (hotels.isEmpty) {
      return AdminEmptyState(
        icon: Icons.domain_outlined,
        title: tr('Không tìm thấy cơ sở lưu trú', 'No properties found'),
        actionLabel: tr('Thêm cơ sở', 'Add property'),
        onAction: onAdd,
      );
    }
    return TableShell(
      child: AdminDataTable(
        columns: [
          tr('Cơ sở lưu trú', 'Property'),
          tr('Thành phố', 'City'),
          tr('Loại hình', 'Type'),
          tr('Số phòng', 'Rooms'),
          tr('Giá cơ bản', 'Base price'),
          tr('Trạng thái', 'Status'),
          tr('Thao tác', 'Actions'),
        ],
        rows: [
          for (final hotel in hotels)
            DataRow(
              cells: [
                DataCell(
                  _ImageCell(
                    imageUrl: hotel.imageUrl,
                    title: hotel.title,
                    subtitle: hotel.address,
                  ),
                ),
                DataCell(Text(adminOptionLabel(hotel.city))),
                DataCell(Text(adminOptionLabel(hotel.type))),
                DataCell(Text('${hotel.roomCount}')),
                DataCell(
                  Text(
                    StayzFormatters.fullVnd(hotel.basePrice),
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataCell(
                  StatusPill(status: hotel.isActive ? 'active' : 'inactive'),
                ),
                DataCell(
                  _RowActions(
                    onEdit: () => onEdit(hotel),
                    onDelete: () => onDelete(hotel),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class AdminRoomsTable extends StatelessWidget {
  const AdminRoomsTable({
    required this.rooms,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });
  final List<AdminRoom> rooms;
  final VoidCallback onAdd;
  final ValueChanged<AdminRoom> onEdit;
  final ValueChanged<AdminRoom> onDelete;

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return AdminEmptyState(
        icon: Icons.bed_outlined,
        title: tr('Không tìm thấy phòng', 'No rooms found'),
        actionLabel: tr('Thêm phòng', 'Add room'),
        onAction: onAdd,
      );
    }
    return TableShell(
      child: AdminDataTable(
        columns: [
          tr('Phòng', 'Room'),
          tr('Cơ sở lưu trú', 'Property'),
          tr('Loại phòng', 'Type'),
          tr('Sức chứa', 'Capacity'),
          tr('Tồn kho', 'Inventory'),
          tr('Giá bán', 'Selling price'),
          tr('Thao tác', 'Actions'),
        ],
        rows: [
          for (final room in rooms)
            DataRow(
              cells: [
                DataCell(
                  _ImageCell(
                    imageUrl: room.imageUrl,
                    title: room.name,
                    subtitle: room.isActive
                        ? tr('Đang bán', 'Active')
                        : tr('Tạm ẩn', 'Inactive'),
                  ),
                ),
                DataCell(CellText(room.hotelTitle)),
                DataCell(Text(adminOptionLabel(room.roomType))),
                DataCell(Text('${room.capacity} ${tr('khách', 'guests')}')),
                DataCell(Text('${room.quantity}')),
                DataCell(
                  Text(
                    StayzFormatters.fullVnd(room.pricePerNight),
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataCell(
                  _RowActions(
                    onEdit: () => onEdit(room),
                    onDelete: () => onDelete(room),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class AdminUsersTable extends StatelessWidget {
  const AdminUsersTable({
    required this.users,
    required this.onRoleChanged,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.busyKey,
    super.key,
  });
  final List<AdminUser> users;
  final String? busyKey;
  final void Function(AdminUser user, String role) onRoleChanged;
  final VoidCallback onAdd;
  final ValueChanged<AdminUser> onEdit;
  final ValueChanged<AdminUser> onDelete;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return AdminEmptyState(
        icon: Icons.group_outlined,
        title: tr('Không tìm thấy tài khoản', 'No users found'),
        actionLabel: tr('Thêm tài khoản', 'Add user'),
        onAction: onAdd,
      );
    }
    return TableShell(
      child: AdminDataTable(
        columns: [
          tr('Người dùng', 'User'),
          tr('Điện thoại', 'Phone'),
          tr('Vai trò', 'Role'),
          tr('Địa chỉ', 'Address'),
          tr('Ngày tham gia', 'Joined'),
          tr('Trạng thái', 'Status'),
          tr('Thao tác', 'Actions'),
        ],
        rows: [
          for (final user in users)
            DataRow(
              cells: [
                DataCell(_AvatarCell(user: user)),
                DataCell(Text(user.phone.isEmpty ? '-' : user.phone)),
                DataCell(
                  DropdownButton<String>(
                    value: user.role == 'admin' ? 'admin' : 'user',
                    underline: const SizedBox.shrink(),
                    isDense: true,
                    items: [
                      DropdownMenuItem(
                        value: 'user',
                        child: Text(tr('Người dùng', 'User')),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text(tr('Quản trị viên', 'Admin')),
                      ),
                    ],
                    onChanged: busyKey == null
                        ? (role) =>
                              role == null ? null : onRoleChanged(user, role)
                        : null,
                  ),
                ),
                DataCell(CellText(user.address.isEmpty ? '-' : user.address)),
                DataCell(Text(StayzFormatters.shortDate(user.createdAt))),
                DataCell(
                  StatusPill(status: user.isActive ? 'active' : 'inactive'),
                ),
                DataCell(
                  _RowActions(
                    onEdit: () => onEdit(user),
                    onDelete: () => onDelete(user),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class AdminDataTable extends StatelessWidget {
  const AdminDataTable({required this.columns, required this.rows, super.key});
  final List<String> columns;
  final List<DataRow> rows;
  @override
  Widget build(BuildContext context) => DataTable(
    headingRowHeight: 48,
    dataRowMinHeight: 56,
    dataRowMaxHeight: 64,
    horizontalMargin: 20,
    columnSpacing: 28,
    dividerThickness: 0.7,
    headingRowColor: WidgetStateProperty.all(
      AppTheme.primarySoft.withValues(alpha: 0.42),
    ),
    headingTextStyle: const TextStyle(
      color: AppTheme.muted,
      fontSize: 11,
      fontWeight: FontWeight.w800,
    ),
    dataTextStyle: const TextStyle(
      color: AppTheme.muted,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    columns: columns.map((label) => DataColumn(label: Text(label))).toList(),
    rows: rows,
  );
}

class BookingStatusMenu extends StatelessWidget {
  const BookingStatusMenu({
    required this.status,
    required this.onSelected,
    this.enabled = true,
    this.loading = false,
    super.key,
  });
  final String status;
  final bool enabled;
  final bool loading;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return PopupMenuButton<String>(
      enabled: enabled,
      initialValue: status,
      onSelected: onSelected,
      itemBuilder: (_) => (status == 'pending'
              ? const ['pending', 'cancelled']
              : status == 'confirmed'
              ? const ['confirmed', 'cancelled']
              : <String>[status])
          .map(
            (value) => PopupMenuItem(
              value: value,
              child: Text(adminStatusLabel(value)),
            ),
          )
          .toList(),
      child: StatusPill(status: status, showArrow: true),
    );
  }
}

class AttendanceStatusMenu extends StatelessWidget {
  const AttendanceStatusMenu({
    required this.status,
    required this.onSelected,
    this.enabled = true,
    this.loading = false,
    super.key,
  });

  final String status;
  final bool enabled;
  final bool loading;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return PopupMenuButton<String>(
      enabled: enabled,
      initialValue: status,
      onSelected: onSelected,
      itemBuilder: (_) => ['pending', 'checked_in', 'no_show']
          .map(
            (value) => PopupMenuItem(
              value: value,
              child: Text(adminAttendanceLabel(value)),
            ),
          )
          .toList(),
      child: AttendanceStatusPill(status: status, showArrow: enabled),
    );
  }
}

class AttendanceStatusPill extends StatelessWidget {
  const AttendanceStatusPill({
    required this.status,
    this.showArrow = false,
    super.key,
  });
  final String status;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final color = status == 'checked_in'
        ? AppTheme.primaryDark
        : status == 'no_show'
        ? AppTheme.danger
        : AppTheme.notificationPendingText;
    return Tooltip(
      message: adminAttendanceDescription(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.55)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              adminAttendanceLabel(status),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 3),
              Icon(Icons.expand_more_rounded, color: color, size: 15),
            ],
          ],
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({required this.status, this.showArrow = false, super.key});
  final String status;
  final bool showArrow;
  @override
  Widget build(BuildContext context) {
    final normalized = normalizeAdminStatus(status);
    final color = normalized == 'paid' || normalized == 'active'
        ? AppTheme.success
        : normalized == 'deposit_30'
        ? AppTheme.depositText
        : normalized == 'confirmed'
        ? AppTheme.muted
        : normalized == 'completed'
        ? AppTheme.success
        : normalized == 'cancelled' || normalized == 'failed' || normalized == 'inactive'
        ? AppTheme.danger
        : AppTheme.gold;
    return Tooltip(
      message: adminStatusDescription(normalized),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.55)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              adminStatusLabel(status),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 3),
              Icon(Icons.expand_more_rounded, color: color, size: 15),
            ],
          ],
        ),
      ),
    );
  }
}

class _RowActions extends StatelessWidget {
  const _RowActions({this.onEdit, this.onDelete});
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (onEdit != null)
        _ActionIcon(
          icon: Icons.edit_outlined,
          tooltip: tr('Chỉnh sửa', 'Edit'),
          onPressed: onEdit!,
        ),
      if (onDelete != null)
        _ActionIcon(
          icon: Icons.delete_outline_rounded,
          tooltip: tr('Xoá', 'Delete'),
          onPressed: onDelete!,
          color: AppTheme.danger,
        ),
    ],
  );
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 44,
    height: 44,
    child: IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      color: color ?? AppTheme.muted,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

class _PrimaryCell extends StatelessWidget {
  const _PrimaryCell({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 190),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.ink,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppTheme.muted, fontSize: 10),
        ),
      ],
    ),
  );
}

class _ImageCell extends StatelessWidget {
  const _ImageCell({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });
  final String imageUrl;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 38,
          height: 38,
          child: imageUrl.isEmpty
              ? Container(
                  color: const Color(0xFFEAF0F5),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 18,
                    color: AppTheme.muted,
                  ),
                )
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFFEAF0F5),
                    child: const Icon(
                      Icons.broken_image_outlined,
                      size: 18,
                      color: AppTheme.muted,
                    ),
                  ),
                ),
        ),
      ),
      const SizedBox(width: 9),
      _PrimaryCell(title: title, subtitle: subtitle),
    ],
  );
}

class _AvatarCell extends StatelessWidget {
  const _AvatarCell({required this.user});
  final AdminUser user;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 18,
        backgroundColor: AppTheme.primarySoft,
        backgroundImage: user.avatarUrl.isEmpty
            ? null
            : NetworkImage(user.avatarUrl),
        child: user.avatarUrl.isEmpty
            ? Text(
                user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              )
            : null,
      ),
      const SizedBox(width: 9),
      _PrimaryCell(title: user.fullName, subtitle: user.email),
    ],
  );
}

class TableShell extends StatelessWidget {
  const TableShell({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppTheme.line),
      boxShadow: AppTheme.softShadow,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: LayoutBuilder(
        builder: (_, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: child,
          ),
        ),
      ),
    ),
  );
}

class CellText extends StatelessWidget {
  const CellText(this.value, {super.key});
  final String value;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 220),
    child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
  );
}
