import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:flutter/material.dart';

class UpcomingBookingDetailPage extends StatelessWidget {
  const UpcomingBookingDetailPage({super.key});

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
                      if (imageUrl == null || imageUrl.isEmpty)
                        Container(
                          height: 290 * responsive.scale,
                          decoration: BoxDecoration(
                            color: AppTheme.neutral200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.hotel_outlined, color: AppTheme.neutral500),
                        )
                      else
                        StayZNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          height: 290 * responsive.scale,
                          borderRadius: BorderRadius.circular(12),
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
                    summary.hotel.name,
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
                      Expanded(
                        child: Text(
                          '${summary.city.name}, ${summary.city.region}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 16 * responsive.scale),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 34 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Thong tin dat phong',
                    children: [
                      DetailLine(label: 'Ma dat phong', value: _bookingCode(summary.booking.id)),
                      const Divider(),
                      DetailLine(label: 'Khach san', value: summary.hotel.name),
                      DetailLine(label: 'Loai phong', value: summary.room.name),
                      const Divider(),
                      DetailLine(label: 'Check-in', value: StayzFormatters.shortDate(summary.booking.checkInDate)),
                      DetailLine(label: 'Check-out', value: StayzFormatters.shortDate(summary.booking.checkOutDate)),
                      DetailLine(label: 'So dem', value: '${summary.booking.nights} dem'),
                      const Divider(),
                      DetailLine(
                        label: 'So khach',
                        value: '${summary.booking.guests.adults} nguoi lon, ${summary.booking.guests.children} tre em',
                      ),
                      DetailLine(label: 'Trang thai', value: summary.booking.status),
                    ],
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  BookingDetailPanel(
                    title: 'Chi tiet thanh toan',
                    children: [
                      DetailLine(label: 'Gia moi dem', value: StayzFormatters.fullVnd(summary.room.pricePerNight)),
                      DetailLine(label: 'So dem', value: '${summary.booking.nights}'),
                      const DetailLine(label: 'Thue va phi', value: 'Da bao gom'),
                      const Divider(),
                      DetailLine(
                        label: 'Tong thanh toan',
                        value: StayzFormatters.fullVnd(summary.booking.totalAmount),
                        total: true,
                      ),
                      const Divider(),
                      Text(
                        'Trang thai thanh toan: ${summary.booking.paymentStatus}',
                        style: TextStyle(color: const Color(0xFF6B5348), fontSize: 14 * responsive.scale, height: 1.4),
                      ),
                    ],
                  ),
                  if (summary.booking.specialRequest != null && summary.booking.specialRequest!.trim().isNotEmpty) ...[
                    SizedBox(height: 20 * responsive.scale),
                    BookingDetailPanel(
                      title: 'Ghi chu',
                      children: [
                        Text(
                          summary.booking.specialRequest!,
                          style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 18 * responsive.scale, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 34 * responsive.scale),
                  SizedBox(
                    height: 58 * responsive.scale,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        AppRoutes.cancelBookingResult,
                        arguments: args,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.accentDark),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Huy dat phong', style: TextStyle(color: AppTheme.accentDark, fontSize: 18 * responsive.scale)),
                    ),
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  Text(
                    'Chinh sach huy duoc ap dung theo dieu kien cua khach san.',
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

  String _bookingCode(String id) {
    if (id.isEmpty) return 'SZ';
    final suffix = id.length > 5 ? id.substring(id.length - 5) : id;
    return 'SZ-$suffix';
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
