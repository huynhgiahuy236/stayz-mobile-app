import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;
    final args = ModalRoute.of(context)?.settings.arguments;
    final draft = args is BookingDraft ? args : null;
    final summary = args is BookingSummaryArgs ? args.summary : null;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                10 * responsive.scale,
                responsive.horizontalPadding,
                10 * responsive.scale,
              ),
              child: Row(
                children: [
                  // Truoc day day la mot Icon tinh: trong nhu nut dong nhung bam khong duoc.
                  IconButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
                    icon: const Icon(Icons.close),
                    color: AppTheme.accentDark,
                    tooltip: tr('Đóng và về trang chủ', 'Close and go home'),
                    constraints: const BoxConstraints.tightFor(
                      width: 48,
                      height: 48,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tr('Đặt phòng thành công', 'Booking successful'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 20 * responsive.scale,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  18 * responsive.scale,
                  responsive.horizontalPadding,
                  24 * responsive.scale,
                ),
                children: [
                  CircleAvatar(
                    radius: 38 * responsive.scale,
                    backgroundColor: AppTheme.primarySoft,
                    child: Icon(
                      Icons.check_rounded,
                      color: AppTheme.primary,
                      size: 44 * responsive.scale,
                    ),
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  Text(
                    tr('Đặt phòng thành công!', 'Booking successful!'),
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.ink,
                      fontSize: 28 * responsive.scale,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8 * responsive.scale),
                  Text(
                    tr(
                      'Thông tin đặt phòng đã được lưu trong Chuyến đi của tôi.',
                      'Your booking is now available in My trips.',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 15 * responsive.scale,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 26 * responsive.scale),
                  _ConfirmedTicket(draft: draft, summary: summary),
                  if (summary?.booking.checkInCode.isNotEmpty == true) ...[
                    SizedBox(height: 14 * responsive.scale),
                    _CheckInCodeTile(code: summary!.booking.checkInCode),
                  ],
                  SizedBox(height: 24 * responsive.scale),
                  BookingPrimaryButton(
                    label: tr('Xem chi tiết booking', 'View booking details'),
                    onTap: () {
                      if (summary == null) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.myBookings,
                          (route) => false,
                        );
                        return;
                      }
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.upcomingBookingDetail,
                        (route) => false,
                        arguments: BookingSummaryArgs(summary: summary),
                      );
                    },
                  ),
                  SizedBox(height: 12 * responsive.scale),
                  SizedBox(
                    height: 52 * responsive.scale,
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.home,
                            (route) => false,
                          ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.neutral200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        tr('Về Trang chủ', 'Go home'),
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 16 * responsive.scale,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
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

class _CheckInCodeTile extends StatelessWidget {
  const _CheckInCodeTile({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.neutral200),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: 16 * responsive.widthScale,
          vertical: 2 * responsive.scale,
        ),
        childrenPadding: EdgeInsets.fromLTRB(
          16 * responsive.widthScale,
          0,
          16 * responsive.widthScale,
          18 * responsive.scale,
        ),
        leading: const Icon(Icons.qr_code_2_rounded, color: AppTheme.primary),
        title: Text(
          tr('Mã nhận phòng', 'Check-in code'),
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 15 * responsive.scale,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          tr('Chạm để xem QR', 'Tap to view QR'),
          style: TextStyle(
            color: AppTheme.muted,
            fontSize: 12 * responsive.scale,
          ),
        ),
        children: [
          QrImageView(
            data: 'STAYZ-CHECKIN:$code',
            size: 176 * responsive.widthScale,
            backgroundColor: Colors.white,
          ),
          SizedBox(height: 8 * responsive.scale),
          Text(
            code,
            style: TextStyle(
              color: AppTheme.ink,
              fontSize: 16 * responsive.scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmedTicket extends StatelessWidget {
  const _ConfirmedTicket({required this.draft, required this.summary});

  final BookingDraft? draft;
  final BookingSummary? summary;

  String get _bookingCode {
    final id = summary?.booking.id;
    if (id == null || id.isEmpty) return 'SZ';
    final suffix = id.length > 5 ? id.substring(id.length - 5) : id;
    return 'SZ-$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final hotelName = summary == null
        ? (draft == null
              ? tr('Không có dữ liệu đặt phòng', 'No booking data')
              : '${draft!.hotel.hotel.name}, ${draft!.hotel.city.name}')
        : '${summary!.hotel.name}, ${summary!.city.name}';
    final address = summary?.hotel.address ?? draft?.hotel.hotel.address ?? '';
    final checkIn = summary == null
        ? (draft == null
              ? ''
              : '${draft!.hotel.hotel.checkInTime}, ${StayzFormatters.shortDate(draft!.checkInDate)}')
        : '${summary!.hotel.checkInTime}, ${StayzFormatters.shortDate(summary!.booking.checkInDate)}';
    final checkOut = summary == null
        ? (draft == null
              ? ''
              : '${draft!.hotel.hotel.checkOutTime}, ${StayzFormatters.shortDate(draft!.checkOutDate)}')
        : '${summary!.hotel.checkOutTime}, ${StayzFormatters.shortDate(summary!.booking.checkOutDate)}';
    final total = summary == null
        ? (draft == null ? '' : StayzFormatters.fullVnd(draft!.totalAmount))
        : StayzFormatters.fullVnd(summary!.booking.totalAmount);
    final totalValue = summary?.booking.totalAmount ?? draft?.totalAmount ?? 0;
    final paid = summary?.booking.recordedAmount ?? draft?.amountPaid ?? 0;
    final isDeposit =
        (summary?.booking.paymentPlan ?? draft?.paymentPlan) == 'deposit_30';
    final remaining =
        summary?.booking.remainingAmount ??
        draft?.remainingAtHotel ??
        (isDeposit ? (totalValue - paid).clamp(0, totalValue) : 0);
    final discount = !isDeposit && paid > 0
        ? (totalValue - paid).clamp(0, totalValue)
        : 0;

    return Container(
      padding: EdgeInsets.all(24 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tr('MÃ ĐẶT PHÒNG', 'BOOKING CODE'),
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 16 * responsive.scale,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
              ),
              Text(
                _bookingCode,
                style: TextStyle(
                  color: AppTheme.ink,
                  fontSize: 17 * responsive.scale,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Divider(height: 34 * responsive.scale, color: AppTheme.line),
          Text(
            hotelName,
            style: TextStyle(
              color: AppTheme.accentDark,
              fontSize: 22 * responsive.scale,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14 * responsive.scale),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppTheme.ink,
                size: 22 * responsive.scale,
              ),
              SizedBox(width: 8 * responsive.widthScale),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 17 * responsive.scale,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 26 * responsive.scale),
          Row(
            children: [
              Expanded(
                child: _TicketMeta(label: 'CHECK-IN', value: checkIn),
              ),
              Expanded(
                child: _TicketMeta(
                  label: 'CHECK-OUT',
                  value: checkOut,
                  alignRight: true,
                ),
              ),
            ],
          ),
          Divider(height: 38 * responsive.scale, color: AppTheme.line),
          PriceLine(label: tr('Tổng giá phòng', 'Room total'), value: total),
          if (discount > 0)
            PriceLine(
              label: tr('Giảm 10%', '10% discount'),
              value: '-${StayzFormatters.fullVnd(discount)}',
            ),
          if (paid > 0)
            PriceLine(
              label: isDeposit
                  ? tr('Đã đặt cọc (30%)', 'Deposit paid (30%)')
                  : tr('Đã thanh toán', 'Amount paid'),
              value: StayzFormatters.fullVnd(paid),
              total: true,
            ),
          if (isDeposit && remaining > 0)
            PriceLine(
              label: tr(
                'Còn lại tại khách sạn (70%)',
                'Remaining at property (70%)',
              ),
              value: StayzFormatters.fullVnd(remaining),
            ),
        ],
      ),
    );
  }
}

class _TicketMeta extends StatelessWidget {
  const _TicketMeta({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 14 * responsive.scale,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 8 * responsive.scale),
        Text(
          value,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 15 * responsive.scale,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
