import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Reusable, subtle Islamic calligraphy-inspired overlay for app screens.
/// The marks are intentionally abstract: they resemble intertwined Arabic
/// calligraphy without forming readable Qur'an, Arabic, or other text.
class IslamicOrnamentalBackground extends StatelessWidget {
  const IslamicOrnamentalBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = theme.brightness == Brightness.dark ? 0.06 : 0.032;

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _AbstractArabicOverlayPainter(
                color: theme.colorScheme.primary,
                opacity: opacity,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AbstractArabicOverlayPainter extends CustomPainter {
  const _AbstractArabicOverlayPainter({
    required this.color,
    required this.opacity,
  });

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) / 430.0;
    final fine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.15 * scale
      ..color = color.withValues(alpha: opacity);

    final accent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.6 * scale
      ..color = color.withValues(alpha: opacity * 1.18);

    // Small, compact calligraphic clusters rather than a large geometric
    // medallion. Each cluster is made from intertwined sweeping strokes,
    // loops and dot groups, evoking traditional Arabic calligraphy.
    final motifs = <Offset>[
      Offset(size.width * .79, size.height * .12),
      Offset(size.width * .93, size.height * .28),
      Offset(size.width * .70, size.height * .34),
      Offset(size.width * .88, size.height * .52),
      Offset(size.width * .16, size.height * .70),
      Offset(size.width * .82, size.height * .78),
      Offset(size.width * .28, size.height * .91),
    ];

    for (var i = 0; i < motifs.length; i++) {
      _drawCalligraphicMotif(
        canvas,
        motifs[i],
        36.0 * scale * (i.isEven ? 1.0 : .82),
        fine,
        accent,
        rotation: (i.isOdd ? -.18 : .08) + (i % 3) * .04,
      );
    }

    // Very light connecting flourishes keep the background feeling like one
    // continuous manuscript ornament without becoming a readable sentence.
    final flourish = Path()
      ..moveTo(size.width * .53, size.height * .04)
      ..cubicTo(
        size.width * .62,
        size.height * .10,
        size.width * .58,
        size.height * .18,
        size.width * .70,
        size.height * .21,
      )
      ..cubicTo(
        size.width * .78,
        size.height * .24,
        size.width * .83,
        size.height * .18,
        size.width * .92,
        size.height * .20,
      );
    canvas.drawPath(flourish, fine);
  }

  void _drawCalligraphicMotif(
    Canvas canvas,
    Offset center,
    double r,
    Paint fine,
    Paint accent, {
    required double rotation,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    // Long curved 'letter' stroke.
    final main = Path()
      ..moveTo(-r * 1.05, r * .15)
      ..cubicTo(-r * .58, -r * .48, -r * .12, r * .52, r * .38, -r * .12)
      ..cubicTo(r * .62, -r * .40, r * .76, -r * .56, r * 1.04, -r * .22)
      ..cubicTo(r * .82, r * .12, r * .48, r * .20, r * .20, r * .05);
    canvas.drawPath(main, accent);

    // Intertwined hook/loop strokes.
    final loop = Path()
      ..moveTo(-r * .82, -r * .08)
      ..cubicTo(-r * .48, -r * .72, r * .12, -r * .66, r * .34, -r * .22)
      ..cubicTo(r * .52, r * .16, r * .18, r * .48, -r * .18, r * .34)
      ..cubicTo(-r * .50, r * .20, -r * .50, -r * .18, -r * .20, -r * .30);
    canvas.drawPath(loop, fine);

    final hook = Path()
      ..moveTo(r * .42, -r * .62)
      ..cubicTo(r * .08, -r * .92, -r * .30, -r * .66, -r * .18, -r * .40)
      ..cubicTo(-r * .04, -r * .10, r * .48, -r * .10, r * .72, r * .20)
      ..cubicTo(r * .88, r * .40, r * .70, r * .64, r * .42, r * .70);
    canvas.drawPath(hook, fine);

    // Short stems, typical of a decorative Arabic-script silhouette.
    for (var i = -1; i <= 1; i++) {
      final x = i * r * .34;
      final stem = Path()
        ..moveTo(x, r * .34)
        ..cubicTo(x - r * .05, r * .02, x + r * .05, -r * .42, x + r * .02, -r * .70);
      canvas.drawPath(stem, fine);
    }

    // Decorative dot clusters; deliberately non-linguistic.
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fine.color;
    for (var i = 0; i < 7; i++) {
      final angle = -.9 + i * .31;
      final distance = r * (.66 + (i.isEven ? .08 : 0));
      canvas.drawCircle(
        Offset(math.cos(angle) * distance, math.sin(angle) * distance),
        (i % 3 == 0 ? 1.25 : .72) * (r / 36.0),
        dotPaint,
      );
    }

    // Tiny leaf curls around the motif.
    for (var i = 0; i < 4; i++) {
      final a = -.8 + i * .55;
      final p = Offset(
        math.cos(a) * r * .92,
        math.sin(a) * r * .72,
      );
      _drawLeaf(canvas, p, a + 1.0, r * .20, fine);
    }

    canvas.restore();
  }

  void _drawLeaf(
    Canvas canvas,
    Offset center,
    double angle,
    double length,
    Paint paint,
  ) {
    final tip = center + Offset(
      math.cos(angle) * length,
      math.sin(angle) * length,
    );
    final side = length * .42;
    final a = center + Offset(
      math.cos(angle + math.pi / 2) * side,
      math.sin(angle + math.pi / 2) * side,
    );
    final b = center + Offset(
      math.cos(angle - math.pi / 2) * side,
      math.sin(angle - math.pi / 2) * side,
    );
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..quadraticBezierTo(a.dx, a.dy, tip.dx, tip.dy)
      ..quadraticBezierTo(b.dx, b.dy, center.dx, center.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AbstractArabicOverlayPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
