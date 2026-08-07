import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CORE SHIMMER ENGINE
// ─────────────────────────────────────────────────────────────────────────────

/// Widget bọc children với hiệu ứng shimmer gradient animation.
/// Không cần package ngoài — dùng AnimationController + LinearGradient thuần.
class StayzShimmer extends StatefulWidget {
  const StayzShimmer({required this.child, this.enabled = true, super.key});

  final Widget child;
  final bool enabled;

  @override
  State<StayzShimmer> createState() => _StayzShimmerState();
}

class _StayzShimmerState extends State<StayzShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppTheme.shimmerBaseDark : AppTheme.shimmerBase;
    final highlight =
        isDark ? AppTheme.shimmerHighlightDark : AppTheme.shimmerHighlight;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [base, highlight, highlight, base],
              stops: const [0.0, 0.35, 0.65, 1.0],
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIMITIVE BUILDING BLOCKS
// ─────────────────────────────────────────────────────────────────────────────

/// Hình chữ nhật shimmer đơn giản.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    required this.width,
    required this.height,
    this.radius,
    super.key,
  });

  final double width;
  final double height;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppTheme.shimmerBaseDark : AppTheme.shimmerBase;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius ?? 8),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOTEL CARD SKELETON
// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton cho HotelCard (normal + compact variant).
class HotelCardSkeleton extends StatelessWidget {
  const HotelCardSkeleton({this.compact = false, this.fullWidth = false, super.key});

  final bool compact;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Theme.of(context).cardColor : Colors.white;
    final width = fullWidth
        ? null
        : (compact ? 174.0 : 254.0);

    return StayzShimmer(
      child: SizedBox(
        width: width,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(
              color: isDark ? AppTheme.borderDark : AppTheme.line,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image placeholder
              AspectRatio(
                aspectRatio: AppTheme.cardImageAspectRatio,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.cardRadius),
                  ),
                  child: ShimmerBox(
                    width: double.infinity,
                    height: double.infinity,
                    radius: 0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: compact ? 110 : 170, height: 14, radius: 6),
                    const SizedBox(height: 8),
                    ShimmerBox(width: compact ? 80 : 120, height: 12, radius: 6),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerBox(width: compact ? 60 : 90, height: 14, radius: 6),
                        ShimmerBox(width: 40, height: 12, radius: 6),
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

// ─────────────────────────────────────────────────────────────────────────────
// BOOKING CARD SKELETON
// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton cho UpcomingBookingCard / HistoryBookingCard.
class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Theme.of(context).cardColor : Colors.white;

    return StayzShimmer(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.line,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ShimmerBox(width: 80, height: 80, radius: 0),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 160, height: 14, radius: 6),
                    const SizedBox(height: 8),
                    ShimmerBox(width: 110, height: 12, radius: 6),
                    const SizedBox(height: 8),
                    ShimmerBox(width: 80, height: 20, radius: 10),
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

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE / SETTINGS TILE SKELETON
// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton cho một dòng trong Settings/Profile.
class ProfileTileSkeleton extends StatelessWidget {
  const ProfileTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Theme.of(context).cardColor : Colors.white;

    return StayzShimmer(
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.controlRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ShimmerBox(width: 36, height: 36, radius: 10),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerBox(width: 140, height: 13, radius: 6),
                    const SizedBox(height: 6),
                    ShimmerBox(width: 90, height: 11, radius: 6),
                  ],
                ),
              ),
              ShimmerBox(width: 20, height: 20, radius: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOTEL LIST (multiple cards stacked)
// ─────────────────────────────────────────────────────────────────────────────

/// Hiển thị N skeleton cards theo chiều dọc (dùng cho Search results / Favorites).
class HotelListSkeleton extends StatelessWidget {
  const HotelListSkeleton({this.count = 4, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      padding: EdgeInsets.zero,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: HotelCardSkeleton(fullWidth: true),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOTEL DETAIL SKELETON (Screen 2 of wireframe)
// ─────────────────────────────────────────────────────────────────────────────

class HotelDetailSkeleton extends StatelessWidget {
  const HotelDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surface;
    final cardColor = isDark ? Theme.of(context).cardColor : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image Box
            StayzShimmer(
              child: Container(
                width: double.infinity,
                height: 280,
                color: cardColor,
                child: const Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 48,
                      child: CircleAvatar(
                        backgroundColor: Colors.black12,
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title skeleton
                  const StayzShimmer(
                    child: ShimmerBox(width: 220, height: 24, radius: 8),
                  ),
                  const SizedBox(height: 10),
                  // Rating / Location row
                  const StayzShimmer(
                    child: Row(
                      children: [
                        ShimmerBox(width: 50, height: 14, radius: 6),
                        SizedBox(width: 12),
                        ShimmerBox(width: 130, height: 14, radius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Amenities row (4 circles)
                  const StayzShimmer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerBox(width: 60, height: 60, radius: 30),
                        ShimmerBox(width: 60, height: 60, radius: 30),
                        ShimmerBox(width: 60, height: 60, radius: 30),
                        ShimmerBox(width: 60, height: 60, radius: 30),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Description paragraphs
                  const StayzShimmer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: double.infinity, height: 14, radius: 6),
                        SizedBox(height: 8),
                        ShimmerBox(width: double.infinity, height: 14, radius: 6),
                        SizedBox(height: 8),
                        ShimmerBox(width: 180, height: 14, radius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Map card skeleton
                  StayzShimmer(
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: StayzShimmer(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border(
              top: BorderSide(
                color: isDark ? AppTheme.borderDark : AppTheme.line,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 70, height: 12, radius: 6),
                  SizedBox(height: 6),
                  ShimmerBox(width: 100, height: 18, radius: 6),
                ],
              ),
              Container(
                width: 140,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.primary : AppTheme.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
