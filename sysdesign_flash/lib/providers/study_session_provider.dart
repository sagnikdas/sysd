import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/study_session.dart';
import 'concepts_provider.dart';
import 'mastered_provider.dart';
import 'spaced_repetition_provider.dart';
import 'subscription_provider.dart';

part 'study_session_provider.g.dart';

@riverpod
StudySession studySession(Ref ref, {int maxNew = 5}) {
  final tier = ref.watch(subscriptionProvider);
  final mastered = ref.watch(masteredProvider);
  final concepts = ref.watch(conceptsProvider);
  final rng = Random();

  if (tier == SubscriptionTier.pro) {
    final schedules = ref.watch(spacedRepetitionProvider);
    final scheduleIds = schedules.keys.toSet();

    final now = DateTime.now();

    final due = schedules.values
        .where((s) => !s.nextReview.isAfter(now))
        .map((s) => s.conceptId)
        .where((id) => !mastered.contains(id))
        .toList()
      ..shuffle(rng);

    // "Weak" = last response was weak, but not already due.
    final weak = schedules.values
        .where((s) => s.lastQuality < 3 && s.nextReview.isAfter(now))
        .map((s) => s.conceptId)
        .where((id) => !mastered.contains(id))
        .toList()
      ..shuffle(rng);

    final newCards = concepts
        .where((c) => !mastered.contains(c.id))
        .where((c) => !scheduleIds.contains(c.id))
        .take(maxNew)
        .map((c) => c.id)
        .toList()
      ..shuffle(rng);

    final order = [...due, ...weak, ...newCards];
    return StudySession(cardOrder: order, startedAt: DateTime.now());
  }

  // Free tier: sequential order by category, all cards.
  final categoryOrder = ref.watch(categoriesProvider);
  final order = <int>[];

  for (final category in categoryOrder) {
    final inCategory = concepts.where((c) => c.category == category);
    for (final c in inCategory) {
      order.add(c.id);
    }
  }

  // Fallback (in case category list doesn't cover everything).
  if (order.isEmpty) {
    order.addAll(concepts.map((c) => c.id));
  }

  return StudySession(cardOrder: order, startedAt: DateTime.now());
}

