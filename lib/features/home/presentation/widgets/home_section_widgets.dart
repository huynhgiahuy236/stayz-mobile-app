import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HomeResponsive {
  const HomeResponsive._({
    required this.widthScale,
    required this.heightScale,
    required this.scale,
    required this.horizontalPadding,
  });

  factory HomeResponsive.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width.clamp(360.0, 430.0).toDouble();
    final widthScale = (width / 390).clamp(0.92, 1.10).toDouble();
    final heightScale = (size.height / 844).clamp(0.72, 1.0).toDouble();

    return HomeResponsive._(
      widthScale: widthScale,
      heightScale: heightScale,
      scale: widthScale < heightScale ? widthScale : heightScale,
      horizontalPadding: 28 * widthScale,
    );
  }

  final double widthScale;
  final double heightScale;
  final double scale;
  final double horizontalPadding;
}

enum HomeTab { home, search, saved, bookings, profile }

class StayZBottomNav extends StatelessWidget {
  const StayZBottomNav({
    required this.activeTab,
    super.key,
  });

  final HomeTab activeTab;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      height: 78 * responsive.scale,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.7)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.explore_outlined,
            label: 'Trang chủ',
            active: activeTab == HomeTab.home,
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.home),
          ),
          _NavItem(
            icon: Icons.search,
            label: 'Tìm kiếm',
            active: activeTab == HomeTab.search,
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.search),
          ),
          _NavItem(
            icon: Icons.favorite_border,
            label: 'Yêu thích',
            active: activeTab == HomeTab.saved,
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.favorites),
          ),
          _NavItem(
            icon: Icons.confirmation_number_outlined,
            label: 'Đặt phòng',
            active: activeTab == HomeTab.bookings,
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.myBookings),
          ),
          _NavItem(
            icon: Icons.person_outline,
            label: 'Tôi',
            active: activeTab == HomeTab.profile,
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final color = active ? AppTheme.accent : const Color(0xFF9B9187);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64 * responsive.widthScale,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 25 * responsive.scale),
            SizedBox(height: 4 * responsive.scale),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11 * responsive.scale,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            SizedBox(height: 3 * responsive.scale),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: active ? AppTheme.accent : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StayZLogoRow extends StatelessWidget {
  const StayZLogoRow({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Row(
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Noto Serif JP',
              fontSize: 28 * responsive.scale,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            children: const [
              TextSpan(text: 'Stay', style: TextStyle(color: AppTheme.ink)),
              TextSpan(text: 'Z', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
          icon: Icon(
            Icons.notifications_none_rounded,
            color: AppTheme.accentDark,
            size: 26 * responsive.scale,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.all(8 * responsive.scale),
            side: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.6)),
          ),
        ),
        SizedBox(width: 10 * responsive.widthScale),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
          child: Container(
            width: 42 * responsive.scale,
            height: 42 * responsive.scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accent.withValues(alpha: 0.08),
              border: Border.all(
                color: AppTheme.neutral200.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.person_outline_rounded,
                color: AppTheme.accentDark,
                size: 22 * responsive.scale,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({
    required this.title,
    this.action,
    super.key,
  });

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: AppTheme.neutral500,
            fontSize: 12 * responsive.scale,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.myBookings),
            child: Text(
              action!,
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 13 * responsive.scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.search),
      child: Container(
        height: 56 * responsive.scale,
        padding: EdgeInsets.symmetric(horizontal: 16 * responsive.widthScale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neutral800.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: AppTheme.neutral200.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 24 * responsive.scale, color: AppTheme.neutral500),
            SizedBox(width: 12 * responsive.widthScale),
            Expanded(
              child: Text(
                'Điểm đến, tên khách sạn...',
                style: TextStyle(
                  color: AppTheme.neutral500.withValues(alpha: 0.7),
                  fontSize: 15 * responsive.scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 36 * responsive.scale,
              height: 36 * responsive.scale,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 18 * responsive.scale,
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterPill extends StatelessWidget {
  const FilterPill({
    required this.label,
    this.active = false,
    super.key,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      height: 44 * responsive.scale,
      padding: EdgeInsets.symmetric(horizontal: 22 * responsive.widthScale),
      decoration: BoxDecoration(
        color: active ? AppTheme.accent : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppTheme.accent.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
        border: Border.all(
          color: active ? AppTheme.accent : AppTheme.neutral200.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppTheme.neutral500,
            fontSize: 14 * responsive.scale,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class HotelCard extends StatelessWidget {
  const HotelCard({
    required this.name,
    required this.location,
    required this.price,
    required this.colors,
    this.compact = false,
    this.fullWidth = false,
    this.imageUrl,
    super.key,
  });

  final String name;
  final String location;
  final String price;
  final List<Color> colors;
  final bool compact;
  final bool fullWidth;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final width = fullWidth
        ? null
        : (compact ? 164 * responsive.widthScale : 240 * responsive.widthScale);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutral800.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppTheme.neutral200.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: (compact ? 120 : 150) * responsive.scale,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: LuxuryArchitecturalPainter(colors: colors),
                    ),
                  ),
                  if (imageUrl != null)
                    Positioned.fill(
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox.shrink();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  Positioned(
                    right: 12 * responsive.scale,
                    top: 12 * responsive.scale,
                    child: Container(
                      width: 32 * responsive.scale,
                      height: 32 * responsive.scale,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite_border_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12 * responsive.scale,
                    top: 12 * responsive.scale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber[700],
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.9',
                            style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: 10 * responsive.scale,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12 * responsive.scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined, 
                      size: 12 * responsive.scale, 
                      color: AppTheme.neutral500,
                    ),
                    SizedBox(width: 4 * responsive.widthScale),
                    Expanded(
                      child: Text(
                        location.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.neutral500,
                          fontSize: 10 * responsive.scale,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6 * responsive.scale),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 16 * responsive.scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10 * responsive.scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        price,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 14 * responsive.scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      width: 28 * responsive.scale,
                      height: 28 * responsive.scale,
                      decoration: const BoxDecoration(
                        color: AppTheme.ink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingPreviewCard extends StatelessWidget {
  const BookingPreviewCard({
    required this.name,
    required this.location,
    required this.date,
    required this.total,
    required this.colors,
    super.key,
  });

  final String name;
  final String location;
  final String date;
  final String total;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutral800.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppTheme.neutral200.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            height: 110 * responsive.scale,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: LuxuryArchitecturalPainter(colors: colors),
                    ),
                  ),
                  Positioned(
                    left: 18 * responsive.scale,
                    top: 18 * responsive.scale,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14 * responsive.widthScale,
                        vertical: 6 * responsive.scale,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Sắp tới',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 13 * responsive.scale,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              const TicketDashedDivider(),
              Positioned(
                left: -8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.cream,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.neutral200.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              Positioned(
                right: -8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.cream,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.neutral200.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(18 * responsive.scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 20 * responsive.scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8 * responsive.scale),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppTheme.neutral500, size: 16),
                    SizedBox(width: 6 * responsive.widthScale),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          color: AppTheme.neutral500,
                          fontSize: 14 * responsive.scale,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _BookingMeta(label: 'THỜI GIAN', value: date),
                    ),
                    _BookingMeta(label: 'TỔNG CỘNG', value: total, alignRight: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingMeta extends StatelessWidget {
  const _BookingMeta({
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
            color: AppTheme.neutral500,
            fontSize: 11 * responsive.scale,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 4 * responsive.scale),
        Text(
          value,
          style: TextStyle(
            color: alignRight ? AppTheme.accent : AppTheme.ink,
            fontSize: (alignRight ? 18 : 14) * responsive.scale,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(16 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutral800.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: unread 
              ? AppTheme.accent.withValues(alpha: 0.3) 
              : AppTheme.neutral200.withValues(alpha: 0.5),
          width: unread ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44 * responsive.scale,
            height: 44 * responsive.scale,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22 * responsive.scale),
          ),
          SizedBox(width: 14 * responsive.widthScale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: AppTheme.ink,
                          fontSize: 16 * responsive.scale,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 4, left: 8),
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 6 * responsive.scale),
                Text(
                  body,
                  style: TextStyle(
                    color: AppTheme.neutral500,
                    fontSize: 14 * responsive.scale,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8 * responsive.scale),
                Text(
                  time,
                  style: TextStyle(
                    color: AppTheme.neutral500.withValues(alpha: 0.7),
                    fontSize: 12 * responsive.scale,
                    fontWeight: FontWeight.w600,
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

class LuxuryArchitecturalPainter extends CustomPainter {
  const LuxuryArchitecturalPainter({required this.colors});
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors.length >= 2 
            ? colors 
            : [const Color(0xFF405F59), const Color(0xFF0F1917)],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final sunCenter = Offset(size.width * 0.7, size.height * 0.45);
    final sunRadius = size.height * 0.22;
    final sunPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15);
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    final pathWave = Path();
    pathWave.moveTo(0, size.height);
    pathWave.quadraticBezierTo(
      size.width * 0.35, 
      size.height * 0.72, 
      size.width * 0.7, 
      size.height * 0.88,
    );
    pathWave.quadraticBezierTo(
      size.width * 0.85, 
      size.height * 0.94, 
      size.width, 
      size.height * 0.8,
    );
    pathWave.lineTo(size.width, size.height);
    pathWave.lineTo(0, size.height);
    pathWave.close();

    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawPath(pathWave, wavePaint);

    final archWidth = size.width * 0.38;
    final archHeight = size.height * 0.65;
    final archLeft = size.width * 0.12;
    final archTop = size.height - archHeight;

    final archPath = Path();
    archPath.moveTo(archLeft, size.height);
    archPath.lineTo(archLeft, archTop + archWidth / 2);
    archPath.arcTo(
      Rect.fromLTWH(archLeft, archTop, archWidth, archWidth),
      3.1415,
      3.1415,
      false,
    );
    archPath.lineTo(archLeft + archWidth, size.height);
    archPath.close();

    final archPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawPath(archPath, archPaint);
  }

  @override
  bool shouldRepaint(covariant LuxuryArchitecturalPainter oldDelegate) => 
      oldDelegate.colors != colors;
}

class TicketDashedDivider extends StatelessWidget {
  const TicketDashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        15,
        (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 1.5,
            color: AppTheme.neutral200.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
