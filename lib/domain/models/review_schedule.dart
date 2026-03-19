class ReviewSchedule {
  final int conceptId;
  final double easiness;
  final int interval;
  final int repetitions;
  final DateTime nextReview;
  final int lastQuality;

  const ReviewSchedule({
    required this.conceptId,
    this.easiness = 2.5,
    this.interval = 1,
    this.repetitions = 0,
    required this.nextReview,
    this.lastQuality = 0,
  });

  ReviewSchedule copyWith({
    int? conceptId,
    double? easiness,
    int? interval,
    int? repetitions,
    DateTime? nextReview,
    int? lastQuality,
  }) {
    return ReviewSchedule(
      conceptId: conceptId ?? this.conceptId,
      easiness: easiness ?? this.easiness,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      nextReview: nextReview ?? this.nextReview,
      lastQuality: lastQuality ?? this.lastQuality,
    );
  }

  Map<String, dynamic> toJson() => {
        'conceptId': conceptId,
        'easiness': easiness,
        'interval': interval,
        'repetitions': repetitions,
        'nextReview': nextReview.toIso8601String(),
        'lastQuality': lastQuality,
      };

  factory ReviewSchedule.fromJson(Map<String, dynamic> json) {
    return ReviewSchedule(
      conceptId: json['conceptId'] as int,
      easiness: (json['easiness'] as num).toDouble(),
      interval: json['interval'] as int,
      repetitions: json['repetitions'] as int,
      nextReview: DateTime.parse(json['nextReview'] as String),
      lastQuality: json['lastQuality'] as int,
    );
  }
}
