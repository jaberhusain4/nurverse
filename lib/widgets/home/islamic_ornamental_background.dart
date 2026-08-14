import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Premium offline Islamic calligraphic ornament.
///
/// This is intentionally abstract: there is no readable Qur'an verse or
/// Arabic sentence. The flowing strokes are inspired by traditional Arabic
/// calligraphy and illuminated Islamic artwork.
class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = context.isAmoled
        ? 0.16
        : theme.brightness == Brightness.dark
            ? 0.135
            : 0.06;

    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _AbstractArabicCalligraphyPainter(
            color: theme.colorScheme.primary,
            opacity: opacity,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _AbstractArabicCalligraphyPainter extends CustomPainter {
  const _AbstractArabicCalligraphyPainter({
    required this.color,
    required this.opacity,
  });

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * .76, size.height * .19);
    final s = math.min(size.width, size.height) / 430.0;

    final glowRect = Rect.fromLTWH(0, 0, size.width, size.height * .62);
    final shader = RadialGradient(
      center: const Alignment(.48, -.34),
      radius: 1.05,
      colors: [
        color.withValues(alpha: opacity * .75),
        color.withValues(alpha: opacity * .18),
        Colors.transparent,
      ],
      stops: const [0, .56, 1],
    ).createShader(glowRect);
    canvas.drawRect(glowRect, Paint()..shader = shader);

    _drawFlourishingLetterforms(canvas, c, s);
    _drawArabesqueFrame(canvas, c, s);
    _drawFineTexture(canvas, c, s);
    _drawCrescent(canvas, size, s);
  }

  void _drawFlourishingLetterforms(Canvas canvas, Offset c, double s) {
    final bold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 8.5 * s
      ..color = color.withValues(alpha: opacity * 1.55);

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.2 * s
      ..color = color.withValues(alpha: opacity * 1.05);

    final paths = <Path>[
      Path()
        ..moveTo(c.dx - 185 * s, c.dy + 18 * s)
        ..cubicTo(c.dx - 116 * s, c.dy - 78 * s, c.dx - 30 * s, c.dy - 92 * s, c.dx + 48 * s, c.dy - 28 * s)
        ..cubicTo(c.dx + 112 * s, c.dy + 24 * s, c.dx + 155 * s, c.dy + 14 * s, c.dx + 194 * s, c.dy - 42 * s),
      Path()
        ..moveTo(c.dx - 158 * s, c.dy + 62 * s)
        ..cubicTo(c.dx - 84 * s, c.dy + 112 * s, c.dx - 12 * s, c.dy + 110 * s, c.dx + 52 * s, c.dy + 50 * s)
        ..cubicTo(c.dx + 94 * s, c.dy + 10 * s, c.dx + 137 * s, c.dy + 18 * s, c.dx + 181 * s, c.dy + 58 * s),
      Path()
        ..moveTo(c.dx - 126 * s, c.dy - 104 * s)
        ..cubicTo(c.dx - 58 * s, c.dy - 150 * s, c.dx + 10 * s, c.dy - 128 * s, c.dx + 50 * s, c.dy - 78 * s)
        ..cubicTo(c.dx + 82 * s, c.dy - 36 * s, c.dx + 122 * s, c.dy - 46 * s, c.dx + 166 * s, c.dy - 96 * s),
      Path()
        ..moveTo(c.dx - 184 * s, c.dy + 112 * s)
        ..cubicTo(c.dx - 96 * s, c.dy + 76 * s, c.dx - 28 * s, c.dy + 138 * s, c.dx + 34 * s, c.dy + 112 * s)
        ..cubicTo(c.dx + 98 * s, c.dy + 84 * s, c.dx + 136 * s, c.dy + 126 * s, c.dx + 192 * s, c.dy + 88 * s),
    ];

    for (final path in paths) {
      canvas.drawPath(path, bold);
      canvas.drawPath(path, edge);
    }

    // Tall stems, hooks and descending tails give the composition its
    // calligraphic character without forming readable words.
    for (var i = 0; i < 8; i++) {
      final x = c.dx + (-150 + i * 43) * s;
      final path = Path()
        ..moveTo(x, c.dy - (142 - (i.isOdd ? 18 : 0)) * s)
        ..cubicTo(x - 12 * s, c.dy - 58 * s, x + 18 * s, c.dy - 4 * s, x - 3 * s, c.dy + 78 * s)
        ..cubicTo(x - 12 * s, c.dy + 102 * s, x + 18 * s, c.dy + 110 * s, x + 34 * s, c.dy + 90 * s);
      canvas.drawPath(path, edge);
    }

    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5 * s
      ..color = color.withValues(alpha: opacity * 1.18);
    final tail = Path()
      ..moveTo(c.dx - 205 * s, c.dy + 146 * s)
      ..cubicTo(c.dx - 120 * s, c.dy + 104 * s, c.dx - 34 * s, c.dy + 172 * s, c.dx + 52 * s, c.dy + 132 * s)
      ..cubicTo(c.dx + 122 * s, c.dy + 100 * s, c.dx + 174 * s, c.dy + 132 * s, c.dx + 214 * s, c.dy + 88 * s);
    canvas.drawPath(tail, sweep);
  }

  void _drawArabesqueFrame(Canvas canvas, Offset c, double s) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.05 * s
      ..color = color.withValues(alpha: opacity * .68);

    for (var ring = 0; ring < 3; ring++) {
      final rect = Rect.fromCenter(
        center: Offset(c.dx + 8 * s, c.dy + 2 * s),
        width: (420 - ring * 30) * s,
        height: (286 - ring * 22) * s,
      );
      canvas.drawOval(rect, paint);
    }

    for (var i = 0; i < 26; i++) {
      final a = -1.5 + i * .12;
      final r = (155 + (i % 4) * 16) * s;
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r * .68);
      _leaf(canvas, p, a + 1.0, 13 * s, paint);
    }
  }

  void _drawFineTexture(Canvas canvas, Offset c, double s) {
    final fine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = .85 * s
      ..color = color.withValues(alpha: opacity * .56);

    for (var i = 0; i < 18; i++) {
      final a = -1.35 + i * .15;
      final p = c + Offset(math.cos(a) * 178 * s, math.sin(a) * 120 * s);
      final path = Path()
        ..moveTo(p.dx, p.dy)
        ..cubicTo(
          p.dx + math.cos(a + .8) * 28 * s,
          p.dy + math.sin(a + .8) * 28 * s,
          p.dx + math.cos(a + 1.4) * 46 * s,
          p.dy + math.sin(a + 1.4) * 46 * s,
          p.dx + math.cos(a + 1.9) * 58 * s,
          p.dy + math.sin(a + 1.9) * 58 * s,
        );
      canvas.drawPath(path, fine);
    }

    final dots = Paint()..color = color.withValues(alpha: opacity * .82);
    for (var i = 0; i < 64; i++) {
      final a = -1.52 + i * .115;
      final r = (115 + (i % 5) * 19) * s;
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r * .66);
      canvas.drawCircle(p, (i % 8 == 0 ? 1.7 : .7) * s, dots);
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

  void _drawCrescent(Canvas canvas, Size size, double s) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * s
      ..color = color.withValues(alpha: opacity * .95);
    final center = Offset(size.width * .43, size.height * .13);
    canvas.drawArc(Rect.fromCenter(center: center, width: 48 * s, height: 48 * s), .65, 4.35, false, paint);
  }

  @override
  bool shouldRepaint(covariant _AbstractArabicCalligraphyPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
