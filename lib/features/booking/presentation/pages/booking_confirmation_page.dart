import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({super.key});

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
                26 * responsive.scale,
              ),
              child: Row(
                children: [
                  Icon(Icons.close, color: AppTheme.accentDark, size: 30 * responsive.scale),
                  Expanded(
                    child: Text(
                      'Booking Confirmed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 24 * responsive.scale,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: 30 * responsive.scale),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  42 * responsive.scale,
                  responsive.horizontalPadding,
                  34 * responsive.scale,
                ),
                children: [
                  CircleAvatar(
                    radius: 54 * responsive.scale,
                    backgroundColor: const Color(0xFFEADDD8),
                    child: Icon(Icons.check_circle_outline, color: AppTheme.ink, size: 58 * responsive.scale),
                  ),
                  SizedBox(height: 34 * responsive.scale),
                  Text(
                    'Dat phong thanh cong!',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.ink,
                      fontSize: 33 * responsive.scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  Text(
                    'Chuc ban co mot chuyen di tuyet voi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF5A3F3F),
                      fontSize: 18 * responsive.scale,
                    ),
                  ),
                  SizedBox(height: 58 * responsive.scale),
                  const _ConfirmedTicket(),
                  SizedBox(height: 52 * responsive.scale),
                  Center(
                    child: Container(
                      width: 206 * responsive.widthScale,
                      padding: EdgeInsets.all(18 * responsive.scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.neutral200),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 210 * responsive.widthScale,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4E8E5),
                              borderRadius: BorderRadius.circular(4),
                              gradient: const LinearGradient(colors: [Color(0xFFE9EFEC), Color(0xFFC9D0CC)]),
                            ),
                            child: Center(
                              child: Icon(Icons.qr_code_2, color: AppTheme.neutral500, size: 86 * responsive.scale),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  Text(
                    'QUET MA DE CHECK-IN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF5A3F3F),
                      fontSize: 16 * responsive.scale,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                    ),
                  ),
                  SizedBox(height: 70 * responsive.scale),
                  const BookingPrimaryButton(label: 'Xem chi tiet booking'),
                  SizedBox(height: 22 * responsive.scale),
                  SizedBox(
                    height: 58 * responsive.scale,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.neutral200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Ve Trang chu',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 20 * responsive.scale,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmedTicket extends StatelessWidget {
  const _ConfirmedTicket();

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(24 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'MA DAT PHONG',
                  style: TextStyle(
                    color: const Color(0xFF5A3F3F),
                    fontSize: 16 * responsive.scale,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
              ),
              Text(
                'STZ-2024-9988',
                style: TextStyle(color: AppTheme.ink, fontSize: 17 * responsive.scale, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          Divider(height: 34 * responsive.scale, color: const Color(0xFFD9B8B8)),
          Text(
            'The Mist Retreat, Da Lat',
            style: TextStyle(
              color: AppTheme.accentDark,
              fontSize: 22 * responsive.scale,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14 * responsive.scale),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: const Color(0xFF5A3F3F), size: 22 * responsive.scale),
              SizedBox(width: 8 * responsive.widthScale),
              Expanded(
                child: Text(
                  'Phuong 10, Thanh pho Da Lat',
                  style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 17 * responsive.scale),
                ),
              ),
            ],
          ),
          SizedBox(height: 26 * responsive.scale),
          Row(
            children: const [
              Expanded(child: _TicketMeta(label: 'CHECK-IN', value: '14:00, 11 Th10 2024')),
              Expanded(child: _TicketMeta(label: 'CHECK-OUT', value: '12:00, 14 Th10 2024', alignRight: true)),
            ],
          ),
          Divider(height: 38 * responsive.scale, color: const Color(0xFFD9B8B8)),
          const PriceLine(label: 'Tong cong', value: 'd3.200.000', total: true),
        ],
      ),
    );
  }
}

class _TicketMeta extends StatelessWidget {
  const _TicketMeta({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF5A3F3F),
            fontSize: 14 * responsive.scale,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 8 * responsive.scale),
        Text(
          value,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: TextStyle(color: AppTheme.ink, fontSize: 15 * responsive.scale, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
