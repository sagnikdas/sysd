import 'package:flutter/material.dart';

import '../../../providers/study_dates_provider.dart';

class HeatmapCalendar extends StatelessWidget {
  final List<StudyDay> days; // oldest -> newest

  const HeatmapCalendar({
    super.key,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxCount =
        days.fold<int>(0, (prev, d) => d.cardsReviewed > prev ? d.cardsReviewed : prev);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity heatmap (30 days)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            // 7 columns looks like a typical calendar heatmap.
            LayoutBuilder(
              builder: (context, constraints) {
                final cellSize = (constraints.maxWidth - 6 * 4) / 7;
                return GridView.builder(
                  itemCount: days.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final count = day.cardsReviewed;

                    final intensity = maxCount == 0 ? 0.0 : count / maxCount;
                    final alpha = count == 0 ? 0.18 : (0.25 + intensity * 0.75);
                    final color = count == 0
                        ? theme.colorScheme.outlineVariant.withValues(alpha: 0.35)
                        : theme.colorScheme.primary.withValues(alpha: alpha);

                    return Tooltip(
                      message:
                          '${day.date.toIso8601String().split('T').first}: $count card(s)',
                      child: Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
