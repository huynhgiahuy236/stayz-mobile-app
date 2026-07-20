import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/payment_policy.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:capstone_mobile/shared/widgets/stayz_state_views.dart';
import 'package:flutter/material.dart';

class PaymentCheckoutPage extends StatefulWidget {
  const PaymentCheckoutPage({super.key});

  @override
  State<PaymentCheckoutPage> createState() => _PaymentCheckoutPageState();
}

class _PaymentCheckoutPageState extends State<PaymentCheckoutPage> {
  bool _creatingPayment = false;
  PaymentPlan _selectedPlan = PaymentPlan.deposit30;

  /// Tao booking pending va payment mot lan, sau do tai su dung cung ma QR
  /// neu nguoi dung quay lai checkout trong cung phien man hinh.
  Future<void> _goToPayment(BookingDraft draft) async {
    if (_creatingPayment) return;
    final quote = PaymentPolicy.quote(_selectedPlan, draft.totalAmount);
    final payableDraft = draft.copyWith(
      paymentMethod: 'PayOS',
      paymentPlan: PaymentPolicy.slug(_selectedPlan),
      amountPaid: quote.payNow,
      remainingAtHotel: quote.remaining,
    );
    setState(() => _creatingPayment = true);
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Đang tạo booking chờ thanh toán...',
              'Creating a pending payment booking...',
            ),
          ),
        ),
      );
      final summary = await ApiStayzRepository.instance.createBooking(
        payableDraft,
      );
      if (summary == null)
        throw const ApiException('Could not create booking.');
      final payment = await ApiStayzRepository.instance.createPayOSPayment(
        summary.booking.id,
        paymentPlan: PaymentPolicy.slug(_selectedPlan),
      );
      final paymentArgs = PayOSPaymentArgs.fromPayment(
        summary: summary,
        payment: payment,
        fallbackAmount: quote.payNow,
      );
      if (paymentArgs.qrCode.isEmpty && paymentArgs.qrImageUrl.isEmpty)
        throw const ApiException('VietQR is missing.');
      if (!mounted) return;
      await Navigator.of(
        context,
      ).pushNamed(AppRoutes.paymentQr, arguments: paymentArgs);
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _creatingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final draft = ModalRoute.of(context)?.settings.arguments as BookingDraft?;

    if (draft == null) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(title: Text(tr('Thanh toán', 'Payment'))),
        body: StayzEmptyView(
          icon: Icons.receipt_long_outlined,
          title: tr('Thiếu thông tin đặt phòng', 'Missing booking details'),
          message: tr(
            'Hãy chọn lại phòng và ngày ở trước khi thanh toán.',
            'Select a room and stay dates before payment.',
          ),
          actionLabel: tr('Về trang chủ', 'Back to home'),
          onAction: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
        ),
      );
    }

    final quote = PaymentPolicy.quote(_selectedPlan, draft.totalAmount);
    final payNow = quote.payNow;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          responsive.horizontalPadding,
          16 * responsive.scale,
          responsive.horizontalPadding,
          16 * responsive.scale,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.line)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tr('Trả ngay', 'Pay now'),
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 13 * responsive.scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    StayzFormatters.fullVnd(payNow),
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 20 * responsive.scale,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10 * responsive.scale),
              BookingPrimaryButton(
                label: _creatingPayment
                    ? tr('Đang tạo thanh toán...', 'Creating payment...')
                    : tr('Thanh toán qua PayOS', 'Pay with PayOS'),
                onTap: _creatingPayment ? null : () => _goToPayment(draft),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookingTopBar(
              title: tr('Thanh toán', 'Payment'),
              onBack: () {
                final navigator = Navigator.of(context);
                if (navigator.canPop()) {
                  navigator.pop();
                } else {
                  navigator.pushReplacementNamed(
                    AppRoutes.bookingSchedule,
                    arguments: draft,
                  );
                }
              },
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  20 * responsive.scale,
                  responsive.horizontalPadding,
                  30 * responsive.scale,
                ),
                children: [
                  _CheckoutHotelCard(draft: draft),
                  SizedBox(height: 16 * responsive.scale),
                  _SectionCaption(
                    label: tr(
                      'Chọn hình thức thanh toán',
                      'Choose payment option',
                    ),
                  ),
                  SizedBox(height: 14 * responsive.scale),
                  _PlanCard(
                    plan: PaymentPlan.deposit30,
                    base: draft.totalAmount,
                    selected: _selectedPlan == PaymentPlan.deposit30,
                    onTap: () =>
                        setState(() => _selectedPlan = PaymentPlan.deposit30),
                  ),
                  SizedBox(height: 12 * responsive.scale),
                  _PlanCard(
                    plan: PaymentPlan.full100,
                    base: draft.totalAmount,
                    selected: _selectedPlan == PaymentPlan.full100,
                    onTap: () =>
                        setState(() => _selectedPlan = PaymentPlan.full100),
                  ),
                  SizedBox(height: 12 * responsive.scale),
                  Text(
                    tr(
                      'Số tiền PayOS được backend tính lại từ giá phòng và gói thanh toán bạn chọn. Booking sẽ nằm ở mục đang chờ thanh toán cho tới khi webhook PayOS hợp lệ.',
                      'PayOS amount is recalculated by the backend from the room price and selected payment option. The booking stays pending until a valid PayOS webhook confirms it.',
                    ),
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  Container(
                    padding: EdgeInsets.all(12 * responsive.scale),
                    decoration: BoxDecoration(
                      color: AppTheme.neutral200.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16 * responsive.scale,
                          color: AppTheme.muted,
                        ),
                        SizedBox(width: 8 * responsive.widthScale),
                        Expanded(
                          child: Text(
                            PaymentPolicy.refundDisclaimer,
                            style: TextStyle(
                              color: AppTheme.muted,
                              fontSize: 11.5 * responsive.scale,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
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

/// Thẻ chọn phương án: hiện số tiền trả ngay + các dòng chính sách.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.base,
    required this.selected,
    required this.onTap,
  });

  final PaymentPlan plan;
  final num base;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final quote = PaymentPolicy.quote(plan, base);
    final isFull = plan == PaymentPlan.full100;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.line,
              width: selected ? 1.8 : 1,
            ),
          ),
          padding: EdgeInsets.all(16 * responsive.scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? AppTheme.primary : AppTheme.muted,
                    size: 22 * responsive.scale,
                  ),
                  SizedBox(width: 10 * responsive.widthScale),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            PaymentPolicy.planLabel(plan),
                            style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: 16 * responsive.scale,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (isFull) ...[
                          SizedBox(width: 8 * responsive.widthScale),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.success,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              tr('Giảm 10%', 'Save 10%'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    StayzFormatters.fullVnd(quote.payNow),
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 17 * responsive.scale,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              if (quote.remaining > 0) ...[
                SizedBox(height: 6 * responsive.scale),
                Padding(
                  padding: EdgeInsets.only(left: 32 * responsive.widthScale),
                  child: Text(
                    tr(
                      'Còn ${StayzFormatters.fullVnd(quote.remaining)} trả tại khách sạn',
                      '${StayzFormatters.fullVnd(quote.remaining)} due at the hotel',
                    ),
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 12.5 * responsive.scale,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 12 * responsive.scale),
              for (final line in PaymentPolicy.policyLines(plan))
                Padding(
                  padding: EdgeInsets.only(
                    left: 32 * responsive.widthScale,
                    bottom: 5 * responsive.scale,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14 * responsive.scale,
                        color: AppTheme.success,
                      ),
                      SizedBox(width: 7 * responsive.widthScale),
                      Expanded(
                        child: Text(
                          line,
                          style: TextStyle(
                            color: AppTheme.ink,
                            fontSize: 12.5 * responsive.scale,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCaption extends StatelessWidget {
  const _SectionCaption({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: AppTheme.muted,
        fontSize: 12 * responsive.scale,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _CheckoutHotelCard extends StatelessWidget {
  const _CheckoutHotelCard({required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final imageUrl =
        draft.room.imageUrls.firstOrNull ??
        draft.hotel.hotel.imageUrls.firstOrNull;

    return Container(
      padding: EdgeInsets.all(18 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (imageUrl == null || imageUrl.isEmpty)
                Container(
                  width: 78 * responsive.scale,
                  height: 78 * responsive.scale,
                  decoration: BoxDecoration(
                    color: AppTheme.neutral200,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.hotel_outlined,
                    color: AppTheme.neutral500,
                  ),
                )
              else
                StayZNetworkImage(
                  imageUrl: imageUrl,
                  width: 78 * responsive.scale,
                  height: 78 * responsive.scale,
                  borderRadius: BorderRadius.circular(9),
                ),
              SizedBox(width: 18 * responsive.widthScale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.hotel.hotel.name,
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 16 * responsive.scale,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8 * responsive.scale),
                    Text(
                      draft.room.name,
                      style: TextStyle(
                        color: AppTheme.neutral500,
                        fontSize: 14 * responsive.scale,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 34 * responsive.scale, color: AppTheme.neutral200),
          _BookingInfoRow(
            label: tr('Nhận phòng', 'Check-in'),
            value: StayzFormatters.shortDate(draft.checkInDate),
          ),
          _BookingInfoRow(
            label: tr('Trả phòng', 'Check-out'),
            value: StayzFormatters.shortDate(draft.checkOutDate),
          ),
          _BookingInfoRow(
            label: tr('Số đêm', 'Nights'),
            value: tr('${draft.nights} đêm', '${draft.nights} nights'),
          ),
          _BookingInfoRow(
            label: tr('Số khách', 'Guests'),
            value: tr(
              '${draft.guestCount} khách',
              '${draft.guestCount} guests',
            ),
          ),
          _BookingInfoRow(
            label: tr('Số phòng', 'Rooms'),
            value: tr('${draft.roomCount} phòng', '${draft.roomCount} rooms'),
          ),
          _BookingInfoRow(
            label: tr('Giá mỗi đêm', 'Price per night'),
            value: StayzFormatters.fullVnd(draft.room.pricePerNight),
          ),
          Divider(height: 34 * responsive.scale, color: AppTheme.neutral200),
          _BookingInfoRow(
            label: tr('Tổng giá phòng', 'Room total'),
            value: StayzFormatters.fullVnd(draft.totalAmount),
          ),
        ],
      ),
    );
  }
}

class _BookingInfoRow extends StatelessWidget {
  const _BookingInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * responsive.scale),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: 14 * responsive.scale,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: 14 * responsive.scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
