import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/mastered_provider.dart';
import '../../providers/bookmarks_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/study_dates_provider.dart';
import '../../providers/user_prefs_provider.dart';
import '../../providers/spaced_repetition_provider.dart';
import '../../providers/auth_provider.dart';
import '../onboarding/widgets/goal_picker.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userPrefs = ref.watch(userPrefsProvider);
    final authState = ref.watch(authControllerProvider);
    final bookmarks = ref.watch(bookmarksProvider);
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
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => _editDisplayName(context, ref, userPrefs.displayName),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: const Text('Account & Cloud Sync'),
            subtitle: Text(
              authState.user?.email ??
                  (authState.isConfigured
                      ? 'Not signed in'
                      : 'Cloud sync not configured in this build'),
            ),
            onTap: () => context.push('/auth'),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(switch (userPrefs.themeMode) {
              ThemeModePreference.light => 'Light',
              ThemeModePreference.dark => 'Dark',
              ThemeModePreference.system => 'System',
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<ThemeModePreference>(
              selected: {userPrefs.themeMode},
              onSelectionChanged: (selection) {
                ref
                    .read(userPrefsProvider.notifier)
                    .setThemeMode(selection.first);
              },
              segments: const [
                ButtonSegment(
                  value: ThemeModePreference.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeModePreference.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeModePreference.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_outline),
            title: const Text('Bookmarks'),
            subtitle: Text(
              bookmarks.isEmpty
                  ? 'No bookmarked cards'
                  : '${bookmarks.length} card${bookmarks.length == 1 ? '' : 's'}',
            ),
            trailing: bookmarks.isNotEmpty
                ? const Icon(Icons.chevron_right)
                : null,
            onTap: bookmarks.isNotEmpty
                ? () => context.push('/study/concepts', extra: bookmarks.toList())
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Daily Goal'),
            subtitle: Text('${userPrefs.dailyGoal} cards / day'),
            onTap: () => _pickDailyGoal(context, ref, userPrefs.dailyGoal),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            title: Text(
              'Reset Progress',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Clear all progress, bookmarks, and streak'),
            onTap: () => _confirmReset(context, ref),
          ),
          const Divider(),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data != null
                  ? '${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                  : '—';
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: Text(version),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send Feedback'),
            subtitle: const Text('sagnikd91@gmail.com'),
            onTap: () async {
              final uri = Uri.parse(
                'mailto:sagnikd91@gmail.com?subject=${Uri.encodeComponent('SysDesign Flash: Feedback')}',
              );
              if (!await launchUrl(uri)) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Could not open mail app. Email sagnikd91@gmail.com directly.',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _editDisplayName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final controller = TextEditingController(text: current.trim());
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Display name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: const InputDecoration(hintText: 'Your name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref
          .read(userPrefsProvider.notifier)
          .setDisplayName(controller.text.trim());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
  }

  Future<void> _pickDailyGoal(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    int selected = current;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Daily Goal'),
          content: GoalPicker(
            selectedGoal: selected,
            onChanged: (g) => setState(() => selected = g),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      ref.read(userPrefsProvider.notifier).setDailyGoal(selected);
    }
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will clear all mastered cards, bookmarks, spaced repetition '
          'data, and your streak. This action cannot be undone.',
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
            onPressed: () async {
              await ref.read(masteredProvider.notifier).clearAll();
              await ref.read(streakProvider.notifier).reset();
              await ref.read(spacedRepetitionProvider.notifier).clearAll();
              await ref.read(studyDatesProvider.notifier).clearAll();
              await ref.read(bookmarksProvider.notifier).clearAll();
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Progress reset')));
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
