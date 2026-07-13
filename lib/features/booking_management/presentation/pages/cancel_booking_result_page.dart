import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/payment_policy.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/data/stayz_taxonomy.dart';
import 'package:capstone_mobile/shared/widgets/stayz_alert.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class CancelBookingResultPage extends StatefulWidget {
  const CancelBookingResultPage({super.key});

  @override
  State<CancelBookingResultPage> createState() => _CancelBookingResultPageState();
}

class _CancelBookingResultPageState extends State<CancelBookingResultPage> {
  BookingSummary? _summary;
  String? _errorMessage;
  bool _isCancelling = true;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final args = ModalRoute.of(context)?.settings.arguments as BookingSummaryArgs?;
    // `_cancelBooking` goi setState ngay dau; hoan lai sau khi khung dung xong
    // de tranh "setState() called during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cancelBooking(args?.summary);
    });
  }

  Future<void> _cancelBooking(BookingSummary? summary) async {
    if (summary == null) {
      setState(() {
        _isCancelling = false;
        _errorMessage = 'Thiếu thông tin đặt phòng cần hủy.';
      });
      return;
    }

    setState(() {
      _isCancelling = true;
      _errorMessage = null;
      _summary = summary;
    });

    // Tinh hoan tien theo ma tran (cung ham voi hop thoai xac nhan).
    final plan = PaymentPolicy.fromSlug(summary.booking.paymentPlan);
    final paid = summary.booking.amountPaid ?? 0;
    final now = DateTime.now();
    final rate = PaymentPolicy.refundRatePercent(plan, summary.booking.checkInDate, now);
    final refund = paid > 0 ? PaymentPolicy.refundAmount(plan, paid, summary.booking.checkInDate, now) : 0;

    try {
      final updated = await ApiStayzRepository.instance.updateBookingStatus(
        summary.booking.id,
        'cancelled',
        refundAmount: refund,
        refundRate: rate,
      );
      await ApiStayzRepository.instance.getBookingSummaries();
      if (!mounted) return;
      setState(() {
        _summary = updated ?? summary.copyWithStatus('cancelled', refundAmount: refund, refundRate: rate);
        _isCancelling = false;
      });
      // Alert tuc thoi cho khach biet ket qua (khac voi thong bao luu lai trong danh sach).
      StayzAlert.show(
        context,
        type: StayzAlertType.success,
        title: tr('Đã hủy đặt phòng', 'Booking cancelled'),
        message: refund > 0
            ? tr('Yêu cầu hoàn ${StayzFormatters.fullVnd(refund)} ($rate%) đang chờ xử lý thủ công.', 'Your ${StayzFormatters.fullVnd(refund)} refund request ($rate%) is awaiting manual processing.')
            : tr('Không có khoản hoàn theo chính sách hủy.', 'No refund is due under the cancellation policy.'),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isCancelling = false;
        // Truoc day in nguyen exception (kem URL va body) ra man hinh.
        _errorMessage = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;
    final hasError = _errorMessage != null;
    final summary = _summary;

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
                      tr('Hủy đặt phòng', 'Cancel booking'),
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
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  46 * responsive.scale,
                  responsive.horizontalPadding,
                  28 * responsive.scale,
                ),
                children: [
                  CircleAvatar(
                    radius: 64 * responsive.scale,
                    backgroundColor: const Color(0xFFFFE9E8),
                    child: CircleAvatar(
                      radius: 46 * responsive.scale,
                      backgroundColor: Colors.white,
                      child: _isCancelling
                          ? const CircularProgressIndicator(color: AppTheme.accent)
                          : Icon(
                              hasError ? Icons.error_outline : Icons.check_rounded,
                              color: hasError ? Colors.redAccent : const Color(0xFF0D8A4E),
                              size: 52 * responsive.scale,
                            ),
                    ),
                  ),
                  SizedBox(height: 44 * responsive.scale),
                  Text(
                    hasError
                        ? tr('Không thể hủy đặt phòng', 'Unable to cancel booking')
                        : _isCancelling
                            ? 'Đang hủy đặt phòng'
                            : 'Đã hủy đặt phòng',
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
                        ? _errorMessage!
                        : summary == null
                            ? 'Đơn đang được cập nhật trong hệ thống.'
                            : 'Đơn tại ${summary.hotel.name} đã chuyển sang trạng thái đã hủy.',
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
                        _ResultLine(
                          label: tr('TRẠNG THÁI', 'STATUS'),
                          value: _isCancelling
                              ? tr('Đang xử lý', 'Processing')
                              : StayzTaxonomy.bookingStatusLabel(summary?.booking.normalizedStatus ?? 'cancelled'),
                        ),
                        const Divider(),
                        if (!_isCancelling && summary != null && (summary.booking.refundAmount ?? 0) > 0) ...[
                          _ResultLine(
                            label: tr('HOÀN TIỀN (${summary.booking.refundRate?.round() ?? 0}%)', 'REFUND (${summary.booking.refundRate?.round() ?? 0}%)'),
                            value: StayzFormatters.fullVnd(summary.booking.refundAmount ?? 0),
                          ),
                          const Divider(),
                        ],
                        _ResultLine(label: tr('MÃ ĐẶT PHÒNG', 'BOOKING CODE'), value: _bookingCode(summary)),
                      ],
                    ),
                  ),
                  if (!_isCancelling && !hasError) ...[
                    SizedBox(height: 16 * responsive.scale),
                    Text(
                      PaymentPolicy.refundDisclaimer,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.muted, fontSize: 12.5 * responsive.scale, height: 1.5),
                    ),
                  ],
                  SizedBox(height: 38 * responsive.scale),
                  _ResultButton(
                    label: tr('Xem đơn đã hủy', 'View cancelled booking'),
                    filled: true,
                    onTap: _isCancelling || hasError
                        ? null
                        : () => Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.cancelledBookings,
                              (route) => false,
                            ),
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  _ResultButton(
                    label: hasError ? tr('Thử lại', 'Try again') : tr('Tìm phòng khác', 'Find another room'),
                    onTap: hasError
                        ? () => _cancelBooking(_summary)
                        : () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.search, (route) => false),
                  ),
                ],
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
  const _ResultLine({required this.label, required this.value});

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

extension on BookingSummary {
  /// Ban sao local khi backend khong tra ve (mo phong): doi status + luu hoan tien.
  BookingSummary copyWithStatus(String status, {num? refundAmount, num? refundRate}) {
    return BookingSummary(
      booking: booking.copyWith(
        status: status,
        paymentStatus: (refundAmount ?? 0) > 0 ? 'refunded' : null,
        refundAmount: refundAmount,
        refundRate: refundRate,
      ),
      room: room,
      hotel: hotel,
      city: city,
    );
  }
}
