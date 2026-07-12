import 'dart:async';

import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/reset_password_page.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/data/auth_validators.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpArgs {
  const OtpArgs({required this.email});

  final String email;
}

/// Man nhap ma xac thuc 6 chu so.
///
/// Truoc day man nay ton tai nhung KHONG route nao dan toi, cac o nhap khong co
/// controller, va nut "Xác nhận" bo qua moi thu nguoi dung go roi nhay thang
/// sang man doi mat khau - khong kem ca email.
class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const _length = 6;
  static const _resendSeconds = 60;

  final _controllers = List.generate(_length, (_) => TextEditingController());
  final _focusNodes = List.generate(_length, (_) => FocusNode());

  String _email = '';
  bool _initialized = false;
  bool _verifying = false;
  bool _resending = false;

  int _secondsLeft = _resendSeconds;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    _email = args is OtpArgs ? args.email : '';
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Dem nguoc that, thay cho dong chu tinh "Gửi lại sau 58s" truoc day.
  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _code => _controllers.map((controller) => controller.text).join();

  void _onDigitChanged(int index, String value) {
    // Dan ca ma 6 so vao mot o: trai deu sang cac o con lai.
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < _length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      FocusScope.of(context).unfocus();
      setState(() {});
      if (_code.length == _length) _verify();
      return;
    }

    if (value.isNotEmpty && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {});
    if (_code.length == _length) _verify();
  }

  Future<void> _verify() async {
    if (_verifying) return;

    final error = AuthValidators.otpCode(_code);
    if (error != null) {
      _showMessage(error);
      return;
    }

    setState(() => _verifying = true);
    try {
      await AuthService.instance.verifyResetCode(email: _email, code: _code);
      if (!mounted) return;

      // Da xac thuc xong thi khong quay lai man nay nua.
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.resetPassword,
        arguments: ResetPasswordArgs(email: _email, code: _code),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
      for (final controller in _controllers) {
        controller.clear();
      }
      setState(() {});
      _focusNodes.first.requestFocus();
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0 || _resending) return;

    setState(() => _resending = true);
    try {
      await AuthService.instance.requestPasswordReset(email: _email);
      if (!mounted) return;
      _showMessage(
        tr('Đã gửi lại mã xác thực.', 'A new verification code has been sent.'),
      );
      _startCountdown();
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _resending = false);
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
    final complete = _code.length == _length;

    return AuthScaffold(
      child: Column(
        children: [
          AuthTopBar(
            title: tr('Nhập mã xác thực', 'Verification code'),
            showLogo: false,
          ),
          Expanded(
            child: AuthScrollBody(
              bottomPadding: 80,
              children: [
                SizedBox(height: 24 * responsive.scale),
                AuthTitleBlock(
                  title: '',
                  centered: true,
                  subtitle: _email.isEmpty
                      ? tr(
                          'Nhập mã gồm 6 chữ số đã được gửi tới email của bạn.',
                          'Enter the 6-digit code sent to your email.',
                        )
                      : tr(
                          'Chúng tôi đã gửi mã gồm 6 chữ số tới $_email.',
                          'We sent a 6-digit code to $_email.',
                        ),
                ),
                SizedBox(height: 32 * responsive.scale),
                // Tinh be rong moi o tu be rong thuc con lai, chia deu 6 o tren
                // MOT hang. Truoc day dung Wrap voi o co dinh 48px nen o thu 6
                // bi tran xuong hang duoi tren man hep.
                LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 8.0;
                    final boxWidth =
                        ((constraints.maxWidth - gap * (_length - 1)) / _length)
                            .clamp(38.0, 56.0);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < _length; i++)
                          _OtpBox(
                            width: boxWidth,
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            autofocus: i == 0,
                            position: i + 1,
                            total: _length,
                            onChanged: (value) => _onDigitChanged(i, value),
                          ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 28 * responsive.scale),
                AuthPrimaryButton(
                  label: tr('Xác nhận', 'Verify'),
                  onPressed: complete && !_verifying ? _verify : null,
                  loading: _verifying,
                ),
                SizedBox(height: 20 * responsive.scale),
                Center(
                  child: _secondsLeft > 0
                      ? Text(
                          tr(
                            'Gửi lại mã sau $_secondsLeft giây',
                            'Resend code in $_secondsLeft seconds',
                          ),
                          style: TextStyle(
                            color: AppTheme.muted,
                            fontSize: 14 * responsive.scale,
                          ),
                        )
                      : TextButton(
                          onPressed: _resending ? null : _resend,
                          child: Text(
                            _resending
                                ? tr('Đang gửi...', 'Sending...')
                                : tr('Gửi lại mã', 'Resend code'),
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

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.width,
    required this.controller,
    required this.focusNode,
    required this.autofocus,
    required this.position,
    required this.total,
    required this.onChanged,
  });

  final double width;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final int position;
  final int total;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tr(
        'Chữ số thứ $position trên $total',
        'Digit $position of $total',
      ),
      child: SizedBox(
        width: width,
        height: 56,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 1,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.6),
            ),
          ),
        ),
      ),
    );
  }
}
