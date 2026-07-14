import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/admin/data/admin_repository.dart';
import 'package:capstone_mobile/features/admin/models/admin_models.dart';
import 'package:capstone_mobile/features/admin/presentation/widgets/admin_forms.dart';
import 'package:capstone_mobile/features/admin/presentation/widgets/admin_shell.dart';
import 'package:capstone_mobile/features/admin/presentation/widgets/admin_tables.dart';
import 'package:capstone_mobile/features/admin/presentation/widgets/admin_extra_tables.dart';
import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/widgets/stayz_brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  static const _lastSectionKey = 'admin_last_section';
  final AdminRepository _repository = const AdminRepository();
  final Map<AdminSection, TextEditingController> _searchControllers = {
    for (final section in AdminSection.values) section: TextEditingController(),
  };

  late Future<AdminSnapshot> _future;
  AdminSnapshot? _snapshot;
  AdminSection _section = AdminSection.overview;
  String? _busyKey;

  TextEditingController get _searchController => _searchControllers[_section]!;
  String get _query => _searchController.text;

  @override
  void initState() {
    super.initState();
    _future = _load();
    for (final controller in _searchControllers.values) {
      controller.addListener(_onSearchChanged);
    }
    _restoreLastSection();
  }

  Future<void> _restoreLastSection() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_lastSectionKey);
    final section = AdminSection.values
        .where((item) => item.name == saved)
        .firstOrNull;
    if (section != null && mounted) setState(() => _section = section);
  }

  Future<void> _selectSection(
    AdminSection section, {
    bool clearSearch = false,
  }) async {
    if (clearSearch) _searchControllers[section]!.clear();
    if (mounted) setState(() => _section = section);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_lastSectionKey, section.name);
  }

  @override
  void dispose() {
    for (final controller in _searchControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  Future<AdminSnapshot> _load() async {
    final snapshot = await _repository.loadDashboard();
    _snapshot = snapshot;
    return snapshot;
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() {
      _future = next;
    });
    await next;
  }

  Future<bool> _runAction(String key, Future<void> Function() action) async {
    if (_busyKey != null) return false;
    setState(() => _busyKey = key);
    try {
      await action();
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Đã lưu thay đổi.', 'Changes saved.'))),
      );
      await _refresh();
      return true;
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
      return false;
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  void _goHome() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushNamedAndRemoveUntil(AppRoutes.settings, (route) => false);
    }
  }

  Future<void> _changeBookingStatus(AdminBooking booking, String status) async {
    if (booking.status == status) return;
    if (status == 'cancelled') {
      final confirmed = await _confirmDelete(
        tr(
          'Xác nhận huỷ booking #${booking.id}? Thao tác này có thể phát sinh hoàn tiền thủ công.',
          'Cancel booking #${booking.id}? This action may require a manual refund.',
        ),
      );
      if (confirmed != true) return;
    }
    await _runAction(
      'booking:${booking.id}',
      () => _repository.updateBookingStatus(booking.id, status),
    );
  }

  Future<void> _changeBookingAttendance(
    AdminBooking booking,
    String attendanceStatus,
  ) async {
    if (booking.attendanceStatus == attendanceStatus) return;
    if (attendanceStatus == 'no_show') {
      final confirmed = await _confirmDelete(
        tr(
          'Xác nhận khách không đến nhận phòng? Sau ngày trả phòng, booking sẽ bị hủy và không hoàn tiền.',
          'Confirm that the guest did not check in? After checkout, the booking will be cancelled with no refund.',
        ),
      );
      if (confirmed != true) return;
    }
    await _runAction(
      'attendance:${booking.id}',
      () => _repository.updateBookingAttendance(booking.id, attendanceStatus),
    );
  }

  Future<void> _editHotel({AdminHotel? hotel}) async {
    final input = await showDialog<AdminHotelInput>(
      context: context,
      builder: (context) => HotelFormDialog(hotel: hotel),
    );
    if (input == null) return;
    final saved = await _runAction(
      hotel == null ? 'hotel:create' : 'hotel:${hotel.id}',
      () async {
        final id = await _repository.saveHotel(input, id: hotel?.id);
        if (input.imageBytes != null && input.imageFilename != null) {
          await _repository.uploadHotelImage(
            id,
            input.imageBytes!,
            input.imageFilename!,
          );
        }
      },
    );
    if (saved) await _selectSection(AdminSection.hotels, clearSearch: true);
  }

  Future<void> _editRoom({AdminRoom? room}) async {
    final hotels = _snapshot?.hotels ?? const <AdminHotel>[];
    if (hotels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Hãy tạo cơ sở lưu trú trước khi thêm phòng.',
              'Create a property before adding rooms.',
            ),
          ),
        ),
      );
      return;
    }
    final input = await showDialog<AdminRoomInput>(
      context: context,
      builder: (context) => RoomFormDialog(room: room, hotels: hotels),
    );
    if (input == null) return;
    final saved = await _runAction(
      room == null ? 'room:create' : 'room:${room.id}',
      () async {
        final id = await _repository.saveRoom(input, id: room?.id);
        if (input.imageBytes != null && input.imageFilename != null) {
          await _repository.uploadRoomImage(
            id,
            input.imageBytes!,
            input.imageFilename!,
          );
        }
      },
    );
    if (saved && mounted) {
      await _selectSection(AdminSection.rooms, clearSearch: true);
    }
  }

  Future<void> _editUser({AdminUser? user}) async {
    final input = await showDialog<AdminUserInput>(
      context: context,
      builder: (_) => UserFormDialog(user: user),
    );
    if (input == null) return;
    final saved = await _runAction(
      user == null ? 'user:create' : 'user:${user.id}',
      () async {
        final id = await _repository.saveUser(input, id: user?.id);
        if (input.imageBytes != null && input.imageFilename != null) {
          await _repository.uploadUserAvatar(
            id,
            input.imageBytes!,
            input.imageFilename!,
          );
        }
      },
    );
    if (saved) await _selectSection(AdminSection.users, clearSearch: true);
  }

  Future<void> _deleteUser(AdminUser user) async {
    if (await _confirmDelete(
          tr('Xoá tài khoản ${user.fullName}?', 'Delete ${user.fullName}?'),
        ) !=
        true) {
      return;
    }
    await _runAction(
      'user:delete:${user.id}',
      () => _repository.deleteUser(user.id),
    );
  }

  Future<void> _editBooking({AdminBooking? booking}) async {
    final data = _snapshot;
    if (data == null ||
        data.users.isEmpty ||
        data.hotels.isEmpty ||
        data.rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Cần có tài khoản, cơ sở lưu trú và phòng trước khi tạo booking.',
              'Users, properties and rooms are required before creating a booking.',
            ),
          ),
        ),
      );
      return;
    }
    final input = await showDialog<AdminBookingInput>(
      context: context,
      builder: (_) => BookingFormDialog(
        users: data.users,
        hotels: data.hotels,
        rooms: data.rooms,
        booking: booking,
      ),
    );
    if (input == null) return;
    final saved = await _runAction(
      booking == null ? 'booking:create' : 'booking:${booking.id}',
      () => _repository.saveBooking(input, id: booking?.id),
    );
    if (saved) await _selectSection(AdminSection.bookings, clearSearch: true);
  }

  Future<void> _deleteBooking(AdminBooking booking) async {
    if (await _confirmDelete(
          tr('Xoá booking #${booking.id}?', 'Delete booking #${booking.id}?'),
        ) !=
        true) {
      return;
    }
    await _runAction(
      'booking:delete:${booking.id}',
      () => _repository.deleteBooking(booking.id),
    );
  }

  Future<void> _deleteReview(AdminReview review) async {
    if (await _confirmDelete(
          tr(
            'Xoá đánh giá của ${review.userName}?',
            'Delete ${review.userName}\'s review?',
          ),
        ) !=
        true) {
      return;
    }
    await _runAction(
      'review:delete:${review.id}',
      () => _repository.deleteReview(review.id),
    );
  }

  Future<void> _cancelPayment(AdminPayment payment) async {
    if (await _confirmDelete(
          tr(
            'Huỷ giao dịch PayOS #${payment.orderCode}?',
            'Cancel PayOS transaction #${payment.orderCode}?',
          ),
        ) !=
        true) {
      return;
    }
    await _runAction(
      'payment:${payment.id}',
      () => _repository.cancelPayment(payment.id),
    );
  }

  Future<void> _deleteHotel(AdminHotel hotel) async {
    if (await _confirmDelete(
          tr(
            'Xoá cơ sở lưu trú ${hotel.title}?',
            'Delete property ${hotel.title}?',
          ),
        ) !=
        true) {
      return;
    }
    await _runAction(
      'hotel:delete:${hotel.id}',
      () => _repository.deleteHotel(hotel.id),
    );
  }

  Future<void> _deleteRoom(AdminRoom room) async {
    if (await _confirmDelete(
          tr('Xoá phòng ${room.name}?', 'Delete room ${room.name}?'),
        ) !=
        true) {
      return;
    }
    await _runAction(
      'room:delete:${room.id}',
      () => _repository.deleteRoom(room.id),
    );
  }

  Future<void> _updateUserRole(AdminUser user, String role) async {
    if (user.role == role) return;
    final confirmed = await _confirmDelete(
      tr(
        'Đổi vai trò của ${user.fullName} thành ${role == 'admin' ? 'quản trị viên' : 'người dùng'}?',
        'Change ${user.fullName} to ${role == 'admin' ? 'administrator' : 'user'}?',
      ),
    );
    if (confirmed != true) return;
    await _runAction(
      'user:${user.id}',
      () => _repository.updateUserRole(user.id, role),
    );
  }

  Future<bool?> _confirmDelete(String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr('Xác nhận thao tác', 'Confirm action')),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr('Huỷ', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            child: Text(tr('Xác nhận', 'Confirm')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: AppLocale.instance,
    builder: (context, _) => _buildDashboard(context),
  );

  Widget _buildDashboard(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: FutureBuilder<AdminSnapshot>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                _snapshot == null) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StayZBrandLogo(size: 72, borderRadius: 20),
                    SizedBox(height: 18),
                    CircularProgressIndicator(color: AppTheme.primary),
                  ],
                ),
              );
            }
            if (snapshot.hasError && _snapshot == null) {
              final error = snapshot.error;
              final message = error is ApiException
                  ? error.message
                  : tr(
                      'Không thể tải dữ liệu quản trị.',
                      'Unable to load admin data.',
                    );
              return Center(child: Text(message));
            }

            final data = _snapshot ?? snapshot.data!;
            final wide = MediaQuery.sizeOf(context).width >= 980;
            return Row(
              children: [
                if (wide)
                  AdminSideNav(
                    selected: _section,
                    onSelect: _selectSection,
                    onHome: _goHome,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      AdminHeader(
                        section: _section,
                        searchController: _searchController,
                        onRefresh: _refresh,
                        onLogout: _logout,
                        onHome: _goHome,
                        onAdd: _section == AdminSection.hotels
                            ? () => _editHotel()
                            : _section == AdminSection.rooms
                            ? () => _editRoom()
                            : _section == AdminSection.users
                            ? () => _editUser()
                            : _section == AdminSection.bookings
                            ? () => _editBooking()
                            : null,
                      ),
                      if (!wide)
                        AdminTopTabs(
                          selected: _section,
                          onSelect: _selectSection,
                        ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refresh,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              wide ? 24 : 16,
                              12,
                              wide ? 24 : 16,
                              32,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_visibleLoadErrors(data).isNotEmpty) ...[
                                  _AdminLoadErrorCard(
                                    messages: _visibleLoadErrors(data),
                                    onRetry: _refresh,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                _content(data),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<String> _visibleLoadErrors(AdminSnapshot data) {
    if (_section == AdminSection.overview) {
      return data.loadErrors.values.toList(growable: false);
    }
    final key = switch (_section) {
      AdminSection.overview => '',
      AdminSection.bookings => 'bookings',
      AdminSection.hotels => 'hotels',
      AdminSection.rooms => 'rooms',
      AdminSection.users => 'users',
      AdminSection.reviews => 'reviews',
      AdminSection.payments => 'payments',
    };
    final message = data.loadErrors[key];
    return message == null ? const [] : [message];
  }

  Widget _content(AdminSnapshot data) {
    switch (_section) {
      case AdminSection.overview:
        return AdminOverview(
          snapshot: data,
          onStatus: _changeBookingStatus,
          onAttendance: _changeBookingAttendance,
        );
      case AdminSection.bookings:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton.icon(
              onPressed: () async {
                await Navigator.of(context).pushNamed(AppRoutes.adminCheckIn);
                await _refresh();
              },
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: Text(
                tr('Quét / nhập mã nhận phòng', 'Scan / enter check-in code'),
              ),
            ),
            const SizedBox(height: 16),
            AdminBookingsTable(
              bookings: data.filterBookings(_query),
              busyKey: _busyKey,
              onStatus: _changeBookingStatus,
              onAttendance: _changeBookingAttendance,
              onAdd: () => _editBooking(),
              onEdit: (booking) => _editBooking(booking: booking),
              onDelete: _deleteBooking,
            ),
          ],
        );
      case AdminSection.hotels:
        return AdminHotelsTable(
          hotels: data.filterHotels(_query),
          onAdd: () => _editHotel(),
          onEdit: (hotel) => _editHotel(hotel: hotel),
          onDelete: _deleteHotel,
        );
      case AdminSection.rooms:
        return AdminRoomsTable(
          rooms: data.filterRooms(_query),
          onAdd: () => _editRoom(),
          onEdit: (room) => _editRoom(room: room),
          onDelete: _deleteRoom,
        );
      case AdminSection.users:
        return AdminUsersTable(
          users: data.filterUsers(_query),
          busyKey: _busyKey,
          onRoleChanged: _updateUserRole,
          onAdd: () => _editUser(),
          onEdit: (user) => _editUser(user: user),
          onDelete: _deleteUser,
        );
      case AdminSection.reviews:
        return AdminReviewsTable(
          reviews: data.filterReviews(_query),
          onDelete: _deleteReview,
        );
      case AdminSection.payments:
        return AdminPaymentsTable(
          payments: data.filterPayments(_query),
          onCancel: _cancelPayment,
        );
    }
  }
}

class _AdminLoadErrorCard extends StatelessWidget {
  const _AdminLoadErrorCard({required this.messages, required this.onRetry});

  final List<String> messages;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Card(
    color: AppTheme.danger.withValues(alpha: 0.08),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppTheme.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              messages.toSet().join('\n'),
              style: const TextStyle(color: AppTheme.danger),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(tr('Thử lại', 'Retry')),
          ),
        ],
      ),
    ),
  );
}
