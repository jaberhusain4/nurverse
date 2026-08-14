import 'package:flutter/material.dart';

/// Clean Home background layer.
///
/// Kept as a dedicated widget so the HomeScreen layout remains stable.
/// No calligraphy, verse, pattern, image, or decorative artwork is painted.
class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: SizedBox.expand(),
    );
  }
}
