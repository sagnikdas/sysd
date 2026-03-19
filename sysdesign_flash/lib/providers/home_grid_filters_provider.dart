import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_grid_filters_provider.g.dart';

@riverpod
class DifficultyDeckFilter extends _$DifficultyDeckFilter {
  @override
  String build() => 'All';

  void select(String value) => state = value;
}

@riverpod
class HomeSearchQuery extends _$HomeSearchQuery {
  @override
  String build() => '';

  void setQuery(String value) => state = value;

  void clear() => state = '';
}

@riverpod
class HomeSearchExpanded extends _$HomeSearchExpanded {
  @override
  bool build() => false;

  void setExpanded(bool value) => state = value;

  void toggle() => state = !state;
}
