import 'package:flutter/material.dart';

/// Background ornament layer for the Home screen.
///
/// Kept intentionally empty while the new compact calligraphy treatment is
/// prepared. It must never interfere with Home content or interactions.
class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key});

  @override
  Widget build(BuildContext context) => const IgnorePointer(
        child: SizedBox.expand(),
      );
}
