import 'package:flutter/material.dart';

enum ScallopSide { top, bottom }

/// Clips a widget so one edge becomes a repeating row of half-circle
/// "scallops" — the signature wave motif from the reference cards.
class ScallopClipper extends CustomClipper<Path> {
  final ScallopSide side;
  final double bumpWidth;

  const ScallopClipper({this.side = ScallopSide.bottom, this.bumpWidth = 28});

  @override
  Path getClip(Size size) {
    final bumps = (size.width / bumpWidth).round().clamp(3, 100);
    final w = size.width / bumps;
    final r = w / 2;
    final path = Path();

    if (side == ScallopSide.bottom) {
      final waveTop = size.height - r;
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, waveTop);
      for (int i = 0; i < bumps; i++) {
        final startX = size.width - i * w;
        final endX = startX - w;
        final midX = startX - r;
        path.quadraticBezierTo(midX, waveTop + r * 1.7, endX, waveTop);
      }
      path.lineTo(0, waveTop);
      path.close();
    } else {
      final waveBottom = r;
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, waveBottom);
      for (int i = 0; i < bumps; i++) {
        final startX = size.width - i * w;
        final endX = startX - w;
        final midX = startX - r;
        path.quadraticBezierTo(midX, waveBottom - r * 1.7, endX, waveBottom);
      }
      path.lineTo(0, waveBottom);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// A thin decorative strip of scallop bumps, used as a divider between
/// two colored sections (mirrors the small wave under the story cards).
class ScallopDivider extends StatelessWidget {
  final Color color;
  final double height;
  final double bumpWidth;

  const ScallopDivider({
    super.key,
    required this.color,
    this.height = 16,
    this.bumpWidth = 20,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ScallopClipper(side: ScallopSide.top, bumpWidth: bumpWidth),
      child: Container(height: height, color: color),
    );
  }
}
