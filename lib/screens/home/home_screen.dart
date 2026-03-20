import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/concepts_provider.dart';
import '../../providers/deck_filter_provider.dart';
import '../../providers/home_grid_filters_provider.dart';
import '../../providers/mastered_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/weak_areas_provider.dart';
import '../../providers/user_prefs_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/pro_gate.dart';
import 'widgets/welcome_banner.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/concept_grid_card.dart';
import 'widgets/difficulty_filter_bar.dart';
import 'widgets/home_search_field.dart';
import 'widgets/interview_simulation_banner.dart';
import 'widgets/streak_reset_warning_sheet.dart';
import 'widgets/smart_queue_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _resetWarningScheduled = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowResetWarning();
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _maybeShowResetWarning() {
    if (_resetWarningScheduled) return;
    _resetWarningScheduled = true;

    final streak = ref.read(streakProvider);
    if (streak.count <= 0 || streak.lastStudyDate == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      streak.lastStudyDate!.year,
      streak.lastStudyDate!.month,
      streak.lastStudyDate!.day,
    );

    // Streak is safe if last study was yesterday; warn only after a missed day.
    final yesterday = today.subtract(const Duration(days: 1));
    final missed = !(_isSameDay(last, yesterday) || _isSameDay(last, today));
    if (!missed) return;

    if (streak.lastResetWarningShownOn != null &&
        _isSameDay(streak.lastResetWarningShownOn!, today)) {
      return;
    }

    // Mark immediately to prevent double-popping due to rebuilds.
    ref.read(streakProvider.notifier).markResetWarningShownForToday();

    final subscriptionTier = ref.read(subscriptionProvider);
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => StreakResetWarningSheet(
        streakCount: streak.count,
        isPro: subscriptionTier == SubscriptionTier.pro,
        onStart: () {
          Navigator.of(context).pop();
          context.push(
            subscriptionTier == SubscriptionTier.pro
                ? '/study/smart'
                : '/study/all',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
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
    final subscriptionTier = ref.watch(subscriptionProvider);
    final weakAreas = ref.watch(weakAreasProvider);
    final userPrefs = ref.watch(userPrefsProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Row(
            children: [
              Hero(
                tag: 'app_logo',
                child: Icon(
                  Icons.architecture,
                  color: theme.colorScheme.primary,
                ),
              ),
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
              icon: Icon(searchExpanded ? Icons.close : Icons.search),
              onPressed: () {
                final expanded = ref.read(homeSearchExpandedProvider.notifier);
                if (searchExpanded) {
                  expanded.setExpanded(false);
                  ref.read(homeSearchQueryProvider.notifier).setQuery('');
                } else {
                  expanded.setExpanded(true);
                }
              },
            ),
            if (streak.count > 0)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(streak.count),
                  tween: Tween<double>(begin: 1.25, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                  builder: (context, scale, _) => Transform.scale(
                    scale: scale,
                    child: Chip(
                      avatar: const Text('🔥', style: TextStyle(fontSize: 14)),
                      label: Text('${streak.count}'),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  ),
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
            sliver: const SliverToBoxAdapter(child: HomeSearchField()),
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
              featureDescription:
                  'Prioritize due, weak, and new cards with SM-2 scheduling.',
              child: SmartQueueBanner(),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          sliver: const SliverToBoxAdapter(
            child: ProGate(
              featureTitle: 'Interview Simulation',
              featureDescription:
                  'Run timed scenarios with hints and post-session review.',
              child: InterviewSimulationBanner(),
            ),
          ),
        ),
        if (subscriptionTier == SubscriptionTier.pro && weakAreas.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            sliver: SliverToBoxAdapter(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.flag,
                            size: 22,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Focus Areas',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...weakAreas.map((weak) {
                        final color = AppColors.categoryColor(weak.category);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      weak.category,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Weakness: ${(weak.weaknessRatio * 100).round()}%',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              FilledButton(
                                onPressed: () =>
                                    context.push('/study/${weak.category}'),
                                child: const Text('Study now'),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
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
            child: const EmptyState(
              icon: Icons.filter_alt_off_outlined,
              title: 'No cards in this category',
              subtitle:
                  'No concepts match your current filters. Try another category, difficulty, or search.',
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
              delegate: SliverChildBuilderDelegate((context, index) {
                final concept = concepts[index];
                return ConceptGridCard(
                  concept: concept,
                  isMastered: mastered.contains(concept.id),
                  onTap: () {
                    final categoryList = ref.read(
                      filteredConceptsProvider(concept.category),
                    );
                    final startIdx = categoryList.indexWhere(
                      (c) => c.id == concept.id,
                    );
                    final ids = categoryList
                        .sublist(startIdx < 0 ? 0 : startIdx)
                        .map((c) => c.id)
                        .toList();
                    context.push('/study/concepts', extra: ids);
                  },
                );
              }, childCount: concepts.length),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}
