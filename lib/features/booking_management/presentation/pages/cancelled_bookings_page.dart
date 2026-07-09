import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:flutter/material.dart';

class CancelledBookingsPage extends StatefulWidget {
  const CancelledBookingsPage({super.key});

  @override
  State<CancelledBookingsPage> createState() => _CancelledBookingsPageState();
}

class _CancelledBookingsPageState extends State<CancelledBookingsPage> {
  Future<List<BookingSummary>>? _bookingsFuture;
  BookingSummary? _immediateSummary;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bookingsFuture != null) return;
    final args = ModalRoute.of(context)?.settings.arguments as BookingSummaryArgs?;
    _immediateSummary = args?.summary;
    _bookingsFuture = ApiStayzRepository.instance.getBookingSummaries();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final initialBookings = _initialCancelledBookings();

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
                future: _bookingsFuture,
                initialData: initialBookings.isEmpty ? null : initialBookings,
                builder: (context, snapshot) {
                  final bookings = _cancelledBookings(snapshot.data ?? initialBookings);

                  if (snapshot.hasError && bookings.isEmpty) {
                    return _CancelledEmptyState(
                      responsive: responsive,
                      message: snapshot.error.toString(),
                    );
                  }

                  if (bookings.isEmpty && snapshot.connectionState != ConnectionState.done) {
                    return _CancelledLoadingState(responsive: responsive);
                  }

                  if (bookings.isEmpty) {
                    return _CancelledEmptyState(responsive: responsive);
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      18 * responsive.scale,
                      responsive.horizontalPadding,
                      28 * responsive.scale,
                    ),
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) => SizedBox(height: 18 * responsive.scale),
                    itemBuilder: (context, index) => _CancelledBookingCard(
                      summary: bookings[index],
                      colors: _cancelledColors[index % _cancelledColors.length],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BookingSummary> _initialCancelledBookings() {
    final byId = <String, BookingSummary>{};
    for (final summary in ApiStayzRepository.cachedBookingSummaries) {
      if (summary.booking.status == 'cancelled') {
        byId[summary.booking.id] = summary;
      }
    }

    final immediate = _immediateSummary;
    if (immediate != null) {
      byId[immediate.booking.id] = _asCancelled(immediate);
    }

    return byId.values.toList(growable: false);
  }

  List<BookingSummary> _cancelledBookings(List<BookingSummary> source) {
    final byId = <String, BookingSummary>{
      for (final summary in _initialCancelledBookings()) summary.booking.id: summary,
    };

    for (final summary in source) {
      if (summary.booking.status == 'cancelled') {
        byId[summary.booking.id] = summary;
      }
    }

    return byId.values.toList(growable: false);
  }

  BookingSummary _asCancelled(BookingSummary summary) {
    if (summary.booking.status == 'cancelled') return summary;
    return BookingSummary(
      booking: summary.booking.copyWith(status: 'cancelled', paymentStatus: 'refunded'),
      room: summary.room,
      hotel: summary.hotel,
      city: summary.city,
    );
  }
}

class _CancelledLoadingState extends StatelessWidget {
  const _CancelledLoadingState({required this.responsive});

  final HomeResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.accent),
          SizedBox(height: 16 * responsive.scale),
          Text(
            'Dang tai booking da huy...',
            style: TextStyle(
              color: AppTheme.neutral500,
              fontSize: 15 * responsive.scale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelledEmptyState extends StatelessWidget {
  const _CancelledEmptyState({required this.responsive, this.message});

  final HomeResponsive responsive;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 44 * responsive.scale,
              backgroundColor: const Color(0xFFF0E9E3),
              child: Icon(Icons.event_busy_outlined, color: const Color(0xFF6B5348), size: 36 * responsive.scale),
            ),
            SizedBox(height: 24 * responsive.scale),
            Text(
              'Chua co booking da huy',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: 20 * responsive.scale,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 10 * responsive.scale),
            Text(
              message ?? 'Khi ban huy dat phong, booking se xuat hien o day.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.neutral500,
                fontSize: 15 * responsive.scale,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelledBookingCard extends StatelessWidget {
  const _CancelledBookingCard({
    required this.summary,
    required this.colors,
  });

  final BookingSummary summary;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final imageUrl = summary.room.imageUrls.firstOrNull ?? summary.hotel.imageUrls.firstOrNull;

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.cancelledBookingDetail,
        arguments: BookingSummaryArgs(summary: summary),
      ),
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
            SizedBox(
              height: 120 * responsive.scale,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: imageUrl == null || imageUrl.isEmpty
                        ? CustomPaint(painter: LuxuryArchitecturalPainter(colors: colors))
                        : StayZNetworkImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            height: 120 * responsive.scale,
                          ),
                  ),
                  Positioned(
                    top: 14 * responsive.scale,
                    right: 14 * responsive.widthScale,
                    child: const BookingStatusPill(label: 'Da huy', color: Color(0xFFFFD8D5)),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                              'TONG HOAN',
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
                          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.search),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.ink,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(horizontal: 16 * responsive.widthScale),
                          ),
                          child: Text(
                            'Tim phong khac',
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
    );
  }
}

const _cancelledColors = [
  [Color(0xFF2E4C2F), Color(0xFFE6A735)],
  [Color(0xFF5D7D8F), Color(0xFF151E24)],
];
