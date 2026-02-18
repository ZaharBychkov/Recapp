import 'dart:io';

import 'package:flutter/material.dart';

class RecipeImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;

  const RecipeImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  bool get _isAsset => imagePath.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    if (imagePath.trim().isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.transparent,
      );
    }

    if (_isAsset) {
      return Image.asset(
        imagePath,
        fit: fit,
        width: width,
        height: height,
      );
    }

    return Image.file(
      File(imagePath),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) {
        return Image.asset(
          'assets/Images/burger_with_two_cutlets.png',
          fit: fit,
          width: width,
          height: height,
        );
      },
    );
  }
}
