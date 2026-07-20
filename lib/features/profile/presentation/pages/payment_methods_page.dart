import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/widgets/stayz_brand_logo.dart';
import 'package:flutter/material.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ProfileHeader(
              title: tr('Phương thức thanh toán', 'Payment methods'),
              trailing: const StayZBrandLogo(size: 38, borderRadius: 11),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  SizedBox(height: 20 * responsive.scale),
                  Text(
                    tr('Thanh toán qua PayOS', 'Payments via PayOS'),
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.ink,
                      fontSize: 28 * responsive.scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12 * responsive.scale),
                  Text(
                    tr(
                      'StayZ không lưu số thẻ hoặc tài khoản ngân hàng. Bạn chọn phương thức trên cổng PayOS khi thanh toán từng đơn.',
                      'StayZ does not store card or bank-account details. You choose a method in PayOS for each booking payment.',
                    ),
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 16 * responsive.scale,
                      height: 1.55,
                    ),
                  ),
                  SizedBox(height: 40 * responsive.scale),
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 56 * responsive.scale,
                    color: AppTheme.neutral200,
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  Text(
                    tr(
                      'Không lưu phương thức thanh toán',
                      'Payment methods are not stored',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontSize: 20 * responsive.scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12 * responsive.scale),
                  Text(
                    tr(
                      'Bạn sẽ chọn phương thức và thanh toán an toàn qua PayOS khi xác nhận đặt phòng.',
                      'You will choose a method and pay securely through PayOS when confirming a booking.',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 15 * responsive.scale,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 40 * responsive.scale),
                  Divider(
                    indent: 96 * responsive.widthScale,
                    endIndent: 96 * responsive.widthScale,
                  ),
                  SizedBox(height: 24 * responsive.scale),
                  Text(
                    tr(
                      'Kết quả thanh toán chỉ được xác nhận sau webhook hợp lệ từ PayOS',
                      'Payment is confirmed only after a valid PayOS webhook',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.neutral200,
                      fontSize: 16 * responsive.scale,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
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
