import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Offline Islamic artwork for the Home background.
///
/// The composition intentionally follows a premium Arabic-calligraphy artwork
/// direction: a large flowing Quranic inscription occupies the upper-right
/// field, surrounded by dense floral/arabesque flourishes, while the left
/// side remains visually quiet for readable Home content.
class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAmoled = context.isAmoled;
    final opacity = isAmoled ? 0.085 : isDark ? 0.095 : 0.045;

    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _PremiumQuranCalligraphyPainter(
            color: theme.colorScheme.primary,
            opacity: opacity,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _PremiumQuranCalligraphyPainter extends CustomPainter {
  const _PremiumQuranCalligraphyPainter({
    required this.color,
    required this.opacity,
  });

  final Color color;
  final double opacity;

  // A short ayah chosen for its compact composition and visual suitability.
  static const String _ayah = 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا';

  @override
  void paint(Canvas canvas, Size size) {
    // Keep the left side intentionally quiet, like the supplied reference.
    final center = Offset(size.width * 0.79, size.height * 0.18);
    final radius = math.min(size.width, size.height) * 0.36;

    _drawDeepBlueAtmosphere(canvas, size);
    _drawFloralArabesque(canvas, size, center, radius);
    _drawCalligraphicHalo(canvas, center, radius);
    _drawLargeCalligraphy(canvas, center, radius);
    _drawCalligraphySwashes(canvas, center, radius);
    _drawDecorativeDots(canvas, center, radius);
    _drawCrescent(canvas, size);
  }

  void _drawDeepBlueAtmosphere(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.56);
    final gradient = RadialGradient(
      center: const Alignment(0.75, -0.55),
      radius: 1.0,
      colors: [
        color.withValues(alpha: opacity * 0.72),
        color.withValues(alpha: opacity * 0.16),
        Colors.transparent,
      ],
      stops: const [0.0, 0.52, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  void _drawLargeCalligraphy(Canvas canvas, Offset center, double radius) {
    final maxWidth = radius * 2.12;
    final fontSize = (radius * 0.39).clamp(42.0, 92.0);

    // A thick outline under the inscription gives the visual weight of
    // hand-painted calligraphy rather than a thin ordinary UI label.
    final outlinePainter = TextPainter(
      text: TextSpan(
        text: _ayah,
        style: TextStyle(
          fontSize: fontSize,
          height: 1.02,
          fontWeight: FontWeight.w900,
          fontFamilyFallback: const [
            'Aref Ruqaa',
            'Amiri',
            'Noto Naskh Arabic',
            'Noto Sans Arabic',
          ],
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8
            ..color = color.withValues(alpha: opacity * 1.10),
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    )..layout(maxWidth: maxWidth);

    final fillPainter = TextPainter(
      text: TextSpan(
        text: _ayah,
        style: TextStyle(
          fontSize: fontSize,
          height: 1.02,
          fontWeight: FontWeight.w900,
          fontFamilyFallback: const [
            'Aref Ruqaa',
            'Amiri',
            'Noto Naskh Arabic',
            'Noto Sans Arabic',
          ],
          color: color.withValues(alpha: opacity * 0.82),
          shadows: [
            Shadow(
              color: color.withValues(alpha: opacity * 0.65),
              blurRadius: 14,
              offset: const Offset(0, 0),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    )..layout(maxWidth: maxWidth);

    final top = center.dy - fillPainter.height * 0.50;
    outlinePainter.paint(
      canvas,
      Offset(center.dx - outlinePainter.width / 2, top),
    );
    fillPainter.paint(
      canvas,
      Offset(center.dx - fillPainter.width / 2, top),
    );
  }

  void _drawCalligraphicHalo(Canvas canvas, Offset center, double radius) {
    final fine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: opacity * 0.48);

    // Large irregular oval instead of a geometric ring.
    for (var i = 0; i < 3; i++) {
      final rect = Rect.fromCenter(
        center: center,
        width: radius * (2.08 - i * 0.14),
        height: radius * (1.18 - i * 0.08),
      );
      canvas.drawOval(rect, fine);
    }

    // Hand-drawn ribbon strokes crossing behind the inscription.
    for (var i = 0; i < 4; i++) {
      final y = center.dy - radius * 0.38 + i * radius * 0.24;
      final path = Path()
        ..moveTo(center.dx - radius * 1.03, y)
        ..cubicTo(
          center.dx - radius * 0.64,
          y - radius * 0.26,
          center.dx - radius * 0.36,
          y + radius * 0.25,
          center.dx - radius * 0.02,
          y,
        )
        ..cubicTo(
          center.dx + radius * 0.36,
          y - radius * 0.25,
          center.dx + radius * 0.70,
          y + radius * 0.22,
          center.dx + radius * 1.08,
          y - radius * 0.06,
        );
      canvas.drawPath(path, fine);
    }
  }

  void _drawCalligraphySwashes(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.25
      ..color = color.withValues(alpha: opacity * 0.92);

    final paths = <Path>[];

    paths.add(
      Path()
        ..moveTo(center.dx - radius * 0.98, center.dy + radius * 0.22)
        ..cubicTo(
          center.dx - radius * 0.52,
          center.dy + radius * 0.02,
          center.dx - radius * 0.38,
          center.dy + radius * 0.58,
          center.dx + radius * 0.02,
          center.dy + radius * 0.34,
        )
        ..cubicTo(
          center.dx + radius * 0.40,
          center.dy + radius * 0.08,
          center.dx + radius * 0.62,
          center.dy + radius * 0.55,
          center.dx + radius * 1.00,
          center.dy + radius * 0.20,
        ),
    );

    paths.add(
      Path()
        ..moveTo(center.dx - radius * 1.06, center.dy - radius * 0.40)
        ..cubicTo(
          center.dx - radius * 0.68,
          center.dy - radius * 0.72,
          center.dx - radius * 0.34,
          center.dy - radius * 0.28,
          center.dx - radius * 0.04,
          center.dy - radius * 0.54,
        )
        ..cubicTo(
          center.dx + radius * 0.30,
          center.dy - radius * 0.82,
          center.dx + radius * 0.66,
          center.dy - radius * 0.30,
          center.dx + radius * 1.04,
          center.dy - radius * 0.55,
        ),
    );

    for (final path in paths) {
      canvas.drawPath(path, paint);
    }

    // Small hook-like strokes around the main lettering.
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi * 0.92 + i * math.pi * 0.205;
      final p = center + Offset(
        math.cos(angle) * radius * 0.98,
        math.sin(angle) * radius * 0.62,
      );
      final hook = Path()
        ..moveTo(p.dx, p.dy)
        ..quadraticBezierTo(
          p.dx + math.cos(angle + 0.7) * radius * 0.11,
          p.dy + math.sin(angle + 0.7) * radius * 0.11,
          p.dx + math.cos(angle + 1.35) * radius * 0.16,
          p.dy + math.sin(angle + 1.35) * radius * 0.16,
        );
      canvas.drawPath(hook, paint);
    }
  }

  void _drawFloralArabesque(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.72
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: opacity * 0.62);

    // Dense ornamental vines around the calligraphy, with a quiet fade toward
    // the left side so Home text remains dominant.
    for (var row = 0; row < 6; row++) {
      for (var col = 0; col < 8; col++) {
        final x = size.width * (0.50 + col * 0.065);
        final y = size.height * (0.015 + row * 0.052);
        final r = size.width * (0.012 + (row + col) % 3 * 0.004);
        _drawFloralMotif(canvas, Offset(x, y), r, paint, row + col);
      }
    }

    // Long vine curls, a key part of the reference's dense calligraphic feel.
    for (var i = 0; i < 5; i++) {
      final path = Path()
        ..moveTo(
          size.width * (0.55 + i * 0.07),
          size.height * 0.02,
        )
        ..cubicTo(
          size.width * (0.48 + i * 0.075),
          size.height * 0.10,
          size.width * (0.68 + i * 0.055),
          size.height * 0.15,
          size.width * (0.58 + i * 0.07),
          size.height * 0.25,
        )
        ..cubicTo(
          size.width * (0.52 + i * 0.07),
          size.height * 0.31,
          size.width * (0.78 + i * 0.035),
          size.height * 0.32,
          size.width * (0.88 + i * 0.025),
          size.height * 0.25,
        );
      canvas.drawPath(path, paint);
    }

    // A few larger leaves give the artwork the dense illuminated-manuscript
    // texture seen in premium Arabic calligraphy compositions.
    for (var i = 0; i < 14; i++) {
      final angle = -1.25 + i * 0.19;
      final p = center + Offset(
        math.cos(angle) * radius * 0.98,
        math.sin(angle) * radius * 0.62,
      );
      _drawLeaf(canvas, p, angle + 1.1, radius * 0.075, paint);
    }
  }

  void _drawFloralMotif(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    int seed,
  ) {
    final petalCount = 5 + seed % 3;
    for (var i = 0; i < petalCount; i++) {
      final a = i * math.pi * 2 / petalCount;
      final p = center + Offset(math.cos(a) * radius * 0.72, math.sin(a) * radius * 0.72);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..quadraticBezierTo(
          p.dx + math.cos(a + math.pi / 2) * radius * 0.42,
          p.dy + math.sin(a + math.pi / 2) * radius * 0.42,
          p.dx,
          p.dy,
        )
        ..quadraticBezierTo(
          p.dx + math.cos(a - math.pi / 2) * radius * 0.42,
          p.dy + math.sin(a - math.pi / 2) * radius * 0.42,
          center.dx,
          center.dy,
        );
      canvas.drawPath(path, paint);
    }
    canvas.drawCircle(center, radius * 0.20, paint);
  }

  void _drawDecorativeDots(Canvas canvas, Offset center, double radius) {
    final paint = Paint()..color = color.withValues(alpha: opacity * 0.88);
    for (var i = 0; i < 34; i++) {
      final angle = -math.pi * 0.96 + i * math.pi * 1.72 / 33;
      final r = radius * (0.74 + (i % 3) * 0.07);
      final p = center + Offset(
        math.cos(angle) * r,
        math.sin(angle) * r * 0.64,
      );
      canvas.drawCircle(p, i % 5 == 0 ? 1.8 : 0.9, paint);
    }
  }

  void _drawCrescent(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.90, size.height * 0.37);
    final radius = math.min(size.width, size.height) * 0.044;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: opacity * 1.15);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.82,
      math.pi * 1.62,
      false,
      paint,
    );
  }

  void _drawLeaf(Canvas canvas, Offset center, double angle, double radius, Paint paint) {
    final axis = Offset(math.cos(angle), math.sin(angle));
    final normal = Offset(-axis.dy, axis.dx);
    final a = center + axis * radius;
    final b = center - axis * radius;
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(
        center.dx + normal.dx * radius * 0.8,
        center.dy + normal.dy * radius * 0.8,
        b.dx,
        b.dy,
      )
      ..quadraticBezierTo(
        center.dx - normal.dx * radius * 0.8,
        center.dy - normal.dy * radius * 0.8,
        a.dx,
        a.dy,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PremiumQuranCalligraphyPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
