import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class PaymentCheckoutPage extends StatelessWidget {
  const PaymentCheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

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
            label: 'Xac nhan dat phong',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.bookingConfirmation),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const BookingTopBar(title: 'Xac nhan dat phong'),
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
                  const _CheckoutHotelCard(),
                  SizedBox(height: 28 * responsive.scale),
                  _SectionCaption(label: 'Thong tin lien he'),
                  SizedBox(height: 24 * responsive.scale),
                  const CheckoutField(label: 'Ho va ten', value: 'Nguyen Minh Quan'),
                  SizedBox(height: 22 * responsive.scale),
                  const CheckoutField(label: 'Email', value: 'quan.nguyen@email.com'),
                  SizedBox(height: 22 * responsive.scale),
                  const CheckoutField(label: 'So dien thoai', value: '0901 234 567'),
                  SizedBox(height: 22 * responsive.scale),
                  const CheckoutField(
                    label: 'Yeu cau dac biet (khong bat buoc)',
                    value: 'Vi du: Phong khong hut thuoc, check-in som...',
                    large: true,
                  ),
                  SizedBox(height: 44 * responsive.scale),
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
                  const PriceLine(label: 'Tien phong (2 dem)', value: 'd3.600.000'),
                  SizedBox(height: 16 * responsive.scale),
                  const PriceLine(label: 'Thue & phi', value: 'd360.000'),
                  Divider(height: 34 * responsive.scale, color: AppTheme.neutral200),
                  const PriceLine(label: 'Tong cong', value: 'd3.960.000', total: true),
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
  const _CheckoutHotelCard();

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

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
              Container(
                width: 78 * responsive.scale,
                height: 78 * responsive.scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  gradient: const LinearGradient(colors: [Color(0xFF355348), Color(0xFFE2ECE5)]),
                ),
              ),
              SizedBox(width: 18 * responsive.widthScale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Da Lat Palace',
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 16 * responsive.scale,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8 * responsive.scale),
                    Text(
                      'Phong Deluxe Garden View',
                      style: TextStyle(color: AppTheme.neutral500, fontSize: 14 * responsive.scale),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 34 * responsive.scale, color: AppTheme.neutral200),
          const _BookingInfoRow(label: 'Nhan phong', value: 'Thu Sau, 12/07/2024'),
          const _BookingInfoRow(label: 'Tra phong', value: 'Chu Nhat, 14/07/2024'),
          const _BookingInfoRow(label: 'So dem', value: '2 dem'),
          const _BookingInfoRow(label: 'So khach', value: '2 nguoi lon'),
        ],
      ),
    );
  }
}

class _BookingInfoRow extends StatelessWidget {
  const _BookingInfoRow({
    required this.label,
    required this.value,
  });

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
