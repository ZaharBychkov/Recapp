import 'package:flutter/material.dart';

class PngIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color? color;

  const PngIcon({
    super.key,
    required this.asset,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
    );
  }
}