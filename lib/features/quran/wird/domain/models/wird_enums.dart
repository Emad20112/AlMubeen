enum WirdGoalType {
  dailyPages,
  dailyJuz,
  customRange,
  targetDate,
  flexible,
  legacy, // For backward compatibility with existing WirdAmountType
}

enum WirdScheduleType {
  daily,
  selectedWeekdays,
}

enum WirdStatus {
  active,
  paused,
  completed,
  archived,
}

enum WirdProgressStatus {
  pending,
  partial,
  completed,
  missed,
  skipped,
}
