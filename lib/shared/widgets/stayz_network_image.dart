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

  /// Mo ta anh cho trinh doc man hinh. Truoc day moi anh khach san deu vo hinh
  /// voi nguoi dung dung screen reader.
  final String? semanticLabel;

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
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null || semanticLabel!.isEmpty,
      // Giu nguyen kich thuoc trong khi tai, thay vi co ve 0 lam layout nhay.
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return _Placeholder(width: width, height: height, child: const _Shimmer());
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _Placeholder(width: width, height: height, child: const _Shimmer());
      },
      // Anh hong phai nhin ra duoc la anh hong, khong the bien mat im lang.
      errorBuilder: (context, error, stackTrace) => Semantics(
        label: semanticLabel == null
            ? null
            : '${semanticLabel!}. ${context.l10n.text('Không tải được ảnh', 'Image unavailable')}',
        image: true,
        child: ExcludeSemantics(
          child: _Placeholder(
            width: width,
            height: height,
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined, color: AppTheme.muted, size: 26),
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
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ton trong cai dat giam chuyen dong cua he dieu hanh.
    if (MediaQuery.disableAnimationsOf(context)) {
      return const SizedBox.expand();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final value = _controller.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + value * 2, 0),
              end: Alignment(1 + value * 2, 0),
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.45),
                Colors.transparent,
              ],
            ),
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}
