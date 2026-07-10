import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/data/auth_validators.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final emailError = AuthValidators.email(email);
    if (emailError != null) {
      _showMessage(emailError);
      return;
    }
    if (password.isEmpty) {
      _showMessage('Vui lòng nhập mật khẩu.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.login(email: email, password: password);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } on ApiException catch (error) {
      // Thong diep da duoc dich san; khong con in URL va body loi ra man hinh.
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

    return AuthScaffold(
      child: AuthScrollBody(
        bottomPadding: 72,
        children: [
          SizedBox(height: 32 * responsive.scale),
          const AuthLogo(large: true),
          SizedBox(height: 36 * responsive.scale),
          const AuthTitleBlock(
            title: 'Chào mừng trở lại',
            subtitle: 'Đăng nhập để tiếp tục hành trình StayZ của bạn.',
          ),
          SizedBox(height: 32 * responsive.scale),
          AuthField(
            label: 'EMAIL',
            hint: 'example@email.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            controller: _emailController,
          ),
          SizedBox(height: 18 * responsive.scale),
          AuthField(
            label: 'MẬT KHẨU',
            hint: 'Password',
            obscure: true,
            textInputAction: TextInputAction.done,
            controller: _passwordController,
          ),
          SizedBox(height: 10 * responsive.scale),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
              child: Text(
                'Forgot password?',
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
            label: _isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
            onPressed: _isLoading ? null : _login,
            loading: _isLoading,
          ),
          SizedBox(height: 28 * responsive.scale),
          const AuthDivider(label: 'hoặc'),
          SizedBox(height: 24 * responsive.scale),
          const _GoogleButton(),
          SizedBox(height: 36 * responsive.scale),
          AuthInlineLink(
            text: 'No account yet?',
            actionText: 'Register',
            onTap: _isLoading ? () {} : () => Navigator.of(context).pushNamed(AppRoutes.register),
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
        onPressed: null,
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
              'Google sign-in not configured',
              style: textTheme.bodyLarge?.copyWith(
                color: AppTheme.neutral500,
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
