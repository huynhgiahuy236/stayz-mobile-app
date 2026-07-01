import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class CompletedBookingDetailPage extends StatelessWidget {
  const CompletedBookingDetailPage({super.key});

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
            const BookingManageHeader(
              title: 'Hospitality',
              trailing: Icon(Icons.account_circle_outlined, color: AppTheme.accentDark),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  Row(
                    children: [
                      const BookingStatusPill(
                        label: 'Da hoan thanh',
                        color: AppTheme.ink,
                        textColor: Colors.white,
                      ),
                      const Spacer(),
                      Text('MA: #LH290424', style: TextStyle(color: AppTheme.ink, fontSize: 14 * responsive.scale, letterSpacing: 1.3)),
                    ],
                  ),
                  SizedBox(height: 22 * responsive.scale),
                  Container(
                    height: 280 * responsive.scale,
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.all(20 * responsive.scale),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(colors: [Color(0xFFD79B26), Color(0xFF3B2514)]),
                    ),
                    child: Text(
                      'Lantern House, Hoi An\nKhu pho co, Hoi An, Quang Nam',
                      style: textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 27 * responsive.scale,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: 36 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Thong tin luu tru',
                    children: [
                      const DetailLine(label: 'Nhan phong', value: '28 Th04, 2024\nTu 14:00'),
                      const DetailLine(label: 'Tra phong', value: '29 Th04, 2024\nTruoc 12:00'),
                    ],
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Chi tiet phong',
                    children: const [
                      DetailLine(label: 'Phong Deluxe Double', value: '1 dem, 2 khach'),
                    ],
                  ),
                  SizedBox(height: 42 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Chi tiet thanh toan',
                    children: const [
                      DetailLine(label: 'Gia phong (1 dem)', value: 'd1.600.000'),
                      DetailLine(label: 'Phi dich vu & Thue', value: 'd200.000'),
                      Divider(),
                      DetailLine(label: 'Tong cong', value: 'd1.800.000', total: true),
                    ],
                  ),
                  SizedBox(height: 34 * responsive.scale),
                  SizedBox(
                    height: 58 * responsive.scale,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.review),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Danh gia dich vu', style: TextStyle(color: Colors.white, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  SizedBox(height: 16 * responsive.scale),
                  SizedBox(
                    height: 58 * responsive.scale,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.neutral200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Tai hoa don dien tu', style: TextStyle(color: AppTheme.ink, fontSize: 17 * responsive.scale)),
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
