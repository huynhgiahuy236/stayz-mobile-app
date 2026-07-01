import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class RoomSelectionPage extends StatelessWidget {
  const RoomSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.search),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookingTopBar(
              title: 'Chon phong',
              trailing: Icon(Icons.tune, color: AppTheme.accentDark, size: 24 * responsive.scale),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  30 * responsive.scale,
                  responsive.horizontalPadding,
                  24 * responsive.scale,
                ),
                children: [
                  const _StaySummaryCard(),
                  SizedBox(height: 42 * responsive.scale),
                  Text(
                    '3 LOAI PHONG',
                    style: TextStyle(
                      color: AppTheme.neutral500,
                      fontSize: 12 * responsive.scale,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  RoomOptionCard(
                    name: 'Phong Deluxe Garden View',
                    price: 'd1.800.000',
                    badge: 'Con 3 phong',
                    badgeColor: const Color(0xFF007044),
                    colors: const [Color(0xFF28341C), Color(0xFFB7D27A)],
                    onBook: () => Navigator.of(context).pushNamed(AppRoutes.bookingSchedule),
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  RoomOptionCard(
                    name: 'Phong Superior City View',
                    price: 'd2.200.000',
                    badge: 'Sap het',
                    note: 'Con 1 phong',
                    badgeColor: const Color(0xFFC06B00),
                    colors: const [Color(0xFF3D2514), Color(0xFFF0B36D)],
                    onBook: () => Navigator.of(context).pushNamed(AppRoutes.bookingSchedule),
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  RoomOptionCard(
                    name: 'Suite Executive',
                    price: 'd3.500.000',
                    badge: 'Con 2 phong',
                    badgeColor: const Color(0xFF007044),
                    colors: const [Color(0xFF4B4C42), Color(0xFFD9D1C2)],
                    onBook: () => Navigator.of(context).pushNamed(AppRoutes.bookingSchedule),
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

class _StaySummaryCard extends StatelessWidget {
  const _StaySummaryCard();

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(16 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, color: AppTheme.accentDark, size: 20 * responsive.scale),
          SizedBox(width: 14 * responsive.widthScale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: _DateText(title: 'Thu Sau, 12\nthg 7')),
                    Text('->', style: TextStyle(fontSize: 16 * responsive.scale)),
                    const Expanded(child: _DateText(title: 'Chu Nhat,\n14 thg 7')),
                  ],
                ),
                SizedBox(height: 12 * responsive.scale),
                Text(
                  '2 nguoi lon, 1 phong',
                  style: TextStyle(color: AppTheme.neutral500, fontSize: 12 * responsive.scale),
                ),
              ],
            ),
          ),
          SizedBox(width: 12 * responsive.widthScale),
          Column(
            children: [
              CircleAvatar(
                radius: 25 * responsive.scale,
                backgroundColor: AppTheme.neutral200.withValues(alpha: 0.5),
                child: Text(
                  '2\ndem',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.neutral500, fontSize: 14 * responsive.scale),
                ),
              ),
              SizedBox(height: 8 * responsive.scale),
              Text(
                'Thay doi',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 11 * responsive.scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateText extends StatelessWidget {
  const _DateText({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(color: AppTheme.ink, fontSize: 15 * responsive.scale, height: 1.35),
    );
  }
}
