import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:flutter/material.dart';

class CancelledBookingsPage extends StatelessWidget {
  const CancelledBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      backgroundColor: AppTheme.cream,
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
              child: FutureBuilder<List<BookingSummary>>(
                future: MockStayzRepository.instance.getBookingSummaries(),
                builder: (context, snapshot) {
                  final bookings = (snapshot.data ?? const <BookingSummary>[])
                      .where((summary) => summary.booking.status == 'cancelled')
                      .toList();

                  if (bookings.isEmpty && snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(responsive.horizontalPadding),
                    itemCount: bookings.isEmpty ? 1 : bookings.length + 1,
                    itemBuilder: (context, index) {
                      if (index == bookings.length) {
                        return Column(
                          children: [
                            SizedBox(height: (bookings.isEmpty ? 90 : 58) * responsive.scale),
                            CircleAvatar(
                              radius: 44 * responsive.scale,
                              backgroundColor: const Color(0xFFF0E9E3),
                              child: Icon(Icons.event_busy_outlined, color: const Color(0xFF6B5348), size: 36 * responsive.scale),
                            ),
                            SizedBox(height: 26 * responsive.scale),
                            Text(
                              bookings.isEmpty 
                                  ? 'Bạn không có phòng hủy nào' 
                                  : 'Bạn không còn phòng hủy nào khác',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.ink,
                                fontSize: 20 * responsive.scale,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 14 * responsive.scale),
                            Text(
                              'Các phòng bạn đã hủy trong vòng 6 tháng qua sẽ xuất hiện tại đây.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.neutral500,
                                fontSize: 16 * responsive.scale,
                                height: 1.45,
                              ),
                            ),
                          ],
                        );
                      }

                      final summary = bookings[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 28 * responsive.scale),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.cancelledBookingDetail),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppTheme.neutral200.withValues(alpha: 0.5)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neutral800.withValues(alpha: 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 120 * responsive.scale,
                                  width: double.infinity,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: LuxuryArchitecturalPainter(
                                            colors: _cancelledColors[index % _cancelledColors.length],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 14 * responsive.scale,
                                        right: 14 * responsive.widthScale,
                                        child: const BookingStatusPill(label: 'Đã hủy', color: Color(0xFFFFD8D5)),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(20 * responsive.scale),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${StayzFormatters.shortDate(summary.booking.checkInDate)} - ${StayzFormatters.shortDate(summary.booking.checkOutDate)}',
                                        style: TextStyle(color: AppTheme.neutral500, fontSize: 15 * responsive.scale, fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(height: 8 * responsive.scale),
                                      Text(
                                        summary.hotel.name,
                                        style: TextStyle(color: AppTheme.ink, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w800),
                                      ),
                                      SizedBox(height: 12 * responsive.scale),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_outlined, color: AppTheme.neutral500, size: 18 * responsive.scale),
                                          SizedBox(width: 6 * responsive.widthScale),
                                          Expanded(
                                            child: Text(
                                              '${summary.city.name}, ${summary.city.region}',
                                              style: TextStyle(color: AppTheme.neutral500, fontSize: 14 * responsive.scale, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(height: 32 * responsive.scale, color: AppTheme.neutral200.withValues(alpha: 0.6)),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'TỔNG CỘNG ĐÃ HOÀN',
                                                  style: TextStyle(
                                                    color: AppTheme.neutral500,
                                                    fontSize: 11 * responsive.scale,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                                SizedBox(height: 4 * responsive.scale),
                                                Text(
                                                  StayzFormatters.compactVnd(summary.booking.totalAmount),
                                                  style: TextStyle(
                                                    color: AppTheme.accentDark,
                                                    fontSize: 18 * responsive.scale,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 42 * responsive.scale,
                                            child: FilledButton(
                                              onPressed: () {},
                                              style: FilledButton.styleFrom(
                                                backgroundColor: AppTheme.ink,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                padding: EdgeInsets.symmetric(horizontal: 16 * responsive.widthScale),
                                              ),
                                              child: Text(
                                                'Tìm phòng khác',
                                                style: TextStyle(color: Colors.white, fontSize: 13 * responsive.scale, fontWeight: FontWeight.w700),
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
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _cancelledColors = [
  [Color(0xFF2E4C2F), Color(0xFFE6A735)],
  [Color(0xFF5D7D8F), Color(0xFF151E24)],
];
