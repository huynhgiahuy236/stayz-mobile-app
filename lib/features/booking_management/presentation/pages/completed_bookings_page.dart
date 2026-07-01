import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class CompletedBookingsPage extends StatelessWidget {
  const CompletedBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.bookings),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const BookingManageHeader(title: 'Dat phong cua toi', trailing: _BrandText()),
            const BookingManageTabs(
              activeTab: BookingManageTab.completed,
              upcomingRoute: AppRoutes.myBookings,
              completedRoute: AppRoutes.completedBookings,
              cancelledRoute: AppRoutes.cancelledBookings,
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.completedBookingDetail),
                    borderRadius: BorderRadius.circular(16),
                    child: HistoryBookingCard(
                      name: 'Dalat Edensee Lake Resort',
                      date: '12 thg 10 - 15 thg 10, 2023',
                      price: '2.450.000 d',
                      colors: const [Color(0xFF27473D), Color(0xFFE2DCA6)],
                      onPrimary: () => Navigator.of(context).pushNamed(AppRoutes.review),
                    ),
                  ),
                  SizedBox(height: 28 * responsive.scale),
                  InkWell(
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.completedBookingDetail),
                    borderRadius: BorderRadius.circular(16),
                    child: HistoryBookingCard(
                      name: 'Mulberry Collection Silk Eco',
                      date: '05 thg 09 - 08 thg 09, 2023',
                      price: '1.820.000 d',
                      colors: const [Color(0xFF4D2416), Color(0xFFB87938)],
                      onPrimary: () => Navigator.of(context).pushNamed(AppRoutes.review),
                    ),
                  ),
                  SizedBox(height: 110 * responsive.scale),
                  CircleAvatar(
                    radius: 42 * responsive.scale,
                    backgroundColor: const Color(0xFFF0E9E3),
                    child: Icon(Icons.card_travel_outlined, color: AppTheme.neutral500, size: 34 * responsive.scale),
                  ),
                  SizedBox(height: 28 * responsive.scale),
                  Text(
                    'Ki niem cua ban',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF5A3F3F),
                      fontSize: 22 * responsive.scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 16 * responsive.scale),
                  Text(
                    'Moi chuyen di la mot cau chuyen. Hay luu lai cam xuc cua ban tai cac diem dung chan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.neutral500,
                      fontSize: 18 * responsive.scale,
                      height: 1.45,
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

class _BrandText extends StatelessWidget {
  const _BrandText();

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Text(
      'StayZ',
      style: textTheme.headlineMedium?.copyWith(
        color: AppTheme.accentDark,
        fontSize: 28 * responsive.scale,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
