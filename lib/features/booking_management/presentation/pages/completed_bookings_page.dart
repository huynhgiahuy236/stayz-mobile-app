import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class CompletedBookingsPage extends StatelessWidget {
  const CompletedBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.bookings),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const BookingsScreenHeader(),
            const BookingManageTabs(
              activeTab: BookingManageTab.completed,
              upcomingRoute: AppRoutes.myBookings,
              completedRoute: AppRoutes.completedBookings,
              cancelledRoute: AppRoutes.cancelledBookings,
            ),
            Expanded(
              child: FutureBuilder<List<BookingSummary>>(
                future: ApiStayzRepository.instance.getBookingSummaries(),
                builder: (context, snapshot) {
                  final bookings = (snapshot.data ?? const <BookingSummary>[])
                      .where((summary) => summary.booking.isCompleted)
                      .toList();

                  if (bookings.isEmpty && snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                  }

                  if (bookings.isEmpty) {
                    return const _CompletedEmptyState();
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(responsive.horizontalPadding),
                    itemCount: bookings.isEmpty ? 1 : bookings.length + 1,
                    itemBuilder: (context, index) {
                      if (index == bookings.length) {
                        return Column(
                          children: [
                            SizedBox(height: (bookings.isEmpty ? 110 : 58) * responsive.scale),
                            CircleAvatar(
                              radius: 42 * responsive.scale,
                              backgroundColor: const Color(0xFFF0E9E3),
                              child: Icon(Icons.card_travel_outlined, color: AppTheme.neutral500, size: 34 * responsive.scale),
                            ),
                            SizedBox(height: 28 * responsive.scale),
                            Text(
                              tr('Kỷ niệm của bạn', 'Your memories'),
                              textAlign: TextAlign.center,
                              style: textTheme.headlineMedium?.copyWith(
                                fontFamily: 'Noto Serif JP',
                                color: AppTheme.accentDark,
                                fontSize: 22 * responsive.scale,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16 * responsive.scale),
                            Text(
                              tr('Mỗi chuyến đi là một câu chuyện. Hãy lưu lại cảm xúc của bạn tại các điểm dừng chân.', 'Every trip is a story. Capture how you felt at each stop.'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.neutral500,
                                fontSize: 16 * responsive.scale,
                                height: 1.45,
                              ),
                            ),
                          ],
                        );
                      }

                      final summary = bookings[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 24 * responsive.scale),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.completedBookingDetail,
                            arguments: BookingSummaryArgs(summary: summary),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: UpcomingBookingCard(
                            name: summary.hotel.name,
                            location: '${summary.city.name}, ${summary.city.region}',
                            code: 'SZ-${summary.booking.id.substring(summary.booking.id.length - 5)}',
                            checkIn: StayzFormatters.shortDate(summary.booking.checkInDate),
                            checkOut: StayzFormatters.shortDate(summary.booking.checkOutDate),
                            imageUrl: summary.room.imageUrls.firstOrNull ?? summary.hotel.imageUrls.firstOrNull,
                            colors: _completedColors[index % _completedColors.length],
                            statusLabel: tr('Đã hoàn thành', 'Completed'),
                            statusColor: const Color(0xFFBDF4D4),
                            statusTextColor: const Color(0xFF096A43),
                            paymentAmount: StayzFormatters.compactVnd(summary.booking.amountPaid ?? summary.booking.totalAmount),
                            deposit30: summary.booking.paymentPlan == 'deposit_30',
                            detailLabel: tr('Đánh giá', 'Review'),
                            secondaryLabel: tr('Đặt lại', 'Rebook'),
                            onCancel: () => Navigator.of(context).pushNamed(
                              AppRoutes.roomSelection,
                              arguments: RoomSelectionArgs(
                                hotel: HotelSummary(
                                  hotel: summary.hotel,
                                  city: summary.city,
                                  lowestPrice: summary.room.pricePerNight,
                                  availableRooms: summary.room.availableUnits,
                                ),
                                adults: summary.booking.guests.adults,
                                children: summary.booking.guests.children,
                              ),
                            ),
                            onDetail: () => Navigator.of(context).pushNamed(
                              AppRoutes.review,
                              arguments: BookingSummaryArgs(summary: summary),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedEmptyState extends StatelessWidget {
  const _CompletedEmptyState();

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
        child: Text(
          tr('Chưa có đặt phòng hoàn tất', 'No completed bookings'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 20 * responsive.scale,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

const _completedColors = [
  [Color(0xFF27473D), Color(0xFFE2DCA6)],
  [Color(0xFF4D2416), Color(0xFFB87938)],
];
