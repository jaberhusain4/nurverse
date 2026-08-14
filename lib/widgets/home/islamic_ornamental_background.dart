import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Premium abstract Islamic calligraphic ornament used as a background layer.
///
/// Decorative only: it is not readable Arabic and contains no Qur'an verse.
/// The composition follows the supplied reference's flowing calligraphy feel,
/// while staying within NurVerse's Sea Shore blue palette.
class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: SizedBox.expand(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _PremiumCalligraphyPainter(),
          ),
        ),
      ),
    );
  }
}

class _PremiumCalligraphyPainter extends CustomPainter {
  const _PremiumCalligraphyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final unit = math.min(size.width, size.height) / 430.0;
    final main = AppColors.seaBlue.withValues(alpha: 0.25);
    final light = AppColors.softAqua.withValues(alpha: 0.16);
    final deep = AppColors.seaBlueDark.withValues(alpha: 0.16);

    // The reference is visually strongest on the upper-right. The left side
    // remains deliberately quiet so the existing Home content is untouched.
    final center = Offset(size.width * 0.73, size.height * 0.19);

    _drawMainCalligraphy(canvas, center, unit, main, light, deep);
    _drawSmallMotifs(canvas, size, unit, main, light);
    _drawLowerFlow(canvas, size, unit, deep);
  }

  void _drawMainCalligraphy(
    Canvas canvas,
    Offset c,
    double s,
    Color main,
    Color light,
    Color deep,
  ) {
    final brush = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Broad ribbon strokes form the large intertwined calligraphic silhouette.
    brush
      ..color = deep
      ..strokeWidth = 19 * s;
    canvas.drawPath(
      _curve([
        c.translate(-190 * s, 8 * s),
        c.translate(-76 * s, -115 * s),
        c.translate(20 * s, -4 * s),
        c.translate(105 * s, -104 * s),
        c.translate(220 * s, -34 * s),
      ]),
      brush,
    );

    brush
      ..color = main
      ..strokeWidth = 12 * s;
    canvas.drawPath(
      _curve([
        c.translate(-210 * s, 22 * s),
        c.translate(-104 * s, -65 * s),
        c.translate(5 * s, 10 * s),
        c.translate(113 * s, -60 * s),
        c.translate(208 * s, -2 * s),
      ]),
      brush,
    );

    brush
      ..color = light
      ..strokeWidth = 8 * s;
    canvas.drawPath(
      _curve([
        c.translate(-178 * s, 68 * s),
        c.translate(-70 * s, 126 * s),
        c.translate(20 * s, 52 * s),
        c.translate(102 * s, 91 * s),
        c.translate(210 * s, 38 * s),
      ]),
      brush,
    );

    // Long sweeping baseline typical of ornamental Arabic lettering.
    brush
      ..color = main
      ..strokeWidth = 10 * s;
    canvas.drawPath(
      _curve([
        c.translate(-194 * s, 92 * s),
        c.translate(-70 * s, 151 * s),
        c.translate(52 * s, 105 * s),
        c.translate(142 * s, 130 * s),
        c.translate(224 * s, 70 * s),
      ]),
      brush,
    );

    // Tall stems, hooked ascenders and descending strokes.
    brush
      ..color = main
      ..strokeWidth = 8 * s;
    final stems = <List<double>>[
      [-125, 56, -106, -83, -86, -124],
      [-52, 86, -37, -65, -15, -102],
      [31, 72, 53, -74, 74, -106],
      [103, 58, 125, -58, 148, -91],
      [165, 40, 181, -28, 198, -60],
    ];
    for (final d in stems) {
      final path = Path()
        ..moveTo(c.dx + d[0] * s, c.dy + d[1] * s)
        ..cubicTo(
          c.dx + d[2] * s,
          c.dy + d[3] * s,
          c.dx + d[4] * s,
          c.dy + d[5] * s,
          c.dx + (d[4] + 18) * s,
          c.dy + (d[5] + 25) * s,
        );
      canvas.drawPath(path, brush);
    }

    // Enclosed loops create the characteristic intertwined rhythm.
    brush
      ..color = light
      ..strokeWidth = 5 * s;
    for (final o in <Offset>[
      c.translate(-145 * s, -30 * s),
      c.translate(-72 * s, 7 * s),
      c.translate(10 * s, -38 * s),
      c.translate(87 * s, 5 * s),
      c.translate(154 * s, -18 * s),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: o,
          width: 45 * s,
          height: 21 * s,
        ),
        brush,
      );
    }

    // Diacritic-like decorative dots, intentionally non-semantic.
    final dot = Paint()..color = light;
    for (final p in <Offset>[
      c.translate(-173 * s, -65 * s),
      c.translate(-158 * s, -76 * s),
      c.translate(-14 * s, -83 * s),
      c.translate(1 * s, -92 * s),
      c.translate(67 * s, -64 * s),
      c.translate(157 * s, -76 * s),
      c.translate(178 * s, -60 * s),
      c.translate(121 * s, 18 * s),
      c.translate(43 * s, 32 * s),
      c.translate(-61 * s, 45 * s),
    ]) {
      canvas.drawCircle(p, 3 * s, dot);
    }

    // Fine curls around the main strokes.
    _curl(canvas, c.translate(-174 * s, 49 * s), 51 * s, -0.8, main);
    _curl(canvas, c.translate(176 * s, 40 * s), 57 * s, 0.4, light);
    _curl(canvas, c.translate(155 * s, -91 * s), 45 * s, -0.2, main);
    _curl(canvas, c.translate(-120 * s, -91 * s), 41 * s, 0.7, light);
  }

  void _drawSmallMotifs(
    Canvas canvas,
    Size size,
    double s,
    Color main,
    Color light,
  ) {
    final points = <Offset>[
      Offset(size.width * .56, size.height * .06),
      Offset(size.width * .89, size.height * .08),
      Offset(size.width * .51, size.height * .30),
      Offset(size.width * .94, size.height * .33),
      Offset(size.width * .70, size.height * .39),
      Offset(size.width * .47, size.height * .47),
    ];

    for (var i = 0; i < points.length; i++) {
      _smallMotif(
        canvas,
        points[i],
        s * (0.55 + (i % 3) * 0.10),
        i.isEven ? main : light,
        i.isEven ? 0.3 : -0.45,
      );
    }
  }

  void _drawLowerFlow(Canvas canvas, Size size, double s, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.2 * s
      ..color = color;

    final path = Path()
      ..moveTo(size.width * .40, size.height * .62)
      ..cubicTo(
        size.width * .56,
        size.height * .56,
        size.width * .68,
        size.height * .70,
        size.width * .81,
        size.height * .64,
      )
      ..cubicTo(
        size.width * .91,
        size.height * .59,
        size.width * .97,
        size.height * .68,
        size.width,
        size.height * .63,
      );
    canvas.drawPath(path, paint);
  }

  Path _curve(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length - 1; i += 2) {
      final control = points[i];
      final end = points[math.min(i + 1, points.length - 1)];
      path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    }
    return path;
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
      ..strokeWidth = math.max(2.5, radius * .075)
      ..strokeCap = StrokeCap.round
      ..color = color;

    final path = Path();
    for (var i = 0; i <= 36; i++) {
      final t = i / 36.0;
      final angle = rotation + t * math.pi * 1.75;
      final r = radius * (1.0 - t * .72);
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

  void _smallMotif(
    Canvas canvas,
    Offset center,
    double s,
    Color color,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.5 * s
      ..color = color;

    final path = Path()
      ..moveTo(-46 * s, 10 * s)
      ..cubicTo(-18 * s, -30 * s, 2 * s, 30 * s, 38 * s, -8 * s)
      ..cubicTo(51 * s, -21 * s, 36 * s, -40 * s, 18 * s, -30 * s)
      ..cubicTo(2 * s, -20 * s, 15 * s, 4 * s, 32 * s, 8 * s);
    canvas.drawPath(path, paint);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-8 * s, 8 * s),
        width: 30 * s,
        height: 13 * s,
      ),
      paint,
    );

    final dot = Paint()..color = color;
    for (final p in <Offset>[
      Offset(-35 * s, -7 * s),
      Offset(-27 * s, -14 * s),
      Offset(10 * s, -20 * s),
      Offset(22 * s, -13 * s),
    ]) {
      canvas.drawCircle(p, 2 * s, dot);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
