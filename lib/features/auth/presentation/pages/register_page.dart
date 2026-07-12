import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/data/auth_validators.dart';
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
  final _otpController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _isOtpLoading = false;
  bool _otpVerified = false;
  bool _otpSent = false;
  bool _registrationSucceeded = false;
  int _step = 0;
  String _otpMethod = 'email';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    final emailError = AuthValidators.email(email);
    if (emailError != null) {
      _showMessage(emailError);
      return;
    }
    if (_otpMethod == 'phone') {
      _showMessage(
        tr(
          'Gửi OTP qua điện thoại chưa được cấu hình SMS. Vui lòng chọn Email.',
          'Phone OTP is not configured yet. Please choose Email.',
        ),
      );
      return;
    }

    setState(() {
      _isOtpLoading = true;
      _otpVerified = false;
      _otpSent = false;
    });
    try {
      await AuthService.instance.requestRegisterOtp(email: email);
      _otpSent = true;
      if (mounted) {
        _showMessage(
          tr(
            'Mã OTP đã được gửi tới email của bạn.',
            'OTP has been sent to your email.',
          ),
        );
      }
    } on ApiException catch (error) {
      if (mounted) {
        _showMessage(
          error.statusCode == 404
              ? tr(
                  'Backend chưa cập nhật API gửi OTP. Cần deploy bản mới lên Render rồi thử lại.',
                  'The OTP API is not deployed yet. Deploy the latest backend and try again.',
                )
              : error.message,
        );
      }
    } catch (error) {
      if (mounted) _showMessage(_messageFromError(error));
    } finally {
      if (mounted) setState(() => _isOtpLoading = false);
    }
  }

  Future<void> _continueToVerification() async {
    final validationError =
        AuthValidators.fullName(_nameController.text.trim()) ??
        AuthValidators.email(_emailController.text.trim()) ??
        (_phoneController.text.trim().isEmpty
            ? null
            : AuthValidators.phone(_phoneController.text.trim())) ??
        AuthValidators.password(_passwordController.text);
    if (validationError != null) {
      _showMessage(validationError);
      return;
    }
    if (!_agreedToTerms) {
      _showMessage(
        tr(
          'Vui lòng đồng ý điều khoản trước khi tiếp tục.',
          'Please agree to the terms before continuing.',
        ),
      );
      return;
    }
    await _sendOtp();
    if (mounted && _otpSent) setState(() => _step = 1);
  }

  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();
    final emailError = AuthValidators.email(email);
    final otpError = AuthValidators.otpCode(_otpController.text);
    if (emailError != null || otpError != null) {
      _showMessage(emailError ?? otpError!);
      return;
    }

    setState(() => _isOtpLoading = true);
    try {
      await AuthService.instance.verifyRegisterOtp(
        email: email,
        code: _otpController.text,
      );
      if (!mounted) return;
      setState(() => _otpVerified = true);
      _showMessage(
        tr('Xác thực OTP thành công.', 'OTP verified successfully.'),
      );
    } catch (error) {
      if (mounted) _showMessage(_messageFromError(error));
    } finally {
      if (mounted) setState(() => _isOtpLoading = false);
    }
  }

  Future<void> _register() async {
    _registrationSucceeded = false;
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    final validationError =
        AuthValidators.fullName(fullName) ??
        AuthValidators.email(email) ??
        (phone.isEmpty ? null : AuthValidators.phone(phone)) ??
        AuthValidators.password(password);
    if (validationError != null) {
      _showMessage(validationError);
      return;
    }
    final otpError = AuthValidators.otpCode(_otpController.text);
    if (otpError != null || !_otpVerified) {
      _showMessage(
        otpError ??
            tr(
              'Vui lòng xác thực OTP trước khi đăng ký.',
              'Please verify OTP before registering.',
            ),
      );
      return;
    }
    if (!_agreedToTerms) {
      _showMessage(
        tr(
          'Vui lòng đồng ý điều khoản trước khi đăng ký.',
          'Please agree to the terms before registering.',
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.register(
        fullName: fullName,
        email: email,
        phoneNumber: phone,
        password: password,
        registerCode: _otpController.text,
      );
      if (!mounted) return;
      _registrationSucceeded = true;
    } catch (error) {
      if (mounted) _showMessage(_messageFromError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _messageFromError(Object error) {
    final text = error.toString();
    if (text.startsWith('HttpException: ')) {
      return text.replaceFirst('HttpException: ', '').split(', uri =').first;
    }
    return text;
  }

  Future<void> _showSuccess() async {
    await showModalBottomSheet<void>(
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
                tr('Thành công!', 'Successful!'),
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                tr(
                  'Tài khoản StayZ của bạn đã sẵn sàng.',
                  'Your StayZ account is ready to use.',
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
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    return AuthScaffold(
      child: Column(
        children: [
          AuthTopBar(
            title: _step == 0
                ? tr('Bắt đầu hành trình', 'Start your journey')
                : tr('Mã xác minh', 'Verification code'),
            showLogo: false,
          ),
          Expanded(
            child: AuthScrollBody(
              bottomPadding: 48,
              children: _step == 0
                  ? _accountStep(responsive)
                  : _verificationStep(responsive),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _accountStep(AuthResponsive responsive) => [
    const SizedBox(height: 8),
    AuthTitleBlock(
      title: '',
      subtitle: tr(
        'Tạo tài khoản để đặt kỳ nghỉ tiếp theo cùng StayZ.',
        'Create an account for your next StayZ trip.',
      ),
      centered: true,
    ),
    SizedBox(height: 24 * responsive.scale),
    AuthField(
      label: tr('Họ và tên', 'Full name'),
      hint: tr('Nhập họ và tên', 'Enter your name'),
      controller: _nameController,
      textInputAction: TextInputAction.next,
    ),
    const SizedBox(height: 16),
    AuthField(
      label: 'Email',
      hint: 'name@example.com',
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
      textInputAction: TextInputAction.next,
    ),
    const SizedBox(height: 16),
    AuthField(
      label: tr('Số điện thoại', 'Phone number'),
      hint: '0901 234 567',
      keyboardType: TextInputType.phone,
      controller: _phoneController,
      textInputAction: TextInputAction.next,
    ),
    const SizedBox(height: 16),
    AuthField(
      label: tr('Mật khẩu', 'Password'),
      hint: tr('Ít nhất 6 ký tự', 'At least 6 characters'),
      obscure: true,
      controller: _passwordController,
      textInputAction: TextInputAction.done,
    ),
    const SizedBox(height: 16),
    _AgreementRow(
      value: _agreedToTerms,
      onChanged: _isLoading
          ? (_) {}
          : (value) => setState(() => _agreedToTerms = value),
    ),
    const SizedBox(height: 24),
    AuthPrimaryButton(
      label: _isOtpLoading
          ? tr('Đang gửi OTP...', 'Sending OTP...')
          : tr('Tạo tài khoản', 'Create account'),
      onPressed: _isOtpLoading ? null : _continueToVerification,
      loading: _isOtpLoading,
    ),
    const SizedBox(height: 24),
    AuthInlineLink(
      text: tr('Đã có tài khoản?', 'Already have an account?'),
      actionText: tr('Đăng nhập', 'Login'),
      onTap: () => Navigator.of(context).pop(),
    ),
  ];

  List<Widget> _verificationStep(AuthResponsive responsive) => [
    const SizedBox(height: 18),
    const Center(
      child: CircleAvatar(
        radius: 42,
        backgroundColor: AppTheme.primarySoft,
        child: Icon(
          Icons.verified_outlined,
          size: 42,
          color: AppTheme.primaryDark,
        ),
      ),
    ),
    const SizedBox(height: 22),
    AuthTitleBlock(
      title: '',
      subtitle: tr(
        'Nhập mã OTP 6 số đã gửi tới ${_emailController.text.trim()}.',
        'Enter the 6-digit OTP sent to ${_emailController.text.trim()}.',
      ),
      centered: true,
    ),
    const SizedBox(height: 28),
    AuthField(
      label: tr('Mã OTP', 'OTP code'),
      hint: '123456',
      keyboardType: TextInputType.number,
      controller: _otpController,
      textInputAction: TextInputAction.done,
    ),
    const SizedBox(height: 14),
    Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isOtpLoading ? null : _sendOtp,
            child: Text(tr('Gửi lại OTP', 'Resend OTP')),
          ),
        ),
        Expanded(
          child: OutlinedButton(
            onPressed: _isOtpLoading ? null : _verifyOtp,
            child: Text(
              _otpVerified
                  ? tr('Đã xác minh', 'Verified')
                  : tr('Xác minh', 'Verify'),
            ),
          ),
        ),
      ],
    ),
    const SizedBox(height: 24),
    AuthPrimaryButton(
      label: _isLoading
          ? tr('Đang tạo tài khoản...', 'Creating account...')
          : tr('Xác minh và tiếp tục', 'Verify & continue'),
      onPressed: _isLoading || !_otpVerified
          ? null
          : () async {
              await _register();
              if (!mounted || !_registrationSucceeded) return;
              await _showSuccess();
              if (!mounted) return;
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
      loading: _isLoading,
    ),
    const SizedBox(height: 14),
    Center(
      child: TextButton(
        onPressed: _isLoading ? null : () => setState(() => _step = 0),
        child: Text(tr('Sửa thông tin tài khoản', 'Edit account details')),
      ),
    ),
  ];

  // Kept temporarily as a layout reference while the two-step flow settles.
  // ignore: unused_element
  Widget _legacyBuild(BuildContext context) {
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
                SizedBox(height: 10 * responsive.scale),
                _OtpMethodRow(
                  value: _otpMethod,
                  onChanged: _isLoading || _isOtpLoading
                      ? (_) {}
                      : (value) => setState(() {
                          _otpMethod = value;
                          _otpVerified = false;
                        }),
                ),
                SizedBox(height: 8 * responsive.scale),
                AuthField(
                  label: tr('MÃ OTP', 'OTP CODE'),
                  hint: '123456',
                  keyboardType: TextInputType.number,
                  controller: _otpController,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 8 * responsive.scale),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isOtpLoading || _isLoading
                            ? null
                            : _sendOtp,
                        child: Text(
                          _isOtpLoading
                              ? tr('Đang gửi...', 'Sending...')
                              : tr('Gửi OTP', 'Send OTP'),
                        ),
                      ),
                    ),
                    SizedBox(width: 10 * responsive.widthScale),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isOtpLoading || _isLoading
                            ? null
                            : _verifyOtp,
                        child: Text(
                          _otpVerified
                              ? tr('Đã xác thực', 'Verified')
                              : tr('Xác thực', 'Verify'),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * responsive.scale),
                _AgreementRow(
                  value: _agreedToTerms,
                  onChanged: _isLoading
                      ? (_) {}
                      : (val) => setState(() => _agreedToTerms = val),
                ),
                SizedBox(height: 28 * responsive.scale),
                AuthPrimaryButton(
                  label: _isLoading
                      ? tr('Đang tạo tài khoản...', 'Creating account...')
                      : tr('Đăng ký', 'Register'),
                  onPressed: _isLoading ? null : _register,
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

class _OtpMethodRow extends StatelessWidget {
  const _OtpMethodRow({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52 * responsive.scale,
            child: ChoiceChip(
              selected: value == 'email',
              label: Text(tr('Email', 'Email')),
              avatar: const Icon(Icons.mail_outline, size: 20),
              onSelected: (_) => onChanged('email'),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              labelStyle: TextStyle(
                fontSize: 15 * responsive.scale,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        SizedBox(width: 8 * responsive.widthScale),
        Expanded(
          child: SizedBox(
            height: 52 * responsive.scale,
            child: ChoiceChip(
              selected: value == 'phone',
              label: Text(tr('Điện thoại', 'Phone')),
              avatar: const Icon(Icons.phone_android, size: 20),
              onSelected: (_) => onChanged('phone'),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              labelStyle: TextStyle(
                fontSize: 15 * responsive.scale,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AgreementRow extends StatelessWidget {
  const _AgreementRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AuthCheckbox(value: value, onChanged: onChanged),
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
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' & '),
                TextSpan(
                  text: tr('Chính sách bảo mật', 'Privacy Policy'),
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
