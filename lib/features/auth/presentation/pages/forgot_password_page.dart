import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _continueToReset() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email.')),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      AppRoutes.resetPassword,
      arguments: email,
    );
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
              crossAxisAlignment: CrossAxisAlignment.center,
              bottomPadding: 84,
              children: [
                SizedBox(height: 42 * responsive.heightScale),
                const _ResetIcon(),
                SizedBox(height: 32 * responsive.scale),
                const AuthTitleBlock(
                  title: 'Reset password',
                  subtitle: 'Enter your account email to set a new password.',
                  centered: true,
                ),
                SizedBox(height: 32 * responsive.scale),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AuthField(
                    label: 'EMAIL',
                    hint: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                SizedBox(height: 20 * responsive.scale),
                AuthPrimaryButton(
                  label: 'Continue',
                  onPressed: _continueToReset,
                ),
                SizedBox(height: 28 * responsive.scale),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.hotelInfoForm),
                  icon: const Icon(Icons.support_agent_outlined),
                  label: const Text('Contact support'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accent,
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
