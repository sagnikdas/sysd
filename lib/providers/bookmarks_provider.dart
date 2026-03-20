import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bookmarks_provider.g.dart';

@riverpod
class Bookmarks extends _$Bookmarks {
  late Box<bool> _box;

  @override
  Set<int> build() {
    _box = Hive.box<bool>('bookmarks');
    return _box.keys.cast<int>().where((k) => _box.get(k) == true).toSet();
  }

  void toggle(int conceptId) {
    final current = state.contains(conceptId);
    if (current) {
      _box.delete(conceptId);
      state = {...state}..remove(conceptId);
    } else {
      _box.put(conceptId, true);
      state = {...state, conceptId};
    }
  }

  Future<void> clearAll() async {
    await _box.clear();
    if (!ref.mounted) return;
    state = {};
  }
}
