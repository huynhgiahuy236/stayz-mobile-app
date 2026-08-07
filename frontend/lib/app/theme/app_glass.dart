import 'dart:ui';

class AppGlass {
  const AppGlass._();

  static const double blurX = 16.0;
  static const double blurY = 16.0;
  static const double opacity = 0.08;

  static ImageFilter get filter => ImageFilter.blur(sigmaX: blurX, sigmaY: blurY);
}
