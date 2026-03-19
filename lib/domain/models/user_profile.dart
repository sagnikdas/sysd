class UserProfile {
  final String name;
  final int streak;
  final DateTime joinDate;
  final int dailyGoal;
  final DateTime? lastStudyDate;

  const UserProfile({
    required this.name,
    this.streak = 0,
    required this.joinDate,
    this.dailyGoal = 10,
    this.lastStudyDate,
  });

  UserProfile copyWith({
    String? name,
    int? streak,
    DateTime? joinDate,
    int? dailyGoal,
    DateTime? lastStudyDate,
  }) {
    return UserProfile(
      name: name ?? this.name,
      streak: streak ?? this.streak,
      joinDate: joinDate ?? this.joinDate,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }
}
