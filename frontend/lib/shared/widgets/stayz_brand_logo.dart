import 'package:flutter/material.dart';

const stayzBrandAsset = 'assets/images/StayZ new.png';

class StayZBrandLogo extends StatelessWidget {
  const StayZBrandLogo({
    this.size = 48,
    this.borderRadius = 14,
    this.alignment = Alignment.center,
    super.key,
  });

  final double size;
  final double borderRadius;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      widthFactor: 1,
      heightFactor: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          stayzBrandAsset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          semanticLabel: 'StayZ',
        ),
      ),
    );
  }
}
