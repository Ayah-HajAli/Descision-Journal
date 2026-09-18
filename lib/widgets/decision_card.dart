import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/decision.dart';
import '../theme/app_theme.dart';
import 'decorative_shapes.dart';
import 'logo_pill.dart';
import 'scallop_edge.dart';

class DecisionCard extends StatelessWidget {
  final Decision decision;
  final VoidCallback onTap;

  const DecisionCard({super.key, required this.decision, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final due = !decision.isResolved && decision.isUnlockable;

    // Sealed / not-yet-due cards use their category color, so the home
    // timeline reads as varied rather than four flat status blocks.
    // Resolved cards use their outcome color, since that's the more
    // useful signal to scan for once a decision is settled.
    final bg = decision.isResolved ? decision.status.color : decision.category.color;
    final fg = AppColors.onStatus(bg);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: ClipPath(
          clipper: const ScallopClipper(side: ScallopSide.bottom, bumpWidth: 22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 34),
            decoration: BoxDecoration(color: bg),
            child: Stack(
              children: [
                if (!decision.isResolved)
                  Positioned.fill(
                    child: SparkleField(color: fg.withOpacity(0.5)),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LogoPill(
                          background: fg == AppColors.cream
                              ? Colors.white.withOpacity(0.14)
                              : Colors.white,
                          foreground: fg,
                          label: decision.category.label.toUpperCase(),
                        ),
                        _StatusChip(decision: decision, due: due),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            decision.title,
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: AppColors.ink,
                              fontSize: 21,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            decision.isResolved
                                ? (decision.outcomeNote ?? '')
                                : (due
                                    ? "Ready to reveal — tap to see if you were right."
                                    : decision.prediction),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.ink.withOpacity(0.65),
                              fontStyle: decision.isResolved || due
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          decision.isResolved
                              ? Icons.check_circle_outline_rounded
                              : (due ? Icons.lock_open_rounded : Icons.lock_clock_rounded),
                          size: 15,
                          color: fg.withOpacity(0.85),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _metaLabel(decision, due),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: fg.withOpacity(0.85),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _metaLabel(Decision d, bool due) {
    final fmt = DateFormat('MMM d, yyyy');
    if (d.isResolved) {
      return 'Revealed ${fmt.format(d.resolvedAt ?? d.revealDate)} · was ${d.confidence}% sure';
    }
    if (due) {
      return 'Unlocked ${fmt.format(d.revealDate)}';
    }
    final daysLeft = d.revealDate.difference(DateTime.now()).inDays;
    return daysLeft <= 0
        ? 'Unlocks today'
        : 'Unlocks in $daysLeft day${daysLeft == 1 ? '' : 's'}';
  }
}

class _StatusChip extends StatelessWidget {
  final Decision decision;
  final bool due;

  const _StatusChip({required this.decision, required this.due});

  @override
  Widget build(BuildContext context) {
    final label = due ? 'REVEAL NOW' : decision.status.label.toUpperCase();
    final chipBg = due ? AppColors.ink : Colors.white;
    final chipFg = due ? AppColors.cream : AppColors.ink;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: chipFg,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
