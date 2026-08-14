import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A lightweight, fully offline Islamic ornamental background for Home.
///
/// It is intentionally low-contrast so it adds premium visual identity
/// without competing with readable content or cards.
class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAmoled = context.isAmoled;

    final opacity = isAmoled
        ? 0.055
        : isDark
            ? 0.065
            : 0.035;

    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _IslamicOrnamentalPainter(
            color: theme.colorScheme.primary,
            opacity: opacity,
            dark: isDark,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _IslamicOrnamentalPainter extends CustomPainter {
  const _IslamicOrnamentalPainter({
    required this.color,
    required this.opacity,
    required this.dark,
  });

  final Color color;
  final double opacity;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final base = color.withValues(alpha: opacity);
    final stronger = color.withValues(alpha: opacity * 1.35);
    final soft = color.withValues(alpha: opacity * 0.7);

    _paintMandala(canvas, size, stronger, soft);
    _paintLantern(canvas, size, stronger);
    _paintCrescent(canvas, size, stronger);
    _paintPalm(canvas, size, soft);
    _paintCornerGeometry(canvas, size, base);
  }

  void _paintMandala(Canvas canvas, Size size, Color line, Color soft) {
    final center = Offset(size.width * 0.88, size.height * 0.15);
    final radius = math.min(size.width, size.height) * 0.31;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..color = line;

    final softStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = soft;

    for (var ring = 1; ring <= 4; ring++) {
      canvas.drawCircle(center, radius * ring / 4, ring.isEven ? stroke : softStroke);
    }

    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final path = Path();
      final inner = radius * 0.18;
      final outer = radius * 0.98;
      final p1 = center + Offset(math.cos(angle) * inner, math.sin(angle) * inner);
      final p2 = center + Offset(math.cos(angle + math.pi / 12) * outer, math.sin(angle + math.pi / 12) * outer);
      final p3 = center + Offset(math.cos(angle - math.pi / 12) * outer, math.sin(angle - math.pi / 12) * outer);
      path.moveTo(p1.dx, p1.dy);
      path.quadraticBezierTo(center.dx, center.dy, p2.dx, p2.dy);
      path.quadraticBezierTo(center.dx, center.dy, p3.dx, p3.dy);
      canvas.drawPath(path, softStroke);
    }

    final innerRadius = radius * 0.48;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final petal = Path();
      final a = center + Offset(math.cos(angle) * innerRadius, math.sin(angle) * innerRadius);
      final b = center + Offset(math.cos(angle + math.pi / 8) * innerRadius * 0.56, math.sin(angle + math.pi / 8) * innerRadius * 0.56);
      final c = center + Offset(math.cos(angle + math.pi / 4) * innerRadius, math.sin(angle + math.pi / 4) * innerRadius);
      petal.moveTo(a.dx, a.dy);
      petal.quadraticBezierTo(b.dx, b.dy, c.dx, c.dy);
      canvas.drawPath(petal, stroke);
    }
  }

  void _paintLantern(Canvas canvas, Size size, Color line) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..color = line;

    void lantern({required Offset top, required double scale}) {
      final ropeTop = top.translate(0, -size.height * 0.09 * scale);
      canvas.drawLine(ropeTop, top, paint);

      final neck = Rect.fromCenter(center: top.translate(0, size.height * 0.018 * scale), width: 14 * scale, height: 7 * scale);
      canvas.drawRect(neck, paint);

      final body = Path()
        ..moveTo(top.dx - 11 * scale, top.dy + 6 * scale)
        ..lineTo(top.dx - 17 * scale, top.dy + 18 * scale)
        ..lineTo(top.dx - 13 * scale, top.dy + 49 * scale)
        ..lineTo(top.dx, top.dy + 60 * scale)
        ..lineTo(top.dx + 13 * scale, top.dy + 49 * scale)
        ..lineTo(top.dx + 17 * scale, top.dy + 18 * scale)
        ..close();
      canvas.drawPath(body, paint);

      canvas.drawLine(top.translate(-9 * scale, 18 * scale), top.translate(-9 * scale, 47 * scale), paint);
      canvas.drawLine(top.translate(9 * scale, 18 * scale), top.translate(9 * scale, 47 * scale), paint);
      canvas.drawLine(top.translate(-15 * scale, 31 * scale), top.translate(15 * scale, 31 * scale), paint);

      final glow = Paint()
        ..style = PaintingStyle.fill
        ..color = line.withValues(alpha: line.a * 0.45);
      canvas.drawCircle(top.translate(0, 31 * scale), 5.5 * scale, glow);
    }

    lantern(
      top: Offset(size.width * 0.10, size.height * 0.22),
      scale: 0.95,
    );
    lantern(
      top: Offset(size.width * 0.20, size.height * 0.34),
      scale: 0.72,
    );
  }

  void _paintCrescent(Canvas canvas, Size size, Color line) {
    final center = Offset(size.width * 0.78, size.height * 0.38);
    final radius = math.min(size.width, size.height) * 0.055;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = line;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.82,
      math.pi * 1.58,
      false,
      paint,
    );

    final starPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = line;
    final star = _starPath(center.translate(radius * 1.35, -radius * 0.45), radius * 0.22);
    canvas.drawPath(star, starPaint);
  }

  Path _starPath(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? radius : radius * 0.42;
      final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  void _paintPalm(Canvas canvas, Size size, Color line) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..color = line;

    final base = Offset(size.width * 0.94, size.height * 0.79);
    final trunk = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx - size.width * 0.015,
        base.dy - size.height * 0.14,
        base.dx + size.width * 0.005,
        base.dy - size.height * 0.27,
      );
    canvas.drawPath(trunk, paint);

    final crown = Offset(base.dx + size.width * 0.005, base.dy - size.height * 0.27);
    for (var i = 0; i < 9; i++) {
      final angle = -math.pi * 0.95 + i * math.pi * 0.19;
      final end = crown + Offset(math.cos(angle) * size.width * 0.11, math.sin(angle) * size.height * 0.075);
      canvas.drawLine(crown, end, paint);
    }
  }

  void _paintCornerGeometry(Canvas canvas, Size size, Color line) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..color = line;

    final rect = Rect.fromLTWH(
      size.width * 0.72,
      0,
      size.width * 0.28,
      size.height * 0.32,
    );

    const step = 22.0;
    for (var x = rect.left; x <= rect.right; x += step) {
      canvas.drawLine(Offset(x, rect.top), Offset(x - rect.height, rect.bottom), paint);
      canvas.drawLine(Offset(x, rect.top), Offset(x + rect.height, rect.bottom), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicOrnamentalPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.opacity != opacity || oldDelegate.dark != dark;
  }
}
