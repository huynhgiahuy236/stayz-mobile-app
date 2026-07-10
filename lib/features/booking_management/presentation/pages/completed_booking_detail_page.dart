import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:flutter/material.dart';

class CompletedBookingDetailPage extends StatelessWidget {
  const CompletedBookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;
    final args = ModalRoute.of(context)?.settings.arguments as BookingSummaryArgs?;
    final summary = args?.summary;

    if (summary == null) {
      return const Scaffold(
        backgroundColor: AppTheme.cream,
        bottomNavigationBar: StayZBottomNav(activeTab: HomeTab.bookings),
        body: SafeArea(child: Center(child: Text('Missing booking detail.'))),
      );
    }

    final imageUrl = summary.room.imageUrls.firstOrNull ?? summary.hotel.imageUrls.firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.bookings),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookingTopBar(
              title: 'Chi tiết đặt phòng',
              fallbackRoute: AppRoutes.completedBookings,
              trailing: const Icon(Icons.account_circle_outlined, color: AppTheme.accentDark),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  Row(
                    children: [
                      const BookingStatusPill(
                        label: 'Đã hoàn thành',
                        color: AppTheme.ink,
                        textColor: Colors.white,
                      ),
                      const Spacer(),
                      Text(
                        'MÃ: ${_bookingCode(summary.booking.id)}',
                        style: TextStyle(color: AppTheme.ink, fontSize: 14 * responsive.scale, letterSpacing: 1.3),
                      ),
                    ],
                  ),
                  SizedBox(height: 22 * responsive.scale),
                  if (imageUrl == null || imageUrl.isEmpty)
                    Container(
                      height: 280 * responsive.scale,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.neutral200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.hotel_outlined, color: AppTheme.neutral500),
                    )
                  else
                    Stack(
                      children: [
                        StayZNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          height: 280 * responsive.scale,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        Positioned(
                          left: 20 * responsive.widthScale,
                          right: 20 * responsive.widthScale,
                          bottom: 20 * responsive.scale,
                          child: Text(
                            '${summary.hotel.name}\n${summary.city.name}, ${summary.city.region}',
                            style: textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 27 * responsive.scale,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 36 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Thông tin lưu trú',
                    children: [
                      DetailLine(label: 'Nhận phòng', value: StayzFormatters.shortDate(summary.booking.checkInDate)),
                      DetailLine(label: 'Trả phòng', value: StayzFormatters.shortDate(summary.booking.checkOutDate)),
                      DetailLine(label: 'Số đêm', value: '${summary.booking.nights} đêm'),
                      DetailLine(
                        label: 'Khách lưu trú',
                        value: '${summary.booking.guests.adults + summary.booking.guests.children} khách',
                      ),
                    ],
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Chi tiết phòng',
                    children: [
                      DetailLine(label: 'Khách sạn', value: summary.hotel.name),
                      DetailLine(label: 'Loại phòng', value: summary.room.name),
                      DetailLine(label: 'Giá mỗi đêm', value: StayzFormatters.fullVnd(summary.room.pricePerNight)),
                    ],
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Chi tiết thanh toán',
                    children: [
                      DetailLine(label: 'Tiền phòng', value: StayzFormatters.fullVnd(summary.booking.totalAmount)),
                      const DetailLine(label: 'Phí dịch vụ & Thuế', value: 'Đã bao gồm'),
                      const Divider(),
                      DetailLine(
                        label: 'Tổng cộng',
                        value: StayzFormatters.fullVnd(summary.booking.totalAmount),
                        total: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 34 * responsive.scale),
                  SizedBox(
                    height: 58 * responsive.scale,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        AppRoutes.review,
                        arguments: args,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Đánh giá dịch vụ',
                        style: TextStyle(color: Colors.white, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w800),
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

  String _bookingCode(String id) {
    if (id.isEmpty) return 'SZ';
    final suffix = id.length > 5 ? id.substring(id.length - 5) : id;
    return 'SZ-$suffix';
  }
}
