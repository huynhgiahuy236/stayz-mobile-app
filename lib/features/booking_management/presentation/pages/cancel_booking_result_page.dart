import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class CancelBookingResultPage extends StatelessWidget {
  const CancelBookingResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                18 * responsive.scale,
                responsive.horizontalPadding,
                20 * responsive.scale,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    color: AppTheme.accentDark,
                  ),
                  Expanded(
                    child: Text(
                      'Thanh toan',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppTheme.accentDark,
                        fontSize: 30 * responsive.scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 48 * responsive.scale),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 64 * responsive.scale,
                      backgroundColor: const Color(0xFFFFE9E8),
                      child: CircleAvatar(
                        radius: 46 * responsive.scale,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.close, color: const Color(0xFFC71920), size: 52 * responsive.scale),
                      ),
                    ),
                    SizedBox(height: 70 * responsive.scale),
                    Text(
                      'Thanh toan khong thanh\ncong',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppTheme.accent,
                        fontSize: 38 * responsive.scale,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 24 * responsive.scale),
                    Text(
                      'Rat tiec, giao dich cua ban khong the hoan tat. Vui long kiem tra lai thong tin the hoac so du tai khoan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 21 * responsive.scale, height: 1.55),
                    ),
                    SizedBox(height: 70 * responsive.scale),
                    Container(
                      padding: EdgeInsets.all(20 * responsive.scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD9B8B8)),
                      ),
                      child: Column(
                        children: const [
                          _ResultLine(label: 'LY DO', value: 'Giao dich bi tu choi boi ngan hang'),
                          Divider(),
                          _ResultLine(label: 'MA GIAO DICH', value: 'STZ-PAY-778899'),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _ResultButton(label: 'Thu lai', filled: true),
                    SizedBox(height: 18 * responsive.scale),
                    const _ResultButton(label: 'Chon phuong thuc thanh toan khac'),
                    SizedBox(height: 28 * responsive.scale),
                    Text('Quay lai', style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 19 * responsive.scale)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Row(
      children: [
        SizedBox(
          width: 120 * responsive.widthScale,
          child: Text(label, style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 16 * responsive.scale, letterSpacing: 2)),
        ),
        Expanded(
          child: Text(value, textAlign: TextAlign.right, style: TextStyle(color: AppTheme.ink, fontSize: 17 * responsive.scale, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _ResultButton extends StatelessWidget {
  const _ResultButton({
    required this.label,
    this.filled = false,
  });

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return SizedBox(
      width: double.infinity,
      height: 58 * responsive.scale,
      child: filled
          ? FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(label, style: TextStyle(color: Colors.white, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w800)),
            )
          : OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(label, style: TextStyle(color: AppTheme.accent, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w800)),
            ),
    );
  }
}
