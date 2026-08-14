import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Offline Islamic artwork for the Home background.
///
/// The artwork keeps the left side quiet for UI readability and places the
/// Qur'anic inscription on a flowing, curved calligraphic path in the
/// upper-right field. Everything is painted locally; no image or network
/// asset is required.
class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAmoled = context.isAmoled;
    final opacity = isAmoled ? 0.11 : isDark ? 0.115 : 0.052;

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

  static const String _ayah = 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا';
  static const List<String> _ayahWords = <String>[
    'فَإِنَّ',
    'مَعَ',
    'الْعُسْرِ',
    'يُسْرًا',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.76, size.height * 0.18);
    final radius = math.min(size.width, size.height) * 0.37;

    _drawDeepBlueAtmosphere(canvas, size, center, radius);
    _drawFloralArabesque(canvas, size, center, radius);
    _drawCalligraphicHalo(canvas, center, radius);
    _drawCurvedAyah(canvas, center, radius);
    _drawCalligraphySwashes(canvas, center, radius);
    _drawDecorativeDots(canvas, center, radius);
    _drawCrescent(canvas, size);
  }

  void _drawDeepBlueAtmosphere(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
  ) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.58);
    final gradient = RadialGradient(
      center: const Alignment(0.62, -0.45),
      radius: 1.05,
      colors: [
        color.withValues(alpha: opacity * 0.78),
        color.withValues(alpha: opacity * 0.22),
        Colors.transparent,
      ],
      stops: const [0.0, 0.56, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    final glow = Paint()
      ..color = color.withValues(alpha: opacity * 0.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(center, radius * 0.62, glow);
  }

  void _drawCurvedAyah(Canvas canvas, Offset center, double radius) {
    // The reference direction is a genuine flowing composition rather than
    // one straight text line: each word follows a sweeping S-shaped baseline,
    // with a slight rotation and scale change to mimic hand-lettered rhythm.
    final wordPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: opacity * 1.72);

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..color = color.withValues(alpha: opacity * 1.05);

    final startX = center.dx - radius * 1.00;
    final step = radius * 0.56;

    for (var i = 0; i < _ayahWords.length; i++) {
      final t = i / (_ayahWords.length - 1);
      final x = startX + step * i;
      final wave = math.sin(t * math.pi * 1.35 - 0.45);
      final y = center.dy + wave * radius * 0.27 + (i.isOdd ? -radius * 0.035 : radius * 0.02);
      final tangent = math.cos(t * math.pi * 1.35 - 0.45) * 0.22;
      final angle = tangent + (i - 1.5) * 0.035;
      final scale = 0.92 + (1 - (i - 1.5).abs() / 2.0) * 0.18;
      final fontSize = (radius * 0.31 * scale).clamp(36.0, 76.0);

      final textPainter = TextPainter(
        text: TextSpan(
          text: _ayahWords[i],
          style: TextStyle(
            fontSize: fontSize,
            height: 0.92,
            fontWeight: FontWeight.w900,
            fontFamilyFallback: const [
              'Aref Ruqaa',
              'Amiri',
              'Noto Naskh Arabic',
              'Noto Sans Arabic',
            ],
            color: wordPaint.color,
            shadows: [
              Shadow(
                color: color.withValues(alpha: opacity * 0.72),
                blurRadius: 16,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      )..layout(maxWidth: radius * 0.78);

      final position = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      );

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.scale(scale, 1.08 - (i * 0.025));
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();

      // Fine underline/pen stroke follows each word and visually joins the
      // separate glyph groups into one continuous calligraphic artwork.
      final underline = Path()
        ..moveTo(position.dx - radius * 0.05, y + textPainter.height * 0.32)
        ..cubicTo(
          position.dx + textPainter.width * 0.25,
          y + radius * 0.12,
          position.dx + textPainter.width * 0.62,
          y - radius * 0.08,
          position.dx + textPainter.width * 1.02,
          y + radius * 0.03,
        );
      canvas.drawPath(underline, outlinePaint);
    }

    // Long sweeping tail under the composition gives it the unmistakable
    // hand-drawn wall-art silhouette while remaining abstract and subtle.
    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius * 0.032
      ..color = color.withValues(alpha: opacity * 1.05);
    final path = Path()
      ..moveTo(center.dx - radius * 1.12, center.dy + radius * 0.42)
      ..cubicTo(
        center.dx - radius * 0.62,
        center.dy + radius * 0.68,
        center.dx + radius * 0.12,
        center.dy + radius * 0.70,
        center.dx + radius * 0.94,
        center.dy + radius * 0.24,
      )
      ..cubicTo(
        center.dx + radius * 1.12,
        center.dy + radius * 0.14,
        center.dx + radius * 1.18,
        center.dy + radius * 0.32,
        center.dx + radius * 1.00,
        center.dy + radius * 0.47,
      );
    canvas.drawPath(path, sweep);
  }

  void _drawCalligraphicHalo(Canvas canvas, Offset center, double radius) {
    final fine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: opacity * 0.52);

    for (var i = 0; i < 4; i++) {
      final rect = Rect.fromCenter(
        center: Offset(center.dx + radius * 0.08, center.dy + radius * 0.02),
        width: radius * (2.22 - i * 0.16),
        height: radius * (1.30 - i * 0.08),
      );
      canvas.drawOval(rect, fine);
    }
  }

  void _drawCalligraphySwashes(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.35
      ..color = color.withValues(alpha: opacity * 1.00);

    final paths = <Path>[
      Path()
        ..moveTo(center.dx - radius * 1.05, center.dy - radius * 0.42)
        ..cubicTo(
          center.dx - radius * 0.74,
          center.dy - radius * 0.74,
          center.dx - radius * 0.38,
          center.dy - radius * 0.20,
          center.dx - radius * 0.04,
          center.dy - radius * 0.54,
        )
        ..cubicTo(
          center.dx + radius * 0.36,
          center.dy - radius * 0.92,
          center.dx + radius * 0.68,
          center.dy - radius * 0.26,
          center.dx + radius * 1.08,
          center.dy - radius * 0.56,
        ),
      Path()
        ..moveTo(center.dx - radius * 0.96, center.dy + radius * 0.28)
        ..cubicTo(
          center.dx - radius * 0.52,
          center.dy + radius * 0.02,
          center.dx - radius * 0.30,
          center.dy + radius * 0.62,
          center.dx + radius * 0.10,
          center.dy + radius * 0.36,
        )
        ..cubicTo(
          center.dx + radius * 0.52,
          center.dy + radius * 0.08,
          center.dx + radius * 0.72,
          center.dy + radius * 0.58,
          center.dx + radius * 1.06,
          center.dy + radius * 0.22,
        ),
    ];

    for (final path in paths) {
      canvas.drawPath(path, paint);
    }

    for (var i = 0; i < 18; i++) {
      final angle = -1.18 + i * 0.145;
      final p = center + Offset(
        math.cos(angle) * radius * 1.05,
        math.sin(angle) * radius * 0.66,
      );
      final hook = Path()
        ..moveTo(p.dx, p.dy)
        ..quadraticBezierTo(
          p.dx + math.cos(angle + 0.7) * radius * 0.10,
          p.dy + math.sin(angle + 0.7) * radius * 0.10,
          p.dx + math.cos(angle + 1.35) * radius * 0.17,
          p.dy + math.sin(angle + 1.35) * radius * 0.17,
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
      ..strokeWidth = 0.76
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: opacity * 0.64);

    for (var i = 0; i < 22; i++) {
      final t = i / 21;
      final x = size.width * (0.47 + t * 0.51);
      final y = size.height * (0.015 + math.sin(t * math.pi * 1.55) * 0.19);
      final r = size.width * (0.010 + (i % 3) * 0.003);
      _drawFloralMotif(canvas, Offset(x, y), r, paint, i);
    }

    for (var i = 0; i < 8; i++) {
      final path = Path()
        ..moveTo(size.width * (0.48 + i * 0.065), size.height * 0.02)
        ..cubicTo(
          size.width * (0.43 + i * 0.075),
          size.height * 0.10,
          size.width * (0.67 + i * 0.05),
          size.height * 0.15,
          size.width * (0.57 + i * 0.07),
          size.height * 0.26,
        )
        ..cubicTo(
          size.width * (0.50 + i * 0.07),
          size.height * 0.33,
          size.width * (0.80 + i * 0.03),
          size.height * 0.30,
          size.width * (0.92 + i * 0.015),
          size.height * 0.22,
        );
      canvas.drawPath(path, paint);
    }

    for (var i = 0; i < 20; i++) {
      final angle = -1.30 + i * 0.16;
      final p = center + Offset(
        math.cos(angle) * radius * 1.00,
        math.sin(angle) * radius * 0.64,
      );
      _drawLeaf(canvas, p, angle + 1.08, radius * 0.075, paint);
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
      final p = center + Offset(
        math.cos(a) * radius * 0.72,
        math.sin(a) * radius * 0.72,
      );
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
    final paint = Paint()..color = color.withValues(alpha: opacity * 0.92);
    for (var i = 0; i < 54; i++) {
      final angle = -math.pi * 0.96 + i * math.pi * 1.78 / 53;
      final r = radius * (0.72 + (i % 4) * 0.075);
      final p = center + Offset(
        math.cos(angle) * r,
        math.sin(angle) * r * 0.66,
      );
      canvas.drawCircle(p, i % 7 == 0 ? 1.7 : 0.75, paint);
    }
  }

  void _drawCrescent(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.90, size.height * 0.34);
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

  void _drawLeaf(
    Canvas canvas,
    Offset center,
    double angle,
    double radius,
    Paint paint,
  ) {
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
