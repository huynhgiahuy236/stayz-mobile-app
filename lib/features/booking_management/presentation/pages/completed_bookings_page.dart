import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:flutter/material.dart';

class CompletedBookingsPage extends StatelessWidget {
  const CompletedBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.bookings),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const BookingManageHeader(title: 'Đặt phòng của tôi', trailing: _BrandText()),
            const BookingManageTabs(
              activeTab: BookingManageTab.completed,
              upcomingRoute: AppRoutes.myBookings,
              completedRoute: AppRoutes.completedBookings,
              cancelledRoute: AppRoutes.cancelledBookings,
            ),
            Expanded(
              child: FutureBuilder<List<BookingSummary>>(
                future: ApiStayzRepository.instance.getBookingSummaries(),
                builder: (context, snapshot) {
                  final bookings = (snapshot.data ?? const <BookingSummary>[])
                      .where((summary) => summary.booking.status == 'completed')
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
                            SizedBox(height: (bookings.isEmpty ? 110 : 58) * responsive.scale),
                            CircleAvatar(
                              radius: 42 * responsive.scale,
                              backgroundColor: const Color(0xFFF0E9E3),
                              child: Icon(Icons.card_travel_outlined, color: AppTheme.neutral500, size: 34 * responsive.scale),
                            ),
                            SizedBox(height: 28 * responsive.scale),
                            Text(
                              'Kỷ niệm của bạn',
                              textAlign: TextAlign.center,
                              style: textTheme.headlineMedium?.copyWith(
                                fontFamily: 'Noto Serif JP',
                                color: AppTheme.accentDark,
                                fontSize: 22 * responsive.scale,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16 * responsive.scale),
                            Text(
                              'Mỗi chuyến đi là một câu chuyện. Hãy lưu lại cảm xúc của bạn tại các điểm dừng chân.',
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
                        padding: EdgeInsets.only(bottom: 24 * responsive.scale),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.completedBookingDetail,
                            arguments: BookingSummaryArgs(summary: summary),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: HistoryBookingCard(
                            name: summary.hotel.name,
                            date: '${StayzFormatters.shortDate(summary.booking.checkInDate)} - ${StayzFormatters.shortDate(summary.booking.checkOutDate)}',
                            price: StayzFormatters.compactVnd(summary.booking.totalAmount),
                            colors: _completedColors[index % _completedColors.length],
                            onPrimary: () => Navigator.of(context).pushNamed(
                              AppRoutes.review,
                              arguments: BookingSummaryArgs(summary: summary),
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

class _BrandText extends StatelessWidget {
  const _BrandText();

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Text(
      'StayZ',
      style: textTheme.headlineMedium?.copyWith(
        fontFamily: 'Noto Serif JP',
        color: AppTheme.accentDark,
        fontSize: 28 * responsive.scale,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

const _completedColors = [
  [Color(0xFF27473D), Color(0xFFE2DCA6)],
  [Color(0xFF4D2416), Color(0xFFB87938)],
];
