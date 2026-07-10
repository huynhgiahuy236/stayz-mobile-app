import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:capstone_mobile/services/auth_service.dart';
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

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter email and password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.login(email: email, password: password);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
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
      child: AuthScrollBody(
        bottomPadding: 72,
        children: [
          SizedBox(height: 32 * responsive.scale),
          const AuthLogo(large: true),
          SizedBox(height: 36 * responsive.scale),
          const AuthTitleBlock(
            title: 'Welcome back',
            subtitle: 'Sign in to continue your StayZ journey.',
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
            label: 'PASSWORD',
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
            label: _isLoading ? 'Signing in...' : 'Sign in',
            onPressed: _isLoading ? () {} : _login,
          ),
          SizedBox(height: 28 * responsive.scale),
          const AuthDivider(label: 'or'),
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
