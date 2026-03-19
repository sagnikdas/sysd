import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/concepts_provider.dart';
import '../../providers/deck_filter_provider.dart';
import '../../providers/home_grid_filters_provider.dart';
import '../../providers/mastered_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/user_prefs_provider.dart';
import '../../shared/widgets/pro_gate.dart';
import 'widgets/welcome_banner.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/concept_grid_card.dart';
import 'widgets/difficulty_filter_bar.dart';
import 'widgets/home_search_field.dart';
import 'widgets/smart_queue_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedCategory = ref.watch(deckFilterProvider);
    final selectedDifficulty = ref.watch(difficultyDeckFilterProvider);
    final searchExpanded = ref.watch(homeSearchExpandedProvider);
    final searchQuery = ref.watch(homeSearchQueryProvider);
    final categories = ref.watch(categoriesProvider);
    final concepts = ref.watch(homeGridConceptsProvider);
    final totalConcepts = ref.watch(conceptsProvider).length;
    final mastered = ref.watch(masteredProvider);
    final streak = ref.watch(streakProvider);
    final userPrefs = ref.watch(userPrefsProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Row(
            children: [
              Icon(Icons.architecture, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text('SysDesign Flash'),
            ],
          ),
          actions: [
            if (searchQuery.isNotEmpty && !searchExpanded)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Center(
                  child: Text(
                    '“$searchQuery”',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            IconButton(
              tooltip: searchExpanded ? 'Close search' : 'Search concepts',
              icon: Icon(
                searchExpanded ? Icons.close : Icons.search,
              ),
              onPressed: () {
                final expanded = ref.read(homeSearchExpandedProvider.notifier);
                if (searchExpanded) {
                  expanded.setExpanded(false);
                } else {
                  expanded.setExpanded(true);
                }
              },
            ),
            if (streak.count > 0)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Chip(
                  avatar: const Text('🔥', style: TextStyle(fontSize: 14)),
                  label: Text('${streak.count}'),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        if (searchExpanded)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: const SliverToBoxAdapter(
              child: HomeSearchField(),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          sliver: SliverToBoxAdapter(
            child: WelcomeBanner(
              displayName: userPrefs.displayName,
              dailyGoal: userPrefs.dailyGoal,
              masteredCount: mastered.length,
              totalCount: totalConcepts,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          sliver: const SliverToBoxAdapter(
            child: ProGate(
              featureTitle: 'Smart Queue',
              child: SmartQueueBanner(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: CategoryFilterBar(
            categories: categories,
            selected: selectedCategory,
            onSelected: (cat) =>
                ref.read(deckFilterProvider.notifier).select(cat),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: DifficultyFilterBar(
            selected: selectedDifficulty,
            onSelected: (d) =>
                ref.read(difficultyDeckFilterProvider.notifier).select(d),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        if (concepts.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No concepts match your filters.\nTry another category, difficulty, or search.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final concept = concepts[index];
                  return ConceptGridCard(
                    concept: concept,
                    isMastered: mastered.contains(concept.id),
                    onTap: () => context.push('/study/${concept.category}'),
                  );
                },
                childCount: concepts.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}
