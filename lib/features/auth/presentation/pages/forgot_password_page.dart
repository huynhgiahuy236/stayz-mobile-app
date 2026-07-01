import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);

    return AuthScaffold(
      child: Column(
        children: [
          const AuthTopBar(),
          Expanded(
            child: AuthScrollBody(
              crossAxisAlignment: CrossAxisAlignment.center,
              bottomPadding: 84,
              children: [
                SizedBox(height: 130 * responsive.heightScale),
                const _ResetIcon(),
                SizedBox(height: 54 * responsive.scale),
                const AuthTitleBlock(
                  title: 'Quên mật khẩu',
                  subtitle:
                      'Nhập email của bạn để nhận hướng dẫn khôi phục mật khẩu.',
                  centered: true,
                ),
                SizedBox(height: 48 * responsive.scale),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AuthField(
                    label: 'EMAIL',
                    hint: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                SizedBox(height: 30 * responsive.scale),
                AuthPrimaryButton(
                  label: 'Gửi mã',
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.otp,
                  ),
                ),
                SizedBox(height: 42 * responsive.scale),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.support_agent_outlined),
                  label: const Text('Liên hệ hỗ trợ'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accent,
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

class _ResetIcon extends StatelessWidget {
  const _ResetIcon();

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);

    return Container(
      width: 96 * responsive.scale,
      height: 96 * responsive.scale,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF0EE),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Icon(
        Icons.lock_reset,
        color: AppTheme.accentDark,
        size: 34 * responsive.scale,
      ),
    );
  }
}
