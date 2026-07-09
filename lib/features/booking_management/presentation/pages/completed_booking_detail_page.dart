import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:flutter/material.dart';

class CompletedBookingDetailPage extends StatelessWidget {
  const CompletedBookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;
    final args = ModalRoute.of(context)?.settings.arguments as BookingSummaryArgs?;
    final summary = args?.summary;

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
                      summary == null
                          ? 'Lantern House, Hoi An\nKhu pho co, Hoi An, Quang Nam'
                          : '${summary.hotel.name}\n${summary.city.name}, ${summary.city.region}',
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
                      DetailLine(
                        label: 'Nhận phòng',
                        value: summary == null ? '28 Th04, 2024\nTu 14:00' : StayzFormatters.shortDate(summary.booking.checkInDate),
                      ),
                      DetailLine(
                        label: 'Trả phòng',
                        value: summary == null ? '29 Th04, 2024\nTruoc 12:00' : StayzFormatters.shortDate(summary.booking.checkOutDate),
                      ),
                    ],
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Chi tiet phong',
                    children: [
                      DetailLine(
                        label: summary?.room.name ?? 'Phong Deluxe Double',
                        value: summary == null
                            ? '1 dem, 2 khach'
                            : '${summary.booking.nights} đêm, ${summary.booking.guests.adults + summary.booking.guests.children} khách',
                      ),
                    ],
                  ),
                  SizedBox(height: 42 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Chi tiet thanh toan',
                    children: [
                      DetailLine(
                        label: summary == null ? 'Gia phong (1 dem)' : 'Giá phòng (${summary.booking.nights} đêm)',
                        value: summary == null ? '₫1.600.000' : StayzFormatters.fullVnd(summary.booking.totalAmount),
                      ),
                      const DetailLine(label: 'Phi dich vu & Thue', value: 'Đã bao gồm'),
                      const Divider(),
                      DetailLine(
                        label: 'Tổng cộng',
                        value: summary == null ? '₫1.800.000' : StayzFormatters.fullVnd(summary.booking.totalAmount),
                        total: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 34 * responsive.scale),
                  SizedBox(
                    height: 58 * responsive.scale,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        AppRoutes.review,
                        arguments: args,
                      ),
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
                      onPressed: () => Navigator.of(context).maybePop(),
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
