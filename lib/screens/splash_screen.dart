import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_shapes.dart';
import '../widgets/scallop_edge.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.4, curve: Curves.easeIn),
    );
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.forestGreen,
      body: Stack(
        children: [
          Positioned.fill(
            child: SparkleField(
              color: Colors.white,
              positions: const [
                Offset(0.12, 0.12),
                Offset(0.85, 0.18),
                Offset(0.15, 0.85),
                Offset(0.88, 0.8),
                Offset(0.5, 0.92),
                Offset(0.5, 0.08),
              ],
              sizes: const [16, 12, 14, 10, 12, 10],
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: AppColors.yellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_clock_rounded,
                          size: 44, color: AppColors.ink),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Decision\nJournal',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: AppColors.cream,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'seal it. see it.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ScallopDivider(color: AppColors.paper, height: 26, bumpWidth: 26),
          ),
        ],
      ),
    );
  }
}
