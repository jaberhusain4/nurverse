import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A fully offline, extremely subtle Islamic calligraphy background for Home.
///
/// The previous geometric/abstract ornament is intentionally removed. The
/// background now uses a short Quranic verse as a restrained calligraphic
/// centerpiece, with non-text decorative flourishes around it.
class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAmoled = context.isAmoled;
    final opacity = isAmoled ? 0.060 : isDark ? 0.068 : 0.032;

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
  const _QuranCalligraphyPainter({
    required this.color,
    required this.opacity,
  });

  final Color color;
  final double opacity;

  static const String _ayah = 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا';

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.76, size.height * 0.16);
    final radius = math.min(size.width, size.height) * 0.285;

    final fine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: opacity * 0.72);

    final main = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: opacity * 1.18);

    _drawCalligraphyFrame(canvas, center, radius, fine, main);
    _drawAyah(canvas, center, radius);
    _drawFlourishes(canvas, size, fine, main);
    _drawCrescent(canvas, size, main);
  }

  void _drawAyah(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: _ayah,
        style: TextStyle(
          fontSize: radius * 0.30,
          height: 1.35,
          fontWeight: FontWeight.w500,
          color: color.withValues(alpha: opacity * 1.15),
          fontFamilyFallback: const ['Noto Naskh Arabic', 'Noto Sans Arabic'],
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      maxLines: 2,
    )..layout(maxWidth: radius * 1.65);

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawCalligraphyFrame(
    Canvas canvas,
    Offset center,
    double radius,
    Paint fine,
    Paint main,
  ) {
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        center,
        radius * (0.82 + i * 0.085),
        i == 1 ? main : fine,
      );
    }

    final upper = Path()
      ..moveTo(center.dx - radius * 0.90, center.dy - radius * 0.10)
      ..cubicTo(
        center.dx - radius * 0.58,
        center.dy - radius * 0.58,
        center.dx - radius * 0.14,
        center.dy - radius * 0.62,
        center.dx + radius * 0.18,
        center.dy - radius * 0.36,
      )
      ..cubicTo(
        center.dx + radius * 0.42,
        center.dy - radius * 0.16,
        center.dx + radius * 0.62,
        center.dy - radius * 0.24,
        center.dx + radius * 0.88,
        center.dy - radius * 0.42,
      );
    canvas.drawPath(upper, main);

    final lower = Path()
      ..moveTo(center.dx - radius * 0.86, center.dy + radius * 0.34)
      ..cubicTo(
        center.dx - radius * 0.52,
        center.dy + radius * 0.16,
        center.dx - radius * 0.16,
        center.dy + radius * 0.62,
        center.dx + radius * 0.18,
        center.dy + radius * 0.40,
      )
      ..cubicTo(
        center.dx + radius * 0.46,
        center.dy + radius * 0.22,
        center.dx + radius * 0.68,
        center.dy + radius * 0.48,
        center.dx + radius * 0.92,
        center.dy + radius * 0.22,
      );
    canvas.drawPath(lower, fine);

    for (var i = 0; i < 9; i++) {
      final angle = -math.pi * 0.92 + i * math.pi * 0.23;
      final r = radius * 0.93;
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      canvas.drawCircle(point, i.isEven ? 1.8 : 1.1, fine);
    }
  }

  void _drawFlourishes(
    Canvas canvas,
    Size size,
    Paint fine,
    Paint main,
  ) {
    final top = Path()
      ..moveTo(size.width * 0.48, size.height * 0.045)
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.005,
        size.width * 0.67,
        size.height * 0.10,
        size.width * 0.76,
        size.height * 0.045,
      )
      ..cubicTo(
        size.width * 0.85,
        size.height * 0.00,
        size.width * 0.94,
        size.height * 0.08,
        size.width,
        size.height * 0.045,
      );
    canvas.drawPath(top, fine);

    final side = Path()
      ..moveTo(size.width * 0.66, size.height * 0.30)
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.24,
        size.width * 0.83,
        size.height * 0.34,
        size.width * 0.96,
        size.height * 0.27,
      )
      ..cubicTo(
        size.width * 0.98,
        size.height * 0.25,
        size.width,
        size.height * 0.28,
        size.width,
        size.height * 0.31,
      );
    canvas.drawPath(side, main);

    for (var i = 0; i < 4; i++) {
      final x = size.width * (0.63 + i * 0.085);
      final stem = Path()
        ..moveTo(x, size.height * 0.035)
        ..cubicTo(
          x - size.width * 0.018,
          size.height * 0.09,
          x + size.width * 0.018,
          size.height * 0.15,
          x - size.width * 0.006,
          size.height * 0.20,
        );
      canvas.drawPath(stem, fine);
    }
  }

  void _drawCrescent(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width * 0.91, size.height * 0.37);
    final radius = math.min(size.width, size.height) * 0.043;
    final crescent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: opacity * 1.15);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.82,
      math.pi * 1.62,
      false,
      crescent,
    );

    final star = Paint()
      ..style = PaintingStyle.fill
      ..color = paint.color;
    final starCenter = center.translate(radius * 1.32, -radius * 0.52);
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? radius * 0.22 : radius * 0.09;
      final point = starCenter + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, star);
  }

  @override
  bool shouldRepaint(covariant _QuranCalligraphyPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
