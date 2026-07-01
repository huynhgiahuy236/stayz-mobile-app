import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);

    return AuthScaffold(
      child: AuthScrollBody(
        bottomPadding: 72,
        children: [
          SizedBox(height: 32 * responsive.scale),
          const AuthLogo(large: true),
          SizedBox(height: 36 * responsive.scale),
          const AuthTitleBlock(
            title: 'Chào mừng trở lại',
            subtitle: 'Đăng nhập để tiếp tục hành trình',
          ),
          SizedBox(height: 32 * responsive.scale),
          const AuthField(
            label: 'EMAIL',
            hint: 'example@email.com',
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 18 * responsive.scale),
          const AuthField(
            label: 'MẬT KHẨU',
            hint: '••••••••',
            obscure: true,
          ),
          SizedBox(height: 10 * responsive.scale),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.forgotPassword,
              ),
              child: Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 14 * responsive.scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: 20 * responsive.scale),
          AuthPrimaryButton(
            label: 'Đăng nhập',
            onPressed: () => Navigator.of(context).pushReplacementNamed(
              AppRoutes.home,
            ),
          ),
          SizedBox(height: 28 * responsive.scale),
          const AuthDivider(label: 'hoặc'),
          SizedBox(height: 24 * responsive.scale),
          const _GoogleButton(),
          SizedBox(height: 36 * responsive.scale),
          AuthInlineLink(
            text: 'Chưa có tài khoản?',
            actionText: 'Đăng ký',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.register),
          ),
        ],
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton();

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 56 * responsive.scale,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.ink,
          side: const BorderSide(color: AppTheme.neutral200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            GoogleLogo(size: 22 * responsive.scale),
            SizedBox(width: 14 * responsive.widthScale),
            Text(
              'Tiếp tục với Google',
              style: textTheme.bodyLarge?.copyWith(
                color: AppTheme.ink,
                fontSize: 16 * responsive.scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
