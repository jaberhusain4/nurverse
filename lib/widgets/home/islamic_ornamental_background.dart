import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Compact decorative Arabic-calligraphy-inspired ornament for the Home
/// background. It is abstract artwork only: no readable Arabic, Qur'an text,
/// or copied verse is drawn.
class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key});

  @override
  Widget build(BuildContext context) => const IgnorePointer(
        child: SizedBox.expand(
          child: RepaintBoundary(
            child: CustomPaint(painter: _CompactCalligraphyPainter()),
          ),
        ),
      );
}

class _CompactCalligraphyPainter extends CustomPainter {
  const _CompactCalligraphyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Keep the artwork small and concentrated above the prayer card, like the
    // supplied reference. The left side remains quiet for existing content.
    final s = math.min(size.width, 430) / 430;
    final center = Offset(size.width * .77, size.height * .135);
    final main = AppColors.softAqua.withValues(alpha: .13);
    final secondary = AppColors.seaBlue.withValues(alpha: .18);
    final highlight = AppColors.softAqua.withValues(alpha: .10);

    final brush = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Intertwined ribbon-like strokes: compact, curved and deliberately
    // non-readable so they feel like ornamental Arabic calligraphy rather
    // than text.
    brush
      ..color = secondary
      ..strokeWidth = 8 * s;
    _stroke(canvas, brush, [
      _p(center, -108, 12, s),
      _p(center, -58, -28, s),
      _p(center, -12, 7, s),
      _p(center, 36, -30, s),
      _p(center, 91, -2, s),
    ]);

    brush
      ..color = main
      ..strokeWidth = 5.5 * s;
    _stroke(canvas, brush, [
      _p(center, -100, 34, s),
      _p(center, -49, 4, s),
      _p(center, 2, 35, s),
      _p(center, 49, 6, s),
      _p(center, 103, 25, s),
    ]);

    // Long curved sweep under the compact motif.
    brush
      ..color = highlight
      ..strokeWidth = 4.5 * s;
    _stroke(canvas, brush, [
      _p(center, -94, 46, s),
      _p(center, -40, 72, s),
      _p(center, 18, 45, s),
      _p(center, 61, 66, s),
      _p(center, 112, 39, s),
    ]);

    // Short hooked stems give the ornament its Arabic-calligraphic rhythm.
    brush
      ..color = main
      ..strokeWidth = 4.2 * s;
    for (final d in <List<double>>[
      [-64, 26, -57, -22, -43, -43],
      [-20, 37, -11, -18, 2, -48],
      [28, 34, 37, -19, 51, -42],
      [69, 25, 77, -12, 89, -30],
    ]) {
      final path = Path()
        ..moveTo(center.dx + d[0] * s, center.dy + d[1] * s)
        ..cubicTo(
          center.dx + d[2] * s,
          center.dy + d[3] * s,
          center.dx + d[4] * s,
          center.dy + d[5] * s,
          center.dx + (d[4] + 10) * s,
          center.dy + (d[5] + 13) * s,
        );
      canvas.drawPath(path, brush);
    }

    // Small loops and dots, echoing the reference's dense decorative texture.
    brush
      ..color = secondary
      ..strokeWidth = 2.8 * s;
    for (final o in <Offset>[
      _p(center, -75, 1, s),
      _p(center, -34, 17, s),
      _p(center, 9, -2, s),
      _p(center, 50, 15, s),
      _p(center, 84, -1, s),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: o, width: 24 * s, height: 11 * s),
        brush,
      );
    }

    final dot = Paint()..color = main;
    for (final o in <Offset>[
      _p(center, -91, -18, s),
      _p(center, -83, -25, s),
      _p(center, -25, -29, s),
      _p(center, -16, -35, s),
      _p(center, 38, -25, s),
      _p(center, 48, -31, s),
      _p(center, 94, -17, s),
      _p(center, 101, -10, s),
      _p(center, -45, 45, s),
      _p(center, 62, 39, s),
    ]) {
      canvas.drawCircle(o, 1.7 * s, dot);
    }

    // Fine curls frame the small artwork without spreading across the screen.
    _curl(canvas, _p(center, -92, 20, s), 24 * s, -.7, highlight);
    _curl(canvas, _p(center, 91, 20, s), 27 * s, .35, main);
    _curl(canvas, _p(center, 76, -28, s), 20 * s, -.25, secondary);
    _curl(canvas, _p(center, -65, -30, s), 18 * s, .65, secondary);
  }

  Offset _p(Offset c, double x, double y, double s) =>
      Offset(c.dx + x * s, c.dy + y * s);

  void _stroke(Canvas canvas, Paint paint, List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length - 1; i += 2) {
      final control = points[i];
      final end = points[math.min(i + 1, points.length - 1)];
      path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    }
    canvas.drawPath(path, paint);
  }

  void _curl(
    Canvas canvas,
    Offset center,
    double radius,
    double rotation,
    Color color,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, radius * .09)
      ..strokeCap = StrokeCap.round
      ..color = color;
    final path = Path();
    for (var i = 0; i <= 28; i++) {
      final t = i / 28;
      final angle = rotation + t * math.pi * 1.65;
      final r = radius * (1 - t * .68);
      final p = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
