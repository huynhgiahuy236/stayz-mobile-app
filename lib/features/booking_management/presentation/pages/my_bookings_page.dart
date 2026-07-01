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
      backgroundColor: const Color(0xFFFBF7F4),
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.bookings),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const BookingManageHeader(title: 'Dat phong cua toi'),
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
                    return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(responsive.horizontalPadding),
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) => SizedBox(height: 28 * responsive.scale),
                    itemBuilder: (context, index) {
                      final summary = bookings[index];

                      return UpcomingBookingCard(
                        name: summary.hotel.name,
                        location: '${summary.city.name}, ${summary.city.region}',
                        code: 'SZ-${summary.booking.id.substring(summary.booking.id.length - 5)}',
                        checkIn: StayzFormatters.shortDate(summary.booking.checkInDate),
                        checkOut: StayzFormatters.shortDate(summary.booking.checkOutDate),
                        colors: _bookingColors[index % _bookingColors.length],
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

const _bookingColors = [
  [Color(0xFF355348), Color(0xFFE0E8DA)],
  [Color(0xFF4C2014), Color(0xFFE79A30)],
  [Color(0xFF80512E), Color(0xFF32170B)],
];
