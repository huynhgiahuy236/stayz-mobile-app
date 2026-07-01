import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:flutter/material.dart';

class AddPaymentMethodPage extends StatelessWidget {
  const AddPaymentMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          responsive.horizontalPadding,
          18 * responsive.scale,
          responsive.horizontalPadding,
          24 * responsive.scale,
        ),
        child: SafeArea(top: false, child: const ProfilePrimaryButton(label: 'Luu phuong thuc')),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                0,
                responsive.horizontalPadding,
                10 * responsive.scale,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      'Them phuong thuc moi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppTheme.accentDark,
                        fontSize: 25 * responsive.scale,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  const ProfileSectionLabel(label: 'Chon loai thanh toan'),
                  SizedBox(height: 20 * responsive.scale),
                  const _PaymentTypeTile(icon: Icons.credit_card, title: 'The Tin dung/Ghi no', subtitle: 'Visa, Mastercard, JCB'),
                  SizedBox(height: 52 * responsive.scale),
                  const _PaymentTypeTile(icon: Icons.account_balance_wallet_outlined, title: 'Vi dien tu', subtitle: 'MoMo, ZaloPay, ShopeePay'),
                  SizedBox(height: 20 * responsive.scale),
                  const _PaymentTypeTile(icon: Icons.account_balance, title: 'Chuyen khoan ngan hang', subtitle: 'Internet Banking / QR Code'),
                  SizedBox(height: 34 * responsive.scale),
                  Container(
                    height: 190 * responsive.scale,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(colors: [Color(0xFF1F1712), Color(0xFF8A1E25)]),
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

class _PaymentTypeTile extends StatelessWidget {
  const _PaymentTypeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(16 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24 * responsive.scale,
            backgroundColor: const Color(0xFFF4E8E4),
            child: Icon(icon, color: AppTheme.accentDark, size: 24 * responsive.scale),
          ),
          SizedBox(width: 20 * responsive.widthScale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: AppTheme.ink, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w800)),
                SizedBox(height: 6 * responsive.scale),
                Text(subtitle, style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 13 * responsive.scale)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppTheme.neutral500, size: 26 * responsive.scale),
        ],
      ),
    );
  }
}
