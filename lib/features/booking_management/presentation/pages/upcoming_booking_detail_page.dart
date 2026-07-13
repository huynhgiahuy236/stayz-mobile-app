import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/cancel_booking_dialog.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/data/stayz_taxonomy.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:flutter/material.dart';

class UpcomingBookingDetailPage extends StatefulWidget {
  const UpcomingBookingDetailPage({super.key});

  @override
  State<UpcomingBookingDetailPage> createState() => _UpcomingBookingDetailPageState();
}

class _UpcomingBookingDetailPageState extends State<UpcomingBookingDetailPage> {
  bool _openingPayment = false;

  Future<void> _continuePayment(BookingSummaryArgs args) async {
    if (_openingPayment) return;
    setState(() => _openingPayment = true);
    try {
      final summary = args.summary;
      final payment = await ApiStayzRepository.instance.createPayOSPayment(summary.booking.id);
      final paymentArgs = PayOSPaymentArgs.fromPayment(
        summary: summary,
        payment: payment,
        fallbackAmount: summary.booking.totalAmount,
      );
      if (!mounted) return;
      await Navigator.of(context).pushNamed(AppRoutes.paymentQr, arguments: paymentArgs);
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _openingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;
    final args = ModalRoute.of(context)?.settings.arguments as BookingSummaryArgs?;
    final summary = args?.summary;

    if (summary == null) {
      return Scaffold(
        backgroundColor: AppTheme.cream,
        bottomNavigationBar: StayZBottomNav(activeTab: HomeTab.bookings),
        body: SafeArea(child: Center(child: Text(tr('Thiếu thông tin đặt phòng.', 'Missing booking detail.')))),
      );
    }

    final imageUrl = summary.room.imageUrls.firstOrNull ?? summary.hotel.imageUrls.firstOrNull;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: const _ThreeItemNav(active: 0),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookingTopBar(
              title: tr('Chi tiết đặt phòng', 'Booking details'),
              fallbackRoute: AppRoutes.myBookings,
              
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  Stack(
                    children: [
                      if (imageUrl == null || imageUrl.isEmpty)
                        Container(
                          height: 290 * responsive.scale,
                          decoration: BoxDecoration(
                            color: AppTheme.neutral200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.hotel_outlined, color: AppTheme.neutral500),
                        )
                      else
                        StayZNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          height: 290 * responsive.scale,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      Positioned(
                        top: 18 * responsive.scale,
                        left: 18 * responsive.widthScale,
                        child: BookingStatusPill(
                          label: summary.booking.isPaymentExpired
                              ? tr('Đã hết hạn thanh toán', 'Payment expired')
                              : summary.booking.isPaymentPending
                                  ? tr('Chờ thanh toán', 'Pending payment')
                                  : tr('Sắp đến', 'Upcoming'),
                          color: summary.booking.isPaymentPending ? const Color(0xFFFFE0A3) : const Color(0xFF9BF0BF),
                          textColor: summary.booking.isPaymentPending ? const Color(0xFF7A4800) : const Color(0xFF055C3A),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24 * responsive.scale),
                  Text(
                    summary.hotel.name,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.ink,
                      fontSize: 28 * responsive.scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10 * responsive.scale),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 18 * responsive.scale),
                      SizedBox(width: 6 * responsive.widthScale),
                      Expanded(
                        child: Text(
                          '${summary.city.name}, ${summary.city.region}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 16 * responsive.scale),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 34 * responsive.scale),
                  BookingDetailPanel(
                    title: tr('Thông tin đặt phòng', 'Booking information'),
                    children: [
                      DetailLine(label: tr('Mã đặt phòng', 'Booking code'), value: _bookingCode(summary.booking.id)),
                      const Divider(),
                      DetailLine(label: tr('Khách sạn', 'Hotel'), value: summary.hotel.name),
                      DetailLine(label: tr('Loại phòng', 'Room type'), value: summary.room.name),
                      const Divider(),
                      DetailLine(label: 'Check-in', value: StayzFormatters.shortDate(summary.booking.checkInDate)),
                      DetailLine(label: 'Check-out', value: StayzFormatters.shortDate(summary.booking.checkOutDate)),
                      DetailLine(label: tr('Số đêm', 'Nights'), value: tr('${summary.booking.nights} đêm', '${summary.booking.nights} nights')),
                      const Divider(),
                      DetailLine(
                        label: tr('Số khách', 'Guests'),
                        value: tr('${summary.booking.guests.adults} người lớn, ${summary.booking.guests.children} trẻ em', '${summary.booking.guests.adults} adults, ${summary.booking.guests.children} children'),
                      ),
                      DetailLine(label: tr('Trạng thái', 'Status'), value: StayzTaxonomy.bookingStatusLabel(summary.booking.status)),
                    ],
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  BookingDetailPanel(
                    title: tr('Chi tiết thanh toán', 'Payment details'),
                    children: [
                      DetailLine(label: tr('Giá mỗi đêm', 'Price per night'), value: StayzFormatters.fullVnd(summary.room.pricePerNight)),
                      DetailLine(label: tr('Số đêm', 'Nights'), value: '${summary.booking.nights}'),
                      DetailLine(label: tr('Thuế và phí', 'Taxes and fees'), value: tr('Đã bao gồm', 'Included')),
                      const Divider(),
                      DetailLine(
                        label: tr('Tổng thanh toán', 'Total'),
                        value: StayzFormatters.fullVnd(summary.booking.totalAmount),
                        total: true,
                      ),
                      const Divider(),
                      Text(
                        '${tr('Trạng thái thanh toán', 'Payment status')}: ${StayzTaxonomy.paymentStatusLabel(summary.booking.paymentStatus)}',
                        style: TextStyle(color: const Color(0xFF6B5348), fontSize: 14 * responsive.scale, height: 1.4),
                      ),
                    ],
                  ),
                  if (summary.booking.specialRequest != null && summary.booking.specialRequest!.trim().isNotEmpty) ...[
                    SizedBox(height: 20 * responsive.scale),
                    BookingDetailPanel(
                      title: tr('Ghi chú', 'Notes'),
                      children: [
                        Text(
                          summary.booking.specialRequest!,
                          style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 18 * responsive.scale, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 34 * responsive.scale),
                  SizedBox(
                    height: 58 * responsive.scale,
                    child: OutlinedButton(
                      onPressed: summary.booking.isPaymentPending
                          ? (_openingPayment || summary.booking.isPaymentExpired ? null : () => _continuePayment(args!))
                          : () async {
                        final confirmed = await confirmCancelBooking(context, summary);
                        if (!confirmed || !context.mounted) return;
                        await Navigator.of(context).pushNamed(
                          AppRoutes.cancelBookingResult,
                          arguments: args,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.accentDark),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        summary.booking.isPaymentPending
                            ? (_openingPayment ? tr('Đang mở thanh toán...', 'Opening payment...') : tr('Thanh toán ngay', 'Pay now'))
                            : tr('Hủy đặt phòng', 'Cancel booking'),
                        style: TextStyle(color: AppTheme.accentDark, fontSize: 18 * responsive.scale),
                      ),
                    ),
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  Text(
                    summary.booking.isPaymentExpired
                        ? tr('Mã thanh toán đã hết hạn. Hãy vào Đặt phòng của tôi để tạo lại.', 'The payment code has expired. Open My bookings to create a new one.')
                        : summary.booking.isPaymentPending
                            ? tr('Đặt phòng chỉ được xác nhận sau khi thanh toán thành công.', 'Your booking is confirmed only after successful payment.')
                            : tr('Chính sách hủy được áp dụng theo điều kiện của khách sạn.', 'The hotel cancellation policy applies.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.neutral500, fontSize: 14 * responsive.scale, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _bookingCode(String id) {
    if (id.isEmpty) return 'SZ';
    final suffix = id.length > 5 ? id.substring(id.length - 5) : id;
    return 'SZ-$suffix';
  }
}

class _ThreeItemNav extends StatelessWidget {
  const _ThreeItemNav({required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final items = [
      (Icons.event_available_outlined, tr('Đặt phòng', 'Reservations')),
      (Icons.history, tr('Lịch sử', 'History')),
      (Icons.person_outline, tr('Tài khoản', 'Account')),
    ];

    return Container(
      height: 78 * responsive.scale,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.7))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(items[i].$1, color: i == active ? AppTheme.accentDark : AppTheme.ink, size: 24 * responsive.scale),
                SizedBox(height: 5 * responsive.scale),
                Text(
                  items[i].$2,
                  style: TextStyle(
                    color: i == active ? AppTheme.accentDark : AppTheme.ink,
                    fontSize: 12 * responsive.scale,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
