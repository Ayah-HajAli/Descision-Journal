import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum DecisionStatus { pending, right, wrong, partial }

enum DecisionCategory { career, money, relationships, health, other }

extension DecisionCategoryX on DecisionCategory {
  String get label {
    switch (this) {
      case DecisionCategory.career:
        return 'Career';
      case DecisionCategory.money:
        return 'Money';
      case DecisionCategory.relationships:
        return 'Relationships';
      case DecisionCategory.health:
        return 'Health';
      case DecisionCategory.other:
        return 'Other';
    }
  }

  Color get color => AppColors.categoryPalette[index % AppColors.categoryPalette.length];

  IconData get icon {
    switch (this) {
      case DecisionCategory.career:
        return Icons.work_rounded;
      case DecisionCategory.money:
        return Icons.savings_rounded;
      case DecisionCategory.relationships:
        return Icons.favorite_rounded;
      case DecisionCategory.health:
        return Icons.self_improvement_rounded;
      case DecisionCategory.other:
        return Icons.auto_awesome_rounded;
    }
  }
}

extension DecisionStatusX on DecisionStatus {
  String get label {
    switch (this) {
      case DecisionStatus.pending:
        return 'Sealed';
      case DecisionStatus.right:
        return 'I was right';
      case DecisionStatus.wrong:
        return 'I was wrong';
      case DecisionStatus.partial:
        return 'Partly right';
    }
  }

  Color get color {
    switch (this) {
      case DecisionStatus.pending:
        return AppColors.statusPending;
      case DecisionStatus.right:
        return AppColors.statusRight;
      case DecisionStatus.wrong:
        return AppColors.statusWrong;
      case DecisionStatus.partial:
        return AppColors.statusPartial;
    }
  }
}

class Decision {
  final String id;
  final String title;
  final DecisionCategory category;
  final String prediction;
  final int confidence; // 0-100, how sure they were
  final DateTime createdAt;
  final DateTime revealDate;
  final DecisionStatus status;
  final String? outcomeNote;
  final DateTime? resolvedAt;
  final String? videoPath;

  const Decision({
    required this.id,
    required this.title,
    required this.category,
    required this.prediction,
    required this.confidence,
    required this.createdAt,
    required this.revealDate,
    this.status = DecisionStatus.pending,
    this.outcomeNote,
    this.resolvedAt,
    this.videoPath,
  });

  bool get isUnlockable => DateTime.now().isAfter(revealDate);
  bool get isResolved => status != DecisionStatus.pending;
  bool get hasVideo => videoPath != null && videoPath!.isNotEmpty;

  Decision copyWith({
    DecisionStatus? status,
    String? outcomeNote,
    DateTime? resolvedAt,
  }) {
    return Decision(
      id: id,
      title: title,
      category: category,
      prediction: prediction,
      confidence: confidence,
      createdAt: createdAt,
      revealDate: revealDate,
      status: status ?? this.status,
      outcomeNote: outcomeNote ?? this.outcomeNote,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      videoPath: videoPath,
    );
  }
}
