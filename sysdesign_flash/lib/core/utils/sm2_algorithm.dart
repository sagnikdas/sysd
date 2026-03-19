import '../../domain/models/review_schedule.dart';

class SM2 {
  /// SM-2 spaced repetition scheduling.
  ///
  /// `quality` is expected in the range 0..5.
  /// - 0..2 are failures/weak responses
  /// - 3..5 are correct responses
  static ReviewSchedule calculate(
    ReviewSchedule s,
    int quality, {
    DateTime? now,
  }) {
    final q = quality.clamp(0, 5);
    final baseNow = now ?? DateTime.now();

    // Update ease factor.
    double ease =
        s.easiness + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    if (ease < 1.3) ease = 1.3;

    // Update repetitions and interval.
    final reps = q < 3 ? 0 : s.repetitions + 1;
    final interval = switch (reps) {
      0 => 1,
      1 => 1,
      2 => 6,
      _ => (s.interval * ease).round(),
    };

    return s.copyWith(
      easiness: ease,
      interval: interval,
      repetitions: reps,
      nextReview: baseNow.add(Duration(days: interval)),
      lastQuality: q,
    );
  }
}

