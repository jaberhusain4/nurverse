import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double size;

  const BrandLogo({super.key, this.size = 52});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final iconSize = size * (28 / 52);
    final radius = size * (16 / 52);

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Center(
          child: Icon(
            Icons.mosque_rounded,
            color: primary,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
