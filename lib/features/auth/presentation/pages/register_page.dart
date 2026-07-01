import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);

    return AuthScaffold(
      child: Column(
        children: [
          const AuthTopBar(),
          Expanded(
            child: AuthScrollBody(
              bottomPadding: 72,
              children: [
                SizedBox(height: 28 * responsive.scale),
                const AuthTitleBlock(title: 'Tạo tài khoản'),
                SizedBox(height: 36 * responsive.scale),
                const AuthField(label: 'HỌ VÀ TÊN', hint: 'Nhập họ và tên'),
                SizedBox(height: 22 * responsive.scale),
                const AuthField(
                  label: 'EMAIL',
                  hint: 'example@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 22 * responsive.scale),
                AuthField(
                  label: 'SỐ ĐIỆN THOẠI',
                  hint: '901 234 567',
                  keyboardType: TextInputType.phone,
                  prefix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+84',
                        style: TextStyle(
                          color: AppTheme.ink,
                          fontSize: 17 * responsive.scale,
                        ),
                      ),
                      SizedBox(width: 10 * responsive.widthScale),
                      Container(
                        width: 1,
                        height: 24 * responsive.scale,
                        color: const Color(0xFFD8BDBD),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 22 * responsive.scale),
                const AuthField(
                  label: 'MẬT KHẨU',
                  hint: '••••••••',
                  obscure: true,
                ),
                SizedBox(height: 24 * responsive.scale),
                const _AgreementRow(),
                SizedBox(height: 40 * responsive.scale),
                AuthPrimaryButton(
                  label: 'Đăng ký',
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.otp,
                  ),
                ),
                SizedBox(height: 52 * responsive.scale),
                AuthInlineLink(
                  text: 'Đã có tài khoản?',
                  actionText: 'Đăng nhập',
                  onTap: () => Navigator.of(context).pushReplacementNamed(
                    AppRoutes.login,
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

class _AgreementRow extends StatelessWidget {
  const _AgreementRow();

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24 * responsive.scale,
          height: 24 * responsive.scale,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppTheme.neutral200),
          ),
        ),
        SizedBox(width: 16 * responsive.widthScale),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5A3F3F),
                fontSize: 14 * responsive.scale,
              ),
              children: const [
                TextSpan(text: 'Tôi đồng ý với '),
                TextSpan(
                  text: 'Điều khoản',
                  style: TextStyle(color: AppTheme.accent),
                ),
                TextSpan(text: ' & '),
                TextSpan(
                  text: 'Chính sách bảo mật',
                  style: TextStyle(color: AppTheme.accent),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
