import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color? color;

  const SvgIcon({
   super.key,
   required this.asset,
   this.size = 24,
   this.color,
});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: color != null
        ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}