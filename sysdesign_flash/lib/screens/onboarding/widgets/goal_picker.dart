import 'package:flutter/material.dart';

/// Three daily card goals with animated selection (5 / 10 / 20).
class GoalPicker extends StatelessWidget {
  const GoalPicker({
    super.key,
    required this.selectedGoal,
    required this.onChanged,
  });

  final int selectedGoal;
  final ValueChanged<int> onChanged;

  static const options = [5, 10, 20];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final g in options)
          _GoalOptionTile(
            count: g,
            selected: selectedGoal == g,
            onTap: () => onChanged(g),
          ),
      ],
    );
  }
}

class _GoalOptionTile extends StatelessWidget {
  const _GoalOptionTile({
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final int count;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon => switch (count) {
        5 => Icons.speed_outlined,
        10 => Icons.auto_stories_outlined,
        _ => Icons.library_books_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return AnimatedScale(
      scale: selected ? 1.04 : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: Material(
        color: selected
            ? color.primaryContainer
            : color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? color.primary : color.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _icon,
                  size: 32,
                  color: selected ? color.onPrimaryContainer : color.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  '$count',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? color.onPrimaryContainer
                        : color.onSurface,
                  ),
                ),
                Text(
                  'cards / day',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: selected
                        ? color.onPrimaryContainer.withValues(alpha: 0.85)
                        : color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
