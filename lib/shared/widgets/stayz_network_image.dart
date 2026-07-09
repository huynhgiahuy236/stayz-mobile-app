import 'dart:math' as math;

import 'package:flutter/material.dart';

class StayZNetworkImage extends StatelessWidget {
  const StayZNetworkImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    super.key,
  });

  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 3.0);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final effectiveWidth = width.isFinite ? width : screenWidth;
    final effectiveHeight = height.isFinite ? height : screenWidth;
    final cacheWidth = math.max(1, (effectiveWidth * pixelRatio).round());
    final cacheHeight = math.max(1, (effectiveHeight * pixelRatio).round());
    final image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      filterQuality: FilterQuality.medium,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return const SizedBox.shrink();
      },
      loadingBuilder: (context, child, progress) => progress == null ? child : const SizedBox.shrink(),
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
