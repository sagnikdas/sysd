import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deck_filter_provider.g.dart';

@riverpod
class DeckFilter extends _$DeckFilter {
  @override
  String build() => 'All';

  void select(String category) {
    state = category;
  }
}
