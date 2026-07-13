import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:flutter/material.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/data/stayz_taxonomy.dart';

class CancelledBookingDetailPage extends StatelessWidget {
  const CancelledBookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;
    final args = ModalRoute.of(context)?.settings.arguments as BookingSummaryArgs?;
    final summary = args?.summary;

    if (summary == null) {
      return Scaffold(
        backgroundColor: AppTheme.cream,
        bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.bookings),
        body: SafeArea(child: Center(child: Text(tr('Thiếu thông tin đặt phòng.', 'Missing booking detail.')))),
      );
    }

    final imageUrl = summary.room.imageUrls.firstOrNull ?? summary.hotel.imageUrls.firstOrNull;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.bookings),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookingTopBar(
              title: tr('Chi tiết đặt phòng', 'Booking details'),
              fallbackRoute: AppRoutes.cancelledBookings,
              trailing: const Icon(Icons.account_circle_outlined, color: AppTheme.accentDark),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  if (imageUrl == null || imageUrl.isEmpty)
                    Container(
                      height: 284 * responsive.scale,
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
                      height: 284 * responsive.scale,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  SizedBox(height: 24 * responsive.scale),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          summary.hotel.name,
                          style: textTheme.headlineMedium?.copyWith(
                            color: AppTheme.accentDark,
                            fontSize: 28 * responsive.scale,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    BookingStatusPill(label: tr('Đã hủy', 'Cancelled'), color: const Color(0xFFFFD8D5)),
                    ],
                  ),
                  SizedBox(height: 10 * responsive.scale),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: const Color(0xFF5A3F3F), size: 20 * responsive.scale),
                      SizedBox(width: 8 * responsive.widthScale),
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
                  SizedBox(height: 28 * responsive.scale),
                  BookingDetailPanel(
                    title: tr('Mã đặt phòng: ${_bookingCode(summary.booking.id)}', 'Booking code: ${_bookingCode(summary.booking.id)}'),
                    children: [
                      DetailLine(label: tr('Khách sạn', 'Hotel'), value: summary.hotel.name),
                      DetailLine(label: tr('Loại phòng', 'Room type'), value: summary.room.name),
                      const Divider(),
                      DetailLine(
                        label: tr('Nhận phòng - Trả phòng', 'Check-in - Check-out'),
                        value: '${StayzFormatters.shortDate(summary.booking.checkInDate)} - ${StayzFormatters.shortDate(summary.booking.checkOutDate)}',
                      ),
                      DetailLine(label: tr('Thời gian', 'Duration'), value: tr('${summary.booking.nights} đêm', '${summary.booking.nights} nights')),
                      DetailLine(
                        label: tr('Khách lưu trú', 'Guests'),
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
                      DetailLine(label: tr('Phí dịch vụ', 'Service fee'), value: tr('Đã bao gồm', 'Included')),
                      const Divider(),
                      DetailLine(
                        label: tr('Tổng cộng', 'Total'),
                        value: StayzFormatters.fullVnd(summary.booking.totalAmount),
                        total: true,
                      ),
                      const Divider(),
                      DetailLine(label: tr('Thanh toán', 'Payment'), value: StayzTaxonomy.paymentStatusLabel(summary.booking.paymentStatus)),
                    ],
                  ),
                  SizedBox(height: 34 * responsive.scale),
                  SizedBox(
                    height: 58 * responsive.scale,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.search),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accentDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      child: Text(
                      tr('Đặt phòng khác', 'Book another room'),
                        style: TextStyle(color: Colors.white, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  SizedBox(height: 14 * responsive.scale),
                  BookingOutlineButton(
                    label: tr('Liên hệ hỗ trợ', 'Contact support'),
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.hotelInfoForm),
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
