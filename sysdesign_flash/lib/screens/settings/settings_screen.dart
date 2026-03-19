import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/mastered_provider.dart';
import '../../providers/bookmarks_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/user_prefs_provider.dart';
import '../../providers/subscription_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userPrefs = ref.watch(userPrefsProvider);
    final displayLabel = userPrefs.displayName.trim().isEmpty
        ? 'Not set'
        : userPrefs.displayName.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Display name'),
            subtitle: Text(displayLabel),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: const Text('System default'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Daily Goal'),
            subtitle: Text('${userPrefs.dailyGoal} cards / day'),
            onTap: () {},
          ),
          if (kDebugMode)
            SwitchListTile(
              secondary: const Icon(Icons.workspace_premium_outlined),
              title: const Text('Debug: Pro mode'),
              value: ref.watch(subscriptionProvider) == SubscriptionTier.pro,
              onChanged: (value) => ref
                  .read(subscriptionProvider.notifier)
                  .setTier(value ? SubscriptionTier.pro : SubscriptionTier.free),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Purchase'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Reset Progress',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Clear all mastered cards and streak'),
            onTap: () => _confirmReset(context, ref),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will clear all mastered cards, bookmarks, and your streak. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref.read(masteredProvider.notifier).clearAll();
              ref.read(streakProvider.notifier).reset();
              // Clear bookmarks too
              final bookmarkIds =
                  ref.read(bookmarksProvider).toList();
              for (final id in bookmarkIds) {
                ref.read(bookmarksProvider.notifier).toggle(id);
              }
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress reset')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
