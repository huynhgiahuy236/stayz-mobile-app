import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage(tr('Vui lòng nhập họ tên, email và mật khẩu.', 'Please enter name, email and password.'));
      return;
    }
    if (password.length < 6) {
      _showMessage(tr('Mật khẩu phải có ít nhất 6 ký tự.', 'Password must be at least 6 characters.'));
      return;
    }
    if (!_agreedToTerms) {
      _showMessage(tr('Vui lòng đồng ý điều khoản trước khi đăng ký.', 'Please agree to the terms before registering.'));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.register(
        fullName: fullName,
        email: email,
        phoneNumber: phone,
        password: password,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Tạo tài khoản thành công. Vui lòng đăng nhập.', 'Account created. Please sign in.'))),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } catch (error) {
      if (mounted) _showMessage(_messageFromError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _messageFromError(Object error) {
    final text = error.toString();
    if (text.startsWith('HttpException: ')) {
      return text.replaceFirst('HttpException: ', '').split(', uri =').first;
    }
    return text;
  }

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
                AuthTitleBlock(title: tr('Tạo tài khoản', 'Create account')),
                SizedBox(height: 24 * responsive.scale),
                AuthField(
                  label: tr('HỌ VÀ TÊN', 'FULL NAME'),
                  hint: tr('Nhập họ tên', 'Enter your name'),
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 16 * responsive.scale),
                AuthField(
                  label: 'EMAIL',
                  hint: 'example@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 16 * responsive.scale),
                AuthField(
                  label: tr('SỐ ĐIỆN THOẠI', 'PHONE'),
                  hint: '901 234 567',
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  textInputAction: TextInputAction.next,
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
                AuthField(
                  label: tr('MẬT KHẨU', 'PASSWORD'),
                  hint: tr('Mật khẩu', 'Password'),
                  obscure: true,
                  controller: _passwordController,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 16 * responsive.scale),
                _AgreementRow(
                  value: _agreedToTerms,
                  onChanged: _isLoading ? (_) {} : (val) => setState(() => _agreedToTerms = val),
                ),
                SizedBox(height: 28 * responsive.scale),
                AuthPrimaryButton(
                  label: _isLoading ? tr('Đang tạo tài khoản...', 'Creating account...') : tr('Đăng ký', 'Register'),
                  onPressed: _isLoading ? () {} : _register,
                ),
                SizedBox(height: 36 * responsive.scale),
                AuthInlineLink(
                  text: tr('Đã có tài khoản?', 'Already have an account?'),
                  actionText: tr('Đăng nhập', 'Sign in'),
                  onTap: _isLoading ? () {} : () => Navigator.of(context).pop(),
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
              children: [
                TextSpan(text: tr('Tôi đồng ý với ', 'I agree to the ')),
                TextSpan(
                  text: tr('Điều khoản', 'Terms'),
                  style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' & '),
                TextSpan(
                  text: tr('Chính sách bảo mật', 'Privacy Policy'),
                  style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
