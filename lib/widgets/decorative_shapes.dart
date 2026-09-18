import 'package:flutter/material.dart';

/// A single small sparkle/star mark, positioned absolutely by the caller.
class Sparkle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const Sparkle({
    super.key,
    this.size = 16,
    this.color = Colors.white,
    this.opacity = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: Size(size, size),
        painter: _SparklePainter(color: color),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;
  _SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final path = Path();
    // four-pointed star / sparkle
    path.moveTo(cx, 0);
    path.quadraticBezierTo(cx, cy, size.width, cy);
    path.quadraticBezierTo(cx, cy, cx, size.height);
    path.quadraticBezierTo(cx, cy, 0, cy);
    path.quadraticBezierTo(cx, cy, cx, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Scatters a handful of sparkles across a fixed-position field, meant to
/// sit behind foreground content inside a Stack. Positions are relative
/// (0-1) so it adapts to whatever box it's placed in.
class SparkleField extends StatelessWidget {
  final Color color;
  final List<Offset> positions;
  final List<double> sizes;

  const SparkleField({
    super.key,
    this.color = Colors.white,
    this.positions = const [
      Offset(0.08, 0.15),
      Offset(0.85, 0.1),
      Offset(0.92, 0.55),
      Offset(0.05, 0.7),
      Offset(0.5, 0.05),
    ],
    this.sizes = const [14, 10, 12, 9, 11],
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: List.generate(positions.length, (i) {
            final p = positions[i];
            final s = sizes[i % sizes.length];
            return Positioned(
              left: p.dx * constraints.maxWidth - s / 2,
              top: p.dy * constraints.maxHeight - s / 2,
              child: Sparkle(size: s, color: color, opacity: 0.55),
            );
          }),
        );
      },
    );
  }
}

/// A small round dot, used for confetti-style clusters.
class Dot extends StatelessWidget {
  final double size;
  final Color color;
  const Dot({super.key, this.size = 8, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
