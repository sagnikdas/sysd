import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/study_session.dart';
import 'concepts_provider.dart';
import 'mastered_provider.dart';
import 'spaced_repetition_provider.dart';

part 'study_session_provider.g.dart';

@riverpod
StudySession studySession(Ref ref, {int maxNew = 5}) {
  final mastered = ref.watch(masteredProvider);
  final concepts = ref.watch(conceptsProvider);
  final schedules = ref.watch(spacedRepetitionProvider);
  final rng = Random();

  final scheduleIds = schedules.keys.toSet();
  final now = DateTime.now();

  final due = schedules.values
      .where((s) => !s.nextReview.isAfter(now))
      .map((s) => s.conceptId)
      .toList()
    ..shuffle(rng);

  final weak = schedules.values
      .where((s) => s.lastQuality < 3 && s.nextReview.isAfter(now))
      .map((s) => s.conceptId)
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
