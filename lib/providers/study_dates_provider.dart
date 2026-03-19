import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_dates_provider.g.dart';

class StudyDay {
  final DateTime date; // midnight-local
  final int cardsReviewed;

  const StudyDay({
    required this.date,
    required this.cardsReviewed,
  });
}

@riverpod
class StudyDates extends _$StudyDates {
  late Box<int> _box;

  @override
  List<StudyDay> build() {
    _box = Hive.box<int>('study_dates');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Oldest -> newest for easier grid rendering.
    return List.generate(30, (i) {
      final date = today.subtract(Duration(days: 29 - i));
      final key = _dateKey(date);
      final count = _box.get(key, defaultValue: 0) as int;
      return StudyDay(date: date, cardsReviewed: count);
    });
  }

  /// Records a single card review for today.
  void recordCardReview({DateTime? now}) {
    final effectiveNow = now ?? DateTime.now();
    final today = DateTime(
      effectiveNow.year,
      effectiveNow.month,
      effectiveNow.day,
    );
    final key = _dateKey(today);

    final current = _box.get(key, defaultValue: 0) as int;
    _box.put(key, current + 1);

    // Update today's value in state without re-building everything.
    final updated = <StudyDay>[];
    for (final day in state) {
      if (_isSameDay(day.date, today)) {
        updated.add(StudyDay(date: day.date, cardsReviewed: current + 1));
      } else {
        updated.add(day);
      }
    }
    state = updated;
  }

  Future<void> clearAll() async {
    await _box.clear();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    state = List.generate(30, (i) {
      final date = today.subtract(Duration(days: 29 - i));
      return StudyDay(date: date, cardsReviewed: 0);
    });
  }

  static String _dateKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.toIso8601String().split('T').first;
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
