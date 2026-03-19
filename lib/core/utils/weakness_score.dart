import '../../domain/models/concept.dart';
import '../../domain/models/review_schedule.dart';

/// Weakness score for a category (0-1).
///
/// Defined as the ratio of cards in the category whose SM-2 lastQuality is
/// `< 3` (or are unseen, treated as weak).
double weaknessScore(
  String category, {
  required List<Concept> allConcepts,
  required Map<int, ReviewSchedule> schedules,
}) {
  final conceptsInCategory =
      allConcepts.where((c) => c.category == category).toList();
  final total = conceptsInCategory.length;
  if (total == 0) return 0.0;

  // Count "strong" cards: reviewed and lastQuality >= 3.
  final strongCount = conceptsInCategory
      .where((c) {
        final s = schedules[c.id];
        return s != null && s.lastQuality >= 3;
      })
      .length;

  final weakCount = total - strongCount;
  return (weakCount / total).clamp(0.0, 1.0);
}

