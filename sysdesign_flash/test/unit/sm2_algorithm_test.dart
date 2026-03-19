import 'package:flutter_test/flutter_test.dart';

import 'package:sysdesign_flash/domain/models/review_schedule.dart';
import 'package:sysdesign_flash/core/utils/sm2_algorithm.dart';

void main() {
  test('quality=5 produces increasing intervals', () {
    final now = DateTime(2026, 1, 1, 12, 0, 0);

    final s0 = ReviewSchedule(
      conceptId: 1,
      easiness: 2.5,
      interval: 1,
      repetitions: 0,
      nextReview: now,
      lastQuality: 0,
    );

    final s1 = SM2.calculate(s0, 5, now: now);
    final s2 = SM2.calculate(s1, 5, now: now.add(const Duration(days: 1)));
    final s3 = SM2.calculate(s2, 5, now: now.add(const Duration(days: 2)));

    expect(s1.interval, 1);
    expect(s2.interval, greaterThan(s1.interval));
    expect(s3.interval, greaterThan(s2.interval));
  });

  test('quality=0 resets repetitions and interval=1', () {
    final now = DateTime(2026, 1, 1, 12, 0, 0);

    final s0 = ReviewSchedule(
      conceptId: 1,
      easiness: 2.5,
      interval: 6,
      repetitions: 2,
      nextReview: now,
      lastQuality: 5,
    );

    final s1 = SM2.calculate(s0, 0, now: now);

    expect(s1.repetitions, 0);
    expect(s1.interval, 1);
    expect(s1.lastQuality, 0);
  });

  test('easiness never drops below 1.3', () {
    final now = DateTime(2026, 1, 1, 12, 0, 0);

    final s0 = ReviewSchedule(
      conceptId: 1,
      easiness: 1.1,
      interval: 1,
      repetitions: 0,
      nextReview: now,
      lastQuality: 0,
    );

    final s1 = SM2.calculate(s0, 0, now: now);
    expect(s1.easiness, greaterThanOrEqualTo(1.3));
  });

  test('first review always yields interval=1', () {
    final now = DateTime(2026, 1, 1, 12, 0, 0);

    final sBase = ReviewSchedule(
      conceptId: 1,
      easiness: 2.5,
      interval: 10,
      repetitions: 0,
      nextReview: now,
      lastQuality: 0,
    );

    final sGotIt = SM2.calculate(sBase, 4, now: now);
    final sReviewAgain = SM2.calculate(sBase, 1, now: now);

    expect(sGotIt.interval, 1);
    expect(sReviewAgain.interval, 1);
  });
}

