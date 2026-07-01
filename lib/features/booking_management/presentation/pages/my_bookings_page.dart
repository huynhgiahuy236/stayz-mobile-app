import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
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
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  UpcomingBookingCard(
                    name: 'Da Lat Palace',
                    location: 'Da Lat, Lam Dong',
                    code: 'SZ-2024-08741',
                    checkIn: '12/07/2024',
                    checkOut: '14/07/2024',
                    colors: const [Color(0xFF355348), Color(0xFFE0E8DA)],
                    onDetail: () => Navigator.of(context).pushNamed(AppRoutes.upcomingBookingDetail),
                    onCancel: () => Navigator.of(context).pushNamed(AppRoutes.cancelBookingResult),
                  ),
                  SizedBox(height: 28 * responsive.scale),
                  UpcomingBookingCard(
                    name: 'Lantern House Hoi An',
                    location: 'Hoi An, Quang Nam',
                    code: 'SZ-2024-09122',
                    checkIn: '20/08/2024',
                    checkOut: '22/08/2024',
                    colors: const [Color(0xFF4C2014), Color(0xFFE79A30)],
                    onDetail: () => Navigator.of(context).pushNamed(AppRoutes.upcomingBookingDetail),
                    onCancel: () => Navigator.of(context).pushNamed(AppRoutes.cancelBookingResult),
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
