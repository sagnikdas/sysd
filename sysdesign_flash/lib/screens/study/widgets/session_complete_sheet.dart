import 'package:flutter/material.dart';

class SessionCompleteSheet extends StatelessWidget {
  final int totalCards;
  final int gotItCount;
  final Duration elapsed;
  final VoidCallback onDone;

  const SessionCompleteSheet({
    super.key,
    required this.totalCards,
    required this.gotItCount,
    required this.elapsed,
    required this.onDone,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reviewCount = totalCards - gotItCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Icon(
            Icons.check_circle,
            size: 56,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Session Complete!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                icon: Icons.style,
                value: '$totalCards',
                label: 'Reviewed',
                theme: theme,
              ),
              _StatItem(
                icon: Icons.check,
                value: '$gotItCount',
                label: 'Got It',
                color: Colors.green,
                theme: theme,
              ),
              _StatItem(
                icon: Icons.refresh,
                value: '$reviewCount',
                label: 'Review',
                color: Colors.orange,
                theme: theme,
              ),
              _StatItem(
                icon: Icons.timer_outlined,
                value: _formatDuration(elapsed),
                label: 'Time',
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onDone,
              child: const Text('Back to Home'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;
  final ThemeData theme;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? theme.colorScheme.onSurface;

    return Column(
      children: [
        Icon(icon, color: effectiveColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: effectiveColor,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
