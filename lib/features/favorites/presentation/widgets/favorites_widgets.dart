import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class FavoriteHotelCard extends StatelessWidget {
  const FavoriteHotelCard({
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.colors,
    super.key,
  });

  final String name;
  final String location;
  final String price;
  final String rating;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 152 * responsive.scale,
                margin: EdgeInsets.fromLTRB(
                  12 * responsive.widthScale,
                  12 * responsive.scale,
                  12 * responsive.widthScale,
                  0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                ),
              ),
              Positioned(
                right: 22 * responsive.widthScale,
                top: 24 * responsive.scale,
                child: CircleAvatar(
                  radius: 20 * responsive.scale,
                  backgroundColor: Colors.white.withValues(alpha: 0.92),
                  child: Icon(
                    Icons.favorite_border,
                    color: AppTheme.accent,
                    size: 23 * responsive.scale,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              14 * responsive.widthScale,
              12 * responsive.scale,
              14 * responsive.widthScale,
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
                          fontSize: 19 * responsive.scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(Icons.star, color: const Color(0xFFF0A31A), size: 16 * responsive.scale),
                    SizedBox(width: 4 * responsive.widthScale),
                    Text(
                      rating,
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 14 * responsive.scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8 * responsive.scale),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: AppTheme.neutral500, size: 16 * responsive.scale),
                    SizedBox(width: 4 * responsive.widthScale),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppTheme.neutral500, fontSize: 14 * responsive.scale),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10 * responsive.scale),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: price,
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 17 * responsive.scale,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      TextSpan(
                        text: ' / dem',
                        style: TextStyle(
                          color: AppTheme.neutral500,
                          fontSize: 13 * responsive.scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * responsive.scale),
                _FavoriteActionButton(
                  label: 'Xem chi tiet',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.roomDetail),
                ),
                SizedBox(height: 6 * responsive.scale),
                _FavoriteActionButton(
                  label: 'Dat ngay',
                  filled: true,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.roomSelection),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteActionButton extends StatelessWidget {
  const _FavoriteActionButton({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return SizedBox(
      width: double.infinity,
      height: 26 * responsive.scale,
      child: filled
          ? FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppTheme.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13 * responsive.scale,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: const BorderSide(color: AppTheme.accent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 13 * responsive.scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}
