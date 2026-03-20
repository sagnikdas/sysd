import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/utils/sm2_algorithm.dart';
import '../domain/models/review_schedule.dart';

part 'spaced_repetition_provider.g.dart';

@riverpod
class SpacedRepetition extends _$SpacedRepetition {
  late Box<String> _box;

  @override
  Map<int, ReviewSchedule> build() {
    _box = Hive.box<String>('review_schedules');

    final map = <int, ReviewSchedule>{};
    for (final key in _box.keys) {
      if (key is! int) continue;
      final raw = _box.get(key);
      if (raw is! String || raw.isEmpty) continue;

      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        map[key] = ReviewSchedule.fromJson(decoded);
      }
    }

    return map;
  }

  ReviewSchedule recordReview(int conceptId, int quality) {
    final existing = state[conceptId] ??
        ReviewSchedule(
          conceptId: conceptId,
          // First review always schedules 1 day ahead per SM-2.
          nextReview: DateTime.now().add(const Duration(days: 1)),
        );

    final updated = SM2.calculate(existing, quality);

    _box.put(conceptId, jsonEncode(updated.toJson()));
    state = {...state, conceptId: updated};

    return updated;
  }

  /// Concept IDs whose `nextReview` is due now (regardless of mastery).
  List<int> getDueCards() {
    final now = DateTime.now();
    return state.values
        .where((s) => !s.nextReview.isAfter(now))
        .map((s) => s.conceptId)
        .toList();
  }

  Future<void> clearAll() async {
    await _box.clear();
    if (!ref.mounted) return;
    state = {};
  }

  /// Concept IDs whose last response was weak (`lastQuality < 3`).
  /// Note: this includes cards that may already be due.
  List<int> getWeakCards() {
    return state.values
        .where((s) => s.lastQuality < 3)
        .map((s) => s.conceptId)
        .toList();
  }
}

