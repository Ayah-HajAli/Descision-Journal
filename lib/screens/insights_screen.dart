import 'package:flutter/material.dart';
import '../data/store.dart';
import '../models/decision.dart';
import '../theme/app_theme.dart';

class InsightsScreen extends StatelessWidget {
  final DecisionStore store;
  const InsightsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracy = store.accuracy;
    final byCategory = store.accuracyByCategory;
    final hasResolved = store.resolvedCount > 0;

    return Scaffold(
      backgroundColor: AppColors.violet,
      appBar: AppBar(
        backgroundColor: AppColors.violet,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: Text('Your track record', style: theme.textTheme.titleLarge),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          children: [
            if (!hasResolved)
              _EmptyInsights(theme: theme)
            else ...[
              _AccuracyRing(accuracy: accuracy),
              const SizedBox(height: 24),
              _SectionLabel('OUTCOME BREAKDOWN'),
              const SizedBox(height: 10),
              _OutcomeBar(
                right: store.rightCount,
                partial: store.partialCount,
                wrong: store.wrongCount,
              ),
              const SizedBox(height: 28),
              _SectionLabel('SEALED VS. REVEALED'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      color: AppColors.yellow,
                      value: '${store.sealedCount}',
                      label: 'Still sealed',
                      icon: Icons.lock_clock_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      color: AppColors.mint,
                      value: '${store.resolvedCount}',
                      label: 'Revealed',
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              if (byCategory.isNotEmpty) ...[
                _SectionLabel('ACCURACY BY CATEGORY'),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: byCategory.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _CategoryRow(category: e.key, accuracy: e.value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 28),
              ],
              if (store.rightCount > 0 || store.wrongCount > 0) ...[
                _SectionLabel('ARE YOU CALIBRATED?'),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Confidence when you were right vs. wrong",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 14),
                      _ConfidenceRow(
                        label: 'When right',
                        value: store.avgConfidenceWhenRight,
                        color: AppColors.forestGreen,
                      ),
                      const SizedBox(height: 10),
                      _ConfidenceRow(
                        label: 'When wrong',
                        value: store.avgConfidenceWhenWrong,
                        color: AppColors.coral,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        store.avgConfidenceWhenRight > store.avgConfidenceWhenWrong
                            ? "You tend to be more confident exactly when you're right — good instincts."
                            : "You're sometimes just as confident when you're wrong — worth noticing before your next big call.",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyInsights extends StatelessWidget {
  final ThemeData theme;
  const _EmptyInsights({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const Icon(Icons.query_stats_rounded, size: 44, color: AppColors.ink),
          const SizedBox(height: 14),
          Text(
            "No revealed decisions yet",
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            "Once a sealed prediction unlocks and you log what really happened, your track record shows up here.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink.withOpacity(0.65)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
        color: AppColors.ink.withOpacity(0.6),
      ),
    );
  }
}

class _AccuracyRing extends StatelessWidget {
  final double accuracy;
  const _AccuracyRing({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: accuracy,
                    strokeWidth: 12,
                    backgroundColor: AppColors.paper,
                    valueColor: const AlwaysStoppedAnimation(AppColors.forestGreen),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(accuracy * 100).round()}%',
                      style: theme.textTheme.displayLarge?.copyWith(fontSize: 30),
                    ),
                    Text(
                      'accurate',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Right + half-credit for partly right',
            style: theme.textTheme.labelSmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _OutcomeBar extends StatelessWidget {
  final int right;
  final int partial;
  final int wrong;

  const _OutcomeBar({required this.right, required this.partial, required this.wrong});

  @override
  Widget build(BuildContext context) {
    final total = (right + partial + wrong).clamp(1, 1 << 30);
    final theme = Theme.of(context);

    Widget segment(int count, Color color) {
      return count == 0
          ? const SizedBox.shrink()
          : Expanded(
              flex: count,
              child: Container(height: 16, color: color),
            );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                segment(right, AppColors.forestGreen),
                segment(partial, AppColors.violet),
                segment(wrong, AppColors.coral),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _Legend(color: AppColors.forestGreen, label: 'Right', count: right),
              _Legend(color: AppColors.violet, label: 'Partly right', count: partial),
              _Legend(color: AppColors.coral, label: 'Wrong', count: wrong),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  const _Legend({required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label ($count)',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color color;
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.color,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.ink, size: 20),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.ink)),
          Text(label,
              style: TextStyle(fontSize: 12.5, color: AppColors.ink.withOpacity(0.7))),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final DecisionCategory category;
  final double accuracy;

  const _CategoryRow({required this.category, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: category.color, shape: BoxShape.circle),
          child: Icon(category.icon, size: 16, color: AppColors.ink),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.label,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: accuracy,
                  minHeight: 6,
                  backgroundColor: AppColors.paper,
                  valueColor: const AlwaysStoppedAnimation(AppColors.forestGreen),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text('${(accuracy * 100).round()}%',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      ],
    );
  }
}

class _ConfidenceRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ConfidenceRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('${value.round()}%',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5)),
      ],
    );
  }
}
