import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/data/booking_status_presentation.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:flutter/material.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';

class CompletedBookingDetailPage extends StatelessWidget {
  const CompletedBookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;
    final args =
        ModalRoute.of(context)?.settings.arguments as BookingSummaryArgs?;
    final summary = args?.summary;

    if (summary == null) {
      return Scaffold(
        backgroundColor: AppTheme.cream,
        body: SafeArea(
          child: Center(
            child: Text(
              tr('Thiếu thông tin đặt phòng.', 'Missing booking detail.'),
            ),
          ),
        ),
      );
    }

    final imageUrl =
        summary.room.imageUrls.firstOrNull ??
        summary.hotel.imageUrls.firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      body: SafeArea(
        child: Column(
          children: [
            BookingTopBar(
              title: tr('Chi tiết đặt phòng', 'Booking details'),
              fallbackRoute: AppRoutes.completedBookings,
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  Row(
                    children: [
                      BookingStatusPill(
                        label: tr('Đã hoàn thành', 'Completed'),
                        color: AppTheme.notificationSuccessBorder.withValues(
                          alpha: 0.32,
                        ),
                        textColor: AppTheme.notificationSuccessText,
                      ),
                      const Spacer(),
                      Text(
                        tr(
                          'MÃ: ${_bookingCode(summary.booking.id)}',
                          'CODE: ${_bookingCode(summary.booking.id)}',
                        ),
                        style: TextStyle(
                          color: AppTheme.ink,
                          fontSize: 14 * responsive.scale,
                          letterSpacing: 1.3,
                        ),
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
                      child: const Icon(
                        Icons.hotel_outlined,
                        color: AppTheme.neutral500,
                      ),
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
                    title: tr('Thông tin lưu trú', 'Stay information'),
                    children: [
                      DetailLine(
                        label: tr('Nhận phòng', 'Check-in'),
                        value: StayzFormatters.shortDate(
                          summary.booking.checkInDate,
                        ),
                      ),
                      DetailLine(
                        label: tr('Trả phòng', 'Check-out'),
                        value: StayzFormatters.shortDate(
                          summary.booking.checkOutDate,
                        ),
                      ),
                      DetailLine(
                        label: tr('Số đêm', 'Nights'),
                        value: tr(
                          '${summary.booking.nights} đêm',
                          '${summary.booking.nights} nights',
                        ),
                      ),
                      DetailLine(
                        label: tr('Khách lưu trú', 'Guests'),
                        value: tr(
                          '${summary.booking.guests.adults + summary.booking.guests.children} khách',
                          '${summary.booking.guests.adults + summary.booking.guests.children} guests',
                        ),
                      ),
                      DetailLine(
                        label: tr('Trạng thái nhận phòng', 'Check-in status'),
                        value: bookingAttendanceLabel(summary.booking),
                        valueColor: AppTheme.notificationSuccessText,
                      ),
                    ],
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  BookingDetailPanel(
                    title: tr('Chi tiết phòng', 'Room details'),
                    children: [
                      DetailLine(
                        label: tr('Khách sạn', 'Hotel'),
                        value: summary.hotel.name,
                      ),
                      DetailLine(
                        label: tr('Loại phòng', 'Room type'),
                        value: summary.room.name,
                      ),
                      DetailLine(
                        label: tr('Giá mỗi đêm', 'Price per night'),
                        value: StayzFormatters.fullVnd(
                          summary.room.pricePerNight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  BookingDetailPanel(
                    title: tr('Chi tiết thanh toán', 'Payment details'),
                    children: [
                      DetailLine(
                        label: tr('Tiền phòng', 'Room charge'),
                        value: StayzFormatters.fullVnd(
                          summary.booking.totalAmount,
                        ),
                      ),
                      DetailLine(
                        label: tr('Phí dịch vụ & Thuế', 'Service fee & taxes'),
                        value: tr('Đã bao gồm', 'Included'),
                      ),
                      if ((summary.booking.remainingAtHotel ?? 0) > 0)
                        DetailLine(
                          label: tr(
                            'Còn lại trả tại khách sạn',
                            'Due at property',
                          ),
                          value: StayzFormatters.fullVnd(
                            summary.booking.remainingAtHotel!,
                          ),
                        ),
                      const Divider(),
                      DetailLine(
                        label: summary.booking.paymentPlan == 'deposit_30'
                            ? tr('Đã thanh toán (30%)', 'Amount paid (30%)')
                            : tr('Đã thanh toán', 'Amount paid'),
                        value: StayzFormatters.fullVnd(
                          summary.booking.amountPaid ??
                              summary.booking.totalAmount,
                        ),
                        total: true,
                        valueColor: summary.booking.paymentPlan == 'deposit_30'
                            ? AppTheme.depositText
                            : const Color(0xFF159A61),
                      ),
                    ],
                  ),
                  SizedBox(height: 34 * responsive.scale),
                  SizedBox(
                    height: 58 * responsive.scale,
                    child: FilledButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.review, arguments: args),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        tr('Đánh giá dịch vụ', 'Review your stay'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18 * responsive.scale,
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

  String _bookingCode(String id) {
    if (id.isEmpty) return 'SZ';
    final suffix = id.length > 5 ? id.substring(id.length - 5) : id;
    return 'SZ-$suffix';
  }
}
