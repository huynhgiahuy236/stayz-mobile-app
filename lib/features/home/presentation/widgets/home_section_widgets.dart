import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/notifications/notifications_controller.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
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
    final width = size.width.clamp(360.0, 560.0).toDouble();
    final widthScale = (width / 390).clamp(0.92, 1.16).toDouble();
    final heightScale = (size.height / 844).clamp(0.78, 1.05).toDouble();
    final maxContentPadding = size.width >= 720 ? (size.width - 640) / 2 : 0.0;

    return HomeResponsive._(
      widthScale: widthScale,
      heightScale: heightScale,
      scale: widthScale < heightScale ? widthScale : heightScale,
      horizontalPadding: maxContentPadding > 0 ? maxContentPadding : 20 * widthScale,
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

    return SafeArea(
      top: false,
      minimum: EdgeInsets.only(bottom: 8 * responsive.scale),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          10 * responsive.widthScale,
          6 * responsive.scale,
          10 * responsive.widthScale,
          0,
        ),
        child: SizedBox(
          height: 66 * responsive.scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.line),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.ink.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4 * responsive.widthScale, vertical: 4 * responsive.scale),
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: tr('Trang chủ', 'Home'),
                    active: activeTab == HomeTab.home,
                    routeName: AppRoutes.home,
                  ),
                  _NavItem(
                    icon: Icons.travel_explore_rounded,
                    label: tr('Tìm kiếm', 'Search'),
                    active: activeTab == HomeTab.search,
                    routeName: AppRoutes.search,
                  ),
                  _NavItem(
                    icon: Icons.favorite_rounded,
                    label: tr('Đã lưu', 'Saved'),
                    active: activeTab == HomeTab.saved,
                    routeName: AppRoutes.favorites,
                  ),
                  _NavItem(
                    icon: Icons.calendar_month_rounded,
                    label: tr('Lịch đặt', 'Trips'),
                    active: activeTab == HomeTab.bookings,
                    routeName: AppRoutes.myBookings,
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: tr('Tôi', 'Me'),
                    active: activeTab == HomeTab.profile,
                    routeName: AppRoutes.settings,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.routeName,
  });

  final IconData icon;
  final String label;
  final bool active;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: 56 * responsive.scale,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 2 * responsive.widthScale, vertical: 5 * responsive.scale),
      decoration: BoxDecoration(
        color: active ? AppTheme.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? AppTheme.primary : AppTheme.muted, size: 22 * responsive.scale),
          SizedBox(height: 3 * responsive.scale),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: active ? AppTheme.primary : AppTheme.muted,
                  fontSize: 10.5 * responsive.scale,
                  fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Expanded(
      child: Semantics(
        selected: active,
        button: true,
        label: label,
        child: InkWell(
          onTap: active || currentRoute == routeName ? null : () => Navigator.of(context).pushReplacementNamed(routeName),
          borderRadius: BorderRadius.circular(18),
          child: Center(child: content),
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
        Container(
          width: 46 * responsive.scale,
          height: 46 * responsive.scale,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.hotel_class_rounded, color: Colors.white),
        ),
        SizedBox(width: 12 * responsive.widthScale),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Noto Serif JP',
              fontSize: 27 * responsive.scale,
              fontWeight: FontWeight.w800,
            ),
            children: const [
              TextSpan(text: 'Stay', style: TextStyle(color: AppTheme.ink)),
              TextSpan(text: 'Z', style: TextStyle(color: AppTheme.primary)),
            ],
          ),
        ),
        const Spacer(),
        const _NotificationBell(),
        SizedBox(width: 10 * responsive.widthScale),
        _RoundIconButton(
          icon: Icons.person_outline_rounded,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
        ),
      ],
    );
  }
}

class StayZScreenHeader extends StatelessWidget {
  const StayZScreenHeader({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        responsive.horizontalPadding,
        16 * responsive.scale,
        responsive.horizontalPadding,
        18 * responsive.scale,
      ),
      child: Row(
        children: [
          leading ?? const SizedBox.shrink(),
          if (leading != null) SizedBox(width: 12 * responsive.widthScale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null) ...[
                  Text(
                    subtitle!.toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 11 * responsive.scale,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
                  ),
                  SizedBox(height: 4 * responsive.scale),
                ],
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 28 * responsive.scale,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({
    required this.title,
    this.action,
    this.onAction,
    super.key,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 19 * responsive.scale,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if (action != null)
          TextButton(
            onPressed: onAction ?? () => Navigator.of(context).pushNamed(AppRoutes.search),
            child: Text(action!),
          ),
      ],
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    this.onTap,
    this.onFilterTap,
    super.key,
  });

  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap ?? () => Navigator.of(context).pushNamed(AppRoutes.search),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: BoxConstraints(minHeight: 60 * responsive.scale),
          padding: EdgeInsets.symmetric(horizontal: 16 * responsive.widthScale, vertical: 10 * responsive.scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.line),
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 24 * responsive.scale, color: AppTheme.primary),
              SizedBox(width: 12 * responsive.widthScale),
              Expanded(
                child: Text(
                  tr('Bạn muốn đi đâu?', 'Where to?'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 15 * responsive.scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onFilterTap,
                child: Container(
                  width: 40 * responsive.scale,
                  height: 40 * responsive.scale,
                  decoration: BoxDecoration(
                    color: AppTheme.ink,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.tune_rounded, color: Colors.white, size: 19 * responsive.scale),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterPill extends StatelessWidget {
  const FilterPill({
    required this.label,
    this.active = false,
    this.icon,
    this.onTap,
    super.key,
  });

  final String label;
  final bool active;
  final IconData? icon;

  /// Thieu callback nay thi chip chi la trang tri: truoc day bam khong co gi xay ra.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Semantics(
      button: onTap != null,
      selected: active,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: BoxConstraints(minHeight: 42 * responsive.scale),
            padding: EdgeInsets.symmetric(horizontal: 16 * responsive.widthScale),
            decoration: BoxDecoration(
              color: active ? AppTheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: active ? AppTheme.primary : AppTheme.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 17 * responsive.scale, color: active ? Colors.white : AppTheme.primary),
                  SizedBox(width: 7 * responsive.widthScale),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.white : AppTheme.ink,
                    fontSize: 13 * responsive.scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
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
    required this.onTap,
    this.compact = false,
    this.fullWidth = false,
    this.imageUrl,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.rating,
    this.reviewCount = 0,
    super.key,
  });

  final String name;
  final String location;
  final String price;
  final List<Color> colors;
  final bool compact;
  final bool fullWidth;
  final String? imageUrl;

  /// Bat buoc: truoc day mac dinh `onTap` mo `/room-detail` KHONG kem tham so,
  /// khien man chi tiet hien du lieu rong.
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  /// Diem danh gia that. `null` = chua co danh gia nao, khong hien huy hieu.
  final double? rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final width = fullWidth ? null : (compact ? 174 * responsive.widthScale : 254 * responsive.widthScale);

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.line),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  // Chieu cao suy tu chieu rong the theo ti le chung, nen anh
                  // luon can doi du the ngang hay rong het man hinh.
                  aspectRatio: AppTheme.cardImageAspectRatio,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(painter: LuxuryArchitecturalPainter(colors: colors)),
                        if (imageUrl != null)
                          StayZNetworkImage(
                            imageUrl: imageUrl!,
                            width: width ?? MediaQuery.sizeOf(context).width,
                            height: (width ?? MediaQuery.sizeOf(context).width) / AppTheme.cardImageAspectRatio,
                          ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.38)],
                            ),
                          ),
                        ),
                        if (rating != null && reviewCount > 0)
                          Positioned(
                            top: 12 * responsive.scale,
                            left: 12 * responsive.scale,
                            child: _RatingBadge(value: rating!.toStringAsFixed(1), reviewCount: reviewCount),
                          ),
                        Positioned(
                          top: 4 * responsive.scale,
                          right: 4 * responsive.scale,
                          child: Semantics(
                            button: true,
                            label: isFavorite ? 'Bỏ khỏi yêu thích' : 'Thêm vào yêu thích',
                            child: InkResponse(
                              onTap: onFavoriteTap,
                              radius: 24,
                              // Vung cham 48dp theo chuan Android, trong khi
                              // huy hieu ben trong van giu 36dp cho gon mat.
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: Center(
                                  child: _GlassIcon(
                                    icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    active: isFavorite,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(14 * responsive.scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14 * responsive.scale, color: AppTheme.primary),
                          SizedBox(width: 5 * responsive.widthScale),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.muted,
                                fontSize: 11 * responsive.scale,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8 * responsive.scale),
                      Text(
                        name,
                        maxLines: fullWidth ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.ink,
                          fontSize: 16 * responsive.scale,
                          height: 1.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 12 * responsive.scale),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 14 * responsive.scale,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_rounded, color: AppTheme.ink, size: 20 * responsive.scale),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
    this.imageUrl,
    this.onTap,
    super.key,
  });

  final String name;
  final String location;
  final String date;
  final String total;
  final List<Color> colors;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final thumbSize = 84 * responsive.scale;

    return Material(
      color: AppTheme.ink,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap ?? () => Navigator.of(context).pushNamed(AppRoutes.myBookings),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.all(16 * responsive.scale),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: thumbSize,
                  height: thumbSize,
                  // Anh khach san that; khong co thi ve gradient + icon.
                  child: (imageUrl != null && imageUrl!.isNotEmpty)
                      ? StayZNetworkImage(imageUrl: imageUrl!, width: thumbSize, height: thumbSize)
                      : DecoratedBox(
                          decoration: BoxDecoration(gradient: LinearGradient(colors: colors)),
                          child: const Icon(Icons.confirmation_number_rounded, color: Colors.white),
                        ),
                ),
              ),
              SizedBox(width: 16 * responsive.widthScale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w900)),
                    SizedBox(height: 6 * responsive.scale),
                    Text(location, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white70, fontSize: 13 * responsive.scale)),
                    SizedBox(height: 12 * responsive.scale),
                    Row(
                      children: [
                        Expanded(child: _DarkMeta(label: 'Ngày', value: date)),
                        _DarkMeta(label: 'Tổng', value: total, alignEnd: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: unread ? AppTheme.primary.withValues(alpha: 0.35) : AppTheme.line),
        boxShadow: unread ? AppTheme.softShadow : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46 * responsive.scale,
            height: 46 * responsive.scale,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 22 * responsive.scale),
          ),
          SizedBox(width: 14 * responsive.widthScale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.ink, fontSize: 15 * responsive.scale, fontWeight: FontWeight.w900)),
                    ),
                    if (unread)
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                  ],
                ),
                SizedBox(height: 6 * responsive.scale),
                Text(body, style: TextStyle(color: AppTheme.muted, fontSize: 13 * responsive.scale, height: 1.35)),
                SizedBox(height: 8 * responsive.scale),
                Text(time, style: TextStyle(color: AppTheme.muted, fontSize: 12 * responsive.scale, fontWeight: FontWeight.w700)),
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
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors.length >= 2 ? colors : [AppTheme.primary, AppTheme.ink],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final glowPaint = Paint()..color = Colors.white.withValues(alpha: 0.16);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.28), size.shortestSide * 0.24, glowPaint);

    final wave = Path()
      ..moveTo(0, size.height * 0.78)
      ..quadraticBezierTo(size.width * 0.34, size.height * 0.58, size.width * 0.68, size.height * 0.80)
      ..quadraticBezierTo(size.width * 0.86, size.height * 0.92, size.width, size.height * 0.70)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave, Paint()..color = Colors.white.withValues(alpha: 0.12));

    final arch = Path()
      ..moveTo(size.width * 0.14, size.height)
      ..lineTo(size.width * 0.14, size.height * 0.52)
      ..quadraticBezierTo(size.width * 0.28, size.height * 0.22, size.width * 0.42, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height)
      ..close();
    canvas.drawPath(arch, Paint()..color = Colors.white.withValues(alpha: 0.13));
  }

  @override
  bool shouldRepaint(covariant LuxuryArchitecturalPainter oldDelegate) => oldDelegate.colors != colors;
}

class TicketDashedDivider extends StatelessWidget {
  const TicketDashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        18,
        (_) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 1,
            color: AppTheme.line,
          ),
        ),
      ),
    );
  }
}

/// Chuong thong bao co badge dem so chua doc. Lang nghe NotificationsController
/// nen badge tu cap nhat khi co booking moi hoac khi danh dau da doc.
class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  @override
  void initState() {
    super.initState();
    // Cap nhat so chua doc moi lan header xuat hien.
    WidgetsBinding.instance.addPostFrameCallback((_) => NotificationsController.instance.refresh());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NotificationsController.instance,
      builder: (context, _) {
        final unread = NotificationsController.instance.unread;
        return Badge(
          isLabelVisible: unread > 0,
          label: Text(unread > 9 ? '9+' : '$unread'),
          backgroundColor: AppTheme.danger,
          child: _RoundIconButton(
            icon: unread > 0 ? Icons.notifications_rounded : Icons.notifications_none_rounded,
            onTap: () async {
              await Navigator.of(context).pushNamed(AppRoutes.notifications);
              await NotificationsController.instance.refresh();
            },
          ),
        );
      },
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44 * responsive.scale,
          height: 44 * responsive.scale,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.line)),
          child: Icon(icon, color: AppTheme.ink, size: 22 * responsive.scale),
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.value, required this.reviewCount});

  final String value;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Semantics(
      label: 'Đánh giá $value trên 5, $reviewCount lượt',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * responsive.widthScale, vertical: 5 * responsive.scale),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, color: AppTheme.gold, size: 14 * responsive.scale),
            SizedBox(width: 3 * responsive.widthScale),
            Text(value, style: TextStyle(color: AppTheme.ink, fontSize: 11 * responsive.scale, fontWeight: FontWeight.w900)),
            SizedBox(width: 3 * responsive.widthScale),
            Text(
              '($reviewCount)',
              style: TextStyle(color: AppTheme.muted, fontSize: 10 * responsive.scale, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon({required this.icon, this.active = false});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      width: 36 * responsive.scale,
      height: 36 * responsive.scale,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
      ),
      child: Icon(icon, color: active ? AppTheme.primary : Colors.white, size: 19 * responsive.scale),
    );
  }
}

class _DarkMeta extends StatelessWidget {
  const _DarkMeta({required this.label, required this.value, this.alignEnd = false});

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(color: Colors.white54, fontSize: 10 * responsive.scale, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        SizedBox(height: 4 * responsive.scale),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 13 * responsive.scale, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
