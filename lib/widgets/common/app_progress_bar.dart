import 'package:flutter/material.dart';

class AppProgressBar extends StatelessWidget {
  final double value;
  final double height;

  const AppProgressBar({super.key, required this.value, this.height = 8});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor:
            isDark
                ? Colors.white.withValues(alpha: .12)
                : const Color(0xFFEAF6FC),
        valueColor: const AlwaysStoppedAnimation(Color(0xFF0288D1)),
      ),
    );
  }
}
