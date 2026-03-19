import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'streak_provider.g.dart';

class StreakState {
  final int count;
  final DateTime? lastStudyDate;
  final DateTime? lastResetWarningShownOn; // midnight-local

  const StreakState({
    this.count = 0,
    this.lastStudyDate,
    this.lastResetWarningShownOn,
  });
}

@riverpod
class Streak extends _$Streak {
  late Box<dynamic> _box;

  @override
  StreakState build() {
    _box = Hive.box('profile');
    final count = _box.get('streak', defaultValue: 0) as int;
    final lastStr = _box.get('lastStudyDate') as String?;
    final lastDate = lastStr != null ? DateTime.tryParse(lastStr) : null;
    final warnStr = _box.get('streakResetWarningShownOn') as String?;
    final warnDate = warnStr != null ? DateTime.tryParse(warnStr) : null;

    return StreakState(
      count: count,
      lastStudyDate: lastDate,
      lastResetWarningShownOn: warnDate,
    );
  }

  /// Call this when user completes a study action.
  /// Returns new streak count if streak was incremented (new day), else null.
  int? recordStudy() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = state.lastStudyDate;

    if (last != null) {
      final lastDay = DateTime(last.year, last.month, last.day);
      if (lastDay == today) {
        // Already studied today — no change
        return null;
      }
      final yesterday = today.subtract(const Duration(days: 1));
      if (lastDay == yesterday) {
        // Studied yesterday — increment
        final newCount = state.count + 1;
        _persist(newCount, today);
        state = StreakState(count: newCount, lastStudyDate: today);
        return newCount;
      }
    }

    // First study or missed a day — start at 1
    _persist(1, today);
    state = StreakState(count: 1, lastStudyDate: today);
    return 1;
  }

  void reset() {
    _persist(0, null);
    state = const StreakState(count: 0);
  }

  void markResetWarningShownForToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _box.put('streakResetWarningShownOn', today.toIso8601String());
    state = StreakState(
      count: state.count,
      lastStudyDate: state.lastStudyDate,
      lastResetWarningShownOn: today,
    );
  }

  void _persist(int count, DateTime? date) {
    _box.put('streak', count);
    if (date != null) {
      _box.put('lastStudyDate', date.toIso8601String());
    } else {
      _box.delete('lastStudyDate');
    }
  }
}
