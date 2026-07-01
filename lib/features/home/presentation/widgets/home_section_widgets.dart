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
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        RichText(
          text: TextSpan(
            style: textTheme.headlineMedium?.copyWith(
              color: AppTheme.ink,
              fontSize: 27 * responsive.scale,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(text: 'Stay'),
              TextSpan(text: 'Z', style: TextStyle(color: AppTheme.accent)),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
          child: CircleAvatar(
            radius: 20 * responsive.scale,
            backgroundColor: const Color(0xFFD8C5B7),
            child: Icon(
              Icons.person,
              color: AppTheme.accentDark,
              size: 22 * responsive.scale,
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
            color: const Color(0xFF5A3F3F),
            fontSize: 11 * responsive.scale,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const Spacer(),
        if (action != null)
          Text(
            action!,
            style: TextStyle(
              color: AppTheme.accent,
              fontSize: 12 * responsive.scale,
              fontWeight: FontWeight.w700,
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
      padding: EdgeInsets.symmetric(horizontal: 20 * responsive.widthScale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 24 * responsive.scale, color: AppTheme.ink),
          SizedBox(width: 14 * responsive.widthScale),
          Expanded(
            child: Text(
              'Điểm đến, tên khách sạn...',
              style: TextStyle(
                color: const Color(0xFFA69E92),
                fontSize: 15 * responsive.scale,
              ),
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
      height: 46 * responsive.scale,
      padding: EdgeInsets.symmetric(horizontal: 24 * responsive.widthScale),
      decoration: BoxDecoration(
        color: active ? AppTheme.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? AppTheme.ink : AppTheme.neutral200,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppTheme.cream : AppTheme.ink,
            fontSize: 14 * responsive.scale,
            fontWeight: FontWeight.w500,
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
    super.key,
  });

  final String name;
  final String location;
  final String price;
  final List<Color> colors;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final width = compact ? 150 * responsive.widthScale : 222 * responsive.widthScale;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: (compact ? 136 : 132) * responsive.scale,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 14,
                  top: 14,
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 26 * responsive.scale,
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'NỔI BẬT',
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 9 * responsive.scale,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14 * responsive.scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.neutral500,
                    fontSize: 10 * responsive.scale,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 6 * responsive.scale),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: (compact ? 16 : 15) * responsive.scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10 * responsive.scale),
                Text(
                  price,
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 14 * responsive.scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12 * responsive.scale),
                Row(
                  children: [
                    Expanded(
                      child: _SmallActionButton(label: compact ? 'Chi tiết' : 'Xem chi tiết'),
                    ),
                    SizedBox(width: 8 * responsive.widthScale),
                    Expanded(
                      child: _SmallActionButton(label: 'Đặt ngay', filled: true),
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

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.label,
    this.filled = false,
  });

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      height: 34 * responsive.scale,
      decoration: BoxDecoration(
        color: filled ? AppTheme.accent : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accent),
      ),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: filled ? Colors.white : AppTheme.accent,
            fontSize: 11 * responsive.scale,
            fontWeight: FontWeight.w700,
          ),
        ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Column(
        children: [
          Container(
            height: 172 * responsive.scale,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(colors: colors),
            ),
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(18 * responsive.scale),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20 * responsive.widthScale,
                vertical: 10 * responsive.scale,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF0EE),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Sắp tới',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 16 * responsive.scale,
                ),
              ),
            ),
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
                    fontSize: 22 * responsive.scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10 * responsive.scale),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Color(0xFF5A3F3F)),
                    SizedBox(width: 6 * responsive.widthScale),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          color: const Color(0xFF5A3F3F),
                          fontSize: 16 * responsive.scale,
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
            color: const Color(0xFF5A3F3F),
            fontSize: 13 * responsive.scale,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 4 * responsive.scale),
        Text(
          value,
          style: TextStyle(
            color: alignRight ? AppTheme.accentDark : AppTheme.ink,
            fontSize: (alignRight ? 20 : 16) * responsive.scale,
            fontWeight: alignRight ? FontWeight.w800 : FontWeight.w500,
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
      padding: EdgeInsets.all(18 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28 * responsive.scale,
            backgroundColor: iconColor.withValues(alpha: 0.24),
            child: Icon(icon, color: iconColor, size: 26 * responsive.scale),
          ),
          SizedBox(width: 18 * responsive.widthScale),
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
                          fontSize: 20 * responsive.scale,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8 * responsive.scale),
                Text(
                  body,
                  style: TextStyle(
                    color: const Color(0xFF5A3F3F),
                    fontSize: 15 * responsive.scale,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 6 * responsive.scale),
                Text(
                  time,
                  style: TextStyle(
                    color: AppTheme.neutral500,
                    fontSize: 13 * responsive.scale,
                    fontWeight: FontWeight.w700,
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
