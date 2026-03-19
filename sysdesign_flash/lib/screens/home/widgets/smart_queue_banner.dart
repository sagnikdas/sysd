import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/concepts_provider.dart';
import '../../../providers/mastered_provider.dart';
import '../../../providers/spaced_repetition_provider.dart';

class SmartQueueBanner extends ConsumerWidget {
  const SmartQueueBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final theme = Theme.of(context);

    final schedules = ref.watch(spacedRepetitionProvider);
    final mastered = ref.watch(masteredProvider);
    final concepts = ref.watch(conceptsProvider);

    final dueCount = schedules.values
        .where((s) => !s.nextReview.isAfter(now))
        .map((s) => s.conceptId)
        .length;

    final weakCount = schedules.values
        .where((s) => s.lastQuality < 3 && s.nextReview.isAfter(now))
        .map((s) => s.conceptId)
        .length;

    final scheduledIds = schedules.keys.toSet();
    final newCount = concepts
        .where((c) => !mastered.contains(c.id))
        .where((c) => !scheduledIds.contains(c.id))
        .length;

    const maxNew = 5;
    final newInQueue = newCount < maxNew ? newCount : maxNew;

    final totalQueued = dueCount + weakCount + newInQueue;

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Queue',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              totalQueued == 0 ? 'All caught up' : '$totalQueued queued',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        children: [
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(
                icon: Icons.calendar_today_outlined,
                label: 'Due today: $dueCount',
              ),
              _StatChip(
                icon: Icons.warning_amber_outlined,
                label: 'Weak: $weakCount',
              ),
              _StatChip(
                icon: Icons.new_releases_outlined,
                label: 'New: $newInQueue',
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: totalQueued == 0
                  ? null
                  : () => context.push('/study/smart'),
              child: Text(
                totalQueued == 0
                    ? 'All caught up'
                    : 'Start Smart Session ($totalQueued)',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

