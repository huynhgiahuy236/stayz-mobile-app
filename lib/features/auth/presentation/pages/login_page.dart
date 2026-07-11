import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/data/auth_validators.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
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
      _showMessage(tr('Vui lòng nhập mật khẩu.', 'Password is required.'));
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
        bottomPadding: responsive.isCompact ? 28 : 56,
        children: [
          SizedBox(height: (responsive.isCompact ? 2 : 20) * responsive.scale),
          const AuthLogo(large: true),
          SizedBox(height: (responsive.isCompact ? 12 : 26) * responsive.scale),
          AuthTitleBlock(
            title: tr('Chào mừng trở lại', 'Welcome back'),
            subtitle: tr('Đăng nhập để tiếp tục hành trình StayZ của bạn.', 'Sign in to continue your StayZ journey.'),
          ),
          SizedBox(height: (responsive.isCompact ? 16 : 26) * responsive.scale),
          AuthField(
            label: 'EMAIL',
            hint: 'example@email.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            controller: _emailController,
          ),
          SizedBox(height: (responsive.isCompact ? 12 : 18) * responsive.scale),
          AuthField(
            label: tr('MẬT KHẨU', 'PASSWORD'),
            hint: tr('Mật khẩu', 'Password'),
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
                tr('Quên mật khẩu?', 'Forgot password?'),
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 14 * responsive.scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: (responsive.isCompact ? 8 : 18) * responsive.scale),
          AuthPrimaryButton(
            label: _isLoading ? tr('Đang đăng nhập...', 'Signing in...') : tr('Đăng nhập', 'Sign in'),
            onPressed: _isLoading ? null : _login,
            loading: _isLoading,
          ),
          SizedBox(height: (responsive.isCompact ? 18 : 28) * responsive.scale),
          if (!responsive.isCompact) ...[
            AuthDivider(label: tr('hoặc', 'or')),
            SizedBox(height: 20 * responsive.scale),
            const _GoogleButton(),
          ],
          SizedBox(height: (responsive.isCompact ? 20 : 36) * responsive.scale),
          AuthInlineLink(
            text: tr('Chưa có tài khoản?', 'No account yet?'),
            actionText: tr('Đăng ký', 'Register'),
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
          mainAxisSize: MainAxisSize.max,
          children: [
            GoogleLogo(size: 22 * responsive.scale),
            SizedBox(width: 14 * responsive.widthScale),
            Flexible(
              child: Text(
                tr('Đăng nhập Google', 'Continue with Google'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppTheme.neutral500,
                  fontSize: 16 * responsive.scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
