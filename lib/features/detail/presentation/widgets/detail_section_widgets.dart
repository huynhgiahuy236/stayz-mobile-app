import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class DetailCircleButton extends StatelessWidget {
  const DetailCircleButton({
    required this.icon,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42 * responsive.scale,
        height: 42 * responsive.scale,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: AppTheme.ink, size: 22 * responsive.scale),
      ),
    );
  }
}

class DetailSectionTitle extends StatelessWidget {
  const DetailSectionTitle({
    required this.title,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.ink,
              fontSize: 18 * responsive.scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class AmenityTile extends StatelessWidget {
  const AmenityTile({
    required this.icon,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      height: 52 * responsive.scale,
      padding: EdgeInsets.symmetric(horizontal: 16 * responsive.widthScale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentDark, size: 22 * responsive.scale),
          SizedBox(width: 12 * responsive.widthScale),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF6B5348),
                fontSize: 13 * responsive.scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    required this.name,
    required this.date,
    required this.body,
    required this.colors,
    super.key,
  });

  final String name;
  final String date;
  final String body;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(16 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20 * responsive.scale,
                backgroundColor: colors.first,
                child: Icon(Icons.person, color: colors.last, size: 22 * responsive.scale),
              ),
              SizedBox(width: 12 * responsive.widthScale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 14 * responsive.scale,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        color: AppTheme.neutral500,
                        fontSize: 11 * responsive.scale,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_border,
                    color: const Color(0xFF8E5F1B),
                    size: 13 * responsive.scale,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14 * responsive.scale),
          Text(
            body,
            style: TextStyle(
              color: const Color(0xFF5A3F3F),
              fontSize: 13 * responsive.scale,
              fontStyle: FontStyle.italic,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailBottomBookingBar extends StatelessWidget {
  const DetailBottomBookingBar({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        responsive.horizontalPadding,
        14 * responsive.scale,
        responsive.horizontalPadding,
        18 * responsive.scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: Border.all(color: AppTheme.neutral200.withValues(alpha: 0.7)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'd1.800.000',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 18 * responsive.scale,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        TextSpan(
                          text: ' /dem',
                          style: TextStyle(
                            color: AppTheme.neutral800,
                            fontSize: 12 * responsive.scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4 * responsive.scale),
                  Text(
                    'Da bao gom thue & phi',
                    style: TextStyle(
                      color: AppTheme.neutral500,
                      fontSize: 11 * responsive.scale,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 18 * responsive.widthScale),
            SizedBox(
              width: 150 * responsive.widthScale,
              height: 58 * responsive.scale,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.roomSelection),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accentDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                ),
                child: Text(
                  'Chon phong',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14 * responsive.scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportActionCard extends StatelessWidget {
  const SupportActionCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      height: 164 * responsive.scale,
      padding: EdgeInsets.all(18 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24 * responsive.scale,
            backgroundColor: color.withValues(alpha: 0.28),
            child: Icon(icon, color: AppTheme.accentDark, size: 22 * responsive.scale),
          ),
          SizedBox(height: 20 * responsive.scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF6B5348),
              fontSize: 17 * responsive.scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8 * responsive.scale),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.accentDark,
              fontSize: 16 * responsive.scale,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
