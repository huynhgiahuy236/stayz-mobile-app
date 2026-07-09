import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:flutter/material.dart';

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
                18 * responsive.scale,
                responsive.horizontalPadding,
                26 * responsive.scale,
              ),
              child: Row(
                children: [
                  Icon(Icons.close, color: AppTheme.accentDark, size: 30 * responsive.scale),
                  Expanded(
                    child: Text(
                      'Booking Confirmed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 24 * responsive.scale,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: 30 * responsive.scale),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  42 * responsive.scale,
                  responsive.horizontalPadding,
                  34 * responsive.scale,
                ),
                children: [
                  CircleAvatar(
                    radius: 54 * responsive.scale,
                    backgroundColor: const Color(0xFFEADDD8),
                    child: Icon(Icons.check_circle_outline, color: AppTheme.ink, size: 58 * responsive.scale),
                  ),
                  SizedBox(height: 34 * responsive.scale),
                  Text(
                    'Dat phong thanh cong!',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.ink,
                      fontSize: 33 * responsive.scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  Text(
                    'Chuc ban co mot chuyen di tuyet voi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF5A3F3F),
                      fontSize: 18 * responsive.scale,
                    ),
                  ),
                  SizedBox(height: 58 * responsive.scale),
                  _ConfirmedTicket(draft: draft, summary: summary),
                  SizedBox(height: 52 * responsive.scale),
                  Center(
                    child: Container(
                      width: 206 * responsive.widthScale,
                      padding: EdgeInsets.all(18 * responsive.scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.neutral200),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 210 * responsive.widthScale,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4E8E5),
                              borderRadius: BorderRadius.circular(4),
                              gradient: const LinearGradient(colors: [Color(0xFFE9EFEC), Color(0xFFC9D0CC)]),
                            ),
                            child: Center(
                              child: Icon(Icons.qr_code_2, color: AppTheme.neutral500, size: 86 * responsive.scale),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  Text(
                    'QUET MA DE CHECK-IN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF5A3F3F),
                      fontSize: 16 * responsive.scale,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                    ),
                  ),
                  SizedBox(height: 70 * responsive.scale),
                  BookingPrimaryButton(
                    label: 'Xem chi tiết booking',
                    onTap: () {
                      if (summary == null) {
                        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.myBookings, (route) => false);
                        return;
                      }
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.upcomingBookingDetail,
                        (route) => false,
                        arguments: BookingSummaryArgs(summary: summary),
                      );
                    },
                  ),
                  SizedBox(height: 22 * responsive.scale),
                  SizedBox(
                    height: 58 * responsive.scale,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.neutral200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Ve Trang chu',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 20 * responsive.scale,
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
        ? (draft == null ? 'Khong co du lieu dat phong' : '${draft!.hotel.hotel.name}, ${draft!.hotel.city.name}')
        : '${summary!.hotel.name}, ${summary!.city.name}';
    final address = summary?.hotel.address ?? draft?.hotel.hotel.address ?? '';
    final checkIn = summary == null
        ? (draft == null ? '' : '${draft!.hotel.hotel.checkInTime}, ${StayzFormatters.shortDate(draft!.checkInDate)}')
        : '${summary!.hotel.checkInTime}, ${StayzFormatters.shortDate(summary!.booking.checkInDate)}';
    final checkOut = summary == null
        ? (draft == null ? '' : '${draft!.hotel.hotel.checkOutTime}, ${StayzFormatters.shortDate(draft!.checkOutDate)}')
        : '${summary!.hotel.checkOutTime}, ${StayzFormatters.shortDate(summary!.booking.checkOutDate)}';
    final total = summary == null
        ? (draft == null ? '' : StayzFormatters.fullVnd(draft!.totalAmount))
        : StayzFormatters.fullVnd(summary!.booking.totalAmount);

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
                  'MA DAT PHONG',
                  style: TextStyle(
                    color: const Color(0xFF5A3F3F),
                    fontSize: 16 * responsive.scale,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
              ),
              Text(
                _bookingCode,
                style: TextStyle(color: AppTheme.ink, fontSize: 17 * responsive.scale, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          Divider(height: 34 * responsive.scale, color: const Color(0xFFD9B8B8)),
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
              Icon(Icons.location_on_outlined, color: const Color(0xFF5A3F3F), size: 22 * responsive.scale),
              SizedBox(width: 8 * responsive.widthScale),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 17 * responsive.scale),
                ),
              ),
            ],
          ),
          SizedBox(height: 26 * responsive.scale),
          Row(
            children: [
              Expanded(
                child: _TicketMeta(
                  label: 'CHECK-IN',
                  value: checkIn,
                ),
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
          Divider(height: 38 * responsive.scale, color: const Color(0xFFD9B8B8)),
          PriceLine(
            label: 'Tổng cộng',
            value: total,
            total: true,
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
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF5A3F3F),
            fontSize: 14 * responsive.scale,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 8 * responsive.scale),
        Text(
          value,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: TextStyle(color: AppTheme.ink, fontSize: 15 * responsive.scale, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
