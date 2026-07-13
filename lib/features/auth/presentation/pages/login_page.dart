import 'dart:async';

import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/data/auth_validators.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // `getInitialLink()` can return the Google callback that launched the app
  // again when a new LoginPage is created after logout. Keep successful
  // callbacks for this app process so an old JWT cannot be replayed.
  static final Set<int> _handledGoogleCallbacks = <int>{};

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _googleLoading = false;
  String? _emailError;
  String? _passwordError;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initGoogleDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _startGoogleLogin() async {
    if (_googleLoading) return;
    setState(() => _googleLoading = true);
    final opened = await launchUrl(
      AuthService.instance.googleLoginUri(),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      setState(() => _googleLoading = false);
      _showMessage(
        tr('Không mở được đăng nhập Google.', 'Could not open Google sign-in.'),
      );
    }
  }

  void _initGoogleDeepLinks() {
    try {
      final appLinks = AppLinks();
      _linkSubscription = appLinks.uriLinkStream.listen(
        _handleGoogleCallback,
        onError: (_) {
          if (mounted) setState(() => _googleLoading = false);
        },
      );
      appLinks
          .getInitialLink()
          .then((uri) {
            if (uri != null) _handleGoogleCallback(uri);
          })
          .catchError((_) {
            if (mounted) setState(() => _googleLoading = false);
          });
    } on MissingPluginException {
      _linkSubscription = null;
    } catch (_) {
      _linkSubscription = null;
    }
  }

  Future<void> _handleGoogleCallback(Uri uri) async {
    if (uri.scheme != 'stayz' || uri.host != 'auth') return;
    final callbackKey = uri.toString().hashCode;
    if (!_handledGoogleCallbacks.add(callbackKey)) return;
    try {
      await AuthService.instance.completeGoogleLogin(uri);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } on ApiException catch (error) {
      // A failed callback may be retried; only successful callbacks must stay
      // consumed to prevent login again after logout.
      _handledGoogleCallbacks.remove(callbackKey);
      if (mounted) _showMessage(error.message);
    } catch (_) {
      _handledGoogleCallbacks.remove(callbackKey);
      rethrow;
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final emailError = AuthValidators.email(email);
    final passwordError = AuthValidators.requiredPassword(password);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });
    if (emailError != null) {
      _showMessage(emailError);
      return;
    }
    if (passwordError != null) {
      _showMessage(passwordError);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.login(email: email, password: password);
      final role = await AuthService.instance.userRole();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        role == 'admin' ? AppRoutes.admin : AppRoutes.home,
        (route) => false,
      );
    } on ApiException catch (error) {
      // Thong diep da duoc dich san; khong con in URL va body loi ra man hinh.
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
          const AuthTopBar(showLogo: false, showBack: false),
          Expanded(
            child: AuthScrollBody(
              bottomPadding: responsive.isCompact ? 28 : 44,
              children: [
                AuthTitleBlock(
                  title: tr('Chào mừng', 'Welcome'),
                  subtitle: tr(
                    'Nhập thông tin để đăng nhập vào tài khoản StayZ.',
                    'Enter your details to sign in to StayZ.',
                  ),
                  accentTitle: true,
                  titleFontSize: responsive.isCompact ? 34 : 38,
                ),
                SizedBox(
                  height: (responsive.isCompact ? 16 : 26) * responsive.scale,
                ),
                AuthField(
                  label: tr('Địa chỉ email', 'Email address'),
                  hint: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  controller: _emailController,
                  errorText: _emailError,
                  onChanged: (_) => setState(
                    () => _emailError = AuthValidators.email(_emailController.text),
                  ),
                ),
                SizedBox(
                  height: (responsive.isCompact ? 12 : 18) * responsive.scale,
                ),
                AuthField(
                  label: tr('Mật khẩu', 'Password'),
                  hint: tr('Mật khẩu', 'Password'),
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  controller: _passwordController,
                  errorText: _passwordError,
                  onChanged: (_) => setState(
                    () => _passwordError = AuthValidators.requiredPassword(_passwordController.text),
                  ),
                ),
                SizedBox(height: 10 * responsive.scale),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.forgotPassword),
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
                SizedBox(
                  height: (responsive.isCompact ? 8 : 18) * responsive.scale,
                ),
                AuthPrimaryButton(
                  label: _isLoading
                      ? tr('Đang đăng nhập...', 'Signing in...')
                      : tr('Đăng nhập', 'Sign in'),
                  onPressed: _isLoading ? null : _login,
                  loading: _isLoading,
                ),
                SizedBox(
                  height: (responsive.isCompact ? 18 : 28) * responsive.scale,
                ),
                ...[
                  AuthDivider(label: tr('hoặc', 'or')),
                  SizedBox(height: 16 * responsive.scale),
                  _GoogleButton(
                    loading: _googleLoading,
                    onPressed: _startGoogleLogin,
                  ),
                ],
                SizedBox(
                  height: (responsive.isCompact ? 20 : 36) * responsive.scale,
                ),
                AuthInlineLink(
                  text: tr('Chưa có tài khoản?', 'No account yet?'),
                  actionText: tr('Đăng ký', 'Register'),
                  onTap: _isLoading
                      ? () {}
                      : () =>
                            Navigator.of(context).pushNamed(AppRoutes.register),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 56 * responsive.scale,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
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
