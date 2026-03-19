import 'package:flutter_test/flutter_test.dart';
import 'package:sysdesign_flash/core/utils/readiness_score.dart';

void main() {
  test('0 mastered, 0 avgQuality, 0 coverage => 0', () {
    final score = readinessScore(
      masteredCount: 0,
      totalConcepts: 120,
      avgQuality: 0,
      categoryCoverage: 0,
    );
    expect(score, 0);
  });

  test('all mastered, perfect quality, full coverage => 100', () {
    final score = readinessScore(
      masteredCount: 120,
      totalConcepts: 120,
      avgQuality: 5,
      categoryCoverage: 1,
    );
    expect(score, 100);
  });

  test('mixed inputs produce expected composite', () {
    // 50% mastered => 20 points
    // avgQuality=2.5 => 50% normalized => 20 points
    // coverage=0.5 => 10 points
    final score = readinessScore(
      masteredCount: 60,
      totalConcepts: 120,
      avgQuality: 2.5,
      categoryCoverage: 0.5,
    );
    expect(score, 50);
  });
}
