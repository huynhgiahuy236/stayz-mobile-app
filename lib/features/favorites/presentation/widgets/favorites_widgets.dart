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
    this.imageUrl,
    super.key,
  });

  final String name;
  final String location;
  final String price;
  final String rating;
  final List<Color> colors;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neutral200.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutral800.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 22 * responsive.widthScale,
                top: 24 * responsive.scale,
                child: Container(
                  width: 32 * responsive.scale,
                  height: 32 * responsive.scale,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite,
                      color: AppTheme.accent,
                      size: 18,
                    ),
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
                          fontSize: 16 * responsive.scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(Icons.star_rounded, color: Colors.amber[700], size: 16 * responsive.scale),
                    SizedBox(width: 4 * responsive.widthScale),
                    Text(
                      rating,
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 13 * responsive.scale,
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
                        style: TextStyle(color: AppTheme.neutral500, fontSize: 13 * responsive.scale),
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
                          fontSize: 16 * responsive.scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: ' / đêm',
                        style: TextStyle(
                          color: AppTheme.neutral500,
                          fontSize: 12 * responsive.scale,
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
