import 'package:flutter/material.dart';
import '../data/store.dart';
import '../models/decision.dart';
import '../theme/app_theme.dart';
import '../widgets/decision_card.dart';
import '../widgets/logo_pill.dart';
import 'detail_screen.dart';
import 'insights_screen.dart';
import 'new_decision_screen.dart';

enum _Filter { all, sealed, revealed }

class HomeScreen extends StatefulWidget {
  final DecisionStore store;
  const HomeScreen({super.key, required this.store});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final all = widget.store.all;
    final dueCount =
        all.where((d) => !d.isResolved && d.isUnlockable).length;

    List<Decision> visible;
    switch (_filter) {
      case _Filter.sealed:
        visible = all.where((d) => !d.isResolved).toList();
        break;
      case _Filter.revealed:
        visible = all.where((d) => d.isResolved).toList();
        break;
      case _Filter.all:
        visible = all;
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NewDecisionScreen(store: widget.store),
            ),
          );
          setState(() {});
        },
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('New decision'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppWordmark(),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => InsightsScreen(store: widget.store),
                              ),
                            );
                            setState(() {});
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.ink,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.query_stats_rounded,
                                color: AppColors.cream, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('Decision\nJournal', style: theme.textTheme.displayLarge),
                    const SizedBox(height: 8),
                    Text(
                      dueCount > 0
                          ? "$dueCount decision${dueCount == 1 ? '' : 's'} ready to be revealed."
                          : "Write what you believe. Find out later if you were right.",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.ink.withOpacity(0.65)),
                    ),
                    const SizedBox(height: 18),
                    _StatsStrip(store: widget.store),
                    const SizedBox(height: 18),
                    _FilterRow(
                      filter: _filter,
                      onChanged: (f) => setState(() => _filter = f),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
            if (visible.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(filter: _filter),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final d = visible[index];
                      return DecisionCard(
                        decision: d,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(
                                store: widget.store,
                                decisionId: d.id,
                              ),
                            ),
                          );
                          setState(() {});
                        },
                      );
                    },
                    childCount: visible.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  final DecisionStore store;
  const _StatsStrip({required this.store});

  @override
  Widget build(BuildContext context) {
    final accuracy = store.accuracy;
    return Row(
      children: [
        Expanded(
          child: _StatPill(
            color: AppColors.yellow,
            value: '${store.sealedCount}',
            label: 'Sealed',
            icon: Icons.lock_clock_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatPill(
            color: AppColors.mint,
            value: '${store.resolvedCount}',
            label: 'Revealed',
            icon: Icons.visibility_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatPill(
            color: AppColors.forestGreen,
            value: store.resolvedCount > 0 ? '${(accuracy * 100).round()}%' : '—',
            label: 'Accuracy',
            icon: Icons.track_changes_rounded,
            dark: true,
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final Color color;
  final String value;
  final String label;
  final IconData icon;
  final bool dark;

  const _StatPill({
    required this.color,
    required this.value,
    required this.label,
    required this.icon,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = dark ? AppColors.cream : AppColors.ink;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: fg.withOpacity(0.85)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: fg)),
          Text(label, style: TextStyle(fontSize: 11, color: fg.withOpacity(0.75))),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final _Filter filter;
  final ValueChanged<_Filter> onChanged;

  const _FilterRow({required this.filter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip(_Filter f, String label) {
      final selected = filter == f;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => onChanged(f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? AppColors.ink : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected ? AppColors.ink : AppColors.ink.withOpacity(0.12),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.cream : AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(_Filter.all, 'All'),
        chip(_Filter.sealed, 'Sealed'),
        chip(_Filter.revealed, 'Revealed'),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final _Filter filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final msg = switch (filter) {
      _Filter.sealed => "Nothing sealed right now.",
      _Filter.revealed => "No revealed decisions yet — check back later.",
      _Filter.all => "No decisions yet. Write your first prediction.",
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty_rounded,
                size: 40, color: AppColors.ink.withOpacity(0.25)),
            const SizedBox(height: 12),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.ink.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }
}
