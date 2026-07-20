import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_taxonomy.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:capstone_mobile/shared/widgets/stayz_brand_logo.dart';

class SearchHotelCard extends StatelessWidget {
  const SearchHotelCard({
    required this.name,
    required this.location,
    required this.price,
    required this.colors,
    required this.onTap,
    required this.onRoomsTap,
    required this.onBookNow,
    this.rating,
    this.reviewCount = 0,
    this.amenities = const <String>[],
    this.badge,
    this.badgeIsWarning = false,
    this.favorite = false,
    this.imageUrl,
    this.onFavoriteTap,
    super.key,
  });

  final String name;
  final String location;
  final String price;
  final List<Color> colors;

  /// Bat buoc: mac dinh cu dieu huong khong kem tham so, dan toi man
  /// chon phong am tham chon khach san dau tien trong danh sach.
  final VoidCallback onTap;
  final VoidCallback onRoomsTap;
  final VoidCallback onBookNow;

  /// `null` = chua co danh gia. Khong ve sao va khong bia so luot.
  final double? rating;
  final int reviewCount;

  /// Khoa tien ich that cua khach san, toi da 4 icon dau.
  final List<String> amenities;

  final String? badge;
  final bool badgeIsWarning;
  final bool favorite;
  final String? imageUrl;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final imageWidth =
        MediaQuery.sizeOf(context).width - responsive.horizontalPadding * 2;
    final imageHeight = imageWidth / AppTheme.cardImageAspectRatio;
    final shownAmenities = amenities.take(4).toList();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      // Cat moi thu ben trong theo bo goc: nen ve (CustomPaint) phia sau anh
      // truoc day loi goc vuong ra ngoai the.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(color: AppTheme.line),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                // Chieu cao suy tu chieu rong the theo ti le chung, tranh anh
                // bi cat cut thanh dai mong.
                aspectRatio: AppTheme.cardImageAspectRatio,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: LuxuryArchitecturalPainter(colors: colors),
                      ),
                    ),
                    if (imageUrl != null)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppTheme.cardRadius),
                          ),
                          child: StayZNetworkImage(
                            imageUrl: imageUrl!,
                            width: imageWidth,
                            height: imageHeight,
                          ),
                        ),
                      ),
                    if (badge != null)
                      Positioned(
                        top: 12 * responsive.scale,
                        left: 12 * responsive.widthScale,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * responsive.widthScale,
                            vertical: 5 * responsive.scale,
                          ),
                          decoration: BoxDecoration(
                            color: badgeIsWarning
                                ? AppTheme.danger
                                : AppTheme.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10 * responsive.scale,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Semantics(
                        button: true,
                        label: favorite
                            ? tr('Bỏ khỏi yêu thích', 'Remove from favorites')
                            : tr('Thêm vào yêu thích', 'Add to favorites'),
                        child: InkResponse(
                          onTap: onFavoriteTap,
                          radius: 24,
                          // Vung cham 48dp; huy hieu tron ben trong van 36dp.
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.92,
                                ),
                                child: Icon(
                                  favorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: AppTheme.accent,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  14 * responsive.scale,
                  12 * responsive.scale,
                  14 * responsive.scale,
                  12 * responsive.scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: 16 * responsive.scale,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (rating != null && reviewCount > 0) ...[
                          SizedBox(width: 8 * responsive.widthScale),
                          Icon(
                            Icons.star_rounded,
                            color: AppTheme.gold,
                            size: 16 * responsive.scale,
                          ),
                          SizedBox(width: 2 * responsive.widthScale),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: 13 * responsive.scale,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 3 * responsive.widthScale),
                          Text(
                            '($reviewCount)',
                            style: TextStyle(
                              color: AppTheme.muted,
                              fontSize: 12 * responsive.scale,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4 * responsive.scale),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 14 * responsive.scale,
                          color: AppTheme.muted,
                        ),
                        SizedBox(width: 3 * responsive.widthScale),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.muted,
                              fontSize: 12.5 * responsive.scale,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (shownAmenities.isNotEmpty) ...[
                      SizedBox(height: 10 * responsive.scale),
                      Row(
                        children: [
                          for (final slug in shownAmenities)
                            Padding(
                              padding: EdgeInsets.only(
                                right: 14 * responsive.widthScale,
                              ),
                              child: Tooltip(
                                message: StayzTaxonomy.amenityTerm(slug).label,
                                child: Icon(
                                  StayzTaxonomy.amenityTerm(slug).icon,
                                  color: AppTheme.muted,
                                  size: 17 * responsive.scale,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    SizedBox(height: 12 * responsive.scale),
                    Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: price,
                                  style: TextStyle(
                                    color: AppTheme.accent,
                                    fontSize: 17 * responsive.scale,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(
                                  text: tr(' / đêm', ' / night'),
                                  style: TextStyle(
                                    color: AppTheme.muted,
                                    fontSize: 12 * responsive.scale,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * responsive.widthScale),
                        SizedBox(
                          height: 44 * responsive.scale,
                          child: OutlinedButton(
                            onPressed: onBookNow,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14 * responsive.widthScale,
                              ),
                              minimumSize: const Size(0, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(tr('Chi tiết', 'Details')),
                          ),
                        ),
                        SizedBox(width: 8 * responsive.widthScale),
                        SizedBox(
                          height: 44 * responsive.scale,
                          child: FilledButton(
                            onPressed: onRoomsTap,
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16 * responsive.widthScale,
                              ),
                              minimumSize: const Size(0, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(tr('Xem phòng', 'View rooms')),
                            ),
                          ),
                        ),
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

class SearchStateScaffold extends StatelessWidget {
  const SearchStateScaffold({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.secondaryLabel,
    this.onPrimary,
    this.onSecondary,
    this.showHeader = true,
    this.footer,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryLabel;
  final String secondaryLabel;

  /// Thieu handler thi nut se bi vo hieu hoa thay vi im lang khong lam gi.
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  final bool showHeader;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      bottomNavigationBar: showHeader
          ? const StayZBottomNav(activeTab: HomeTab.search)
          : null,
      body: SafeArea(
        bottom: !showHeader,
        child: Column(
          children: [
            if (showHeader) const SearchTopBar(),
            // Cuon duoc: khoi tran khi man hinh nho hoac co chu he thong phong to.
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                    vertical: 24 * responsive.scale,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 132 * responsive.widthScale,
                        height: 132 * responsive.widthScale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.5),
                          border: Border.all(color: AppTheme.neutral200),
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            color: AppTheme.accent.withValues(alpha: 0.84),
                            size: 52 * responsive.scale,
                          ),
                        ),
                      ),
                      SizedBox(height: 24 * responsive.scale),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppTheme.ink,
                          fontSize: 24 * responsive.scale,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: 14 * responsive.scale),
                      Text(
                        body,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 15 * responsive.scale,
                          height: 1.55,
                        ),
                      ),
                      SizedBox(height: 24 * responsive.scale),
                      PrimarySearchButton(
                        label: primaryLabel,
                        onTap: onPrimary,
                      ),
                      SizedBox(height: 12 * responsive.scale),
                      SecondarySearchButton(
                        label: secondaryLabel,
                        onTap: onSecondary,
                      ),
                      if (footer != null) ...[
                        SizedBox(height: 32 * responsive.scale),
                        footer!,
                      ],
                    ],
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

class SearchTopBar extends StatelessWidget {
  const SearchTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        responsive.horizontalPadding,
        18 * responsive.scale,
        responsive.horizontalPadding,
        20 * responsive.scale,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.menu,
            color: AppTheme.accentDark,
            size: 30 * responsive.scale,
          ),
          SizedBox(width: 28 * responsive.widthScale),
          Expanded(
            child: StayZBrandLogo(
              size: 48 * responsive.scale,
              borderRadius: 14,
              alignment: Alignment.centerLeft,
            ),
          ),
          Icon(
            Icons.notifications_none_outlined,
            color: AppTheme.accentDark,
            size: 30 * responsive.scale,
          ),
        ],
      ),
    );
  }
}

class PrimarySearchButton extends StatelessWidget {
  const PrimarySearchButton({required this.label, this.onTap, super.key});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return SizedBox(
      width: double.infinity,
      height: 58 * responsive.scale,
      child: FilledButton(
        // Khong co handler thi disable, thay vi giả vờ bấm được rồi không làm gì.
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18 * responsive.scale,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class SecondarySearchButton extends StatelessWidget {
  const SecondarySearchButton({required this.label, this.onTap, super.key});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return SizedBox(
      width: double.infinity,
      height: 58 * responsive.scale,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.neutral200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 18 * responsive.scale,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
