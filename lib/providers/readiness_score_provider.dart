import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/utils/readiness_score.dart';
import 'concepts_provider.dart';
import 'mastered_provider.dart';
import 'spaced_repetition_provider.dart';

part 'readiness_score_provider.g.dart';

class ReadinessScoreState {
  final int percent;
  final int masteredCount;
  final int totalConcepts;
  final double avgQuality;
  final double categoryCoverage;
  final String timelineText;

  const ReadinessScoreState({
    required this.percent,
    required this.masteredCount,
    required this.totalConcepts,
    required this.avgQuality,
    required this.categoryCoverage,
    required this.timelineText,
  });
}

@riverpod
class ReadinessScore extends _$ReadinessScore {
  @override
  ReadinessScoreState build() {
    final allConcepts = ref.watch(conceptsProvider);
    final categories = ref.watch(categoriesProvider);
    final mastered = ref.watch(masteredProvider);
    final schedules = ref.watch(spacedRepetitionProvider);

    final totalConcepts = allConcepts.length;
    final masteredCount = mastered.length;

    final avgQuality = schedules.isEmpty
        ? 0.0
        : schedules.values
                .map((s) => s.lastQuality)
                .reduce((a, b) => a + b) /
            schedules.length;

    final conceptsById = {
      for (final c in allConcepts) c.id: c,
    };

    final reviewedCategories = schedules.keys
        .map((id) => conceptsById[id]?.category)
        .whereType<String>()
        .toSet();

    final categoryCoverage =
        categories.isEmpty ? 0.0 : reviewedCategories.length / categories.length;

    final percent = readinessScore(
      masteredCount: masteredCount,
      totalConcepts: totalConcepts,
      avgQuality: avgQuality,
      categoryCoverage: categoryCoverage,
    );

    final avgQualityNorm = (avgQuality / 5).clamp(0.0, 1.0);
    final timelineText = _projectedTimelineTo80(
      readinessPercent: percent,
      avgQualityNorm: avgQualityNorm,
    );

    return ReadinessScoreState(
      percent: percent,
      masteredCount: masteredCount,
      totalConcepts: totalConcepts,
      avgQuality: avgQuality,
      categoryCoverage: categoryCoverage,
      timelineText: timelineText,
    );
  }

  String _projectedTimelineTo80({
    required int readinessPercent,
    required double avgQualityNorm,
  }) {
    if (readinessPercent >= 80) return 'Projected: already at 80%+';

    // Approximate daily improvement rate based on how strong the user's recent
    // SM-2 quality looks.
    final dailyImprovement = (0.8 + avgQualityNorm * 2.4).clamp(0.6, 3.2);
    final remaining = 80 - readinessPercent;
    final days = (remaining / dailyImprovement).ceil();
    final weeks = (days / 7).ceil();
    return '~$weeks weeks to 80%';
  }
}

