import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class UpcomingBookingDetailPage extends StatelessWidget {
  const UpcomingBookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: const _ThreeItemNav(active: 0),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const BookingManageHeader(
              title: 'Chi tiet dat phong',
              trailing: Icon(Icons.account_circle_outlined, color: AppTheme.accentDark),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 290 * responsive.scale,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(colors: [Color(0xFF1F332C), Color(0xFF81A185)]),
                        ),
                      ),
                      Positioned(
                        top: 18 * responsive.scale,
                        left: 18 * responsive.widthScale,
                        child: const BookingStatusPill(
                          label: 'Sap den',
                          color: Color(0xFF9BF0BF),
                          textColor: Color(0xFF055C3A),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24 * responsive.scale),
                  Text(
                    'The Mist Retreat',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.ink,
                      fontSize: 28 * responsive.scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10 * responsive.scale),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 18 * responsive.scale),
                      SizedBox(width: 6 * responsive.widthScale),
                      Text('Phuong 10, Da Lat', style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 16 * responsive.scale)),
                    ],
                  ),
                  SizedBox(height: 34 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Thong tin dat phong',
                    children: [
                      const DetailLine(label: 'Ma dat phong', value: 'STZ-2024-9988'),
                      const Divider(),
                      const DetailLine(label: 'Check-in', value: '14:00, 11 Th10\n2024'),
                      const DetailLine(label: 'Check-out', value: '12:00, 14 Th10\n2024'),
                      const Divider(),
                      const DetailLine(label: 'So khach', value: '2 nguoi lon'),
                      const Divider(),
                      const DetailLine(label: 'Loai phong', value: 'Deluxe Garden View'),
                    ],
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Chi tiet thanh toan',
                    children: [
                      const DetailLine(label: 'Gia phong', value: 'd3.200.000'),
                      const DetailLine(label: 'Thue va phi', value: 'd320.000'),
                      const Divider(),
                      const DetailLine(label: 'Tong thanh toan', value: 'd3.520.000', total: true),
                      const Divider(),
                      Text('The Visa (**** 1234)\nDa thanh toan: 10:30, 05 Th10 2024',
                          style: TextStyle(color: const Color(0xFF6B5348), fontSize: 14 * responsive.scale, height: 1.4)),
                    ],
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Ghi chu',
                    children: [
                      Text(
                        '"Yeu cau phong tang cao, yen tinh."',
                        style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 18 * responsive.scale, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  SizedBox(height: 34 * responsive.scale),
                  SizedBox(
                    height: 58 * responsive.scale,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cancelBookingResult),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.accentDark),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Huy dat phong', style: TextStyle(color: AppTheme.accentDark, fontSize: 18 * responsive.scale)),
                    ),
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  Text(
                    'Chinh sach huy: Hoan tien 100% neu huy truoc ngay 09 Th10 2024.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.neutral500, fontSize: 14 * responsive.scale, height: 1.4),
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

class _ThreeItemNav extends StatelessWidget {
  const _ThreeItemNav({required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final items = [
      (Icons.event_available_outlined, 'Reservations'),
      (Icons.history, 'History'),
      (Icons.person_outline, 'Account'),
    ];

    return Container(
      height: 78 * responsive.scale,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.7))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(items[i].$1, color: i == active ? AppTheme.accentDark : AppTheme.ink, size: 24 * responsive.scale),
                SizedBox(height: 5 * responsive.scale),
                Text(
                  items[i].$2,
                  style: TextStyle(
                    color: i == active ? AppTheme.accentDark : AppTheme.ink,
                    fontSize: 12 * responsive.scale,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
