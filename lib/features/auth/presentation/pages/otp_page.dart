import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AuthScaffold(
      child: Column(
        children: [
          const AuthTopBar(showLogo: false),
          Divider(color: AppTheme.neutral200.withValues(alpha: 0.7), height: 1),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                50 * responsive.scale,
                responsive.horizontalPadding,
                72 * responsive.scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthTitleBlock(
                    title: 'Nhập mã xác thực',
                    subtitle:
                        'Vui lòng nhập mã OTP gồm 6 chữ số đã được gửi đến email của bạn.',
                    accentTitle: true,
                  ),
                  SizedBox(height: 50 * responsive.scale),
                  const _OtpFields(),
                  const Spacer(),
                  AuthPrimaryButton(
                    label: 'Xác nhận',
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.resetPassword,
                    ),
                  ),
                  SizedBox(height: 38 * responsive.scale),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Không nhận được mã?',
                          style: textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF5A3F3F),
                            fontSize: 16 * responsive.scale,
                          ),
                        ),
                        SizedBox(height: 6 * responsive.scale),
                        Text(
                          'Gửi lại sau 58s',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppTheme.neutral500,
                            fontSize: 16 * responsive.scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 56 * responsive.scale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpFields extends StatelessWidget {
  const _OtpFields();

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final fieldSize = 46 * responsive.widthScale;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: fieldSize,
          height: 50 * responsive.scale,
          child: TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFDDBDBD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.accent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
