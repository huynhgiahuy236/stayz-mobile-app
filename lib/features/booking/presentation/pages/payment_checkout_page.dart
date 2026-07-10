import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:flutter/material.dart';

class PaymentCheckoutPage extends StatefulWidget {
  const PaymentCheckoutPage({super.key});

  @override
  State<PaymentCheckoutPage> createState() => _PaymentCheckoutPageState();
}

class _PaymentCheckoutPageState extends State<PaymentCheckoutPage> {
  bool _isSubmitting = false;

  Future<void> _confirmBooking(BookingDraft draft) async {
    setState(() => _isSubmitting = true);
    try {
      final summary = await ApiStayzRepository.instance.createBooking(draft);
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        AppRoutes.bookingConfirmation,
        arguments: summary == null ? draft : BookingSummaryArgs(summary: summary),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final draft = ModalRoute.of(context)?.settings.arguments as BookingDraft?;

    if (draft == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFBF7F4),
        body: SafeArea(child: Center(child: Text('Thieu thong tin dat phong.'))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          responsive.horizontalPadding,
          18 * responsive.scale,
          responsive.horizontalPadding,
          20 * responsive.scale,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.8))),
        ),
        child: SafeArea(
          top: false,
          child: BookingPrimaryButton(
            label: _isSubmitting ? 'Dang dat phong...' : 'Thanh toan',
            onTap: _isSubmitting ? null : () => _confirmBooking(draft),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookingTopBar(
              title: 'Thanh toan',
              onBack: () {
                final navigator = Navigator.of(context);
                if (navigator.canPop()) {
                  navigator.pop();
                } else {
                  navigator.pushReplacementNamed(AppRoutes.bookingSchedule, arguments: draft);
                }
              },
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  24 * responsive.scale,
                  responsive.horizontalPadding,
                  30 * responsive.scale,
                ),
                children: [
                  _CheckoutHotelCard(draft: draft),
                  SizedBox(height: 28 * responsive.scale),
                  _SectionCaption(label: 'Phuong thuc thanh toan'),
                  SizedBox(height: 22 * responsive.scale),
                  const PaymentMethodTile(icon: Icons.payments_outlined, label: 'Thanh toan khi nhan phong', active: true),
                  SizedBox(height: 14 * responsive.scale),
                  const PaymentMethodTile(icon: Icons.credit_card, label: 'The tin dung / ghi no'),
                  SizedBox(height: 14 * responsive.scale),
                  const PaymentMethodTile(icon: Icons.account_balance_wallet_outlined, label: 'Vi MoMo'),
                  SizedBox(height: 14 * responsive.scale),
                  const PaymentMethodTile(icon: Icons.qr_code_2, label: 'ZaloPay'),
                  SizedBox(height: 38 * responsive.scale),
                  PriceLine(
                    label: 'Tien phong (${draft.nights} dem x ${draft.roomCount} phong)',
                    value: StayzFormatters.fullVnd(draft.roomSubtotal),
                  ),
                  SizedBox(height: 16 * responsive.scale),
                  PriceLine(
                    label: 'Thue & phi',
                    value: StayzFormatters.fullVnd(draft.serviceFee),
                  ),
                  Divider(height: 34 * responsive.scale, color: AppTheme.neutral200),
                  PriceLine(
                    label: 'Tong cong',
                    value: StayzFormatters.fullVnd(draft.totalAmount),
                    total: true,
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

class _SectionCaption extends StatelessWidget {
  const _SectionCaption({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: const Color(0xFF6B5348),
        fontSize: 12 * responsive.scale,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
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
    final imageUrl = draft.room.imageUrls.firstOrNull ?? draft.hotel.hotel.imageUrls.firstOrNull;

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
                  child: const Icon(Icons.hotel_outlined, color: AppTheme.neutral500),
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
                      style: TextStyle(color: AppTheme.neutral500, fontSize: 14 * responsive.scale),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 34 * responsive.scale, color: AppTheme.neutral200),
          _BookingInfoRow(label: 'Nhan phong', value: StayzFormatters.shortDate(draft.checkInDate)),
          _BookingInfoRow(label: 'Tra phong', value: StayzFormatters.shortDate(draft.checkOutDate)),
          _BookingInfoRow(label: 'So dem', value: '${draft.nights} dem'),
          _BookingInfoRow(label: 'So khach', value: '${draft.guestCount} khach'),
          _BookingInfoRow(label: 'So phong', value: '${draft.roomCount} phong'),
          _BookingInfoRow(label: 'Gia moi dem', value: StayzFormatters.fullVnd(draft.room.pricePerNight)),
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
            child: Text(label, style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 14 * responsive.scale)),
          ),
          Text(
            value,
            style: TextStyle(color: AppTheme.ink, fontSize: 14 * responsive.scale, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
