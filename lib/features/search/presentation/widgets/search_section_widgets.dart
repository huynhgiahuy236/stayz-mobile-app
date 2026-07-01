import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
          color: AppTheme.ink,
        ),
        SizedBox(width: 8 * responsive.widthScale),
        Expanded(
          child: Container(
            height: 50 * responsive.scale,
            padding: EdgeInsets.symmetric(horizontal: 14 * responsive.widthScale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accent),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: AppTheme.accent,
                  size: 22 * responsive.scale,
                ),
                SizedBox(width: 8 * responsive.widthScale),
                Expanded(
                  child: Text(
                    'Da Lat',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontSize: 15 * responsive.scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.close,
                  color: AppTheme.neutral500,
                  size: 20 * responsive.scale,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12 * responsive.widthScale),
        InkWell(
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.filter),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 50 * responsive.scale,
            padding: EdgeInsets.symmetric(horizontal: 14 * responsive.widthScale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.neutral200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  color: AppTheme.ink,
                  size: 20 * responsive.scale,
                ),
                SizedBox(width: 6 * responsive.widthScale),
                Text(
                  'Loc',
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 14 * responsive.scale,
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

class SearchHotelCard extends StatelessWidget {
  const SearchHotelCard({
    required this.name,
    required this.location,
    required this.price,
    required this.reviewCount,
    required this.colors,
    this.badge,
    this.favorite = false,
    super.key,
  });

  final String name;
  final String location;
  final String price;
  final String reviewCount;
  final List<Color> colors;
  final String? badge;
  final bool favorite;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 190 * responsive.scale,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.18),
                        ],
                      ),
                    ),
                  ),
                ),
                if (badge != null)
                  Positioned(
                    top: 16 * responsive.scale,
                    left: 16 * responsive.widthScale,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * responsive.widthScale,
                        vertical: 8 * responsive.scale,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge!.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10 * responsive.scale,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 14 * responsive.scale,
                  right: 14 * responsive.widthScale,
                  child: CircleAvatar(
                    radius: 18 * responsive.scale,
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    child: Icon(
                      favorite ? Icons.favorite : Icons.favorite_border,
                      color: AppTheme.accent,
                      size: 21 * responsive.scale,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(18 * responsive.scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.neutral500,
                    fontSize: 10 * responsive.scale,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 8 * responsive.scale),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 19 * responsive.scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8 * responsive.scale),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        Icons.star_border,
                        color: const Color(0xFF8E5F1B),
                        size: 16 * responsive.scale,
                      ),
                    ),
                    SizedBox(width: 6 * responsive.widthScale),
                    Expanded(
                      child: Text(
                        '($reviewCount danh gia)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.neutral500,
                          fontSize: 12 * responsive.scale,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16 * responsive.scale),
                Row(
                  children: [
                    Icons.wifi,
                    Icons.local_parking_outlined,
                    Icons.pool_outlined,
                    Icons.restaurant_outlined,
                  ]
                      .map(
                        (icon) => Padding(
                          padding: EdgeInsets.only(right: 18 * responsive.widthScale),
                          child: Icon(
                            icon,
                            color: const Color(0xFF6B5348),
                            size: 18 * responsive.scale,
                          ),
                        ),
                      )
                      .toList(),
                ),
                Divider(height: 30 * responsive.scale, color: AppTheme.neutral200),
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
                                fontSize: 19 * responsive.scale,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                            TextSpan(
                              text: '/dem',
                              style: TextStyle(
                                color: AppTheme.neutral800,
                                fontSize: 12 * responsive.scale,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'Xem phong',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 14 * responsive.scale,
                        fontWeight: FontWeight.w700,
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

class SearchStateScaffold extends StatelessWidget {
  const SearchStateScaffold({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.secondaryLabel,
    this.showHeader = true,
    this.footer,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryLabel;
  final String secondaryLabel;
  final bool showHeader;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      bottomNavigationBar: showHeader ? const StayZBottomNav(activeTab: HomeTab.search) : null,
      body: SafeArea(
        bottom: !showHeader,
        child: Column(
          children: [
            if (showHeader) const SearchTopBar(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 244 * responsive.widthScale,
                      height: 244 * responsive.widthScale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.5),
                        border: Border.all(color: AppTheme.neutral200),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: AppTheme.accent.withValues(alpha: 0.84),
                          size: 82 * responsive.scale,
                        ),
                      ),
                    ),
                    SizedBox(height: 50 * responsive.scale),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppTheme.ink,
                        fontSize: 38 * responsive.scale,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 18 * responsive.scale),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF6B5348),
                        fontSize: 19 * responsive.scale,
                        height: 1.55,
                      ),
                    ),
                    SizedBox(height: 42 * responsive.scale),
                    PrimarySearchButton(label: primaryLabel),
                    SizedBox(height: 16 * responsive.scale),
                    SecondarySearchButton(label: secondaryLabel),
                    if (footer != null) ...[
                      SizedBox(height: 70 * responsive.scale),
                      footer!,
                    ],
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

class SearchTopBar extends StatelessWidget {
  const SearchTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        responsive.horizontalPadding,
        18 * responsive.scale,
        responsive.horizontalPadding,
        20 * responsive.scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF7F4),
        border: Border(
          bottom: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.menu, color: AppTheme.accentDark, size: 30 * responsive.scale),
          SizedBox(width: 28 * responsive.widthScale),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: textTheme.headlineMedium?.copyWith(
                  color: AppTheme.ink,
                  fontSize: 30 * responsive.scale,
                  fontWeight: FontWeight.w600,
                ),
                children: const [
                  TextSpan(text: 'Stay'),
                  TextSpan(text: 'Z', style: TextStyle(color: AppTheme.accent)),
                ],
              ),
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
  const PrimarySearchButton({
    required this.label,
    this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return SizedBox(
      width: double.infinity,
      height: 58 * responsive.scale,
      child: FilledButton(
        onPressed: onTap ?? () {},
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  const SecondarySearchButton({
    required this.label,
    this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return SizedBox(
      width: double.infinity,
      height: 58 * responsive.scale,
      child: OutlinedButton(
        onPressed: onTap ?? () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.neutral200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
