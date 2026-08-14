import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A lightweight, fully offline Islamic ornamental background for Home.
///
/// The ornament is inspired by classical Arabic calligraphic flow,
/// arabesque curves, crescent-and-lantern motifs, and geometric framing.
/// It uses abstract calligraphic strokes rather than readable religious text,
/// so it adds historical Islamic character without introducing copied verses
/// or competing with the actual Home content.
class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAmoled = context.isAmoled;
    final opacity = isAmoled ? 0.052 : isDark ? 0.062 : 0.030;

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
    final stronger = color.withValues(alpha: opacity * 1.45);
    final soft = color.withValues(alpha: opacity * 0.72);

    _paintCalligraphicMedallion(canvas, size, stronger, soft);
    _paintLantern(canvas, size, stronger);
    _paintCrescent(canvas, size, stronger);
    _paintPalm(canvas, size, soft);
    _paintCornerGeometry(canvas, size, base);
  }

  void _paintCalligraphicMedallion(
    Canvas canvas,
    Size size,
    Color line,
    Color soft,
  ) {
    final center = Offset(size.width * 0.80, size.height * 0.17);
    final radius = math.min(size.width, size.height) * 0.27;

    final fine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.82
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = soft;
    final bold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.28
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = line;

    // Soft circular medallion framing, echoing classical manuscript seals.
    for (var ring = 1; ring <= 3; ring++) {
      canvas.drawCircle(center, radius * ring / 3, ring == 2 ? bold : fine);
    }

    // Abstract Arabic-calligraphy-inspired composition. These are deliberately
    // non-literal flowing strokes rather than readable Arabic text.
    final main = Path()
      ..moveTo(center.dx - radius * 0.76, center.dy + radius * 0.20)
      ..cubicTo(
        center.dx - radius * 0.62,
        center.dy - radius * 0.16,
        center.dx - radius * 0.38,
        center.dy - radius * 0.34,
        center.dx - radius * 0.10,
        center.dy - radius * 0.18,
      )
      ..cubicTo(
        center.dx + radius * 0.16,
        center.dy - radius * 0.02,
        center.dx + radius * 0.02,
        center.dy + radius * 0.20,
        center.dx - radius * 0.20,
        center.dy + radius * 0.27,
      )
      ..cubicTo(
        center.dx - radius * 0.48,
        center.dy + radius * 0.34,
        center.dx - radius * 0.55,
        center.dy + radius * 0.04,
        center.dx - radius * 0.28,
        center.dy - radius * 0.05,
      )
      ..cubicTo(
        center.dx + radius * 0.05,
        center.dy - radius * 0.15,
        center.dx + radius * 0.32,
        center.dy - radius * 0.12,
        center.dx + radius * 0.64,
        center.dy - radius * 0.30,
      )
      ..cubicTo(
        center.dx + radius * 0.78,
        center.dy - radius * 0.38,
        center.dx + radius * 0.76,
        center.dy - radius * 0.02,
        center.dx + radius * 0.55,
        center.dy + radius * 0.10,
      )
      ..cubicTo(
        center.dx + radius * 0.38,
        center.dy + radius * 0.20,
        center.dx + radius * 0.27,
        center.dy + radius * 0.35,
        center.dx + radius * 0.05,
        center.dy + radius * 0.42,
      );
    canvas.drawPath(main, bold);

    final upper = Path()
      ..moveTo(center.dx - radius * 0.72, center.dy - radius * 0.31)
      ..cubicTo(
        center.dx - radius * 0.42,
        center.dy - radius * 0.50,
        center.dx - radius * 0.04,
        center.dy - radius * 0.48,
        center.dx + radius * 0.22,
        center.dy - radius * 0.32,
      )
      ..cubicTo(
        center.dx + radius * 0.42,
        center.dy - radius * 0.20,
        center.dx + radius * 0.49,
        center.dy - radius * 0.02,
        center.dx + radius * 0.70,
        center.dy + radius * 0.02);
    canvas.drawPath(upper, fine);

    // Long horizontal flourish, characteristic of flowing Arabic lettering.
    final flourish = Path()
      ..moveTo(center.dx - radius * 0.80, center.dy + radius * 0.48)
      ..cubicTo(
        center.dx - radius * 0.36,
        center.dy + radius * 0.37,
        center.dx + radius * 0.12,
        center.dy + radius * 0.50,
        center.dx + radius * 0.48,
        center.dy + radius * 0.35,
      )
      ..cubicTo(
        center.dx + radius * 0.66,
        center.dy + radius * 0.27,
        center.dx + radius * 0.78,
        center.dy + radius * 0.34,
        center.dx + radius * 0.82,
        center.dy + radius * 0.24);
    canvas.drawPath(flourish, bold);

    // Small diacritic-like decorative marks; not Arabic letters.
    for (var i = 0; i < 5; i++) {
      final x = center.dx - radius * 0.52 + i * radius * 0.25;
      final y = center.dy - radius * 0.58 + (i.isEven ? 0 : radius * 0.04);
      canvas.drawCircle(Offset(x, y), radius * 0.018, fine);
    }

    // Outer arabesque leaves around the medallion.
    for (var i = 0; i < 8; i++) {
      final angle = -math.pi * 0.92 + i * math.pi * 0.26;
      final start = center + Offset(
        math.cos(angle) * radius * 0.74,
        math.sin(angle) * radius * 0.74,
      );
      final end = center + Offset(
        math.cos(angle) * radius * 0.94,
        math.sin(angle) * radius * 0.94,
      );
      final control = center + Offset(
        math.cos(angle + 0.22) * radius * 0.90,
        math.sin(angle + 0.22) * radius * 0.90,
      );
      final leaf = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy)
        ..quadraticBezierTo(control.dx, control.dy, start.dx, start.dy);
      canvas.drawPath(leaf, fine);
    }
  }

  void _paintLantern(Canvas canvas, Size size, Color line) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..strokeCap = StrokeCap.round
      ..color = line;

    void lantern({required Offset top, required double scale}) {
      final ropeTop = top.translate(0, -size.height * 0.075 * scale);
      canvas.drawLine(ropeTop, top, paint);
      final body = Path()
        ..moveTo(top.dx - 10 * scale, top.dy + 6 * scale)
        ..lineTo(top.dx - 16 * scale, top.dy + 17 * scale)
        ..lineTo(top.dx - 12 * scale, top.dy + 45 * scale)
        ..lineTo(top.dx, top.dy + 57 * scale)
        ..lineTo(top.dx + 12 * scale, top.dy + 45 * scale)
        ..lineTo(top.dx + 16 * scale, top.dy + 17 * scale)
        ..close();
      canvas.drawPath(body, paint);
      canvas.drawLine(
        top.translate(-8 * scale, 17 * scale),
        top.translate(-8 * scale, 44 * scale),
        paint,
      );
      canvas.drawLine(
        top.translate(8 * scale, 17 * scale),
        top.translate(8 * scale, 44 * scale),
        paint,
      );
      canvas.drawLine(
        top.translate(-14 * scale, 30 * scale),
        top.translate(14 * scale, 30 * scale),
        paint,
      );
      final glow = Paint()
        ..style = PaintingStyle.fill
        ..color = line.withValues(alpha: line.a * 0.38);
      canvas.drawCircle(top.translate(0, 30 * scale), 5 * scale, glow);
    }

    lantern(top: Offset(size.width * 0.12, size.height * 0.20), scale: 0.92);
    lantern(top: Offset(size.width * 0.21, size.height * 0.31), scale: 0.68);
  }

  void _paintCrescent(Canvas canvas, Size size, Color line) {
    final center = Offset(size.width * 0.72, size.height * 0.37);
    final radius = math.min(size.width, size.height) * 0.052;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeCap = StrokeCap.round
      ..color = line;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.84,
      math.pi * 1.62,
      false,
      paint,
    );
    final starPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = line;
    canvas.drawPath(
      _starPath(center.translate(radius * 1.30, -radius * 0.46), radius * 0.20),
      starPaint,
    );
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
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round
      ..color = line;
    final base = Offset(size.width * 0.95, size.height * 0.79);
    final trunk = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx - size.width * 0.015,
        base.dy - size.height * 0.14,
        base.dx + size.width * 0.005,
        base.dy - size.height * 0.27,
      );
    canvas.drawPath(trunk, paint);
    final crown = Offset(
      base.dx + size.width * 0.005,
      base.dy - size.height * 0.27,
    );
    for (var i = 0; i < 9; i++) {
      final angle = -math.pi * 0.95 + i * math.pi * 0.19;
      final end = crown + Offset(
        math.cos(angle) * size.width * 0.10,
        math.sin(angle) * size.height * 0.07,
      );
      canvas.drawLine(crown, end, paint);
    }
  }

  void _paintCornerGeometry(Canvas canvas, Size size, Color line) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.70
      ..color = line;
    final rect = Rect.fromLTWH(
      size.width * 0.68,
      0,
      size.width * 0.32,
      size.height * 0.34,
    );
    const step = 22.0;
    for (var x = rect.left; x <= rect.right; x += step) {
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x - rect.height, rect.bottom),
        paint,
      );
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x + rect.height, rect.bottom),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicOrnamentalPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.dark != dark;
  }
}
