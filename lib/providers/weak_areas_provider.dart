import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/utils/weakness_score.dart';
import 'concepts_provider.dart';
import 'spaced_repetition_provider.dart';

part 'weak_areas_provider.g.dart';

class WeakArea {
  final String category;
  final double weaknessRatio; // 0..1 (1 == weakest)

  const WeakArea({
    required this.category,
    required this.weaknessRatio,
  });
}

@riverpod
class WeakAreas extends _$WeakAreas {
  @override
  List<WeakArea> build() {
    final allConcepts = ref.watch(conceptsProvider);
    final categories = ref.watch(categoriesProvider);
    final schedules = ref.watch(spacedRepetitionProvider);

    final scored = <WeakArea>[];
    for (final category in categories) {
      final score = weaknessScore(
        category,
        allConcepts: allConcepts,
        schedules: schedules,
      );
      scored.add(WeakArea(category: category, weaknessRatio: score));
    }

    scored.sort((a, b) => b.weaknessRatio.compareTo(a.weaknessRatio));
    return scored.take(2).toList();
  }
}
