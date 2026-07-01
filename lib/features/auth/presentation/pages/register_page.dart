import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _agreedToTerms = false;

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
                SizedBox(height: 20 * responsive.scale),
                const AuthTitleBlock(title: 'Tạo tài khoản'),
                SizedBox(height: 24 * responsive.scale),
                const AuthField(label: 'HỌ VÀ TÊN', hint: 'Nhập họ và tên'),
                SizedBox(height: 16 * responsive.scale),
                const AuthField(
                  label: 'EMAIL',
                  hint: 'example@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16 * responsive.scale),
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
                          fontSize: 16 * responsive.scale,
                        ),
                      ),
                      SizedBox(width: 10 * responsive.widthScale),
                      Container(
                        width: 1.5,
                        height: 20 * responsive.scale,
                        color: AppTheme.neutral200.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16 * responsive.scale),
                const AuthField(
                  label: 'MẬT KHẨU',
                  hint: '••••••••',
                  obscure: true,
                ),
                SizedBox(height: 16 * responsive.scale),
                _AgreementRow(
                  value: _agreedToTerms,
                  onChanged: (val) => setState(() => _agreedToTerms = val),
                ),
                SizedBox(height: 28 * responsive.scale),
                AuthPrimaryButton(
                  label: 'Đăng ký',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(height: 36 * responsive.scale),
                AuthInlineLink(
                  text: 'Đã có tài khoản?',
                  actionText: 'Đăng nhập',
                  onTap: () => Navigator.of(context).pop(),
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
  const _AgreementRow({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AuthCheckbox(
          value: value,
          onChanged: onChanged,
        ),
        SizedBox(width: 16 * responsive.widthScale),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.neutral500,
                fontSize: 14 * responsive.scale,
              ),
              children: const [
                TextSpan(text: 'Tôi đồng ý với '),
                TextSpan(
                  text: 'Điều khoản',
                  style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: ' & '),
                TextSpan(
                  text: 'Chính sách bảo mật',
                  style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
