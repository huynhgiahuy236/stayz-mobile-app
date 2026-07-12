import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/data/stayz_taxonomy.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/stayz_state_views.dart';
import 'package:flutter/material.dart';

class RealRoomSelectionPage extends StatefulWidget {
  const RealRoomSelectionPage({super.key});

  @override
  State<RealRoomSelectionPage> createState() => _RealRoomSelectionPageState();
}

class _RealRoomSelectionPageState extends State<RealRoomSelectionPage> {
  RoomSelectionArgs? _args;
  Future<List<Room>>? _roomsFuture;
  bool _initialized = false;

  int _guestCount = 2;
  int _roomCount = 1;
  String _roomType = 'all';
  bool _availableOnly = true;
  bool _filtersOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    _args = args is RoomSelectionArgs ? args : null;

    if (_args != null) {
      _guestCount = (_args!.adults + _args!.children).clamp(1, 20);
      _roomCount = _args!.roomCount;
      // Gan thang, khong setState: didChangeDependencies chay trong luc dung widget.
      _roomsFuture = _fetchRooms();
    }
  }

  Future<List<Room>> _fetchRooms() {
    return ApiStayzRepository.instance.getRoomsByHotelId(
      _args!.hotel.hotel.id,
      checkInDate: _args!.checkInDate,
      checkOutDate: _args!.checkOutDate,
    );
  }

  /// Dung cho nut "Thu lai" - luc nay da qua giai doan dung nen setState hop le.
  void _loadRooms() {
    setState(() {
      _roomsFuture = _fetchRooms();
    });
  }

  /// Suc chua lon nhat trong danh sach phong: dung de chan nut cong so khach
  /// khi da cham tran, thay vi kep im lang.
  int _maxGuests(List<Room> rooms) {
    if (rooms.isEmpty) return 20;
    final maxCapacity = rooms
        .map((room) => room.capacityAdults + room.capacityChildren)
        .fold<int>(1, (a, b) => a > b ? a : b);
    return (maxCapacity * _roomCount).clamp(1, 40);
  }

  List<Room> _filterRooms(List<Room> rooms) {
    return rooms
        .where((room) {
          final capacity = room.capacityAdults + room.capacityChildren;
          final capacityOk = capacity * _roomCount >= _guestCount;
          final typeOk = _roomType == 'all' || room.roomType == _roomType;
          final availableOk =
              !_availableOnly || room.availableUnits >= _roomCount;
          return capacityOk &&
              typeOk &&
              availableOk &&
              room.status != 'inactive';
        })
        .toList(growable: false);
  }

  BookingDraft _draftFor(HotelSummary hotel, Room room) {
    final args = _args!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkIn = args.hasDates ? args.checkInDate! : today;
    final checkOut = args.hasDates
        ? args.checkOutDate!
        : today.add(const Duration(days: 1));

    final maxGuests =
        ((room.capacityAdults + room.capacityChildren) * _roomCount).clamp(
          1,
          999,
        );
    final guests = _guestCount.clamp(1, maxGuests);

    return BookingDraft(
      hotel: hotel,
      room: room,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      adults: guests,
      children: 0,
      roomCount: _roomCount,
      datesLocked: args.hasDates,
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final args = _args;

    // Mo man nay khong kem `RoomSelectionArgs` la mot loi lap trinh.
    // Truoc day no am tham lay khach san DAU TIEN trong toan bo danh sach
    // roi cho nguoi dung dat phong cua mot khach san hoan toan khac.
    if (args == null) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(title: Text(tr('Chọn phòng', 'Select room'))),
        body: StayzEmptyView(
          icon: Icons.meeting_room_outlined,
          title: tr('Thiếu thông tin khách sạn', 'Missing hotel info'),
          message: tr(
            'Hãy quay lại và chọn một khách sạn trước khi xem danh sách phòng.',
            'Please go back and pick a hotel before viewing rooms.',
          ),
          actionLabel: tr('Về trang chủ', 'Go home'),
          onAction: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
        ),
      );
    }

    final hotel = args.hotel;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.search),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookingTopBar(
              title: tr('Chọn phòng', 'Select room'),
              fallbackRoute: AppRoutes.home,
              trailing: _FilterToggle(
                open: _filtersOpen,
                onTap: () => setState(() => _filtersOpen = !_filtersOpen),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Room>>(
                future: _roomsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  }
                  if (snapshot.hasError) {
                    return StayzErrorView(
                      error: snapshot.error,
                      onRetry: _loadRooms,
                    );
                  }

                  final allRooms = snapshot.data ?? const <Room>[];
                  final rooms = _filterRooms(allRooms);
                  final maxGuests = _maxGuests(allRooms);

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      16 * responsive.scale,
                      responsive.horizontalPadding,
                      24 * responsive.scale,
                    ),
                    children: [
                      _StaySummaryCard(hotel: hotel, args: args),
                      SizedBox(height: 14 * responsive.scale),

                      // Bo loc thu gon mac dinh: truoc day the loc chiem gan nua man hinh.
                      _FilterSummaryRow(
                        guestCount: _guestCount,
                        roomCount: _roomCount,
                        roomType: _roomType,
                        availableOnly: _availableOnly,
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 200),
                        crossFadeState: _filtersOpen
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: const SizedBox(width: double.infinity),
                        secondChild: Padding(
                          padding: EdgeInsets.only(top: 12 * responsive.scale),
                          child: _RoomFilterPanel(
                            guestCount: _guestCount,
                            maxGuests: maxGuests,
                            roomCount: _roomCount,
                            roomType: _roomType,
                            availableOnly: _availableOnly,
                            onGuestChanged: (value) =>
                                setState(() => _guestCount = value),
                            onRoomCountChanged: (value) =>
                                setState(() => _roomCount = value),
                            onRoomTypeChanged: (value) =>
                                setState(() => _roomType = value),
                            onAvailableChanged: (value) =>
                                setState(() => _availableOnly = value),
                          ),
                        ),
                      ),

                      SizedBox(height: 20 * responsive.scale),

                      if (rooms.isEmpty)
                        StayzEmptyView(
                          icon: Icons.bed_outlined,
                          title: allRooms.isEmpty
                              ? tr('Khách sạn chưa có phòng', 'No rooms yet')
                              : tr(
                                  'Không có phòng phù hợp',
                                  'No matching rooms',
                                ),
                          message: allRooms.isEmpty
                              ? tr(
                                  'Nơi lưu trú này chưa cập nhật phòng nào.',
                                  'This stay has not listed any rooms yet.',
                                )
                              : tr(
                                  'Hãy giảm số khách, giảm số phòng hoặc tắt "chỉ phòng còn trống".',
                                  'Try fewer guests, fewer rooms, or turn off "available only".',
                                ),
                          actionLabel: allRooms.isEmpty
                              ? null
                              : tr('Mở bộ lọc', 'Open filters'),
                          onAction: allRooms.isEmpty
                              ? null
                              : () => setState(() => _filtersOpen = true),
                          compact: true,
                        )
                      else ...[
                        Text(
                          tr(
                            '${rooms.length} loại phòng',
                            '${rooms.length} room types',
                          ),
                          style: TextStyle(
                            color: AppTheme.muted,
                            fontSize: 13 * responsive.scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 12 * responsive.scale),
                        for (var i = 0; i < rooms.length; i++) ...[
                          _roomCard(hotel, rooms[i], i),
                          if (i != rooms.length - 1)
                            SizedBox(height: 14 * responsive.scale),
                        ],
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roomCard(HotelSummary hotel, Room room, int index) {
    final soldOut = room.availableUnits == 0;
    final lowStock = room.availableUnits > 0 && room.availableUnits <= 2;
    final capacity = room.capacityAdults + room.capacityChildren;

    return RoomOptionCard(
      name: room.name,
      price: StayzFormatters.fullVnd(room.pricePerNight),
      badge: soldOut
          ? tr('Hết phòng', 'Sold out')
          : lowStock
          ? tr('Sắp hết', 'Few left')
          : tr(
              'Còn ${room.availableUnits} phòng',
              '${room.availableUnits} rooms left',
            ),
      badgeColor: soldOut
          ? AppTheme.danger
          : lowStock
          ? AppTheme.gold
          : AppTheme.success,
      note: tr(
        '${StayzTaxonomy.roomTypeLabel(room.roomType)} · tối đa $capacity khách/phòng',
        '${StayzTaxonomy.roomTypeLabel(room.roomType)} · up to $capacity guests/room',
      ),
      colors: _roomColors[index % _roomColors.length],
      canBook: !soldOut,
      imageUrl: room.imageUrls.firstOrNull,
      roomMeta: [
        tr('$capacity khách', '$capacity guests'),
        '${room.sizeSqm}m²',
        room.bedType,
      ],
      amenityLabels: room.amenityIds
          .map((slug) => StayzTaxonomy.amenityTerm(slug).label)
          .toList(),
      onBook: () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.bookingSchedule, arguments: _draftFor(hotel, room)),
    );
  }
}

const _roomColors = [
  [Color(0xFFEAF7FF), Color(0xFF1D8BD1)],
  [Color(0xFFDDEEFF), Color(0xFF0A4E83)],
  [Color(0xFFE0F0FB), Color(0xFF135D95)],
];

class _FilterToggle extends StatelessWidget {
  const _FilterToggle({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: open
          ? tr('Đóng bộ lọc phòng', 'Close room filters')
          : tr('Mở bộ lọc phòng', 'Open room filters'),
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: open ? AppTheme.ink : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: open ? AppTheme.ink : AppTheme.line),
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 19,
                color: open ? Colors.white : AppTheme.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mot dong tom tat dieu kien dang ap dung, thay cho the loc luon mo.
class _FilterSummaryRow extends StatelessWidget {
  const _FilterSummaryRow({
    required this.guestCount,
    required this.roomCount,
    required this.roomType,
    required this.availableOnly,
  });

  final int guestCount;
  final int roomCount;
  final String roomType;
  final bool availableOnly;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      tr('$guestCount khách', '$guestCount guests'),
      tr('$roomCount phòng', '$roomCount rooms'),
      if (roomType != 'all') StayzTaxonomy.roomTypeLabel(roomType),
      if (availableOnly) tr('Còn trống', 'Available'),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final chip in chips)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primarySoft.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              chip,
              style: const TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _RoomFilterPanel extends StatelessWidget {
  const _RoomFilterPanel({
    required this.guestCount,
    required this.maxGuests,
    required this.roomCount,
    required this.roomType,
    required this.availableOnly,
    required this.onGuestChanged,
    required this.onRoomCountChanged,
    required this.onRoomTypeChanged,
    required this.onAvailableChanged,
  });

  final int guestCount;
  final int maxGuests;
  final int roomCount;
  final String roomType;
  final bool availableOnly;
  final ValueChanged<int> onGuestChanged;
  final ValueChanged<int> onRoomCountChanged;
  final ValueChanged<String> onRoomTypeChanged;
  final ValueChanged<bool> onAvailableChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        children: [
          _Stepper(
            label: tr('Số khách', 'Guests'),
            value: guestCount,
            min: 1,
            max: maxGuests,
            onChanged: onGuestChanged,
          ),
          const Divider(height: 1, color: AppTheme.line),
          _Stepper(
            label: tr('Số phòng', 'Rooms'),
            value: roomCount,
            min: 1,
            max: 5,
            onChanged: onRoomCountChanged,
          ),
          const Divider(height: 1, color: AppTheme.line),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  child: Text(
                    tr('Hạng phòng', 'Room class'),
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.end,
                    children: [
                      _TypeChip(
                        label: tr('Tất cả', 'All'),
                        active: roomType == 'all',
                        onTap: () => onRoomTypeChanged('all'),
                      ),
                      for (final term in StayzTaxonomy.roomTypes)
                        _TypeChip(
                          label: term.label,
                          active: roomType == term.slug,
                          onTap: () => onRoomTypeChanged(term.slug),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.line),
          SwitchListTile.adaptive(
            value: availableOnly,
            onChanged: onAvailableChanged,
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              tr('Chỉ hiện phòng còn trống', 'Available rooms only'),
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // Ca hai nut deu disable khi cham gioi han. Truoc day nut cong luon bat
    // nhung gia tri bi kep im lang, nen bam thay nhu bi treo.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: value <= min ? null : () => onChanged(value - 1),
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: tr('Giảm $label', 'Decrease $label'),
            color: AppTheme.primary,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            onPressed: value >= max ? null : () => onChanged(value + 1),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: tr('Tăng $label', 'Increase $label'),
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      child: Material(
        color: active ? AppTheme.ink : Colors.white,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            constraints: const BoxConstraints(minHeight: 36),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: active ? AppTheme.ink : AppTheme.line),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : AppTheme.ink,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StaySummaryCard extends StatelessWidget {
  const _StaySummaryCard({required this.hotel, required this.args});

  final HotelSummary hotel;
  final RoomSelectionArgs args;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final hasDates = args.hasDates;
    final nights = hasDates
        ? StayzFormatters.nightsBetween(
            args.checkInDate!,
            args.checkOutDate!,
          ).clamp(1, 999)
        : null;

    return Container(
      padding: EdgeInsets.all(14 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.hotel.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 15 * responsive.scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4 * responsive.scale),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13 * responsive.scale,
                      color: AppTheme.muted,
                    ),
                    SizedBox(width: 5 * responsive.widthScale),
                    Expanded(
                      child: Text(
                        hasDates
                            ? '${StayzFormatters.shortDate(args.checkInDate!)} → ${StayzFormatters.shortDate(args.checkOutDate!)}'
                            : tr(
                                'Chọn ngày ở bước tiếp theo',
                                'Pick dates in the next step',
                              ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 12.5 * responsive.scale,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (nights != null) ...[
            SizedBox(width: 10 * responsive.widthScale),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primarySoft.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                tr('$nights đêm', '$nights nights'),
                style: const TextStyle(
                  color: AppTheme.primaryDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
