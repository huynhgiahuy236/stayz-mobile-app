import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/data/auth_validators.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

/// Man doi mat khau chi den tu man OTP, nen luon co ca email lan ma da xac thuc.
class ResetPasswordArgs {
  const ResetPasswordArgs({required this.email, required this.code});

  final String email;
  final String code;
}

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  ResetPasswordArgs? _args;
  bool _initialized = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    _args = args is ResetPasswordArgs ? args : null;
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final args = _args;
    if (args == null) {
      _showMessage(
        tr(
          'Thiếu mã xác thực. Vui lòng bắt đầu lại từ bước quên mật khẩu.',
          'Missing verification code. Please restart the password reset flow.',
        ),
      );
      return;
    }

    final newPassword = _newPasswordController.text;
    final passwordError = AuthValidators.password(newPassword);
    if (passwordError != null) {
      _showMessage(passwordError);
      return;
    }

    final confirmError = AuthValidators.confirmPassword(
      newPassword,
      _confirmPasswordController.text,
    );
    if (confirmError != null) {
      _showMessage(confirmError);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Ma OTP la bat buoc. Truoc day chi can email la doi duoc mat khau
      // cua bat ky tai khoan nao.
      await AuthService.instance.resetPassword(
        email: args.email,
        code: args.code,
        newPassword: newPassword,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Đã đổi mật khẩu. Vui lòng đăng nhập lại.',
              'Password changed. Please sign in again.',
            ),
          ),
        ),
      );
      await _showSuccess();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
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

  Future<void> _showSuccess() => showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 34, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 42,
              backgroundColor: Color(0xFFE7F8EE),
              child: Icon(
                Icons.check_rounded,
                size: 48,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              tr('Đổi mật khẩu thành công!', 'Password updated!'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              tr(
                'Bạn có thể đăng nhập bằng mật khẩu mới.',
                'You can now sign in with your new password.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.muted, height: 1.5),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Text(tr('Tiếp tục', 'Continue')),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final args = _args;

    return AuthScaffold(
      child: Column(
        children: [
          AuthTopBar(title: tr('Mật khẩu mới', 'New password')),
          Divider(color: AppTheme.neutral200.withValues(alpha: 0.7), height: 1),
          Expanded(
            child: AuthScrollBody(
              bottomPadding: 80,
              children: [
                SizedBox(height: 28 * responsive.scale),
                AuthTitleBlock(
                  title: tr('Bảo vệ tài khoản', 'Secure your account'),
                  subtitle: args == null
                      ? tr(
                          'Không nhận được mã xác thực. Hãy bắt đầu lại từ bước quên mật khẩu.',
                          'No verification code was provided. Please restart the password reset flow.',
                        )
                      : tr(
                          'Đặt mật khẩu mới cho ${args.email}.',
                          'Set a new password for ${args.email}.',
                        ),
                ),
                SizedBox(height: 32 * responsive.scale),

                if (args == null) ...[
                  AuthPrimaryButton(
                    label: tr(
                      'Quay lại quên mật khẩu',
                      'Restart password reset',
                    ),
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.forgotPassword,
                          (route) => route.settings.name == AppRoutes.login,
                        ),
                  ),
                ] else ...[
                  AuthField(
                    label: tr('Mật khẩu mới', 'New password'),
                    hint: tr('Ít nhất 6 ký tự', 'At least 6 characters'),
                    obscure: true,
                    controller: _newPasswordController,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  AuthField(
                    label: tr('Xác nhận mật khẩu', 'Confirm password'),
                    hint: tr(
                      'Nhập lại mật khẩu mới',
                      'Enter the new password again',
                    ),
                    obscure: true,
                    controller: _confirmPasswordController,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 32 * responsive.scale),
                  AuthPrimaryButton(
                    label: tr('Cập nhật mật khẩu', 'Update password'),
                    onPressed: _isLoading ? null : _resetPassword,
                    loading: _isLoading,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
