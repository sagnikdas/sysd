import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/all_concepts.dart';
import '../domain/models/concept.dart';

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
