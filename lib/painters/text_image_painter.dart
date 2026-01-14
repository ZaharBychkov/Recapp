import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..filterQuality = FilterQuality.high;
    canvas.drawImage(image, Offset.zero, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TextImagePainter extends CustomPainter {
  final String text;
  final double fontSize;
  final String fontFamily;
  final FontWeight fontWeight;
  final ui.Image image;

  TextImagePainter({
    required this.text,
    required this.fontSize,
    required this.fontFamily,
    required this.fontWeight,
    required this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontWeight: fontWeight,
          color: Colors.black,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);

    final offset = Offset(
      (size.width - textPainter.size.width) / 2,
      (size.height - textPainter.size.height) / 2,
    );

    final pictureRecorder = ui.PictureRecorder();
    final pathCanvas = Canvas(pictureRecorder);
    textPainter.paint(pathCanvas, offset);

    final picture = pictureRecorder.endRecording();
    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height)); // или другой способ получения path

    canvas.save();
    canvas.clipPath(path);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TextImagePainter oldDelegate) {
    return text != oldDelegate.text ||
        fontSize != oldDelegate.fontSize ||
        fontFamily != oldDelegate.fontFamily ||
        fontWeight != oldDelegate.fontWeight ||
        image != oldDelegate.image;
  }
}