import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AuthScaffold(
      child: Column(
        children: [
          const AuthTopBar(title: 'Đổi mật khẩu'),
          Divider(color: AppTheme.neutral200.withValues(alpha: 0.7), height: 1),
          Expanded(
            child: AuthScrollBody(
              bottomPadding: 80,
              children: [
                Center(
                  child: Container(
                    width: 64 * responsive.scale,
                    height: 4 * responsive.scale,
                    margin: EdgeInsets.only(top: 48 * responsive.scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0C7C7),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                SizedBox(height: 58 * responsive.scale),
                const AuthTitleBlock(
                  title: 'Bảo mật tài khoản',
                  subtitle:
                      'Vui lòng nhập mật khẩu hiện tại và mật khẩu mới để tiếp tục bảo vệ quyền riêng tư của bạn.',
                ),
                SizedBox(height: 52 * responsive.scale),
                const AuthField(
                  label: 'MẬT KHẨU HIỆN TẠI',
                  hint: '••••••••',
                  obscure: true,
                ),
                SizedBox(height: 34 * responsive.scale),
                const AuthField(
                  label: 'MẬT KHẨU MỚI',
                  hint: '••••••••',
                  obscure: true,
                ),
                SizedBox(height: 34 * responsive.scale),
                const AuthField(
                  label: 'XÁC NHẬN MẬT KHẨU MỚI',
                  hint: '••••••••',
                  obscure: true,
                ),
                SizedBox(height: 52 * responsive.scale),
                AuthPrimaryButton(
                  label: 'Cập nhật mật khẩu',
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  ),
                ),
                SizedBox(height: 58 * responsive.scale),
                const Divider(color: AppTheme.neutral200),
                SizedBox(height: 24 * responsive.scale),
                Center(
                  child: Text(
                    'Nếu bạn quên mật khẩu, vui lòng liên hệ bộ phận\nhỗ trợ của StayZ để được khôi phục.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5A3F3F),
                      fontSize: 15 * responsive.scale,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
