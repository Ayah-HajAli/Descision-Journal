import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Small rounded badge used inside cards, mirroring the little
/// "🔒 ACADEMY" pill in the reference screenshots.
class LogoPill extends StatelessWidget {
  final Color background;
  final Color foreground;
  final String label;

  const LogoPill({
    super.key,
    this.background = AppColors.cream,
    this.foreground = AppColors.ink,
    this.label = 'JOURNAL',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: foreground.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.book_rounded, size: 10, color: background),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// The big lockup used on the home screen header, mirroring the
/// "ACADEMY · knowledge is power" wordmark pairing at the top of the
/// reference sheet.
class AppWordmark extends StatelessWidget {
  const AppWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            'THE JOURNAL',
            style: TextStyle(
              color: AppColors.cream,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Transform.rotate(
          angle: -0.05,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.yellow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'seal it. see it.',
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
