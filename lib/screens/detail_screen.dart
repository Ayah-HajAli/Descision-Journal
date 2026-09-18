import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/store.dart';
import '../models/decision.dart';
import '../theme/app_theme.dart';
import '../widgets/logo_pill.dart';
import '../widgets/scallop_edge.dart';
import '../widgets/video_preview_player.dart';

class DetailScreen extends StatefulWidget {
  final DecisionStore store;
  final String decisionId;

  const DetailScreen({super.key, required this.store, required this.decisionId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    final decision = widget.store.all.firstWhere((d) => d.id == widget.decisionId);
    final due = !decision.isResolved && decision.isUnlockable;

    if (decision.isResolved) {
      return _ResolvedView(decision: decision);
    }
    if (due) {
      return _RevealFlow(
        decision: decision,
        onResolved: (status, note) {
          widget.store.resolveDecision(decision.id, status, note);
          setState(() {});
        },
      );
    }
    return _SealedView(decision: decision);
  }
}

/// Locked state: prediction is hidden/blurred behind a frosted seal
/// until the reveal date arrives.
class _SealedView extends StatelessWidget {
  final Decision decision;
  const _SealedView({required this.decision});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = decision.revealDate.difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: AppColors.yellow,
      appBar: AppBar(
        backgroundColor: AppColors.yellow,
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LogoPill(
                background: Colors.white,
                foreground: AppColors.ink,
                label: decision.category.label.toUpperCase(),
              ),
              const SizedBox(height: 18),
              Text(decision.title, style: theme.textTheme.displayLarge),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_rounded,
                          color: AppColors.yellow, size: 36),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      daysLeft <= 0
                          ? "Unlocks today"
                          : "Unlocks in $daysLeft day${daysLeft == 1 ? '' : 's'}",
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('EEEE, MMM d, yyyy').format(decision.revealDate),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.ink.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'YOUR SEALED PREDICTION',
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        decision.prediction,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.white.withOpacity(0.35),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.visibility_off_rounded,
                                  color: AppColors.ink, size: 22),
                              const SizedBox(height: 6),
                              Text(
                                "Hidden from your\nfuture self too",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall
                                    ?.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _MetaRow(
                label: 'CONFIDENCE AT THE TIME',
                value: '${decision.confidence}%',
              ),
              _MetaRow(
                label: 'SEALED ON',
                value: DateFormat('MMM d, yyyy').format(decision.createdAt),
              ),
              if (decision.hasVideo) ...[
                const SizedBox(height: 20),
                Text('VIDEO MESSAGE', style: theme.textTheme.labelSmall),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.ink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.videocam_off_rounded,
                            color: AppColors.yellow, size: 22),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "You also recorded a video — sealed until reveal",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.ink.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                "No peeking. The whole point is finding out whether your gut was right — come back after the unlock date.",
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.ink.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown once the reveal date has passed but the outcome hasn't been
/// recorded yet — the user's prediction becomes visible, and they log
/// what actually happened.
class _RevealFlow extends StatefulWidget {
  final Decision decision;
  final void Function(DecisionStatus status, String note) onResolved;

  const _RevealFlow({required this.decision, required this.onResolved});

  @override
  State<_RevealFlow> createState() => _RevealFlowState();
}

class _RevealFlowState extends State<_RevealFlow> {
  DecisionStatus? _selected;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = widget.decision;

    return Scaffold(
      backgroundColor: AppColors.forestGreen,
      appBar: AppBar(
        backgroundColor: AppColors.forestGreen,
        iconTheme: const IconThemeData(color: AppColors.cream),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LogoPill(
                background: Colors.white24,
                foreground: AppColors.cream,
                label: 'UNSEALED',
              ),
              const SizedBox(height: 18),
              Text(
                d.title,
                style: theme.textTheme.displayLarge?.copyWith(color: AppColors.cream),
              ),
              const SizedBox(height: 8),
              Text(
                "Sealed on ${DateFormat('MMM d, yyyy').format(d.createdAt)}, ${d.confidence}% sure",
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Text('WHAT YOU BELIEVED WOULD HAPPEN',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: Colors.white60)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(d.prediction, style: theme.textTheme.bodyLarge),
              ),
              if (d.hasVideo) ...[
                const SizedBox(height: 16),
                Text('YOUR VIDEO, UNSEALED',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: Colors.white60)),
                const SizedBox(height: 10),
                VideoPreviewPlayer(path: d.videoPath!),
              ],
              const SizedBox(height: 28),
              Text('SO... WHAT ACTUALLY HAPPENED?',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: AppColors.cream)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _OutcomeChip(
                    status: DecisionStatus.right,
                    selected: _selected == DecisionStatus.right,
                    onTap: () => setState(() => _selected = DecisionStatus.right),
                  ),
                  _OutcomeChip(
                    status: DecisionStatus.partial,
                    selected: _selected == DecisionStatus.partial,
                    onTap: () => setState(() => _selected = DecisionStatus.partial),
                  ),
                  _OutcomeChip(
                    status: DecisionStatus.wrong,
                    selected: _selected == DecisionStatus.wrong,
                    onTap: () => setState(() => _selected = DecisionStatus.wrong),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('WHAT ACTUALLY HAPPENED (a few sentences)',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: Colors.white60)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _noteController,
                  maxLines: 5,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText:
                        "Describe the real outcome — this becomes part of your track record.",
                    hintStyle: TextStyle(color: AppColors.ink.withOpacity(0.35)),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_selected != null && _noteController.text.trim().isNotEmpty)
                      ? () => widget.onResolved(_selected!, _noteController.text.trim())
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.cream,
                    disabledBackgroundColor: Colors.white38,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Lock in the outcome',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: AppColors.forestGreenDeep),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutcomeChip extends StatelessWidget {
  final DecisionStatus status;
  final bool selected;
  final VoidCallback onTap;

  const _OutcomeChip({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? status.color : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? status.color : Colors.white38,
            width: 1.5,
          ),
        ),
        child: Text(
          status.label,
          style: TextStyle(
            color: selected ? AppColors.onStatus(status.color) : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}

/// Final state: prediction vs. reality, side by side, with the outcome
/// badge front and center.
class _ResolvedView extends StatelessWidget {
  final Decision decision;
  const _ResolvedView({required this.decision});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = decision.status.color;
    final fg = AppColors.onStatus(bg);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: IconThemeData(color: fg),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: fg == AppColors.cream ? Colors.white24 : AppColors.ink,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  decision.status.label.toUpperCase(),
                  style: TextStyle(
                    color: fg == AppColors.cream ? AppColors.cream : AppColors.cream,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                decision.title,
                style: theme.textTheme.displayLarge?.copyWith(color: fg),
              ),
              const SizedBox(height: 6),
              Text(
                "${decision.category.label} · sealed ${DateFormat('MMM d, yyyy').format(decision.createdAt)} · ${decision.confidence}% sure",
                style: theme.textTheme.bodyMedium?.copyWith(color: fg.withOpacity(0.75)),
              ),
              const SizedBox(height: 26),
              _ComparisonBlock(
                label: 'WHAT YOU PREDICTED',
                text: decision.prediction,
                fg: fg,
              ),
              if (decision.hasVideo) ...[
                const SizedBox(height: 16),
                Text('YOUR VIDEO',
                    style: theme.textTheme.labelSmall?.copyWith(color: fg.withOpacity(0.65))),
                const SizedBox(height: 10),
                VideoPreviewPlayer(path: decision.videoPath!),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: ScallopDivider(color: fg.withOpacity(0.25), height: 12)),
                ],
              ),
              const SizedBox(height: 16),
              _ComparisonBlock(
                label: 'WHAT ACTUALLY HAPPENED',
                text: decision.outcomeNote ?? '',
                fg: fg,
                emphasized: true,
              ),
              const SizedBox(height: 20),
              if (decision.resolvedAt != null)
                Text(
                  'Revealed on ${DateFormat('EEEE, MMM d, yyyy').format(decision.resolvedAt!)}',
                  style: theme.textTheme.labelSmall?.copyWith(color: fg.withOpacity(0.65)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonBlock extends StatelessWidget {
  final String label;
  final String text;
  final Color fg;
  final bool emphasized;

  const _ComparisonBlock({
    required this.label,
    required this.text,
    required this.fg,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: fg.withOpacity(0.65)),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: emphasized ? AppColors.ink : Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: emphasized ? AppColors.cream : AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          Text(value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
