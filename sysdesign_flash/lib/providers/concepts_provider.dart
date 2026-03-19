import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/all_concepts.dart';
import '../domain/models/concept.dart';
import 'deck_filter_provider.dart';
import 'home_grid_filters_provider.dart';

part 'concepts_provider.g.dart';

@riverpod
List<Concept> concepts(Ref ref) {
  return allConcepts;
}

@riverpod
List<String> categories(Ref ref) {
  return allCategories;
}

@riverpod
List<Concept> filteredConcepts(Ref ref, String category) {
  final concepts = ref.watch(conceptsProvider);
  if (category == 'All') return concepts;
  return concepts.where((c) => c.category == category).toList();
}

@riverpod
List<Concept> homeGridConcepts(Ref ref) {
  final category = ref.watch(deckFilterProvider);
  final difficulty = ref.watch(difficultyDeckFilterProvider);
  final query = ref.watch(homeSearchQueryProvider).trim().toLowerCase();

  var list = ref.watch(conceptsProvider);
  if (category != 'All') {
    list = list.where((c) => c.category == category).toList();
  }
  if (difficulty != 'All') {
    final level = switch (difficulty) {
      'Beginner' => Difficulty.beginner,
      'Intermediate' => Difficulty.intermediate,
      'Advanced' => Difficulty.advanced,
      _ => null,
    };
    if (level != null) {
      list = list.where((c) => c.difficulty == level).toList();
    }
  }
  if (query.isNotEmpty) {
    list = list
        .where(
          (c) =>
              c.title.toLowerCase().contains(query) ||
              c.category.toLowerCase().contains(query) ||
              c.tags.any((t) => t.toLowerCase().contains(query)),
        )
        .toList();
  }
  return list;
}
