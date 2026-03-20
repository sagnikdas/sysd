import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/concepts_provider.dart';
import '../../providers/mastered_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/study_dates_provider.dart';
import '../../providers/spaced_repetition_provider.dart';
import '../../providers/readiness_score_provider.dart';
import 'widgets/stats_overview.dart';
import 'widgets/category_progress_card.dart';
import 'widgets/readiness_gauge.dart';
import 'widgets/heatmap_calendar.dart';
import 'widgets/category_confidence_bars.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allConceptsList = ref.watch(conceptsProvider);
    final mastered = ref.watch(masteredProvider);
    final streak = ref.watch(streakProvider);
    final categories = ref.watch(categoriesProvider);
    final schedules = ref.watch(spacedRepetitionProvider);
    final readiness = ref.watch(readinessScoreProvider);
    final studyDays = ref.watch(studyDatesProvider);

    final total = allConceptsList.length;
    final masteredCount = mastered.length;
    final remaining = total - masteredCount;

    return CustomScrollView(
      slivers: [
        const SliverAppBar(floating: true, title: Text('Progress')),
        // Stats overview
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          sliver: SliverToBoxAdapter(
            child: StatsOverview(
              total: total,
              mastered: masteredCount,
              remaining: remaining,
              streak: streak.count,
            ),
          ),
        ),
        // Overall progress
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Overall Mastery',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          total > 0
                              ? '${(masteredCount / total * 100).round()}%'
                              : '0%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: total > 0 ? masteredCount / total : 0.0,
                      ),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // Per-category breakdown
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Text(
              'By Category',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final category = categories[index];
              final catConcepts = allConceptsList
                  .where((c) => c.category == category)
                  .toList();
              final catMastered = catConcepts
                  .where((c) => mastered.contains(c.id))
                  .length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CategoryProgressCard(
                  category: category,
                  mastered: catMastered,
                  total: catConcepts.length,
                  delay: index * 50,
                  onTap: () => context.push('/study/$category'),
                ),
              );
            }, childCount: categories.length),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: ReadinessGauge(readiness: readiness),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(child: HeatmapCalendar(days: studyDays)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          sliver: SliverToBoxAdapter(
            child: CategoryConfidenceBars(
              categories: categories,
              allConcepts: allConceptsList,
              schedules: schedules,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}
