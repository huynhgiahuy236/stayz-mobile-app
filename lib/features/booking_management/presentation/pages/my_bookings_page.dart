import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:flutter/material.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.bookings),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            StayZScreenHeader(
              title: 'Chuyến đi của tôi',
              subtitle: 'Lịch đặt',
              trailing: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.search),
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(backgroundColor: AppTheme.primarySoft, foregroundColor: AppTheme.primary),
              ),
            ),
            const BookingManageTabs(
              activeTab: BookingManageTab.upcoming,
              upcomingRoute: AppRoutes.myBookings,
              completedRoute: AppRoutes.completedBookings,
              cancelledRoute: AppRoutes.cancelledBookings,
            ),
            Expanded(
              child: FutureBuilder<List<BookingSummary>>(
                future: MockStayzRepository.instance.getBookingSummaries(),
                builder: (context, snapshot) {
                  final bookings = (snapshot.data ?? const <BookingSummary>[])
                      .where((summary) => summary.booking.status == 'pending' || summary.booking.status == 'confirmed')
                      .toList();

                  if (bookings.isEmpty && snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      18 * responsive.scale,
                      responsive.horizontalPadding,
                      24 * responsive.scale,
                    ),
                    itemCount: bookings.length + 1,
                    separatorBuilder: (_, __) => SizedBox(height: 16 * responsive.scale),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _TripSummaryCard(count: bookings.length);
                      }

                      final summary = bookings[index - 1];
                      return UpcomingBookingCard(
                        name: summary.hotel.name,
                        location: '${summary.city.name}, ${summary.city.region}',
                        code: 'SZ-${summary.booking.id.substring(summary.booking.id.length - 5)}',
                        checkIn: StayzFormatters.shortDate(summary.booking.checkInDate),
                        checkOut: StayzFormatters.shortDate(summary.booking.checkOutDate),
                        colors: _bookingColors[(index - 1) % _bookingColors.length],
                        onDetail: () => Navigator.of(context).pushNamed(AppRoutes.upcomingBookingDetail),
                        onCancel: () => Navigator.of(context).pushNamed(AppRoutes.cancelBookingResult),
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

class _TripSummaryCard extends StatelessWidget {
  const _TripSummaryCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(18 * responsive.scale),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 54 * responsive.scale,
            height: 54 * responsive.scale,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: Colors.white),
          ),
          SizedBox(width: 14 * responsive.widthScale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count lịch đặt sắp tới', style: TextStyle(color: Colors.white, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w900)),
                SizedBox(height: 5 * responsive.scale),
                Text('Xem chi tiết, đổi kế hoạch hoặc hủy đặt phòng khi cần.', style: TextStyle(color: Colors.white70, fontSize: 13 * responsive.scale, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _bookingColors = [
  [Color(0xFFEAF7FF), Color(0xFF1D8BD1)],
  [Color(0xFFDDEEFF), Color(0xFF0A4E83)],
  [Color(0xFFF8FCFF), Color(0xFF3A95D8)],
];
