import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/data/auth_validators.dart';
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
      _showMessage('Thiếu mã xác thực. Vui lòng bắt đầu lại từ bước quên mật khẩu.');
      return;
    }

    final newPassword = _newPasswordController.text;
    final passwordError = AuthValidators.password(newPassword);
    if (passwordError != null) {
      _showMessage(passwordError);
      return;
    }

    final confirmError = AuthValidators.confirmPassword(newPassword, _confirmPasswordController.text);
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
        const SnackBar(content: Text('Đã đổi mật khẩu. Vui lòng đăng nhập lại.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final args = _args;

    return AuthScaffold(
      child: Column(
        children: [
          const AuthTopBar(title: 'Mật khẩu mới'),
          Divider(color: AppTheme.neutral200.withValues(alpha: 0.7), height: 1),
          Expanded(
            child: AuthScrollBody(
              bottomPadding: 80,
              children: [
                SizedBox(height: 28 * responsive.scale),
                AuthTitleBlock(
                  title: 'Bảo vệ tài khoản',
                  subtitle: args == null
                      ? 'Không nhận được mã xác thực. Hãy bắt đầu lại từ bước quên mật khẩu.'
                      : 'Đặt mật khẩu mới cho ${args.email}.',
                ),
                SizedBox(height: 32 * responsive.scale),

                if (args == null) ...[
                  AuthPrimaryButton(
                    label: 'Quay lại quên mật khẩu',
                    onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.forgotPassword,
                      (route) => route.settings.name == AppRoutes.login,
                    ),
                  ),
                ] else ...[
                  AuthField(
                    label: 'MẬT KHẨU MỚI',
                    hint: 'Ít nhất 6 ký tự',
                    obscure: true,
                    controller: _newPasswordController,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  AuthField(
                    label: 'NHẬP LẠI MẬT KHẨU',
                    hint: 'Nhập lại mật khẩu mới',
                    obscure: true,
                    controller: _confirmPasswordController,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 32 * responsive.scale),
                  AuthPrimaryButton(
                    label: 'Cập nhật mật khẩu',
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
