import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/otp_page.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/data/auth_validators.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Gui ma OTP that toi email, roi moi sang buoc nhap ma.
  /// Truoc day man nay nhay thang sang man doi mat khau, bo qua xac thuc.
  Future<void> _sendCode() async {
    final email = _emailController.text.trim();

    final error = AuthValidators.email(email);
    setState(() => _emailError = error);
    if (error != null) {
      _showMessage(error);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.requestPasswordReset(email: email);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Nếu email tồn tại, mã xác thực đã được gửi.',
              'If the email exists, a verification code has been sent.',
            ),
          ),
        ),
      );
      await Navigator.of(
        context,
      ).pushNamed(AppRoutes.otp, arguments: OtpArgs(email: email));
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);

    return AuthScaffold(
      child: Column(
        children: [
          AuthTopBar(
            title: tr('Quên mật khẩu', 'Recover password'),
            showLogo: false,
          ),
          Expanded(
            child: AuthScrollBody(
              crossAxisAlignment: CrossAxisAlignment.center,
              bottomPadding: 84,
              children: [
                SizedBox(height: 42 * responsive.heightScale),
                const _ResetIcon(),
                SizedBox(height: 32 * responsive.scale),
                AuthTitleBlock(
                  title: '',
                  subtitle: tr(
                    'Nhập email tài khoản, chúng tôi sẽ gửi mã xác thực gồm 6 chữ số.',
                    'Enter your account email and we will send a 6-digit verification code.',
                  ),
                  centered: true,
                ),
                SizedBox(height: 32 * responsive.scale),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AuthField(
                    label: tr('Địa chỉ email', 'Email address'),
                    hint: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    errorText: _emailError,
                    onChanged: (_) => setState(
                      () => _emailError = AuthValidators.email(_emailController.text),
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                SizedBox(height: 20 * responsive.scale),
                AuthPrimaryButton(
                  label: _isLoading
                      ? tr('Đang gửi mã...', 'Sending...')
                      : tr('Gửi mã xác thực', 'Send verification code'),
                  // `null` de nut that su bi vo hieu hoa khi dang tai,
                  // thay vi giu mau day du nhung bam khong an gi.
                  onPressed: _isLoading ? null : _sendCode,
                  loading: _isLoading,
                ),
                SizedBox(height: 28 * responsive.scale),
                TextButton.icon(
                  // Truoc day nut nay dieu huong sang... form thong tin khach san.
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.helpCenter),
                  icon: const Icon(Icons.support_agent_outlined),
                  label: Text(tr('Trung tâm hỗ trợ', 'Help center')),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
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
        color: AppTheme.accent.withValues(alpha: 0.06),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Container(
          width: 72 * responsive.scale,
          height: 72 * responsive.scale,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.neutral800.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.lock_reset,
            color: AppTheme.accent,
            size: 32 * responsive.scale,
          ),
        ),
      ),
    );
  }
}
