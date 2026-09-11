import 'wird_enums.dart';

class WirdDailyProgress {
  final String id;
  final String wirdId;
  final String dateKey; // YYYY-MM-DD
  final int plannedStartPage;
  final int plannedEndPage;
  final int actualStartPage;
  final int actualEndPage;
  final int targetPages;
  final int completedPages;
  final WirdProgressStatus status;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WirdDailyProgress({
    required this.id,
    required this.wirdId,
    required this.dateKey,
    required this.plannedStartPage,
    required this.plannedEndPage,
    required this.actualStartPage,
    required this.actualEndPage,
    required this.targetPages,
    required this.completedPages,
    required this.status,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  WirdDailyProgress copyWith({
    int? actualStartPage,
    int? actualEndPage,
    int? completedPages,
    WirdProgressStatus? status,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return WirdDailyProgress(
      id: id,
      wirdId: wirdId,
      dateKey: dateKey,
      plannedStartPage: plannedStartPage,
      plannedEndPage: plannedEndPage,
      actualStartPage: actualStartPage ?? this.actualStartPage,
      actualEndPage: actualEndPage ?? this.actualEndPage,
      targetPages: targetPages,
      completedPages: completedPages ?? this.completedPages,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
