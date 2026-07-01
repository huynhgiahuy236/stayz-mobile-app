import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class CancelledBookingDetailPage extends StatelessWidget {
  const CancelledBookingDetailPage({super.key});

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
              title: 'Chi tiet dat phong',
              trailing: Icon(Icons.account_circle_outlined, color: AppTheme.accentDark),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  BookingDetailPanel(
                    title: 'Ma dat phong: #HL-8291',
                    children: [
                      Row(
                        children: [
                          Text('Dat ngay 12 Th05, 2024', style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 14 * responsive.scale)),
                          const Spacer(),
                          const BookingStatusPill(label: 'Da huy', color: Color(0xFFFFD8D5)),
                        ],
                      ),
                      const Divider(),
                      Text('LY DO HUY', style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 13 * responsive.scale, letterSpacing: 1.5)),
                      SizedBox(height: 10 * responsive.scale),
                      Text('Thay doi ke hoach ca nhan.', style: TextStyle(color: AppTheme.ink, fontSize: 16 * responsive.scale)),
                    ],
                  ),
                  SizedBox(height: 42 * responsive.scale),
                  Container(
                    height: 284 * responsive.scale,
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.all(18 * responsive.scale),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(colors: [Color(0xFFD7C8AA), Color(0xFF82694E)]),
                    ),
                    child: const BookingStatusPill(
                      label: '1/8',
                      color: Colors.white,
                      textColor: AppTheme.ink,
                    ),
                  ),
                  SizedBox(height: 24 * responsive.scale),
                  Text(
                    'Minimal Loft',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.accentDark,
                      fontSize: 28 * responsive.scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10 * responsive.scale),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: const Color(0xFF5A3F3F), size: 20 * responsive.scale),
                      SizedBox(width: 8 * responsive.widthScale),
                      Text('Quan 1, TP. HCM', style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 16 * responsive.scale)),
                    ],
                  ),
                  SizedBox(height: 28 * responsive.scale),
                  const DetailLine(label: 'Nhan phong - Tra phong', value: '20 Th06 - 22 Th06, 2024'),
                  const DetailLine(label: 'Thoi gian', value: '2 dem'),
                  const DetailLine(label: 'Khach luu tru', value: '2 Nguoi lon, 1 Tre em'),
                  SizedBox(height: 28 * responsive.scale),
                  Container(
                    padding: EdgeInsets.all(20 * responsive.scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E9E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        DetailLine(label: 'Gia phong (2 dem)', value: 'd820.000'),
                        DetailLine(label: 'Phi dich vu', value: 'd80.000'),
                        DetailLine(label: 'Thue GTGT', value: 'd50.000'),
                        Divider(),
                        DetailLine(label: 'Tong cong', value: 'd950.000', total: true),
                      ],
                    ),
                  ),
                  SizedBox(height: 34 * responsive.scale),
                  SizedBox(
                    height: 58 * responsive.scale,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accentDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      child: Text('Dat lai phong nay', style: TextStyle(color: Colors.white, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  SizedBox(height: 14 * responsive.scale),
                  BookingOutlineButton(label: 'Lien he ho tro'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
