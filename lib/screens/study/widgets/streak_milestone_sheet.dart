import 'package:flutter/material.dart';

class StreakMilestoneSheet extends StatelessWidget {
  final int streakCount;

  const StreakMilestoneSheet({
    super.key,
    required this.streakCount,
  });

  String get _title {
    return switch (streakCount) {
      7 => '7-Day Streak!',
      30 => '30-Day Streak!',
      _ => '${streakCount}-Day Streak!',
    };
  }

  String get _message {
    return switch (streakCount) {
      7 => 'You kept your momentum. One more day and it keeps getting easier.',
      30 => 'Legendary consistency. Your interview readiness is compounding!',
      _ => 'Keep going. Small reps add up fast.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Icon(
            Icons.local_fire_department_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            _title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            _message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Nice!'),
            ),
          ),
        ],
      ),
    );
  }
}

