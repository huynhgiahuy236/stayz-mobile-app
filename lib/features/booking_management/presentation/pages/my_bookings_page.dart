import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/cancel_booking_dialog.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/widgets/stayz_state_views.dart';
import 'package:flutter/material.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  late Future<List<BookingSummary>> _bookingsFuture = _loadBookings();
  final Set<String> _openingPayments = <String>{};

  Future<List<BookingSummary>> _loadBookings() =>
      ApiStayzRepository.instance.getBookingSummaries();

  void _refreshBookings() {
    setState(() => _bookingsFuture = _loadBookings());
  }

  Future<void> _continuePayment(BookingSummary summary) async {
    final bookingId = summary.booking.id;
    if (_openingPayments.contains(bookingId)) return;
    setState(() => _openingPayments.add(bookingId));
    try {
      final payment = await ApiStayzRepository.instance.createPayOSPayment(
        bookingId,
      );
      final paymentArgs = PayOSPaymentArgs.fromPayment(
        summary: summary,
        payment: payment,
        fallbackAmount: summary.booking.totalAmount,
      );
      if (paymentArgs.qrCode.isEmpty && paymentArgs.qrImageUrl.isEmpty) {
        throw const ApiException('VietQR is missing.');
      }
      if (!mounted) return;
      await Navigator.of(context).pushNamed(
        AppRoutes.paymentQr,
        arguments: paymentArgs,
      );
      if (mounted) _refreshBookings();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _openingPayments.remove(bookingId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final focusedBookingId =
        ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.bookings),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const BookingsScreenHeader(),
            const BookingManageTabs(
              activeTab: BookingManageTab.upcoming,
              upcomingRoute: AppRoutes.myBookings,
              completedRoute: AppRoutes.completedBookings,
              cancelledRoute: AppRoutes.cancelledBookings,
            ),
            Expanded(
              child: FutureBuilder<List<BookingSummary>>(
                future: _bookingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return StayzErrorView(
                      error: snapshot.error,
                      onRetry: _refreshBookings,
                    );
                  }
                  final bookings = (snapshot.data ?? const <BookingSummary>[])
                      .where((summary) => summary.booking.isUpcoming)
                      .toList();
                  if (focusedBookingId != null) {
                    bookings.sort(
                      (a, b) => a.booking.id == focusedBookingId
                          ? -1
                          : b.booking.id == focusedBookingId
                          ? 1
                          : 0,
                    );
                  }

                  if (bookings.isEmpty &&
                      snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  }

                  if (bookings.isEmpty) {
                    return const _UpcomingEmptyState();
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      18 * responsive.scale,
                      responsive.horizontalPadding,
                      24 * responsive.scale,
                    ),
                    itemCount: bookings.length + 1,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: 16 * responsive.scale),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _TripSummaryCard(count: bookings.length);
                      }

                      final summary = bookings[index - 1];
                      return UpcomingBookingCard(
                        name: summary.hotel.name,
                        location:
                            '${summary.city.name}, ${summary.city.region}',
                        code:
                            'SZ-${summary.booking.id.substring(summary.booking.id.length - 5)}',
                        checkIn: StayzFormatters.shortDate(
                          summary.booking.checkInDate,
                        ),
                        checkOut: StayzFormatters.shortDate(
                          summary.booking.checkOutDate,
                        ),
                        imageUrl:
                            summary.room.imageUrls.firstOrNull ??
                            summary.hotel.imageUrls.firstOrNull,
                        colors:
                            _bookingColors[(index - 1) % _bookingColors.length],
                        pendingPayment:
                            summary.booking.isPaymentPending,
                        paymentExpired: summary.booking.isPaymentExpired,
                        paymentBusy: _openingPayments.contains(
                          summary.booking.id,
                        ),
                        onPay: () => _continuePayment(summary),
                        onDetail: () => Navigator.of(context).pushNamed(
                          AppRoutes.upcomingBookingDetail,
                          arguments: BookingSummaryArgs(summary: summary),
                        ),
                        // Hoi lai truoc, roi moi dieu huong sang man thuc thi huy.
                        onCancel: () async {
                          final confirmed = await confirmCancelBooking(
                            context,
                            summary,
                          );
                          if (!confirmed || !context.mounted) return;
                          await Navigator.of(context).pushNamed(
                            AppRoutes.cancelBookingResult,
                            arguments: BookingSummaryArgs(summary: summary),
                          );
                        },
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

class _TripSummaryCard extends StatelessWidget {
  const _TripSummaryCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(18 * responsive.scale),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 54 * responsive.scale,
            height: 54 * responsive.scale,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 14 * responsive.widthScale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('$count lịch đặt sắp tới', '$count upcoming bookings'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18 * responsive.scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5 * responsive.scale),
                Text(
                  tr(
                    'Xem chi tiết, đổi kế hoạch hoặc hủy đặt phòng khi cần.',
                    'View details, change plans, or cancel your booking when needed.',
                  ),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13 * responsive.scale,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingEmptyState extends StatelessWidget {
  const _UpcomingEmptyState();

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
        child: Text(
          tr('Chưa có đặt phòng sắp tới', 'No upcoming bookings'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 20 * responsive.scale,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

const _bookingColors = [
  [Color(0xFFEAF7FF), Color(0xFF1D8BD1)],
  [Color(0xFFDDEEFF), Color(0xFF0A4E83)],
  [Color(0xFFF8FCFF), Color(0xFF3A95D8)],
];
