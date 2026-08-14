import 'package:flutter/material.dart';

/// Reusable screen background wrapper.
///
/// The decorative Islamic ornament is intentionally removed for now so the
/// next background design can be rebuilt cleanly without layering the old
/// artwork underneath it.
class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
