import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class CancelledBookingsPage extends StatelessWidget {
  const CancelledBookingsPage({super.key});

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
            const BookingManageHeader(title: 'StayZ', brand: true),
            const BookingManageTabs(
              activeTab: BookingManageTab.cancelled,
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
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.cancelledBookingDetail),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.neutral200),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 284 * responsive.scale,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [Color(0xFF2E4C2F), Color(0xFFE6A735)]),
                                ),
                              ),
                              Positioned(
                                top: 28 * responsive.scale,
                                right: 24 * responsive.widthScale,
                                child: const BookingStatusPill(label: 'Da huy', color: Color(0xFFFFD8D5)),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(26 * responsive.scale),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '15 thg 10 - 18 thg 10, 2023',
                                  style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 20 * responsive.scale),
                                ),
                                SizedBox(height: 14 * responsive.scale),
                                Text(
                                  'Boutique Hotel Hoi An',
                                  style: TextStyle(color: AppTheme.ink, fontSize: 22 * responsive.scale, fontWeight: FontWeight.w900),
                                ),
                                SizedBox(height: 16 * responsive.scale),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, color: const Color(0xFF5A3F3F), size: 24 * responsive.scale),
                                    SizedBox(width: 10 * responsive.widthScale),
                                    Expanded(
                                      child: Text(
                                        'Minh An, Hoi An, Quang Nam',
                                        style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 17 * responsive.scale),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(height: 42 * responsive.scale, color: const Color(0xFFD9B8B8)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'TONG CONG DA HOAN',
                                            style: TextStyle(
                                              color: const Color(0xFF5A3F3F),
                                              fontSize: 12 * responsive.scale,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                          SizedBox(height: 8 * responsive.scale),
                                          Text(
                                            '3.450.000d',
                                            style: TextStyle(
                                              color: AppTheme.accentDark,
                                              fontSize: 22 * responsive.scale,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 178 * responsive.widthScale,
                                      height: 58 * responsive.scale,
                                      child: FilledButton(
                                        onPressed: () {},
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppTheme.accentDark,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                        ),
                                        child: Text(
                                          'Tim phong khac',
                                          style: TextStyle(color: Colors.white, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 90 * responsive.scale),
                  CircleAvatar(
                    radius: 44 * responsive.scale,
                    backgroundColor: const Color(0xFFF0E9E3),
                    child: Icon(Icons.event_busy_outlined, color: const Color(0xFF6B5348), size: 36 * responsive.scale),
                  ),
                  SizedBox(height: 26 * responsive.scale),
                  Text(
                    'Ban khong con phong huy nao khac',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.ink, fontSize: 20 * responsive.scale),
                  ),
                  SizedBox(height: 14 * responsive.scale),
                  Text(
                    'Cac phong ban da huy trong vong 6 thang qua se xuat hien tai day.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 18 * responsive.scale, height: 1.45),
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
