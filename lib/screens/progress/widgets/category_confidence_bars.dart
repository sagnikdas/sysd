import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/models/concept.dart';
import '../../../domain/models/review_schedule.dart';

class CategoryConfidenceBars extends StatelessWidget {
  final List<String> categories;
  final List<Concept> allConcepts;
  final Map<int, ReviewSchedule> schedules;

  const CategoryConfidenceBars({
    super.key,
    required this.categories,
    required this.allConcepts,
    required this.schedules,
  });

  double _confidenceForCategory(String category) {
    final inCat = allConcepts.where((c) => c.category == category).toList();
    if (inCat.isEmpty) return 0.0;

    final reviewedInCat =
        inCat.where((c) => schedules.containsKey(c.id)).toList();
    if (reviewedInCat.isEmpty) return 0.0;

    final avgQuality = reviewedInCat
            .map((c) => schedules[c.id]!.lastQuality)
            .reduce((a, b) => a + b) /
        reviewedInCat.length;

    return (avgQuality / 5).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mastery confidence by category',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...categories.map((category) {
          final confidence01 = _confidenceForCategory(category);
          final color = AppColors.categoryColor(category);
          final percent = (confidence01 * 100).round();

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                          child: Text(
                            category,
                            style:
                                theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$percent%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: confidence01),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

