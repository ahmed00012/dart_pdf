import 'dart:async';
import 'dart:typed_data';

import 'package:image/image.dart' as im;

import 'color.dart';

/// Represents a bitmap image
class PdfRasterBase {
  /// Create a bitmap image
  const PdfRasterBase(
      this.width,
      this.height,
      this.alpha,
      this.pixels,
      );

  factory PdfRasterBase.fromImage(im.Image image) {
    // image: 3.0.2 does not have `convert()`, use getBytes() instead
    final data = Uint8List.fromList(image.getBytes(format: im.Format.rgba));
    return PdfRasterBase(image.width, image.height, true, data);
  }

  factory PdfRasterBase.fromPng(Uint8List png) {
    final img = im.decodePng(png)!; // image 3.0.2 uses decodePng instead of PngDecoder
    return PdfRasterBase.fromImage(img);
  }

  static im.Image shadowRect(
      double width,
      double height,
      double spreadRadius,
      double blurRadius,
      PdfColor color,
      ) {
    final shadow = im.Image(
      (width + spreadRadius * 2).round(),
      (height + spreadRadius * 2).round(),
    );

    im.fillRect(
      shadow,
      spreadRadius.round(),
      spreadRadius.round(),
      (spreadRadius + width).round(),
      (spreadRadius + height).round(),
      im.getColor(
        (color.red * 255).toInt(),
        (color.green * 255).toInt(),
        (color.blue * 255).toInt(),
        (color.alpha * 255).toInt(),
      ),
    );

    return im.gaussianBlur(shadow, blurRadius.round());
  }

  static im.Image shadowEllipse(
      double width,
      double height,
      double spreadRadius,
      double blurRadius,
      PdfColor color,
      ) {
    final shadow = im.Image(
      (width + spreadRadius * 2).round(),
      (height + spreadRadius * 2).round(),
    );

    im.fillCircle(
      shadow,
      (spreadRadius + width / 2).round(),
      (spreadRadius + height / 2).round(),
      (width / 2).round(),
      im.getColor(
        (color.red * 255).toInt(),
        (color.green * 255).toInt(),
        (color.blue * 255).toInt(),
        (color.alpha * 255).toInt(),
      ),
    );

    return im.gaussianBlur(shadow, blurRadius.round());
  }

  /// The width of the image
  final int width;

  /// The height of the image
  final int height;

  /// The alpha channel is used
  final bool alpha;

  /// The raw RGBA pixels of the image
  final Uint8List pixels;

  @override
  String toString() => 'Image ${width}x$height ${width * height * 4} bytes';

  /// Convert to a PNG image
  Future<Uint8List> toPng() async {
    final img = asImage();
    return Uint8List.fromList(im.encodePng(img)); // image 3.0.2 uses encodePng directly
  }

  /// Returns the image as an [Image] object from the pub:image library
  im.Image asImage() {
    return im.Image.fromBytes(width, height, pixels);
  }
}
