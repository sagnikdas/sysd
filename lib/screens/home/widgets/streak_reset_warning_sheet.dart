import 'package:flutter/material.dart';

class StreakResetWarningSheet extends StatelessWidget {
  final int streakCount;
  final bool isPro;
  final VoidCallback onStart;

  const StreakResetWarningSheet({
    super.key,
    required this.streakCount,
    required this.isPro,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = isPro ? 'Streak reset incoming' : 'Streak reset incoming';
    final cta = isPro ? 'Start smart session' : 'Start studying';

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
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'You are currently on a ${streakCount}-day streak, but you missed a day. When you study again, your streak will reset to 1 unless you keep going from here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onStart,
              child: Text(cta),
            ),
          ),
        ],
      ),
    );
  }
}

