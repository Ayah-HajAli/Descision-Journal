import 'package:flutter/foundation.dart';
import '../models/decision.dart';

class DecisionStore extends ChangeNotifier {
  final List<Decision> _decisions = [];
  bool hasOnboarded = false;

  DecisionStore() {
    _seed();
  }

  void completeOnboarding() {
    hasOnboarded = true;
    notifyListeners();
  }

  List<Decision> get all => List.unmodifiable(
        [..._decisions]..sort((a, b) {
            // Unresolved-and-due first, then pending-sealed by soonest reveal,
            // then resolved by most recently resolved.
            int rank(Decision d) {
              if (!d.isResolved && d.isUnlockable) return 0;
              if (!d.isResolved) return 1;
              return 2;
            }

            final r = rank(a).compareTo(rank(b));
            if (r != 0) return r;
            if (!a.isResolved && !b.isResolved) {
              return a.revealDate.compareTo(b.revealDate);
            }
            if (a.isResolved && b.isResolved) {
              return (b.resolvedAt ?? b.createdAt)
                  .compareTo(a.resolvedAt ?? a.createdAt);
            }
            return b.createdAt.compareTo(a.createdAt);
          }),
      );

  List<Decision> get pending =>
      all.where((d) => d.status == DecisionStatus.pending).toList();

  List<Decision> get resolved =>
      all.where((d) => d.status != DecisionStatus.pending).toList();

  int get rightCount =>
      _decisions.where((d) => d.status == DecisionStatus.right).length;
  int get wrongCount =>
      _decisions.where((d) => d.status == DecisionStatus.wrong).length;
  int get partialCount =>
      _decisions.where((d) => d.status == DecisionStatus.partial).length;
  int get sealedCount =>
      _decisions.where((d) => d.status == DecisionStatus.pending).length;
  int get resolvedCount => rightCount + wrongCount + partialCount;

  /// Right counts fully, partial counts as half, out of everything resolved.
  double get accuracy {
    if (resolvedCount == 0) return 0;
    return (rightCount + partialCount * 0.5) / resolvedCount;
  }

  /// Accuracy broken down by category, only for categories with at least
  /// one resolved decision.
  Map<DecisionCategory, double> get accuracyByCategory {
    final map = <DecisionCategory, double>{};
    for (final cat in DecisionCategory.values) {
      final catDecisions =
          _decisions.where((d) => d.category == cat && d.isResolved).toList();
      if (catDecisions.isEmpty) continue;
      final right = catDecisions.where((d) => d.status == DecisionStatus.right).length;
      final partial = catDecisions.where((d) => d.status == DecisionStatus.partial).length;
      map[cat] = (right + partial * 0.5) / catDecisions.length;
    }
    return map;
  }

  /// Average confidence stated on decisions that turned out right, vs.
  /// average confidence on ones that turned out wrong — a rough signal
  /// of whether the user's gut-certainty is actually well calibrated.
  double get avgConfidenceWhenRight {
    final rightOnes =
        _decisions.where((d) => d.status == DecisionStatus.right).toList();
    if (rightOnes.isEmpty) return 0;
    return rightOnes.map((d) => d.confidence).reduce((a, b) => a + b) /
        rightOnes.length;
  }

  double get avgConfidenceWhenWrong {
    final wrongOnes =
        _decisions.where((d) => d.status == DecisionStatus.wrong).toList();
    if (wrongOnes.isEmpty) return 0;
    return wrongOnes.map((d) => d.confidence).reduce((a, b) => a + b) /
        wrongOnes.length;
  }

  void addDecision(Decision decision) {
    _decisions.add(decision);
    notifyListeners();
  }

  void resolveDecision(String id, DecisionStatus status, String note) {
    final index = _decisions.indexWhere((d) => d.id == id);
    if (index == -1) return;
    _decisions[index] = _decisions[index].copyWith(
      status: status,
      outcomeNote: note,
      resolvedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void _seed() {
    final now = DateTime.now();
    _decisions.addAll([
      Decision(
        id: 'seed-1',
        title: 'Take the new job offer',
        category: DecisionCategory.career,
        prediction:
            "I believe this role will be more stressful than my current one for the first 3 months, but I'll be glad I took it within a year because of the growth ceiling here.",
        confidence: 70,
        createdAt: now.subtract(const Duration(days: 200)),
        revealDate: now.subtract(const Duration(days: 5)),
      ),
      Decision(
        id: 'seed-2',
        title: 'Move in with my partner',
        category: DecisionCategory.relationships,
        prediction:
            "I think we'll have more small arguments about chores in the first two months, but overall it will strengthen the relationship, not strain it.",
        confidence: 80,
        createdAt: now.subtract(const Duration(days: 260)),
        revealDate: now.subtract(const Duration(days: 90)),
        status: DecisionStatus.right,
        outcomeNote:
            "Pretty much exactly this. We argued about dishes for a month, then settled into a rhythm. Genuinely closer now.",
        resolvedAt: now.subtract(const Duration(days: 88)),
      ),
      Decision(
        id: 'seed-3',
        title: 'Invest a chunk of savings into index funds',
        category: DecisionCategory.money,
        prediction:
            "I predict the market will dip in the next 6 months before recovering, and I'll be tempted to sell but won't.",
        confidence: 55,
        createdAt: now.subtract(const Duration(days: 150)),
        revealDate: now.subtract(const Duration(days: 20)),
        status: DecisionStatus.partial,
        outcomeNote:
            "It dipped like I thought, but I actually did panic-sell a small portion. Half right, half not.",
        resolvedAt: now.subtract(const Duration(days: 18)),
      ),
      Decision(
        id: 'seed-4',
        title: 'Start training for a marathon',
        category: DecisionCategory.health,
        prediction:
            "I believe I'll stay consistent for the first month and then start skipping runs once work gets busy again.",
        confidence: 60,
        createdAt: now.subtract(const Duration(days: 40)),
        revealDate: now.add(const Duration(days: 30)),
      ),
      Decision(
        id: 'seed-5',
        title: 'Turn down the freelance client',
        category: DecisionCategory.money,
        prediction:
            "I think saying no will feel bad short-term but open space for a better client within 2 months.",
        confidence: 65,
        createdAt: now.subtract(const Duration(days: 10)),
        revealDate: now.add(const Duration(days: 55)),
      ),
      Decision(
        id: 'seed-6',
        title: 'Skip the group trip to save money',
        category: DecisionCategory.relationships,
        prediction:
            "I believe I won't regret it and everyone will understand — money is tight right now.",
        confidence: 75,
        createdAt: now.subtract(const Duration(days: 120)),
        revealDate: now.subtract(const Duration(days: 40)),
        status: DecisionStatus.wrong,
        outcomeNote:
            "I regretted it a lot. Everyone had a great time and I felt genuinely left out — should have found a cheaper way to join instead of skipping entirely.",
        resolvedAt: now.subtract(const Duration(days: 38)),
      ),
    ]);
  }
}
