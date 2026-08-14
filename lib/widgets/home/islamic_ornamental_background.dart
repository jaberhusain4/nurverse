import 'package:flutter/material.dart';

/// Temporary clean background layer.
///
/// Kept as a dedicated widget so the HomeScreen layout and future visual
/// system remain stable. It intentionally paints nothing until the new
/// abstract Islamic ornament is designed from scratch.
class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: SizedBox.expand(),
    );
  }
}
