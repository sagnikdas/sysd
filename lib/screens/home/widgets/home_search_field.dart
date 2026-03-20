import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/home_grid_filters_provider.dart';

class HomeSearchField extends ConsumerStatefulWidget {
  const HomeSearchField({super.key});

  @override
  ConsumerState<HomeSearchField> createState() => _HomeSearchFieldState();
}

class _HomeSearchFieldState extends ConsumerState<HomeSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(homeSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = ref.watch(homeSearchQueryProvider);

    // Keep controller in sync if query is cleared externally (e.g. AppBar X).
    if (_controller.text != q) {
      _controller.value = _controller.value.copyWith(text: q);
    }

    return SearchBar(
      hintText: 'Search title, category, or tags',
      controller: _controller,
      leading: const Icon(Icons.search),
      trailing: [
        if (q.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              ref.read(homeSearchQueryProvider.notifier).clear();
              ref.read(homeSearchExpandedProvider.notifier).setExpanded(false);
            },
          ),
      ],
      onChanged: (value) {
        ref.read(homeSearchQueryProvider.notifier).setQuery(value);
      },
      autoFocus: true,
    );
  }
}
