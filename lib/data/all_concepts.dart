import '../domain/models/concept.dart';
import 'concepts/concepts_scalability.dart';
import 'concepts/concepts_distributed.dart';
import 'concepts/concepts_databases.dart';

final List<Concept> allConcepts = [
  ...conceptsScalability,
  ...conceptsDistributed,
  ...conceptsDatabases,
];

List<String> get allCategories =>
    allConcepts.map((c) => c.category).toSet().toList();
