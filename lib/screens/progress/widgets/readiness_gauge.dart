import 'package:flutter/material.dart';

import '../../../providers/readiness_score_provider.dart';

class ReadinessGauge extends StatelessWidget {
  final ReadinessScoreState readiness;

  const ReadinessGauge({
    super.key,
    required this.readiness,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent01 = readiness.percent / 100.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_graph_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Readiness Score',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${readiness.percent}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percent01),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                borderRadius: BorderRadius.circular(8),
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              readiness.timelineText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
