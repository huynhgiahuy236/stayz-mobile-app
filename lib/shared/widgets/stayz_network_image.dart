import 'dart:math' as math;

import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class StayZNetworkImage extends StatelessWidget {
  const StayZNetworkImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel,
    super.key,
  });

  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  /// Mo ta anh cho trinh doc man hinh.
  final String? semanticLabel;

  /// Chuyen doi tat ca anh xau/anh cong trinh backend sang bo anh 4K HD sang trong.
  static String resolveHighQualityImageUrl(String rawUrl) {
    if (rawUrl.isEmpty) return 'assets/images/luxury_ocean_resort.jpg';
    if (rawUrl.startsWith('assets/')) return rawUrl;

    final lower = rawUrl.toLowerCase();

    if (lower.contains('sheraton') || lower.contains('danang') || lower.contains('four points') || lower.contains('đà nẵng')) {
      return 'assets/images/luxury_ocean_resort.jpg';
    }
    if (lower.contains('colline') || lower.contains('dalat') || lower.contains('đà lạt')) {
      return 'assets/images/modern_penthouse_suite.jpg';
    }
    if (lower.contains('ana') || lower.contains('mandara')) {
      return 'assets/images/tropical_beach_villa.jpg';
    }
    if (lower.contains('intercontinental') || lower.contains('saigon') || lower.contains('hồ chí minh')) {
      return 'assets/images/city_executive_hotel.jpg';
    }
    if (lower.contains('sapa') || lower.contains('horizon')) {
      return 'assets/images/mountain_pine_resort.jpg';
    }
    if (lower.contains('hoi an') || lower.contains('heritage') || lower.contains('hội an')) {
      return 'assets/images/boutique_heritage_hotel.jpg';
    }
    if (lower.contains('phu quoc') || lower.contains('pearl') || lower.contains('phú quốc')) {
      return 'assets/images/private_sunset_pool_villa.jpg';
    }

    const hdPhotos = [
      'assets/images/luxury_ocean_resort.jpg',
      'assets/images/city_executive_hotel.jpg',
      'assets/images/modern_penthouse_suite.jpg',
      'assets/images/private_sunset_pool_villa.jpg',
      'assets/images/boutique_heritage_hotel.jpg',
      'assets/images/mountain_pine_resort.jpg',
      'assets/images/luxury_rooftop_terrace.jpg',
      'assets/images/spa_wellness_resort.jpg',
    ];

    final index = (rawUrl.hashCode.abs()) % hdPhotos.length;
    return hdPhotos[index];
  }

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = resolveHighQualityImageUrl(imageUrl);

    if (effectiveUrl.startsWith('assets/')) {
      final assetImage = Image.asset(
        effectiveUrl,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.medium,
        semanticLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null || semanticLabel!.isEmpty,
        errorBuilder: (context, error, stackTrace) => Semantics(
          label: semanticLabel == null
              ? null
              : '${semanticLabel!}. ${context.l10n.text('Không tải được ảnh', 'Image unavailable')}',
          image: true,
          child: ExcludeSemantics(
            child: _Placeholder(
              width: width,
              height: height,
              child: Center(
                child: Icon(Icons.image_not_supported_outlined, color: Theme.of(context).colorScheme.secondary, size: 26),
              ),
            ),
          ),
        ),
      );

      if (borderRadius == null) return assetImage;
      return ClipRRect(borderRadius: borderRadius!, child: assetImage);
    }

    final pixelRatio = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 3.0);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final effectiveWidth = width.isFinite ? width : screenWidth;
    final effectiveHeight = height.isFinite ? height : screenWidth;
    final cacheWidth = math.max(1, (effectiveWidth * pixelRatio).round());
    final cacheHeight = math.max(1, (effectiveHeight * pixelRatio).round());

    final image = Image.network(
      effectiveUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      filterQuality: FilterQuality.medium,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null || semanticLabel!.isEmpty,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return _Placeholder(width: width, height: height, child: const _Shimmer());
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _Placeholder(width: width, height: height, child: const _Shimmer());
      },
      errorBuilder: (context, error, stackTrace) => Semantics(
        label: semanticLabel == null
            ? null
            : '${semanticLabel!}. ${context.l10n.text('Không tải được ảnh', 'Image unavailable')}',
        image: true,
        child: ExcludeSemantics(
          child: _Placeholder(
            width: width,
            height: height,
            child: Center(
              child: Icon(Icons.image_not_supported_outlined, color: Theme.of(context).colorScheme.secondary, size: 26),
            ),
          ),
        ),
      ),
    );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.width, required this.height, required this.child});

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(color: AppTheme.primarySoft.withValues(alpha: 0.55), child: child),
    );
  }
}

class _Shimmer extends StatefulWidget {
  const _Shimmer();

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppTheme.shimmerBaseDark : AppTheme.shimmerBase;
    final highlightColor = isDark ? AppTheme.shimmerHighlightDark : AppTheme.shimmerHighlight;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                math.max(0.0, _controller.value - 0.3),
                _controller.value,
                math.min(1.0, _controller.value + 0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}
