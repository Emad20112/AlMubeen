import 'package:flutter/foundation.dart';

@immutable
class AdhkarUserProgress {
  const AdhkarUserProgress({
    required this.itemId,
    required this.categoryId,
    required this.completedCount,
    required this.isCompleted,
    required this.lastUpdated,
  });

  final String itemId;
  final String categoryId;
  final int completedCount;
  final bool isCompleted;
  final DateTime lastUpdated;

  AdhkarUserProgress copyWith({
    String? itemId,
    String? categoryId,
    int? completedCount,
    bool? isCompleted,
    DateTime? lastUpdated,
  }) {
    return AdhkarUserProgress(
      itemId: itemId ?? this.itemId,
      categoryId: categoryId ?? this.categoryId,
      completedCount: completedCount ?? this.completedCount,
      isCompleted: isCompleted ?? this.isCompleted,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'category_id': categoryId,
      'completed_count': completedCount,
      'is_completed': isCompleted ? 1 : 0,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory AdhkarUserProgress.fromJson(Map<String, dynamic> json) {
    return AdhkarUserProgress(
      itemId: json['item_id'] as String,
      categoryId: json['category_id'] as String,
      completedCount: json['completed_count'] as int,
      isCompleted: json['is_completed'] == 1 || (json['is_completed'] as bool? ?? false),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }
}
