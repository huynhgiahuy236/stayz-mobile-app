import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/profile/presentation/widgets/profile_widgets.dart';
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
            const ProfileHeader(title: 'Phương thức thanh toán', trailing: Text('StayZ')),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  SizedBox(height: 52 * responsive.scale),
                  Text(
                    'Tài khoản thanh toán',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.ink,
                      fontSize: 36 * responsive.scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 24 * responsive.scale),
                  Text(
                    'Quản lý các phương thức thanh toán của bạn một cách an toàn và tinh tế.',
                    style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 23 * responsive.scale, height: 1.55),
                  ),
                  SizedBox(height: 72 * responsive.scale),
                  const ProfileSectionLabel(label: 'Thẻ đã lưu'),
                  SizedBox(height: 24 * responsive.scale),
                  const PaymentAccountTile(icon: Icons.credit_card, title: 'Visa', subtitle: '**** 1234', defaultBadge: true),
                  SizedBox(height: 22 * responsive.scale),
                  const PaymentAccountTile(icon: Icons.account_balance_wallet_outlined, title: 'Ví MoMo', subtitle: '0901***567'),
                  SizedBox(height: 48 * responsive.scale),
                  ProfilePrimaryButton(
                    label: '+  Thêm phương thức mới',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.addPaymentMethod),
                  ),
                  SizedBox(height: 82 * responsive.scale),
                  Divider(indent: 150 * responsive.widthScale, endIndent: 150 * responsive.widthScale),
                  SizedBox(height: 24 * responsive.scale),
                  Text(
                    'Bảo mật bởi tiêu chuẩn mã hóa Shibui-Z',
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
