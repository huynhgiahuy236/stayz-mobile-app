import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:flutter/material.dart';

class BookingSchedulePage extends StatefulWidget {
  const BookingSchedulePage({super.key});

  @override
  State<BookingSchedulePage> createState() => _BookingSchedulePageState();
}

class _BookingSchedulePageState extends State<BookingSchedulePage> {
  BookingDraft? _draft;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_draft != null) return;
    _draft = ModalRoute.of(context)?.settings.arguments as BookingDraft?;
  }

  int get _maxGuests => _draft?.maxGuests ?? 1;
  int get _guestCount => (_draft?.adults ?? 0) + (_draft?.children ?? 0);

  Future<void> _pickDate({required bool checkIn}) async {
    final now = DateTime.now();
    final initial = checkIn ? _draft?.checkInDate ?? now : _draft?.checkOutDate ?? now.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: initial.isBefore(now) ? now : initial,
    );
    if (picked == null || _draft == null) return;
    setState(() {
      _draft = checkIn
          ? _draft!.copyWith(checkInDate: picked)
          : _draft!.copyWith(checkOutDate: picked);
    });
  }

  void _changeGuests(int delta) {
    if (_draft == null) return;
    final nextAdults = (_draft!.adults + delta).clamp(1, _maxGuests).toInt();
    setState(() => _draft = _draft!.copyWith(adults: nextAdults));
  }

  void _changeRoomCount(int delta) {
    if (_draft == null) return;
    final nextCount = (_draft!.roomCount + delta).clamp(1, _draft!.room.availableUnits).toInt();
    final maxGuests = ((_draft!.room.capacityAdults + _draft!.room.capacityChildren) * nextCount).clamp(1, 999).toInt();
    final nextGuests = _guestCount.clamp(1, maxGuests).toInt();
    setState(() => _draft = _draft!.copyWith(roomCount: nextCount, adults: nextGuests, children: 0));
  }

  void _continue() {
    final draft = _draft;
    if (draft == null) {
      _showMessage(tr('Vui lòng chọn phòng trước.', 'Please select a room first.'));
      return;
    }
    if (!draft.hasValidDates) {
      _showMessage(tr('Ngày check-out phải sau ngày check-in.', 'Check-out must be after check-in.'));
      return;
    }
    if (_guestCount > _maxGuests) {
      _showMessage(tr('Số khách vượt quá sức chứa phòng.', 'Number of guests exceeds room capacity.'));
      return;
    }
    Navigator.of(context).pushNamed(AppRoutes.paymentCheckout, arguments: draft);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final draft = _draft;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          responsive.horizontalPadding,
          18 * responsive.scale,
          responsive.horizontalPadding,
          22 * responsive.scale,
        ),
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: BookingPrimaryButton(
            label: tr('Tiếp tục thanh toán', 'Continue to payment'),
            icon: Icons.arrow_forward,
            onTap: _continue,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            responsive.horizontalPadding,
            12 * responsive.scale,
            responsive.horizontalPadding,
            28 * responsive.scale,
          ),
          children: [
            BookingTopBar(
              title: tr('Chi tiết đặt phòng', 'Booking details'),
              onBack: () {
                final navigator = Navigator.of(context);
                if (navigator.canPop()) {
                  navigator.pop();
                } else if (draft != null) {
                  navigator.pushReplacementNamed(
                    AppRoutes.roomSelection,
                    arguments: RoomSelectionArgs(
                      hotel: draft.hotel,
                      checkInDate: draft.checkInDate,
                      checkOutDate: draft.checkOutDate,
                      adults: draft.adults,
                      children: draft.children,
                      roomCount: draft.roomCount,
                    ),
                  );
                } else {
                  navigator.pushReplacementNamed(AppRoutes.search);
                }
              },
            ),
            SizedBox(height: 20 * responsive.scale),
            if (draft == null)
              _StateCard(message: tr('Vui lòng chọn phòng trước.', 'Please select a room first.'))
            else
              _BookingRoomHero(draft: draft),
            SizedBox(height: 18 * responsive.scale),
            if (draft?.datesLocked == true)
              _InfoCard(
                title: '${StayzFormatters.shortDate(draft!.checkInDate)} - ${StayzFormatters.shortDate(draft.checkOutDate)}',
                subtitle: tr('${draft.nights} đêm đã chọn từ bước trước', '${draft.nights} nights chosen in the previous step'),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _DateButton(
                      label: 'Check-in',
                      value: draft == null ? tr('Bắt buộc', 'Required') : StayzFormatters.shortDate(draft.checkInDate),
                      onTap: () => _pickDate(checkIn: true),
                    ),
                  ),
                  SizedBox(width: 12 * responsive.widthScale),
                  Expanded(
                    child: _DateButton(
                      label: 'Check-out',
                      value: draft == null ? tr('Bắt buộc', 'Required') : StayzFormatters.shortDate(draft.checkOutDate),
                      onTap: () => _pickDate(checkIn: false),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 18 * responsive.scale),
            _RoomCountStepper(
              count: draft?.roomCount ?? 1,
              maxRooms: draft?.room.availableUnits ?? 1,
              onMinus: () => _changeRoomCount(-1),
              onPlus: () => _changeRoomCount(1),
            ),
            SizedBox(height: 18 * responsive.scale),
            _GuestStepper(
              count: _guestCount,
              maxGuests: _maxGuests,
              onMinus: () => _changeGuests(-1),
              onPlus: () => _changeGuests(1),
            ),
            SizedBox(height: 18 * responsive.scale),
            _InfoCard(
              title: draft == null ? tr('Tổng tiền', 'Total') : StayzFormatters.fullVnd(draft.totalAmount),
              subtitle: draft == null
                  ? tr('Chọn ngày và số khách', 'Choose dates and guests')
                  : tr('${draft.nights} đêm, $_guestCount khách, ${draft.roomCount} phòng', '${draft.nights} nights, $_guestCount guests, ${draft.roomCount} rooms'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    return Container(
      padding: EdgeInsets.all(16 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppTheme.ink, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w900)),
          SizedBox(height: 6 * responsive.scale),
          Text(subtitle, style: TextStyle(color: AppTheme.muted, fontSize: 14 * responsive.scale)),
        ],
      ),
    );
  }
}

class _BookingRoomHero extends StatelessWidget {
  const _BookingRoomHero({required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final imageUrl = draft.room.imageUrls.firstOrNull ?? draft.hotel.hotel.imageUrls.firstOrNull;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl == null || imageUrl.isEmpty)
            Container(
              height: 180 * responsive.scale,
              color: AppTheme.neutral200,
              child: const Center(child: Icon(Icons.hotel_outlined, color: AppTheme.neutral500)),
            )
          else
            StayZNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: 180 * responsive.scale,
            ),
          Padding(
            padding: EdgeInsets.all(16 * responsive.scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.hotel.hotel.name,
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 19 * responsive.scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6 * responsive.scale),
                Text(
                  draft.room.name,
                  style: TextStyle(color: AppTheme.accentDark, fontSize: 15 * responsive.scale, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8 * responsive.scale),
                Text(
                  draft.hotel.hotel.address,
                  style: TextStyle(color: AppTheme.muted, fontSize: 13 * responsive.scale, height: 1.4),
                ),
                Divider(height: 26 * responsive.scale),
                _DetailMiniLine(label: tr('Giá mỗi đêm', 'Price per night'), value: StayzFormatters.fullVnd(draft.room.pricePerNight)),
                _DetailMiniLine(label: tr('Trạng thái phòng', 'Room status'), value: draft.room.availableUnits > 0 ? tr('Còn ${draft.room.availableUnits} phòng', '${draft.room.availableUnits} rooms left') : tr('Hết phòng', 'Sold out')),
                _DetailMiniLine(label: tr('Sức chứa', 'Capacity'), value: tr('${draft.room.capacityAdults + draft.room.capacityChildren} khách/phòng', '${draft.room.capacityAdults + draft.room.capacityChildren} guests/room')),
                _DetailMiniLine(label: tr('Số đêm', 'Nights'), value: tr('${draft.nights} đêm', '${draft.nights} nights')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailMiniLine extends StatelessWidget {
  const _DetailMiniLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4 * responsive.scale),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: AppTheme.muted, fontSize: 13 * responsive.scale))),
          Text(value, style: TextStyle(color: AppTheme.ink, fontSize: 13 * responsive.scale, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    return Container(
      padding: EdgeInsets.all(18 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.line),
      ),
      child: Text(message, textAlign: TextAlign.center),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(14 * responsive.scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: AppTheme.muted, fontSize: 12 * responsive.scale, fontWeight: FontWeight.w800)),
            SizedBox(height: 8 * responsive.scale),
            Text(value, style: TextStyle(color: AppTheme.ink, fontSize: 15 * responsive.scale, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _GuestStepper extends StatelessWidget {
  const _GuestStepper({
    required this.count,
    required this.maxGuests,
    required this.onMinus,
    required this.onPlus,
  });

  final int count;
  final int maxGuests;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    return Container(
      padding: EdgeInsets.all(16 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              tr('Số khách (tối đa $maxGuests)', 'Guests (max $maxGuests)'),
              style: TextStyle(color: AppTheme.ink, fontSize: 16 * responsive.scale, fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(onPressed: onMinus, icon: const Icon(Icons.remove_circle_outline)),
          Text('$count', style: TextStyle(fontSize: 18 * responsive.scale, fontWeight: FontWeight.w900)),
          IconButton(onPressed: onPlus, icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
    );
  }
}

class _RoomCountStepper extends StatelessWidget {
  const _RoomCountStepper({
    required this.count,
    required this.maxRooms,
    required this.onMinus,
    required this.onPlus,
  });

  final int count;
  final int maxRooms;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    return Container(
      padding: EdgeInsets.all(16 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              tr('Số phòng (còn $maxRooms)', 'Rooms ($maxRooms left)'),
              style: TextStyle(color: AppTheme.ink, fontSize: 16 * responsive.scale, fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(onPressed: count <= 1 ? null : onMinus, icon: const Icon(Icons.remove_circle_outline)),
          Text('$count', style: TextStyle(fontSize: 18 * responsive.scale, fontWeight: FontWeight.w900)),
          IconButton(onPressed: count >= maxRooms ? null : onPlus, icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
    );
  }
}
