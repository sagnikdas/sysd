import 'package:flutter/material.dart';

class WelcomeBanner extends StatelessWidget {
  final String displayName;
  final int dailyGoal;
  final int masteredCount;
  final int totalCount;

  const WelcomeBanner({
    super.key,
    required this.displayName,
    required this.dailyGoal,
    required this.masteredCount,
    required this.totalCount,
  });

  String get _greeting {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) return 'Hey there!';
    final first = trimmed.split(RegExp(r'\s+')).first;
    return 'Hey, $first!';
  }

  String _motivationalLine(double ratio) {
    if (ratio <= 0) {
      return 'Start your system design journey — one card at a time.';
    }
    if (ratio < 0.25) {
      return 'Nice start — consistency beats intensity.';
    }
    if (ratio < 0.5) {
      return 'You\'re building real momentum. Keep going!';
    }
    if (ratio < 0.75) {
      return 'Solid progress — you\'re in the top half of the deck.';
    }
    return 'Outstanding — push for full mastery!';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalCount > 0 ? masteredCount / totalCount : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _motivationalLine(progress),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Daily goal: $dailyGoal cards',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                borderRadius: BorderRadius.circular(4),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$masteredCount / $totalCount mastered',
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
