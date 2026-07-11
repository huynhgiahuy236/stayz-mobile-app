import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.profile),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ProfileHeader(title: tr('Phương thức thanh toán', 'Payment methods'), trailing: const Text('StayZ')),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  SizedBox(height: 52 * responsive.scale),
                  Text(
                    tr('Tài khoản thanh toán', 'Payment accounts'),
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.ink,
                      fontSize: 36 * responsive.scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 24 * responsive.scale),
                  Text(
                    tr('Quản lý các phương thức thanh toán của bạn một cách an toàn.', 'Manage your payment methods securely.'),
                    style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 23 * responsive.scale, height: 1.55),
                  ),
                  SizedBox(height: 72 * responsive.scale),
                  Icon(Icons.account_balance_wallet_outlined, size: 72 * responsive.scale, color: AppTheme.neutral200),
                  SizedBox(height: 20 * responsive.scale),
                  Text(
                    tr('Chưa có phương thức thanh toán đã lưu', 'No saved payment methods'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.ink, fontSize: 20 * responsive.scale, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 12 * responsive.scale),
                  Text(
                    tr('Bạn sẽ chọn phương thức và thanh toán an toàn qua PayOS khi xác nhận đặt phòng.', 'You will choose a method and pay securely through PayOS when confirming a booking.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.muted, fontSize: 15 * responsive.scale, height: 1.5),
                  ),
                  SizedBox(height: 82 * responsive.scale),
                  Divider(indent: 150 * responsive.widthScale, endIndent: 150 * responsive.widthScale),
                  SizedBox(height: 24 * responsive.scale),
                  Text(
                    tr('Dữ liệu thanh toán được bảo mật', 'Your payment data is protected'),
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
