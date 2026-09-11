import 'wird_enums.dart';

class QuranWird {
  final String id;
  final String name;
  final WirdGoalType goalType;
  final WirdStatus status;
  final int startPage;
  final int endPage;
  final int? pagesPerDay;
  final DateTime startDate;
  final DateTime? targetDate;
  final WirdScheduleType scheduleType;
  final List<int> activeWeekdays;
  final bool isFlexible;
  final bool allowCatchUp;
  final bool autoStartNextKhatma;
  final int currentCycle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const QuranWird({
    required this.id,
    required this.name,
    required this.goalType,
    required this.status,
    required this.startPage,
    required this.endPage,
    this.pagesPerDay,
    required this.startDate,
    this.targetDate,
    required this.scheduleType,
    required this.activeWeekdays,
    this.isFlexible = false,
    this.allowCatchUp = false,
    this.autoStartNextKhatma = false,
    this.currentCycle = 1,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  QuranWird copyWith({
    String? name,
    WirdStatus? status,
    int? startPage,
    int? endPage,
    int? pagesPerDay,
    DateTime? targetDate,
    WirdScheduleType? scheduleType,
    List<int>? activeWeekdays,
    bool? isFlexible,
    bool? allowCatchUp,
    bool? autoStartNextKhatma,
    int? currentCycle,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return QuranWird(
      id: id,
      name: name ?? this.name,
      goalType: goalType,
      status: status ?? this.status,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      pagesPerDay: pagesPerDay ?? this.pagesPerDay,
      startDate: startDate,
      targetDate: targetDate ?? this.targetDate,
      scheduleType: scheduleType ?? this.scheduleType,
      activeWeekdays: activeWeekdays ?? this.activeWeekdays,
      isFlexible: isFlexible ?? this.isFlexible,
      allowCatchUp: allowCatchUp ?? this.allowCatchUp,
      autoStartNextKhatma: autoStartNextKhatma ?? this.autoStartNextKhatma,
      currentCycle: currentCycle ?? this.currentCycle,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
