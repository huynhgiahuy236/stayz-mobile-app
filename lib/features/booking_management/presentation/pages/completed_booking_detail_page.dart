import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:flutter/material.dart';

class CompletedBookingDetailPage extends StatelessWidget {
  const CompletedBookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;
    final args = ModalRoute.of(context)?.settings.arguments as BookingSummaryArgs?;
    final summary = args?.summary;

    if (summary == null) {
      return const Scaffold(
        backgroundColor: AppTheme.cream,
        bottomNavigationBar: StayZBottomNav(activeTab: HomeTab.bookings),
        body: SafeArea(child: Center(child: Text('Missing booking detail.'))),
      );
    }

    final imageUrl = summary.room.imageUrls.firstOrNull ?? summary.hotel.imageUrls.firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.bookings),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookingTopBar(
              title: 'Chi tiet dat phong',
              fallbackRoute: AppRoutes.completedBookings,
              trailing: const Icon(Icons.account_circle_outlined, color: AppTheme.accentDark),
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
                      Text(
                        'MA: ${_bookingCode(summary.booking.id)}',
                        style: TextStyle(color: AppTheme.ink, fontSize: 14 * responsive.scale, letterSpacing: 1.3),
                      ),
                    ],
                  ),
                  SizedBox(height: 22 * responsive.scale),
                  if (imageUrl == null || imageUrl.isEmpty)
                    Container(
                      height: 280 * responsive.scale,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.neutral200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.hotel_outlined, color: AppTheme.neutral500),
                    )
                  else
                    Stack(
                      children: [
                        StayZNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          height: 280 * responsive.scale,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        Positioned(
                          left: 20 * responsive.widthScale,
                          right: 20 * responsive.widthScale,
                          bottom: 20 * responsive.scale,
                          child: Text(
                            '${summary.hotel.name}\n${summary.city.name}, ${summary.city.region}',
                            style: textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 27 * responsive.scale,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 36 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Thong tin luu tru',
                    children: [
                      DetailLine(label: 'Nhan phong', value: StayzFormatters.shortDate(summary.booking.checkInDate)),
                      DetailLine(label: 'Tra phong', value: StayzFormatters.shortDate(summary.booking.checkOutDate)),
                      DetailLine(label: 'So dem', value: '${summary.booking.nights} dem'),
                      DetailLine(
                        label: 'Khach luu tru',
                        value: '${summary.booking.guests.adults + summary.booking.guests.children} khach',
                      ),
                    ],
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Chi tiet phong',
                    children: [
                      DetailLine(label: 'Khach san', value: summary.hotel.name),
                      DetailLine(label: 'Loai phong', value: summary.room.name),
                      DetailLine(label: 'Gia moi dem', value: StayzFormatters.fullVnd(summary.room.pricePerNight)),
                    ],
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Chi tiet thanh toan',
                    children: [
                      DetailLine(label: 'Tien phong', value: StayzFormatters.fullVnd(summary.booking.totalAmount)),
                      const DetailLine(label: 'Phi dich vu & Thue', value: 'Da bao gom'),
                      const Divider(),
                      DetailLine(
                        label: 'Tong cong',
                        value: StayzFormatters.fullVnd(summary.booking.totalAmount),
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
                      child: Text(
                        'Danh gia dich vu',
                        style: TextStyle(color: Colors.white, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w800),
                      ),
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

  String _bookingCode(String id) {
    if (id.isEmpty) return 'SZ';
    final suffix = id.length > 5 ? id.substring(id.length - 5) : id;
    return 'SZ-$suffix';
  }
}
