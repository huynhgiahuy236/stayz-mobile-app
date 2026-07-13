import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class FavoriteHotelCard extends StatelessWidget {
  const FavoriteHotelCard({
    required this.name,
    required this.location,
    required this.price,
    this.rating,
    required this.colors,
    this.imageUrl,
    this.onTap,
    this.onBook,
    this.onFavoriteTap,
    super.key,
  });

  final String name;
  final String location;
  final String price;

  /// `null` = khach san chua co danh gia nao.
  final String? rating;
  final List<Color> colors;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onBook;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final imageWidth =
        MediaQuery.sizeOf(context).width -
        responsive.horizontalPadding * 2 -
        24 * responsive.scale;
    final imageHeight = imageWidth / AppTheme.cardImageAspectRatio;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(color: AppTheme.line),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(12 * responsive.scale),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: LuxuryArchitecturalPainter(colors: colors),
                        ),
                        if (imageUrl != null)
                          StayZNetworkImage(
                            imageUrl: imageUrl!,
                            width: imageWidth,
                            height: imageHeight,
                          ),
                        Positioned(
                          top: 12 * responsive.scale,
                          right: 12 * responsive.scale,
                          child: InkWell(
                            onTap: onFavoriteTap,
                            customBorder: const CircleBorder(),
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Center(
                                child: CircleAvatar(
                                  radius: 18 * responsive.scale,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.92,
                                  ),
                                  child: Icon(
                                    Icons.favorite_rounded,
                                    color: AppTheme.primary,
                                    size: 19 * responsive.scale,
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
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16 * responsive.widthScale,
                  4 * responsive.scale,
                  16 * responsive.widthScale,
                  16 * responsive.scale,
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
                              fontSize: 17 * responsive.scale,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (rating != null) ...[
                          Icon(
                            Icons.star_rounded,
                            color: AppTheme.gold,
                            size: 17 * responsive.scale,
                          ),
                          SizedBox(width: 4 * responsive.widthScale),
                          Text(
                            rating!,
                            style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: 13 * responsive.scale,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 8 * responsive.scale),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppTheme.muted,
                          size: 16 * responsive.scale,
                        ),
                        SizedBox(width: 5 * responsive.widthScale),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.muted,
                              fontSize: 13 * responsive.scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12 * responsive.scale),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: price,
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 17 * responsive.scale,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                  text: tr(' / đêm', ' / night'),
                            style: TextStyle(
                              color: AppTheme.muted,
                              fontSize: 12 * responsive.scale,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14 * responsive.scale),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onTap,
              child: Text(tr('Chi tiết', 'Details')),
                          ),
                        ),
                        SizedBox(width: 10 * responsive.widthScale),
                        Expanded(
                          child: FilledButton(
                            onPressed: onBook,
              child: Text(tr('Xem phòng', 'View rooms')),
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
