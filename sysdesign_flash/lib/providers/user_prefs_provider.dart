import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_prefs_provider.g.dart';

class UserPrefsState {
  final String displayName;
  final int dailyGoal;

  const UserPrefsState({
    this.displayName = '',
    this.dailyGoal = 10,
  });

  UserPrefsState copyWith({
    String? displayName,
    int? dailyGoal,
  }) {
    return UserPrefsState(
      displayName: displayName ?? this.displayName,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }
}

@Riverpod(keepAlive: true)
class UserPrefs extends _$UserPrefs {
  late Box<dynamic> _profile;
  late Box<dynamic> _settings;

  @override
  UserPrefsState build() {
    _profile = Hive.box('profile');
    _settings = Hive.box('settings');
    final rawName = _profile.get('name');
    final name = rawName is String ? rawName.trim() : '';
    final rawGoal = _settings.get('dailyGoal');
    final goal = rawGoal is int ? rawGoal : 10;
    return UserPrefsState(displayName: name, dailyGoal: goal);
  }

  void setDisplayName(String name) {
    final trimmed = name.trim();
    _profile.put('name', trimmed);
    state = state.copyWith(displayName: trimmed);
  }

  void setDailyGoal(int goal) {
    _settings.put('dailyGoal', goal);
    state = state.copyWith(dailyGoal: goal);
  }

  void ensureJoinDateRecorded() {
    if (_profile.get('joinDate') == null) {
      _profile.put('joinDate', DateTime.now().toIso8601String());
    }
  }
}
