import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final sourceFile = File('assets/images/StayZ new.png');
  final source = img.decodePng(sourceFile.readAsBytesSync());
  if (source == null) {
    throw StateError('Cannot decode ${sourceFile.path}');
  }

  const canvasSize = 2000;
  const markSize = 900;
  final canvas = img.Image(width: canvasSize, height: canvasSize);
  img.fill(canvas, color: img.ColorRgb8(4, 108, 184));
  final mark = img.copyResize(
    source,
    width: markSize,
    height: markSize,
    interpolation: img.Interpolation.cubic,
  );
  img.compositeImage(
    canvas,
    mark,
    dstX: (canvasSize - markSize) ~/ 2,
    dstY: (canvasSize - markSize) ~/ 2,
  );

  File('assets/images/StayZ splash.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(img.encodePng(canvas));
}
