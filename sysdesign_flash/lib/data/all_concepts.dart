import '../domain/models/concept.dart';
import 'concepts/concepts_scalability.dart';
import 'concepts/concepts_distributed.dart';
import 'concepts/concepts_databases.dart';
import 'concepts/concepts_messaging.dart';
import 'concepts/concepts_api.dart';
import 'concepts/concepts_reliability.dart';
import 'concepts/concepts_rate_limiting.dart';
import 'concepts/concepts_microservices.dart';
import 'concepts/concepts_security.dart';
import 'concepts/concepts_observability.dart';
import 'concepts/concepts_networking.dart';
import 'concepts/concepts_data_engineering.dart';
import 'concepts/concepts_interview_systems.dart';

final List<Concept> allConcepts = [
  ...conceptsScalability,
  ...conceptsDistributed,
  ...conceptsDatabases,
  ...conceptsMessaging,
  ...conceptsApi,
  ...conceptsReliability,
  ...conceptsRateLimiting,
  ...conceptsMicroservices,
  ...conceptsSecurity,
  ...conceptsObservability,
  ...conceptsNetworking,
  ...conceptsDataEngineering,
  ...conceptsInterviewSystems,
];

const _kCategoryOrder = [
  'Scalability',
  'Distributed Systems',
  'Databases',
  'Messaging',
  'API Design',
  'Reliability',
  'Rate Limiting',
  'Microservices',
  'Security',
  'Observability',
  'Networking',
  'Data Engineering',
  'Interview Systems',
];

List<String> get allCategories {
  final present = allConcepts.map((c) => c.category).toSet();
  return _kCategoryOrder.where(present.contains).toList();
}
