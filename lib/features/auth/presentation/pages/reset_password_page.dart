import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _initializedEmail = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedEmail) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _emailController.text = args;
    }
    _initializedEmail = true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty) {
      _showMessage('Please enter your email.');
      return;
    }
    if (newPassword.length < 6) {
      _showMessage('Password must be at least 6 characters.');
      return;
    }
    if (newPassword != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.resetPassword(
        email: email,
        newPassword: newPassword,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated. Please sign in.')),
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
    final textTheme = Theme.of(context).textTheme;

    return AuthScaffold(
      child: Column(
        children: [
          const AuthTopBar(title: 'New password'),
          Divider(color: AppTheme.neutral200.withValues(alpha: 0.7), height: 1),
          Expanded(
            child: AuthScrollBody(
              bottomPadding: 80,
              children: [
                Center(
                  child: Container(
                    width: 48 * responsive.scale,
                    height: 4 * responsive.scale,
                    margin: EdgeInsets.only(top: 28 * responsive.scale),
                    decoration: BoxDecoration(
                      color: AppTheme.neutral200.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                SizedBox(height: 32 * responsive.scale),
                const AuthTitleBlock(
                  title: 'Secure your account',
                  subtitle: 'Enter and confirm your new password.',
                ),
                SizedBox(height: 32 * responsive.scale),
                AuthField(
                  label: 'EMAIL',
                  hint: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20 * responsive.scale),
                AuthField(
                  label: 'NEW PASSWORD',
                  hint: 'Password',
                  obscure: true,
                  controller: _newPasswordController,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20 * responsive.scale),
                AuthField(
                  label: 'CONFIRM NEW PASSWORD',
                  hint: 'Password',
                  obscure: true,
                  controller: _confirmPasswordController,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 32 * responsive.scale),
                AuthPrimaryButton(
                  label: _isLoading ? 'Updating...' : 'Update password',
                  onPressed: _isLoading ? () {} : _resetPassword,
                ),
                SizedBox(height: 32 * responsive.scale),
                Divider(color: AppTheme.neutral200.withValues(alpha: 0.6)),
                SizedBox(height: 18 * responsive.scale),
                Center(
                  child: Text(
                    'OTP and email verification are skipped for this flow.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppTheme.neutral500,
                      fontSize: 14 * responsive.scale,
                      height: 1.4,
                    ),
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
