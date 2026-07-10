import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/chat/ai_chat_sheet.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:flutter/material.dart';

class RealRoomSelectionPage extends StatefulWidget {
  const RealRoomSelectionPage({super.key});

  @override
  State<RealRoomSelectionPage> createState() => _RealRoomSelectionPageState();
}

class _RealRoomSelectionPageState extends State<RealRoomSelectionPage> {
  int _guestCount = 2;
  int _roomCount = 1;
  String _roomType = 'all';
  RangeValues _priceRange = const RangeValues(0, 15000000);
  bool _availableOnly = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final args = ModalRoute.of(context)?.settings.arguments as RoomSelectionArgs?;
    if (args != null) {
      _guestCount = args.adults + args.children;
      _roomCount = args.roomCount;
    }
    _initialized = true;
  }

  List<Room> _filterRooms(List<Room> rooms) {
    return rooms.where((room) {
      final capacity = room.capacityAdults + room.capacityChildren;
      final capacityOk = capacity * _roomCount >= _guestCount;
      final priceOk = room.pricePerNight >= _priceRange.start && room.pricePerNight <= _priceRange.end;
      final typeOk = _roomType == 'all' || room.roomType == _roomType;
      final availableOk = !_availableOnly || room.availableUnits >= _roomCount;
      return capacityOk && priceOk && typeOk && availableOk && room.status != 'inactive';
    }).toList(growable: false);
  }

  BookingDraft _draftFor(HotelSummary hotel, Room room, RoomSelectionArgs? args) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkIn = args?.hasDates == true ? args!.checkInDate! : today;
    final checkOut = args?.hasDates == true ? args!.checkOutDate! : today.add(const Duration(days: 1));
    final maxGuests = ((room.capacityAdults + room.capacityChildren) * _roomCount).clamp(1, 999).toInt();
    final guests = _guestCount.clamp(1, maxGuests).toInt();

    return BookingDraft(
      hotel: hotel,
      room: room,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      adults: guests,
      children: 0,
      roomCount: _roomCount,
      datesLocked: args?.hasDates == true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final args = ModalRoute.of(context)?.settings.arguments as RoomSelectionArgs?;
    final selectedHotel = args?.hotel;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.search),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookingTopBar(
              title: 'Chon phong',
              trailing: Icon(Icons.tune, color: AppTheme.accentDark, size: 24 * responsive.scale),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  30 * responsive.scale,
                  responsive.horizontalPadding,
                  24 * responsive.scale,
                ),
                children: [
                  _StaySummaryCard(hotel: selectedHotel, args: args),
                  SizedBox(height: 18 * responsive.scale),
                  _RoomFilterCard(
                    guestCount: _guestCount,
                    roomCount: _roomCount,
                    roomType: _roomType,
                    priceRange: _priceRange,
                    availableOnly: _availableOnly,
                    onGuestChanged: (value) => setState(() => _guestCount = value),
                    onRoomCountChanged: (value) => setState(() => _roomCount = value),
                    onRoomTypeChanged: (value) => setState(() => _roomType = value ?? 'all'),
                    onPriceRangeChanged: (value) => setState(() => _priceRange = value),
                    onAvailableChanged: (value) => setState(() => _availableOnly = value),
                  ),
                  SizedBox(height: 24 * responsive.scale),
                  FutureBuilder<List<HotelSummary>>(
                    future: ApiStayzRepository.instance.getHotelSummaries(),
                    builder: (context, hotelSnapshot) {
                      final hotelSummary = selectedHotel ?? hotelSnapshot.data?.firstOrNull;
                      final hotelId = hotelSummary?.hotel.id;

                      if (hotelId == null) {
                        if (hotelSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                        }
                        return const _StateMessage(message: 'Khong co khach san de chon phong.');
                      }

                      return FutureBuilder<List<Room>>(
                        future: ApiStayzRepository.instance.getRoomsByHotelId(
                          hotelId,
                          checkInDate: args?.checkInDate,
                          checkOutDate: args?.checkOutDate,
                        ),
                        builder: (context, roomSnapshot) {
                          if (roomSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                          }
                          if (roomSnapshot.hasError) {
                            return _StateMessage(message: roomSnapshot.error.toString());
                          }

                          final rooms = _filterRooms(roomSnapshot.data ?? const <Room>[]);
                          if (rooms.isEmpty) {
                            return const _StateMessage(message: 'Khong co phong phu hop voi bo loc hien tai.');
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${rooms.length} LOAI PHONG',
                                style: TextStyle(
                                  color: AppTheme.neutral500,
                                  fontSize: 12 * responsive.scale,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                              SizedBox(height: 18 * responsive.scale),
                              for (var i = 0; i < rooms.length; i++) ...[
                                RoomOptionCard(
                                  name: rooms[i].name,
                                  price: StayzFormatters.fullVnd(rooms[i].pricePerNight),
                                  badge: rooms[i].availableUnits == 0
                                      ? 'Het phong'
                                      : rooms[i].availableUnits <= 2
                                          ? 'Sap het'
                                          : 'Con ${rooms[i].availableUnits} phong',
                                  note: '${rooms[i].roomType} - toi da ${rooms[i].capacityAdults + rooms[i].capacityChildren} khach/phong',
                                  badgeColor: rooms[i].availableUnits == 0
                                      ? AppTheme.neutral500
                                      : rooms[i].availableUnits <= 2
                                          ? const Color(0xFFC06B00)
                                          : const Color(0xFF007044),
                                  colors: _roomColors[i % _roomColors.length],
                                  canBook: rooms[i].availableUnits > 0,
                                  imageUrl: rooms[i].imageUrls.firstOrNull,
                                  roomMeta: [
                                    '${rooms[i].capacityAdults + rooms[i].capacityChildren} khach',
                                    '${rooms[i].sizeSqm}m2',
                                    rooms[i].bedType,
                                  ],
                                  amenityLabels: rooms[i].amenityIds.map(_amenityLabel).toList(),
                                  onAskAi: () => showAiChatSheet(
                                    context,
                                    aiContext: AiChatContext.forRoom(
                                      hotel: hotelSummary!,
                                      room: rooms[i],
                                      args: args,
                                    ),
                                  ),
                                  onBook: () => Navigator.of(context).pushNamed(
                                    AppRoutes.bookingSchedule,
                                    arguments: _draftFor(hotelSummary!, rooms[i], args),
                                  ),
                                ),
                                if (i != rooms.length - 1) SizedBox(height: 20 * responsive.scale),
                              ],
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _roomColors = [
  [Color(0xFF28341C), Color(0xFFB7D27A)],
  [Color(0xFF3D2514), Color(0xFFF0B36D)],
  [Color(0xFF4B4C42), Color(0xFFD9D1C2)],
];

String _amenityLabel(String value) {
  const labels = {
    'toiletries': 'Do dung ca nhan',
    'shower': 'Voi sen',
    'toilet': 'Toilet rieng',
    'towels': 'Khan tam',
    'socket_near_bed': 'O cam gan giuong',
    'sitting_area': 'Khu tiep khach',
    'private_entrance': 'Loi vao rieng',
    'slippers': 'Dep phong',
    'hair_dryer': 'May say toc',
    'fan': 'Quat',
    'electric_kettle': 'Am dun nuoc',
    'wardrobe': 'Tu quan ao',
    'clothes_rack': 'Gia treo do',
    'toilet_paper': 'Giay ve sinh',
  };
  return labels[value] ?? value.replaceAll('_', ' ');
}

class _StaySummaryCard extends StatelessWidget {
  const _StaySummaryCard({this.hotel, this.args});

  final HotelSummary? hotel;
  final RoomSelectionArgs? args;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final hasDates = args?.hasDates == true;
    final checkIn = hasDates ? StayzFormatters.shortDate(args!.checkInDate!) : 'Chua chon';
    final checkOut = hasDates ? StayzFormatters.shortDate(args!.checkOutDate!) : 'Chon o buoc tiep';
    final nights = hasDates ? args!.checkOutDate!.difference(args!.checkInDate!).inDays.clamp(1, 999) : 1;

    return Container(
      padding: EdgeInsets.all(16 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, color: AppTheme.accentDark, size: 20 * responsive.scale),
          SizedBox(width: 14 * responsive.widthScale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _DateText(title: checkIn)),
                    Text('->', style: TextStyle(fontSize: 16 * responsive.scale)),
                    Expanded(child: _DateText(title: checkOut)),
                  ],
                ),
                SizedBox(height: 12 * responsive.scale),
                Text(
                  hotel == null ? 'Chon khach san' : '${hotel!.hotel.name} - ${hotel!.city.name}',
                  style: TextStyle(color: AppTheme.neutral500, fontSize: 12 * responsive.scale),
                ),
              ],
            ),
          ),
          SizedBox(width: 12 * responsive.widthScale),
          CircleAvatar(
            radius: 25 * responsive.scale,
            backgroundColor: AppTheme.neutral200.withValues(alpha: 0.5),
            child: Text(
              '$nights\ndem',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.neutral500, fontSize: 14 * responsive.scale),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomFilterCard extends StatelessWidget {
  const _RoomFilterCard({
    required this.guestCount,
    required this.roomCount,
    required this.roomType,
    required this.priceRange,
    required this.availableOnly,
    required this.onGuestChanged,
    required this.onRoomCountChanged,
    required this.onRoomTypeChanged,
    required this.onPriceRangeChanged,
    required this.onAvailableChanged,
  });

  final int guestCount;
  final int roomCount;
  final String roomType;
  final RangeValues priceRange;
  final bool availableOnly;
  final ValueChanged<int> onGuestChanged;
  final ValueChanged<int> onRoomCountChanged;
  final ValueChanged<String?> onRoomTypeChanged;
  final ValueChanged<RangeValues> onPriceRangeChanged;
  final ValueChanged<bool> onAvailableChanged;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    return Container(
      padding: EdgeInsets.all(14 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _StepperFilter(label: 'Khach', value: guestCount, min: 1, onChanged: onGuestChanged)),
              SizedBox(width: 12 * responsive.widthScale),
              Expanded(child: _StepperFilter(label: 'Phong', value: roomCount, min: 1, onChanged: onRoomCountChanged)),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: roomType,
                  decoration: const InputDecoration(labelText: 'Loai phong'),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tat ca')),
                    DropdownMenuItem(value: 'standard_room', child: Text('Standard')),
                    DropdownMenuItem(value: 'deluxe_room', child: Text('Deluxe')),
                    DropdownMenuItem(value: 'suite', child: Text('Suite')),
                  ],
                  onChanged: onRoomTypeChanged,
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * responsive.scale),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Khoang gia: ${StayzFormatters.compactVnd(priceRange.start)} - ${StayzFormatters.compactVnd(priceRange.end)}',
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 13 * responsive.scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          RangeSlider(
            min: 0,
            max: 15000000,
            divisions: 15,
            values: priceRange,
            labels: RangeLabels(
              StayzFormatters.compactVnd(priceRange.start),
              StayzFormatters.compactVnd(priceRange.end),
            ),
            onChanged: onPriceRangeChanged,
          ),
          SwitchListTile(
            value: availableOnly,
            onChanged: onAvailableChanged,
            contentPadding: EdgeInsets.zero,
            title: const Text('Chi hien phong con trong'),
          ),
        ],
      ),
    );
  }
}

class _StepperFilter extends StatelessWidget {
  const _StepperFilter({
    required this.label,
    required this.value,
    required this.min,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
        IconButton(onPressed: value <= min ? null : () => onChanged(value - 1), icon: const Icon(Icons.remove_circle_outline)),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w900)),
        IconButton(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add_circle_outline)),
      ],
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(child: Text(message, textAlign: TextAlign.center)),
    );
  }
}

class _DateText extends StatelessWidget {
  const _DateText({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(color: AppTheme.ink, fontSize: 15 * responsive.scale, height: 1.35),
    );
  }
}
