import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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
    final rect = Offset.zero & size;
    final scale = 1.05;
    final scaledWidth = image.width.toDouble() * scale;
    final scaleHeight = image.height.toDouble() * scale;

    // 1. Создаём слой
    canvas.saveLayer(rect, Paint());

    // 2. Рисуем ТЕКСТ как маску (НЕ прозрачный!)
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontWeight: fontWeight,
          color: Colors.white, // ВАЖНО: белый
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: size.width);

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);

    // 3. Рисуем изображение ВНУТРИ текста
    final imagePaint = Paint()
      ..blendMode = BlendMode.srcIn
      ..filterQuality = FilterQuality.high;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, scaledWidth, scaleHeight),
      rect,
      imagePaint,
    );

    // 4. Восстанавливаем слой
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