import 'dart:math' as math;

import 'package:flutter/material.dart';

class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _IslamicCalligraphyPainter(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IslamicCalligraphyPainter extends CustomPainter {
  const _IslamicCalligraphyPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.055)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.15;

    final center = Offset(size.width * 0.82, size.height * 0.18);
    final radius = math.min(size.width, size.height) * 0.34;

    _drawCalligraphicMedallion(canvas, center, radius, paint);
    _drawFlowingStrokes(canvas, size, paint);
    _drawDots(canvas, center, radius);
  }

  void _drawCalligraphicMedallion(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(center, radius * (1 - i * 0.105), paint);
    }

    final path = Path();
    for (var i = 0; i <= 160; i++) {
      final t = i / 160 * math.pi * 2;
      final r = radius * (0.58 + 0.075 * math.sin(5 * t));
      final p = Offset(
        center.dx + r * math.cos(t),
        center.dy + r * math.sin(t),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawFlowingStrokes(Canvas canvas, Size size, Paint paint) {
    final paths = [
      Path()
        ..moveTo(size.width * 0.43, size.height * 0.07)
        ..cubicTo(size.width * 0.56, size.height * 0.015,
            size.width * 0.68, size.height * 0.10, size.width * 0.82, size.height * 0.055)
        ..cubicTo(size.width * 0.91, size.height * 0.025,
            size.width * 0.96, size.height * 0.10, size.width, size.height * 0.075),
      Path()
        ..moveTo(size.width * 0.55, size.height * 0.22)
        ..cubicTo(size.width * 0.64, size.height * 0.16,
            size.width * 0.72, size.height * 0.27, size.width * 0.84, size.height * 0.19)
        ..cubicTo(size.width * 0.91, size.height * 0.145,
            size.width * 0.96, size.height * 0.24, size.width, size.height * 0.21),
      Path()
        ..moveTo(size.width * 0.62, size.height * 0.30)
        ..cubicTo(size.width * 0.71, size.height * 0.24,
            size.width * 0.78, size.height * 0.35, size.width * 0.90, size.height * 0.29),
    ];

    for (final path in paths) {
      canvas.drawPath(path, paint);
    }

    for (var i = 0; i < 4; i++) {
      final x = size.width * (0.66 + i * 0.075);
      final path = Path()
        ..moveTo(x, size.height * 0.035)
        ..cubicTo(x - size.width * 0.025, size.height * 0.10,
            x + size.width * 0.025, size.height * 0.15, x - size.width * 0.008, size.height * 0.205);
      canvas.drawPath(path, paint);
    }
  }

  void _drawDots(Canvas canvas, Offset center, double radius) {
    final dotPaint = Paint()
      ..color = color.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 13; i++) {
      final t = i / 12 * math.pi * 1.65 + 0.35;
      final r = radius * (0.66 + (i.isEven ? 0.035 : 0));
      canvas.drawCircle(
        Offset(center.dx + r * math.cos(t), center.dy + r * math.sin(t)),
        i % 3 == 0 ? 2.0 : 1.25,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicCalligraphyPainter oldDelegate) =>
      oldDelegate.color != color;
}
