/// Composite interview readiness score (0-100).
///
/// - 40% mastered ratio
/// - 40% average SM-2 quality (normalized from 0..5 -> 0..1)
/// - 20% category coverage
int readinessScore({
  required int masteredCount,
  required int totalConcepts,
  required double avgQuality,
  required double categoryCoverage,
}) {
  if (totalConcepts <= 0) return 0;

  final masteredRatio = (masteredCount / totalConcepts).clamp(0.0, 1.0);

  // avgQuality is expected in 0..5 range (but clamp for safety).
  final avgQualityNorm = (avgQuality / 5).clamp(0.0, 1.0);
  final coverageNorm = categoryCoverage.clamp(0.0, 1.0);

  final score01 = masteredRatio * 0.4 + avgQualityNorm * 0.4 + coverageNorm * 0.2;

  return (score01 * 100).round();
}

