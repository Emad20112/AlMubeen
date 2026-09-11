class WirdCycle {
  final String id;
  final String wirdId;
  final int cycleNumber;
  final DateTime startDate;
  final DateTime? completedDate;
  final int startPage;
  final int endPage;
  final int actualCompletedPages;
  final DateTime createdAt;

  const WirdCycle({
    required this.id,
    required this.wirdId,
    required this.cycleNumber,
    required this.startDate,
    this.completedDate,
    required this.startPage,
    required this.endPage,
    required this.actualCompletedPages,
    required this.createdAt,
  });
}
