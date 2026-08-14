import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Reusable, subtle Islamic calligraphy-inspired overlay for app screens.
/// It contains no readable Qur'an/Arabic text; all marks are abstract ornament.
class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = theme.brightness == Brightness.dark ? 0.055 : 0.028;

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _AbstractArabicOverlayPainter(
                color: theme.colorScheme.primary,
                opacity: opacity,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AbstractArabicOverlayPainter extends CustomPainter {
  const _AbstractArabicOverlayPainter({
    required this.color,
    required this.opacity,
  });

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * .78, size.height * .18);
    final s = math.min(size.width, size.height) / 430.0;

    final fine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.2 * s
      ..color = color.withValues(alpha: opacity);

    final bold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 4.2 * s
      ..color = color.withValues(alpha: opacity * 1.18);

    for (var i = 0; i < 5; i++) {
      final y = c.dy - 125 * s + i * 58 * s;
      final path = Path()
        ..moveTo(c.dx - 205 * s, y)
        ..cubicTo(c.dx - 125 * s, y - 38 * s, c.dx - 58 * s, y + 38 * s, c.dx + 8 * s, y)
        ..cubicTo(c.dx + 74 * s, y - 38 * s, c.dx + 132 * s, y + 34 * s, c.dx + 205 * s, y - 6 * s);
      canvas.drawPath(path, i == 2 ? bold : fine);
    }

    for (var i = 0; i < 7; i++) {
      final x = c.dx - 150 * s + i * 50 * s;
      final path = Path()
        ..moveTo(x, c.dy - 142 * s)
        ..cubicTo(x - 15 * s, c.dy - 58 * s, x + 16 * s, c.dy - 10 * s, x - 2 * s, c.dy + 88 * s)
        ..cubicTo(x - 10 * s, c.dy + 108 * s, x + 20 * s, c.dy + 116 * s, x + 36 * s, c.dy + 92 * s);
      canvas.drawPath(path, fine);
    }

    for (var i = 0; i < 18; i++) {
      final a = -1.5 + i * .145;
      final r = (155 + (i % 4) * 16) * s;
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r * .66);
      _leaf(canvas, p, a + 1.0, 12 * s, fine);
    }

    for (var i = 0; i < 48; i++) {
      final a = -1.52 + i * .12;
      final r = (118 + (i % 5) * 18) * s;
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r * .65);
      canvas.drawCircle(p, (i % 8 == 0 ? 1.5 : .65) * s, Paint()..color = color.withValues(alpha: opacity * .9));
    }
  }

  void _leaf(Canvas canvas, Offset c, double angle, double length, Paint paint) {
    final tip = c + Offset(math.cos(angle) * length, math.sin(angle) * length);
    final side = length * .42;
    final a = c + Offset(math.cos(angle + math.pi / 2) * side, math.sin(angle + math.pi / 2) * side);
    final b = c + Offset(math.cos(angle - math.pi / 2) * side, math.sin(angle - math.pi / 2) * side);
    final path = Path()
      ..moveTo(c.dx, c.dy)
      ..quadraticBezierTo(a.dx, a.dy, tip.dx, tip.dy)
      ..quadraticBezierTo(b.dx, b.dy, c.dx, c.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AbstractArabicOverlayPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
