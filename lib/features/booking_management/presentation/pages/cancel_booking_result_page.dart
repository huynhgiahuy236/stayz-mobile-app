import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:flutter/material.dart';

class CancelBookingResultPage extends StatefulWidget {
  const CancelBookingResultPage({super.key});

  @override
  State<CancelBookingResultPage> createState() => _CancelBookingResultPageState();
}

class _CancelBookingResultPageState extends State<CancelBookingResultPage> {
  Future<BookingSummary?>? _cancelFuture;
  BookingSummary? _originalSummary;

  BookingSummary? _cancelledSummary(BookingSummary? summary) {
    if (summary == null) return null;
    if (summary.booking.status == 'cancelled') return summary;
    return BookingSummary(
      booking: summary.booking.copyWith(status: 'cancelled', paymentStatus: 'refunded'),
      room: summary.room,
      hotel: summary.hotel,
      city: summary.city,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_cancelFuture != null) return;
    final args = ModalRoute.of(context)?.settings.arguments as BookingSummaryArgs?;
    _originalSummary = args?.summary;
    final summary = _originalSummary;
    _cancelFuture = summary == null
        ? Future<BookingSummary?>.value(null)
        : ApiStayzRepository.instance.updateBookingStatus(summary.booking.id, 'cancelled');
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                18 * responsive.scale,
                responsive.horizontalPadding,
                20 * responsive.scale,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    color: AppTheme.accentDark,
                  ),
                  Expanded(
                    child: Text(
                      'Huy dat phong',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppTheme.accentDark,
                        fontSize: 30 * responsive.scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 48 * responsive.scale),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<BookingSummary?>(
                future: _cancelFuture,
                builder: (context, snapshot) {
                  final summary = _cancelledSummary(snapshot.data ?? _originalSummary);
                  final isLoading = snapshot.connectionState == ConnectionState.waiting;
                  final hasError = snapshot.hasError;

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      18 * responsive.scale,
                      responsive.horizontalPadding,
                      28 * responsive.scale,
                    ),
                    children: [
                      SizedBox(height: 28 * responsive.scale),
                      Column(
                      children: [
                        CircleAvatar(
                          radius: 64 * responsive.scale,
                          backgroundColor: const Color(0xFFFFE9E8),
                          child: CircleAvatar(
                            radius: 46 * responsive.scale,
                            backgroundColor: Colors.white,
                            child: Icon(
                              hasError ? Icons.error_outline : Icons.check_rounded,
                              color: hasError ? Colors.redAccent : const Color(0xFF0D8A4E),
                              size: 52 * responsive.scale,
                            ),
                          ),
                        ),
                        SizedBox(height: 44 * responsive.scale),
                        Text(
                          hasError
                              ? 'Khong the huy dat phong'
                              : isLoading
                                  ? 'Dang huy dat phong'
                                  : 'Da huy dat phong',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            color: AppTheme.accent,
                            fontSize: 31 * responsive.scale,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: 24 * responsive.scale),
                        Text(
                          hasError
                              ? snapshot.error.toString()
                              : summary == null
                                  ? 'Booking da duoc cap nhat trong he thong.'
                                  : 'Booking ${summary.hotel.name} da chuyen sang trang thai huy. Hoan tien du kien: ${StayzFormatters.fullVnd(summary.booking.totalAmount)}.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 17 * responsive.scale, height: 1.45),
                        ),
                        SizedBox(height: 38 * responsive.scale),
                        Container(
                          padding: EdgeInsets.all(20 * responsive.scale),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD9B8B8)),
                          ),
                          child: Column(
                            children: [
                              _ResultLine(label: 'TRANG THAI', value: isLoading ? 'Dang xu ly' : summary?.booking.status ?? 'cancelled'),
                              const Divider(),
                              _ResultLine(label: 'MA DAT PHONG', value: _bookingCode(summary)),
                            ],
                          ),
                        ),
                        SizedBox(height: 38 * responsive.scale),
                        _ResultButton(
                          label: 'Xem booking da huy',
                          filled: true,
                          onTap: isLoading || hasError
                              ? null
                              : () => Navigator.of(context).pushNamedAndRemoveUntil(
                                    AppRoutes.cancelledBookings,
                                    (route) => false,
                                    arguments: summary == null ? null : BookingSummaryArgs(summary: summary),
                                  ),
                        ),
                        SizedBox(height: 18 * responsive.scale),
                        _ResultButton(
                          label: 'Tim phong khac',
                          onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.search, (route) => false),
                        ),
                      ],
                    ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _bookingCode(BookingSummary? summary) {
    final id = summary?.booking.id;
    if (id == null || id.isEmpty) return 'SZ';
    final suffix = id.length > 5 ? id.substring(id.length - 5) : id;
    return 'SZ-$suffix';
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Row(
      children: [
        SizedBox(
          width: 120 * responsive.widthScale,
          child: Text(label, style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 16 * responsive.scale, letterSpacing: 2)),
        ),
        Expanded(
          child: Text(value, textAlign: TextAlign.right, style: TextStyle(color: AppTheme.ink, fontSize: 17 * responsive.scale, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _ResultButton extends StatelessWidget {
  const _ResultButton({
    required this.label,
    this.filled = false,
    this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return SizedBox(
      width: double.infinity,
      height: 58 * responsive.scale,
      child: filled
          ? FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(label, style: TextStyle(color: Colors.white, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w800)),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(label, style: TextStyle(color: AppTheme.accent, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w800)),
            ),
    );
  }
}
