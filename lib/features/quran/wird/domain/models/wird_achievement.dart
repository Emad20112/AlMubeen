class WirdAchievement {
  final String id;
  final String type;
  final int threshold;
  final bool unlocked;
  final DateTime? unlockedAt;

  const WirdAchievement({
    required this.id,
    required this.type,
    required this.threshold,
    required this.unlocked,
    this.unlockedAt,
  });
}
