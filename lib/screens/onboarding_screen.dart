import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_shapes.dart';
import '../widgets/scallop_edge.dart';

class _OnboardPage {
  final Color background;
  final Color foreground;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String body;

  const _OnboardPage({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
  });
}

const _pages = [
  _OnboardPage(
    background: AppColors.violet,
    foreground: AppColors.ink,
    icon: Icons.edit_note_rounded,
    eyebrow: 'STEP 1',
    title: 'Predict first.',
    body:
        "Before an important decision — a job, a move, a big purchase — write down exactly what you believe will happen. Be specific. Say how sure you are.",
  ),
  _OnboardPage(
    background: AppColors.yellow,
    foreground: AppColors.ink,
    icon: Icons.lock_rounded,
    eyebrow: 'STEP 2',
    title: 'We seal it away.',
    body:
        "Your prediction is locked the moment you save it — hidden even from you — until the reveal date you set. No editing, no peeking, no rewriting history.",
  ),
  _OnboardPage(
    background: AppColors.mint,
    foreground: AppColors.ink,
    icon: Icons.hourglass_bottom_rounded,
    eyebrow: 'STEP 3',
    title: 'Time does its thing.',
    body:
        "Weeks or months pass. Life happens the way it happens. Your sealed prediction just waits quietly in the background, untouched.",
  ),
  _OnboardPage(
    background: AppColors.forestGreen,
    foreground: AppColors.cream,
    icon: Icons.auto_awesome_rounded,
    eyebrow: 'STEP 4',
    title: 'Then, the reveal.',
    body:
        "When the date arrives, your prediction unlocks. Compare it to what actually happened and mark yourself right, wrong, or partly right — building an honest track record of your own judgment.",
  ),
];

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _pages.length - 1) {
      widget.onDone();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_index];
    final theme = Theme.of(context);
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      backgroundColor: page.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, top: 4),
                child: TextButton(
                  onPressed: isLast ? null : widget.onDone,
                  child: Text(
                    isLast ? '' : 'Skip',
                    style: TextStyle(
                      color: page.foreground.withOpacity(0.6),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: SparkleField(color: p.foreground.withOpacity(0.4)),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: p.foreground == AppColors.cream
                                    ? Colors.white24
                                    : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(p.icon, size: 34, color: p.foreground),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              p.eyebrow,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: p.foreground.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p.title,
                              style: theme.textTheme.displayLarge
                                  ?.copyWith(color: p.foreground, fontSize: 32),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              p.body,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: p.foreground.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? page.foreground
                              : page.foreground.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: page.foreground == AppColors.cream
                            ? AppColors.cream
                            : AppColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isLast ? 'Start journaling' : 'Next',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: page.foreground == AppColors.cream
                              ? AppColors.forestGreenDeep
                              : AppColors.cream,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ScallopDivider(
              color: page.background == AppColors.forestGreen
                  ? AppColors.forestGreenDeep
                  : Colors.white,
              height: 14,
            ),
          ],
        ),
      ),
    );
  }
}
