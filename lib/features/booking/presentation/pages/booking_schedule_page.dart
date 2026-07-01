import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class BookingSchedulePage extends StatelessWidget {
  const BookingSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          responsive.horizontalPadding,
          22 * responsive.scale,
          responsive.horizontalPadding,
          24 * responsive.scale,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAF7),
          border: Border(top: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.8))),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TONG DU TINH',
                style: TextStyle(
                  color: const Color(0xFF5A3F3F),
                  fontSize: 16 * responsive.scale,
                  letterSpacing: 4,
                ),
              ),
              SizedBox(height: 14 * responsive.scale),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '3.200.000d',
                      style: TextStyle(
                        color: AppTheme.accentDark,
                        fontSize: 28 * responsive.scale,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Text(
                    'Da bao gom thue & phi',
                    style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 16 * responsive.scale),
                  ),
                ],
              ),
              SizedBox(height: 22 * responsive.scale),
              BookingPrimaryButton(
                label: 'Dat ngay',
                icon: Icons.arrow_forward,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.paymentCheckout),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                8 * responsive.scale,
                responsive.horizontalPadding,
                16 * responsive.scale,
              ),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.8))),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    color: AppTheme.accentDark,
                  ),
                  SizedBox(width: 16 * responsive.widthScale),
                  Expanded(
                    child: Text(
                      'Chon thoi gian &\nkhach',
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppTheme.accentDark,
                        fontSize: 30 * responsive.scale,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  56 * responsive.scale,
                  responsive.horizontalPadding,
                  28 * responsive.scale,
                ),
                children: [
                  const _CalendarCard(),
                  SizedBox(height: 52 * responsive.scale),
                  Text(
                    'So luong khach',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.ink,
                      fontSize: 26 * responsive.scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 24 * responsive.scale),
                  const _GuestCard(),
                  SizedBox(height: 40 * responsive.scale),
                  Container(
                    padding: EdgeInsets.all(22 * responsive.scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E2DD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.neutral200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event_available_outlined, color: AppTheme.accentDark, size: 24 * responsive.scale),
                        SizedBox(width: 14 * responsive.widthScale),
                        Expanded(
                          child: Text(
                            'Luu tru: 11 Th10 - 14 Th10 (3 dem)',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: 17 * responsive.scale,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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

class _CalendarCard extends StatelessWidget {
  const _CalendarCard();

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final numbers = ['', '', '', '', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31'];

    return Container(
      padding: EdgeInsets.all(28 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9B8B8)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Thang 10, 2024',
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 25 * responsive.scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.chevron_left, color: AppTheme.neutral500, size: 30 * responsive.scale),
              SizedBox(width: 22 * responsive.widthScale),
              Icon(Icons.chevron_right, color: AppTheme.neutral500, size: 30 * responsive.scale),
            ],
          ),
          SizedBox(height: 28 * responsive.scale),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.05,
            children: [
              ...days.map(
                (day) => Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: const Color(0xFFD1AFAF),
                      fontSize: 19 * responsive.scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              ...numbers.map((day) => _DayCell(day: day)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day});

  final String day;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final selected = day == '11' || day == '14';
    final inRange = day == '12' || day == '13';

    if (day.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: inRange ? const Color(0xFFF1E7E6) : Colors.transparent,
        shape: selected ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: Center(
        child: Container(
          width: selected ? 44 * responsive.scale : null,
          height: selected ? 44 * responsive.scale : null,
          decoration: selected
              ? const BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                )
              : null,
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                color: selected ? Colors.white : AppTheme.ink,
                fontSize: 18 * responsive.scale,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard();

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(24 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9B8B8)),
      ),
      child: Column(
        children: [
          const _GuestRow(title: 'Nguoi lon', subtitle: 'Tu 13 tuoi tro len', count: '2'),
          Divider(height: 28 * responsive.scale, color: const Color(0xFFD9B8B8)),
          const _GuestRow(title: 'Tre em', subtitle: 'Duoi 12 tuoi', count: '0'),
        ],
      ),
    );
  }
}

class _GuestRow extends StatelessWidget {
  const _GuestRow({
    required this.title,
    required this.subtitle,
    required this.count,
  });

  final String title;
  final String subtitle;
  final String count;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: AppTheme.ink, fontSize: 20 * responsive.scale, fontWeight: FontWeight.w800)),
              SizedBox(height: 6 * responsive.scale),
              Text(subtitle, style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 18 * responsive.scale)),
            ],
          ),
        ),
        _RoundCounter(icon: Icons.remove),
        SizedBox(width: 24 * responsive.widthScale),
        Text(count, style: TextStyle(color: AppTheme.ink, fontSize: 22 * responsive.scale, fontWeight: FontWeight.w800)),
        SizedBox(width: 24 * responsive.widthScale),
        _RoundCounter(icon: Icons.add),
      ],
    );
  }
}

class _RoundCounter extends StatelessWidget {
  const _RoundCounter({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      width: 50 * responsive.scale,
      height: 50 * responsive.scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.neutral500),
      ),
      child: Icon(icon, color: AppTheme.accentDark, size: 26 * responsive.scale),
    );
  }
}
