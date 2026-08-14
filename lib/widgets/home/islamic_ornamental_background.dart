import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Fully offline premium Islamic calligraphy background for Home.
/// The ornament is vector-drawn and intentionally subtle so it never competes
/// with readable Home content.
class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAmoled = context.isAmoled;
    final opacity = isAmoled ? 0.075 : isDark ? 0.082 : 0.040;

    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _QuranCalligraphyPainter(
            color: theme.colorScheme.primary,
            opacity: opacity,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _QuranCalligraphyPainter extends CustomPainter {
  const _QuranCalligraphyPainter({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  static const String _ayah = 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا';

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.79, size.height * 0.17);
    final radius = math.min(size.width, size.height) * 0.32;
    final fine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.82
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: opacity * 0.72);
    final main = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: opacity * 1.18);

    _drawFloralTexture(canvas, size, fine);
    _drawMedallion(canvas, center, radius, fine, main);
    _drawAyah(canvas, center, radius);
    _drawArabicFlourishes(canvas, center, radius, main, fine);
    _drawDots(canvas, center, radius, main);
    _drawCrescent(canvas, size);
  }

  void _drawAyah(Canvas canvas, Offset center, double radius) {
    final painter = TextPainter(
      text: TextSpan(
        text: _ayah,
        style: TextStyle(
          color: color.withValues(alpha: opacity * 1.25),
          fontSize: radius * 0.285,
          height: 1.28,
          fontWeight: FontWeight.w600,
          fontFamilyFallback: const ['Noto Naskh Arabic', 'Noto Sans Arabic'],
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      maxLines: 2,
    )..layout(maxWidth: radius * 1.72);

    painter.paint(canvas, Offset(
      center.dx - painter.width / 2,
      center.dy - painter.height / 2 - 1,
    ));
  }

  void _drawMedallion(
    Canvas canvas,
    Offset center,
    double radius,
    Paint fine,
    Paint main,
  ) {
    // Layered hand-drawn oval frame, closer to classical calligraphic artwork
    // than a modern geometric card pattern.
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radius * 2.05,
        height: radius * 1.35,
      ),
      fine,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radius * 1.82,
        height: radius * 1.17,
      ),
      main,
    );

    final upper = Path()
      ..moveTo(center.dx - radius * 0.94, center.dy - radius * 0.02)
      ..cubicTo(
        center.dx - radius * 0.62,
        center.dy - radius * 0.58,
        center.dx - radius * 0.15,
        center.dy - radius * 0.67,
        center.dx + radius * 0.14,
        center.dy - radius * 0.38,
      )
      ..cubicTo(
        center.dx + radius * 0.38,
        center.dy - radius * 0.14,
        center.dx + radius * 0.64,
        center.dy - radius * 0.30,
        center.dx + radius * 0.92,
        center.dy - radius * 0.50,
      );
    canvas.drawPath(upper, main);

    final lower = Path()
      ..moveTo(center.dx - radius * 0.95, center.dy + radius * 0.30)
      ..cubicTo(
        center.dx - radius * 0.61,
        center.dy + radius * 0.08,
        center.dx - radius * 0.28,
        center.dy + radius * 0.63,
        center.dx + radius * 0.06,
        center.dy + radius * 0.34,
      )
      ..cubicTo(
        center.dx + radius * 0.38,
        center.dy + radius * 0.06,
        center.dx + radius * 0.67,
        center.dy + radius * 0.48,
        center.dx + radius * 0.96,
        center.dy + radius * 0.14,
      );
    canvas.drawPath(lower, fine);

    for (var i = 0; i < 12; i++) {
      final angle = -math.pi * 0.95 + i * math.pi * 0.17;
      final p = center + Offset(
        math.cos(angle) * radius * 0.94,
        math.sin(angle) * radius * 0.67,
      );
      _leaf(canvas, p, angle + math.pi / 2, radius * 0.065, fine.color);
    }
  }

  void _drawArabicFlourishes(
    Canvas canvas,
    Offset center,
    double radius,
    Paint main,
    Paint fine,
  ) {
    for (var i = 0; i < 5; i++) {
      final y = center.dy - radius * 0.66 + i * radius * 0.32;
      final path = Path()
        ..moveTo(center.dx - radius * (1.12 - i * 0.035), y)
        ..cubicTo(
          center.dx - radius * 0.72,
          y - radius * 0.16,
          center.dx - radius * 0.48,
          y + radius * 0.17,
          center.dx - radius * 0.18,
          y,
        )
        ..cubicTo(
          center.dx + radius * 0.12,
          y - radius * 0.17,
          center.dx + radius * 0.47,
          y + radius * 0.14,
          center.dx + radius * (1.08 - i * 0.035),
          y - radius * 0.04,
        );
      canvas.drawPath(path, i == 2 ? main : fine);
    }

    for (var i = 0; i < 6; i++) {
      final x = center.dx - radius * 0.78 + i * radius * 0.31;
      final stem = Path()
        ..moveTo(x, center.dy - radius * 0.72)
        ..cubicTo(
          x - radius * 0.13,
          center.dy - radius * 0.45,
          x + radius * 0.12,
          center.dy - radius * 0.15,
          x - radius * 0.02,
          center.dy + radius * 0.58,
        );
      canvas.drawPath(stem, i == 3 ? main : fine);
      _leaf(canvas, Offset(x, center.dy - radius * 0.48), -0.55, radius * 0.07, fine.color);
    }
  }

  void _drawFloralTexture(Canvas canvas, Size size, Paint fine) {
    // Dense but low-contrast floral texture in the upper-right, inspired by
    // illuminated manuscripts and arabesque artwork.
    for (var i = 0; i < 18; i++) {
      final x = size.width * (0.50 + (i % 9) * 0.058);
      final y = size.height * (0.015 + (i ~/ 9) * 0.15);
      final r = size.width * (0.018 + (i % 3) * 0.006);
      final petal = Path()
        ..moveTo(x, y - r)
        ..cubicTo(x + r * 1.7, y - r * 0.25, x + r * 1.35, y + r * 0.95, x, y + r)
        ..cubicTo(x - r * 1.35, y + r * 0.95, x - r * 1.7, y - r * 0.25, x, y - r);
      canvas.drawPath(petal, fine);
      canvas.drawCircle(Offset(x, y), r * 0.22, fine);
    }
  }

  void _drawDots(Canvas canvas, Offset center, double radius, Paint paint) {
    final dot = Paint()..color = paint.color;
    for (var i = 0; i < 24; i++) {
      final angle = -math.pi * 0.92 + i * math.pi * 1.55 / 23;
      final r = radius * (0.70 + (i.isEven ? 0.09 : 0));
      canvas.drawCircle(
        center + Offset(math.cos(angle) * r, math.sin(angle) * r),
        i % 4 == 0 ? 1.9 : 1.0,
        dot,
      );
    }
  }

  void _drawCrescent(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.90, size.height * 0.37);
    final radius = math.min(size.width, size.height) * 0.044;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: opacity * 1.2);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.82,
      math.pi * 1.62,
      false,
      paint,
    );
  }

  void _leaf(Canvas canvas, Offset center, double angle, double radius, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round
      ..color = color;
    final axis = Offset(math.cos(angle), math.sin(angle));
    final normal = Offset(-axis.dy, axis.dx);
    final a = center + axis * radius;
    final b = center - axis * radius;
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(
        center.dx + normal.dx * radius * 0.7,
        center.dy + normal.dy * radius * 0.7,
        b.dx,
        b.dy,
      )
      ..quadraticBezierTo(
        center.dx - normal.dx * radius * 0.7,
        center.dy - normal.dy * radius * 0.7,
        a.dx,
        a.dy,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _QuranCalligraphyPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
